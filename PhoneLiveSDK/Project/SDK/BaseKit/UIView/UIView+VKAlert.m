//
//  UIView+VKAlert.m
//
//  Created by vick on 2023/10/20.
//

#import "UIView+VKAlert.h"
#import <LEEAlert/LEEAlert.h>
#import "VKInline.h"
#import "VKMacro.h"

@implementation UIView (VKAlert)

- (void)showFromCenter {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [LEEAlert alert].config
    .LeeCustomView(self)
    .LeeHeaderInsets(UIEdgeInsetsZero)
    .LeeHeaderColor(UIColor.clearColor)
    .LeeMaxWidth(VK_SCREEN_W)
    .LeeMaxHeight(VK_SCREEN_H)
    .LeeContinueQueueDisplay(YES)
    .LeeQueue(YES)
    .LeeClickBackgroundClose(self.backgroundCloseEnable)
    .LeeIdentifier(self.identifier)
    .LeePriority(self.priority)
    .LeePresentation(self.alertPresentationVC ? [LEEPresentation viewController:vkTopVC()] : [LEEPresentation windowLevel:UIWindowLevelAlert])
    .LeeShow();
}

- (void)showFromBottom {
    [self layoutIfNeeded];
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat offsetY = VK_SCREEN_H/2 - height/2;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [LEEAlert alert].config
    .LeeCustomView(self)
    .LeeHeaderInsets(UIEdgeInsetsZero)
    .LeeHeaderColor(UIColor.clearColor)
    .LeeMaxWidth(VK_SCREEN_W)
    .LeeMaxHeight(VK_SCREEN_H)
    .LeeContinueQueueDisplay(YES)
    .LeeQueue(YES)
    .LeeClickBackgroundClose(YES)
    .LeeIdentifier(self.identifier)
    .LeePriority(self.priority)
    .LeeOpenAnimationStyle(LEEAnimationStyleOrientationBottom)
    .LeeCloseAnimationStyle(LEEAnimationStyleFade)
    .LeeAlertCenterOffset(CGPointMake(0, offsetY))
    .LeeIsScrollEnabled(NO)
    .LeePresentation(self.alertPresentationVC ? [LEEPresentation viewController:vkTopVC()] : [LEEPresentation windowLevel:UIWindowLevelAlert])
    .LeeShow();
}

- (void)showFromTop {
    [self layoutIfNeeded];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [LEEAlert alert].config
    .LeeCustomView(self)
    .LeeHeaderInsets(UIEdgeInsetsZero)
    .LeeHeaderColor(UIColor.clearColor)
    .LeeMaxWidth(VK_SCREEN_W)
    .LeeContinueQueueDisplay(NO)
    .LeeQueue(YES)
    .LeeClickBackgroundClose(YES)
    .LeeIdentifier(self.identifier)
    .LeePriority(self.priority)
    .LeeOpenAnimationStyle(LEEAnimationStyleOrientationNone)
    .LeeCloseAnimationStyle(LEEAnimationStyleFade)
    .LeeAlertCenterOffset(self.alertCenterOffset)
    .LeeShow();
}

- (void)hideAlert:(dispatch_block_t)block {
    [LEEAlert closeWithCompletionBlock:^{
        [LEEAlert continueQueueDisplay];
        !block ?: block();
    }];
}

- (void)hideAlertWithPause:(dispatch_block_t)block {
    [LEEAlert closeWithCompletionBlock:block];
}

+ (void)continueAlertQueueDisplay {
    [LEEAlert continueQueueDisplay];
}

+ (void)clearAlertQueueDisplay {
    [LEEAlert clearQueue];
}

- (BOOL)backgroundCloseEnable {
    return NO;
}

- (NSInteger)priority {
    return 1;
}

- (NSString *)identifier {
    return nil;
}

- (CGPoint)alertCenterOffset {
    return CGPointZero;
}

- (BOOL)alertPresentationVC {
    return NO;
}

@end
