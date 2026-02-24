//
//  HomeContainer.m
//  c700LIVE
//
//  Created by user on 2024/6/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeContainer.h"
#import "RecommendContainer.h"
#import "ShortVideosContainer.h"
#import "SkitHomeMainVC.h"
#import "LongVideoMainVC.h"
#import "PZXFreeMoveButton.h"
#import "HomeSearchVC.h"
#import "HomeWebViewController.h"
#import "ZYTabBarController.h"
#import "VideoTicketFloatView.h"
#import "MessageListViewController.h"
#import "MessageListNetworkUtil.h"
#import "MsgSysVC.h"
#import "h5game.h"
#import "GameContainer.h"
#import "RecommendMainVC.h"
#import "LobbyLotteryVC_New.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "LotteryBetHallVC.h"
#import <UMCommon/UMCommon.h>

@interface HomeContainer () <JXCategoryViewDelegate, lotteryBetViewDelegate> {
    RecommendContainer *_recommendVC;
    ShortVideosContainer *_shortVideosVC;
    SkitHomeMainVC *_playletVC;
    LongVideoMainVC *_longVideosVC;
    GameContainer *_gameVC;
    NSInteger currentIndex;
    UIView *meunContainerView;
    UIButton *menuButton;
    UIButton *searchButton;
    UIStackView *menuStackView;
    UIButton *messageBell;
    UILabel *messageCountLabel;
    NSInteger systemUnreadCount; // 系统消息 未读数量
    NSInteger interactiveUnreadCount; // 互动消息 未读数量
}
//@property(nonatomic,strong)NSArray *anotheWebControllersInfo;

@end

@implementation HomeContainer

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidenWobble:) name:@"KNoticeHidenWobble" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationClickItemAtIndex:) name:@"KHomeContainerClickItemAtIndex" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WeakSelf
//    [self needShowTicket: currentIndex];
    searchButton.hidden = NO;
    meunContainerView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (!strongSelf) return;
        strongSelf->menuButton.alpha = 1.0;
        strongSelf->searchButton.alpha = 1.0;
    }];
    
    [MessageListNetworkUtil getMessageHome:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        NSNumber *messageCount = [networkData.info valueForKeyPath:@"@sum.unread_count"];
        NSInteger unreadCount =  [messageCount intValue];
        [strongSelf->messageCountLabel setHidden: (unreadCount == 0)];
        strongSelf->messageCountLabel.text = [NSString stringWithFormat:@"%ld", unreadCount];
        [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeMessageKey" object:@(unreadCount)];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    _weakify(self)
    //    [UIView animateWithDuration:0.3 animations:^{
    //        _strongify(self)
    //        self->menuButton.alpha = 0.0;
    //        self->searchButton.alpha = 0.0;
    //    } completion:^(BOOL finished) {
    //        self->searchButton.hidden = YES;
    //        self->meunContainerView.hidden = YES;
    //    }];
    
    [VideoTicketFloatView hideTicketButton];
    [VideoTicketFloatView hidePostVideoButton];
    
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController stopAndHidenWobble];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self needShowTicket: currentIndex];
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController startWobble];
}

- (void)showOrHideWobble {
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    if ([self.currentVC isMemberOfClass:[RecommendContainer class]] ||
        [self.currentVC isKindOfClass:[LongVideoMainVC class]] ||
        [self.currentVC isKindOfClass:[SkitHomeMainVC class]]) {
        [tabbarController startWobble];
    }  else {
        [tabbarController stopAndHidenWobble];
    }
}

- (void)handleRefreshOrBackToRecommend:(void (^)(BOOL isNeedAnimation))completionBlock {
    BOOL isAnimation = NO;
    if (self.categoryView.selectedIndex == 0) {
        isAnimation = YES;
        [_recommendVC handleRecommendRefresh];
    } else {
        [self.categoryView selectItemAtIndex:0];
        [_recommendVC handleRedirectToRecommend];
    }
    
    if (completionBlock) {
        completionBlock(isAnimation);
    }
}

- (void)changeCategory:(HomeContainerType)type {
    NSString *selectNavString = @"";
    
    switch (type) {
        case HomeContainerTypeRecommend:
            selectNavString = @"nav://recommend";
            break;
        case HomeContainerTypeShortVideo:
            selectNavString = @"nav://shortVideo";
            break;
        case HomeContainerTypeLongVideo:
            selectNavString = @"nav://longvideo";
            break;
        case HomeContainerTypeShortSkit:
            selectNavString = @"nav://skit";
            break;
        case HomeContainerTypeGame:
            selectNavString = @"nav://web";
            break;
        default:
            break;
    }
    
    NSArray *navItems = [self getTopNavConfig];
    for (int i = 0; i<navItems.count; i++) {
        NSString *navString = navItems[i][@"nav"];
        if ([navString isEqualToString:selectNavString]) {
            [self.categoryView selectItemAtIndex:i];
            break;
        }
    }
}

- (void)openShortVideo:(ShortVideoModel*)model {
    [self changeCategory:HomeContainerTypeShortVideo];
    [_shortVideosVC insertModelToHotShortVideo:model];
}

- (void)hideTopBarItems:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = [notification object];
        BOOL hidden = [[dic valueForKey:@"isHidden"] boolValue];
        searchButton.hidden = hidden;
        meunContainerView.hidden = hidden;
        _shortVideosVC.categoryView.hidden = hidden;
        [self.categoryView.listContainer.contentScrollView setScrollEnabled:!hidden];
        [_shortVideosVC.categoryView.listContainer.contentScrollView setScrollEnabled:!hidden];
    }
}

- (void)setupView {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTopBarItems:) name:@"hideTopBarItems" object:nil];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame: self.view.frame];
    backgroundImage.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    [self.view addSubview:backgroundImage];
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(backgroundImage.mas_width).multipliedBy(360/1125.0);
    }];
    
    //self.anotheWebControllersInfo = [common getExtensionPage];
    
    //    if (self.anotheWebControllersInfo.count>0) {
    ////        for (int i = 0; i<self.anotheWebControllersInfo.count; i++) {
    ////            NSDictionary *subDic = self.anotheWebControllersInfo[i];
    ////            NSString *urlStr = [subDic objectForKey:@"url"];
    ////            WebViewController *VC = [[WebViewController alloc]init];
    ////            VC.urls = urlStr;
    ////            [self.pagesViewC addObject:VC];
    ////        }
    //    }
    
    //    self.anotheWebControllersInfo = @[@{@"title":@"网页",@"url":@"http://www.google.com"}];
    NSArray *navItems = [self getTopNavConfig];
    NSMutableArray *arrayTitles = [NSMutableArray array];
    for (int i = 0; i< navItems.count; i++) {
        [arrayTitles addObject:navItems[i][@"title"]];
    }
    
    self.categoryView.titles = arrayTitles;
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleFont = vkFont(16);
    self.categoryView.titleColor = vkColorHexA(0x000000, 0.5);
    self.categoryView.titleLabelZoomEnabled = YES;
    self.categoryView.segmentStyle = SegmentStyleLine;
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.cellSpacing = 18;
    
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view).multipliedBy(0.76);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(44);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.categoryView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    
    //    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    UIImage *search_image = [ImageBundle imagewithBundleName:@"home_search_button"];
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    [searchButton setImage:search_image forState:UIControlStateNormal];
    searchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchButton];
    
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.size.mas_equalTo(40);
        make.top.mas_equalTo(VK_STATUS_H);
    }];
    
    messageBell = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBell setImage:[ImageBundle imagewithBundleName:@"messageListView_bell"] forState:UIControlStateNormal];
    [messageBell addTarget:self action:@selector(doMessageList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageBell];
    messageBell.hidden = YES;
    [messageBell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(28);
        make.centerX.mas_equalTo(self.view).multipliedBy(1.61);
        make.centerY.mas_equalTo(self.categoryView);
    }];
    
    messageCountLabel = [[UILabel alloc] init];
    [messageCountLabel setHidden:YES];
    messageCountLabel.textAlignment = NSTextAlignmentCenter;
    messageCountLabel.backgroundColor = vkColorRGB(242, 81, 187);
    messageCountLabel.textColor = [UIColor whiteColor];
    messageCountLabel.layer.cornerRadius = 6;
    messageCountLabel.layer.masksToBounds = YES;
    messageCountLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightRegular];
    [messageBell addSubview:messageCountLabel];
    [messageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.width.mas_greaterThanOrEqualTo(12);
        make.centerX.mas_equalTo(messageBell).offset(8);
        make.centerY.mas_equalTo(messageBell.mas_top).offset(9);
    }];
    
}
- (void)doMessageList:(UIButton *)sender {
    MessageListViewController *vc = [[MessageListViewController alloc] initWithMessageList:YES];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)searchAction:(id)sender {
    HomeSearchVC *searchVC = [HomeSearchVC new];
    if ([self.currentVC isKindOfClass:[SkitHomeMainVC class]]) {
        searchVC.type = 1;
    } else if ([self.currentVC isKindOfClass:[LongVideoMainVC class]]) {
        searchVC.type = 3;
    } else if (self.tabBarController.selectedIndex == 1) {
        searchVC.type = 2;
    } else {
        searchVC.type = 0;
    }
    
    [[MXBADelegate sharedAppDelegate] pushViewController:searchVC animated:YES];
    searchButton.hidden = YES;
    
    NSArray *navItems = [self getTopNavConfig];
    NSString *tab_name = [NSString stringWithFormat:@"%@%@", navItems[self.currentVC.pageIndex][@"title"], @"tab"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"page_current": tab_name};
    [MobClick event:@"home_search_click" attributes:dict];

}

- (void)setMenuButtonSelectedImage:(NSInteger)index {
    if (index>3) {
        return;
    }
    if (index == 0) {
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_menu_button_selected"] forState:UIControlStateNormal];
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_menu_button_selected"] forState:UIControlStateSelected];
    } else if (index == 1) {
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_shortVideo_button_selected"] forState:UIControlStateNormal];
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_shortVideo_button_selected"] forState:UIControlStateSelected];
    } else if (index == 2) {
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_playlet_button_selected"] forState:UIControlStateNormal];
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_playlet_button_selected"] forState:UIControlStateSelected];
    } else if (index == 3) {
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_longVideo_button_selected"] forState:UIControlStateNormal];
        [menuButton setImage:[ImageBundle imagewithBundleName:@"home_longVideo_button_selected"] forState:UIControlStateSelected];
    }
    [menuStackView.arrangedSubviews enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        [button setHidden: (idx == index)];
    }];
    [menuButton setSelected:NO];
}

- (void)setHiddenMenuAndSearchButton:(NSInteger)index {
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [meunContainerView setHidden:index != 0];
    searchButton.hidden = index != 0 && index != 1;
    if (index == 0 && ([self.currentVC isKindOfClass:[RecommendContainer class]] || [self.currentVC isKindOfClass:[GameContainer class]])) {
        if ([_recommendVC.currentVC isKindOfClass:[h5game class]]) {
            [_recommendVC resetOperate]; // 重置最后一次记录到的 转入转出状态
            [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeConvertCoinOut" object:@{@"operate": @"in"}];
        } else if ([_gameVC.currentVC isKindOfClass:[h5game class]]) {
            [_gameVC resetOperate]; // 重置最后一次记录到的 转入转出状态
            [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeConvertCoinOut" object:@{@"operate": @"in"}];
        }
        if ([_recommendVC.currentVC isKindOfClass:[RecommendMainVC class]]) {
            [tabbarController startWobble];
        }
    } else if ([self getTabbarButtonsConfig].count > 0 && ([[self getTabbarButtonsConfig][index][@"nav"] isEqualToString:@"nav://personalPage"] ||
               [[self getTabbarButtonsConfig][index][@"nav"] isEqualToString:@"nav://liveshow"])) {
        [tabbarController startWobble];
    } else {
        [tabbarController stopAndHidenWobble];
    }
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    NSArray *navItems = [self getTopNavConfig];
    NSString *navString = navItems[index][@"nav"];
    if ([navString isEqualToString:@"nav://recommend"]) {
        // 推荐
        if (_recommendVC == nil) {
            _recommendVC = [RecommendContainer new];
            _recommendVC.tags = navItems[index][@"tags"];
        }
        return (id)_recommendVC;
    } else if ([navString isEqualToString:@"nav://shortVideo"]) { // 以防需求突然要加回来，先挖洞
        // 短视频
        if (_shortVideosVC == nil) {
            _shortVideosVC = [ShortVideosContainer new];
        }
        return (id)_shortVideosVC;
    } else if ([navString isEqualToString:@"nav://skit"]) {
        // 短剧
        if (_playletVC == nil) {
            _playletVC = [SkitHomeMainVC new];
        }
        return (id)_playletVC;
    } else if ([navString isEqualToString:@"nav://longvideo"]) {
        // 长视频
        if (_longVideosVC == nil) {
            _longVideosVC = [LongVideoMainVC new];
        }
        return (id)_longVideosVC;
    } else if ([navString isEqualToString:@"nav://web"]) {
        // 游戏
        if (_gameVC == nil) {
            _gameVC = [GameContainer new];
            _gameVC.tags = navItems[index][@"tags"];
        }
        return (id)_gameVC;
    } else {
        return [VKPagerChildVC new];
    }
}

- (void)categoryView:(JXCategoryBaseView *)categoryView scrollingFromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex ratio:(CGFloat)ratio {
    
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    self.listContainerView.scrollView.scrollEnabled = YES;
    currentIndex = index;
    [self showOrHideWobble];
    if (![self.currentVC isKindOfClass:[RecommendContainer class]] || ![self.currentVC isKindOfClass:[GameContainer class]]) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeConvertCoinOut" object:@{@"operate": @"out"}];
    } else {
        if ([_recommendVC.currentVC isKindOfClass:[h5game class]] || [_gameVC.currentVC isKindOfClass:[h5game class]]) {
            self.listContainerView.scrollView.scrollEnabled = NO;
        }
    }
    [self needShowTicket: index];
}
-(void)pageViewDidClickItemAtIndex:(NSInteger)index
{
    NSArray *navItems = [self getTopNavConfig];
    NSString *navString = navItems[index][@"nav"];
    if ([navString isEqualToString:@"nav://recommend"]) {
        [_playletVC.categoryView selectItemAtIndex:0];
        [_longVideosVC.categoryView selectItemAtIndex:0];
    } else if ([navString isEqualToString:@"nav://shortVideo"]) { // 以防需求突然要加回来，先挖洞
        //[_shortVideosVC.categoryView selectItemAtIndex:1];
        [_playletVC.categoryView selectItemAtIndex:0];
        [_longVideosVC.categoryView selectItemAtIndex:0];
    } else if ([navString isEqualToString:@"nav://skit"]) {
        [_playletVC.categoryView selectItemAtIndex:0];
        [_longVideosVC.categoryView selectItemAtIndex:0];
    } else if ([navString isEqualToString:@"nav://longvideo"]) {
        [_playletVC.categoryView selectItemAtIndex:_playletVC.categoryView.dataSource.count-1];
        [_longVideosVC.categoryView selectItemAtIndex:0];
    } else {
        
    }
    [self needShowTicket: index];
    NSString *tab_name = [NSString stringWithFormat:@"%@%@", navItems[index][@"title"], @"tab"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"top_nav": tab_name};
    [MobClick event:@"home_topnav" attributes:dict];
}

// 来自 NSNotification 通知的 click
- (void)notificationClickItemAtIndex:(NSNotification *)notification {
    NSNumber *indexNumber = notification.userInfo[@"index"];
    NSInteger index = [indexNumber integerValue];
    [self.categoryView selectItemAtIndex:index];
}

- (void)needShowTicket:(NSInteger)index {
    NSArray *navItems = [self getTopNavConfig];
    if (navItems.count == 0 || index < 0 || index >= navItems.count) {
        [VideoTicketFloatView hideTicketButton];
        return;
    }
    NSString *navString = navItems[index][@"nav"];
    if ([navString isEqualToString:@"nav://recommend"]) {
        [VideoTicketFloatView showTicketButton];
    } else if ([navString isEqualToString:@"nav://shortVideo"]) { // 以防需求突然要加回来，先挖洞
        [VideoTicketFloatView showTicketButton];
    } else if ([navString isEqualToString:@"nav://skit"]) {
        [VideoTicketFloatView showTicketButton];
    } else if ([navString isEqualToString:@"nav://longvideo"]) {
        [VideoTicketFloatView showTicketButton];
    } else {
        [VideoTicketFloatView hideTicketButton];
    }
}

- (void)hidenWobble:(NSNotification *)notice {
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    if (notice.object[@"hidenWobble"] && [notice.object[@"hidenWobble"] isEqual: @1]) {
        [tabbarController stopAndHidenWobble];
    }else{
        [tabbarController startWobble];
    }
}
- (NSArray *)getTopNavConfig {
    NSDictionary *cachedConfig = [[MXBADelegate sharedAppDelegate] getAppConfig:nil];
    if (cachedConfig) {
        return cachedConfig[@"MainPage"][@"TopNavs"];
    } else {
        return @[];
    }
}

- (NSArray *)getTabbarButtonsConfig {
    NSDictionary *cachedConfig = [[MXBADelegate sharedAppDelegate] getAppConfig:nil];
    if (cachedConfig) {
        return cachedConfig[@"MainPage"][@"tabbar"][@"tabbar_buttons"];
    } else {
        return @[];
    }
}

-(void)exchangeVersionToNew:(NSInteger)curLotteryType {
    if (curLotteryType == 6 || curLotteryType == 11) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSSC_view"];
        [YBToolClass sharedInstance].default_oldSSC_view = false;
    } else if (curLotteryType == 10) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldNN_view"];
        [YBToolClass sharedInstance].default_oldNN_view = false;
    } else if (curLotteryType == 14) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSC_view"];
        [YBToolClass sharedInstance].default_oldSC_view = false;
    } else if (curLotteryType == 26  || curLotteryType == 27 ) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_old_view"];
        [YBToolClass sharedInstance].default_old_view = false;
    } else if (curLotteryType == 28) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = false;
    } else if(curLotteryType == 29) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = false;
    } else if (curLotteryType == 30) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = false;
    } else if (curLotteryType == 31) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLH_view"];
        [YBToolClass sharedInstance].default_oldLH_view = false;
    } else if ( curLotteryType == 8) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLHC_view"];
        [YBToolClass sharedInstance].default_oldLHC_view = false;
    }
    LotteryBetHallVC *VC = [LotteryBetHallVC new];
    VC.lotteryDelegate = self;
    VC.lotteryType = curLotteryType;
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    NSArray* vcArr = [[[MXBADelegate sharedAppDelegate] navigationViewController] viewControllers];
    for (UIViewController *vc in vcArr) {
        if([vc isKindOfClass:[LotteryBetViewController_Fullscreen class]] || [vc isKindOfClass:[LobbyLotteryVC_New class]]) {
            [vc removeFromParentViewController];
        }
    }
}

- (void)exchangeVersionToOld:(NSInteger)curLotteryType {
    NSArray* vcArr = [[[MXBADelegate sharedAppDelegate] navigationViewController] viewControllers];
    if (curLotteryType == 6 || curLotteryType == 8 || curLotteryType == 11) {
        LobbyLotteryVC_New *VC = [[LobbyLotteryVC_New alloc]initWithNibName:@"LobbyLotteryVC_New" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        VC.lotteryDelegate = self;
        [VC setLotteryType:curLotteryType];
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    } else {
        LotteryBetViewController_Fullscreen *VC = [[LotteryBetViewController_Fullscreen alloc]initWithNibName:@"LotteryBetViewController_Fullscreen" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        VC.lotteryDelegate = self;
        [VC setLotteryType:curLotteryType];
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    }
    if (curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27) {
        [YBToolClass sharedInstance].default_old_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_old_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if (curLotteryType == 28) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = true;
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 30) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = true;
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 29) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = true;
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 31) {
        [YBToolClass sharedInstance].default_oldLH_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldLH_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 14) {
        [YBToolClass sharedInstance].default_oldSC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldSC_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 8) {
        [YBToolClass sharedInstance].default_oldLHC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldLHC_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 6 || curLotteryType == 11) {
        [YBToolClass sharedInstance].default_oldSSC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldSSC_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 10) {
        [YBToolClass sharedInstance].default_oldNN_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldNN_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    }
}

//关闭
-(void)lotteryCancless {
    
}
//礼物
-(void)doLiwu {
    
}
-(BOOL)cancelLuwu {
    return NO;
}
//游戏
-(void)doGame {
    
}
//红包
-(void)showRedView {
    
}
//聊天输入框
-(void)showkeyboard:(UIButton *)sender {
    
}

//设置当前彩种选择
- (void)setCurlotteryVC:(LotteryBetViewController *)vc {
    
}
//刷新直播聊天列表的高度
-(void)refreshTableHeight:(BOOL)isShowTopView {
    
}

@end
