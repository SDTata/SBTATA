//
//  NodePublisher+PublisherCustom.m
//  QLive
//
//  Created by Co co on 28/12/23.
//  Copyright © 2023 Mingliang Chen. All rights reserved.
//

#import "NodePublisher+PublisherCustom.h"

#import <objc/runtime.h>

@implementation NodePublisher (PublisherCustom)


- (void)setCustomDelegate:(id<NodePublisherCustomDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(customDelegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<NodePublisherCustomDelegate>)customDelegate {
    return objc_getAssociatedObject(self, @selector(customDelegate));
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NodePublisher class];

        SEL originalSelector = NSSelectorFromString(@"outputSampleBuffer:");
        SEL swizzledSelector = @selector(custom_outputSampleBuffer:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)custom_outputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // 在这里处理sampleBuffer
    if ([self.customDelegate respondsToSelector:@selector(didOutputVideoSampleBuffer:)]) {
         [self.customDelegate didOutputVideoSampleBuffer:sampleBuffer];
        
        [self custom_outputSampleBuffer:sampleBuffer];
        
    }else{
        // 调用原始的 outputSampleBuffer: 方法
        [self custom_outputSampleBuffer:sampleBuffer];
    }

    
    
}

@end

