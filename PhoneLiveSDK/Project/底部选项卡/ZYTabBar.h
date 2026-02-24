//
//  ZYTabBar.h
//  自定义tabbarDemo
//
//  Created by tarena on 16/7/1.
//  Copyright © 2016年 张永强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXtabbar.h"
#import "TouchSuperView.h"
#import "LiveActivityView.h"
#import "ZYTabBarController.h"

@class ZYTabBar;
@protocol ZYTabBarDelegate <NSObject>
@required
- (void)pathButton:(ZYTabBar *)ZYTabBar clickItemButtonAtIndex:(NSUInteger)itemButtonIndex;
@end

@interface ZYTabBar : UITabBar
/** 点中button代理属性 */
@property (nonatomic , weak)id <ZYTabBarDelegate> delegateT;

/** 所有的弹出按钮 */
@property (nonatomic , strong)NSArray<ZYPathItemButton *> *pathButtonArray;
@property (nonatomic , strong)MXtabbar *plusBtn;
@property (nonatomic , strong)UILabel *kbLabel;

/** 弹出动画时间*/
@property (assign, nonatomic) NSTimeInterval basicDuration;
/** 设置弹出时是否旋转   */
@property (assign, nonatomic) BOOL allowSubItemRotation;

/**  设置底部弹出的半径，默认是105 */
@property (assign, nonatomic) CGFloat bloomRadius;

/**  设置散开的角度 */
@property (assign, nonatomic) CGFloat bloomAngel;

/**  设置中间的按钮是否旋转 */
@property (assign, nonatomic) BOOL allowCenterButtonRotation;

/**  配置tabbar Item */
@property (nonatomic, strong) NSDictionary *configData;
@property (assign, nonatomic) BOOL hasMiddle;
@property (assign, nonatomic) BOOL selected;
@property (nonatomic, strong) TouchSuperView *expandView;
@property (nonatomic, strong) UIImageView *expandBackgroundView;
@property (nonatomic , strong)NSMutableArray<LiveActivityButton *> *activityButtonArray;
@property (nonatomic, strong) UIImage *bgImg;
- (void)closeAnimation;
@end
