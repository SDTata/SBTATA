//
//  EMASCurlUrlSchemeHandler.m
//  EMASCurl
//
//  Created by xuyecan on 2025/2/3.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <os/lock.h>
#import "EMASCurlWebUtils.h"
#import "EMASCurlWebNetworkManager.h"
#import "EMASCurlWebUrlSchemeHandler.h"
#import "WKWebViewConfiguration+Loader.h"
#import "EMASCurlWebLogger.h"
#import "AFHTTPSessionManager.h"
#import "AFURLSessionManager.h"
#import "HttpDnsNSURLProtocolImpl.h"
#import "EMASCurlWebProgressiveRender.h"
#import "EMASCurlProtocol.h"
#import "MyDNSResolver.h"
#import "EMASCurlWebPerformanceMonitor.h"

@interface EMASCurlWebUrlSchemeHandler () {
    os_unfair_lock _taskMaplock;
    NSHashTable *_taskHashTable;
}

@property (nonatomic, strong) EMASCurlWebNetworkManager *networkSession;

@end

static AFHTTPSessionManager *manager;
static dispatch_queue_t s_urlSchemeTaskQueue;

@implementation EMASCurlWebUrlSchemeHandler

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        _taskMaplock = OS_UNFAIR_LOCK_INIT;
        _taskHashTable = [NSHashTable weakObjectsHashTable];

        // 初始化为每个host缓存独立session的字典
        _hostSessionManagers = [NSMutableDictionary dictionary];
        _defaultSessionConfiguration = configuration;

        _networkSession = [[EMASCurlWebNetworkManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

- (void)dealloc {
    // ✅ 关键：页面销毁时立即取消所有网络任务，释放所有资源
    [_networkSession cancelAllTasks];

    // ✅ 清空任务字典
    [_hostSessionManagers removeAllObjects];
    _hostSessionManagers = nil;

    NSLog(@"🛑 EMASCurlWebUrlSchemeHandler dealloc: 已清理所有资源");
}

#pragma mark - Session Manager Factory

// ✅ 判断JS是否是非关键脚本（统计、分析、跟踪等）
- (BOOL)isOptionalJavaScript:(NSURL *)url {
    NSString *absoluteString = url.absoluteString.lowercaseString;
    NSString *host = url.host.lowercaseString;

    // 统计分析脚本 - 这些通常是非关键的，可以快速超时
    NSArray *optionalDomains = @[
        @"tongji",           // 百度统计
        @"uv60",             // 统计脚本
        @"google-analytics", // Google分析
        @"gtag",             // Google Tag Manager
        @"facebook.com",     // Facebook Pixel
        @"mixpanel",         // Mixpanel分析
        @"segment",          // Segment分析
        @"hotjar",           // Hotjar分析
        @"fullstory",        // FullStory分析
        @"intercom",         // Intercom
        @"drift",            // Drift
        @"zendesk",          // Zendesk
        @"appcenter",        // AppCenter
        @"sentry",           // Sentry错误追踪
        @"newrelic",         // New Relic
        @"amplitude",        // Amplitude分析
    ];

    for (NSString *domain in optionalDomains) {
        if ([absoluteString containsString:domain] || [host containsString:domain]) {
            return YES;  // 这是可选脚本
        }
    }

    return NO;  // 这是必须脚本
}

// ✅ 根据资源类型和优先级判断合适的请求超时时间
- (NSTimeInterval)requestTimeoutForURL:(NSURL *)url {
    NSString *path = url.path.lowercaseString;
    NSString *lastComponent = url.lastPathComponent.lowercaseString;

    // ✅ 非关键 JS（统计、分析等）：极短超时，快速失败，不阻塞页面
    if ([path hasSuffix:@".js"] && [self isOptionalJavaScript:url]) {
        return 0.8;  // 统计脚本：0.8秒超时（快速失败，最小化对页面的阻塞）
    }

    // 关键资源：HTML、API、必要 JS、CSS - 给更多时间
    if ([path hasSuffix:@".php"] ||
        [path hasSuffix:@".html"] ||
        [lastComponent isEqualToString:@"api.php"] ||
        [path containsString:@"/api/"]) {
        return 20.0;  // API和页面：20秒
    }

    // 必要的脚本和样式：18秒
    if ([path hasSuffix:@".js"] || [path hasSuffix:@".css"]) {
        return 18.0;  // 脚本和样式：18秒
    }

    // 图片资源：可以超时降级（通过超时处理逻辑）
    if ([path hasSuffix:@".png"] ||
        [path hasSuffix:@".jpg"] ||
        [path hasSuffix:@".jpeg"] ||
        [path hasSuffix:@".gif"] ||
        [path hasSuffix:@".webp"]) {
        return 12.0;  // 图片：12秒（超时不中断）
    }

    // 加密资源：可能较大
    if ([path hasSuffix:@".aes"] || [path hasSuffix:@".enc"]) {
        return 25.0;  // 加密资源：25秒
    }

    // 其他资源
    return 15.0;  // 默认15秒
}

// 为指定的host获取或创建独立的AFHTTPSessionManager，实现真正的并发加载
- (AFHTTPSessionManager *)sessionManagerForHost:(NSString *)host {
    if (!host || host.length == 0) {
        host = @"default";
    }

    // 检查是否已有该host的session manager
    AFHTTPSessionManager *cachedManager = [self.hostSessionManagers objectForKey:host];
    if (cachedManager) {
        return cachedManager;
    }

    // ✅ 为该host创建新的独立session manager，各个host可并发请求
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

    // 关键：每个host独立配置，提升并发能力
    config.HTTPMaximumConnectionsPerHost = 22;      // 每个host最多22个并发
    config.HTTPShouldUsePipelining = YES;           // 启用HTTP管道
    config.HTTPShouldSetCookies = YES;
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    config.timeoutIntervalForRequest = 10.0;        // 单个请求10秒超时（避免过长等待，加快失败响应）
    config.timeoutIntervalForResource = 20.0;       // 总资源20秒超时（页面加载总时限）
    config.TLSMinimumSupportedProtocol = kTLSProtocol1;
    config.TLSMaximumSupportedProtocol = kTLSProtocol13;

    // ⚠️ 关键：安装EMASCurlProtocol以使用DOH和自定义DNS resolver
    // 这样AFNetworking创建的NSURLSession也能使用SkyShield的DOH服务
    [EMASCurlProtocol installIntoSessionConfiguration:config];

    // 设置自定义DNS resolver（支持DOH）
    [EMASCurlProtocol setDNSResolver:[MyDNSResolver class]];

    // 设置Protocol（如DNS解析等）
    NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:config.protocolClasses];
    if ([HttpDnsNSURLProtocolImpl isKindOfClass:[NSURLProtocol class]]) {
        [protocolsArray insertObject:[HttpDnsNSURLProtocolImpl class] atIndex:0];
        [config setProtocolClasses:protocolsArray];
    }

    // 创建manager
    AFHTTPSessionManager *newManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    newManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    newManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

    // 安全策略
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    newManager.securityPolicy = securityPolicy;

    // 缓存该manager
    [self.hostSessionManagers setObject:newManager forKey:host];

    NSLog(@"✅ Created session manager for host: %@", host);
    return newManager;
}

#pragma mark - Network Resource Matcher Methods

- (BOOL)canHandleWithRequest:(NSURLRequest *)request {
    return YES;
}

- (void)startWithRequest:(NSURLRequest *)request
         responseCallback:(EMASCurlNetResponseCallback)responseCallback
             dataCallback:(EMASCurlNetDataCallback)dataCallback
             failCallback:(EMASCurlNetFailCallback)failCallback
          successCallback:(EMASCurlNetSuccessCallback)successCallback
         redirectCallback:(EMASCurlNetRedirectCallback)redirectCallback {

    // ✅ 需要在这里也设置超时（因为有些请求会走这条路径，跳过 loadSecurityManagerRequestWithwebView）
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if (mutableRequest) {
        // 根据资源类型设置超时
        NSTimeInterval timeout = [self requestTimeoutForURL:mutableRequest.URL];
        NSString *resourceType = @"other";
        NSString *urlPath = mutableRequest.URL.path.lowercaseString;
        BOOL isOptional = NO;

        if ([urlPath hasSuffix:@".php"] || [urlPath hasSuffix:@".html"]) {
            resourceType = @"page";
        } else if ([urlPath hasSuffix:@".js"]) {
            isOptional = [self isOptionalJavaScript:mutableRequest.URL];
            resourceType = isOptional ? @"optional-script" : @"script";
        } else if ([urlPath hasSuffix:@".css"]) {
            resourceType = @"style";
        } else if ([urlPath hasSuffix:@".png"] || [urlPath hasSuffix:@".jpg"] || [urlPath hasSuffix:@".jpeg"] || [urlPath hasSuffix:@".gif"]) {
            resourceType = @"image";
        } else if ([urlPath hasSuffix:@".aes"]) {
            resourceType = @"encrypted";
        }

        NSString *logPrefix = isOptional ? @"⚡" : @"🔄";
        NSLog(@"%@ [Path2] Loading [%@] (%@s): %@", logPrefix, resourceType, @(timeout), mutableRequest.URL.lastPathComponent);

        // ✅ 通过 NSURLProtocol property 传递超时给 curl
        [NSURLProtocol setProperty:@(timeout) forKey:@"kEMASCurlCustomTimeoutKey" inRequest:mutableRequest];
        NSLog(@"⏲️ [Path2] Passed timeout %.2fs to curl for %@", timeout, mutableRequest.URL.lastPathComponent);

        request = mutableRequest;
    }

    EMASCurlNetworkDataTask *dataTask = [self.networkSession dataTaskWithRequest:request
                                                                responseCallback:responseCallback
                                                                    dataCallback:dataCallback
                                                                 successCallback:^{
        successCallback();
        EMASCurlCacheLog(@"WebContentLoader fetched data from network, url: %@", request.URL.absoluteString);
    }
                                                                    failCallback:failCallback
                                                                redirectCallback:redirectCallback];
    [dataTask resume];
}

-(void)loadSecurityManagerRequestWithwebView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask request:(NSMutableURLRequest*)request
{
    // ✅ 为该host获取或创建独立的session manager，实现真正的并发加载
    NSString *host = request.URL.host;
    AFHTTPSessionManager *manager = [self sessionManagerForHost:host];

    // ✅ 根据资源类型记录不同的超时时间（用于日志和监控）
    NSTimeInterval timeout = [self requestTimeoutForURL:request.URL];
    NSString *resourceType = @"other";
    NSString *urlPath = request.URL.path.lowercaseString;
    BOOL isOptional = NO;

    if ([urlPath hasSuffix:@".php"] || [urlPath hasSuffix:@".html"]) {
        resourceType = @"page";
    } else if ([urlPath hasSuffix:@".js"]) {
        isOptional = [self isOptionalJavaScript:request.URL];
        resourceType = isOptional ? @"optional-script" : @"script";
    } else if ([urlPath hasSuffix:@".css"]) {
        resourceType = @"style";
    } else if ([urlPath hasSuffix:@".png"] || [urlPath hasSuffix:@".jpg"] || [urlPath hasSuffix:@".jpeg"] || [urlPath hasSuffix:@".gif"]) {
        resourceType = @"image";
    } else if ([urlPath hasSuffix:@".aes"]) {
        resourceType = @"encrypted";
    }

    NSString *logPrefix = isOptional ? @"⚡" : @"🔄";
    NSLog(@"%@ Loading [%@] (%@s): %@", logPrefix, resourceType, @(timeout), request.URL.lastPathComponent);

    // ✅ 通过 NSURLProtocol property 传递超时给 curl（在 EMASCurlProtocol 里面设置）
    // 可选脚本使用极短超时，不阻塞主要资源
    [NSURLProtocol setProperty:@(timeout) forKey:@"kEMASCurlCustomTimeoutKey" inRequest:request];
    NSLog(@"⏲️ Passed timeout %.2fs to curl for %@", timeout, request.URL.lastPathComponent);

    // 安全获取domainString
    NSString *domainString = nil;
    NSString *domainGetString = nil;

    if ([DomainManager respondsToSelector:@selector(sharedInstance)]) {
        DomainManager *domainManager = [DomainManager sharedInstance];
        if ([domainManager respondsToSelector:@selector(domainString)]) {
            domainString = domainManager.domainString;
        }
        if ([domainManager respondsToSelector:@selector(domainGetString)]) {
            domainGetString = domainManager.domainGetString;
        }
    }
    // 检查serverVersion是否存在并有效
    BOOL hasServerVersion = NO;
    if (serverVersion && [serverVersion isKindOfClass:[NSString class]]) {
        hasServerVersion = (serverVersion.length > 0);
    }

    if (domainString && domainGetString && [urlSchemeTask.request.URL.absoluteString rangeOfString:domainString].location!=NSNotFound && hasServerVersion) {
        NSString *pathS = [[request.URL.absoluteString stringByReplacingOccurrencesOfString:domainGetString withString:@""]
                           stringByReplacingOccurrencesOfString:domainString withString:@""];
        if (pathS.length>1 && [[pathS substringToIndex:1] isEqualToString:@"/"]) {
            pathS = [pathS substringFromIndex:1];
        }

        if ([YBNetworking respondsToSelector:@selector(encodePath:withForm:withDic:)]) {
            NSString *headerStr = [YBNetworking encodePath:pathS withForm:@{} withDic:@{}];
            if (headerStr) {
                [request addValue:headerStr forHTTPHeaderField:@"eh"];
            }
        }

        NSURL *domainURL = [NSURL URLWithString:domainGetString];
        if (domainURL) {
            request.URL = domainURL;
        }
    }

    WeakSelf
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject1, NSError * _Nullable error) {
        // 使用强引用确保在回调中self不会被释放
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        
        // 检查任务是否已被取消 - 添加额外的nil检查和状态验证
        if (!urlSchemeTask || !strongSelf.taskDic) {
            return;
        }
        
        NSNumber *taskStatus = [strongSelf.taskDic objectForKey:urlSchemeTask.description];
        if (!taskStatus || [taskStatus boolValue] == NO) {
            // 任务已被取消，不执行任何操作
            return;
        }
        
        if (webView!=nil && urlSchemeTask != nil) {
            @try {
                [urlSchemeTask didReceiveResponse:response];
                
                // 安全处理HTTP响应
                NSHTTPURLResponse *httpResponse = nil;
                NSDictionary *headers = nil;
                
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    httpResponse = (NSHTTPURLResponse *)response;
                    headers = [httpResponse allHeaderFields];
                }
                
                if (headers && [[headers objectForKey:@"be"] boolValue]) {
                    if (responseObject1 && [responseObject1 isKindOfClass:[NSData class]]) {
                        NSString *responseStr = [[NSString alloc] initWithData:responseObject1 encoding:NSUTF8StringEncoding];
                        
                        if (responseStr && [YBNetworking respondsToSelector:@selector(decodeResponseString:)]) {
                            id responseObject = [YBNetworking decodeResponseString:responseStr];
                            
                            if (responseObject) {
                                NSData *responseData = nil;
                                
                                if (![responseObject isKindOfClass:[NSString class]] &&
                                    [responseObject respondsToSelector:@selector(mj_JSONString)]) {
                                    responseObject = [responseObject mj_JSONString];
                                }
                                
                                if ([responseObject isKindOfClass:[NSString class]]) {
                                    responseData = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
                                    if (responseData) {
                                        [urlSchemeTask didReceiveData:responseData];
                                    }
                                }
                            }
                            else {
                                // 处理解码失败的情况
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if ([MXBADelegate respondsToSelector:@selector(sharedAppDelegate)]) {
                                        MXBADelegate *appDelegate = [MXBADelegate sharedAppDelegate];
                                        if ([appDelegate respondsToSelector:@selector(topViewController)]) {
                                            UIViewController *topVC = appDelegate.topViewController;
                                            if (topVC && httpResponse.statusCode!=0) {
                                                UIAlertController *alertTry = [UIAlertController alertControllerWithTitle:YZMsg(@"Illegal_request")
                                                                                                                  message:[NSString stringWithFormat:@"code:%ld",(long)httpResponse.statusCode]
                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                UIAlertAction *actionAl = [UIAlertAction actionWithTitle:YZMsg(@"public_retryAgain")
                                                                                                 style:UIAlertActionStyleDefault
                                                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                    //重新请求刷新
                                                    __strong typeof(weakSelf) strongSelf2 = weakSelf;
                                                    if (strongSelf2 && webView && urlSchemeTask) {
                                                        [strongSelf2 webView:webView startURLSchemeTask:urlSchemeTask];
                                                    }
                                                }];
                                                
                                                UIAlertAction *actionAlCanel = [UIAlertAction actionWithTitle:YZMsg(@"public_retryAgain")
                                                                                                      style:UIAlertActionStyleCancel
                                                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                    [alertTry dismissViewControllerAnimated:YES completion:nil];
                                                }];
                                                
                                                [alertTry addAction:actionAl];
                                                [alertTry addAction:actionAlCanel];
                                                [topVC presentViewController:alertTry animated:YES completion:nil];
                                            }
                                        }
                                    }
                                });
                                if (strongSelf && urlSchemeTask) {
                                    if (strongSelf && urlSchemeTask) {
                                if (strongSelf && urlSchemeTask) {
                            [strongSelf return404ForTask:urlSchemeTask];
                        }
                            }
                                }
                                return;
                            }
                        } else {
                            if (strongSelf && urlSchemeTask) {
                                if (strongSelf && urlSchemeTask) {
                            [strongSelf return404ForTask:urlSchemeTask];
                        }
                            }
                            return;
                        }
                    } else {
                        if (strongSelf && urlSchemeTask) {
                            [strongSelf return404ForTask:urlSchemeTask];
                        }
                        return;
                    }
            
                } else {
                    // 处理普通响应
                    if (domainGetString &&
                        [urlSchemeTask.request.URL.absoluteString rangeOfString:domainGetString].location != NSNotFound &&
                        hasServerVersion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([MXBADelegate respondsToSelector:@selector(sharedAppDelegate)]) {
                                MXBADelegate *appDelegate = [MXBADelegate sharedAppDelegate];
                                if ([appDelegate respondsToSelector:@selector(topViewController)]) {
                                    UIViewController *topVC = appDelegate.topViewController;
                                    if (topVC && httpResponse.statusCode != 0) {
                                        UIAlertController *alertTry = [UIAlertController alertControllerWithTitle:YZMsg(@"Illegal_request")
                                                                                                          message:[NSString stringWithFormat:@"code:%ld",(long)httpResponse.statusCode]
                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                        
                                        UIAlertAction *actionAl = [UIAlertAction actionWithTitle:YZMsg(@"public_retryAgain")
                                                                                         style:UIAlertActionStyleDefault
                                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                            //重新请求刷新
                                            __strong typeof(weakSelf) strongSelf2 = weakSelf;
                                            if (strongSelf2 && webView && urlSchemeTask) {
                                                [strongSelf2 webView:webView startURLSchemeTask:urlSchemeTask];
                                            }
                                        }];
                                        
                                        UIAlertAction *actionAlCanel = [UIAlertAction actionWithTitle:YZMsg(@"public_retryAgain")
                                                                                              style:UIAlertActionStyleCancel
                                                                                            handler:^(UIAlertAction * _Nonnull action) {
                                            [alertTry dismissViewControllerAnimated:YES completion:nil];
                                        }];
                                        
                                        [alertTry addAction:actionAl];
                                        [alertTry addAction:actionAlCanel];
                                        [topVC presentViewController:alertTry animated:YES completion:nil];
                                    }
                                }
                            }
                        });
                        if (strongSelf && urlSchemeTask) {
                            [strongSelf return404ForTask:urlSchemeTask];
                        }
                        return;
                    } else if (responseObject1 && [responseObject1 isKindOfClass:[NSData class]]) {
                        // ✅ 检查是否是 HTML 内容，应用异步并发加载优化
                        NSData *dataToSend = responseObject1;

                        // 判断是否是 HTML
                        NSLog(@"📋 Response MIME Type: %@", httpResponse.MIMEType);
                        BOOL isHTML = httpResponse && [httpResponse.MIMEType.lowercaseString containsString:@"text/html"];
                        NSLog(@"🔍 Is HTML: %@", isHTML ? @"YES" : @"NO");

                        if (isHTML) {
                            // 这是 HTML，应用优化
                            NSLog(@"🚀 [AsyncRender] Starting HTML optimization...");
                            [EMASCurlWebPerformanceMonitor recordEventStart:@"html_optimization" forURL:urlSchemeTask.request.URL.absoluteString];

                            NSTimeInterval optimizeStartTime = [[NSDate date] timeIntervalSince1970] * 1000;

                            NSString *htmlString = [[NSString alloc] initWithData:responseObject1 encoding:NSUTF8StringEncoding];
                            if (htmlString) {
                                // ✅ 核心优化：异步并发加载所有外部资源（脚本、样式表）
                                // 不按 HTML 标签顺序等待，而是并发加载
                                // 这是最关键的优化！
                                htmlString = [EMASCurlWebProgressiveRender optimizeScriptTagsInHTML:htmlString];

                                // 也可选：添加 lazy loading 到图片（可选）
                                if (htmlString.length < 1024*1024) {  // 小于1MB才做图片优化
                                    htmlString = [EMASCurlWebProgressiveRender optimizeImageTagsInHTML:htmlString];
                                }

                                dataToSend = [htmlString dataUsingEncoding:NSUTF8StringEncoding];

                                NSTimeInterval optimizeEndTime = [[NSDate date] timeIntervalSince1970] * 1000;
                                NSLog(@"🚀 [AsyncRender] HTML optimized in %.0fms (size: %.0fKB → %.0fKB)",
                                      optimizeEndTime - optimizeStartTime,
                                      htmlString.length / 1024.0,
                                      dataToSend.length / 1024.0);
                                NSLog(@"  ✅ All external scripts moved to async concurrent loading");
                                NSLog(@"  ✅ All stylesheets converted to async loading");

                                [EMASCurlWebPerformanceMonitor recordEventEnd:@"html_optimization" forURL:urlSchemeTask.request.URL.absoluteString];
                            }
                        }

                        [urlSchemeTask didReceiveData:dataToSend];
                    }
                }

                // 确保在所有数据处理完成后再调用didFinish
                // 完成任务 - 这里是正确的位置，因为所有数据已经通过didReceiveData发送
                [urlSchemeTask didFinish];
            } @catch (NSException *exception) {
                NSLog(@"Exception in response processing: %@", exception);
                @try {
                    if (urlSchemeTask) {
                        [urlSchemeTask didFailWithError:[NSError errorWithDomain:@"CustomURLSchemeHandlerErrorDomain"
                                                                            code:-1
                                                                        userInfo:@{NSLocalizedDescriptionKey: exception.description}]];
                    }
                } @catch (NSException *innerException) {
                    NSLog(@"Exception in didFailWithError: %@", innerException);
                }
            }
        } else if (error) {
            @try {
                // ✅ 优化：对可选脚本和超时错误做降级处理，不中断页面加载
                NSURL *url = urlSchemeTask.request.URL;
                BOOL isOptionalScript = [strongSelf isOptionalJavaScript:url];
                NSString *urlPath = url.path.lowercaseString;
                BOOL isJavaScript = [urlPath hasSuffix:@".js"];

                // 错误码 -1001 是 NSURLErrorTimedOut (请求超时)
                // 错误码 -1004 是 NSURLErrorCannotConnectToHost (无法连接)
                // 错误码 -1005 是 NSURLErrorNetworkConnectionLost (网络连接丢失)
                // 错误码 49 是 MultiCurlManager Malformed option
                BOOL isNetworkError = (error.code == -1001 ||
                                      error.code == -1004 ||
                                      error.code == -1005 ||
                                      error.code == 49);

                // ✅ 对可选脚本（统计、分析等）的任何错误都降级处理
                if (isJavaScript && isOptionalScript) {
                    // 可选脚本：返回空 JS 内容，不报错
                    NSHTTPURLResponse *fallbackResponse = [[NSHTTPURLResponse alloc]
                        initWithURL:url
                        statusCode:200
                        HTTPVersion:@"HTTP/1.1"
                        headerFields:@{@"Content-Type": @"application/javascript"}];

                    // 返回空 JS，页面继续运行
                    NSData *emptyJS = [@"/* optional script failed to load */" dataUsingEncoding:NSUTF8StringEncoding];

                    [urlSchemeTask didReceiveResponse:fallbackResponse];
                    [urlSchemeTask didReceiveData:emptyJS];
                    [urlSchemeTask didFinish];

                    NSString *errorMsg = [NSString stringWithFormat:@"Error %ld", (long)error.code];
                    NSLog(@"⚡ Optional script skipped [%@]: %@ (%@)", errorMsg, url.lastPathComponent, url.host);
                    return;
                }

                // ✅ 网络错误或超时：返回 200 OK，不报错
                if (isNetworkError) {
                    NSHTTPURLResponse *fallbackResponse = [[NSHTTPURLResponse alloc]
                        initWithURL:url
                        statusCode:200
                        HTTPVersion:@"HTTP/1.1"
                        headerFields:@{@"X-Resource-Error": @(error.code).stringValue}];

                    [urlSchemeTask didReceiveResponse:fallbackResponse];
                    [urlSchemeTask didFinish];  // 成功完成，不中断加载

                    NSString *errorType = (error.code == -1001) ? @"timeout" : @"network error";
                    NSLog(@"⏱️ Resource %@ (skipped): %@", errorType, url.absoluteString);
                    return;
                }

                // 其他真正的错误才报失败（比如验证错误、响应错误等）
                NSLog(@"❌ Resource error: %@ (Code: %ld)", url.lastPathComponent, (long)error.code);
                [urlSchemeTask didFailWithError:error];
            } @catch (NSException *exception) {
                NSLog(@"Exception in error handling: %@", exception);
            }
        }
    }];
    
    [task resume];
}


#pragma mark - WKURLSchemeHandler

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(LimitVersion)) {
    
    os_unfair_lock_lock(&_taskMaplock);
    [_taskHashTable addObject:urlSchemeTask];
    os_unfair_lock_unlock(&_taskMaplock);
    
    EMASCurlCacheLog(@"WebContentLoader intercepted url: %@", urlSchemeTask.request.URL.absoluteString);
    
    
    
    NSMutableURLRequest *request = [urlSchemeTask.request mutableCopy];
    if (!request || !request.URL) {
        [self return404ForTask:urlSchemeTask];
        return;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    if (!components) {
        [self return404ForTask:urlSchemeTask];
        return;
    }
    
    // 清除 `fragment`（# 及其后面的部分）
    components.fragment = nil;
    
    // 对 URL 进行适当的编码，避免 `+`、空格等特殊字符问题
    if (components.percentEncodedQuery) {
        components.percentEncodedQuery = [components.percentEncodedQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    // 重新生成 URL
    NSURL *newURL = components.URL;
    if (newURL) {
        request.URL = newURL;
    } else {
        NSLog(@"URL 解析失败: %@", urlSchemeTask.request.URL);
        [self return404ForTask:urlSchemeTask];
        return;
    }
    
    // 去除URL中的#及其后面的部分
    NSString *urlString = request.URL.absoluteString;
    NSRange hashRange = [urlString rangeOfString:@"#"];
    if (hashRange.location != NSNotFound) {
        urlString = [urlString substringToIndex:hashRange.location];
        // 更新请求的URL
        NSURL *updatedURL = [NSURL URLWithString:urlString];
        if (updatedURL) {
            request.URL = updatedURL;
        }
    }
    
    if (request.URL == nil) {
        [self return404ForTask:urlSchemeTask];
        return;
    }
    
    NSLog(@"request = %@",request);
    // 安全获取domainString
    NSString *domainString = nil;
    NSString *domainGetString = nil;
    
    if ([DomainManager respondsToSelector:@selector(sharedInstance)]) {
        DomainManager *domainManager = [DomainManager sharedInstance];
        if ([domainManager respondsToSelector:@selector(domainString)]) {
            domainString = domainManager.domainString;
        }
        if ([domainManager respondsToSelector:@selector(domainGetString)]) {
            domainGetString = domainManager.domainGetString;
        }
    }
    // 检查serverVersion是否存在并有效
    BOOL hasServerVersion = NO;
    if (serverVersion && [serverVersion isKindOfClass:[NSString class]]) {
        hasServerVersion = (serverVersion.length > 0);
    }
    
    if (domainString && domainGetString && [urlSchemeTask.request.URL.absoluteString rangeOfString:domainString].location!=NSNotFound && hasServerVersion) {
        // ✅ 直接记录任务状态，不用barrier避免阻塞
        // barrier会导致超时的请求阻塞后续所有请求，造成整个应用卡死
        [self.taskDic setObject:@(true) forKey:urlSchemeTask.description];

        // ✅ 异步加载，不要阻塞主流程
        [self loadSecurityManagerRequestWithwebView:webView startURLSchemeTask:urlSchemeTask request:request];
        return;
    }else{
        if (request.URL.host && ![request.URL.host containsString:@"127.0.0"]) {

            NSLog(@"ssss");
        }else{
            // ✅ 直接记录任务状态，不用barrier避免阻塞
            [self.taskDic setObject:@(true) forKey:urlSchemeTask.description];

            [self loadSecurityManagerRequestWithwebView:webView startURLSchemeTask:urlSchemeTask request:request];
            return;
        }
    }


    EMASCurlWeak(self)
    [self startWithRequest:urlSchemeTask.request
          responseCallback:^(NSURLResponse * _Nonnull response) {
        EMASCurlStrong(self)
        [self didReceiveResponse:response urlSchemeTask:urlSchemeTask];
    }
              dataCallback:^(NSData * _Nonnull data) {
        EMASCurlStrong(self)
        [self didReceiveData:data urlSchemeTask:urlSchemeTask];
    }
              failCallback:^(NSError * _Nonnull error) {
        EMASCurlStrong(self)
        [self didFailWithError:error urlSchemeTask:urlSchemeTask];
    }
           successCallback:^{
        EMASCurlStrong(self)
        [self didFinishWithUrlSchemeTask:urlSchemeTask];
    }
          redirectCallback:^(NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull redirectRequest, EMASCurlNetRedirectDecisionCallback redirectDecisionCallback) {
        EMASCurlStrong(self)
        [self didRedirectWithResponse:response newRequest:redirectRequest redirectDecision:redirectDecisionCallback urlSchemeTask:urlSchemeTask];
    }];
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(LimitVersion)) {
    os_unfair_lock_lock(&_taskMaplock);
    [_taskHashTable removeObject:urlSchemeTask];
    os_unfair_lock_unlock(&_taskMaplock);

    if (urlSchemeTask) {
        // ✅ 关键：标记任务已停止，避免进一步的回调处理
        [self.taskDic setObject:@(false) forKey:urlSchemeTask.description];

        NSLog(@"🛑 stopURLSchemeTask: 已停止单个任务，URL: %@", urlSchemeTask.request.URL.absoluteString);
    }
}

#pragma mark - Task Callbacks

- (void)didReceiveResponse:(NSURLResponse *)response urlSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    if (![self isAliveWithURLSchemeTask:urlSchemeTask]) {
        return;
    }
    @try {
        EMASCurlCacheLog(@"WebContentLoader received response, url: %@", urlSchemeTask.request.URL.absoluteString);
        [urlSchemeTask didReceiveResponse:response];
    } @catch (NSException *exception) {} @finally {}
}

- (void)didReceiveData:(NSData *)data urlSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    if (![self isAliveWithURLSchemeTask:urlSchemeTask]) {
        return;
    }
    @try {
        EMASCurlCacheLog(@"WebContentLoader received data, length: %ld, url: %@", data.length, urlSchemeTask.request.URL.absoluteString);
        [urlSchemeTask didReceiveData:data];
    } @catch (NSException *exception) {} @finally {}
}

- (void)didFinishWithUrlSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    if (![self isAliveWithURLSchemeTask:urlSchemeTask]) {
        return;
    }
    @try {
        EMASCurlCacheLog(@"WebContentLoader finished, url: %@", urlSchemeTask.request.URL.absoluteString);
        [urlSchemeTask didFinish];
    } @catch (NSException *exception) {} @finally {}
}

- (void)didFailWithError:(NSError *)error urlSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    if (![self isAliveWithURLSchemeTask:urlSchemeTask]) {
        return;
    }
    @try {
        EMASCurlCacheLog(@"WebContentLoader encountered error, url: %@", urlSchemeTask.request.URL.absoluteString);
        [urlSchemeTask didFailWithError:error];
    } @catch (NSException *exception) {} @finally {}
}

- (void)didRedirectWithResponse:(NSURLResponse *)response
                     newRequest:(NSURLRequest *)redirectRequest
               redirectDecision:(EMASCurlNetRedirectDecisionCallback)redirectDecisionCallback
                  urlSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    if (![EMASCurlWebUtils isEqualURLA:urlSchemeTask.request.mainDocumentURL.absoluteString withURLB:response.URL.absoluteString]) {
        redirectDecisionCallback(YES);
        return;
    }
    redirectDecisionCallback(NO);
    if ([self isAliveWithURLSchemeTask:urlSchemeTask]) {
        NSString *s1 = @"didPerform";
        NSString *s2 = @"Redirection:";
        NSString *s3 = @"newRequest:";
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"_%@%@%@", s1, s2, s3]);
        if ([urlSchemeTask respondsToSelector:sel]) {
            @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [urlSchemeTask performSelector:sel withObject:response withObject:redirectRequest];
#pragma clang diagnostic pop
            } @catch (NSException *exception) {
            } @finally {}
        }
    }
    [self redirectWithRequest:redirectRequest];
}

#pragma mark - Utility Methods

- (BOOL)isAliveWithURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    BOOL alive = NO;
    os_unfair_lock_lock(&_taskMaplock);
    alive = [_taskHashTable containsObject:urlSchemeTask];
    os_unfair_lock_unlock(&_taskMaplock);
    EMASCurlCacheLog(@"isAliveWithURLSchemeTask encountered an exception");
    return alive;
}

- (void)redirectWithRequest:(NSURLRequest *)redirectRequest {
    void *storeKey = (__bridge  void*)[EMASCurlWebUrlSchemeHandler class];
    EMASCurlWebWeakProxy *redirectDelegateProxy = objc_getAssociatedObject(self, storeKey);
    if ([redirectDelegateProxy respondsToSelector:@selector(redirectWithRequest:)]) {
        ((void (*)(id, SEL, NSURLRequest *))objc_msgSend)(redirectDelegateProxy, @selector(redirectWithRequest:), redirectRequest);
    }
}

- (void)return404ForTask:(id <WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(11.0)) {
    if (!urlSchemeTask) {
        return;
    }

    NSURL *requestURL = urlSchemeTask.request.URL;
    if (!requestURL) {
        requestURL = [NSURL URLWithString:@"about:blank"];
    }

    // ✅ 对可选脚本做降级处理：返回空 JS 而不是 404
    NSString *urlPath = requestURL.path.lowercaseString;
    if ([urlPath hasSuffix:@".js"] && [self isOptionalJavaScript:requestURL]) {
        // 可选脚本：返回空 JS
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc]
            initWithURL:requestURL
            statusCode:200
            HTTPVersion:@"HTTP/1.1"
            headerFields:@{@"Content-Type": @"application/javascript"}];

        NSData *emptyJS = [@"/* optional script skipped */" dataUsingEncoding:NSUTF8StringEncoding];

        @try {
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:emptyJS];
            [urlSchemeTask didFinish];
            NSLog(@"⚡ Optional script fallback: %@", requestURL.lastPathComponent);
        } @catch (NSException *exception) {
            NSLog(@"Exception in return404ForTask: %@", exception);
        }
        return;
    }

    // 非可选资源：返回标准 404
    NSString *html404 = @"<html><head><title>404 Not Found</title></head><body><h1>404 Not Found</h1><p>The requested resource was not found on this server.（非法请求）</p></body></html>";
    NSData *data = [html404 dataUsingEncoding:NSUTF8StringEncoding];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:requestURL statusCode:404 HTTPVersion:@"HTTP/1.1" headerFields:@{}];

    @try {
        // 确保按照正确的顺序调用API：先didReceiveResponse，然后是didReceiveData，最后是didFinish
        [urlSchemeTask didReceiveResponse:response];
        if (data) {
            [urlSchemeTask didReceiveData:data];
        }
        // 所有数据已发送，完成任务
        [urlSchemeTask didFinish];
    } @catch (NSException *exception) {
        NSLog(@"Exception in return404ForTask: %@", exception);
    }
}



-(NSMutableDictionary*)taskDic{
    if (_taskDic == nil) {
        _taskDic = [NSMutableDictionary dictionary];
    }
    return _taskDic;
}

@end
