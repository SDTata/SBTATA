#import "homepageController.h"
#import "Hotpage.h"
#import "Hotpage.h"
#import "AttentionController.h"
#import "GamesController.h"
#import "searchVC.h"

#import "ZYTabBar.h"
#import "WebViewController.h"
#import "MNFloatBtn.h"
#import "RankVC.h"
#import "EnterLivePlay.h"

#import "FirstInvestAlert.h"
#import "RichVC.h"
#import "LiveEncodeCommon.h"

#import "FilterCountryVC.h"
#import <UMCommon/UMCommon.h>

@interface homepageController ()

@property(nonatomic, strong) UIButton *moreBtn;
@property (nonatomic,strong) UIStackView *itemStackView;
@property (nonatomic,strong) UIImageView *arrowimgV;

@end

@implementation homepageController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController stopAndHidenWobble];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController startWobble];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self refreshMenuData];
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame: self.view.frame];
    backgroundImage.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(backgroundImage.mas_width).multipliedBy(360/1125.0);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 0;
    [self.view addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(44);
    }];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreBtn.tag = 10000;
    [self.moreBtn setTitleColor:RGB(153, 153, 153) forState:0];
    self.moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.moreBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.moreBtn addTarget:self action:@selector(filterVC) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
    }];

    UIImageView *arrowimgV = [UIImageView new];
    arrowimgV.contentMode = UIViewContentModeScaleAspectFit;
    arrowimgV.backgroundColor=[UIColor clearColor];
    [arrowimgV setImage:[ImageBundle imagewithBundleName:@"zjm_jt2"]];
    [stackView addArrangedSubview:arrowimgV];
    [arrowimgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@8);
        make.height.equalTo(@6);
    }];
    self.arrowimgV = arrowimgV;

    UIButton *searchBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBTN setImage:[ImageBundle imagewithBundleName:@"icon_sousuo"] forState:UIControlStateNormal];
    searchBTN.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [searchBTN addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    searchBTN.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [stackView addArrangedSubview:searchBTN];
    [searchBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
    }];

    UIButton *rankBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [rankBTN setImage:[ImageBundle imagewithBundleName:@"icon_phb"] forState:UIControlStateNormal];
    rankBTN.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [rankBTN addTarget:self action:@selector(rankBtnClick) forControlEvents:UIControlEventTouchUpInside];
    rankBTN.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [stackView addArrangedSubview:rankBTN];
    [rankBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
    }];

    UIButton *livechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    livechatBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [livechatBtn setImage:[ImageBundle imagewithBundleName:@"zjm_rg"] forState:UIControlStateNormal];
    [livechatBtn addTarget:self action:@selector(livechatBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    livechatBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [stackView addArrangedSubview:livechatBtn];
    [livechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
    }];

    self.itemStackView = stackView;

    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleFont = vkFont(16);
    self.categoryView.titleColor = vkColorHexA(0x000000, 0.5);
    self.categoryView.titleLabelZoomEnabled = YES;
    self.categoryView.segmentStyle = SegmentStyleLine;
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.cellSpacing = 18;
    self.categoryView.defaultSelectedIndex = 1;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(stackView.mas_left);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(44);
    }];

    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.categoryView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshMenuData {
    NSMutableArray *results = [NSMutableArray array];
    
    /// 关注
    [results addObject:({
        VKActionModel *model = [VKActionModel new];
        model.title = YZMsg(@"homepageController_attention");
        model.value = @"1";
        model;
    })];
    
    /// 推荐
    [results addObject:({
        VKActionModel *model = [VKActionModel new];
        model.title = YZMsg(@"homepageController_live");
        model.value = @"2";
        model;
    })];
    
    /// 游戏
    [results addObject:({
        VKActionModel *model = [VKActionModel new];
        model.title = YZMsg(@"homepageController_game");
        model.value = @"3";
        model;
    })];
    
    /// 排行榜
    if ([LiveEncodeCommon sharedInstance].show_lottery_profit_rank) {
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"homepageController_Rich_list");
            model.value = @"4";
            model;
        })];
    }
    
    /// 其他
    NSArray *array = [common getExtensionPage];
    for (int i = 0; i<array.count; i++) {
        NSDictionary *subDic = array[i];
        NSString *titleBStr = [subDic objectForKey:@"title"];
        if (titleBStr && titleBStr.length>0) {
            [results addObject:({
                VKActionModel *model = [VKActionModel new];
                model.title = titleBStr;
                model.value = @"5";
                model.extra = subDic;
                model;
            })];
        }
    }
    
    self.categoryView.titles = [results valueForKeyPath:@"title"];
    self.categoryView.values = results;
    [self.categoryView reloadData];
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    if ( self.categoryView.values.count>index) {
        VKActionModel *model = self.categoryView.values[index];
        NSInteger type = model.value.integerValue;

        switch (type) {
            case 1:
            {
                AttentionController *vc = [[AttentionController alloc] init];
                vc.pageView = self.itemStackView;
                return vc;
            }
            case 2:
            {
                Hotpage *vc = [[Hotpage alloc] init];
                vc.pageView = self.itemStackView;
                return vc;
            }
            case 3:
            {
                GamesController *vc = [[GamesController alloc] init];
                vc.pageView = self.itemStackView;
                return vc;
            }
            case 4:
            {
                RichVC *vc = [[RichVC alloc] init];
                return vc;
            }
            default:
            {
                NSDictionary *subDic = model.extra;
                NSString *urlStr = [subDic objectForKey:@"url"];
                WebViewController *vc = [[WebViewController alloc] init];
                vc.urls = urlStr;
                return vc;
            }
        }
    }else{
        return nil;
    }
    
}

-(void)filterVC{
    UIViewController *subVC = self.currentVC;
    if ([subVC isKindOfClass:[Hotpage class]]) {
        [(Hotpage*)subVC filterVC];
    } else {
        return;
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"切换国家"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                  name:UIApplicationWillEnterForegroundNotification
                object:nil];
}

-(void)rankBtnClick{
//    if(isOpenFiter){
//        self.tabBarController.selectedIndex = 4;
//    }else{
//        self.tabBarController.selectedIndex = 2;
//    }
    RankVC *rVC = [[RankVC alloc]init];
    [[MXBADelegate sharedAppDelegate]pushViewController:rVC animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"排行榜"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}

-(void)livechatBtnClick{
//    LiveChat.licenseId = livechatKey;
//    LiveChat.name = [Config getOwnID];
//    if (!LiveChat.isChatPresented) {
//        [LiveChat presentChatWithAnimated:YES completion:nil];
//    }else{
//        [LiveChat dismissChatWithAnimated:YES completion:^(BOOL finished) {
//
//        }];
//    }
    [YBToolClass showService];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"客服"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}

-(void)search{
    searchVC *search = [[searchVC alloc]init];
//    UINavigationController *naviSearch = [[UINavigationController alloc]initWithRootViewController:search];
//    [self presentViewController:naviSearch animated:YES completion:nil];
    [[MXBADelegate sharedAppDelegate]pushViewController:search animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"搜索昵称或ID"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    VKActionModel *model = self.categoryView.values[index];
    NSInteger type = model.value.integerValue;

    self.moreBtn.alpha = type == 2 ? 1 : 0;
    self.arrowimgV.alpha = self.moreBtn.alpha;
    
    NSString *title = ((VKActionModel *)self.categoryView.values[index]).title;
    NSString *tab_name = [NSString stringWithFormat:@"%@%@", title, @"页"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": tab_name};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}

@end
