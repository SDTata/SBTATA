//
//  UIViewController+Alert.m
//  phonelive2
//
//  Created by vick on 2023/12/11.
//  Copyright © 2023 toby. All rights reserved.
//

#import "UIViewController+Alert.h"
#import <STPopup/STPopup.h>

@implementation UIViewController (Alert)

- (void)showFromBottom {
    self.contentSizeInPopup = self.view.frame.size;
    
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:self];
    popupController.style = STPopupStyleBottomSheet;
    popupController.navigationBarHidden = YES;
    [popupController.backgroundView vk_addTapAction:self selector:@selector(clickBackgroundAction)];
    popupController.backgroundView.backgroundColor = self.backgroundCloseColor;
    popupController.containerView.backgroundColor = UIColor.clearColor;
    popupController.safeAreaInsets = UIEdgeInsetsZero;
    [popupController presentInViewController:vkTopVC()];
}

- (void)clickBackgroundAction {
    if (!self.backgroundCloseEnable) {
        return;
    }
    [self hideAlert];
}

- (void)hideAlert {
    [self.popupController dismissWithCompletion:nil];
}

- (BOOL)backgroundCloseEnable {
    return YES;
}

- (UIColor *)backgroundCloseColor {
    return vkColorHexA(0x000000, 0.3);
}

- (void)addGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.popupController.containerView addGestureRecognizer:pan];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:self.view];
    CGFloat height = CGRectGetHeight(self.popupController.containerView.frame);
    CGFloat y = point.y;
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (y > 0) {
            self.popupController.containerView.transform = CGAffineTransformMakeTranslation(0, y);
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [gesture velocityInView:self.view].y;
        if (y > height / 2 || velocity > 1000) {
            [self hideAlert];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.popupController.containerView.transform = CGAffineTransformMakeTranslation(0, 0);
                [self.view layoutIfNeeded];
            }];
        }
    }
}

- (void)showGameFromBottom {
//    CGFloat y = VK_STATUS_H + VKPX(150);
//    self.view.frame = CGRectMake(0, y, VK_SCREEN_W, VK_SCREEN_H - y);
//    UINavigationController *nav = [MXBADelegate sharedAppDelegate].navigationViewController;
//    UIViewController *vc = nav.viewControllers.lastObject;
//    [vc.view addSubview:self.view];
//    [vc addChildViewController:self];
    
    [GameFloatView createGameView:self];
    [GameFloatView showNormalGameView];
}

@end
