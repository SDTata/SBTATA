//
//  SkitListViewController.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "SkitListViewController.h"
#import "ScrollCardViewCell.h"
#import "HotSkitSegmentHeaderView.h"
#import "HomeSectionKindSkitContentViewCell.h"
#import "HomeRecommendSkitModel.h"
#import "SkitHotModel.h"
#import "SkitPlayerVC.h"
#import "AnimRefreshHeader.h"

#define CateId @"CateId"

@interface SkitListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, assign) SkitListViewControllerType viewType;
@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, assign) NSInteger page;
@property(nonatomic, strong) NSMutableArray<HomeRecommendSkit*> *dataSources;
@property(nonatomic, strong) NSMutableArray<HomeRecommendSkit*> *categoryDataSources;
@property(nonatomic, strong) NSMutableArray<CateInfoModel*> *categoryInfoDataSources;
//@property(nonatomic, strong) UIView *emptyView;
@property(nonatomic, assign) NSInteger ticketCount;
@property(nonatomic, strong) NSString *cateId;

@end

@implementation SkitListViewController

- (instancetype)initWithType:(SkitListViewControllerType)type
{
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{CateId: @""}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.viewType = type;
        if (type == SkitListViewControllerTypeCategory) {
            self.cateId = [[NSUserDefaults standardUserDefaults] stringForKey:CateId];
        } else {
            self.cateId = @"";
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self refresh:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skitListUpdate:) name:@"SkitListUpdate" object:nil];

    if (self.viewType == SkitListViewControllerTypeFavorite) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSkit:) name:@"SkitFavoriteViewControllerRemoveSkit" object:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SkitListUpdate" object:nil];
    if (self.viewType == SkitListViewControllerTypeFavorite) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SkitFavoriteViewControllerRemoveSkit" object:nil];
    }
}

#pragma mark - UI
- (void)setupViews {
    self.view.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-10);
    }];

//    [self.view addSubview:self.emptyView];
//    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (self.viewType == SkitListViewControllerTypeCategory && self.categoryDataSources.count > 0) {
//            make.left.right.equalTo(self.view);
//            make.top.equalTo(self.view).offset(ScrollCardViewCell.height);
//        } else {
//            make.top.left.right.equalTo(self.view);
//        }
//        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
//    }];
}

- (UICollectionView *)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionHeadersPinToVisibleBounds = YES;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[ScrollCardViewCell class] forCellWithReuseIdentifier:@"ScrollCardViewCell"];
    [collectionView registerClass:[HomeSectionKindSkitContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindSkitContentViewCell"];
    [collectionView registerClass:[HotSkitSegmentHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HotSkitSegmentHeaderView"];

    WeakSelf
    AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf refresh:YES];
    }];
    [collectionView setMj_header:refreshHeader];

    return collectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

//- (UIView *)emptyView {
//    if (!_emptyView) {
//        _emptyView = [[UIView alloc] init];
//        _emptyView.backgroundColor = [UIColor clearColor];
//        _emptyView.userInteractionEnabled = NO;
//        _emptyView.hidden = YES;
//
//        UILabel *noDataLabel = [[UILabel alloc] init];
//        noDataLabel.font = [UIFont systemFontOfSize:14];
//        noDataLabel.textColor = UIColor.blackColor;
//        if (self.viewType == SkitListViewControllerTypeFavorite) {
//            noDataLabel.text = YZMsg(@"DramaFavoriteViewController_empty_favorite");
//        } else {
//            noDataLabel.text = YZMsg(@"Not Search Any Result");
//        }
//
//        [_emptyView addSubview:noDataLabel];
//        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(_emptyView);
//        }];
//    }
//    return _emptyView;
//}

#pragma mark - API
- (void)requestCategoryCompletion:(nullable void (^)(BOOL success))completion {
    NSDictionary *dic = @{
        @"page": minnum(1),
        @"type": @(SkitListViewControllerTypeHot),
        @"cate": self.cateId,
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Skit.getSkitListByType" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if ([info isKindOfClass:[NSArray class]]) {
                completion(NO);
                return;
            }

            SkitHotModel *model = [SkitHotModel mj_objectWithKeyValues:info];
            if (strongSelf.cateId.length <= 0) {
                NSMutableArray *newArray = [NSMutableArray array];
                for (HomeRecommendSkit *tempModel in model.list) {
                    BOOL isNew = YES;
                    for (HomeRecommendSkit *oldModel in strongSelf.dataSources) {
                        if ([oldModel.skit_id isEqualToString:tempModel.skit_id]) {
                            isNew = NO;
                            break;
                        }
                    }
                    if (isNew) {
                        [newArray addObject:tempModel];
                    }
                }

                [strongSelf.dataSources addObjectsFromArray:newArray];
            }

            if (strongSelf.categoryDataSources.count <= 0) {
                [strongSelf.categoryDataSources addObjectsFromArray:model.cate_skit_list];
            }
            if (strongSelf.categoryInfoDataSources.count <= 0) {
                [strongSelf.categoryInfoDataSources addObjectsFromArray:model.cate_info];
            }

            completion(YES);
        } else {
            completion(NO);
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

- (void)requestList:(NSInteger)page completion:(nullable void (^)(BOOL success))completion {
    NSDictionary *dic = @{
        @"page": minnum(page),
        @"type": @(self.viewType),
        @"cate": self.cateId,
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Skit.getSkitListByType" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if ([info isKindOfClass:[NSArray class]]) {
                completion(NO);
                return;
            }

            NSArray *list = info[@"list"];
            NSInteger ticketCount = [minstr(info[@"ticket_count"]) integerValue];
            strongSelf.ticketCount = ticketCount;

            if (![list isKindOfClass:[NSArray class]]) {
                completion(NO);
                return;
            }

            if (list.count <= 0) {
                completion(NO);
                return;
            }

            NSArray *models = [HomeRecommendSkit mj_objectArrayWithKeyValuesArray:list];
            BOOL isNew = YES;
            NSMutableArray *sortModels = [NSMutableArray array];
            for (HomeRecommendSkit *element in models) {
                for (HomeRecommendSkit *tempModel in strongSelf.dataSources) {
                    if ([tempModel.skit_id isEqualToString:element.skit_id]) {
                        isNew = NO;
                        break;
                    }
                }
                if (isNew) {
                    [sortModels addObject:element];
                }
            }
            [strongSelf.dataSources addObjectsFromArray:sortModels];
            completion(YES);
        } else {
            completion(NO);
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

#pragma mark - Action
- (void)refresh:(BOOL)isNeedCategory {
    if (isNeedCategory) {
        self.categoryInfoDataSources = [NSMutableArray array];
        self.categoryDataSources = [NSMutableArray array];
        if (self.viewType == SkitListViewControllerTypeCategory) {
            WeakSelf
            [self requestCategoryCompletion:^(BOOL success) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf.collectionView reloadData];

//                [strongSelf.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    if (strongSelf.viewType == SkitListViewControllerTypeCategory &&
//                        strongSelf.categoryDataSources.count > 0) {
//                        make.left.right.bottom.equalTo(strongSelf.view);
//                        make.top.equalTo(strongSelf.view).offset(ScrollCardViewCell.height);
//                    } else {
//                        make.top.left.right.equalTo(strongSelf.view);
//                    }
//                    make.bottom.equalTo(strongSelf.view.mas_safeAreaLayoutGuideBottom);
//                }];
            }];
        }
    }
    self.dataSources = [NSMutableArray array];
    self.hasMore = YES;
    self.page = 1;

    [self fetchDataIsRefresh:YES page:1];
}

- (void)fetchMoreList {
    NSInteger page = self.page + 1;
    [self fetchDataIsRefresh:NO page:page];
}

- (void)fetchDataIsRefresh:(BOOL)isRefresh page:(NSInteger)page {
    if (self.isLoading || !self.hasMore) {
        return;
    }
    self.isLoading = YES;

    if (isRefresh) {
        self.dataSources = [NSMutableArray array];
    }

    WeakSelf
    [self requestList:page completion:^(BOOL success) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];
        strongSelf.isLoading = NO;
//        strongSelf.emptyView.hidden = YES;
        strongSelf.hasMore = success;
        [strongSelf.collectionView reloadData];

        if (success) {
            strongSelf.page = page;
        } else if (page == 1) {
//            strongSelf.emptyView.hidden = NO;
            [strongSelf.collectionView reloadData];
        }
    }];
}

- (void)removeSkit:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *skitId = userInfo[@"skitId"];

    HomeRecommendSkit *removeModel = nil;
    for (HomeRecommendSkit *model in self.dataSources) {
        if ([model.skit_id isEqualToString:skitId]) {
            removeModel = model;
            break;
        }
    }

    if (removeModel) {
        [self.dataSources removeObject:removeModel];
//        if (self.viewType == SkitListViewControllerTypeCategory) {
//            self.emptyView.hidden = self.dataSources.count != 0 || self.categoryDataSources.count != 0;
//        } else {
//            self.emptyView.hidden = self.dataSources.count != 0;
//        }
        [self.collectionView reloadData];
    }
}

- (void)skitListUpdate:(NSNotification *)notification {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.viewType == SkitListViewControllerTypeCategory ? (self.categoryDataSources.count > 0 ? 1 : 0) : 0;
    }
    return self.dataSources.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        ScrollCardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScrollCardViewCell" forIndexPath:indexPath];
        [cell update:self.categoryDataSources];

        WeakSelf
        cell.tapIndex = ^(NSInteger index) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.categoryDataSources.count <= index) {
                return;
            }
            SkitPlayerVC *viewController = [SkitPlayerVC new];
            viewController.skitArray = strongSelf.categoryDataSources;
            viewController.skitIndex = index;
            viewController.hasTabbar = YES;
            [[MXBADelegate sharedAppDelegate] pushViewController:viewController cell:[collectionView cellForItemAtIndexPath:indexPath] hidesBottomBarWhenPushed:NO];
        };
        return cell;
    }

    HomeSectionKindSkitContentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindSkitContentViewCell" forIndexPath:indexPath];
    if (self.dataSources.count > indexPath.item) {
        [cell update:self.dataSources[indexPath.item]];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HotSkitSegmentHeaderView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HotSkitSegmentHeaderView" forIndexPath:indexPath];
    [cell update:self.categoryInfoDataSources cateId:self.cateId];

    WeakSelf
    [cell setTapBlock:^(NSString *cateId) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([strongSelf.cateId isEqualToString:cateId]) {
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:cateId forKey:CateId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        strongSelf.cateId = cateId;
        [strongSelf refresh:NO];
        NSLog(@"%@", cateId);
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSources.count - 3 == indexPath.row) {
        [self fetchMoreList];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }

    if (self.dataSources.count <= indexPath.item) {
        return;
    }

    SkitPlayerVC *viewController = [SkitPlayerVC new];
    viewController.skitArray = self.dataSources;
    viewController.skitIndex = indexPath.item;
    viewController.hasTabbar = YES;
    [[MXBADelegate sharedAppDelegate] pushViewController:viewController cell:[collectionView cellForItemAtIndexPath:indexPath] hidesBottomBarWhenPushed:NO];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), ScrollCardViewCell.height);
    }

    CGFloat width = (CGRectGetWidth(collectionView.frame) - (14 * 2 + 8 + 1)) / 2;
    return CGSizeMake(width, width * 226 / 177);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }

    if (self.viewType == SkitListViewControllerTypeCategory) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 54);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsZero;
    }

    return UIEdgeInsetsMake(0, 14, 0, 14);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 0;
    }

    return 8;
}
@end
