//
//  MXBADelegate.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWindow           [UIApplication sharedApplication].keyWindow 
#define kPrompt_DismisTime    0.2


@class LaunchAdModel;
@interface MXBADelegate : NSObject

@property(nonatomic,assign)BOOL isAutoDirection;

@property (strong, nonatomic) UIWindow * _Nullable window;
//@property (strong, nonatomic) UIWindow * _Nullable keyWindow;
@property(nonatomic,strong)UIAlertController * _Nullable alertetworkStatueControl;
+ (instancetype _Nullable)sharedAppDelegate;

-(void)initSDK;

-(void)getConfig:(BOOL)checkVersion complete:(void (^_Nullable)(NSString * _Nullable errormsg))callback;
-(NSDictionary *_Nullable)getAppConfig:(void (^_Nullable)(NSString * _Nullable errormsg, NSDictionary * _Nullable json))callback;
-(void)checkNetworkStatue;

-(void)showLaunchAdWithModel:(LaunchAdModel*_Nullable)model;

- (UINavigationController *_Nullable)navigationViewController;

- (UINavigationController *_Nullable)homeNavigationViewController;

- (UIViewController *_Nullable)topViewController;

- (void)homePushViewController:(UIViewController *_Nullable)viewController animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *_Nullable)viewController animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *_Nullable)viewController animated:(BOOL)animated hidesBottomBarWhenPushed:(BOOL)isHide;
- (void)pushViewController:(UIViewController *_Nullable)viewController cell:(UIView *_Nullable)cell;
- (void)pushViewController:(UIViewController *_Nullable)viewController cell:(UIView * _Nullable)cell hidesBottomBarWhenPushed:(BOOL)isHide;

- (NSArray *_Nullable)popToViewController:(UIViewController *_Nullable)viewController;

- (UIViewController *_Nullable)popViewController:(BOOL)animated;

- (NSArray *_Nullable)popToRootViewController;

- (void)presentViewController:(UIViewController *_Nullable)vc animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;

- (void)dismissViewController:(UIViewController *_Nullable)vc animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
// 预加载游戏大厅图片
- (void)getGameInfo;
    
///delegate

-(UIInterfaceOrientationMask)application:(UIApplication *_Nullable)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

- (BOOL)application:(UIApplication *_Nullable)app openURL:(NSURL *_Nullable)url options:(NSDictionary<NSString*, id> *_Nullable)options;

- (BOOL)application:(UIApplication *_Nullable)application continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;


-(void)checkAppVersionWithHandle:(BOOL)Handle;
@end
