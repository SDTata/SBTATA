//
//  RecommendMainVC.m
//  phonelive2
//
//  Created by user on 2024/7/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "RecommendMainVC.h"
#import "HomeMoreSectionHeaderView.h"
#import "HomeSectionKindShortVideoCell.h"
#import "HomeSectionKindLotteryCell.h"
#import "HomeSectionKindLongVideoCell.h"
#import "HomeSectionKindCarouselCell.h"
#import "HomeSectionKindLiveStreamingCell.h"
#import "HomeSectionKindSkitCell.h"
#import "HomeCommonListViewController.h"
#import "HomeContainer.h"
#import "ZYTabBarController.h"
#import "ShortVideosContainer.h"
#import "AnimRefreshHeader.h"
// model
#import "HomeRecommendModel.h"
#import "LivePlayTableVC.h"

typedef NS_ENUM(NSInteger, HomeSectionKind) {
    HomeSectionKindShortVideo,//短視頻
    HomeSectionKindLottery,//彩票
    HomeSectionKindLongVideo,//長視頻
    HomeSectionKindCarousel,//輪播
    HomeSectionKindLiveStreaming,//直播
    HomeSectionKindSkit,//短劇
    HomeSectionKindGames,//鏈遊
};

@interface RecommendSectionModel ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) id model;
@property (nonatomic, assign) HomeSectionKind type;
@end
@implementation RecommendSectionModel
@end

@interface RecommendMainVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HomeSectionKindShortVideoCellDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray<RecommendSectionModel*> *sectionModels;

@end

@implementation RecommendMainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLivePlay:) name:@"KNoticeShowLivePlay" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateRemoveMode:) name:LivePlayTableVCUpdateRemoveModelNotifcation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoLike:) name:@"updateShortVideoLike" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSkitFavorite:) name:@"updateSkitFavorite" object:nil];

    [self setupViews];
    [self refresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startInfinite:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self startInfinite:NO];
}

- (void)appDidEnterBackground {
    [self startInfinite:NO];
}

- (void)appWillEnterForeground {
    [self startInfinite:YES];
}

- (void)startInfinite:(BOOL)isStart {
    for (int i = 0; i<self.sectionModels.count; i++) {
        RecommendSectionModel *sectionModel = self.sectionModels[i];
        if (sectionModel.type == HomeSectionKindCarousel) {
            HomeSectionKindCarouselCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            if ([cell isKindOfClass:[HomeSectionKindCarouselCell class]]) {
                if (isStart) {
                    [cell startAutoScroll];
                } else {
                    [cell stopAutoScroll];
                }
            }
        }
    }
}

- (void)handleRefresh {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)changeCategory:(HomeSectionKind)type {
    if (![self.superPagerVC.superPagerVC isKindOfClass:[HomeContainer class]]) {
        return;
    }
    HomeContainer *container = (HomeContainer*)self.superPagerVC.superPagerVC;
    switch (type) {
        case HomeSectionKindShortVideo:
        {
            ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
            if (![tabbarController changeTab:ZYTabBarControllerTypeShortVideo]) {
                [container changeCategory:HomeContainerTypeShortVideo];
            }
        }
            break;
        case HomeSectionKindLongVideo:
            [container changeCategory:HomeContainerTypeLongVideo];
            break;
        case HomeSectionKindSkit:
            [container changeCategory:HomeContainerTypeShortSkit];
            break;
        default:
            break;
    }
}

#pragma mark - UI
- (void)setupViews {
    self.view.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (UICollectionView *)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;

    [collectionView registerClass:[HomeSectionKindSkitCell class] forCellWithReuseIdentifier:@"HomeSectionKindSkitCell"];
    [collectionView registerClass:[HomeSectionKindShortVideoCell class] forCellWithReuseIdentifier:@"HomeSectionKindShortVideoCell"];
    [collectionView registerClass:[HomeSectionKindLotteryCell class] forCellWithReuseIdentifier:@"HomeSectionKindLotteryCell"];
    [collectionView registerClass:[HomeSectionKindLongVideoCell class] forCellWithReuseIdentifier:@"HomeSectionKindLongVideoCell"];
    [collectionView registerClass:[HomeSectionKindCarouselCell class] forCellWithReuseIdentifier:@"HomeSectionKindCarouselCell"];
    [collectionView registerClass:[HomeSectionKindLiveStreamingCell class] forCellWithReuseIdentifier:@"HomeSectionKindLiveStreamingCell"];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [collectionView registerClass:[HomeMoreSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HomeMoreSectionHeaderView"];

    WeakSelf
    AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf requestAPI];
    }];

    [collectionView setMj_header:refreshHeader];
    /*
     collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
     STRONGSELF
     if (strongSelf == nil) {
     return;
     }
     [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
     }];
     */
    return collectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

#pragma mark - API
- (void)requestAPI {
    NSString *regionSelected = [[NSUserDefaults standardUserDefaults] objectForKey:RegionAnchorSelected];
    if (regionSelected == nil) {
        regionSelected =@"";
    }

    NSDictionary *dic = @{
        @"region": regionSelected
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getHomeRecommend" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (code == 0 && [info isKindOfClass:[NSArray class]]) {
            [strongSelf resetData:info];
            [common saveHomeRecommendData:info];
        } else {
            [MBProgressHUD showError:msg];
        }
        [strongSelf.collectionView.mj_header endRefreshing];
        //[strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];
        //[strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
    }];
}

- (void)resetData:(NSArray*)infoDic {
    NSMutableArray<RecommendSectionModel*> *sectionModels = [NSMutableArray array];

    for (NSDictionary *dic in infoDic) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSString *className = minstr(dic[@"class"]);
        NSString *titleName = minstr(dic[@"title"]);
        NSString *titleIcon = minstr(dic[@"icon"]);
        RecommendSectionModel *sectionModel = [[RecommendSectionModel alloc] init];
        sectionModel.title = titleName;
        sectionModel.icon = titleIcon;
        if ([className isEqualToString:@"ads"]) {
            HomeRecommendAdsModel *model = [HomeRecommendAdsModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindCarousel;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        } else if ([className isEqualToString:@"game"]) {
            HomeRecommendLotteriesModel *model = [HomeRecommendLotteriesModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindGames;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        } else if ([className isEqualToString:@"live"]) {
            HomeRecommendLiveModel *model = [HomeRecommendLiveModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindLiveStreaming;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        } else if ([className isEqualToString:@"long_video"]) {
            HomeRecommendLongVideoModel *model = [HomeRecommendLongVideoModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindLongVideo;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        } else if ([className isEqualToString:@"lottery"]) {
            HomeRecommendLotteriesModel *model = [HomeRecommendLotteriesModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindLottery;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        } else if ([className isEqualToString:@"short_video"]) {
            HomeRecommendShortVideoModel *model = [HomeRecommendShortVideoModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindShortVideo;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        } else if ([className isEqualToString:@"skit"]) {
            HomeRecommendSkitModel *model = [HomeRecommendSkitModel mj_objectWithKeyValues:dic];
            sectionModel.model = model;
            sectionModel.type = HomeSectionKindSkit;
            if (model.data.count > 0) {
                [sectionModels addObject:sectionModel];
            }
        }
    }

    self.sectionModels = sectionModels;
    [self.collectionView reloadData];
}

#pragma mark - Action
- (void)refresh {
    NSArray *datas = [common getHomeRecommendData];
    if (datas != nil && datas.count > 0) {
        [self resetData:datas];
    } else {
        [self requestAPI];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionModels.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendSectionModel *sectionModel = self.sectionModels[indexPath.section];
    switch (sectionModel.type) {
        case HomeSectionKindShortVideo:
        {
            HomeSectionKindShortVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindShortVideoCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            cell.delegate = self;
            return cell;
        }
            break;
        case HomeSectionKindLottery:
        {
            HomeSectionKindLotteryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindLotteryCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            return cell;
        }
            break;
        case HomeSectionKindLongVideo:
        {
            HomeSectionKindLongVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindLongVideoCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            return cell;
        }
            break;
        case HomeSectionKindCarousel:
        {
            HomeSectionKindCarouselCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindCarouselCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            return cell;
        }
            break;
        case HomeSectionKindLiveStreaming:
        {
            HomeSectionKindLiveStreamingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindLiveStreamingCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            return cell;
        }
            break;
        case HomeSectionKindSkit:
        {
            HomeSectionKindSkitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindSkitCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            return cell;
        }
            break;
        case HomeSectionKindGames:
        {
            HomeSectionKindLotteryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindLotteryCell" forIndexPath:indexPath];
            [cell update:sectionModel.model];
            return cell;
        }
            break;
        default:
            break;
    }

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HomeMoreSectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HomeMoreSectionHeaderView" forIndexPath:indexPath];

    RecommendSectionModel *sectionModel = self.sectionModels[indexPath.section];
    NSString *title = sectionModel.title;
    NSString *icon = sectionModel.icon;
    WeakSelf
    switch (sectionModel.type) {
        case HomeSectionKindShortVideo:
        {
            [view updateForIcon:icon title:title placeholder:@"HomeHeaderShortVideoIcon" block:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf changeCategory:HomeSectionKindShortVideo];
            }];
        }
            break;
        case HomeSectionKindLottery:
        {
            [view updateForIcon:icon title:title placeholder:@"HomeHeaderLotteryIcon" block:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                ZYTabBarController *tabbarController = (ZYTabBarController *)strongSelf.tabBarController;
                [tabbarController changeTab:ZYTabBarControllerTypeGamepage];
            }];
        }
            break;
        case HomeSectionKindLongVideo:
        {
            [view updateForIcon:icon title:title placeholder:@"HomeHeaderLongVideoIcon" block:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf changeCategory:HomeSectionKindLongVideo];
            }];
        }
            break;
        case HomeSectionKindCarousel:
            break;
        case HomeSectionKindLiveStreaming:
        {
            [view updateForIcon:icon title:title placeholder:@"HomeHeaderLiveStreamIcon" block:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                ZYTabBarController *tabbarController = (ZYTabBarController *)strongSelf.tabBarController;
                [tabbarController changeTab:ZYTabBarControllerTypeLive];
            }];
        }
            break;
        case HomeSectionKindSkit:
        {
            [view updateForIcon:icon title:title placeholder:@"HomeHeaderSkitIcon" block:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf changeCategory:HomeSectionKindSkit];
            }];
        }
            break;
        case HomeSectionKindGames:
        {
            [view updateForIcon:icon title:title placeholder:@"HomeHeaderGameIcon" block:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                ZYTabBarController *tabbarController = (ZYTabBarController *)strongSelf.tabBarController;
                [tabbarController changeTab:ZYTabBarControllerTypeGamepage];
            }];
        }
            break;
        default:
            break;
    }
    return view;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendSectionModel *sectionModel = self.sectionModels[indexPath.section];
    switch (sectionModel.type) {
        case HomeSectionKindShortVideo:
            break;
        case HomeSectionKindSkit:
            break;
        case HomeSectionKindLottery:
            break;
        case HomeSectionKindGames:
            break;
        case HomeSectionKindLongVideo:
            break;
        case HomeSectionKindLiveStreaming:
            break;
        case HomeSectionKindCarousel:
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendSectionModel *sectionModel = self.sectionModels[indexPath.section];

    switch (sectionModel.type) {
        case HomeSectionKindShortVideo:
        {
            CGFloat height = HomeSectionKindShortVideoCell.height;
            HomeRecommendShortVideoModel *infoModel = (HomeRecommendShortVideoModel*)sectionModel.model;
            if (![infoModel isKindOfClass:[HomeRecommendShortVideoModel class]]) {
                return CGSizeZero;
            }
            if (infoModel.isScroll == NO) {
                CGFloat width = (_window_width - ((infoModel.layout_column - 1) * HomeSectionKindShortVideoContentViewCell.minimumLineSpacing) - 30)/infoModel.layout_column;
                int minRow = MIN(infoModel.layout_row, ceil((float)infoModel.data.count / infoModel.layout_column));
                height = width * HomeSectionKindShortVideoContentViewCell.ratio * minRow + 10 * (minRow - 1);
                if (minRow <= 0) {
                    height = 0;
                }
            }
            return CGSizeMake(CGRectGetWidth(collectionView.frame), height);
        }
        case HomeSectionKindLottery:
        case HomeSectionKindGames:
        {
            CGFloat height = HomeSectionKindLotteryCell.height;
            HomeRecommendLotteriesModel *infoModel = (HomeRecommendLotteriesModel*)sectionModel.model;
            if (![infoModel isKindOfClass:[HomeRecommendLotteriesModel class]]) {
                return CGSizeZero;
            }
            if (infoModel.isScroll == NO) {
                CGFloat width = (_window_width - ((infoModel.layout_column - 1) * HomeSectionKindLotteryContentViewCell.minimumLineSpacing) - 30)/infoModel.layout_column;
                int minRow = MIN(infoModel.layout_row, ceil((float)infoModel.data.count / infoModel.layout_column));
                height = width * HomeSectionKindLotteryContentViewCell.ratio * minRow + 10 * (minRow - 1);
                if (minRow <= 0) {
                    height = 0;
                }
            }
            return CGSizeMake(CGRectGetWidth(collectionView.frame), height);
        }
        case HomeSectionKindLongVideo:
        {
            CGFloat height = HomeSectionKindLongVideoCell.height;
            HomeRecommendLongVideoModel *infoModel = (HomeRecommendLongVideoModel*)sectionModel.model;
            if (![infoModel isKindOfClass:[HomeRecommendLongVideoModel class]]) {
                return CGSizeZero;
            }
            if (infoModel.isScroll == NO) {
                CGFloat width = (_window_width - ((infoModel.layout_column - 1) * LongVideoCell.minimumLineSpacing) - 30)/infoModel.layout_column;
                int minRow = MIN(infoModel.layout_row, ceil((float)infoModel.data.count / infoModel.layout_column));
                height = width * LongVideoCell.ratio * minRow + 10 * (minRow - 1);
                if (minRow <= 0) {
                    height = 0;
                }
            }
            return CGSizeMake(CGRectGetWidth(collectionView.frame), height);
        }
        case HomeSectionKindCarousel:
            return CGSizeMake(CGRectGetWidth(collectionView.frame), HomeSectionKindCarouselCell.height);
        case HomeSectionKindLiveStreaming:
        {
            CGFloat height = HomeSectionKindLiveStreamingCell.height;
            HomeRecommendLiveModel *infoModel = (HomeRecommendLiveModel*)sectionModel.model;
            if (![infoModel isKindOfClass:[HomeRecommendLiveModel class]]) {
                return CGSizeZero;
            }
            if (infoModel.isScroll == NO) {
                CGFloat width = (_window_width - ((infoModel.layout_column - 1) * HotCollectionViewCell.minimumLineSpacing) - 30)/infoModel.layout_column;
                int minRow = MIN(infoModel.layout_row, ceil((float)infoModel.data.count / infoModel.layout_column));
                height = width * HotCollectionViewCell.ratio * minRow + 10 * (minRow - 1);
                if (minRow <= 0) {
                    height = 0;
                }
            }
            return CGSizeMake(CGRectGetWidth(collectionView.frame), height);
        }
        case HomeSectionKindSkit:
        {
            CGFloat height = HomeSectionKindShortVideoCell.height;
            HomeRecommendSkitModel *infoModel = (HomeRecommendSkitModel*)sectionModel.model;
            if (![infoModel isKindOfClass:[HomeRecommendSkitModel class]]) {
                return CGSizeZero;
            }
            if (infoModel.isScroll == NO) {
                CGFloat width = (_window_width - ((infoModel.layout_column - 1) * HomeSectionKindSkitContentViewCell.minimumLineSpacing) - 30)/infoModel.layout_column;
                int minRow = MIN(infoModel.layout_row, ceil((float)infoModel.data.count / infoModel.layout_column));
                height = width * HomeSectionKindSkitContentViewCell.ratio * minRow + 10 * (minRow - 1);
                if (minRow <= 0) {
                    height = 0;
                }
            }
            return CGSizeMake(CGRectGetWidth(collectionView.frame), height);
        }
        default:
            return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    RecommendSectionModel *sectionModel = self.sectionModels[section];
    switch (sectionModel.type) {
        case HomeSectionKindShortVideo:
        case HomeSectionKindSkit:
        case HomeSectionKindLottery:
        case HomeSectionKindGames:
        case HomeSectionKindLongVideo:
        case HomeSectionKindLiveStreaming:
            return UIEdgeInsetsMake(6, 0, 10, 0);
        case HomeSectionKindCarousel:
            return UIEdgeInsetsMake(0, 0, 10, 0);
        default:
            return UIEdgeInsetsZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    RecommendSectionModel *sectionModel = self.sectionModels[section];
    switch (sectionModel.type) {
        case HomeSectionKindShortVideo:
        case HomeSectionKindSkit:
        case HomeSectionKindLottery:
        case HomeSectionKindGames:
        case HomeSectionKindLongVideo:
        case HomeSectionKindLiveStreaming:
            return CGSizeMake(CGRectGetWidth(collectionView.frame), 22);
        case HomeSectionKindCarousel:
            return CGSizeZero;
        default:
            return CGSizeZero;
    }
}

#pragma mark - HomeSectionKindShortVideoCellDelegate
- (void)homeSectionKindShortVideoCellDelegateForHotGotoShortVideo:(ShortVideoModel*)model {
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    if ([tabbarController changeTab:ZYTabBarControllerTypeShortVideo]) {
        UIViewController *vc = [tabbarController getTabController:ZYTabBarControllerTypeShortVideo];
        if ([vc isKindOfClass:[ShortVideosContainer class]]) {
            ShortVideosContainer *shortVc = (ShortVideosContainer*)vc;
            [shortVc insertModelToHotShortVideo:model];
            [tabbarController stopAndHidenWobble];
            [shortVc hideCommentView];
        }
    } else {
        if ([self.superPagerVC.superPagerVC isKindOfClass:[HomeContainer class]]) {

            HomeContainer *container = (HomeContainer*)self.superPagerVC.superPagerVC;
            [container openShortVideo:model];
        }
    }
}

#pragma mark - NSNotification
-(void)showLivePlay:(NSNotification *)notice {
    if (notice.object && [notice.object isKindOfClass: [UIViewController class]]) {
        HomeRecommendLiveModel *liveModel;
        for (RecommendSectionModel *model in self.sectionModels) {
            if (model.type == HomeSectionKindLiveStreaming &&
                [model.model isKindOfClass:[HomeRecommendLiveModel class]]) {
                liveModel = model.model;
                break;
            }
        }
        if (liveModel == nil) {
            return;
        }
        LivePlayTableVC *livePlayTableVC = [[LivePlayTableVC alloc]init];
        livePlayTableVC.index = 0;
        livePlayTableVC.datas = [NSMutableArray arrayWithArray:liveModel.data];
        [((UIViewController *)notice.object).navigationController pushViewController:livePlayTableVC animated:YES];
    }
}

- (void)updateRemoveMode:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *roomId = userInfo[@"roomId"];

    for (int i = 0; i<self.sectionModels.count; i++) {
        RecommendSectionModel *sectionModel = self.sectionModels[i];
        switch (sectionModel.type) {
            case HomeSectionKindLiveStreaming:
                if ([sectionModel.model isKindOfClass:[HomeRecommendLiveModel class]]) {
                    HomeRecommendLiveModel *liveModel = sectionModel.model;
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:liveModel.data];
                    for (hotModel *model in liveModel.data) {
                        if ([model.zhuboID isEqualToString:roomId]) {
                            [tempArray removeObject:model];
                        }
                    }
                    liveModel.data = tempArray;
                }

                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:i]];
                break;
            default:
                break;
        }
    }
}

- (void)updateVideoLike:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *videoId = minstr(dic[@"video_id"]);
    int is_like = [dic[@"is_like"] intValue];

    for (int i = 0; i<self.sectionModels.count; i++) {
        RecommendSectionModel *sectionModel = self.sectionModels[i];
        switch (sectionModel.type) {
            case HomeSectionKindShortVideo:
                if ([sectionModel.model isKindOfClass:[HomeRecommendShortVideoModel class]]) {
                    HomeRecommendShortVideoModel *shortModel = sectionModel.model;
                    for (ShortVideoModel *model in shortModel.data) {
                        if ([model.video_id isEqualToString:videoId]) {
                            model.is_like = is_like;
                        }
                    }
                }

                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:i]];
                break;
            default:
                break;
        }
    }
}

- (void)updateSkitFavorite:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *skitId = minstr(dic[@"skit_id"]);
    int is_favorite = [dic[@"is_favorite"] intValue];

    for (int i = 0; i<self.sectionModels.count; i++) {
        RecommendSectionModel *sectionModel = self.sectionModels[i];
        switch (sectionModel.type) {
            case HomeSectionKindSkit:
                if ([sectionModel.model isKindOfClass:[HomeRecommendSkitModel class]]) {
                    HomeRecommendSkitModel *skitModel = sectionModel.model;
                    for (HomeRecommendSkit *model in skitModel.data) {
                        if ([model.skit_id isEqualToString:skitId]) {
                            model.is_favorite = is_favorite;
                        }
                    }
                }

                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:i]];
                break;
            default:
                break;
        }
    }
}

@end
