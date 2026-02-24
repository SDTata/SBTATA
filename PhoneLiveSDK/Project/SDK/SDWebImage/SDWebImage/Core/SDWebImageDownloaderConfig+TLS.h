//
//  SDWebImageDownloaderConfig+TLS.h
//  Live_iOS2
//
//  Created on 2025-06-07.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloaderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDWebImageDownloaderConfig (TLS)

/**
 * 配置 TLS 版本支持，从 TLS 1.0 到 TLS 1.3
 * 此方法会修改 sessionConfiguration 以支持更多 TLS 版本
 */
- (void)configureTLSSupport;

@end

NS_ASSUME_NONNULL_END
