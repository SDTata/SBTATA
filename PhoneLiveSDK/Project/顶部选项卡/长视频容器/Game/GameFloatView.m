//
//  GameFloatView.m
//  phonelive2
//
//  Created by vick on 2024/10/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameFloatView.h"
#import "LotteryBetHallVC.h"
#import "h5game.h"
#import "LongVideoDetailMainVC.h"

#define kGameFloatViewTag 9876
#define kRootVC (UIApplication.sharedApplication.keyWindow.rootViewController)

@implementation GameFloatView

- (instancetype)initWithGameView:(UIViewController *)gameVC {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.blackColor;
        self.layer.masksToBounds = YES;
        self.isKeepBounds = YES;
        self.gameVC = gameVC;
        
        [self addSubview:gameVC.view];
        [gameVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        UIView *frontMaskView = [UIView new];
        frontMaskView.backgroundColor = vkColorHexA(0x000000, 0.2);
        [self addSubview:frontMaskView];
        self.frontMaskView = frontMaskView;
        [frontMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        UIButton *fullButton = [UIView vk_buttonImage:@"game_float_full" selected:nil];
        [fullButton vk_addTapAction:self selector:@selector(clickFullAction:)];
        [frontMaskView addSubview:fullButton];
        [fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(100);
        }];
        
        UIButton *closeButton = [UIView vk_buttonImage:@"game_float_close" selected:nil];
        [closeButton vk_addTapAction:self selector:@selector(clickCloseAction)];
        [frontMaskView addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(20);
            make.size.mas_equalTo(45);
        }];
    }
    return self;
}

- (void)clickFullAction:(UIButton *)button {
    if ([self.gameVC isKindOfClass:[LotteryBetHallVC class]]) {
        LotteryBetHallVC *vc = [LotteryBetHallVC new];
        vc.lotteryType = ((LotteryBetHallVC *)self.gameVC).lotteryType;
        vc.lotteryDelegate = [MXBADelegate sharedAppDelegate].homeNavigationViewController.viewControllers.firstObject;
        [[MXBADelegate sharedAppDelegate] homePushViewController:vc animated:YES];
        [GameFloatView hideGameView];
        return;
    }
    if ([self.gameVC isKindOfClass:[h5game class]]) {
        h5game *VC = [[h5game alloc] init];
        VC.wevView = ((h5game *)self.gameVC).wevView;
        VC.urls = ((h5game *)self.gameVC).urls;
        VC.bKYorLC = ((h5game *)self.gameVC).bKYorLC;
        VC.titles = @"";
        VC.bHiddenReturnBtn = true;
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
        [GameFloatView hideGameView];
        return;
    }
}

- (void)clickCloseAction {
    [GameFloatView hideGameView];
}

+ (void)createGameView:(UIViewController *)gameVC {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    if (view) {
        [GameFloatView hideGameView];
        return;
    }
    view = [[GameFloatView alloc] initWithGameView:gameVC];
    view.tag = kGameFloatViewTag;
    view.frame = CGRectMake(0, VK_SCREEN_H, VK_SCREEN_W, 0);
    
    [vkTopVC().view addSubview:view];
    [vkTopVC() addChildViewController:view.gameVC];
}

+ (void)showNormalGameView {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    if (view) {
        view.frontMaskView.hidden = YES;
        view.layer.cornerRadius = 0;
        view.dragEnable = NO;
        
        [GameFloatView hideGameView];
        
        [vkTopVC().view addSubview:view];
        [vkTopVC() addChildViewController:view.gameVC];
        
        [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.transform = CGAffineTransformIdentity;
            CGFloat y = LongVideoDetailMainVCVideoHeight;
            view.frame = CGRectMake(0, y, VK_SCREEN_W, VK_SCREEN_H - y);
        } completion:nil];
    }
}

+ (void)showSmallGameView {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    if (view) {
        view.frontMaskView.hidden = NO;
        view.layer.cornerRadius = 20;
        view.dragEnable = YES;
        
        [GameFloatView hideGameView];
        
        [kRootVC.view addSubview:view];
        [kRootVC addChildViewController:view.gameVC];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.transform = CGAffineTransformMakeScale(0.5, 0.5);
            view.frame = CGRectMake(VK_SCREEN_W/2, VK_SCREEN_H/2, VK_SCREEN_W/2, VK_SCREEN_H/2);
        } completion:nil];
    }
}

+ (void)hideGameView {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    if (view) {
        [NSNotificationCenter.defaultCenter postNotificationName:KBetCloseNotificationMsg object:nil];
        [view removeFromSuperview];
        [view.gameVC removeFromParentViewController];
    }
    view = [vkTopVC().view viewWithTag:kGameFloatViewTag];
    if (view) {
        [NSNotificationCenter.defaultCenter postNotificationName:KBetCloseNotificationMsg object:nil];
        [view removeFromSuperview];
        [view.gameVC removeFromParentViewController];
    }
}

+ (void)sendToFront {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    if (view) {
        [kRootVC.view bringSubviewToFront:view];
    }
}

+ (void)sendToBack:(UIViewController*)controller frontView:(UIView*)frontView {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    if (view) {
        [controller.view insertSubview:view belowSubview:frontView];
    }
}

+ (BOOL)gameIsShow {
    GameFloatView *view = [kRootVC.view viewWithTag:kGameFloatViewTag];
    return view ? YES : NO;
}

@end
