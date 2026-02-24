#import "AttentionController.h"
#import "AttentionHeader.h"
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
#import "AnimRefreshHeader.h"

@interface AttentionController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,SDCycleScrollViewDelegate>
{
    UILabel *labelFirst;
    UILabel *labelSecond;
    UIAlertController *alertController;//邀请码填写
    UITextField *codetextfield;
    NSString *type_val;//
    NSString *livetype;//
    CGFloat oldOffset;
    NSInteger page;
    UIAlertController *md5AlertController;
    BOOL appearReq;
    NSInteger refrshPage;
    BOOL loadingData;
    //    SDCycleScrollView *bannerScrollView;
    //    NSArray           *adBannerInfoArr;
}
@property(nonatomic,strong)NSMutableArray *zhuboModels;//主播模型
@property(nonatomic,strong)NSMutableArray *zhuboModel;//主播模型
@property(nonatomic,strong)AttentionHeader *attentionHeader;//关注组头
@property(nonatomic,strong)AttentionHeader *hotHeader;//热点组头
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSString *MD5;//加密密码
@property(nonatomic,copy)NSDictionary *lastPlayInfo;  //点击跳转的info数据，用于预览返回之后使用
@end
static NSString *Reuse_AttentionSectionHeader = @"reuse_attentionsectionheader";
@implementation AttentionController
//懒加载
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

//    if(refrshPage <= 0){
//        refrshPage = 1;
////    }
//    [self pullInternet];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    oldOffset = 0;
    type_val = @"0";
    livetype = @"0";
    page = 1;
    self.zhuboModel = [NSMutableArray array];
    self.attentionHeader = [[AttentionHeader alloc] initWithSourceType:1001 noNetHandler:^{
        [self pullInternet];
    }];
    self.hotHeader = [[AttentionHeader alloc] initWithSourceType:1002 noNetHandler:^{
        [self pullInternet];
    }];
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
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Reuse_AttentionSectionHeader];
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
//    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        STRONGSELF
//        if (strongSelf==nil) {
//            return;
//        }
//        strongSelf->page = 1;
//        [strongSelf pullInternet];
//    }];
//    ((MJRefreshNormalHeader*)_collectionView.mj_header).stateLabel.textColor = [UIColor clearColor];
//    ((MJRefreshNormalHeader*)_collectionView.mj_header).arrowView.tintColor = [UIColor clearColor];
//    ((MJRefreshNormalHeader*)_collectionView.mj_header).activityIndicatorViewStyle = UIScrollViewIndicatorStyleDefault;
//    ((MJRefreshNormalHeader*)_collectionView.mj_header).hidden = 0;
//    [((MJRefreshNormalHeader*)_collectionView.mj_header) setImages:[NSArray array] forState:MJRefreshStateIdle];
//    //2.设置即将刷新状态的动画图片（一松开就会刷新的状态）
//    [((MJRefreshNormalHeader*)_collectionView.mj_header) setImages:NSArray array] forState:MJRefreshStatePulling];
//    //3.设置正在刷新状态的动画图片
//    [((MJRefreshNormalHeader*)_collectionView.mj_header) setImages:NSArray array] forState:MJRefreshStateRefreshing];
//    ((MJRefreshNormalHeader*)_collectionView.mj_header).lastUpdatedTimeLabel.textColor = [UIColor clearColor];
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
//    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadMoreDataFromPlayList:) name:LivePlayTableVCRequestDataNotifcation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateRemoveMode:) name:LivePlayTableVCUpdateRemoveModelNotifcation object:nil];
    [self pullInternet];
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

-(void)loadMoreDataFromPlayList:(NSNotification*)notify
{
    NSNumber *numberIndex = [(NSDictionary*)notify.userInfo objectForKey:@"zhubo_id"];
    if (numberIndex==nil) {
        return;
    }
    if(numberIndex.intValue<self.zhuboModel.count &&  numberIndex.intValue == self.zhuboModel.count-2){
        if (self.zhuboModel!=nil && self.zhuboModel.count>0 && [self.view isDisplayedInScreen]) {
            if (!loadingData) {
                [self pullInternet];
            }
        }
    }else  if(numberIndex.intValue<self.zhuboModels.count &&  numberIndex.intValue == self.zhuboModels.count-2){
        if (self.zhuboModels!=nil && self.zhuboModels.count>0 && [self.view isDisplayedInScreen]) {
            if (!loadingData) {
                [self pullInternet];
            }
        }
    }
    
    
    
     
}

static BOOL isNoMoreOtherDatas;
-(void)pullInternet{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{@"p":@(appearReq?refrshPage:page)}];
    loadingData = YES;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getFollow" withBaseDomian:YES andParameter:param data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->loadingData = NO;
        strongSelf->refrshPage = strongSelf->appearReq?strongSelf->refrshPage:strongSelf->page;
        if (code == 0) {
            NSArray *infoList = [[info firstObject] valueForKey:@"list"];
            if (strongSelf->page == 1) {
                isNoMoreOtherDatas = NO;
                [strongSelf.zhuboModel removeAllObjects];
            }else if(strongSelf->appearReq){
                //                    [strongSelf.zhuboModel removeObjectsInRange:NSMakeRange(strongSelf.zhuboModel.count-infoList.count, infoList.count)];
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
            //                strongSelf->appearReq = false;
            if ([infoList count] <= 0) {
                isNoMoreOtherDatas = YES;
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCUpdateNotifcation object:nil];
            }
        }
        [strongSelf getHotPage];
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf getHotPage];
    }];
}
-(void)getHotPage{
    WeakSelf
    NSString *regionSelected = [[NSUserDefaults standardUserDefaults] objectForKey:RegionAnchorSelected];
    if (regionSelected == nil) {
        regionSelected =@"";
    }
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getHot" withBaseDomian:YES andParameter:@{@"p":@(1),@"region":regionSelected} data:nil success:^(int code,id info,NSString *msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if (code == 0) {
            if(![info isKindOfClass:[NSArray class]]|| [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSArray *infoA = [info objectAtIndex:0];
            NSArray *list = [infoA valueForKey:@"list"];
            [strongSelf.zhuboModels removeAllObjects];
            for (NSDictionary *dic in list) {
                hotModel *model = [hotModel mj_objectWithKeyValues:dic];
                [strongSelf.zhuboModels addObject:model];
            }
            if (list.count == 0) {
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCUpdateNotifcation object:nil];
            }
        }
       
        [MBProgressHUD hideHUD];
        [strongSelf.collectionView.mj_header endRefreshing];
        [strongSelf.collectionView.mj_footer endRefreshing];
        [strongSelf.collectionView reloadData];
        [strongSelf.attentionHeader reloadDatas:self.zhuboModel];
        [strongSelf.hotHeader reloadDatas:self.zhuboModels];
        NSLog(@"任务完成");
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf.collectionView.mj_header endRefreshing];
        [strongSelf.collectionView.mj_footer endRefreshing];
        [strongSelf.collectionView reloadData];
        [strongSelf.attentionHeader reloadDatas:self.zhuboModel];
        [strongSelf.hotHeader reloadDatas:self.zhuboModels];
    }];
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
 layout:(UICollectionViewLayout *)collectionViewLayout
insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(5, 10, 0, 10);//分别为上、左、下、右
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return _zhuboModel.count;
    }else{
        return _zhuboModels.count;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModel index:indexPath.row cell:[collectionView cellForItemAtIndexPath:indexPath]];
    }else{
        [[EnterLivePlay sharedInstance]showLivePlayFromModels:_zhuboModels index:indexPath.row cell:[collectionView cellForItemAtIndexPath:indexPath]];
    }
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HotCollectionViewCell *cell = (HotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotCollectionViewCELL" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.model = _zhuboModel[indexPath.row];
    }else{
        cell.model = _zhuboModels[indexPath.row];
    }
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *view;
    if (kind == UICollectionElementKindSectionHeader) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:Reuse_AttentionSectionHeader forIndexPath:indexPath];
        if (indexPath.section == 0) {
            [view addSubview:self.attentionHeader];
        }else{
            [view addSubview:self.hotHeader];
        }
    }else{
        view = [[UICollectionReusableView alloc]init];
    }
    return view;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (_zhuboModel.count == 0) {
            return CGSizeMake(_window_width, AD(150));
        }
    }else{
        if (_zhuboModels.count == 0) {
            return CGSizeMake(_window_width, AD(150));
        }
    }
    return CGSizeMake(_window_width, AD(57));
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == _zhuboModel.count - 4 && !loadingData && collectionView.contentSize.height>collectionView.frame.size.height && isNoMoreOtherDatas == false) {
            [self pullInternet];
        }
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

#pragma mark - lazy load -
- (NSMutableArray *)zhuboModels{
    if (!_zhuboModels) {
        _zhuboModels = [NSMutableArray array];
    }
    return _zhuboModels;
}
@end
