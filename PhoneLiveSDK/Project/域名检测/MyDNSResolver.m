//
//  MyDNSResolver.h
//  phonelive2
//
//  Created by Co co on 2025/6/9.
//  Copyright © 2025 toby. All rights reserved.
//



#import <WebKit/WebKit.h>
#import "EMASCurl.h"
#import "EMASCurlWeb.h"


// DNS解析器实现
@interface MyDNSResolver : NSObject <EMASCurlProtocolDNSResolver>
@end

@implementation MyDNSResolver
+ (NSString *)resolveDomain:(NSString *)domain {
    NSString *address =  [[SkyShield shareInstance] replaceUrlHostToDNS:domain];
    return address;
}
@end

