//
//  ZYTabBarController.h
//  tabbar增加弹出bar
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 张永强. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZYTabBarControllerType) {
    ZYTabBarControllerTypeGamepage,
    ZYTabBarControllerTypeShortVideo,
    ZYTabBarControllerTypeLive
};

@interface ZYTabBarController : UITabBarController
@property (nonatomic , strong)UIImageView *bg;
@property (nonatomic , strong) UIView *bgView;
- (void)setTabbarHiden:(BOOL)isHiddin;


- (void)startWobble;
- (void)stopAndHidenWobble;
- (BOOL)changeTab:(ZYTabBarControllerType)type;
- (UIViewController*)getTabController:(ZYTabBarControllerType)type;

@end
