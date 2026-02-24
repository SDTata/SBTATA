//
//  GameListViewController.m
//
//

#import "GameListViewController.h"
#import "MultilevelMenu.h"
#import "h5game.h"
#import "SDCycleScrollView.h"

#import "webH5.h"
#import "NavWeb.h"
#import "UINavModalWebView.h"
#import "OneBuyGirlViewController.h"
#import "myWithdrawVC2.h"
#import "MBProgressHUD+MJ.h"
#import "exchangeVC.h"
#import "PayViewController.h"
#import "GameMoreListVC.h"

#import "UUMarqueeView.h"
#import "LobbyLotteryVC.h"
#import "LobbyLotteryVC_New.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "LotteryBetHallVC.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface GameListViewController ()<SDCycleScrollViewDelegate, lotteryBetViewDelegate,UUMarqueeViewDelegate, MultilevelMenuDeleaget, UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *lis;
//    UILabel *labelTitle;
    
    CGFloat oldOffset;
    NSInteger page;
    NSString *classID;
    NSString *mCurrentUrl;
    UIView *collectionHeaderView;
    YBNoWordView *noNetwork;
    UILabel *titleLabel;
    SDCycleScrollView *bannerScrollView;
    NSArray           *adBannerInfoArr;
    UIButton *inviteImageBtn;
    
    UIView *assistive_view;
    UIButton *assistive_touchButton;
    UIButton *popularize_touchButton;
    UILabel * nameLab;
    UILabel * coinLab;
    UIView *bg;
    
    // 跑马灯
    UUMarqueeView *_horizontalMarquee;
    NSMutableArray <NSString *> *_marqueeDatas;
    
    //
    NSInteger marqueeIndex;
    BOOL isWobble;
    //    BOOL appearReq;
    //    NSInteger refrshPage;
    BOOL loadingData;
    BOOL isFirstLoadingData;
    UIButton *refreshBtn;
    NSDictionary *_gameReportDic;

    NSString *iconUrlName;
    NSInteger firstSectionHeaderY;
}

@property (strong, nonatomic) GameListTableView * tableView;
@property (nonatomic, strong) MultilevelMenu * multilevelMenu;
@end

@implementation GameListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (self.isPushV) {
        
    }
    self.navigationController.toolbarHidden = YES;
//    if (labelTitle.hidden) {
//        labelTitle.hidden = NO;
//    }
    [self downData];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isPushV) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.multilevelMenu.allData.count) {
        [self getInfo];
    }
//    if (labelTitle.hidden) {
//        labelTitle.hidden = NO;
//    }
    if (self.isPushV) {
        self.navigationController.navigationBarHidden = YES;
    }
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    if (!labelTitle.hidden) {
//        labelTitle.hidden = YES;
//    }
    if (self.isPushV) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)getInfo{
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getPlats&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];//User.getPlats
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        NSLog(@"xxxxxxxxx%@",info);
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            //            // test code start
            //            NSString *dataStr = @"[{\"meunName\":\"为您推荐\",\"sub\":[{\"meunName\":\"浏览历史\",\"sub\":[{\"meunName\":\"德州扑克\",\"urlName\":\"http://qd.zhixiaoren8.com/logo_circle/620.png\",\"kindID\":\"620\",\"plat\":\"ky\"},{\"meunName\":\"德州扑克\",\"urlName\":\"http://qd.zhixiaoren8.com/logo_circle/620.png\",\"kindID\":\"620\",\"plat\":\"ky\"}]}]},{\"meunName\":\"开元棋牌\",\"sub\":[{\"meunName\":\"浏览历史\",\"sub\":[{\"meunName\":\"二八杠\",\"urlName\":\"http://qd.zhixiaoren8.com/logo_circle/720.png\",\"kindID\":\"720\",\"plat\":\"ky\"},{\"meunName\":\"二八杠\",\"urlName\":\"http://qd.zhixiaoren8.com/logo_circle/720.png\",\"kindID\":\"720\",\"plat\":\"ky\"}]}]}]";
            //            NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];//转化为data
            //            NSArray *info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            //            // test code end
            
            NSLog(@"%@",info);
            
            [common savegamecontroller:info];//保存在本地，防止没网的时候不显示
            
            strongSelf->lis = [strongSelf getMenuListByInfo:info];
            
            [strongSelf multilevelMenu];
            [self.multilevelMenu reloadInputViews];
            [self.multilevelMenu.leftTablew reloadData];
       
        }
        else{
            NSArray *info = [common getgamec];
            strongSelf->lis = [strongSelf getMenuListByInfo:info];
            dispatch_main_async_safe(^{
                [strongSelf multilevelMenu];
            });
        }
        [strongSelf reloadCollectionHeaderView];
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSArray *info = [common getgamec];
        strongSelf->lis = [strongSelf getMenuListByInfo:info];
        dispatch_main_async_safe(^{
            [strongSelf multilevelMenu];
        });
        [strongSelf reloadCollectionHeaderView];
    }];
    
    [self refreshBtnClick];
}

- (NSMutableArray*)getMenuListByInfo:(NSArray *)info{
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:0];;
    NSInteger countMax = info.count;
    for (int i=0; i<countMax; i++) {
        NSDictionary *meunInfo = [info objectAtIndex:i];
        
        rightMeun * meun = [[rightMeun alloc] init];
        meun.meunName = [NSString stringWithFormat:@"%@",meunInfo[@"meunName"]];
        meun.urlName = [NSString stringWithFormat:@"%@",meunInfo[@"meunIcon"]];
        meun.urlSelectName = [NSString stringWithFormat:@"%@",meunInfo[@"meunIconSelected"]];
        meun.show_name =  [meunInfo[@"show_name"] boolValue];
        
        NSArray *subRootArray = meunInfo[@"sub"];
        NSMutableArray * sub = [NSMutableArray arrayWithCapacity:0];
        for ( int j=0; j <subRootArray.count; j++) {
            NSDictionary *subRootInfo = [subRootArray objectAtIndex:j];
            
            rightMeun * meun1 = [[rightMeun alloc] init];
            meun1.meunName = [NSString stringWithFormat:@"%@",subRootInfo[@"meunName"]];
            meun1.show_name =  [meunInfo[@"show_name"] boolValue];
            [sub addObject:meun1];
            
            if([subRootInfo objectForKey:@"sub"]){
                NSMutableArray *zList = [NSMutableArray arrayWithCapacity:0];
                
                NSArray *subs = [subRootInfo objectForKey:@"sub"];
                NSInteger subCount = subs.count;
                for ( int z=0; z <subCount; z++) {
                    NSDictionary *subInfo = [subs objectAtIndex:z];
                    
                    rightMeun * meun2 = [[rightMeun alloc] init];
                    meun2.meunName = subInfo[@"meunName"];
                    meun2.urlName = subInfo[@"urlName"];//@"https://www.baidu.com/img/baidu_resultlogo@2.png";
                    meun2.kindID = subInfo[@"kindID"];
                    meun2.type = subInfo[@"type"];
                    meun2.show_name =  [subInfo[@"show_name"] boolValue];
                    
                    if(meun2.kindID == nil){
                        meun2.kindID = 0;
                    }
                    meun2.plat = subInfo[@"plat"];
                    
                    
                    [zList addObject:meun2];
                }
                
                meun1.nextArray=zList;
                meun1.offsetScorller = -statusbarHeight;
            }
        }
        meun.nextArray=sub;
        meun.offsetScorller = -statusbarHeight;
        [menuList addObject:meun];
    }
    return menuList;
}


- (MultilevelMenu*)multilevelMenu {
    if (nil == _multilevelMenu) {
        //        _multilevelMenu = [[MultilevelMenu alloc]initWithFrame:_swipeTableView.bounds];
        WeakSelf
        _multilevelMenu = [[MultilevelMenu alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) WithData:lis withSelectIndex:^(NSInteger left, NSInteger right,rightMeun* info) {
            
            NSLog(@"点击的 [%@], 跳转:%@",info.meunName, info.kindID);
            // 自动转换额度
            if(info.plat && info.plat.length > 0){
                
                if ([info.type containsString:@"more"]) {
                    GameMoreListVC *vc = [GameMoreListVC new];
//                    vc.cateModel = info;
                    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

//                    NSLog(@"跳转更多列表");
//                    [MBProgressHUD showMessage:@"跳转更多游戏列表"];
//                api是:User.getPlatGames
//                    'User.getPlatGames' => array(
//                        'uid' => array('name' => 'uid', 'type' => 'string', 'require' => true, 'desc' => '玩家ID'),
//                        'token' => array('name' => 'token', 'type' => 'string', 'require' => true, 'desc' => '用户token'),
//                        'plat' => array('name' => 'plat', 'type' => 'string', 'require' => true, 'desc' => '平台'),
//                        'sub_plat' => array('name' => 'sub_plat', 'type' => 'string', 'require' => true, 'desc' => '子平台（KindID）'),
//                    ),

                    return;
                    
                }
                
                
                STRONGSELF
                strongSelf->iconUrlName = info.urlName;
                [GameToolClass enterGame:info.plat menueName:info.meunName kindID:info.kindID iconUrlName:info.urlName parentViewController: weakSelf autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                    
                } fail:^{
                    
                }];
            }else{
                [MBProgressHUD showError:YZMsg(@"GameListVC_UnknowGamePlat")];
            }
        }];
        _multilevelMenu.delelgate = self;
        _multilevelMenu.backgroundColor = [UIColor clearColor];
        _multilevelMenu.allData = lis;
        
        NSString *defaultType = minstr([GameToolClass getCurGameCenterDefaultType]);
        if(defaultType && defaultType.length > 0){
            BOOL bFound = false;
            for (int i = 0; i < lis.count; i++) {
                rightMeun * meun = lis[i];
                
                if([defaultType isEqualToString:@"lottery"] && [minstr(meun.meunName) containsString:YZMsg(@"GameListVC_lotteryTitle")]){
                    bFound = true;
                    _multilevelMenu.needToScorllerIndex=i;
                    break;
                }
            }
            if(!bFound){
                _multilevelMenu.needToScorllerIndex=0;
            }
        }else{
            _multilevelMenu.needToScorllerIndex=0;
        }
        
        _multilevelMenu.isRecordLastScroll=YES;
        [self.tableView reloadData];
     
        
        //[self.view addSubview:_multilevelMenu];
    }else{
        _multilevelMenu.allData = lis;
        NSString *defaultType = minstr([GameToolClass getCurGameCenterDefaultType]);
        if(defaultType && defaultType.length > 0){
            BOOL bFound = false;
            for (int i = 0; i < lis.count; i++) {
                rightMeun * meun = lis[i];
                
                if([defaultType isEqualToString:@"lottery"] && [minstr(meun.meunName) containsString:YZMsg(@"GameListVC_lotteryTitle")]){
                    bFound = true;
                    _multilevelMenu.needToScorllerIndex=i;
                    break;
                }
            }
//            if(!bFound){
//                _multilevelMenu.needToScorllerIndex=0;
//            }
        }else{
//            _multilevelMenu.needToScorllerIndex=0;
        }
        [_multilevelMenu reloadData];
    }
    
    [GameToolClass setCurGameCenterDefaultType:@""];
    return _multilevelMenu;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    if ([rate compare:[NSDecimalNumber decimalNumberWithString:@"0.0"]]!= NSOrderedDescending) {
        [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
            dispatch_main_async_safe(^{
            
            });
        }];
    }
    
    UIImageView * bj = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, VK_NAV_H+80)];
    bj.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    [self.view addSubview: bj];
    
    self.navigationController.title = YZMsg(@"");
    //    self.title = @"游戏中心";
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    
//    labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, self.navigationController.navigationBar.height)];
//    labelTitle.text = YZMsg(@"GameListVC_GameCenter_title");
//    labelTitle.textAlignment = NSTextAlignmentCenter;
//    labelTitle.backgroundColor = [UIColor clearColor];
//    labelTitle.textColor = [UIColor blackColor];
//    labelTitle.font = [UIFont systemFontOfSize:16];
//    [self.navigationController.navigationBar addSubview:labelTitle];
    
    if (self.isPushV) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 40, 40);
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
        [leftButton setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftButton];
        [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(VK_STATUS_H);
            make.height.width.mas_equalTo(44);
        }];
    }
    
    UIButton *customerBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-42, (self.navigationController.navigationBar.height -20)/2, 25, 20)];
    [customerBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"game_kf")] forState:UIControlStateNormal];
    [customerBtn addTarget:self action:@selector(livechatBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customerBtn];
    [customerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.width.mas_equalTo(44);
    }];
    
    [self createCollectionHeaderView];
    [self reloadCollectionHeaderView];
    if (@available(iOS 11.0, *)) {
       
        self.multilevelMenu.leftTablew.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets=NO;
#pragma clang diagnostic pop
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[GameListTableView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, 300)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 300.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableHeaderView = collectionHeaderView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    //self.tableView.bounces = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(VK_NAV_H);
        make.leading.trailing.bottom.mas_equalTo(self.view);
    }];
    self.isTableCanScroll = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setTableCanScroll) name:@"SetTableCanScroll" object:nil];
    
    WeakSelf
    self.tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
           STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf downData];
        [strongSelf getInfo];
        [strongSelf refreshBtnClick];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.tableView.mj_header endRefreshing];
//            ((MJRefreshNormalHeader*)strongSelf.tableView.mj_header).ignoredScrollViewContentInsetTop = 0;
        });
    }];
    ((MJRefreshNormalHeader*)self.tableView.mj_header).stateLabel.hidden = YES;
    ((MJRefreshNormalHeader*)self.tableView.mj_header).arrowView.tintColor = [UIColor whiteColor];
    ((MJRefreshNormalHeader*)self.tableView.mj_header).activityIndicatorViewStyle = UIScrollViewIndicatorStyleWhite;
    ((MJRefreshNormalHeader*)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
}

-(void)setTableCanScroll {
    self.isTableCanScroll = YES;
}

- (void)createCollectionHeaderView{
    if (collectionHeaderView) {
        [collectionHeaderView removeFromSuperview];
        collectionHeaderView = nil;
    }
    
    collectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 13 + 150 * (_window_width/375))];
    
    bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(10, 0, _window_width - 20, 150 * (_window_width/375)) delegate:self placeholderImage:[ImageBundle imagewithBundleName:YZMsg(@"img_zwsj")]];
    bannerScrollView.layer.cornerRadius = 7;
    bannerScrollView.layer.masksToBounds = YES;
    bannerScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    bannerScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    bannerScrollView.pageControlDotSize = CGSizeMake(6, 6);
    bannerScrollView.pageDotColor = RGB_COLOR(@"#ffffff", 0.4);
    bannerScrollView.currentPageDotColor = RGB_COLOR(@"#ffffff", 0.8);
    bannerScrollView.autoScrollTimeInterval = 5;
    bannerScrollView.backgroundColor = RGB(244, 245, 246);
    [collectionHeaderView addSubview:bannerScrollView];
    collectionHeaderView.userInteractionEnabled = YES;
    [self createCollectionHeaderBtnView];
    collectionHeaderView.backgroundColor = [UIColor clearColor];
}


#pragma mark - UUMarqueeViewDelegate
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    return 2;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    return _marqueeDatas ? _marqueeDatas.count : 0;
}


- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake( 0,0, CGRectGetWidth(itemView.bounds), CGRectGetHeight(itemView.bounds))];
    content.font = [UIFont systemFontOfSize:14];
    content.textColor  = RGB(51, 51, 51);
    content.tag = 1001;
    [itemView addSubview:content];
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    UILabel *content = [itemView viewWithTag:1001];
    if (index < _marqueeDatas.count) {
        content.text = _marqueeDatas[index];
    }
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for leftwardMarqueeView
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:14];
    if (index < _marqueeDatas.count) {
        content.text = _marqueeDatas[index];
    }
    return (5.0f + 16.0f + 5.0f) + content.intrinsicContentSize.width;  // icon width + label width (it's perfect to cache them all)
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    NSArray *system_msg = [common getSystemMsg];
    if(system_msg.count<1){
        return;
    }
    NSMutableArray *arrayStr = [NSMutableArray array];
    for (NSString *subStr in system_msg) {
        //NSArray *subStrA = [subStr componentsSeparatedByString:@"\n"];
        [arrayStr addObject:subStr];
    }
    if (_marqueeDatas.count > index && arrayStr.count>0) {
        NSString *msg = [arrayStr objectAtIndex:index];
        UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_systemMsgTitle") message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertC addAction:suerA];
        if (currentVC.presentedViewController != nil)
        {
            [currentVC dismissViewControllerAnimated:NO completion:nil];
        }
        if (currentVC.presentedViewController == nil) {
            [currentVC presentViewController:alertC animated:YES completion:nil];
        }
        
    }
}

// 头部点击区域
- (void)createCollectionHeaderBtnView{
    bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 116)];
    bg.backgroundColor = [UIColor clearColor];
    bg.userInteractionEnabled = YES;
    bg.layer.masksToBounds = YES;
    
    UIView *marqueeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bannerScrollView.width, 32)];
//    marqueeView.backgroundColor = [UIColor whiteColor];
    marqueeView.userInteractionEnabled = YES;
    marqueeView.layer.masksToBounds = YES;
    marqueeView.layer.cornerRadius = 16;
    marqueeView.tag = 777;
    [collectionHeaderView addSubview:marqueeView];
    
    // 公告图标
    UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 3, 25, 25)];
    [iconView setImage:[ImageBundle imagewithBundleName:@"game_gg"]];
    [marqueeView addSubview:iconView];
    
    _horizontalMarquee = [[UUMarqueeView alloc] initWithFrame:CGRectMake(45, 5, bannerScrollView.width - 45, 20) direction:UUMarqueeViewDirectionLeftward];
    _horizontalMarquee.delegate = self;
    _horizontalMarquee.timeIntervalPerScroll = 0.0f;
    _horizontalMarquee.scrollSpeed = 60.0f;
    _horizontalMarquee.itemSpacing = 20.0f;
    _horizontalMarquee.touchEnabled = YES;
    
    [bg addSubview:marqueeView];
    [marqueeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bg);
        make.leading.trailing.mas_equalTo(bg).inset(10);
        make.height.mas_equalTo(32);
    }];
    
    [marqueeView addSubview:_horizontalMarquee];
    
    UIView *bgContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 64)];
//    bgContentView.backgroundColor = [UIColor whiteColor];
    bgContentView.layer.cornerRadius = 16;
    [bg addSubview:bgContentView];
    [bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(bg).offset(10);
        make.trailing.mas_equalTo(bg).inset(10);
        make.top.mas_equalTo(marqueeView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(bg).inset(10);
    }];
    
    // 添加点击手势
    UIView *tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 64)];
    tapView.userInteractionEnabled = true;
    tapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapUpdateBalance = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refreshBtnClick)];
    [tapView addGestureRecognizer:tapUpdateBalance];
 
    [bgContentView addSubview:tapView];
    
    nameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 15)];
    LiveUser *user = [Config myProfile];
    nameLab.text = user.user_nicename;
    nameLab.font = [UIFont boldSystemFontOfSize:15];
    nameLab.textColor = [UIColor blackColor];
  
    nameLab.adjustsFontSizeToFitWidth = YES;
    nameLab.minimumScaleFactor = 0.3;
    [tapView addSubview:nameLab];
    
    coinLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 36, 60, 20)];
   
    coinLab.font = [UIFont systemFontOfSize:14];
    coinLab.numberOfLines = 1;
    coinLab.textColor = [UIColor blackColor];
     [tapView addSubview:coinLab];
    [coinLab sizeToFit];
    [bgContentView addSubview:coinLab];
    [self setTextBalance];
    
    refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [refreshBtn setTitle:@"0.11" forState:UIControlStateNormal];
    //    refreshBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [refreshBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    refreshBtn.frame = CGRectMake(coinLab.right+1,35,20,20);
    refreshBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [refreshBtn setImage:[ImageBundle imagewithBundleName:@"game_sx"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    //    [refreshBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - refreshBtn.imageView.image.size.width, 0, refreshBtn.imageView.image.size.width)];
    //    [refreshBtn setImageEdgeInsets:UIEdgeInsetsMake(0, refreshBtn.titleLabel.bounds.size.width, 0, -refreshBtn.titleLabel.bounds.size.width)];
    [tapView addSubview:refreshBtn];
    
    NSArray * nameArr = @[YZMsg(@"Bet_Charge_Title"),YZMsg(@"public_WithDraw"),YZMsg(@"GameCenter_List"),YZMsg(@"exchangeVC_OneKeyBack")];
    NSArray * imgArr = @[@"game_cz",@"game_tixian",@"game_bb",@"game_yjgj"];

    // 计算每个按钮的宽度
    CGFloat buttonWidth = (([UIScreen mainScreen].bounds.size.width-tapView.right-bgContentView.left*2)-5-3*nameArr.count-5) / nameArr.count;

    for (int i = 0; i< nameArr.count; i ++) {
        UIButton *livechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        livechatBtn.frame = CGRectMake(nameLab.right+i*(buttonWidth+3)+5,6,buttonWidth,50);
        
        livechatBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [livechatBtn setImage:[ImageBundle imagewithBundleName:imgArr[i]] forState:UIControlStateNormal];
        [livechatBtn setTitle:nameArr[i] forState:UIControlStateNormal];
        livechatBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        livechatBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        livechatBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        livechatBtn.titleLabel.minimumScaleFactor = 0.2;
        [livechatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self initButton:livechatBtn];
        livechatBtn.tag = 1000+i;
        [livechatBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgContentView addSubview:livechatBtn];
    }
}

- (void)reloadMarqueeData:(NSString *)gameTip {
    NSArray *system_msg = @[gameTip];
    NSMutableArray *arrayStr = [NSMutableArray array];
    for (NSString *subStr in system_msg) {
        NSString *stringMuta = @"";
        NSArray *subStrA = [subStr componentsSeparatedByString:@"\n"];
        for (NSString *subStr in subStrA) {
            stringMuta = [[stringMuta stringByAppendingString:subStr] stringByAppendingString:@"  "];
        }
        
        [arrayStr addObject:stringMuta];
    }
    if(system_msg.count > 0){
        _marqueeDatas = arrayStr;
    }else{
        _marqueeDatas = [NSMutableArray arrayWithArray:@[@" "]];
    }
    [_horizontalMarquee reloadData];
}

-(void)setTextBalance{
    LiveUser *user = [Config myProfile];
    coinLab.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
//    coinLab.text = @"10000000.00";
    [coinLab sizeToFit];
    if (coinLab.width>70) {
        coinLab.numberOfLines = 1;
        coinLab.width = 70;
        coinLab.adjustsFontSizeToFitWidth = YES;
        coinLab.minimumScaleFactor = 0.2;
        coinLab.text = coinLab.text;
    }
    refreshBtn.left = coinLab.right;
    
}

-(void)titleBtnClick:(UIButton *)btn{
    if(btn.tag == 1003){
        //  一键归集
        [MBProgressHUD showMessage:YZMsg(@"exchangeVC_OneKeyBack")];
        WeakSelf
        [GameToolClass backAllCoin:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [MBProgressHUD hideHUD];
            if (code == 0 && info && ![info isEqual:[NSNull null]]) {
                NSDictionary *infoDic = info;
                if([infoDic isKindOfClass:[NSArray class]]){
                    infoDic =  [info firstObject];
                }
                LiveUser *user = [Config myProfile];
                user.coin =  minstr([infoDic valueForKey:@"coin"]);
                [Config updateProfile:user];
                [strongSelf setTextBalance];
                [MBProgressHUD showSuccess:YZMsg(@"myRechargeCoinVC_OptionSuccess")];
            }else if(msg && ![msg isEqual:[NSNull null]]&& msg.length > 0){
                
                [MBProgressHUD showError:msg];
            }
        } fail:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [MBProgressHUD hideHUD];
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
    }else if (btn.tag == 1001){
        //  提现
        myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
        withdraw.titleStr = YZMsg(@"public_WithDraw");
        [[MXBADelegate sharedAppDelegate] pushViewController:withdraw animated:YES];
    }else if (btn.tag == 1000){
        //  充值
        PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        payView.titleStr = YZMsg(@"Bet_Charge_Title");
        [payView setHomeMode:false];
        [[MXBADelegate sharedAppDelegate] pushViewController:payView animated:YES];
    }else if (btn.tag == 1002){
        //  报表
        if (_gameReportDic) {
            NSString *url = [_gameReportDic objectForKey:@"href"];
            webH5 *VC = [[webH5 alloc]init];
            VC.titles = YZMsg(minstr([_gameReportDic valueForKey:@"name"]));
            url = [YBToolClass decodeReplaceUrl:url];
            VC.urls = url;
            [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
        }
    }else if (btn.tag == 1004){
        //  更多
        [self addBtnClick];
//        exchangeVC *exchange = [[exchangeVC alloc]init];
//        exchange.titleStr = YZMsg(@"h5game_Amount_Conversion");
//        [[MXBADelegate sharedAppDelegate] pushViewController:exchange animated:YES];
    }
    
}


-(void)refreshBtnClick{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            LiveUser *user = [Config myProfile];
            user.coin = minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
            [strongSelf setTextBalance];
            NSString *gameTip = [infoDic objectForKey:@"gameTip"];
            [strongSelf reloadMarqueeData:gameTip];
            [strongSelf updateSystemMsg];
        }else{
            [MBProgressHUD showError:msg];
        }
        
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
}


-(void)updateSystemMsg{
   
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"Home.getMarqueeContent&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:@{@"type":@"game_center"} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            NSString *gameTip = [infoDic objectForKey:@"content"];
            [strongSelf reloadMarqueeData:gameTip];
        }else{
//            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
}


//将按钮设置为图片在上，文字在下
-(void)initButton:(UIButton*)btn{
    [btn.titleLabel sizeToFit];
    float  spacing = 4;//图片和文字的上下间距
    CGSize imageSize = btn.imageView.frame.size;
    CGSize titleSize = btn.titleLabel.frame.size;
    
    CGSize textSize = [btn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    btn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), (btn.width-imageSize.width)/2, 0.0, 0);
    btn.titleEdgeInsets = UIEdgeInsetsMake(spacing, - imageSize.width, - (totalHeight - titleSize.height), 0);
    
}

//-(void)initButton:(UIButton*)btn{
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
//    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
//    [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
//}

- (void)reloadCollectionHeaderView{
    CGFloat reloadBottom = 0;
    BOOL hasBanner = true;
    if (adBannerInfoArr.count == 0) {
        bannerScrollView.frame = CGRectMake(10, 0, _window_width - 20, 0);
        bannerScrollView.hidden = YES;
        hasBanner = false;
    }else{
        bannerScrollView.frame = CGRectMake(10, 0, _window_width - 20, 150 * (_window_width/375));
        bannerScrollView.hidden = NO;
        hasBanner = true;
        reloadBottom = reloadBottom + 150 * (_window_width/375) + 2;
    }

    UIView *marqueeView = _horizontalMarquee.superview;
    marqueeView.frame = CGRectMake(10, reloadBottom==0?0:reloadBottom+5, _window_width -20 , 32);
    reloadBottom = marqueeView.bottom + 5;
//    bg.frame = CGRectMake(0, reloadBottom, _window_width , 74);

//    reloadBottom = bg.bottom + 2;
    UIView *line = [collectionHeaderView viewWithTag:131411];
    [line removeFromSuperview];
    collectionHeaderView.frame = CGRectMake(0, 0, _window_width, hasBanner?(13 + 150 * (_window_width/375)):1);
//    if (hasBanner) {
//        [_multilevelMenu reloadFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-(40+ShowDiff/2.5+ collectionHeaderView.bottom+6))];
//    }else{
//        [_multilevelMenu reloadFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-(40+ShowDiff/2.5+ collectionHeaderView.bottom+6))];
//    }
    [self.tableView reloadData];
}

-(void)downData{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetBaseInfo" withBaseDomian:YES andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        NSLog(@"%@",info);
        
        
        NSMutableArray *imageUrlArr = [NSMutableArray array];
        NSMutableArray *infoDataArr = [NSMutableArray array];
        if([info isKindOfClass:[NSArray class]]&& [(NSArray*)info count]>0){
            NSDictionary *infoDic = [info objectAtIndex:0];
            
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
            user.isBindMobile = [[infoDic valueForKey:@"isBindMobile"] boolValue];
            user.isZeroCharge =[[infoDic valueForKey:@"isZeroCharge"] boolValue];
            user.liveShowChargeTime = [[infoDic valueForKey:@"liveShowChargeTime"] intValue];
            user.signature = minstr([infoDic valueForKey:@"signature"]);
            user.coin = minstr(infoDic[@"coin"]);
            user.withdrawInfo = infoDic[@"withdrawInfo"];
            [Config updateProfile:user];
            
            [strongSelf setTextBalance];
            
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
            NSArray *list = [infoDic valueForKey:@"list"];
            [common savepersoncontroller:list];//保存在本地，防止没网的时候不显示
            [[NSNotificationCenter defaultCenter]postNotificationName:KUpdateSkitEntrance object:nil];
            for (NSArray *subArray in list) {
                if (subArray.count>0) {
                    for (NSDictionary *subDic in subArray) {
                        NSString *href = [subDic objectForKey:@"href"];
                        NSString *scheme = [subDic objectForKey:@"scheme"];
                        if (href && [scheme containsString:@"game-report://"]) {
                            strongSelf->_gameReportDic = subDic;
                        }
                    }
                }
            }
            if([infoDic objectForKey:@"adlist"])
            {
                NSArray *adListArr = [infoDic objectForKey:@"adlist"];
                
                for(NSDictionary *adDic in adListArr)
                {
                    if([[adDic objectForKey:@"pos"] intValue] == 4 || [[adDic objectForKey:@"pos"]  isEqual: @"4"])
                    {
                        [infoDataArr addObject:adDic];
                        if([adDic objectForKey:@"image"])
                        {
                            [imageUrlArr addObject:[adDic objectForKey:@"image"]];
                        }
                    }
                }
            }
            if (infoDataArr) {
                strongSelf->adBannerInfoArr = [NSArray arrayWithArray:infoDataArr];
            }
            strongSelf->bannerScrollView.imageURLStringsGroup = imageUrlArr;
            
            [strongSelf reloadCollectionHeaderView];
        }else{
            [MBProgressHUD showError:msg];
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        dispatch_main_async_safe(^{
            [strongSelf reloadCollectionHeaderView];
        });
    }];
}

-(void)livechatBtnClick{

    [YBToolClass showService];
}


- (void)closeService:(id)sender{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeVC{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
    [[[MXBADelegate sharedAppDelegate] topViewController].navigationController popViewControllerAnimated:YES];
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    if(adBannerInfoArr.count > index)
    {
        NSDictionary *infoDic = [adBannerInfoArr objectAtIndex:index];
        
        if([infoDic objectForKey:@"url"])
        {
            NSString *urlStr = [infoDic objectForKey:@"url"];
            NSString *urlShowType = [infoDic objectForKey:@"show_type"];
            NSDictionary *data = @{@"scheme": urlStr, @"showType": urlShowType};
            [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
        }
    }
}


//提现记录
- (void)addBtnClick{
    webH5 *web = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=Withdraw&a=index&uid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    
    web.urls = url;
    [[MXBADelegate sharedAppDelegate] pushViewController:web animated:YES];
   
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - lotteryBetViewDelegate
- (void)setCurlotteryVC:(LotteryBetViewController *)vc {

}
-(BOOL)cancelLuwu {
    return false;
}

-(void)lotteryCancless {
    return;
}

- (void)refreshTableHeight:(BOOL)isShowTopView {
    return;
}
-(void)doGame {
    return;
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
    } else if (curLotteryType == 32 || curLotteryType == 7 || curLotteryType == 8) {
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

#pragma mark - MultilevelMenuDeleaget
- (void)multilevelMenuScrollViewDidScroll:(UIScrollView *)scrollView {
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![self.tableView.subviews containsObject:bg]) { return; }
    if (firstSectionHeaderY == 0 && self.tableView.subviews.count >= 3) {
        firstSectionHeaderY = [self.tableView.subviews objectAtIndex:2].frame.size.height;
    } else {
        if (self.isTableCanScroll == NO) {
            [self.tableView setContentOffset:CGPointMake(0, firstSectionHeaderY) animated:NO];
        } else if (scrollView.contentOffset.y >= firstSectionHeaderY) { // 悬停了
            self.isTableCanScroll = NO;
            [self.tableView setContentOffset:CGPointMake(0, firstSectionHeaderY) animated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetContentTableCanScroll" object:nil];
        }
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell.contentView.subviews.count == 0) {
        [cell.contentView addSubview:_multilevelMenu];
    }
    [_multilevelMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(cell);
        NSInteger bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        if (self.isPushV) {
            make.height.mas_equalTo(kScreenHeight - (13 + 150 * (_window_width/375)) - (bottom > 0 ? 64 : 20));
        } else {
            make.height.mas_equalTo(kScreenHeight - (13 + 150 * (_window_width/375)) - 74);
        }
    }];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return bg;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 116;
}

@end

@implementation GameListTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
