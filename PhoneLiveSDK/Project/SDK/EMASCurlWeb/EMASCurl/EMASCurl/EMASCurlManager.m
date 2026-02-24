//
//  MultiCurlManager.m
//  EMASCurl
//
//  Created by xuyecan on 2024/12/9.
//

#import "EMASCurlManager.h"

@interface EMASCurlManager () {
    CURLM *_multiHandle;
    CURLSH *_shareHandle;
    NSThread *_networkThread;
    NSCondition *_condition;
    BOOL _shouldStop;
    NSMutableDictionary<NSNumber *, void (^)(BOOL, NSError *)> *_completionMap;
}

@end

@implementation EMASCurlManager

+ (instancetype)sharedInstance {
    static EMASCurlManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EMASCurlManager alloc] initPrivate];
    });
    return manager;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        curl_global_init(CURL_GLOBAL_ALL);

        _multiHandle = curl_multi_init();

        // ✅ 并发优化：启用HTTP管道化和多路复用
        curl_multi_setopt(_multiHandle, CURLMOPT_PIPELINING, CURLPIPE_MULTIPLEX);

        // ✅ 增加最大并发连接数到32，支持更多同时请求
        curl_multi_setopt(_multiHandle, CURLMOPT_MAXCONNECTS, 32L);

        // cookie手动管理，所以这里不共享
        // 如果有需求，需要做实例隔离，整个架构要重新设计
        _shareHandle = curl_share_init();
        curl_share_setopt(_shareHandle, CURLSHOPT_SHARE, CURL_LOCK_DATA_DNS);
        curl_share_setopt(_shareHandle, CURLSHOPT_SHARE, CURL_LOCK_DATA_SSL_SESSION);
        curl_share_setopt(_shareHandle, CURLSHOPT_SHARE, CURL_LOCK_DATA_CONNECT);

        _completionMap = [NSMutableDictionary dictionary];

        _condition = [[NSCondition alloc] init];
        _shouldStop = NO;
        _networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadEntry) object:nil];
        _networkThread.qualityOfService = NSQualityOfServiceUserInitiated;
        [_networkThread start];
    }
    return self;
}

- (void)dealloc {
    // ✅ 关键：立即取消所有请求，不等待完成
    [_condition lock];

    // 立即从curl multi中移除所有handle，不再继续处理
    NSArray<NSNumber *> *handleKeys = [_completionMap.allKeys copy];
    for (NSNumber *key in handleKeys) {
        CURL *easyHandle = (CURL *)(uintptr_t)key.unsignedLongLongValue;
        if (easyHandle && _multiHandle) {
            curl_multi_remove_handle(_multiHandle, easyHandle);
        }
    }
    [_completionMap removeAllObjects];

    _shouldStop = YES;
    [_condition signal];
    [_condition unlock];

    // 等待网络线程退出（最多3秒）
    NSDate *startTime = [NSDate date];
    while (_networkThread && !_networkThread.isFinished && [[NSDate date] timeIntervalSinceDate:startTime] < 3.0) {
        [NSThread sleepForTimeInterval:0.01];
    }

    // 清理curl资源
    if (_multiHandle) {
        curl_multi_cleanup(_multiHandle);
        _multiHandle = NULL;
    }
    if (_shareHandle) {
        curl_share_cleanup(_shareHandle);
        _shareHandle = NULL;
    }
    curl_global_cleanup();

    NSLog(@"🛑 EMASCurlManager dealloc: 已立即清理所有curl资源");
}

- (void)stop {
    [_condition lock];
    _shouldStop = YES;
    [_condition signal];
    [_condition unlock];
}

- (void)enqueueNewEasyHandle:(CURL *)easyHandle completion:(void (^)(BOOL, NSError *))completion {
    NSNumber *easyKey = @((uintptr_t)easyHandle);
    _completionMap[easyKey] = completion;

    [_condition lock];

    curl_easy_setopt(easyHandle, CURLOPT_SHARE, _shareHandle);
    curl_multi_add_handle(_multiHandle, easyHandle);

    [_condition signal];
    [_condition unlock];
}

// ✅ 取消指定的curl handle
- (void)cancelEasyHandle:(CURL *)easyHandle {
    if (!easyHandle) {
        return;
    }

    [_condition lock];

    NSNumber *easyKey = @((uintptr_t)easyHandle);
    // 移除完成回调
    [_completionMap removeObjectForKey:easyKey];

    // 从multi handle中移除
    curl_multi_remove_handle(_multiHandle, easyHandle);

    [_condition signal];
    [_condition unlock];

    NSLog(@"🛑 EMASCurlManager.cancelEasyHandle: 已取消curl handle");
}

// ✅ 取消所有curl handles
- (void)cancelAllEasyHandles {
    [_condition lock];

    NSArray<NSNumber *> *handleKeys = [_completionMap.allKeys copy];
    for (NSNumber *key in handleKeys) {
        CURL *easyHandle = (CURL *)(uintptr_t)key.unsignedLongLongValue;
        if (easyHandle) {
            curl_multi_remove_handle(_multiHandle, easyHandle);
            [_completionMap removeObjectForKey:key];
        }
    }

    [_condition signal];
    [_condition unlock];

    NSLog(@"🛑 EMASCurlManager.cancelAllEasyHandles: 已取消 %lu 个curl请求", handleKeys.count);
}

#pragma mark - Thread Entry and Main Loop

- (void)networkThreadEntry {
    @autoreleasepool {
        [_condition lock];

        while (!_shouldStop) {
            if (_completionMap.count == 0) {
                [_condition wait];
                if (_shouldStop) {
                    break;
                }
            }

            [self performCurlTransfers];

            if (_completionMap.count > 0 && !_shouldStop) {
                [_condition unlock];

                // ✅ 并发优化：减少等待时间从1000ms到100ms，提高并发响应速度
                // 新请求加入时会立即signal，不用等待整个1秒
                curl_multi_wait(_multiHandle, NULL, 0, 100, NULL);

                [_condition lock];
            }
        }
        [_condition unlock];
    }
}

- (void)performCurlTransfers {
    int stillRunning = 0;
    CURLMsg *msg = NULL;
    int msgsLeft = 0;

    do {
        curl_multi_perform(_multiHandle, &stillRunning);

        while ((msg = curl_multi_info_read(_multiHandle, &msgsLeft))) {
            if (msg->msg == CURLMSG_DONE) {
                CURL *easy = msg->easy_handle;
                NSNumber *easyKey = @((uintptr_t)easy);
                void (^completion)(BOOL, NSError *) = _completionMap[easyKey];

                [_completionMap removeObjectForKey:easyKey];

                BOOL succeeded = (msg->data.result == CURLE_OK);
                NSError *error = nil;
                if (!succeeded) {
                    char *urlp = NULL;
                    curl_easy_getinfo(easy, CURLINFO_EFFECTIVE_URL, &urlp);
                    NSString *url = urlp ? @(urlp) : @"unknownURL";
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @(curl_easy_strerror(msg->data.result)), NSURLErrorFailingURLStringErrorKey: url };
                    error = [NSError errorWithDomain:@"MultiCurlManager" code:msg->data.result userInfo:userInfo];
                }

                curl_multi_remove_handle(_multiHandle, easy);

                if (completion) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        completion(succeeded, error);
                    });
                }
            }
        }
    } while (stillRunning > 0);
}

@end
