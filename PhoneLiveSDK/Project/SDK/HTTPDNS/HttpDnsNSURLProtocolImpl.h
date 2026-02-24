#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpDnsNSURLProtocolImpl : NSURLProtocol
+ (BOOL)isPlainIpAddress:(NSString *)hostStr;
@end

NS_ASSUME_NONNULL_END
