//
//  MultiCurlManager.h
//  EMASCurl
//
//  Created by xuyecan on 2024/12/9.
//

#import <Foundation/Foundation.h>
#import <curl/curl.h>

@interface EMASCurlManager : NSObject

+ (instancetype)sharedInstance;

- (void)enqueueNewEasyHandle:(CURL *)easyHandle completion:(void (^)(BOOL, NSError *))completion;

// ✅ 取消指定的curl handle
- (void)cancelEasyHandle:(CURL *)easyHandle;

// ✅ 取消所有curl handles
- (void)cancelAllEasyHandles;

@end
