//
//  ZYTabBarController.m
//  tabbar增加弹出bar
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 张永强. All rights reserved.
//
#import <UserNotifications/UserNotifications.h>
#import "ZYTabBarController.h"
#import "ZYTabBar.h"
#import "Livebroadcast.h"
#import "homepageController.h"
#import "YBUserInfoViewController.h"
#import "RankVC.h"
#import "myInfoEdit.h"
#import "LivePlay.h"
#import "live&VideoSelectView.h"
#import "GameHomeMainVC.h"
#import "PayViewController.h"
#import "TaskVC.h"
#import "myWithdrawVC2.h"
#import "EditContactInfo.h"
#import "MXBADelegate.h"
#import "HomeContainer.h"
#import "myPopularizeVC.h"
#import "UIView+Shake.h"
#import "OneBuyGirlViewController.h"
#import "Loginbonus.h"
#import "MoreAlertView.h"
#import "LiveNotificationAlert.h"

#import "VideoTicketFloatView.h"
#import "ShortVideosContainer.h"
#import "TouchSuperView.h"
#import "Lottie.h"
#import "MessageListNetworkUtil.h"
#import <UMCommon/UMCommon.h>
#import "VKSupportUtil.h"
@interface ZYTabBarController ()<ZYTabBarDelegate,UIAlertViewDelegate,liveVideoDelegate,TaskJumpDelegate,UIGestureRecognizerDelegate,FirstLogDelegate, UITabBarControllerDelegate,socketDelegate, UNUserNotificationCenterDelegate>
{
//    UIAlertView *alertupdate;
    NSString *type_val;//
    NSString *livetype;//
    UIAlertController *md5AlertController;
    hotModel *playDicModel;
    homepageController *homePage;
    ZYTabBar *zytabbar;
    HomeContainer *newHomeVC;
    
    TouchSuperView *assistive_view;
    UIButton *assistive_touchButton;
    UIButton *drama_touchButton;
    UIButton *openlive_bottom;
    UILabel *skitLabel;
    
    BOOL isWobble;
    
    
    //
    /********* firstLV -> ************/

    NSString *bonus_switch;
    NSString *bonus_day;
    NSArray  *bonus_list;
    NSString *dayCount;
    NSMutableArray  *coins;
    NSMutableArray  *days;
   
    //测试用变量
    NSString *testDay;//仅仅测试用（已注释）
    /********* <- firstLV ************/
    
    
    Loginbonus *firstLV;
    ShortVideosContainer *shortVideosVC;
}
@property(nonatomic,strong) NSMutableArray *arrayNotice2;

@property(nonatomic,strong)NSString *Build;

@property (nonatomic,assign) NSInteger  indexFlag;
//记录上一次点击tabbar，使用时，记得先在init或viewDidLoad里 初始化 = 0
@property (nonatomic, assign) NSTimeInterval lastTapTime;
@property (nonatomic, assign) NSTimeInterval shortVideoLastTapTime;

@property (nonatomic, strong) socketMovieplay *socketDelegate;
@property (nonatomic, copy) NSString *socketUrl;
@property (nonatomic,assign) NSInteger lastAnimationIndex;
@property (nonatomic,assign) NSInteger lastSelectedIndex;

@end

@implementation ZYTabBarController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [GameFloatView sendToFront];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.tabBar.selectedItem == 0) {
        [self startWobble];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopWobble];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
static  BOOL isShowNotifi = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1. 請求通知權限
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSLog(@"用戶拒絕了通知權限");
            return;
        }
    }];
    
    UNUserNotificationCenter.currentNotificationCenter.delegate = self;
    
    self.delegate = self;
    isShowNotifi = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aaaa:) name:@"jinruzhibojiantongzhi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bbbb:) name:@"system_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUnreadCount) name:@"UpdateUnreadMessages" object:nil];
    [self getBaseInfo:YES];
    
    // 启用interactivePopGestureRecognizer
    //    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    //    [self buildUpdate];
    //设置子视图
    [self setUpAllChildVc];
    [self configureMXtabbar];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if([Config getOwnID]){
            [strongSelf localLockBecomeActive];
            
        }
    });
    
    /// 图标数字授权
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    /// 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageNotice:) name:@"KNoticeMessageKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createSocket) name:@"KHomeSocketCreateKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteSocket) name:@"KHomeSocketDeleteKey" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MXBADelegate sharedAppDelegate] getGameInfo];
        [[MXBADelegate sharedAppDelegate] checkAppVersionWithHandle:false];
    });
    [self assistive];
    [self startWobble];
    
    
    
    //每天第一次登录
    //[self pullInternet];
    //登录奖励后台回到前台
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getBaseInfo:) name:KGetBaseInfoNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        
        if ([strongSelf->shortVideosVC superclass]) {
            [strongSelf->shortVideosVC loadViewIfNeeded];
        }
    });
    
 
    
    if([Config getOwnID]){
        [self localLockBecomeActive];
    }
    
}

- (BOOL)changeTab:(ZYTabBarControllerType)type {
    switch (type) {
        case ZYTabBarControllerTypeGamepage:
        {
            NSInteger index = [self fetchClassIndex:[GameHomeMainVC class]];
            [self setSelectedIndex:index];
            return index == -1 ? NO : YES;
        }
            break;
        case ZYTabBarControllerTypeShortVideo:
        {
            NSInteger index = [self fetchClassIndex:[ShortVideosContainer class]];
            [self setSelectedIndex:index];
            return index == -1 ? NO : YES;
        }
            break;
        case ZYTabBarControllerTypeLive:
        {
            NSInteger index = [self fetchClassIndex:[homepageController class]];
            [self setSelectedIndex:index];
            return index == -1 ? NO : YES;
        }
            break;
        default:
            break;
    }
    return NO;
}

- (NSInteger)fetchClassIndex:(Class)searchClass {
    for (int i = 0; i<self.viewControllers.count; i++) {
        UINavigationController *nav = self.viewControllers[i];
        if ([nav isKindOfClass:[UINavigationController class]] &&
            [nav.viewControllers.firstObject isKindOfClass:searchClass]) {
            return i;
        }
    }
    return -1;
}

- (UIViewController*)getTabController:(ZYTabBarControllerType)type {
    Class searchClass = nil;
    switch (type) {
        case ZYTabBarControllerTypeGamepage:
            searchClass = [GameHomeMainVC class];
            break;
        case ZYTabBarControllerTypeShortVideo:
            searchClass = [ShortVideosContainer class];
            break;
        case ZYTabBarControllerTypeLive:
            searchClass = [homepageController class];
            break;
        default:
            break;
    }

    if (searchClass == nil) {
        return nil;
    }

    UIViewController *vc = nil;
    for (int i = 0; i<self.viewControllers.count; i++) {
        UINavigationController *nav = self.viewControllers[i];
        if ([nav isKindOfClass:[UINavigationController class]] &&
            [nav.viewControllers.firstObject isKindOfClass:searchClass]) {
            vc = nav.viewControllers.firstObject;
            break;
        }
    }
    return vc;
}

#define RADIANS(degrees) (((degrees) * M_PI) / 180.0)
- (void)startWobble {
    if(isWobble){
        return;
    }
    isWobble = true;

    assistive_view.hidden = NO;

    if (drama_touchButton != nil) {
        drama_touchButton.hidden = NO;
    }
    
    if (![[RookieTools currentLanguageServer] isEqualToString:@"zh-cn"]|![common isShowfuckactivity]) {
        //assistive_touchButton.hidden = YES;
    }else{
        assistive_touchButton.hidden = NO;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startWobble) object:nil];
#ifdef LIVE
    openlive_bottom.hidden = NO;
//    [openlive_bottom shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
//        //        [self performSelector:@selector(startWobble) withObject:nil afterDelay:1.5f];
//    }];
#endif
    if (drama_touchButton != nil) {
        WeakSelf
        [drama_touchButton shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
            //        [self performSelector:@selector(startWobble) withObject:nil afterDelay:1.5f];
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            if(strongSelf->isWobble){
                [strongSelf performSelector:@selector(startWobble) withObject:nil afterDelay:2.0f];
                strongSelf->isWobble = false;
            }

        }];
    }
    
    if (assistive_touchButton != nil) {
        [assistive_touchButton shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
            //        [self performSelector:@selector(startWobble) withObject:nil afterDelay:1.5f];
        }];
    }
  
   
    
}


- (void)stopWobble {
#ifdef LIVE
    [openlive_bottom endShake];
#endif
    isWobble = false;
    if (assistive_touchButton != nil) {
        [assistive_touchButton endShake];
    }
    if (drama_touchButton != nil) {
        [drama_touchButton endShake];
    }
 
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startWobble) object:nil];

}

- (void)stopAndHidenWobble {
#ifdef LIVE
    openlive_bottom.hidden = YES;
//    [openlive_bottom endShake];
#endif
    isWobble = false;
    if (assistive_touchButton != nil) {
        [assistive_touchButton endShake];
        assistive_touchButton.hidden = YES;
    }
    if (drama_touchButton != nil) {
        [drama_touchButton endShake];
        drama_touchButton.hidden = YES;
    }
  
  
    assistive_view.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startWobble) object:nil];
}

-(void)assistive{
    // 不管37、21直接回收
    if([common getAutoExchange]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [GameToolClass backAllCoin:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                if (code == 0) {
                    
                }else{
                    //                    [MBProgressHUD showError:msg];
                }
            } fail:^{
            }];
        });
    }
    if(!assistive_view){
        assistive_view = [TouchSuperView new];

        [self.view addSubview:assistive_view];
        float minusHeight = 0;
        
#ifdef LIVE
        openlive_bottom = [UIButton buttonWithType:UIButtonTypeCustom];
        openlive_bottom.frame = CGRectMake(13, 0, 50, 50);
        [openlive_bottom setBackgroundImage:[ImageBundle imagewithBundleName:@"main_bottom_openlive"] forState:UIControlStateNormal];
        [openlive_bottom setBackgroundImage:[ImageBundle imagewithBundleName:@"main_bottom_openlive"] forState:UIControlStateDisabled];
        [openlive_bottom setBackgroundImage:[ImageBundle imagewithBundleName:@"main_bottom_openlive"] forState:UIControlStateHighlighted];
        [openlive_bottom addTarget:self action:@selector(openliveTouch) forControlEvents:UIControlEventTouchUpInside];
        [assistive_view addSubview:openlive_bottom];
        minusHeight = openlive_bottom.height;
#endif
        NSArray *floatingButtonArr = [self getAppConfig][@"MainPage"][@"ShakingFloatingButton"];
        if (floatingButtonArr!=nil && [floatingButtonArr isKindOfClass:[NSArray class]] && floatingButtonArr.count > 0) {
            for (int i = 0; i<floatingButtonArr.count; i++) {
                if ([floatingButtonArr[i][@"nav"] isEqualToString:@"nav://task"]) {
                    // 宝箱
                    drama_touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    drama_touchButton.hidden = NO;
                    NSString *icon_selected = floatingButtonArr[i][@"icon_selected"];
                    NSString *icon_normal = floatingButtonArr[i][@"icon_normal"];
                    [drama_touchButton sd_setImageWithURL:[NSURL URLWithString:icon_normal]
                                       forState:UIControlStateNormal
                               placeholderImage:[ImageBundle imagewithBundleName:@"main_bottom_baoxiang"]];
                    [drama_touchButton sd_setImageWithURL:[NSURL URLWithString:icon_normal]
                                       forState:UIControlStateDisabled
                               placeholderImage:[ImageBundle imagewithBundleName:@"main_bottom_baoxiang"]];
                    [drama_touchButton sd_setImageWithURL:[NSURL URLWithString:icon_selected]
                                       forState:UIControlStateHighlighted
                               placeholderImage:[ImageBundle imagewithBundleName:@"main_bottom_baoxiang"]];
                    minusHeight = minusHeight+8;
                    drama_touchButton.frame = CGRectMake(8,minusHeight, 60, 60);
                    minusHeight = minusHeight+60;
                    [drama_touchButton addTarget:self action:@selector(dramaTouch) forControlEvents:UIControlEventTouchUpInside];
                    [assistive_view addSubview:drama_touchButton];
                } else if ([floatingButtonArr[i][@"nav"] isEqualToString:@"nav://fuckgirl"]) {
                    // 一元空降
                    assistive_touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    NSString *icon_selected = floatingButtonArr[i][@"icon_selected"];
                    NSString *icon_normal = floatingButtonArr[i][@"icon_normal"];
                    [assistive_touchButton sd_setImageWithURL:[NSURL URLWithString:icon_normal]
                                       forState:UIControlStateNormal
                               placeholderImage:[ImageBundle imagewithBundleName:@"yiyuankj"]];
                    [assistive_touchButton sd_setImageWithURL:[NSURL URLWithString:icon_normal]
                                       forState:UIControlStateDisabled
                               placeholderImage:[ImageBundle imagewithBundleName:@"yiyuankj"]];
                    [assistive_touchButton sd_setImageWithURL:[NSURL URLWithString:icon_selected]
                                       forState:UIControlStateHighlighted
                               placeholderImage:[ImageBundle imagewithBundleName:@"yiyuankj"]];
                    minusHeight = minusHeight+8;
                    assistive_touchButton.frame = CGRectMake(8, minusHeight, 60, 60);
                    minusHeight = minusHeight+60;
                    [assistive_touchButton addTarget:self action:@selector(suspensionAssistiveTouch) forControlEvents:UIControlEventTouchUpInside];
                    [assistive_view addSubview:assistive_touchButton];
                    
                    if (![[RookieTools currentLanguageServer] isEqualToString:@"zh-cn"]|![common isShowfuckactivity]) {
                        assistive_touchButton.hidden = YES;
                    }
                }
            }
        }
        
        minusHeight = minusHeight;
        
        assistive_view.frame = CGRectMake(_window_width + 70,
                                          _window_height - minusHeight - ShowDiff-70,
                                          60,
                                          minusHeight);
//
//        WeakSelf
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            STRONGSELF
//            if (strongSelf==nil) {
//                return;
//            }
//            [UIView animateWithDuration:0.5 animations:^{
//                if (strongSelf == nil) {
//                    return;
//                }
//                CGRect view_frame = strongSelf->assistive_view.frame;
//                view_frame.origin.x = _window_width - 85;
//                
//                strongSelf->assistive_view.frame = view_frame;
        CGRect view_frame = assistive_view.frame;
        view_frame.origin.x = _window_width - 85;
        
        assistive_view.frame = view_frame;
        
//            } completion:^(BOOL finished) {
//                if (strongSelf == nil) {
//                    return;
//                }
//              
//            }];
//        });
    }
    
    [self.view bringSubviewToFront:assistive_view];
}

/// 接收消息
- (void)getMessageNotice:(NSNotification *)notice {
    NSString *number = [notice.object stringValue];
    number = number.integerValue > 0 ? number : nil;
    [self setUnreadMsgNum:number];
}
-(void)setUnreadMsgNum:(NSString*)number {
    self.tabBar.items.lastObject.badgeValue = number;
    [UIApplication sharedApplication].applicationIconBadgeNumber = number.integerValue;

    [self.tabBar layoutIfNeeded];
    [self.tabBar setNeedsLayout];
    
}
#ifdef LIVE
- (void)openliveTouch {
    [self requestAccess];
}
#endif
- (void)dramaTouch {
//    TaskVC *taskVC = [[TaskVC alloc]initWithNibName:@"TaskVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//    taskVC.delelgate = self;
//    taskVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [[MXBADelegate sharedAppDelegate].topViewController presentViewController:taskVC animated:NO completion:nil];
    [YBUserInfoManager.sharedManager pushToTaskCenter: nil];
//    DramaHomeViewController *viewController = [[DramaHomeViewController alloc] init];
//    [[MXBADelegate sharedAppDelegate] pushViewController:viewController animated:YES];
}
-(void)suspensionPopularizeTouch{
    myPopularizeVC *VC = [[myPopularizeVC alloc]init];
    VC.titleStr = YZMsg(@"Hotpage_my_expand");
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
}
-(void)suspensionAssistiveTouch {
    [YBUserInfoManager.sharedManager pushToOneBuyGirl];
}


- (void)localLockBecomeActive {
    if ([VKSupportUtil isLocalGestureEnableForUserId:[Config getOwnID]]) {
        [VKSupportUtil showLockGesture:[Config getOwnID] type:FQLockTypeLogin isPush:NO];
    }
}

- (void)configureMXtabbar {
    if (!zytabbar) {
        zytabbar = [ZYTabBar new];
    }
    zytabbar.delegateT = self;
    
    NSDictionary *middleDic = [self getAppConfig][@"MainPage"][@"tabbar"][@"middle"];
    if (middleDic) {
        zytabbar.configData = middleDic;
        zytabbar.hasMiddle = YES;
    } else {
        zytabbar.hasMiddle = NO;
    }
    
    zytabbar.translucent = NO;

    [self setValue:zytabbar forKey:@"tabBar"];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (@available(iOS 10.0, *)) {
        zytabbar.tintColor = [UIColor clearColor];
        zytabbar.unselectedItemTintColor = [UIColor clearColor];
    } else {
        NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
        textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:11];
        textAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
        
        NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
        selectedTextAttrs[NSFontAttributeName] = textAttrs[NSFontAttributeName];
        selectedTextAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
        
        UITabBarItem *item = [UITabBarItem appearance];
        [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
        [item setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
    }
    UIImage *defaultImage = [ImageBundle imagewithBundleName:@"tabBar_bg"];
    zytabbar.bgImg = defaultImage;

    NSURL *backgroundImageURL = [NSURL URLWithString:[self getAppConfig][@"MainPage"][@"tabbar"][@"bg_normal"]];
    WeakSelf
    [[SDWebImageManager sharedManager] loadImageWithURL:backgroundImageURL
                                                options:0
                                               progress:nil
                                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (!strongSelf) return;
        if (image) {
            strongSelf->zytabbar.bgImg = image;
        }
    }];
}


#pragma mark  在这里更换 左右tabbar的image
- (void)setUpAllChildVc {    
    
    //首页
    if (!homePage) {
        homePage = [[homepageController alloc]init];
    }
    ////点播

    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:true];
    
   
    //我的
    YBUserInfoViewController *userInfo = [YBUserInfoViewController new];
    
    //游戏中心
    GameHomeMainVC *game = [[GameHomeMainVC alloc] init];

 /*
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, _window_height - (68 + (iPhoneX?34/2:5)), _window_width, 68+(iPhoneX?34/2:5))];
    bg.contentMode = UIViewContentModeScaleToFill;
    CGFloat leftRightInset = 25.0;
    CGFloat bottomInset = 0.0;

    // 使用 UIEdgeInsets 计算不被拉伸的边界
    UIEdgeInsets insets = UIEdgeInsetsMake(30, leftRightInset, bottomInset, leftRightInset);

    // 生成可拉伸的图片
    UIImage *stretchableImage = [[ImageBundle imagewithBundleName:@"main_bottom_bg_visitor"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
#ifdef LIVE
        [bg setImage:stretchableImage];
#else
        // 设置边界
        
        [bg setImage:stretchableImage];
#endif
        [self.view addSubview:bg];
        self.bg = bg;
*/
//    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height - (68 + (iPhoneX?34/2:-14)), _window_width, (iPhoneX?84:54))];
//    self.bgView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.bgView];
    
    
    NSArray *normalTabbarArray = [self getAppConfig][@"MainPage"][@"tabbar"][@"tabbar_buttons"];
    NSArray *middleTabbarArray = [self getAppConfig][@"MainPage"][@"tabbar"][@"middle"][@"buttons"];
    for (NSDictionary *tabItem in normalTabbarArray) {
//        @{
//            @"title": YZMsg(@"ZYTabBarC_HomePage"),
//            @"icon_selected": @"tabbar_home_selected",
//            @"icon_normal": @"tabbar_home_normal",
//            @"text_color_selected": @"#9F57DF",
//            @"text_color_normal": @"#7E778C",
//            @"nav": @"nav://homepage"
//        },
//        @{
//            @"title": YZMsg(@"homepageController_game"),
//            @"icon_selected": @"tabbar_game_selected",
//            @"icon_normal": @"tabbar_game_normal",
//            @"text_color_selected": @"#9F57DF",
//            @"text_color_normal": @"#7E778C",
//            @"nav": @"nav://gamepage"
//        },
//        @{
//            @"title": @"直播",
//            @"icon_selected": @"tabbar_live_selected",
//            @"icon_normal": @"tabbar_live_normal",
//            @"text_color_selected": @"#9F57DF",
//            @"text_color_normal": @"#7E778C",
//            @"nav": @"nav://live"
//        },
//        @{
//            @"title": YZMsg(@"Bet_Charge_Title"),
//            @"icon_selected": @"tabbar_recharge_selected",
//            @"icon_normal": @"tabbar_recharge_normal",
//            @"text_color_selected": @"#9F57DF",
//            @"text_color_normal": @"#7E778C",
//            @"nav": @"nav://chargepage"
//        },
//        @{
//            @"title": YZMsg(@"ZYTabBarC_MePage"),
//            @"icon_selected": @"tabbar_profile_selected",
//            @"icon_normal": @"tabbar_profile_normal",
//            @"text_color_selected": @"#9F57DF",
//            @"text_color_normal": @"#7E778C",
//            @"nav": @"nav://personalPage"
//        }
        NSString *navString = tabItem[@"nav"];
        NSString *title = tabItem[@"title"];
        NSString *icon_normal = tabItem[@"icon_normal"];
        NSString *icon_selected = tabItem[@"icon_selected"];
        
        if ([PublicObj checkNull:icon_normal] && [PublicObj checkNull:icon_selected]) {
            if ([navString containsString:@"homepage"]) {
                icon_normal = @"tabbar_home_normal";
                icon_selected = @"tabbar_home_selected";
            } else if ([navString containsString:@"shortVideo"]) {// shortVideo
                icon_normal = @"tabbar_shortVideo_normal";
                icon_selected = @"tabbar_shortVideo_selected";
            } else if ([navString containsString:@"chargepage"]) {
                icon_normal = @"tabbar_recharge_normal";
                icon_selected = @"tabbar_recharge_selected";
            }else if ([navString containsString:@"liveshow"]) {
                icon_normal = @"tabbar_live_normal";
                icon_selected = @"tabbar_live_selected";
            }else if ([navString containsString:@"gamepage"]) {
                icon_normal = @"tabbar_game_normal";
                icon_selected = @"tabbar_game_selected";
            }else if ([navString containsString:@"personalPage"]) {
                icon_normal = @"tabbar_profile_normal";
                icon_selected = @"tabbar_profile_selected";
            }
        }
      
       
        
        NSString *textColor_normal = tabItem[@"text_color_normal"];
        NSString *textColor_selected = tabItem[@"text_color_selected"];
        if ([navString isEqualToString:@"nav://homepage"]) {
            newHomeVC = [HomeContainer new];
            [self setUpOneChildVcWithVc:newHomeVC Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://shortVideo"]) { // nav://shortVideo
            shortVideosVC = [ShortVideosContainer new];
            [self setUpOneChildVcWithVc:shortVideosVC Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://chargepage"]) {
            [self setUpOneChildVcWithVc:payView Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://personalPage"]) {
            [self setUpOneChildVcWithVc:userInfo Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://gamepage"]) {
            [self setUpOneChildVcWithVc:game Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://liveshow"]) {
            [self setUpOneChildVcWithVc:homePage Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else {
            NSLog(@"nav %@", navString);
        }
    }
    for (NSDictionary *tabItem in middleTabbarArray) {
        NSString *navString = tabItem[@"nav"];
        NSString *title = tabItem[@"title"];
        NSString *icon_normal = tabItem[@"icon_normal"];
        NSString *icon_selected = tabItem[@"icon_selected"];
        NSString *textColor_normal = tabItem[@"text_color_normal"];
        NSString *textColor_selected = tabItem[@"text_color_selected"];
        if ([navString isEqualToString:@"nav://shortVideo"]) {
            UIViewController *vc1 = [UIViewController new];
            vc1.view.backgroundColor = UIColor.yellowColor;
            [self setUpOneChildVcWithVc:vc1 Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://shortSkit"]) {
            UIViewController *vc2 = [UIViewController new];
            vc2.view.backgroundColor = UIColor.redColor;
            [self setUpOneChildVcWithVc:vc2 Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else if ([navString isEqualToString:@"nav://longvideo"]) {
            UIViewController *vc3 = [UIViewController new];
            vc3.view.backgroundColor = UIColor.greenColor;
            [self setUpOneChildVcWithVc:vc3 Image:icon_normal selectedImage:icon_selected title:title textColorNormal:textColor_normal textColorSelected:textColor_selected nav:navString];
        } else {
            NSLog(@"nav %@", navString);
        }
    }
//    if(isOpenFiter){
        
        
      
       
//        [self setUpOneChildVcWithVc:rVC Image:@"tab_rank" selectedImage:@"tab_rank_sel" title:YZMsg(@"排行")];
//    }else{
//        [self setUpOneChildVcWithVc:homePage Image:@"tab_home" selectedImage:@"tab_home_sel" title:YZMsg(@"首页")];
//        [self setUpOneChildVcWithVc:payView Image:@"tab_near" selectedImage:@"tab_near_sel" title:YZMsg(@"充值")];
//        [self setUpOneChildVcWithVc:rVC Image:@"tab_rank" selectedImage:@"tab_rank_sel" title:YZMsg(@"排行")];
//        [self setUpOneChildVcWithVc:game Image:@"tab_game" selectedImage:@"tab_game_sel" title:YZMsg(@"游戏")];
//        [self setUpOneChildVcWithVc:userInfo Image:@"tab_mine" selectedImage:@"tab_mine_sel" title:YZMsg(YZMsg(@"我的"))];
//    }
}
- (NSString *)checkIconToLoacl:(NSString *)navString isNormal:(BOOL)isNormal {
    if ([navString isEqualToString:@"nav://homepage"]) {
        return isNormal ? @"tabbar_home_normal" : @"tabbar_home_selected";
    } else if ([navString isEqualToString:@"nav://shortVideo"]) {
        return isNormal ? @"tabbar_shortVideo_normal" : @"tabbar_shortVideo_selected";
    } else if ([navString isEqualToString:@"nav://chargepage"]) {
        return isNormal ? @"tabbar_recharge_normal" : @"tabbar_recharge_selected";
    } else if ([navString isEqualToString:@"nav://personalPage"]) {
        return isNormal ? @"tabbar_profile_normal" : @"tabbar_profile_selected";
    } else if ([navString isEqualToString:@"nav://gamepage"]) {
        return isNormal ? @"tabbar_game_normal" : @"tabbar_game_selected";
    } else if ([navString isEqualToString:@"nav://liveshow"]) {
        return isNormal ? @"tabbar_live_normal" : @"tabbar_live_selected";
    } else {
        return @"";
    }
}
#pragma mark - 初始化设置tabBar上面单个按钮的方法
/**
 *  @author li bo, 16/05/10
 *
 *  设置单个tabBarButton
 *
 *  @param Vc            每一个按钮对应的控制器
 *  @param imageStr         每一个按钮对应的普通状态下图片
 *  @param selectedImageStr 每一个按钮对应的选中状态下的图片
 *  @param title         每一个按钮对应的标题
 */
- (void)setUpOneChildVcWithVc:(UIViewController *)Vc Image:(NSString *)imageStr selectedImage:(NSString *)selectedImageStr title:(NSString *)title
              textColorNormal:(NSString *)normalHex textColorSelected:(NSString *)selectedHex nav:(NSString *)navString
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:Vc];
    // 在方法中定义两个属性来存储加载后的图片
    __block UIImage *loadedImage = nil;
    __block UIImage *loadedSelectedImage = nil;

    // 定义一个方法来检查是否都加载完成
    void (^updateTabBarItemIfNeeded)(void) = ^{
        if (loadedImage && loadedSelectedImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 重新分配 tabBarItem
                Vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:loadedImage selectedImage:loadedSelectedImage];
                [Vc.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, 1)];
                [Vc.tabBarItem setImageInsets:UIEdgeInsetsMake(1, 0, -1, 0)];

                unsigned normalResult = 0;
                NSScanner *scanner1 = [NSScanner scannerWithString:normalHex];
                [scanner1 setScanLocation:1];
                [scanner1 scanHexInt:&normalResult];
                
                unsigned selectedResult = 0;
                NSScanner *scanner2 = [NSScanner scannerWithString:selectedHex];
                [scanner2 setScanLocation:1];
                [scanner2 scanHexInt:&selectedResult];
                
                [Vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: vkColorHex(normalResult)} forState:UIControlStateNormal];
                [Vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: vkColorHex(selectedResult)} forState:UIControlStateSelected];

                if (@available(iOS 13.0, *)) {
                    UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
                    tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: vkColorHex(normalResult)};
                    tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: vkColorHex(selectedResult)};
                    Vc.tabBarItem.standardAppearance = tabBarAppearance;
                } else {
                    // Fallback on earlier versions
                }
            });
        }
    };

    // 加载默认图片
    if ([imageStr containsString:@"http"]) {
        // 异步加载普通图片
        WeakSelf
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageStr] options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            STRONGSELF
            if (!strongSelf) return;
            if (image) {
                loadedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                NSString *normalStr = [strongSelf checkIconToLoacl:navString isNormal:YES];
                loadedImage = [[ImageBundle imagewithBundleName:normalStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            // 检查是否可以更新
            updateTabBarItemIfNeeded();
        }];

        // 异步加载选中状态图片
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:selectedImageStr] options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            STRONGSELF
            if (!strongSelf) return;
            if (image) {
                loadedSelectedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                NSString *selectedStr = [strongSelf checkIconToLoacl:navString isNormal:NO];
                loadedSelectedImage = [[ImageBundle imagewithBundleName:selectedStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            // 检查是否可以更新
            updateTabBarItemIfNeeded();
        }];
    } else {
        // 如果是本地图片，直接赋值并立即更新
        NSString *normalStr = [self checkIconToLoacl:navString isNormal:YES];
        loadedImage = [[ImageBundle imagewithBundleName:normalStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        NSString *selectedStr = [self checkIconToLoacl:navString isNormal:NO];
        loadedSelectedImage = [[ImageBundle imagewithBundleName:selectedStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        // 检查是否可以更新
        updateTabBarItemIfNeeded();
    }
    [self addChildViewController:nav];
}

//点击开始直播
- (void)pathButton:(MXtabbar *)MXtabbar clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
#ifdef LIVE
    [self requestAccess];
#else
    TaskVC *taskVC = [[TaskVC alloc]initWithNibName:@"TaskVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    taskVC.delelgate = self;
    taskVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[MXBADelegate sharedAppDelegate].topViewController presentViewController:taskVC animated:NO completion:nil];
    
#endif
}

#ifdef LIVE
-(void)requestAccess{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 停用旧 session
    [session setActive:NO error:nil];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
       
        // 激活
        WeakSelf
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (granted) {
              
            }
        }];
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            dispatch_main_async_safe(^{
                if (granted) {
                    //弹出麦克风权限
                    
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        STRONGSELF
                        if (strongSelf == nil) {
                            return;
                        }
                        if (granted) {
                            // 3. 在主线程统一配置 audio session
                                             
                                               // deactivate 先关掉旧状态（如果 active）
                                               [session setActive:NO error:nil];
                                               
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    // 设置新的 category
                                    NSError *error = nil;
                                
                                    // 允许后台混音
                                    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                                             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                                   error:&error];
                                    [session setMode:AVAudioSessionModeVideoChat error:&error]; // 直播场景推荐使用 VideoChat 模式
                                    [session setActive:YES error:&error];
                                    
                                    // 儲存各種輸入類型
                                    AVAudioSessionPortDescription *usbAudio = nil;
                                    AVAudioSessionPortDescription *wiredMic = nil;
                                    AVAudioSessionPortDescription *bluetoothMic = nil;
                                    AVAudioSessionPortDescription *builtInMic = nil;

                                    // 遍歷所有可用輸入裝置
                                    for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                                        NSLog(@"🔌 可用輸入: %@, 類型: %@", port.portName, port.portType);

                                        if ([port.portType isEqualToString:AVAudioSessionPortUSBAudio]) {
                                            usbAudio = port;
                                        } else if ([port.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
                                            wiredMic = port;
                                        } else if ([port.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
                                                   [port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
                                                   [port.portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
                                            bluetoothMic = port;
                                        } else if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                                            builtInMic = port;
                                        }
                                    }

                                    // 按照優先順序選擇輸入設備
                                    AVAudioSessionPortDescription *preferredPort = nil;
                                    if (usbAudio) {
                                        preferredPort = usbAudio;
                                    } else if (wiredMic) {
                                        preferredPort = wiredMic;
                                    } else if (bluetoothMic) {
                                        preferredPort = bluetoothMic;
                                    } else if (builtInMic) {
                                        preferredPort = builtInMic;
                                    }

                                    if (preferredPort) {
                                        NSError *setError = nil;
                                        BOOL success = [session setPreferredInput:preferredPort error:&setError];
                                        if (success) {
                                            NSLog(@"✅ 使用音频输入设备: %@ (%@)", preferredPort.portName, preferredPort.portType);
                                        } else {
                                            for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                                                if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                                                    [session setPreferredInput:port error:&error];
                                                    if (error) {
                                                        NSLog(@"❌ 设置内建麦克风失败: %@", error.localizedDescription);
                                                    } else {
                                                        NSLog(@"✅ 成功强制使用内建麦克风");
                                                    }
                                                    break;
                                                }
                                            }
                                        }
                                    } else {
                                        NSLog(@"⚠️ 未找到任何可用输入设备");
                                        // 4. 遍历输入设备，强制设为内建麦克风
                                            for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                                                if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                                                    [session setPreferredInput:port error:&error];
                                                    if (error) {
                                                        NSLog(@"❌ 设置内建麦克风失败: %@", error.localizedDescription);
                                                    } else {
                                                        NSLog(@"✅ 成功强制使用内建麦克风");
                                                    }
                                                    break;
                                                }
                                            }
                                    }
                              
                                    // 停用旧 session
//                                    [session setActive:NO error:nil];
                                    [strongSelf openLive];
                                });
                          
                        }else{
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:YZMsg(@"Livebroadcast_private_rule_no") message:YZMsg(@"Livebroadcast_please_open_mic_private") delegate:strongSelf cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                  
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf requestAccess];
                    });
                }
            });
            
        }];
        // 请求麦克风权限
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
               
            } else {
                NSLog(@"用户拒绝了麦克风权限");
            }
        }];
        
    });
   
    
}

-(void)openLive{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:5];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopBannerTimer" object:nil];
    WeakSelf
    [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
        STRONGSELF
        if (errormsg!= nil) {
            [MBProgressHUD showError:errormsg];
            return;
        }
     
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
        NSArray *applist = [Config getAppList];
        BOOL isConfigContact = NO;
        for (LiveAppItem *app in applist) {
            if (app.info.length > 0) {
                isConfigContact = YES;
            }
        }
        if(!isConfigContact){
            //没有配置主播名片
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"ContactInfo_notEditTipsTitle") message:YZMsg(@"ContactInfo_notEditTipsMsg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:YZMsg(@"ContactInfo_notEditTipsSure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                EditContactInfo *EditContactInfoView = [[EditContactInfo alloc] init];
                [[MXBADelegate sharedAppDelegate] pushViewController:EditContactInfoView animated:YES];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"ContactInfo_notEditTipsCancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alertC dismissViewControllerAnimated:YES completion:nil];
                //继续开播
                Livebroadcast *start = [[Livebroadcast alloc]init];
                [[MXBADelegate sharedAppDelegate] pushViewController:start animated:YES];
            }];
            [alertC addAction:sure];
            [alertC addAction:cancel];
            if (strongSelf.presentedViewController == nil) {
                [strongSelf presentViewController:alertC animated:YES completion:nil];
            }
        }else{
            //已经配置主播名片
            Livebroadcast *start = [[Livebroadcast alloc]init];
            [[MXBADelegate sharedAppDelegate] pushViewController:start animated:YES];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}
#else

#endif

-(void)taskJumpWithTaskID:(NSInteger)taskID
{
    switch (taskID) {
        case 1:
        case 4:
        case 7:
        case 8:
            
            self.selectedIndex = 1;
            break;
        case 2:
        case 6:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 16:
            
            self.selectedIndex = 2;
            break;
        case 3:
        case 5:
        case 15:
        {
            myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
            withdraw.titleStr = YZMsg(@"public_WithDraw");
            [[MXBADelegate sharedAppDelegate] pushViewController:withdraw animated:YES];
        }
            
            break;
            
        default:
            break;
    }
}

- (NSDictionary *)getAppConfig {
    NSDictionary *cachedConfig = [[MXBADelegate sharedAppDelegate] getAppConfig:nil];
    /*
    NSDictionary *data = @{
        @"MainPage": @{
            @"ShakingFloatingButton": @[
                @{
                    @"title": @"推广赚钱",
                    @"icon_selected": @"imgeurl",
                    @"icon_normal": @"imgeurl",
                    @"text_color_selected": @"#FFFFFF",
                    @"text_color_normal": @"#000000",
                    @"nav": @"nav://推广赚钱"
                },
                @{
                    @"title": @"一元空降",
                    @"icon_selected": @"imgeurl",
                    @"icon_normal": @"imgeurl",
                    @"text_color_selected": @"#FFFFFF",
                    @"text_color_normal": @"#000000",
                    @"nav": @"nav://一元空降"
                },
                @{
                    @"title": @"宝箱",
                    @"icon_selected": @"imgeurl",
                    @"icon_normal": @"imgeurl",
                    @"text_color_selected": @"#FFFFFF",
                    @"text_color_normal": @"#000000",
                    @"nav": @"nav://宝箱"
                },
                @{
                    @"title": @"短剧入口",
                    @"icon_selected": @"imgeurl",
                    @"icon_normal": @"imgeurl",
                    @"text_color_selected": @"#FFFFFF",
                    @"text_color_normal": @"#000000",
                    @"nav": @"nav://短剧入口"
                }
            ],
            @"tabbar": @{
                @"bg_normal": @"tabbar的背景长条图",
//                @"middle": @{
//                    @"icon_bg": @"中间按钮的背景图",
//                    @"icon_nor mal": @"中间按钮的显示icon",
//                    @"title": @"中间按钮标题",
//                    @"icon_show": @"中间按钮展开的悬浮图",
//                    @"buttons": @[
//                        @{
//                            @"title": @"短视频",
//                            @"icon_selected": @"http://hd.godtuk.com/livephone/bx.png",
//                            @"icon_normal": @"http://hd.godtuk.com/livephone/bx.png",
//                            @"text_color_selected": @"#FFFFFF",
//                            @"text_color_normal": @"#000000",
//                            @"nav": @"nav://shortVideo"
//                        },
//                        @{
//                            @"title": @"短剧",
//                            @"icon_selected": @"http://hd.godtuk.com/20230124/63cfe92f0d15c.png",
//                            @"icon_normal": @"http://hd.godtuk.com/20230124/63cfe92f0d15c.png",
//                            @"text_color_selected": @"#FFFFFF",
//                            @"text_color_normal": @"#000000",
//                            @"nav": @"nav://shortSkit"
//                        },
//                        @{
//                            @"title": @"长视频",
//                            @"icon_selected": @"http://hd.godtuk.com/livephone/bx.png",
//                            @"icon_normal": @"http://hd.godtuk.com/livephone/bx.png",
//                            @"text_color_selected": @"#FFFFFF",
//                            @"text_color_normal": @"#000000",
//                            @"nav": @"nav://longvideo"
//                        },
//                        @{
//                            @"title": @"按鈕4",
//                            @"icon_selected": @"http://hd.godtuk.com/20230124/63cfe92f0d15c.png",
//                            @"icon_normal": @"http://hd.godtuk.com/20230124/63cfe92f0d15c.png",
//                            @"text_color_selected": @"#FFFFFF",
//                            @"text_color_normal": @"#000000",
//                            @"nav": @"nav://longvideo"
//                        }
//                    ]
//                },
                @"normal": @[
                    @{
                        @"title": YZMsg(@"ZYTabBarC_HomePage"),
                        @"icon_selected": @"tabbar_home_selected",
                        @"icon_normal": @"tabbar_home_normal",
                        @"text_color_selected": @"#9F57DF",
                        @"text_color_normal": @"#7E778C",
                        @"nav": @"nav://homepage"
                    },
                    @{
                        @"title": YZMsg(@"homepageController_game"),
                        @"icon_selected": @"tabbar_game_selected",
                        @"icon_normal": @"tabbar_game_normal",
                        @"text_color_selected": @"#9F57DF",
                        @"text_color_normal": @"#7E778C",
                        @"nav": @"nav://gamepage"
                    },
                    @{
                        @"title": @"直播",
                        @"icon_selected": @"tabbar_live_selected",
                        @"icon_normal": @"tabbar_live_normal",
                        @"text_color_selected": @"#9F57DF",
                        @"text_color_normal": @"#7E778C",
                        @"nav": @"nav://live"
                    },
                    @{
                        @"title": YZMsg(@"Bet_Charge_Title"),
                        @"icon_selected": @"tabbar_recharge_selected",
                        @"icon_normal": @"tabbar_recharge_normal",
                        @"text_color_selected": @"#9F57DF",
                        @"text_color_normal": @"#7E778C",
                        @"nav": @"nav://chargepage"
                    },
                    @{
                        @"title": YZMsg(@"ZYTabBarC_MePage"),
                        @"icon_selected": @"tabbar_profile_selected",
                        @"icon_normal": @"tabbar_profile_normal",
                        @"text_color_selected": @"#9F57DF",
                        @"text_color_normal": @"#7E778C",
                        @"nav": @"nav://personalPage"
                    }
                ]
            }
        }
    };
    */
    return cachedConfig;
}

//-(void)buildUpdate{
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    NSString *url = [NSString stringWithFormat:@"%@?service=Home.getConfig",[DomainManager sharedInstance].baseAPIString];
//    NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
//    NSString *sign = [YBToolClass getRequestSign:url params:pDic];
//    pDic[@"__sign"] = sign;
//    WeakSelf
//    [session POST:url parameters:pDic headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//
//        NSNumber *number = [responseObject valueForKey:@"ret"] ;
//        if([number isEqualToNumber:[NSNumber numberWithInt:200]])
//        {
//            NSArray *data = [responseObject valueForKey:@"data"];
//            int code = [minstr([data valueForKey:@"code"]) intValue];
//            NSArray *info = [data valueForKey:@"info"];
//            if (code == 0) {
//                NSDictionary *subdic = [info firstObject];
//                if (![subdic isEqual:[NSNull null]]) {
//                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//                    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//                    // 缓存客服地址
//                    if ([subdic isKindOfClass:[NSDictionary class]]) {
//                        NSString *chat_service_url = [subdic objectForKey:@"chat_service_url"];
//                        [common saveServiceUrl:chat_service_url];
//                    }
//                    NSString *ios_shelves = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ios_shelves"]];
//                    //ios_shelves 为上架版本号，与本地一致则为上架版本,需要隐藏一些东西
//                    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
//                    if (![ios_shelves isEqual:app_build]) {
//                        //  NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];version
//                        //  NSLog(@"当前应用软件版本:%@",appCurVersion);
//                        NSString *ipa_des = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_des"]];
//                        NSString *build = [subdic valueForKey:@"ipa_ver"];//远程
//                        NSComparisonResult r = [app_Version compare:build];
//                        strongSelf.Build =[NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_url"]];
//                        if (r == NSOrderedAscending) {
//                           strongSelf->alertupdate = [[UIAlertView alloc]initWithTitle:YZMsg(@"提示") message:minstr(ipa_des) delegate:strongSelf cancelButtonTitle:YZMsg(@"使用旧版") otherButtonTitles:YZMsg(@"前往更新"), nil];
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//                                if (strongSelf == nil) {
//                                    return;
//                                }
//                                [strongSelf->alertupdate show];
//                            });
//                        }
//                    }
//                    else{
//
//
//                    }
//                    NSString *maintain_switch = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"maintain_switch"]];
//                    NSString *maintain_tips = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"maintain_tips"]];
//                    if ([maintain_switch isEqual:@"1"]) {
//                        UIAlertView *alertMaintain = [[UIAlertView alloc]initWithTitle:YZMsg(@"维护信息") message:maintain_tips delegate:strongSelf cancelButtonTitle:YZMsg(@"确认") otherButtonTitles:nil, nil];
//                        [alertMaintain show];
//                    }
//                    liveCommon *commons = [[liveCommon alloc]initWithDic:subdic];
//                    [common saveProfile:commons];
//                    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//                    dispatch_async(queue, ^{
//                        [strongSelf downloadAllLevelImage:[subdic valueForKey:@"level"]];
//                    });
//
//                    //接口请求完成发送通知
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"home.getconfig" object:nil];
//                }
//
//            }
//
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
//
//}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_Build] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
}
- (void)aaaa:(NSNotification *)noti{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self setSelectedIndex:0];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->homePage.categoryView selectItemAtIndex:0];
    });
    
    //    playDic = [noti object];
//    [self checklive:minstr([playDic valueForKey:@"stream"]) andliveuid:minstr([playDic valueForKey:@"uid"])];
}
- (void)bbbb:(NSNotification *)noti{

}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [self showTabBarAnimation];
    [self->zytabbar closeAnimation];
    NSInteger index = [self.tabBar.items indexOfObject:item];
    [newHomeVC setHiddenMenuAndSearchButton:index];
    
    NSString *tabbar_name = [NSString stringWithFormat:@"%@%@", item.title, @"tab"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"tabbar_name": tabbar_name};
    [MobClick event:@"tab_home_click" attributes:dict];
    
    if (index != self.indexFlag) {
        //执行动画
        NSMutableArray *arry = [NSMutableArray array];
        NSArray *subviewssss = self.tabBar.subviews;
        for (UIView *btn in subviewssss) {
            if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                btn.backgroundColor = [UIColor clearColor];
                [arry addObject:btn];
            }
        }
    
        //添加动画
        //放大效果，并回到原位
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        //速度控制函数，控制动画运行的节奏
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.duration = 0.2;       //执行时间
        animation.repeatCount = 1;      //执行次数
        animation.autoreverses = YES;    //完成动画后会回到执行动画之前的状态
        animation.fromValue = [NSNumber numberWithFloat:0.9];   //初始伸缩倍数
        animation.toValue = [NSNumber numberWithFloat:1.1];     //结束伸缩倍数

        if (arry.count>0) {
            //CAShapeLayer *circle = [CAShapeLayer layer];
            UIView *v = arry[index];
            [v.layer addAnimation:animation forKey:nil];
        }
    
        self.indexFlag = index;
    }
   
}

//- (void)downloadAllLevelImage:(NSArray *)arr{
//    for (NSDictionary *dic in arr) {
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        [manager loadImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]
//                          options:(SDWebImageLowPriority | SDWebImageContinueInBackground)
//                         progress:nil
//                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        }];
//        
//    }
//}
#pragma mark ================ 视频直播选择视图代理 ===============
-(void)clickLive:(BOOL)islive{
    if (islive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopBannerTimer" object:nil];
        Livebroadcast *start = [[Livebroadcast alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:start animated:YES];

    }else{
//        TCVideoRecordViewController *video = [[TCVideoRecordViewController alloc]init];
//        [[MXBADelegate sharedAppDelegate] pushViewController:video animated:YES];
    }
    [self hideSelctView];
}
-(void)hideSelctView{
//    [selectView removeFromSuperview];
//    selectView = nil;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
-(void)dealloc
{
    [self deleteSocket];
    NSLog(@"ZYTabBarController dealloc");
}

#pragma mark ================ 隐藏 tabbar ================
- (void)setTabbarHiden:(BOOL)isHidden {
    self.bg.hidden = isHidden;
    zytabbar.plusBtn.hidden = isHidden;
    self.tabBar.hidden = isHidden;
    [self.bgView setHidden:isHidden];
}





////首页弹框
///
///

static BOOL isRequesting = NO;
//-(void)pullInternet {
//    isRequesting = NO;
//    WeakSelf
//    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.Bonus" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        if (code == 0) {
//            NSArray *infos = info;
//            strongSelf->bonus_switch = [NSString stringWithFormat:@"%@",[[infos lastObject] valueForKey:@"bonus_switch"]];
//            strongSelf->bonus_day = [[infos lastObject] valueForKey:@"bonus_day"];
//           strongSelf-> bonus_list = [[infos lastObject] valueForKey:@"bonus_list"];
//          
//            int day = [strongSelf->bonus_day intValue];
//            
//            strongSelf->dayCount = minstr([[infos lastObject] valueForKey:@"count_day"]);
//            
//            
//            if ([strongSelf->bonus_switch isEqual:@"1"] && day > 0 ) {
//                [strongSelf firstLog];
//            }
//        }
//
//    } fail:^(NSError * _Nonnull error) {
//        
//    }];
//}
///避免短时间重复请求
-(void)firstLog{
    firstLV = [[Loginbonus alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)AndNSArray:bonus_list AndDay:bonus_day andDayCount:dayCount];
    firstLV.delegate = self;
//    firstLV.layer.cornerRadius = 5;
//    firstLV.layer.masksToBounds = YES;
//    [self.view addSubview:firstLV];
    [[UIApplication sharedApplication].keyWindow addSubview:firstLV];
}

-(void)getBaseInfo:(BOOL)isFirst
{
    if (isRequesting) {
        return;
    }
    isRequesting = YES;
    
    WeakSelf
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getBaseInfo"];
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        isRequesting = NO;
        if(code == 0)
        {
            NSDictionary *infoDic = [info firstObject];
            NSArray *notices = [infoDic valueForKey:@"notices"];
            
            strongSelf.socketUrl = infoDic[@"lobbyServer"];
            [strongSelf createSocket];

            if([notices isKindOfClass:[NSArray class]] && notices.count > 0 && isFirst)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!isShowNotifi) {
                        
                        NSMutableArray *arrayNotice1 = [NSMutableArray array];
                        strongSelf.arrayNotice2 = [NSMutableArray array];
                        
                        for (NSDictionary *subDic in notices) {
                            
                            NSInteger typeNotice = [[subDic objectForKey:@"type"] integerValue];
                            if (typeNotice == 0) {
                                [arrayNotice1 addObject:subDic];
                            }else{
                                [strongSelf.arrayNotice2 addObject:subDic];
                            }
                            
                        }
                        
                        if (arrayNotice1.count>0) {
                            LiveNotificationAlert *alert = [LiveNotificationAlert instanceNotificationAlertWithMessages:arrayNotice1];
                            [alert alertShowAnimationWithfishi:strongSelf block:^{
                                if (strongSelf != nil) {
                                    [strongSelf showNote2View];
                                }
                            }];
                        }else{
                            [strongSelf showNote2View];
                        }
                    }
                    isShowNotifi = true;
                });
            }
           
            //            self.infoArray = infoDic;
            LiveUser *user = [Config myProfile];
            user.user_nicename = minstr([infoDic valueForKey:@"user_nicename"]);
            user.contact_info = minstr([infoDic valueForKey:@"contact_info"]);
            NSArray *app_list = [infoDic valueForKey:@"app_list"];
            NSMutableArray *apps = [NSMutableArray array];
            for (NSDictionary *item in app_list) {
                LiveAppItem *app = [[LiveAppItem alloc] init];
                app.info = minstr(item[@"info"]);
                app.id = minstr(item[@"id"]);
                app.app_name = item[@"app_name"];
                app.app_logo = item[@"app_logo"];
                [apps addObject:app];
            }
            user.coin = minstr(infoDic[@"coin"]);
            user.app_list = apps.copy;
            user.sex = minstr([infoDic valueForKey:@"sex"]);
            user.level =minstr([infoDic valueForKey:@"level"]);
            user.king_level =minstr([infoDic valueForKey:@"king_level"]);
            user.avatar = minstr([infoDic valueForKey:@"avatar"]);
            user.city = minstr([infoDic valueForKey:@"city"]);
            user.level_anchor = minstr([infoDic valueForKey:@"level_anchor"]);
            user.change_name_cost = minstr([infoDic valueForKey:@"change_name_cost"]);
            user.chat_level = minstr([infoDic valueForKey:@"chat_level"]);
            user.show_level = minstr([infoDic valueForKey:@"show_level"]);
            user.chess_url = minstr([infoDic valueForKey:@"chess_url"]);
            user.game_url = minstr([infoDic valueForKey:@"game_url"]);
            user.live_ad_text = minstr([infoDic valueForKey:@"live_ad_text"]);
            user.live_ad_url = minstr([infoDic valueForKey:@"live_ad_url"]);
            user.user_email = minstr([infoDic valueForKey:@"user_email"]);
            user.isBindMobile = [[infoDic valueForKey:@"isBindMobile"] boolValue];
            user.isZeroCharge =[[infoDic valueForKey:@"isZeroCharge"] boolValue];
            user.liveShowChargeTime = [[infoDic valueForKey:@"liveShowChargeTime"] intValue];
            user.signature = minstr([infoDic valueForKey:@"signature"]);
            user.withdrawInfo = infoDic[@"withdrawInfo"];
            [Config updateProfile:user];
            
            [common saveLivePopChargeInfo:[infoDic valueForKey:@"livePopChargeInfo"]];
            
            // TODO 保存系统公告 infoDic[@"system_msg"]
            NSArray *system_msg = [infoDic objectForKey:@"system_msg"];
            [common saveSystemMsg:system_msg];
            
            NSArray *contactPrice = [infoDic objectForKey:@"live_contact_cost"];
            [common saveContactPrice:contactPrice];
            
//            if ([infoDic isKindOfClass:[NSDictionary class]]) {
//                NSString *chat_service_url = [infoDic objectForKey:@"chat_service_url"];
//                [common saveServiceUrl:chat_service_url];
//            }
            NSDictionary *liang = [infoDic valueForKey:@"liang"];
            NSString *liangnum = minstr([liang valueForKey:@"name"]);
            NSDictionary *vip = [infoDic valueForKey:@"vip"];
            NSString *type = minstr([vip valueForKey:@"type"]);
            NSDictionary *subdic = [NSDictionary dictionaryWithObjects:@[type,liangnum] forKeys:@[@"vip_type",@"liang"]];
            [Config saveVipandliang:subdic];
            //            _model = [YBPersonTableViewModel modelWithDic:infoDic];
            NSArray *list = [infoDic valueForKey:@"list"];
            
            [common savepersoncontroller:list];//保存在本地，防止没网的时候不显示
            [[NSNotificationCenter defaultCenter]postNotificationName:KUpdateSkitEntrance object:nil];
        }
        else{
            
        }
        
    } fail:^(NSError * _Nonnull error) {
        isRequesting = NO;
        
        
    }];
}

-(void)showNote2View{
    
    if (self.arrayNotice2!= nil && self.arrayNotice2.count>0) {
        NSDictionary *subDic = self.arrayNotice2[0];
        MoreAlertView *alert = [MoreAlertView instanceNotificationAlertWithMessages:subDic[@"content"] type:minstr(subDic[@"type"]) jumpurl:minstr(subDic[@"jump_url"]) jumptype:minstr(subDic[@"jump_type"])];
        WeakSelf
        [alert alertShowAnimationWithfishi:^{
           STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.arrayNotice2!= nil && strongSelf.arrayNotice2.count>0) {
                [strongSelf.arrayNotice2 removeObjectAtIndex:0];
            }
            [strongSelf showNote2View];
        }];
    }
  
    
}

-(void)onAppWillEnterForeground:(UIApplication*)app {
    //firstLV不存在 (避免一整天不杀进程第二天登录无奖励)
    //这里加uid判断或者把网络请求改为get请求
    NSString *uid = [Config getOwnID];
    if (!firstLV && uid) {
        //[self pullInternet];
    }
}
-(void)removeView:(NSDictionary*)dic{
    [firstLV removeFromSuperview];
    firstLV = nil;
   
}

// 首页 双击首页 回到推荐页面。若当前就在首页，刷新当前页面
- (void)handleTapForHomeView:(HomeContainer *)homeContainer {
    NSUInteger selectedIndex = [self indexForNav:@"nav://homepage"];
    _weakify(self)
    [homeContainer handleRefreshOrBackToRecommend:^(BOOL isNeedAnimation) {
        _strongify(self)
        if (isNeedAnimation) {
            [self refreshRecommendTabAnimation: selectedIndex];
        }
    }];
}


- (void)handleTapForShortVideo:(ShortVideosContainer*)container {
    [container handleRefresh];
    NSUInteger selectedIndex = [self indexForNav:@"nav://shortVideo"];
    [self refreshRecommendTabAnimation: selectedIndex];
}

- (void)refreshRecommendTabAnimation:(NSInteger)index {
    NSMutableArray *arry = [NSMutableArray array];
    for (UIView *btn in self.tabBar.subviews) {
        if ([btn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            btn.backgroundColor = [UIColor clearColor];
            [arry addObject:btn];
        }
    }

    if (arry.count <= index) {
        return;
    }
    UIView *v = arry[index];
    v.hidden = YES;

    UIButton *refreshImgView = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshImgView.frame = v.frame;
    [refreshImgView setImage:[ImageBundle imagewithBundleName:@"tab_refresh"] forState:UIControlStateNormal];
    refreshImgView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    refreshImgView.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    refreshImgView.userInteractionEnabled = NO;
    [v.superview addSubview:refreshImgView];

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1.0;
    animation.repeatCount = MAXFLOAT;
    animation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 ];
    animation.fillMode = kCAFillModeForwards;
    [refreshImgView.layer addAnimation:animation forKey:@"rotationAnimation"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshImgView.layer removeAnimationForKey:@"rotationAnimation"];
        [refreshImgView removeFromSuperview];
        v.hidden = NO;
    });
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *nav = (UINavigationController*)viewController;
    NSInteger selectedIndex = [tabBarController.viewControllers indexOfObject:viewController];
    // 當切換到不同Tab時，更新選中索引，直接返回
    if (selectedIndex != self.lastSelectedIndex) {
        self.lastSelectedIndex = selectedIndex;
        return YES;
    }
    // 當再次點擊當前Tab時執行相關操作
    if ([nav isKindOfClass:[UINavigationController class]]) {
        if (nav.viewControllers.count <= 1) {
            if ([nav.viewControllers.firstObject isKindOfClass:[HomeContainer class]]) {
                HomeContainer *vc = (HomeContainer *)nav.viewControllers.firstObject;
                //[vc showOrHideWobble];
                [self handleTapForHomeView:vc];
            } else if ([nav.viewControllers.firstObject isKindOfClass:[ShortVideosContainer class]]) {
                ShortVideosContainer *vc = (ShortVideosContainer *)nav.viewControllers.firstObject;
                [self handleTapForShortVideo:vc];
            }
        }
    } else {
        //[self startWobble];
    }
    return YES;
}

#pragma mark - Socket
- (void)createSocket {
    [self deleteSocket];
    if (self.socketUrl.length) {
        hotModel * model = [[hotModel alloc] init];
        model.zhuboID = @"0";
        model.stream = @"";
        model.centerUrl = self.socketUrl;
        self.socketDelegate = [[socketMovieplay alloc]init];
        self.socketDelegate.socketDelegate = self;
        [self.socketDelegate addNodeListen:model isFirstConnect:NO serverUrl:self.socketUrl];
    }
}

- (void)deleteSocket {
    if (self.socketDelegate) {
        [self.socketDelegate socketStop];
    }
    self.socketDelegate.socketDelegate = nil;
    self.socketDelegate = nil;
}

#pragma mark - SocketDelegate
- (void)timeDelayUpdate:(long long)timeDelayNum {
    
}

- (void)setSystemNot:(NSDictionary *)msg {
    NSString *text = msg[@"ct"];
    if (text.length>1) {
        [VKAlertView showAlertTitle:YZMsg(@"public_warningAlert") message:text cancelAction:nil confirmAction:YZMsg(@"publictool_sure") cancelBlock:nil confirmBlock:nil];
    }       
}

- (void)giveVideoTicketMessage:(GiveVideoTicket *)msg {
    NSString *text = msg.msg.ct;
    if (text.length) {
        [MBProgressHUD showBottomMessage:text];
    }
    [VideoTicketFloatView refreshFloatData];
}

// 接收 socket 显示本地通知
-(void)giveAppTopNotice:(AppTopNotice *)msg {
    AppTopNotice_Msg *notice = msg.msg;
    if (notice.noticeScheme) {
        // 刷新未读数量
        if ([notice.noticeScheme containsString:@"my-message://"]) {
            // 取消之前的調用，以確保只執行最新的，延遲 0.5 秒後執行最後一次
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshUnreadCount) object:nil];
            [self performSelector:@selector(refreshUnreadCount) withObject:nil afterDelay:0.5];
        }
    }
    /// 通知关闭
    if (!YBToolClass.sharedInstance.noticeSwitch) {
        return;
    }
    if (notice.hasNoticeSubIcon && notice.noticeSubIcon) {
        NSURL *imageURL = [NSURL URLWithString:notice.noticeSubIcon];
        [[SDWebImageManager sharedManager] loadImageWithURL:imageURL
                                                    options:0
                                                   progress:nil
                                                  completed:^(UIImage * _Nullable image,
                                                              NSData * _Nullable data,
                                                              NSError * _Nullable error,
                                                              SDImageCacheType cacheType,
                                                              BOOL finished,
                                                              NSURL * _Nullable imageURL) {
            // 1. 建立通知內容
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = notice.noticeTitle;
            content.body = notice.noticeContent;
            content.userInfo = @{@"scheme": notice.noticeScheme};
            
            // 2. 若圖片下載成功，則添加圖片附件
            if (!error && data) {
                NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"notification_image.jpg"];
                NSURL *tempFileURL = [NSURL fileURLWithPath:tempFilePath];
                [data writeToURL:tempFileURL atomically:YES];
                
                NSError *attachmentError = nil;
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"imageAttachment"
                                                                                                      URL:tempFileURL
                                                                                                  options:nil
                                                                                                    error:&attachmentError];
                if (attachment) {
                    content.attachments = @[attachment];
                } else {
                    NSLog(@"圖片附件添加失敗: %@", attachmentError);
                }
            } else {
                NSLog(@"圖片下載失敗，將顯示無圖片的通知: %@", error);
            }
            
            // 3. 發送通知
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ImmediateNotification"
                                                                                  content:content
                                                                                  trigger:nil];
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center addNotificationRequest:request withCompletionHandler:nil];
        }];
    } else {
        // 1. 設置通知內容
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = notice.noticeTitle;
        content.body = notice.noticeContent;
        content.userInfo = @{@"scheme": notice.noticeScheme};
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ImmediateNotification"
                                                                              content:content
                                                                              trigger:nil];
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:nil];
    }
}

- (void)refreshUnreadCount {
    [MessageListNetworkUtil getMessageHome:^(NetworkData *networkData) {
        NSInteger unreadCount = [[networkData.info valueForKeyPath:@"@sum.unread_count"] intValue];
        [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeMessageKey" object:@(unreadCount)];
    }];
}

// 設置 Lottie 動畫
- (LOTAnimationView *)setupLottieAnimationWithURL:(NSString *)urlString forState:(BOOL)isSelected {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    if (jsonData != nil) {
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

        if (!error) {
            LOTAnimationView *animationView = [LOTAnimationView animationFromJSON:jsonDict];
            return animationView;
        } else {
            return nil;
        }
    }
    return nil;
}

- (NSInteger)indexForNav:(NSString *)targetNav {
    NSArray *tabbarButtons = [self getAppConfig][@"MainPage"][@"tabbar"][@"tabbar_buttons"];
    for (NSInteger i = 0; i < tabbarButtons.count; i++) {
        NSDictionary *button = tabbarButtons[i];
        if ([button[@"nav"] isEqualToString:targetNav]) {
            return i; // 找到目標 nav 的索引
        }
    }
    return 0; // 未找到返回 0
}

#pragma mark - Tab Animation
- (void)showTabBarAnimation {
    NSUInteger selectedIndex = self.selectedIndex ?: 0;
    if (selectedIndex == self.lastAnimationIndex) {
        return;
    }
    self.lastAnimationIndex = selectedIndex;
    NSArray *normalTabbarArray = [self getAppConfig][@"MainPage"][@"tabbar"][@"tabbar_buttons"];
    NSArray<UIView *> *views = self.tabBar.subviews;
    if (normalTabbarArray.count == views.count) {
        for (int i = 0; i < normalTabbarArray.count; i++) {
            UIView *view = views[i];
            if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                NSArray<UIView *> *subViews = view.subviews;
                
                BOOL isSelected = NO;
                UIView *animationView;
                for (UIView *subView in subViews) {
                    if ([subView isKindOfClass:NSClassFromString(@"UITabBarButtonLabel")]) {
                        NSString *title = [subView valueForKey:@"text"];
                        isSelected = [normalTabbarArray[i][@"title"] isEqualToString:title];
                    } else if ([subView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                        animationView = subView;
                    }
                }
                if (isSelected) {
                    //addAnimation
                    LOTAnimationView *animation = [self setupLottieAnimationWithURL: normalTabbarArray[self.selectedIndex][@"icon_selected"] forState:YES];
                    if (animation == nil) { return;}
                    animationView.hidden = YES;
                    animation.frame = animationView.frame;
                    [view addSubview:animation];
                    [animation playWithCompletion:^(BOOL animationFinished) {
                        animationView.hidden = NO;
                        [animation stop];
                        [animation removeFromSuperview];
                    }];
                } else {
                    //remove animation
                    for (UIView *sub in view.subviews) {
                        if ([sub isKindOfClass:[LOTAnimationView class]]) {
                            [(LOTAnimationView *)sub stop];
                            [sub removeFromSuperview];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark  UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

// 点击通知跳转到指定页面
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [[YBUserInfoManager sharedManager] pushVC: userInfo viewController: self];
    completionHandler();
}

@end
