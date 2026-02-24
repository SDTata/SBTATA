//
//  KTVHCDataDownload.m
//  KTVHTTPCache
//
//  Created by Single on 2017/8/12.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "KTVHCDownload.h"
#import "KTVHCData+Internal.h"
#import "KTVHCDataUnitPool.h"
#import "KTVHCDataStorage.h"
#import "KTVHCError.h"
#import "KTVHCLog.h"
#import <SkyShield/SkyShield.h>
#import "HttpDnsNSURLProtocolImpl.h"
#import <UIKit/UIKit.h>

NSString * const KTVHCContentTypeText                   = @"text/";
NSString * const KTVHCContentTypeVideo                  = @"video/";
NSString * const KTVHCContentTypeAudio                  = @"audio/";
NSString * const KTVHCContentTypeAppleHLS1              = @"vnd.apple.mpegURL";
NSString * const KTVHCContentTypeAppleHLS2              = @"application/x-mpegURL";
NSString * const KTVHCContentTypeApplicationMPEG4       = @"application/mp4";
NSString * const KTVHCContentTypeApplicationOctetStream = @"application/octet-stream";
NSString * const KTVHCContentTypeBinaryOctetStream      = @"binary/octet-stream";

@interface KTVHCDownload () <NSURLSessionDataDelegate, NSLocking>

@property (nonatomic, strong) NSLock *coreLock;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, NSError *> *errorDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, KTVHCDataRequest *> *requestDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, id<KTVHCDownloadDelegate>> *delegateDictionary;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation KTVHCDownload

+ (instancetype)download
{
    static KTVHCDownload *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        KTVHCLogAlloc(self);
        self.timeoutInterval = 30.0f;
        self.coreLock = [[NSLock alloc] init];
        self.backgroundTask = UIBackgroundTaskInvalid;
        self.errorDictionary = [NSMutableDictionary dictionary];
        self.requestDictionary = [NSMutableDictionary dictionary];
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
        self.sessionDelegateQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        
        // 配置 NSURLSessionConfiguration 的安全选项
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.sessionConfiguration.timeoutIntervalForRequest = self.timeoutInterval;
        self.sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
      
        self.sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol1;  // 支持更多TLS版本
        self.sessionConfiguration.TLSMaximumSupportedProtocol = kTLSProtocol13; // 支持到TLS 1.3
        NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:self.sessionConfiguration.protocolClasses];
        [protocolsArray insertObject:[HttpDnsNSURLProtocolImpl class] atIndex:0];
        [self.sessionConfiguration setProtocolClasses:protocolsArray];
        
        // 创建 NSURLSession，使用自定义的代理对象来处理 SSL 证书验证
        // 注意：必须将 self 设置为代理，并且确保代理方法的签名完全正确
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                                     delegate:self
                                                delegateQueue:self.sessionDelegateQueue];
        
        // 打印日志确认代理设置
        KTVHCLogDownload(@"%p, NSURLSession created with delegate: %@", self, self);
        
        self.acceptableContentTypes = @[KTVHCContentTypeText,
                                        KTVHCContentTypeVideo,
                                        KTVHCContentTypeAudio,
                                        KTVHCContentTypeAppleHLS1,
                                        KTVHCContentTypeAppleHLS2,
                                        KTVHCContentTypeApplicationMPEG4,
                                        KTVHCContentTypeApplicationOctetStream,
                                        KTVHCContentTypeBinaryOctetStream];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    KTVHCLogDealloc(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)availableHeaderKeys
{
    static NSArray<NSString *> *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = @[@"User-Agent",
                @"Connection",
                @"Accept",
                @"Accept-Encoding",
                @"Accept-Language",
                @"Range"];
    });
    return obj;
}

- (NSURLRequest *)requestWithDataRequest:(KTVHCDataRequest *)request
{
    // 保存原始URL和域名
    NSURL *originalURL = request.URL;
    NSString *originalHost = originalURL.host;
    
    // 创建请求
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:originalURL];
    mRequest.timeoutInterval = self.timeoutInterval;
    mRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    // 添加请求头
    [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        if ([self.availableHeaderKeys containsObject:key] ||
            [self.whitelistHeaderKeys containsObject:key]) {
            [mRequest setValue:obj forHTTPHeaderField:key];
        }
    }];
    [self.additionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [mRequest setValue:obj forHTTPHeaderField:key];
    }];
    if (originalHost == nil) {
        NSString *fixedUrlString = originalURL.absoluteString ;
        fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"http:///" withString:@"http://"];
        fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"https:///" withString:@"https://"];
        
        if (([fixedUrlString hasPrefix:@"http:/"] && ![fixedUrlString hasPrefix:@"http://"])||([fixedUrlString hasPrefix:@"https:/"] && ![fixedUrlString hasPrefix:@"https://"])) {
            fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
            fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"https:/" withString:@"https://"];
            NSURL *fixedUrl = [NSURL URLWithString:fixedUrlString];
            originalHost = fixedUrl.host;
        }
    }
    // 处理自定义DNS解析
    if (originalHost && ![originalHost containsString:@"127.0.0"]) {
        if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count > 0) {
            // 添加原始域名作为Host头
            [mRequest setValue:originalHost forHTTPHeaderField:@"Host"];
            
            // 替换URL中的域名为解析后的IP
            NSString *requestUrlS = originalURL.absoluteString;
            if (requestUrlS) {
                NSString *replaceHostUrl = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                if (replaceHostUrl) {
                    NSURL *domainURL = [NSURL URLWithString:replaceHostUrl];
                    if (domainURL) {
                        mRequest.URL = domainURL;
                        KTVHCLogDownload(@"%p, Replace URL host with DNS\nOriginal URL: %@\nReplaced URL: %@", self, originalURL, domainURL);
                    }
                }
            }
        }
    }
    
    return mRequest;
}

- (NSURLSessionTask *)downloadWithRequest:(KTVHCDataRequest *)request delegate:(id<KTVHCDownloadDelegate>)delegate
{
    [self lock];
    NSURLRequest *mRequest = [self requestWithDataRequest:request];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:mRequest];
    [self.requestDictionary setObject:request forKey:task];
    [self.delegateDictionary setObject:delegate forKey:task];
    task.priority = 1.0;
    [task resume];
    KTVHCLogDownload(@"%p, Add Request\nrequest : %@\nURL : %@\nheaders : %@\nHTTPRequest headers : %@\nCount : %d", self, request, request.URL, request.headers, mRequest.allHTTPHeaderFields, (int)self.delegateDictionary.count);
    [self beginBackgroundTaskAsync];
    [self unlock];
    return task;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self lock];
    KTVHCLogDownload(@"%p, Complete\nError : %@", self, error);
    if ([self.errorDictionary objectForKey:task]) {
        error = [self.errorDictionary objectForKey:task];
    }
    id<KTVHCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:task];
    [delegate ktv_download:self didCompleteWithError:error];
    [self.delegateDictionary removeObjectForKey:task];
    [self.requestDictionary removeObjectForKey:task];
    [self.errorDictionary removeObjectForKey:task];
    if (self.delegateDictionary.count <= 0 && self.backgroundTask != UIBackgroundTaskInvalid) {
        [self endBackgroundTaskDelay];
    }
    [self unlock];
}

// 处理SSL证书验证挑战 - 会话级别
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    KTVHCLogDownload(@"%p, Session level challenge received for host: %@", self, challenge.protectionSpace.host);
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 无条件信任所有证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        KTVHCLogDownload(@"%p, Trust all certificates at session level for host: %@", self, challenge.protectionSpace.host);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

// 处理SSL证书验证挑战 - 任务级别
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    KTVHCLogDownload(@"%p, Task level challenge received for URL: %@, host: %@", self, task.currentRequest.URL, challenge.protectionSpace.host);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 获取请求信息
        NSURL *requestURL = task.currentRequest.URL;
        NSString *host = requestURL.host;
        NSString *originalHost = [task.currentRequest valueForHTTPHeaderField:@"Host"];
        
        // 检查是否是 IP 地址
        BOOL isIPAddress = [self isIPAddress:host];
        
        // 无条件信任所有证书，特别是对 IP 地址的请求
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        
        if (isIPAddress || originalHost) {
            KTVHCLogDownload(@"%p, Trust all certificates for IP address or custom host. URL: %@, Host: %@, Original Host: %@", 
                             self, requestURL, host, originalHost);
        } else {
            KTVHCLogDownload(@"%p, Trust certificate for host: %@", self, host);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

// 检查是否是 IP 地址
- (BOOL)isIPAddress:(NSString *)host {
    if (!host) return NO;
    
    // 检查是否是 IPv4 地址
    NSString *ipv4Pattern = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
    NSRegularExpression *ipv4Regex = [NSRegularExpression regularExpressionWithPattern:ipv4Pattern options:0 error:nil];
    NSUInteger ipv4Matches = [ipv4Regex numberOfMatchesInString:host options:0 range:NSMakeRange(0, host.length)];
    
    // 检查是否是 IPv6 地址
    // 支持标准格式和压缩格式的IPv6地址，以及可能包含方括号的格式
    NSString *ipv6Pattern = @"^\\[?([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}\\]?$";
    NSRegularExpression *ipv6Regex = [NSRegularExpression regularExpressionWithPattern:ipv6Pattern options:0 error:nil];
    NSUInteger ipv6Matches = [ipv6Regex numberOfMatchesInString:host options:0 range:NSMakeRange(0, host.length)];
    
    // 检查是否包含数字和点，这可能是 IPv4 地址
    BOOL containsOnlyDigitsAndDots = YES;
    for (NSInteger i = 0; i < host.length; i++) {
        unichar c = [host characterAtIndex:i];
        if (!((c >= '0' && c <= '9') || c == '.')) {
            containsOnlyDigitsAndDots = NO;
            break;
        }
    }
    
    // 检查是否包含十六进制字符和冒号，这可能是 IPv6 地址
    BOOL containsHexAndColons = NO;
    if (!containsOnlyDigitsAndDots) {
        containsHexAndColons = YES;
        for (NSInteger i = 0; i < host.length; i++) {
            unichar c = [host characterAtIndex:i];
            // 允许十六进制字符、冒号和方括号（用于URL中的IPv6地址）
            if (!(((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) || c == ':' || c == '[' || c == ']')) {
                containsHexAndColons = NO;
                break;
            }
        }
    }
    
    return ipv4Matches > 0 || ipv6Matches > 0 || containsOnlyDigitsAndDots || containsHexAndColons;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self lock];
    NSError *error = nil;
    KTVHCDataRequest *dataRequest = nil;
    KTVHCDataResponse *dataResponse = nil;
    NSHTTPURLResponse *HTTPURLResponse = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        HTTPURLResponse = (NSHTTPURLResponse *)response;
        if (HTTPURLResponse.statusCode > 400) {
            error = [KTVHCError errorForResponseStatusCode:task.currentRequest.URL
                                                   request:task.currentRequest
                                                  response:task.response];
        } else {
            dataRequest = [self.requestDictionary objectForKey:task];
            dataResponse = [[KTVHCDataResponse alloc] initWithURL:dataRequest.URL headers:HTTPURLResponse.allHeaderFields];
        }
    } else {
        error = [KTVHCError errorForResponseClass:task.currentRequest.URL
                                          request:task.currentRequest
                                         response:task.response];
    }
    if (!error) {
        BOOL vaild = NO;
        if (dataResponse.contentType.length > 0) {
            for (NSString *obj in self.acceptableContentTypes) {
                if ([[dataResponse.contentType lowercaseString] containsString:[obj lowercaseString]]) {
                    vaild = YES;
                }
            }
            if (!vaild && self.unacceptableContentTypeDisposer) {
                vaild = self.unacceptableContentTypeDisposer(dataRequest.URL, dataResponse.contentType);
            }
        }
        if (!vaild) {
            error = [KTVHCError errorForResponseContentType:task.currentRequest.URL
                                                    request:task.currentRequest
                                                   response:task.response];
        }
    }
    if (!error) {
        if (dataResponse.contentLength <= 0 ||
            (!KTVHCRangeIsFull(dataRequest.range) &&
             dataRequest.range.end < dataResponse.totalLength &&
             (dataResponse.contentLength != KTVHCRangeGetLength(dataRequest.range)))) {
                error = [KTVHCError errorForResponseContentLength:task.currentRequest.URL
                                                          request:task.currentRequest
                                                         response:task.response];
            }
    }
    if (!error) {
        long long (^getDeletionLength)(long long) = ^(long long desireLength){
            return desireLength + [KTVHCDataStorage storage].totalCacheLength - [KTVHCDataStorage storage].maxCacheLength;
        };
        long long length = getDeletionLength(dataResponse.contentLength);
        if (length > 0) {
            [[KTVHCDataUnitPool pool] deleteUnitsWithLength:length];
            length = getDeletionLength(dataResponse.contentLength);
            if (length > 0) {
                error = [KTVHCError errorForNotEnoughDiskSpace:dataResponse.totalLength
                                                       request:dataResponse.contentLength
                                              totalCacheLength:[KTVHCDataStorage storage].totalCacheLength
                                                maxCacheLength:[KTVHCDataStorage storage].maxCacheLength];
            }
        }
    }
    if (error) {
        KTVHCLogDownload(@"%p, Invaild response\nError : %@", self, error);
        [self.errorDictionary setObject:error forKey:task];
        completionHandler(NSURLSessionResponseCancel);
    } else {
        KTVHCLogDownload(@"%p, Receive response\nrequest : %@\nresponse : %@\nHTTPResponse : %@", self, dataRequest, dataResponse, HTTPURLResponse);
        id<KTVHCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:task];
        [delegate ktv_download:self didReceiveResponse:dataResponse];
        completionHandler(NSURLSessionResponseAllow);
    }
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    [self lock];
    KTVHCLogDownload(@"%p, Perform HTTP redirection\nresponse : %@\nrequest : %@", self, response, request);
    completionHandler(request);
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self lock];
    KTVHCLogDownload(@"%p, Receive data - Begin\nLength : %lld\nURL : %@", self, (long long)data.length, dataTask.originalRequest.URL.absoluteString);
    id<KTVHCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:dataTask];
    [delegate ktv_download:self didReceiveData:data];
    KTVHCLogDownload(@"%p, Receive data - End\nLength : %lld\nURL : %@", self, (long long)data.length, dataTask.originalRequest.URL.absoluteString);
    [self unlock];
}

- (void)lock
{
    [self.coreLock lock];
}

- (void)unlock
{
    [self.coreLock unlock];
}

#pragma mark - Background Task

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self beginBackgroundTaskIfNeeded];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self endBackgroundTaskIfNeeded:YES];
}

- (void)beginBackgroundTaskIfNeeded
{
    [self lock];
    if (self.backgroundTask == UIBackgroundTaskInvalid && self.delegateDictionary.count > 0) {
        __weak typeof(self) weakSelf = self;
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf endBackgroundTaskIfNeeded:YES];
        }];
    }
    [self unlock];
}

- (void)endBackgroundTaskIfNeeded:(BOOL)force
{
    [self lock];
    if (force || self.delegateDictionary.count <= 0) {
        if (self.backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }
    }
    [self unlock];
}

- (void)beginBackgroundTaskAsync
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [self beginBackgroundTaskIfNeeded];
        }
    });
}

- (void)endBackgroundTaskDelay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endBackgroundTaskIfNeeded:NO];
    });
}

@end
