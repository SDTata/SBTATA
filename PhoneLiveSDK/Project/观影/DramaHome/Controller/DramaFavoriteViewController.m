//
//  DramaFavoriteViewController.m
//  DramaTest
//
//  Created by s5346 on 2024/5/6.
//

#import "DramaFavoriteViewController.h"
#import "DramaHomeVideoCell.h"
#import "DramaVideoViewController.h"

@interface DramaFavoriteViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, assign) DramaFavoriteViewControllerType viewType;
@property(nonatomic, strong) UIView *navigationView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<DramaInfoModel*> *dramaInfoList;
@property(nonatomic, assign) int page;
@property(nonatomic, assign) bool isLoading;
@property(nonatomic, assign) bool isMore;
@property(nonatomic, strong) UILabel *noDataLabel;

@end

@implementation DramaFavoriteViewController

- (instancetype)initWithType:(DramaFavoriteViewControllerType)type
{
    self = [super init];
    if (self) {
        self.viewType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self requestDrama:self.viewType page:1];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dramaListUpdate:) name:@"DramaListUpdate" object:nil];

    if (self.viewType == DramaFavoriteViewControllerForFavorite) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSkit:) name:@"DramaFavoriteViewControllerRemoveSkit" object:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DramaListUpdate" object:nil];
    if (self.viewType == DramaFavoriteViewControllerForFavorite) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DramaFavoriteViewControllerRemoveSkit" object:nil];
    }
}

#pragma mark - UI
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

    [self.view addSubview:self.noDataLabel];
    [self.noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.right.equalTo(self.view).inset(15);
    }];
}

- (UICollectionView *)createCollectionView {
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
    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSection:section];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[DramaHomeVideoCell self] forCellWithReuseIdentifier:NSStringFromClass([DramaHomeVideoCell class])];
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
        [strongSelf requestDrama:self.viewType page:1];
    }];

    
    return collectionView;
}

#pragma mark - API
- (void)requestDrama:(NSInteger)type page:(int)page {
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
            strongSelf.page = page;

            if (![info isKindOfClass:[NSDictionary class]]) {
                strongSelf.noDataLabel.hidden = strongSelf.dramaInfoList.count != 0;
                strongSelf.isLoading = NO;
                strongSelf.isMore = NO;
                [strongSelf.collectionView reloadData];
                return;
            }

            NSArray *list = info[@"list"];
            if (![list isKindOfClass:[NSArray class]]) {
                return;
            }
            strongSelf.isMore = list.count > 0;

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
            strongSelf.noDataLabel.hidden = strongSelf.dramaInfoList.count != 0;
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

#pragma mark - action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeSkit:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *skitId = userInfo[@"skitId"];

    DramaInfoModel *removeModel = nil;
    for (DramaInfoModel *model in self.dramaInfoList) {
        if ([model.skit_id isEqualToString:skitId]) {
            removeModel = model;
            break;
        }
    }

    if (removeModel) {
        [self.dramaInfoList removeObject:removeModel];
        self.noDataLabel.hidden = self.dramaInfoList.count != 0;
        [self.collectionView reloadData];
    }
}

- (void)dramaListUpdate:(NSNotification *)notification {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dramaInfoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DramaHomeVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DramaHomeVideoCell class]) forIndexPath:indexPath];
    if (self.dramaInfoList.count > indexPath.item) {
        cell.model = self.dramaInfoList[indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.dramaInfoList.count - 3) {
        [self requestDrama:self.viewType page:self.page + 1];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.dramaInfoList.count) {
        return;
    }
    DramaInfoModel *model = self.dramaInfoList[indexPath.item];
    DramaVideoViewController *viewController = [[DramaVideoViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - lazy
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

        UILabel *navigationTitleLabel = [[UILabel alloc] init];
        if (self.viewType == DramaFavoriteViewControllerForFavorite) {
            navigationTitleLabel.text = YZMsg(@"DramaFavoriteViewController_title");
        } else {
            navigationTitleLabel.text = YZMsg(@"DramaHomeHistoryCell_history_title");
        }

        navigationTitleLabel.font = [UIFont systemFontOfSize:18];
        navigationTitleLabel.textColor = [UIColor blackColor];
        navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
        [_navigationView addSubview:navigationTitleLabel];
        [navigationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_navigationView);
            make.left.equalTo(backButton.mas_right);
            make.right.equalTo(@-44);
        }];
    }
    return _navigationView;
}

- (UILabel *)noDataLabel {
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor blackColor];
        _noDataLabel.text = YZMsg(@"DramaFavoriteViewController_empty_favorite");
        _noDataLabel.hidden = YES;
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noDataLabel;
}

@end
