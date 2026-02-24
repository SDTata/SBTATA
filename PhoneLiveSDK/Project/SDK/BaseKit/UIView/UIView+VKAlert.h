//
//  UIView+VKAlert.h
//
//  Created by vick on 2023/10/20.
//

#import <UIKit/UIKit.h>

@interface UIView (VKAlert)

/// 显示中心弹窗
- (void)showFromCenter;

/// 显示底部弹窗
- (void)showFromBottom;

/// 显示顶部部弹窗
- (void)showFromTop;

/// 关闭弹窗回调
- (void)hideAlert:(dispatch_block_t)block;

/// 关闭弹窗回调，暂停队列
- (void)hideAlertWithPause:(dispatch_block_t)block;

/// 继续队列
+ (void)continueAlertQueueDisplay;

/// 清空队列
+ (void)clearAlertQueueDisplay;

/// 点击背景关闭
- (BOOL)backgroundCloseEnable;

/// 优先级
- (NSInteger)priority;

/// 标识
- (NSString *)identifier;

/// 中心位置偏移
- (CGPoint)alertCenterOffset;

/// 在VC中弹出
- (BOOL)alertPresentationVC;

@end
