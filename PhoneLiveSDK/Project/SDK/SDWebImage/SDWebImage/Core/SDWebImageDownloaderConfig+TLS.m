//
//  SDWebImageDownloaderConfig+TLS.m
//  Live_iOS2
//
//  Created on 2025-06-07.
//

#import "SDWebImageDownloaderConfig+TLS.h"

@implementation SDWebImageDownloaderConfig (TLS)

- (void)configureTLSSupport {
    // 如果没有 sessionConfiguration，创建一个默认的
    if (!self.sessionConfiguration) {
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    // 配置 TLS 版本支持
    NSMutableDictionary *sslOptions = [NSMutableDictionary dictionary];
    sslOptions[(NSString *)kCFStreamSSLLevel] = (NSString *)kCFStreamSocketSecurityLevelTLSv1;
    sslOptions[(NSString *)kCFStreamSSLSettings] = @{
        (NSString *)kCFStreamSSLProtocolVersionMin: @(kTLSProtocol1),
        (NSString *)kCFStreamSSLProtocolVersionMax: @(kTLSProtocol13)
    };
    
    // 设置 TLS 选项到 sessionConfiguration
    if (!self.sessionConfiguration.connectionProxyDictionary) {
        self.sessionConfiguration.connectionProxyDictionary = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *connectionProxyDictionary = [self.sessionConfiguration.connectionProxyDictionary mutableCopy];
    connectionProxyDictionary[(NSString *)kCFStreamPropertySSLSettings] = sslOptions;
    self.sessionConfiguration.connectionProxyDictionary = connectionProxyDictionary;
    
    // 设置 TLS 最小和最大版本
    if (@available(iOS 13.0, *)) {
        self.sessionConfiguration.TLSMinimumSupportedProtocolVersion = tls_protocol_version_TLSv10;
        self.sessionConfiguration.TLSMaximumSupportedProtocolVersion = tls_protocol_version_TLSv13;
    } else {
        self.sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol1;
        self.sessionConfiguration.TLSMaximumSupportedProtocol = kTLSProtocol13;
    }
}

@end
