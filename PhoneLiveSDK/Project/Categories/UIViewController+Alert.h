//
//  UIViewController+Alert.h
//  phonelive2
//
//  Created by vick on 2023/12/11.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Alert)

/// 显示底部弹窗
- (void)showFromBottom;

/// 隐藏弹窗
- (void)hideAlert;

/// 点击背景关闭
- (BOOL)backgroundCloseEnable;

/// 背景色
- (UIColor *)backgroundCloseColor;

- (void)showGameFromBottom;

@end
