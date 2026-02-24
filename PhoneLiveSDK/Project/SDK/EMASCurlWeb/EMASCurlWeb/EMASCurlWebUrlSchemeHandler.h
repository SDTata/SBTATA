//
//  EMASCurlUrlSchemeHandler.h
//  EMASCurl
//
//  Created by xuyecan on 2025/2/3.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "WKWebViewConfiguration+Loader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMASCurlResourceMatcherManagerDelegate <NSObject>

- (void)redirectWithRequest:(NSURLRequest *)redirectRequest;

@end

API_AVAILABLE(ios(LimitVersion))
@interface EMASCurlWebUrlSchemeHandler : NSObject<WKURLSchemeHandler>
@property(nonatomic,strong)NSMutableDictionary *taskDic;
// 为每个host缓存独立的AFHTTPSessionManager，实现真正的并发加载
@property(nonatomic,strong)NSMutableDictionary<NSString *, id> *hostSessionManagers;
@property(nonatomic,strong)NSURLSessionConfiguration *defaultSessionConfiguration;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
