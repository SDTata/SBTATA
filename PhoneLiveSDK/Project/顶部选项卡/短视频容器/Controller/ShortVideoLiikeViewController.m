//
//  ShortVideoLiikeViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/8/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoLiikeViewController.h"
#import "HomeSectionKindShortVideoContentViewCell.h"
#import "ShortVideoListViewController.h"
#import "AnimRefreshHeader.h"

@interface ShortVideoLiikeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *dataSources;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, assign) int page;
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, weak) ShortVideoListViewController *shortVideoViewController;
@property(nonatomic, strong) UIView *emptyView;

@end

@implementation ShortVideoLiikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoLike:) name:@"updateShortVideoLike" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeModel:) name:@"ShortVideoLikeForRemove" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addModel:) name:@"ShortVideoLikeForAdd" object:nil];

    [self setupViews];
    [self refresh];
    [self changeStyle];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeStyle];
}

- (void)refresh {
    self.page = 0;
    self.dataSources = [NSMutableArray array];
    self.hasMore = YES;
    [self requestList];
}

- (void)refreshAndScrollToTop {
    [self refresh];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
}

- (void)scroll:(BOOL)isScroll {
    self.collectionView.scrollEnabled = isScroll;
}

- (void)updateVideoLike:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *videoId = minstr(dic[@"video_id"]);
    int is_like = [dic[@"is_like"] intValue];

    for (ShortVideoModel *model in self.dataSources) {
        if (![model isKindOfClass:[ShortVideoModel class]]) {
            continue;
        }
        if ([model.video_id isEqualToString:videoId]) {
            model.is_like = is_like;
            [self.collectionView reloadData];
            break;
        }
    }
}

- (void)handleRefresh {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)removeModel:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *videoId = minstr(dic[@"video_id"]);

    for (ShortVideoModel *model in self.dataSources) {
        if (![model isKindOfClass:[ShortVideoModel class]]) {
            continue;
        }
        if ([model.video_id isEqualToString:videoId]) {
            [self.dataSources removeObject:model];
            [self.collectionView reloadData];
            break;
        }
    }
}

- (void)addModel:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    ShortVideoModel *newModel = dic[@"model"];
    if (![newModel isKindOfClass:[ShortVideoModel class]]) {
        return;
    }

    BOOL isNew = true;
    for (ShortVideoModel *model in self.dataSources) {
        if (![model isKindOfClass:[ShortVideoModel class]]) {
            continue;
        }
        if ([model.video_id isEqualToString:newModel.video_id]) {
            isNew = false;
            break;
        }
    }

    if (isNew) {
        [self.dataSources insertObject:newModel atIndex:0];
        [self.collectionView reloadData];
    }
}

#pragma mark - Private
- (void)setupViews {
    self.view.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(VK_STATUS_H + 50);
        make.left.right.equalTo(self.view);
        CGFloat tabBarHeight = self.tabBarController.tabBar.height;
        make.bottom.equalTo(self.view).offset(-tabBarHeight);
    }];

    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)changeStyle {
    if ([self.delegate respondsToSelector:@selector(changeSegmentStyle:)]) {
        [self.delegate changeSegmentStyle:SegmentStyleLine];
    }
}

#pragma mark - API
- (void)requestList{
    if (self.isLoading == YES) {
        return;
    }

    if (self.hasMore == NO) {
        return;
    }

    self.isLoading = YES;

    int page = self.page + 1;

    NSString *urlkey = @"ShortVideo.getLikedVideos";
    NSDictionary *dic = @{@"p":@(page)};

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:urlkey withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isLoading = NO;

        [strongSelf.collectionView.mj_header endRefreshing];

        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                strongSelf.hasMore = NO;
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                return;
            }

            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *tempDic in info) {
                if (![tempDic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                if (![minstr(tempDic[@"video_type"]) isEqualToString:@"live"]) {
                    ShortVideoModel *model = [ShortVideoModel mj_objectWithKeyValues:tempDic];
                    [models addObject:model];
                }
            }

            NSMutableArray *sortModels = [NSMutableArray array];
            for (ShortVideoModel *element in models) {
                for (ShortVideoModel *tempModel in strongSelf.dataSources) {
                    if ([tempModel.video_id isEqualToString:element.video_id]) {
                        continue;
                    }
                }
                [sortModels addObject:element];
            }

            [strongSelf.dataSources addObjectsFromArray:sortModels];
            if (strongSelf.shortVideoViewController != nil) {
                [strongSelf.shortVideoViewController updateData:strongSelf.dataSources selectIndex:-1 fetchMore:NO];
            }
            [strongSelf.collectionView reloadData];

            strongSelf.emptyView.hidden = strongSelf.dataSources.count > 0;

            if (models.count > 0) {
                strongSelf.page = page;
                [strongSelf.collectionView.mj_footer endRefreshing];
            } else {
                strongSelf.hasMore = NO;
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isLoading = NO;

        [strongSelf.collectionView.mj_header endRefreshing];
    }];

}

#pragma mark - Lazy
- (UICollectionView *)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    layout.sectionInset = UIEdgeInsetsZero;
    collectionView.contentInset = UIEdgeInsetsZero;
    collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"personLiveCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"personLiveCELL"];
    [collectionView registerClass:[HomeSectionKindShortVideoContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell"];

    WeakSelf
    AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf refresh];
    }];
    [collectionView setMj_header:refreshHeader];

    collectionView.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf requestList];
    }];

    return collectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = [UIColor clearColor];
        _emptyView.hidden = YES;
        _emptyView.userInteractionEnabled = NO;

        UILabel *noDataLabel = [[UILabel alloc] init];
        noDataLabel.font = [UIFont systemFontOfSize:14];
        noDataLabel.textColor = [UIColor blackColor];
        noDataLabel.text = YZMsg(@"DramaFavoriteViewController_empty_like");

        [_emptyView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    HomeSectionKindShortVideoContentViewCell *cell = (HomeSectionKindShortVideoContentViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell" forIndexPath:indexPath];
    if (self.dataSources.count > indexPath.item) {
        [cell updateForLikeView:self.dataSources[indexPath.item]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.dataSources.count - 3 == indexPath.row) {
//        [self requestList];
//    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSources.count <= indexPath.item) {
        return;
    }

    ShortVideoListViewController *vc = [[ShortVideoListViewController alloc] initWithHost:@""];
    [vc updateData:self.dataSources selectIndex:indexPath.item fetchMore:NO];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:[collectionView cellForItemAtIndexPath:indexPath]];
    _weakify(self)
    vc.fetchMoreBlock = ^{
        _strongify(self)
        [self requestList];
    };

    vc.currentIndexBlock = ^(NSString *videoId) {
        _strongify(self)
        NSInteger currentIndex = -1;
        for (int i = 0; i < self.dataSources.count; i++) {
            ShortVideoModel *model = self.dataSources[i];
            if (![model isKindOfClass:[ShortVideoModel class]]) {
                continue;
            }
            if ([model.video_id isEqualToString:videoId]) {
                currentIndex = i;
                break;
            }
        }

        if (currentIndex < 0) {
            return;
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        if ([self.collectionView numberOfItemsInSection:0] > currentIndex) {
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionNone
                                                animated:NO];
        }
    };

    vc.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSString *videoId) {
        _strongifyReturn(self)
        NSInteger currentIndex = -1;
        for (int i = 0; i < self.dataSources.count; i++) {
            ShortVideoModel *model = self.dataSources[i];
            if (![model isKindOfClass:[ShortVideoModel class]]) {
                continue;
            }
            if ([model.video_id isEqualToString:videoId]) {
                currentIndex = i;
                break;
            }
        }

        if (currentIndex < 0) {
            return nil;
        }

        HomeSectionKindShortVideoContentViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
        return cell.contentView;
    };

    self.shortVideoViewController = vc;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (collectionView.width - 8 - 14*2 - 1)/2;
    CGFloat height = width * 226 / 177.0;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 14, 0, 14);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

@end
