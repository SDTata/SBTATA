#import "NSTimer+Hook.h"
#import <objc/runtime.h>

@implementation NSTimer (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 获取原始方法和替换方法的选择器
        SEL originalSelector = @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:);
        SEL swizzledSelector = @selector(hooked_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:);
        
        // 获取原始方法和替换方法的Method对象
        Method originalMethod = class_getClassMethod(self, originalSelector);
        Method swizzledMethod = class_getClassMethod(self, swizzledSelector);
        
        // 交换方法的实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

+ (NSTimer *)hooked_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                            target:(id)target
                                          selector:(SEL)selector
                                          userInfo:(nullable id)userInfo
                                           repeats:(BOOL)repeats {
    if([YBToolClass sharedInstance].shouldUseHookedMethodForTimer){
        NSTimer *timer = [self hooked_scheduledTimerWithTimeInterval:interval
                                                               target:target
                                                             selector:selector
                                                             userInfo:userInfo
                                                              repeats:repeats];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = NO;
//        // 获取原始方法和替换方法的选择器
//        SEL originalSelector = @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:);
//        SEL swizzledSelector = @selector(hooked_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:);
//        
//        // 获取原始方法和替换方法的Method对象
//        Method originalMethod = class_getClassMethod(self, originalSelector);
//        Method swizzledMethod = class_getClassMethod(self, swizzledSelector);
//        
//        // 交换方法的实现（这里需要恢复交换回去）
//        method_exchangeImplementations(swizzledMethod, originalMethod);
        
        return timer;
    }else{
        return [self hooked_scheduledTimerWithTimeInterval:interval
                                                    target:target
                                                  selector:selector
                                                  userInfo:userInfo
                                                   repeats:repeats];
    }
    // 创建NSTimer对象
    
}

@end
