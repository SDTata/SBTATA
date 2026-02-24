#import "SVGAParser+Decrypt.h"
#import <objc/runtime.h>
#import "FFAES.h"
#import <zlib.h>
#import <SSZipArchive/SSZipArchive.h>
#import <CommonCrypto/CommonDigest.h>
#import "HttpDnsNSURLProtocolImpl.h"

@implementation SVGAParser (Decrypt)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(parseWithURLRequest:completionBlock:failureBlock:));
               Method swizzledMethod = class_getInstanceMethod([self class], @selector(decrypt_parseWithURLRequest:completionBlock:failureBlock:));
               method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (NSData *)vk_imageDecode:(NSData *)fromData {
    return [FFAES decryptData:fromData key:KAESKEY];
}

- (void)decrypt_parseWithURLRequest:(NSURLRequest *)URLRequest
                   completionBlock:(void (^)(SVGAVideoEntity *videoItem))completionBlock
                      failureBlock:(void (^)(NSError *error))failureBlock {
   
    if (URLRequest.URL == nil) {
        if (failureBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                failureBlock([NSError errorWithDomain:@"SVGAParser" code:411 userInfo:@{NSLocalizedDescriptionKey: @"URL cannot be nil."}]);
            }];
        }
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory:[self cacheKey:URLRequest.URL]]]) {
        
        [self callOriginalMethodWithSelector:NSSelectorFromString(@"parseWithCacheKey:completionBlock:failureBlock:")
                                        cacheKey:[self cacheKey:URLRequest.URL]
                                 completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
            if (completionBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionBlock(videoItem);
                }];
            }
        }
        failureBlock:^(NSError * _Nonnull error) {
            [self clearCache:[self cacheKey:URLRequest.URL]];
            if (failureBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureBlock(error);
                }];
            }
        }];
        
        return;
    }
    // 创建可修改的请求对象
    NSMutableURLRequest *mutableRequest = [URLRequest mutableCopy];
    
    NSString *originalHost = mutableRequest.URL.host;
    if (originalHost == nil) {
        NSString *fixedUrlString = mutableRequest.URL.absoluteString ;
        fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"http:///" withString:@"http://"];
        fixedUrlString= [fixedUrlString stringByReplacingOccurrencesOfString:@"https:///" withString:@"https://"];
        
        if (([fixedUrlString hasPrefix:@"http:/"] && ![fixedUrlString hasPrefix:@"http://"])||([fixedUrlString hasPrefix:@"https:/"] && ![fixedUrlString hasPrefix:@"https://"])) {
            fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"http:/" withString:@"http://"];
            fixedUrlString = [fixedUrlString stringByReplacingOccurrencesOfString:@"https:/" withString:@"https://"];
            NSURL *fixedUrl = [NSURL URLWithString:fixedUrlString];
            originalHost = fixedUrl.host;
        }
    }
    
    
    // 自定义解析IP并替换原域名，同时添加Host头
    if (originalHost && ![mutableRequest.URL.host containsString:@"127.0.0"]) {
        if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count > 0) {
            // 添加原始域名作为Host头
            [mutableRequest addValue:mutableRequest.URL.host forHTTPHeaderField:@"Host"];
            
            // 替换URL中的域名为解析后的IP
            NSString *requestUrlS = mutableRequest.URL.absoluteString;
            if (requestUrlS) {
                NSString *replaceHostUrl = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                NSURL *domainURL1 = [NSURL URLWithString:replaceHostUrl];
                if (domainURL1) {
                    mutableRequest.URL = domainURL1;
                }
            }
        }
    }
    
    // 创建自定义的NSURLSession来处理SSL证书验证
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.TLSMinimumSupportedProtocol = kTLSProtocol1;  // 支持更多TLS版本
    configuration.TLSMaximumSupportedProtocol = kTLSProtocol13; // 支持到TLS 1.3
    NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:configuration.protocolClasses];
    [protocolsArray insertObject:[HttpDnsNSURLProtocolImpl class] atIndex:0];
    [configuration setProtocolClasses:protocolsArray];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                      delegate:self
                                                 delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && data != nil) {
            if ([URLRequest.URL.lastPathComponent containsString:@".aes"]) {
                data = [self vk_imageDecode:data];
            }
            [self parseWithData:data cacheKey:[self cacheKey:URLRequest.URL] completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                if (completionBlock) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completionBlock(videoItem);
                    }];
                }
            } failureBlock:^(NSError * _Nonnull error) {
                [self clearCache:[self cacheKey:URLRequest.URL]];
                if (failureBlock) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        failureBlock(error);
                    }];
                }
            }];
        }
        else {
            if (failureBlock) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failureBlock(error);
                }];
            }
        }
    }] resume];
}

- (nonnull NSString *)cacheKey:(NSURL *)URL {
    return [self MD5String:URL.absoluteString];
}


- (NSString *)MD5String:(NSString *)str {
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (nullable NSString *)cacheDirectory:(NSString *)cacheKey {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [cacheDir stringByAppendingFormat:@"/%@", cacheKey];
}

- (void)clearCache:(nonnull NSString *)cacheKey {
    NSString *cacheDir = [self cacheDirectory:cacheKey];
    [[NSFileManager defaultManager] removeItemAtPath:cacheDir error:NULL];
}


// 处理SSL证书验证
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 对于自定义解析的IP地址，信任所有证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)callOriginalMethodWithSelector:(SEL)selector
                              cacheKey:(NSString *)cacheKey
                       completionBlock:(void (^)(SVGAVideoEntity *videoItem))completionBlock
                          failureBlock:(void (^)(NSError *error))failureBlock {
    if ([self respondsToSelector:selector]) {
        NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:self];
        [invocation setArgument:&cacheKey atIndex:2];
        [invocation setArgument:&completionBlock atIndex:3];
        [invocation setArgument:&failureBlock atIndex:4];
        [invocation invoke];
    }
}
@end
