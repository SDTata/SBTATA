#import "Hotpage.h"
#import "hotModel.h"
#import "LivePlay.h"
#import "MXBADelegate.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "HotCollectionViewCell.h"
//#import "classVC.h"

#import "allClassView.h"
//#import <SDCycleScrollView/SDCycleScrollView.h>

#import "myPopularizeVC.h"
#import "HotAndAttentionPreviewLogic.h"
#import "h5game.h"



#import "UUMarqueeView.h"
#import "ZYTabBarController.h"
#import "UINavModalWebView.h"
#import "NavWeb.h"
#import "LivePlayTableVC.h"
#import "EnterLivePlay.h"
#import "ChannelStatistics.h"
#import "UIView+UIScreenDisplaying.h"

#if !TARGET_IPHONE_SIMULATOR
#import "GrowingTracker.h"
#endif

#import "FilterAnchorCounrtyView.h"
#import "HotCycleBanner.h"
#import "OneBuyGirlViewController.h"
#import "myWithdrawVC2.h"
#import "AnimRefreshHeader.h"
#import "DramaHomeViewController.h"
#import <UMCommon/UMCommon.h>

@interface Hotpage ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate,UIScrollViewDelegate,UUMarqueeViewDelegate,FilterCountryDelegate>
{
    UIImageView *NoInternetImageV;//直播无网络的时候显示
    UIAlertController *alertController;//邀请码填写
    UITextField *codetextfield;
    
    CGFloat oldOffset;
    NSInteger page;
    NSString *classID;
    NSString *mCurrentUrl;
    allClassView *allClassV;
    YBNoWordView *noNetwork;
 
    UIButton *inviteImageBtn;
    


    // 跑马灯
    UUMarqueeView *_horizontalMarquee;
    NSMutableArray <NSString *> *_marqueeDatas;
    //
   

//    BOOL appearReq;
//    NSInteger refrshPage;
    BOOL loadingData;
    BOOL isFirstLoadingData;
    
    BOOL _isBannerSection_0;
    BOOL _isBannerSection_1;
    
    BOOL _isBannerSection_5;
    BOOL _isBannerSection_10;
    
    NSString *regionCurrent;
    CountryFilterModel * selectedModel;
    CGFloat collectionViewHeight;
    CGFloat collectionViewTop;
}
@property(nonatomic,strong)NSMutableArray *zhuboModels;//主播模型
@property(nonatomic,strong)UICollectionView *collectionView;


@property(nonatomic,strong)UIView *systemNotifyView;



@property(nonatomic,strong)HotCycleBanner *banner_section_0;//轮播组2


@property(nonatomic,strong)HotCycleBanner *banner_section_5;//轮播组5
@property(nonatomic,strong)HotCycleBanner *banner_section_10;//轮播组10
@property(nonatomic,strong)FilterAnchorCounrtyView *anchorfiltrCountryView;
@property(nonatomic,strong)UIView *countryView;
@property(nonatomic,strong)NSArray *datas;



@end
@implementation Hotpage

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh_system_msg) name:KRefresh_system_msg object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    mCurrentUrl = @"Home.getHot";

    if (!isFirstLoadingData) {
        if ([common ad_list]!= nil) {
            page = 1;
            [self homeConfig];
           
        }else{
            WeakSelf
            [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (errormsg== nil) {
                    strongSelf->page = 1;
                    [strongSelf pullInternet];
                }
            }];
        }
        
        isFirstLoadingData = YES;
    }else{
    }
    
    
    NSLog(@"%f",_collectionView.contentOffset.y);
}
- (void)viewWillDisappear:(BOOL)animated{
   
  
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KRefresh_system_msg object:nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
#if !TARGET_IPHONE_SIMULATOR  && !DEBUG
    [[GrowingTracker sharedInstance] trackCustomEvent:@"loginSuccess_var"];
#endif

    regionCurrent = [[NSUserDefaults standardUserDefaults]objectForKey:RegionAnchorSelected];
    if (regionCurrent == nil) {
        regionCurrent = @"";
    }
    
    _marqueeDatas = [NSMutableArray <NSString *> array];
    oldOffset = 0;
    _isBannerSection_5 = NO;
    _isBannerSection_10 = NO;
    page = 1;
    mCurrentUrl = @"Home.getHot";
    self.zhuboModels    =  [NSMutableArray array];
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self nothingview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeConfig) name:@"home.getconfig" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadMoreDataFromPlayList:) name:LivePlayTableVCRequestDataNotifcation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadMoreDataAfterCheckNetwork) name:@"LoadDataAfterCheckNetwork" object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateRemoveMode:) name:LivePlayTableVCUpdateRemoveModelNotifcation object:nil];

    [self createView];
}

-(void)loadMoreDataAfterCheckNetwork
{
    if (self.zhuboModels==nil ||self.zhuboModels.count == 0) {
        if (!loadingData) {
            page = 1;
            [self pullInternet];
        }
    }
}

- (void)updateRemoveMode:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *roomId = userInfo[@"roomId"];
    for (hotModel *model in _zhuboModels) {
        if ([model.zhuboID isEqualToString:roomId]) {
            [_zhuboModels removeObject:model];
            break;
        }
    }
    [self.collectionView reloadData];
}

-(void)loadMoreDataFromPlayList:(NSNotification*)notify {
    if (!notify.userInfo || ![notify.userInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *zhubo_id = [notify.userInfo objectForKey:@"zhubo_id"];
    if (!zhubo_id || ![zhubo_id isKindOfClass:[NSString class]]) {
        return;
    }
    
    // 检查数据源是否有效
    if (!self.zhuboModels || ![self.zhuboModels isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    
    NSInteger numberIndeXint = -1; // 使用-1表示未找到
    
    // 查找对应的主播索引
    for (NSInteger i = 0; i < self.zhuboModels.count; i++) {
        id obj = self.zhuboModels[i];
        if (![obj isKindOfClass:[hotModel class]]) {
            continue;
        }
        
        hotModel *model = (hotModel *)obj;
        if ([model.zhuboID isEqualToString:zhubo_id]) {
            numberIndeXint = i;
            break;
        }
    }
    
    // 如果没找到对应的主播,直接返回
    if (numberIndeXint == -1) {
        return;
    }
    
    // 检查索引是否在数组范围内
    if (numberIndeXint > self.zhuboModels.count) {
        // 如果索引超出数组范围，可以在这里处理错误或直接返回
        return;
    }

    
    // 计算应该滚动到的部分和行
    NSInteger section = 0;
    NSInteger row = 0;
    
    // 根据主播索引计算section和row
    if (numberIndeXint < 8) {
        section = 0;
        row = numberIndeXint;
    } else if (numberIndeXint >= 8 && numberIndeXint < 12) {
        section = 1;
        row = numberIndeXint - 8;
    } else if (numberIndeXint >= 12 && numberIndeXint < 20) {
        section = 2;
        row = numberIndeXint - 12;
    } else if (numberIndeXint >= 20 && numberIndeXint < 28) {
        section = 3;
        row = numberIndeXint - 20;
    } else if (numberIndeXint >= 28 && numberIndeXint < 38) {
        section = 4;
        row = numberIndeXint - 28;
    } else {
        section = 5;
        row = numberIndeXint - 38;
    }
    
    // 检查collectionView是否存在
    if (!self.collectionView) {
        return;
    }
    
    // 验证section和row的有效性
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (section >= numberOfSections) {
        return;
    }
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    if (row >= numberOfItems) {
        return;
    }

    // 滚动到计算出的部分和行
    @try {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        if (indexPath) {
            [self.collectionView scrollToItemAtIndexPath:indexPath 
                                      atScrollPosition:UICollectionViewScrollPositionCenteredVertically 
                                              animated:YES];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception in scrollToItemAtIndexPath: %@", exception);
    }
    
    // 加载更多数据的逻辑（如果需要）
    if (numberIndeXint == (self.zhuboModels.count - 2) && !loadingData && self.zhuboModels != nil && self.zhuboModels.count > 0 && [self.view isDisplayedInScreen]) {
        [self pullInternet];
    }
}


- (void)homeConfig{

    // 悬浮按钮
   
    if (self.zhuboModels==nil || self.zhuboModels.count == 0) {
        page = 1;
        [self pullInternet];
    }
}
- (void)createView{

    [self createCollectionView];
  
    [self homeAddGames];
    [self homeCountryView];
    self.banner_section_0 = [[HotCycleBanner alloc] initWithFrame:CGRectZero andType:2];
    self.banner_section_5 = [[HotCycleBanner alloc] initWithFrame:CGRectZero andType:0];
    self.banner_section_10 = [[HotCycleBanner alloc] initWithFrame:CGRectZero andType:1];
}


-(void)systemNotifyViewCreate {
    UIView *marqueeView = [[UIView alloc]initWithFrame:CGRectMake(0,-35, SCREEN_WIDTH, 35)];
    marqueeView.backgroundColor =[UIColor clearColor];
    marqueeView.userInteractionEnabled = YES;
    
//    UIImageView *imgbg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
//    imgbg.image = [ImageBundle imagewithBundleName:@"bg_main_notification"];
//    imgbg.contentMode = UIViewContentModeScaleAspectFill;
//    [marqueeView addSubview:imgbg];
    
    // 公告图标
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(14, 7, 69.65, 22)];
    [imgView setImage:[ImageBundle imagewithBundleName:YZMsg(@"Hotpage_zxggIcon")]];
    [marqueeView addSubview:imgView];
    
    _horizontalMarquee = [[UUMarqueeView alloc] initWithFrame:CGRectMake(88, 8, SCREEN_WIDTH - 88 - 12, 20) direction:UUMarqueeViewDirectionLeftward];
    _horizontalMarquee.delegate = self;
    _horizontalMarquee.timeIntervalPerScroll = 0.0f;
    _horizontalMarquee.scrollSpeed = 60.0f;
    _horizontalMarquee.itemSpacing = 20.0f;
    _horizontalMarquee.touchEnabled = YES;
    
    
    NSArray *system_msg = [common getSystemMsg];
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
        _marqueeDatas = arrayStr.mutableCopy;
    }else{
        _marqueeDatas = @[@" "].mutableCopy;
    }
    [marqueeView addSubview:_horizontalMarquee];
    [_horizontalMarquee reloadData];
    [self.collectionView addSubview:marqueeView];
}


- (void)reloadCollectionHeaderView{
  
    _gamesView.frame = CGRectMake(_gamesView.frame.origin.x, 0, _gamesView.width, _gamesView.height);
   
    [_horizontalMarquee reloadData];

    [self.collectionView reloadData];
}
-(void)countryModelSelected:(CountryFilterModel *)model
{
    selectedModel = model;
    regionCurrent = model.countryCode;
    [[NSUserDefaults standardUserDefaults]setObject:regionCurrent forKey:RegionAnchorSelected];
    [[NSUserDefaults standardUserDefaults]synchronize];
    page = 1;
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self pullInternet];
    [self updateCountry];
}
- (void)refresh_system_msg{
    WeakSelf
    dispatch_main_async_safe(^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSArray *system_msg = [common getSystemMsg];
        NSMutableArray *arrayStr = [NSMutableArray array];
        for (NSString *subStr in system_msg) {
            NSString *stringMuta = @"";
            NSArray *subStrA = [subStr componentsSeparatedByString:@"\n"];
            for (NSString *subStr in subStrA) {
                stringMuta = [[stringMuta stringByAppendingString:subStr] stringByAppendingString:@"  "];
            }
            //[arrayStr addObjectsFromArray:subStrA];
            [arrayStr addObject:stringMuta];
        }
        if(system_msg.count > 0){
            strongSelf->_marqueeDatas = arrayStr.mutableCopy;
        }else{
            strongSelf->_marqueeDatas = @[@" "].mutableCopy;
        }
        [strongSelf reloadCollectionHeaderView];
    })
    //_verticalMarquee.text = [NSString stringWithFormat:@"%@                              ", system_msg];
}



- (void)homeAddGames{
    NSArray* ad_list = [common ad_list];
    int gameCount = 0;
    //    ad_list = [[NSArray alloc] init];;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqual:@"game"]){
                gameCount++;
            }
        }
    }
    
    int numPreLine = 4;
    CGFloat marigin = AD(10);
    CGFloat argW = ((_window_width - 5) - (numPreLine + 1) * marigin) / numPreLine;
    CGFloat argH = argW * 5/4;
    CGFloat totalH = argH + AD(30);
    _gamesView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, totalH)];
    _gamesView.backgroundColor = [UIColor clearColor];
    _gamesView.layer.cornerRadius = 5.0;
    _gamesView.layer.masksToBounds = YES;
    _gamesView.userInteractionEnabled = YES;
    
    if(gameCount <= 0){
        _gamesView.hidden = YES;
        _isBannerSection_1 = false;
    }else{
        _gamesView.hidden = NO;
        _isBannerSection_1 = true;
    }
    // 精品推荐title
    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, _gamesView.right - 180 - 13, 15)];
    [labTitle setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    [labTitle setTextColor:RGB(51, 51, 51)];
    //    [labTitle setTextAlignment:NSTextAlignmentCenter];
    [labTitle setText:YZMsg(@"GamesHeader_Game_Recommend")];
    [labTitle setNumberOfLines:2];
    [_gamesView addSubview:labTitle];
    [labTitle sizeToFit];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(labTitle.right - 29, labTitle.bottom +3, 30 , 3)];
    line.backgroundColor = RGB(184, 92, 238);
    line.layer.masksToBounds = YES;
    line.layer.cornerRadius = 1.5;
    [_gamesView addSubview:line];
    
    // 更多
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(_gamesView.right - 180,7,170,15);
//    moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //[moreBtn setImage:[ImageBundle imagewithBundleName:@"arrows_43"] forState:UIControlStateNormal];
    [moreBtn setTitle:YZMsg(@"Hotpage_leftAddMore") forState:UIControlStateNormal];
    [moreBtn setTitleColor:RGB(153, 153, 153) forState:0];
    [moreBtn setImage:[ImageBundle imagewithBundleName:@"zjm_jt1"]forState:UIControlStateNormal];
    moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(15, 155, 15, 0)];
    moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    moreBtn.titleLabel.font = SYS_Font(14);
    moreBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [moreBtn addTarget:self action:@selector(moreGamesClick) forControlEvents:UIControlEventTouchUpInside];
    [_gamesView addSubview:moreBtn];
    UIScrollView *gamecontent = [[UIScrollView alloc]initWithFrame:CGRectMake(0, line.bottom+10, SCREEN_WIDTH, argH)];
    gamecontent.showsHorizontalScrollIndicator = NO;
    gamecontent.contentSize = CGSizeMake((marigin + 1 + argW) * gameCount, argH);
    gamecontent.backgroundColor = [UIColor clearColor];
    [_gamesView addSubview:gamecontent];
    NSInteger idx = 0;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqual:@"game"]){
                UIButton *btn = [UIButton buttonWithType:0];
                btn.frame = CGRectMake(marigin + 1 + idx * (marigin + 1 + argW), 0, argW, argH);
                btn.tag = idx;
                btn.userInteractionEnabled = YES;
                [btn addTarget:self action:@selector(jumpGame:) forControlEvents:UIControlEventTouchUpInside];
                                
                [btn sd_setImageWithURL:[NSURL URLWithString:[_ad valueForKey:@"src"]] forState:UIControlStateNormal placeholderImage:GamePlaceholdImageVertical completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (image) {
                        [btn setImage:image forState:UIControlStateNormal];
                        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];
                [gamecontent addSubview:btn];
                idx ++;
            }
        }
    }
    
}

-(void)filterVC{
    FilterCountryVC *filterVC = [[FilterCountryVC alloc]initWithNibName:@"FilterCountryVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    filterVC.delegate = self;
    filterVC.datas = self.datas;
    [[MXBADelegate sharedAppDelegate] pushViewController:filterVC animated:YES];
}
-(void)updateCountry{
    UIButton *buttonContry = [self.pageView viewWithTag:10000];
    if (buttonContry && selectedModel) {
        NSURL *imgUrl = [NSURL URLWithString:selectedModel.icon];
        if (imgUrl) {
            [buttonContry sd_setImageWithURL:imgUrl forState:UIControlStateNormal];
        }
        
    }
}


- (void)homeCountryView{
    _countryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , _window_width, 30)];
    _countryView.backgroundColor = [UIColor clearColor];
    _countryView.userInteractionEnabled = YES;
   
    // 精品推荐title
    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, _gamesView.right - 180 - 13, 15)];
    [labTitle setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    [labTitle setTextColor:RGB(51, 51, 51)];
    //    [labTitle setTextAlignment:NSTextAlignmentCenter];
    [labTitle setText:YZMsg(@"AttentionHeader_Popular_Hot")];
    [labTitle setNumberOfLines:2];
    [_countryView addSubview:labTitle];
    [labTitle sizeToFit];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(labTitle.right - 29, labTitle.bottom +3, 30 , 3)];
    line.backgroundColor = RGB(184, 92, 238);
    line.layer.masksToBounds = YES;
    line.layer.cornerRadius = 1.5;
    [_countryView addSubview:line];
    
}



-(void)moreGamesClick{
    //_pageView.hidden = NO;
    
    [self showTabBar];
    self.tabBarController.selectedIndex = 2;
    // 标记 默认是彩票
    [GameToolClass setCurGameCenterDefaultType:@"lottery"];
}

- (void)jumpGame:(UIButton *)sender{
    NSArray* ad_list = [common ad_list];
    int idx = 0;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqualToString:@"game"]){
                if(sender.tag == idx){
                    NSString *kindID = [_ad valueForKey:@"kindID"];
                    NSString *plat = _ad[@"plat"];
                    NSString *urlName = _ad[@"urlName"];
                    [GameToolClass enterGame:plat menueName:@"" kindID:kindID iconUrlName:urlName parentViewController: self autoExchange:[common getAutoExchange]  success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                        
                    } fail:^{
                        
                    }];
//                    if([kindID integerValue] == 26){
//                        LotteryCenterBetViewController_YFKS *VC = [[LotteryCenterBetViewController_YFKS alloc]initWithNibName:@"LotteryCenterBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//                        [VC setLotteryType:[kindID integerValue]];
//                        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//                    }else if([kindID integerValue] == 28){
//                        LotteryCenterBetViewController_BJL *VC = [[LotteryCenterBetViewController_BJL alloc]initWithNibName:@"LotteryCenterBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//                        [VC setLotteryType:[kindID integerValue]];
//                        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//                    }else if([kindID integerValue] == 29){
//                        LotteryCenterBetViewController_ZJH *VC = [[LotteryCenterBetViewController_ZJH alloc]initWithNibName:@"LotteryCenterBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//                        [VC setLotteryType:[kindID integerValue]];
//                        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//                    }else if([kindID integerValue] == 30){
//                        LotteryCenterBetViewController_ZP *VC = [[LotteryCenterBetViewController_ZP alloc]initWithNibName:@"LotteryCenterBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//                        [VC setLotteryType:[kindID integerValue]];
//                        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//                    }else if([kindID integerValue] == 31){
//                        LotteryCenterBetViewController_LH *VC = [[LotteryCenterBetViewController_LH alloc]initWithNibName:@"LotteryCenterBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//                        [VC setLotteryType:[kindID integerValue]];
//                        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//                    }
                    break;
                    return;
                }
                idx++;
            }
        }
    }
}




-(void)createCollectionView{
    
    if (_collectionView) {
        [_collectionView removeFromSuperview];
        _collectionView = nil;
    }
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat  itemW = _window_width/2-15;
    CGFloat  itemH = itemW * 8/7;
    flow.itemSize = CGSizeMake(itemW, itemH);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);

    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds
                                        collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotCollectionViewCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"HotCollectionViewCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV1"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV2"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV3"];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"bannerHeaderV_sec5"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"bannerHeaderV_sec10"];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _collectionView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
    [self systemNotifyViewCreate];  //直接显示
    
    WeakSelf
    AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->page = 1;
        
        if ([common ad_list] == nil ||([common ad_list]!= nil && [common ad_list].count<1)) {
            [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
                [strongSelf homeConfig];
                if (strongSelf.zhuboModels!=nil && strongSelf.zhuboModels.count > 0) {
                    [strongSelf pullInternet];
                }else{
                    [strongSelf.collectionView.mj_header endRefreshing];
                }
            }];
        }else{
           
            [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
                [strongSelf pullInternet];
                [strongSelf refresh_system_msg];
            }];
        }
    }];
    refreshHeader.ignoredScrollViewContentInsetTop = 35;
    [_collectionView setMj_header:refreshHeader];

    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf pullInternet];
    }];
    _collectionView.mj_footer.hidden = YES;
    ((MJRefreshBackNormalFooter*)_collectionView.mj_footer).stateLabel.textColor = [UIColor blackColor];
    ((MJRefreshBackNormalFooter*)_collectionView.mj_footer).arrowView.tintColor = [UIColor blackColor];
    ((MJRefreshBackNormalFooter*)_collectionView.mj_footer).activityIndicatorViewStyle = UIScrollViewIndicatorStyleWhite;

    
    _collectionView.backgroundColor = [UIColor clearColor];
}
-(void)nothingview{
  
    WeakSelf
    noNetwork = [[YBNoWordView alloc]initWithImageName:NULL andTitle:NULL withBlock:^(id  _Nullable msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->mCurrentUrl = @"Home.getHot";
        [strongSelf pullInternet];
    } AddTo:self.view];
    
}
static BOOL isNoMoreDatas;
//获取网络数据
-(void)pullInternet{
    //@"Home.getHot"
    if (loadingData) {
        return;
    }
    loadingData = YES;
    WeakSelf
    [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 20;
    [[YBNetworking sharedManager] postNetworkWithUrl:mCurrentUrl withBaseDomian:YES andParameter:@{@"p":@(page),@"region":regionCurrent} data:nil success:^(int code,id info,NSString *msg) {
        STRONGSELF
        [MBProgressHUD hideHUD];
        if (strongSelf==nil) {
            return;
        }
        strongSelf->loadingData = NO;

        if (code == 0) {
            strongSelf->noNetwork.hidden = YES;
            if(![info isKindOfClass:[NSArray class]] ||[(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSDictionary *infoA = [info objectAtIndex:0];
            strongSelf.datas = [CountryFilterModel mj_objectArrayWithKeyValuesArray:infoA[@"live_support_regions"]];
            strongSelf->selectedModel = [CountryFilterModel mj_objectWithKeyValues:infoA[@"live_current_region"]];
            strongSelf->regionCurrent = strongSelf->selectedModel.countryCode;
            [strongSelf updateCountry];
            
            NSArray *list = NULL;
            if([strongSelf->mCurrentUrl isEqualToString:@"Home.getClassLive"]){
                list = info;
            }else{
                list = [infoA valueForKey:@"list"];
            }
            if (strongSelf->page == 1) {
                isNoMoreDatas = NO;
                [strongSelf.zhuboModels removeAllObjects];
                
            }
            for (NSDictionary *dic in list) {
                hotModel *model = [hotModel mj_objectWithKeyValues:dic];
                if(strongSelf.zhuboModels.count>0 && strongSelf->page>1){
                    ///去重复
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zhuboID CONTAINS[cd] %@" ,model.zhuboID];
                    NSArray *arrays = [strongSelf.zhuboModels filteredArrayUsingPredicate:predicate];
                    if(arrays.count>0){
                        continue;
                    }
                }
                [strongSelf.zhuboModels addObject:model];
            }
            
            if(strongSelf.collectionView.mj_footer.hidden){
                strongSelf.collectionView.mj_footer.hidden = NO;
            }
            if(list.count>0){
                strongSelf->page = strongSelf->page + 1;
            }
            [strongSelf.collectionView.mj_header endRefreshing];
            [strongSelf.collectionView.mj_footer endRefreshing];
            [strongSelf reloadCollectionHeaderView];
            if (list.count == 0) {
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                isNoMoreDatas = YES;
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCUpdateNotifcation object:nil];
            }
            NSDictionary *userInfo = @{@"models": [NSArray arrayWithArray:strongSelf.zhuboModels]};
            [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCUpdateModelsNotifcation object:nil userInfo:userInfo];
        }else{
            [strongSelf.collectionView.mj_header endRefreshing];
            [strongSelf.collectionView.mj_footer endRefreshing];
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->loadingData = NO;
        [MBProgressHUD hideHUD];
        [strongSelf.collectionView.mj_header endRefreshing];
        [strongSelf.collectionView.mj_footer endRefreshing];
        if (strongSelf.zhuboModels.count == 0) {
            strongSelf->noNetwork.hidden = NO;
        }
        
    }];
    if (page == 1) {
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetBaseInfo" withBaseDomian:YES andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            NSLog(@"%@",info);
            
          
            if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSDictionary *infoDic = [info objectAtIndex:0];
            NSInteger section_0_count = 0;
            NSInteger section_5_count = 0;
            NSInteger section_10_count = 0;
            if([infoDic objectForKey:@"adlist"])
            {
                NSArray *adListArr = [infoDic objectForKey:@"adlist"];
                
                for(NSDictionary *adDic in adListArr)
                {
                    if([[adDic objectForKey:@"pos"] intValue] == 8 || [[adDic objectForKey:@"pos"]  isEqual: @"8"])
                    {
                        section_0_count++;
                    }
                    if([[adDic objectForKey:@"pos"] intValue] == 6)
                    {
                        section_5_count++;
                    }
                    if([[adDic objectForKey:@"pos"] intValue] == 7)
                    {
                        section_10_count++;
                    }
                }
            }
            if (section_0_count > 0) {
                strongSelf->_isBannerSection_0 = YES;
            }else{
                strongSelf->_isBannerSection_0 = NO;
            }
            if (section_5_count > 0) {
                strongSelf->_isBannerSection_5 = YES;
            }else{
                strongSelf->_isBannerSection_5 = NO;
            }
            if (section_10_count > 0) {
                strongSelf->_isBannerSection_10 = YES;
            }else{
                strongSelf->_isBannerSection_10 = NO;
            }
           
            
            NSArray *system_msg = [infoDic objectForKey:@"system_msg"];
            [common saveSystemMsg:system_msg];
            [strongSelf reloadCollectionHeaderView];
        } fail:^(NSError * _Nonnull error) {
            
        }];
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_zhuboModels.count<=8) {
        return 1;
    }else if (_zhuboModels.count>8 && _zhuboModels.count<=12) {
        return 2;
    }else if (_zhuboModels.count>12 && _zhuboModels.count<=20) {
        return 3;
    }else if (_zhuboModels.count>20 && _zhuboModels.count<=28) {
        return 4;
    }else if (_zhuboModels.count>28 && _zhuboModels.count<=38) {
        return 5;
    }else if (_zhuboModels.count>38) {
        return 6;
    }else{
        return 0;
    }
   
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        if (_zhuboModels.count > 8) {
            return 8;
        }else{
            return _zhuboModels.count;
        }
    }else if (section == 1){
        if (_zhuboModels.count > 12) {
            return 4;
        }else {
            return _zhuboModels.count - 8;
        }
    }else if (section == 2){
        if (_zhuboModels.count > 20) {
            return 8;
        }else{
            return _zhuboModels.count - 12;
        }
    }else if (section == 3){
        if (_zhuboModels.count > 28) {
            return 8;
        }else {
            return _zhuboModels.count - 20;
        }
    }else if (section == 4){
        if (_zhuboModels.count > 38) {
            return 10;
        }else{
            return _zhuboModels.count - 28;
        }
    }else{
        return _zhuboModels.count - 38;
    }
    return _zhuboModels.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSString *type;
    if (indexPath.section == 0) {
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row cell:[collectionView cellForItemAtIndexPath:indexPath]];
        type = @"推荐1";
    }else if (indexPath.section == 1 && _zhuboModels.count > indexPath.row + 8){
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row + 8 cell:[collectionView cellForItemAtIndexPath:indexPath]];
        type = @"推荐2";
    }else if (indexPath.section == 2 && _zhuboModels.count > indexPath.row + 12){
            [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row + 12 cell:[collectionView cellForItemAtIndexPath:indexPath]];
        type = @"遊戲推荐";
    }else if (indexPath.section == 3 && _zhuboModels.count > indexPath.row + 20){
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row + 20 cell:[collectionView cellForItemAtIndexPath:indexPath]];
        type = @"熱門推荐";
    }else if (indexPath.section == 4 && _zhuboModels.count > indexPath.row + 28){
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row + 28 cell:[collectionView cellForItemAtIndexPath:indexPath]];
    }else if (indexPath.section == 5 && _zhuboModels.count > indexPath.row + 38){
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row + 38 cell:[collectionView cellForItemAtIndexPath:indexPath]];
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": [NSString stringWithFormat:@"直播详情-%@",type]};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HotCollectionViewCell *cell = (HotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCollectionViewCELL" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.model = _zhuboModels[indexPath.row];
    }else if (indexPath.section == 1 && _zhuboModels.count > indexPath.row + 8){
        cell.model = _zhuboModels[indexPath.row + 8];
    }else if (indexPath.section == 2 && _zhuboModels.count > indexPath.row + 12){
        cell.model = _zhuboModels[indexPath.row + 12];
    }else if (indexPath.section == 3 && _zhuboModels.count > indexPath.row + 20){
        cell.model = _zhuboModels[indexPath.row + 20];
    }else if (indexPath.section == 4 && _zhuboModels.count > indexPath.row + 28){
        cell.model = _zhuboModels[indexPath.row + 28];
    }else if (indexPath.section == 5 && _zhuboModels.count > indexPath.row + 38){
        cell.model = _zhuboModels[indexPath.row + 38];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5 && indexPath.row == (_zhuboModels.count-40) - 4 && !loadingData && collectionView.contentSize.height>collectionView.frame.size.height && isNoMoreDatas == false) {
        [self pullInternet];
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
 layout:(UICollectionViewLayout *)collectionViewLayout
insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(5, 10, 0, 10);//分别为上、左、下、右
}

#pragma mark ================ collectionview头视图 ===============


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 0) {
        return nil;
    }else if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 1) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV1" forIndexPath:indexPath];
        
        header.backgroundColor = [UIColor clearColor];
        __block BOOL isExist = NO;
        [header.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HotCycleBanner class]]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (!isExist) {
            [header addSubview:self.banner_section_0];
            [self.banner_section_0 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(header);
            }];
        }
        return header;
        
    }else if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 2) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV2" forIndexPath:indexPath];
        
        header.backgroundColor = [UIColor clearColor];
        UIView *gameSu = self.gamesView.superview;
        if (gameSu== nil) {
            [header addSubview:self.gamesView];
            [self.gamesView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(header);
            }];
        }
        return header;
        
    }else if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 3) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV3" forIndexPath:indexPath];
        header.backgroundColor = [UIColor clearColor];
        UIView *contrySu = self.countryView.superview;
        if (contrySu== nil) {
            [header addSubview:self.countryView];
            [self.countryView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(header);
            }];
        }
        return header;
    }else if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 4) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"bannerHeaderV_sec5" forIndexPath:indexPath];
        
        header.backgroundColor = [UIColor clearColor];
        __block BOOL isExist = NO;
        [header.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HotCycleBanner class]]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (!isExist) {
            [header addSubview:self.banner_section_5];
            [self.banner_section_5 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(header);
            }];
        }
        return header;
    }else if ([kind isEqualToString:UICollectionElementKindSectionHeader] && indexPath.section == 5) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"bannerHeaderV_sec10" forIndexPath:indexPath];
        
        header.backgroundColor = [UIColor clearColor];
        __block BOOL isExist = NO;
        [header.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HotCycleBanner class]]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (!isExist) {
            [header addSubview:self.banner_section_10];
            [self.banner_section_10 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(header);
            }];
        }
        return header;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(0, 0);
       
    }else if (section == 1) {
        if (_isBannerSection_0) {
            return CGSizeMake(_window_width, (_window_width * 150.0 / 350.0)+5);
        }
    }else if (section == 2) {
        if (_isBannerSection_1) {
            int numPreLine = 4;
            CGFloat marigin = AD(10);
            CGFloat argW = ((_window_width - 5) - (numPreLine + 1) * marigin) / numPreLine;
            CGFloat argH = argW * 5/4;
            CGFloat totalH = argH + AD(30);
            return CGSizeMake(_window_width, totalH+15);
        }
    } else if (section == 3) {
        return CGSizeMake(_window_width, 38);
    } else if (section == 4) {
        if (_isBannerSection_5) {
            return CGSizeMake(_window_width, (_window_width * 150.0 / 350.0)+5);
//            return CGSizeMake(_window_width, (SCREEN_WIDTH - 10)/350.0 * 120 + 10);
        }
    } else if (section == 5) {
        if (_isBannerSection_10) {
            return CGSizeMake(_window_width, (_window_width * 150.0 / 350.0)+5);
//            return CGSizeMake(_window_width, (SCREEN_WIDTH - 10)/350.0 * 120 + 10);
        }
    }
    return CGSizeMake(0, 0);
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    oldOffset = scrollView.contentOffset.y;
//}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    
//    CGFloat statusBarHeight = statusbarHeight/2;
//    CGFloat fixedValue = 64 + statusBarHeight;
//    
//    if (scrollView.contentOffset.y<-28) {
////        _horizontalMarquee.superview.top = (fixedValue-30)-scrollView.contentOffset.y;
////        _horizontalMarquee.superview.alpha = 1;
//    }else{
//        if (scrollView.contentOffset.y < 0) {
//            return;
//        }
//
//        CGFloat currentOffset = scrollView.contentOffset.y;
//        
//        // 判断滑动方向
//        BOOL isScrollingUp = currentOffset > oldOffset;
//                // 如果是往上滑动
//        if (isScrollingUp && scrollView.contentOffset.y != 0) {
//            if (self->_horizontalMarquee.superview.alpha == 0) {
//                return;
//            }
//
//            [UIView animateWithDuration:0.1 animations:^{
//                self->_horizontalMarquee.superview.top  = fixedValue-10;
//                self->_horizontalMarquee.superview.alpha = 0;
//                self.collectionView.mj_y = self->collectionViewTop;
//                self.collectionView.mj_h = self->collectionViewHeight;
//            }];
//        }
//        // 如果是往下滑动
//        else {
//            if (self->_horizontalMarquee.superview.alpha == 1) {
//                return;
//            }
//
//            [UIView animateWithDuration:0.1 animations:^{
//                self->_horizontalMarquee.superview.top =  fixedValue;
//                self->_horizontalMarquee.superview.alpha = 1;
//                self.collectionView.mj_y = self->collectionViewTop + 35.0;
//                self.collectionView.mj_h = self->collectionViewHeight + 35.0;
//            }];
//            
//        }
//        oldOffset = currentOffset;  // 更新旧的contentOffset值
//        
//    }
////    
//    
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"%f",oldOffset);
//}

- (void)jumpRecommend:(UIButton *)sender{
    NSArray* ad_list = [common ad_list];
    
    int adPosIdx = 0;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqual:@"recommend"]){
                if(sender.tag == adPosIdx){
                    NSString *url = [_ad valueForKey:@"dump_url"];
                    // todo 还需要根据plat 做自动转换？？ （提取一个GameHelper做公共方法吧）
                    NSRange range = [url rangeOfString:@"ky206"];
                    if(range.location != NSNotFound){
                       
                        h5game *VC = [[h5game alloc]init];
                        NSString *paths = url;//@"https://play.ky206.com/";
                        //                                        NSString *paths = @"https://shop209793.m.youzan.com/v2/showcase/homepage?alias=jfm4tjis";
                        VC.urls = paths;
                        VC.titles = @"";
                        VC.bHiddenReturnBtn = true;
                        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    }
                    return;
                }
                adPosIdx++;
            }
        }
    }
}
- (void)jumpPopularize:(UIButton *)sender{
    myPopularizeVC *VC = [[myPopularizeVC alloc]init];
    VC.titleStr = YZMsg(@"Hotpage_my_expand");
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
}

//- (void)pushLiveClassVC:(NSDictionary *)dic{
//    classVC *class = [[classVC alloc]init];
//    class.titleStr = minstr([dic valueForKey:@"name"]);
//    class.classID = minstr([dic valueForKey:@"id"]);
//    [[MXBADelegate sharedAppDelegate] pushViewController:class animated:YES];
//    
//}
#pragma mark ================ 隐藏和显示tabbar ===============
- (void)hideTabBar {
    
//    if (self.tabBarController.tabBar.hidden == YES) {
//        return;
//    }
//    self.tabBarController.tabBar.hidden = YES;
//    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
//    ZYTabBar *tabbar = (ZYTabBar *)self.tabBarController.tabBar;
//    tabbar.plusBtn.hidden = YES;
//    tabbarController.bg.hidden = tabbar.plusBtn.hidden;
//    tabbar.kbLabel.hidden = tabbar.plusBtn.hidden;
}
- (void)showTabBar

{
//    if (self.tabBarController.tabBar.hidden == NO)
//    {
//        return;
//    }
//    self.tabBarController.tabBar.hidden = NO;
//    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
//    ZYTabBar *tabbar = (ZYTabBar *)self.tabBarController.tabBar;
//    tabbar.plusBtn.hidden = NO;
//    tabbarController.bg.hidden = tabbar.plusBtn.hidden;
//    tabbar.kbLabel.hidden = tabbar.plusBtn.hidden;
    
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
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"公告"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}
#pragma mark - NewPageFlowViewDelegate

- (void)closeService:(id)sender{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}



@end
