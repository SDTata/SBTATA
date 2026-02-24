//
//  GameFloatView.h
//  phonelive2
//
//  Created by vick on 2024/10/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFloatView.h"

@interface GameFloatView : BaseFloatView

@property (nonatomic, strong) UIViewController *gameVC;
@property (nonatomic, strong) UIView *frontMaskView;

/// 创建游戏视图
+ (void)createGameView:(UIViewController *)gameVC;

/// 显示游戏视图
+ (void)showNormalGameView;

/// 缩小游戏视图
+ (void)showSmallGameView;

/// 隐藏游戏视图
+ (void)hideGameView;

/// 显示最上层
+ (void)sendToFront;

/// 顯示指定畫面後面
+ (void)sendToBack:(UIViewController*)controller frontView:(UIView*)frontView;

/// 游戏是否显示
+ (BOOL)gameIsShow;

@end
