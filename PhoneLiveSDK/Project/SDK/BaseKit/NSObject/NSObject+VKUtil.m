//
//  NSObject+VKUtil.m
//
//  Created by vick on 2022/12/2.
//

#import "NSObject+VKUtil.h"

@implementation NSObject (VKUtil)

- (void)setExtraData:(id)extraData {
    VK_PROPERTY_OBJECT(extraData);
}

- (id)extraData {
    return VK_PROPERTY_GET(extraData);
}

- (void)runSelector:(SEL)selector {
    [self runSelector:selector object:nil];
}

- (void)runSelector:(SEL)selector object:(id)object {
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:object];
#pragma clang diagnostic pop
    }
}

@end
