//
//  UINavigationController+TabBar.m
//  phonelive2
//
//  Created by vick on 2024/10/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import "UINavigationController+TabBar.h"

@implementation UINavigationController (TabBar)

// Swizzled方法，用来替换系统的pushViewController:animated:方法
- (void)swizzled_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 在这里修改 viewController 的 hidesBottomBarWhenPushed 属性
    if ([self isKindOfClass:[UINavigationController class]] && self.navigationController.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;  // 默认情况下，推入时隐藏 TabBar
    }
    
    // 调用原始的 pushViewController:animated:
    [self swizzled_pushViewController:viewController animated:animated];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 获取系统的 pushViewController:animated: 方法
        Method originalMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(swizzled_pushViewController:animated:));
        
        // 进行方法交换
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

@end
