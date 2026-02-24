//
//  DramaHomeViewController.m
//  DramaTest
//
//  Created by s5346 on 2024/5/3.
//

#import "DramaHomeViewController.h"
#import "DramaHomeHistoryCell.h"
#import "DramaHomeVideoCell.h"
#import "DramaHomeHeaderView.h"
#import "DramaFavoriteViewController.h"
#import "DramaVideoViewController.h"
#import "DramaInfoModel.h"

typedef NS_ENUM(NSUInteger, DramaHomeViewControllerSectionKind) {
    DramaHomeViewControllerSectionTypeForHistory = 0,
    DramaHomeViewControllerSectionTypeForSelect,
};

@interface DramaHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DramaHomeHeaderViewDelegate, DramaHomeHistoryCellDelegate>

@property(nonatomic, strong) UIView *navigationView;
@property(nonatomic, strong) UILabel *navigationTitleLabel;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, assign) int ticketCount;
@property(nonatomic, strong) NSMutableArray<DramaInfoModel*> *dramaInfoList;
@property(nonatomic, assign) int page;
@property(nonatomic, assign) bool isLoading;
@property(nonatomic, assign) bool isMore;
@property(nonatomic, strong) NSMutableArray<DramaInfoModel*> *dramaHistoryInfoList;
@property(nonatomic, assign) int pagehistory;
@property(nonatomic, assign) bool isLoadingHistory;
@property(nonatomic, assign) bool isMoreHistory;
@end

@implementation DramaHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dramaListUpdate:) name:@"DramaListUpdate" object:nil];

    [self setupViews];
    [self requestDrama:1 page:1];
    [self requestHistoryForPage:1];
    [self update];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DramaListUpdate" object:nil];
}

#pragma mark - API
- (void)requestDrama:(int)type page:(int)page {
    if (page == 1) {
        self.dramaInfoList = [NSMutableArray array];
        self.isMore = YES;
    }
    if (self.isLoading == YES || self.isMore == NO) {
        return;
    }
    self.isLoading = YES;

    // 类型 0:观看历史 1:最新短剧 2:热门短剧 3:收藏列表
    NSDictionary *dic = @{
        @"type":@(type),
        @"page":@(page)
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getSkitListByType" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];

        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                strongSelf.isLoading = NO;
                strongSelf.isMore = NO;
                [strongSelf.collectionView reloadData];
                return;
            }

            NSArray *list = info[@"list"];
            if (![list isKindOfClass:[NSArray class]]) {
                strongSelf.isLoading = NO;
                strongSelf.isMore = NO;
                [strongSelf.collectionView reloadData];
                return;
            }
            if (list.count > 0) {
                strongSelf.page = page;
            }
            strongSelf.isMore = list.count > 0;

            strongSelf.ticketCount = [minstr(info[@"skit_ticket_count"]) intValue];
            [strongSelf update];
            NSArray *models = [DramaInfoModel mj_objectArrayWithKeyValuesArray:list];
            NSMutableArray *newArray = [NSMutableArray array];
            for (DramaInfoModel *model in models) {
                BOOL isNew = YES;
                for (DramaInfoModel *oldModel in strongSelf.dramaInfoList) {
                    if ([oldModel.skit_id isEqualToString:model.skit_id]) {
                        isNew = NO;
                        break;
                    }
                }
                if (isNew) {
                    [newArray addObject:model];
                }
            }
            [strongSelf.dramaInfoList addObjectsFromArray:newArray];
            [strongSelf.collectionView reloadData];
        } else {
            [MBProgressHUD showError:msg];
        }
        strongSelf.isLoading = NO;
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        strongSelf.isLoading = NO;
        [strongSelf.collectionView.mj_header endRefreshing];
        if (strongSelf == nil) {
            return;
        }
    }];
}

- (void)requestHistoryForPage:(int)page {
    if (page == 1) {
        self.dramaHistoryInfoList = [NSMutableArray array];
        self.isMoreHistory = YES;
    }
    if (self.isLoadingHistory == YES || self.isMoreHistory == NO) {
        return;
    }
    self.isLoadingHistory = YES;

    // 类型 0:观看历史 1:最新短剧 2:热门短剧 3:收藏列表
    NSDictionary *dic = @{
        @"type":@(0),
        @"page":@(page)
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getSkitListByType" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                strongSelf.isLoadingHistory = NO;
                [strongSelf.collectionView reloadData];
                return;
            }

            NSArray *list = info[@"list"];
            if (![list isKindOfClass:[NSArray class]]) {
                strongSelf.isLoadingHistory = NO;
                [strongSelf.collectionView reloadData];
                return;
            }
            if (list.count > 0) {
                strongSelf.pagehistory = page;
            }
            strongSelf.isMoreHistory = list.count > 0;

            strongSelf.ticketCount = [minstr(info[@"skit_ticket_count"]) intValue];
            [strongSelf update];
            NSArray *models = [DramaInfoModel mj_objectArrayWithKeyValuesArray:list];
            NSMutableArray *newArray = [NSMutableArray array];
            for (DramaInfoModel *model in models) {
                BOOL isNew = YES;
                for (DramaInfoModel *oldModel in strongSelf.dramaHistoryInfoList) {
                    if ([oldModel.skit_id isEqualToString:model.skit_id]) {
                        isNew = NO;
                        break;
                    }
                }
                if (isNew) {
                    [newArray addObject:model];
                }
            }
            [strongSelf.dramaHistoryInfoList addObjectsFromArray:newArray];
            [strongSelf.collectionView reloadData];
        } else {
            [MBProgressHUD showError:msg];
        }
        strongSelf.isLoadingHistory = NO;
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        strongSelf.isLoadingHistory = NO;
        if (strongSelf == nil) {
            return;
        }
    }];
}

#pragma mark - private
- (void)update {
    self.navigationTitleLabel.text = [NSString stringWithFormat:@"%@:%d", YZMsg(@"DramaHomeViewController_title"), self.ticketCount];;
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [ImageBundle imagewithBundleName:@"sy_bj"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.right.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (UICollectionView *)createCollectionView {
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        __typeof(self) strongSelf = self;
        if (!strongSelf) { return nil; }
        DramaHomeViewControllerSectionKind sectionLayoutKind = (DramaHomeViewControllerSectionKind)sectionIndex;

        switch (sectionLayoutKind) {
            case DramaHomeViewControllerSectionTypeForHistory:
                return [strongSelf historyLayoutSection];
            case DramaHomeViewControllerSectionTypeForSelect:
                return [strongSelf videoLayoutSection];
        }
    }];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[DramaHomeHistoryCell self] forCellWithReuseIdentifier:NSStringFromClass([DramaHomeHistoryCell class])];
    [collectionView registerClass:[DramaHomeVideoCell self] forCellWithReuseIdentifier:NSStringFromClass([DramaHomeVideoCell class])];
    [collectionView registerClass:[DramaHomeHeaderView self] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([DramaHomeHeaderView class])];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsVerticalScrollIndicator = NO;

    WeakSelf
    collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf == nil) {
            return;
        }
        [strongSelf requestDrama:1 page:1];
    }];

    return collectionView;
}

- (NSCollectionLayoutSection *)historyLayoutSection {
    NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension absoluteDimension:RatioBaseWidth360(183)]];
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:itemSize subitems:@[item]];

    group.edgeSpacing = [NSCollectionLayoutEdgeSpacing spacingForLeading:nil
                                                                     top:nil
                                                                trailing:nil
                                                                  bottom:[NSCollectionLayoutSpacing fixedSpacing:1]];
    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];

    return section;
}

- (NSCollectionLayoutSection *)videoLayoutSection {
    CGFloat cellSpacing = 5;
    NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]];
    NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension absoluteDimension:RatioBaseWidth360(184)]];

    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:2];
    group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:cellSpacing];


    group.edgeSpacing = [NSCollectionLayoutEdgeSpacing spacingForLeading:nil
                                                                     top:nil
                                                                trailing:nil
                                                                  bottom:[NSCollectionLayoutSpacing fixedSpacing:cellSpacing]];

    NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];

    NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension absoluteDimension:44]];
    NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:UICollectionElementKindSectionHeader alignment:NSRectAlignmentTop];
    header.pinToVisibleBounds = YES;
    section.boundarySupplementaryItems = @[header];

    return section;
}



#pragma mark - action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoStar {
    DramaFavoriteViewController *viewController = [[DramaFavoriteViewController alloc] initWithType:DramaFavoriteViewControllerForFavorite];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)dramaListUpdate:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *skitId = userInfo[@"skitId"];
    NSString *progress = userInfo[@"progress"];
    for (DramaInfoModel *model in self.dramaInfoList) {
        if ([model.skit_id isEqualToString:skitId]) {
            model.p_progress = progress;
            break;
        }
    }

    for (DramaInfoModel *model in self.dramaHistoryInfoList) {
        if ([model.skit_id isEqualToString:skitId]) {
            model.p_progress = progress;
            break;
        }
    }

    [self.collectionView reloadData];
}

#pragma mark - lazy
- (UILabel *)navigationTitleLabel {
    if (!_navigationTitleLabel) {
        _navigationTitleLabel = [[UILabel alloc] init];
        _navigationTitleLabel.font = [UIFont systemFontOfSize:18];
        _navigationTitleLabel.textColor = [UIColor blackColor];
        _navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navigationTitleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

- (UIView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[UIView alloc]init];
        _navigationView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_navigationView];
        [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@44);
        }];

        UIButton *backButton = [[UIButton alloc] init];
        [backButton setImage:[ImageBundle imagewithBundleName:@"fh-1"] forState:UIControlStateNormal];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:backButton];
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_navigationView);
            make.left.equalTo(_navigationView).offset(8);
            make.size.equalTo(@44);
        }];

        UIButton *starButton = [[UIButton alloc] init];
        [starButton setImage:[ImageBundle imagewithBundleName:@"sc-1"] forState:UIControlStateNormal];
        [starButton setImageEdgeInsets:UIEdgeInsetsMake(13.5, 13.25, 13.5, 13.25)];
        [starButton addTarget:self action:@selector(gotoStar) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:starButton];
        [starButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_navigationView);
            make.right.equalTo(_navigationView).offset(-8);
            make.size.equalTo(@44);
        }];

        [_navigationView addSubview:self.navigationTitleLabel];
        [self.navigationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_navigationView);
            make.left.equalTo(backButton.mas_right);
            make.right.equalTo(starButton.mas_left);
        }];
    }
    return _navigationView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DramaHomeViewControllerSectionKind sectionKind = (DramaHomeViewControllerSectionKind)section;
    switch (sectionKind) {
        case DramaHomeViewControllerSectionTypeForHistory:
            return self.dramaHistoryInfoList.count > 0 ? 1 : 0;
            break;
        case DramaHomeViewControllerSectionTypeForSelect:
            return self.dramaInfoList.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DramaHomeViewControllerSectionKind section = (DramaHomeViewControllerSectionKind)indexPath.section;

    switch (section) {
        case DramaHomeViewControllerSectionTypeForHistory: {
            DramaHomeHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DramaHomeHistoryCell class]) forIndexPath:indexPath];
            cell.dramaHistoryInfoList = self.dramaHistoryInfoList;
            cell.delegate = self;
            return cell;
        }
        case DramaHomeViewControllerSectionTypeForSelect: {
            DramaHomeVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DramaHomeVideoCell class]) forIndexPath:indexPath];
            if (self.dramaInfoList.count > indexPath.item) {
                cell.model = self.dramaInfoList[indexPath.item];
            }
            return cell;
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DramaHomeHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([DramaHomeHeaderView class]) forIndexPath:indexPath];
    view.delegate = self;

    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.dramaInfoList.count - 3) {
        [self requestDrama:1 page:self.page + 1];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.item >= self.dramaInfoList.count) {
        return;
    }
    DramaInfoModel *model = self.dramaInfoList[indexPath.item];
    DramaVideoViewController *viewController = [[DramaVideoViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - DramaHomeHeaderViewDelegate
- (void)DramaHomeHeaderViewDelegateForSelectType:(DramaHomeHeaderViewSelectType)type {
    // TODO: bill wait data
    switch (type) {
        case DramaHomeHeaderViewSelectTypeForLatest:
            [self requestDrama:1 page:1];
            break;
        case DramaHomeHeaderViewSelectTypeForHot:
            [self requestDrama:2 page:1];
            break;
    }
    [self.collectionView reloadData];
}

#pragma mark - DramaHomeHistoryCellDelegate
- (void)dramaHomeHistoryCellForTapDrama:(DramaInfoModel*)model {
    DramaVideoViewController *viewController = [[DramaVideoViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)dramaHomeHistoryCellForTapMore {
//    [self requestHistoryForPage:self.pagehistory + 1];
    DramaFavoriteViewController *viewController = [[DramaFavoriteViewController alloc] initWithType:DramaFavoriteViewControllerForHistory];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
