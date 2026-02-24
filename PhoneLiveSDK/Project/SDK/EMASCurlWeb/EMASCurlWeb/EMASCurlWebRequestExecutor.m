//
//  EMASCurlNetworkManager.m
//

#import "EMASCurlWebRequestExecutor.h"
#import "EMASCurlWebUtils.h"
#import <WebKit/Webkit.h>

@interface EMASCurlWebNetworkCallbackPack : NSObject

@property (nonatomic, copy) EMASCurlNetResponseCallback responseCallback;
@property (nonatomic, copy) EMASCurlNetDataCallback dataCallback;
@property (nonatomic, copy) EMASCurlNetSuccessCallback successCallback;
@property (nonatomic, copy) EMASCurlNetFailCallback failCallback;
@property (nonatomic, copy) EMASCurlNetRedirectCallback redirectCallback;

- (instancetype)initWithResponseCallback:(EMASCurlNetResponseCallback)responseCallback
                            dataCallback:(EMASCurlNetDataCallback)dataCallback
                         successCallback:(EMASCurlNetSuccessCallback)successCallback
                            failCallback:(EMASCurlNetFailCallback)failCallback
                        redirectCallback:(EMASCurlNetRedirectCallback)redirectCallback;

@end

@implementation EMASCurlWebNetworkCallbackPack

- (instancetype)initWithResponseCallback:(EMASCurlNetResponseCallback)responseCallback
                            dataCallback:(EMASCurlNetDataCallback)dataCallback
                         successCallback:(EMASCurlNetSuccessCallback)successCallback
                            failCallback:(EMASCurlNetFailCallback)failCallback
                        redirectCallback:(EMASCurlNetRedirectCallback)redirectCallback {
    self = [super init];
    if (self) {
        _responseCallback = responseCallback;
        _dataCallback = dataCallback;
        _successCallback = successCallback;
        _failCallback = failCallback;
        _redirectCallback = redirectCallback;
    }
    return self;
}

@end

@interface EMASCurlWebRequestExecutor ()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSOperationQueue *requestCallbackQueue;
@property (nonatomic, strong) EMASCurlSafeDictionary *taskToCallbackPackMap;
@property (nonatomic, strong) EMASCurlSafeDictionary *taskidToDataTaskMap;

@end

@implementation EMASCurlWebRequestExecutor

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration {
    if (self = [super init]) {
        sessionConfiguration.HTTPShouldUsePipelining = YES;
        // ✅ 改为 NSURLRequestUseProtocolCachePolicy 以启用 EMASCurlProtocol 中的缓存机制
        sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        self.URLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                    delegate:self
                                               delegateQueue:self.requestCallbackQueue];
    }
    return self;
}

- (RequestTaskIdentifier)startWithRequest:(NSURLRequest *)request
                         responseCallback:(EMASCurlNetResponseCallback)responseCallback
                             dataCallback:(EMASCurlNetDataCallback)dataCallback
                          successCallback:(EMASCurlNetSuccessCallback)successCallback
                             failCallback:(EMASCurlNetFailCallback)failCallback
                         redirectCallback:(EMASCurlNetRedirectCallback)redirectCallback {
    NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:request];
    EMASCurlWebNetworkCallbackPack *cbPack = [[EMASCurlWebNetworkCallbackPack alloc]
                                               initWithResponseCallback:responseCallback
                                               dataCallback:dataCallback
                                               successCallback:successCallback
                                               failCallback:failCallback
                                               redirectCallback:redirectCallback];

    [self.taskToCallbackPackMap setObject:cbPack forKey:@(dataTask.taskIdentifier)];
    [self.taskidToDataTaskMap setObject:dataTask forKey:@(dataTask.taskIdentifier)];
    [dataTask resume];

    return dataTask.taskIdentifier;
}

- (void)cancelWithRequestIdentifier:(RequestTaskIdentifier)requestTaskIdentifier {
    if (requestTaskIdentifier < 0) {
        return;
    }

    // ✅ 立即移除回调，防止任何回调被执行
    [self.taskToCallbackPackMap removeObjectForKey:@(requestTaskIdentifier)];

    // ✅ 取消实际的网络任务
    NSURLSessionDataTask *dataTask = [self.taskidToDataTaskMap objectForKey:@(requestTaskIdentifier)];
    if (dataTask) {
        @try {
            NSLog(@"🛑 取消网络任务 ID: %ld, 状态: %ld", (long)requestTaskIdentifier, (long)dataTask.state);
            [dataTask cancel];
            [self.taskidToDataTaskMap removeObjectForKey:@(requestTaskIdentifier)];
        } @catch (NSException *exception) {
            NSLog(@"⚠️ 取消网络任务时出错: %@", exception);
        }
    }
}

#pragma mark - Lazy

- (NSOperationQueue *)requestCallbackQueue {
    if (!_requestCallbackQueue) {
        _requestCallbackQueue = [NSOperationQueue new];
        _requestCallbackQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        // ✅ 允许并发处理回调，但限制并发数避免系统过载
        // 原来的 maxConcurrentOperationCount = 1 导致序列化处理，某个回调被阻塞时会卡死整个页面
        // 改为 8 允许并发但不至于过度占用系统资源
        _requestCallbackQueue.maxConcurrentOperationCount = 8;
        _requestCallbackQueue.name = @"com.alicloud.emascurl.networkcallback";
    }
    return _requestCallbackQueue;
}

- (EMASCurlSafeDictionary *)taskToCallbackPackMap {
    if (!_taskToCallbackPackMap) {
        _taskToCallbackPackMap = [EMASCurlSafeDictionary new];
    }
    return _taskToCallbackPackMap;
}

- (EMASCurlSafeDictionary *)taskidToDataTaskMap {
    if (!_taskidToDataTaskMap) {
        _taskidToDataTaskMap = [EMASCurlSafeDictionary new];
    }
    return _taskidToDataTaskMap;
}

#pragma mark - <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session
              dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveResponse:(NSHTTPURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self syncCookieToWKWithResponse:response];

    // ✅ 异常保护：避免响应回调异常导致系统卡死
    @try {
        EMASCurlWebNetworkCallbackPack *cbPack = [self.taskToCallbackPackMap objectForKey:@(dataTask.taskIdentifier)];
        if (cbPack && cbPack.responseCallback) {
            cbPack.responseCallback(response);
        }
    } @catch (NSException *exception) {
        NSLog(@"⚠️ Exception in didReceiveResponse: %@", exception);
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // ✅ 异常保护：避免数据回调异常导致系统卡死
    @try {
        EMASCurlWebNetworkCallbackPack *cbPack = [self.taskToCallbackPackMap objectForKey:@(dataTask.taskIdentifier)];
        if (cbPack && cbPack.dataCallback) {
            cbPack.dataCallback(data);
        }
    } @catch (NSException *exception) {
        NSLog(@"⚠️ Exception in didReceiveData: %@", exception);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    EMASCurlWebNetworkCallbackPack *cbPack = [self.taskToCallbackPackMap objectForKey:@(task.taskIdentifier)];
    if (!cbPack) {
        return;
    }

    // ✅ 用异步dispatch避免回调阻塞当前线程
    // 特别是对于failCallback，要确保它不会导致整个系统卡死
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            if (error) {
                if (cbPack.failCallback) {
                    cbPack.failCallback(error);
                }
            } else {
                if (cbPack.successCallback) {
                    cbPack.successCallback();
                }
            }
        } @catch (NSException *exception) {
            // 捕获任何异常，避免回调异常导致系统崩溃
            NSLog(@"⚠️ Exception in network callback: %@", exception);
        } @finally {
            // 确保一定要清理资源
            [self.taskToCallbackPackMap removeObjectForKey:@(task.taskIdentifier)];
            [self.taskidToDataTaskMap removeObjectForKey:@(task.taskIdentifier)];
        }
    });
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    [self syncCookieToWKWithResponse:response];

    // ✅ 异常保护：避免重定向回调异常导致系统卡死
    @try {
        EMASCurlWebNetworkCallbackPack *cbworker = [self.taskToCallbackPackMap objectForKey:@(task.taskIdentifier)];
        void(^redirectDecisionCallback)(BOOL) = ^(BOOL canPass) {
            if (canPass) {
                completionHandler(request);
            } else {
                [task cancel];
                completionHandler(nil);
            }
        };
        if (cbworker && cbworker.redirectCallback) {
            cbworker.redirectCallback(response, request, redirectDecisionCallback);
        } else {
            completionHandler(request);
        }
    } @catch (NSException *exception) {
        NSLog(@"⚠️ Exception in willPerformHTTPRedirection: %@", exception);
        completionHandler(request);
    }
}

-(void)syncCookieToWKWithResponse:(NSHTTPURLResponse *)response {
    NSArray<NSHTTPCookie *> *responseCookies =
        [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    if ([responseCookies isKindOfClass:[NSArray class]] && responseCookies.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [responseCookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull cookie, NSUInteger idx, BOOL * _Nonnull stop) {
                if (@available(iOS 11.0, *)) {
                    [[WKWebsiteDataStore defaultDataStore].httpCookieStore setCookie:cookie completionHandler:nil];
                }
            }];
        });
    }
}

@end
