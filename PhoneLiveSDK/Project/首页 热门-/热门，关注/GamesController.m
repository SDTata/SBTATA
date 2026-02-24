//
//  GamesController.m
//  phonelive2
//
//  Created by test on 4/12/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import "GamesController.h"
#import "hotModel.h"
#import "LivePlay.h"
#import "MXBADelegate.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HotCollectionViewCell.h"
#import "ZYTabBar.h"
#import "SDCycleScrollView.h"
#import "HotAndAttentionPreviewLogic.h"
#import "ZYTabBarController.h"
#import "EnterLivePlay.h"
#import "LivePlayTableVC.h"
#import "UIView+UIScreenDisplaying.h"
#import "GamesHeader.h"
#import "AnimRefreshHeader.h"
#import "LobbyLotteryVC_New.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "LotteryBetHallVC.h"
#import <UMCommon/UMCommon.h>

@interface GamesController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,SDCycleScrollViewDelegate,FilterCountryDelegate,GameHeaderDelegate,lotteryBetViewDelegate>
{
    UIView *nothingView;//直播无网络的时候显示
    UILabel *labelFirst;
    UILabel *labelSecond;
    
    UIAlertController *alertController;//邀请码填写
    UITextField *codetextfield;
    NSString *type_val;//
    NSString *livetype;//
    CGFloat oldOffset;
    NSInteger page;
    UIAlertController *md5AlertController;
    YBNoWordView *noNetwork;
    BOOL appearReq;
    NSInteger refrshPage;
    BOOL loadingData;
    
    NSString *regionCurrent;
    CountryFilterModel * selectedModel;
}
@property(nonatomic,strong)NSMutableArray *zhuboModel;//主播模型
@property(nonatomic,strong)GamesHeader *header;
@property(nonatomic,strong)UIView *footer;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSString *MD5;//加密密码
@property(nonatomic,copy)NSDictionary           *lastPlayInfo;  //点击跳转的info数据，用于预览返回之后使用
@property(nonatomic,copy)NSArray           *datas;

@end
static NSString *Reuse_GamesectionHeader = @"reuse_gamessectionheader";
static NSString *Reuse_GamesectionFooter = @"reuse_gamessectionfooter";
@implementation GamesController
//懒加载
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    appearReq = true;
//    if(refrshPage <= 0){
//        refrshPage = 1;
//    }
//    [self pullInternet];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    regionCurrent = [[NSUserDefaults standardUserDefaults]objectForKey:RegionAnchorSelected];
    if (regionCurrent == nil) {
        regionCurrent = @"";
    }
    oldOffset = 0;
    type_val = @"0";
    livetype = @"0";
    page = 1;
    self.zhuboModel = [NSMutableArray array];
    
    self.header = [[GamesHeader alloc]initWithFrame:CGRectMake(AD(0), AD(0), _window_width, AD(90)+[self countHeaderHeight])];
    self.header.delegate = self;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat  itemW = _window_width/2-15;
    CGFloat  itemH = itemW * 8/7;
    flow.itemSize = CGSizeMake(itemW, itemH);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
   
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotCollectionViewCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"HotCollectionViewCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Reuse_GamesectionHeader];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:Reuse_GamesectionFooter];
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    WeakSelf
    AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->page = 1;
        [strongSelf pullInternet];
    }];
    [_collectionView setMj_header:refreshHeader];
//    _collectionView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
//        STRONGSELF
//        if (strongSelf==nil) {
//            return;
//        }
//        strongSelf->page = 1;
//        [strongSelf pullInternet];
//    }];
//    ((MJRefreshGifHeader*)_collectionView.mj_header).stateLabel.textColor = [UIColor clearColor];
////    ((MJRefreshGifHeader*)_collectionView.mj_header).arrowView.tintColor = [UIColor clearColor];
////    ((MJRefreshGifHeader*)_collectionView.mj_header).activityIndicatorViewStyle = UIScrollViewIndicatorStyleDefault;
//    ((MJRefreshGifHeader*)_collectionView.mj_header).lastUpdatedTimeLabel.textColor = [UIColor clearColor];
//    [((MJRefreshGifHeader*)_collectionView.mj_header) setImages:[NSArray array] forState:MJRefreshStateIdle];
//    //2.设置即将刷新状态的动画图片（一松开就会刷新的状态）
//    [((MJRefreshGifHeader*)_collectionView.mj_header) setImages:[NSArray array] forState:MJRefreshStatePulling];
//    //3.设置正在刷新状态的动画图片
//    [((MJRefreshGifHeader*)_collectionView.mj_header) setImages:[NSArray array] forState:MJRefreshStateRefreshing];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf pullInternet];
    }];
    _collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.footer = [self createNonetView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadMoreDataFromPlayList:) name:LivePlayTableVCRequestDataNotifcation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateRemoveMode:) name:LivePlayTableVCUpdateRemoveModelNotifcation object:nil];
    [self pullInternet];
}

- (void)updateRemoveMode:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *roomId = userInfo[@"roomId"];
    for (hotModel *model in _zhuboModel) {
        if ([model.zhuboID isEqualToString:roomId]) {
            [_zhuboModel removeObject:model];
            break;
        }
    }
    [self.collectionView reloadData];
}

- (CGFloat)countHeaderHeight{
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
    float avgW = 0;
    float imgBtnW = _window_width;//inviteImageBtn.width;
    if(gameCount > 0){
        avgW = (imgBtnW-5) / MIN(numPreLine, (gameCount + 1));
        if(avgW > 80){
            avgW = 80;
        }
    }else{
        avgW = -79;
    }
    
    float avgH = ceil(1.0*gameCount/numPreLine) * (avgW + 30) + 20;
    return avgH;
}

-(void)loadMoreDataFromPlayList:(NSNotification*)notify
{
    NSDictionary *subDic = (NSDictionary*)notify.userInfo;
    NSNumber *numberIndex  = (NSNumber*)[subDic objectForKey:@"zhubo_id"];
    if (numberIndex==nil) {
        return;
    }
    if (numberIndex.intValue < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:numberIndex.intValue inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
       
        
        if (numberIndex.intValue == (_zhuboModel.count-2) && self.zhuboModel!=nil && self.zhuboModel.count>0 && [self.view isDisplayedInScreen]) {
            if (!loadingData) {
                [self pullInternet];
            }
        }
    }
     
}

-(UIView *)createNonetView{
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    footer.backgroundColor = [UIColor clearColor];
    //    bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 90, _window_width, 180) imageURLStringsGroup:nil];
    //    bannerScrollView.delegate = self;
    //    [self.view addSubview:bannerScrollView];
    
    nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    nothingView.hidden = YES;
    nothingView.backgroundColor = [UIColor clearColor];
    [footer addSubview:nothingView];
    labelFirst = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 20)];
    labelFirst.font = [UIFont systemFontOfSize:14];
    //    labelFirst.text = YZMsg(@"附近没有主播开播");
    labelFirst.textAlignment = NSTextAlignmentCenter;
    labelFirst.textColor = RGB_COLOR(@"#333333", 1);
    [nothingView addSubview:labelFirst];
    labelSecond = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, _window_width, 20)];
    labelSecond.font = [UIFont systemFontOfSize:13];
    //    labelSecond.text = YZMsg(@"去首页看看其他主播的直播吧～");
    labelSecond.textAlignment = NSTextAlignmentCenter;
    labelSecond.textColor = RGB_COLOR(@"#969696", 1);
    [nothingView addSubview:labelSecond];
    /*
    noNetwork = [[YBNoWordView alloc]initWithImageName:NULL andTitle:NULL withBlock:^(id  _Nullable msg) {
        STRONGSELF
        [strongSelf pullInternet];
    } AddTo:self.view];
     */
    return footer;
}
static BOOL isNoMoreOtherDatas;
-(void)pullInternet{
    NSString *endPointUrl = @"Home.getLiveListByType";
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"p":@(appearReq?refrshPage:page)}];
    [param setValue:minnum(1) forKey:@"type"];
    [param setObject:regionCurrent forKey:@"region"];
    loadingData = YES;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:endPointUrl withBaseDomian:YES andParameter:param data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->loadingData = NO;
        strongSelf->refrshPage = strongSelf->appearReq?strongSelf->refrshPage:strongSelf->page;
        strongSelf->noNetwork.hidden = YES;
        if (code == 0) {
            NSArray *infoList = [[info firstObject] valueForKey:@"list"];
            NSDictionary *infoDics = [info firstObject];
            
            strongSelf.datas = [CountryFilterModel mj_objectArrayWithKeyValuesArray:infoDics[@"live_support_regions"]];
            strongSelf->selectedModel = [CountryFilterModel mj_objectWithKeyValues:infoDics[@"live_current_region"]];
            strongSelf->regionCurrent = strongSelf->selectedModel.countryCode;
            
            [strongSelf updateCountry];
            if (strongSelf->page == 1) {
                isNoMoreOtherDatas = NO;
                [strongSelf.zhuboModel removeAllObjects];
            }else if(strongSelf->appearReq){
//                [strongSelf.zhuboModel removeObjectsInRange:NSMakeRange(strongSelf.zhuboModel.count-infoList.count, infoList.count)];
            }
            for (NSDictionary *dic in infoList) {
                hotModel *model = [hotModel mj_objectWithKeyValues:dic];
                if(strongSelf.zhuboModel.count>0 && strongSelf->page>1){
                    ///去重复
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"zhuboID CONTAINS[cd] %@" ,model.zhuboID];
                    NSArray *arrays = [strongSelf.zhuboModel filteredArrayUsingPredicate:predicate];
                    if(arrays.count>0){
                        continue;
                    }
                }
                [strongSelf.zhuboModel addObject:model];
            }
            if(infoList.count>0){
                strongSelf->page = strongSelf->refrshPage + 1;
            }
//            strongSelf->appearReq = false;
            
            if (strongSelf.zhuboModel.count == 0) {
                if (![PublicObj  checkNull: minstr([[info firstObject] valueForKey:@"title"])]) {
                    strongSelf->labelFirst.text = minstr([[info firstObject] valueForKey:@"title"]);
                }else{
                    strongSelf->labelFirst.text = YZMsg(@"GamesVC_NoGameAnchor");
                }
                if (![PublicObj  checkNull: minstr([[info firstObject] valueForKey:@"des"])]) {
                    strongSelf->labelSecond.text = minstr([[info firstObject] valueForKey:@"des"]);
                }else{
                    strongSelf->labelSecond.text = YZMsg(@"GamesVC_SeeOthersGameAnchor");
                }
                
                strongSelf->nothingView.hidden = NO;
            }else{
                strongSelf->nothingView.hidden = YES;
            }
            [strongSelf.collectionView.mj_header endRefreshing];
            [strongSelf.collectionView.mj_footer endRefreshing];
            [strongSelf.collectionView reloadData];
            
            if ([infoList count] <= 0) {
                isNoMoreOtherDatas = YES;
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCUpdateNotifcation object:nil];
            }
            NSDictionary *userInfo = @{@"models": [NSArray arrayWithArray:strongSelf.zhuboModel]};
            [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCUpdateModelsNotifcation object:nil userInfo:userInfo];
        }else{
            [strongSelf.collectionView.mj_header endRefreshing];
            [strongSelf.collectionView.mj_footer endRefreshing];
            if (strongSelf.zhuboModel.count == 0) {
                strongSelf->nothingView.hidden = NO;
            }else{
                strongSelf->nothingView.hidden = YES;
            }
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];
        [strongSelf.collectionView.mj_footer endRefreshing];
        strongSelf->nothingView.hidden = YES;
        if (strongSelf.zhuboModel.count == 0) {
            strongSelf->noNetwork.hidden = NO;
        }
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@_10004",YZMsg(@"public_networkError")]];
    }];
    
    
   
}


-(void)countryModelSelected:(CountryFilterModel *)model
{
    selectedModel = model;
    regionCurrent = model.countryCode;
    [[NSUserDefaults standardUserDefaults]setObject:regionCurrent forKey:RegionAnchorSelected];
    [[NSUserDefaults standardUserDefaults]synchronize];
    page = 1;
    [self pullInternet];
    [self updateCountry];
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
 layout:(UICollectionViewLayout *)collectionViewLayout
insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(5, 10, 0, 10);//分别为上、左、下、右
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _zhuboModel.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModel index:indexPath.row cell:[collectionView cellForItemAtIndexPath:indexPath]];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"游戏-热门"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}
-(void)jumpToGameType:(NSDictionary*)gameDic
{
    NSString *plat = gameDic[@"plat"];
    NSString *kid = gameDic[@"kindID"];
    NSString *urlName = gameDic[@"urlName"];
    [GameToolClass enterGame:plat menueName:@"" kindID:kid iconUrlName:urlName parentViewController: self autoExchange:[common getAutoExchange]  success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        
    } fail:^{
        
    }];
//    
//    if(index == 26){
//        LotteryCenterBetViewController_YFKS *VC = [[LotteryCenterBetViewController_YFKS alloc]initWithNibName:@"LotteryCenterBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//        [VC setLotteryType:index];
//        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//    }else if(index == 28){
//        LotteryCenterBetViewController_BJL *VC = [[LotteryCenterBetViewController_BJL alloc]initWithNibName:@"LotteryCenterBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//        [VC setLotteryType:index];
//        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//    }else if(index == 29){
//        LotteryCenterBetViewController_ZJH *VC = [[LotteryCenterBetViewController_ZJH alloc]initWithNibName:@"LotteryCenterBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//        [VC setLotteryType:index];
//        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//    }else if(index == 30){
//        LotteryCenterBetViewController_ZP *VC = [[LotteryCenterBetViewController_ZP alloc]initWithNibName:@"LotteryCenterBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//        [VC setLotteryType:index];
//        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//    }else if(index == 31){
//        LotteryCenterBetViewController_LH *VC = [[LotteryCenterBetViewController_LH alloc]initWithNibName:@"LotteryCenterBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//        [VC setLotteryType:index];
//        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
//    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"游戏-游戏"};
    [MobClick event:@"live_home_detail_click" attributes:dict];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HotCollectionViewCell *cell = (HotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCollectionViewCELL" forIndexPath:indexPath];
    cell.model = _zhuboModel[indexPath.row];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _zhuboModel.count - 4 && !loadingData && collectionView.contentSize.height>collectionView.frame.size.height && isNoMoreOtherDatas == false) {
        [self pullInternet];
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *view;
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:Reuse_GamesectionHeader forIndexPath:indexPath];
        [view addSubview:self.header];
        return view;
    }else{
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:Reuse_GamesectionFooter forIndexPath:indexPath];
        [view addSubview:self.footer];
        return view;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    return CGSizeMake(_window_width, AD(90)+[self countHeaderHeight]);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (_zhuboModel.count > 0) {
        return CGSizeMake(_window_width, 0);
    }else{
        return CGSizeMake(_window_width, 40);
    }
}
#pragma mark ================ socrollview代理 ===============
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    oldOffset = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView.contentOffset.y > oldOffset) {
//        if (scrollView.contentOffset.y > 0) {
//            _pageView.hidden = YES;
//            [self hideTabBar];
//        }
//    }else{
//        _pageView.hidden = NO;
//        [self showTabBar];
//    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%f",oldOffset);
}
#pragma mark ================ 隐藏和显示tabbar ===============
- (void)hideTabBar {
    
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    self.tabBarController.tabBar.hidden = YES;
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    ZYTabBar *tabbar = (ZYTabBar *)self.tabBarController.tabBar;
    tabbar.plusBtn.hidden = YES;
    tabbarController.bg.hidden = tabbar.plusBtn.hidden;
    tabbar.kbLabel.hidden = tabbar.plusBtn.hidden;
}
- (void)showTabBar

{
    if (self.tabBarController.tabBar.hidden == NO)
    {
        return;
    }
    self.tabBarController.tabBar.hidden = NO;
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    ZYTabBar *tabbar = (ZYTabBar *)self.tabBarController.tabBar;
    tabbar.plusBtn.hidden = NO;
    tabbarController.bg.hidden = tabbar.plusBtn.hidden;
    tabbar.kbLabel.hidden = tabbar.plusBtn.hidden;
    
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    //    if(adBannerInfoArr.count > index)
    //    {
    //        NSDictionary *infoDic = [adBannerInfoArr objectAtIndex:index];
    //
    //        if([infoDic objectForKey:@"url"])
    //        {
    //            NSString *urlStr = [infoDic objectForKey:@"url"];
    //
    //            if([urlStr length] > 0)
    //            {
    //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    //            }
    //        }
    //    }
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
@end
