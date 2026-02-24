//
//  ShortVideosFollowContainer.m
//  phonelive2
//
//  Created by s5346 on 2024/9/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideosFollowContainer.h"
#import "ShortVideoListViewController.h"
#import "ShortVideosFollowCell.h"
#import "AnimRefreshHeader.h"
#import "ShortVideosFollowHeader.h"
#import "HomeSectionKindShortVideoContentViewCell.h"
#import "ShortVideosFollowModel.h"
#import <UMCommon/UMCommon.h>

@interface ShortVideosFollowContainer ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<ShortVideosFollowModel *> *dataSources;
@property(nonatomic, assign) int page;
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, strong) UIView *emptyView;

@end

@implementation ShortVideosFollowContainer

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadLiveplayAttion:) name:@"reloadLiveplayAttion" object:nil];

    [self setupViews];
    [self refresh];
    [self changeStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeStyle];
}

- (void)refresh {
    self.page = 0;
    self.dataSources = [NSMutableArray array];
    self.hasMore = YES;
    self.isLoading = NO;
    [self requestList];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadLiveplayAttion:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *isattention = minstr([dic valueForKey:@"isattent"]);
        NSString *uid = minstr([dic valueForKey:@"uid"]);
        for (int i = 0; i<self.dataSources.count; i++) {
            ShortVideosFollowModel *model = self.dataSources[i];
            if (![model isKindOfClass:[ShortVideosFollowModel class]]) {
                continue;
            }
            if ([model.user.uid isEqualToString:uid]) {
                model.user.is_followed = [NSString stringWithFormat:@"%ld", isattention.integerValue];
                break;
            }
        }
    }
}

- (void)handleRefresh {
    [self.collectionView.mj_header beginRefreshing];
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
    int page = self.page + 1;
    self.isLoading = YES;

    NSString *urlkey = @"ShortVideo.getFollowInfo";//getLikedVideos
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
                    ShortVideosFollowModel *model = [ShortVideosFollowModel mj_objectWithKeyValues:tempDic];
                    [models addObject:model];
                }
            }

            NSMutableArray *sortModels = [NSMutableArray array];
            for (ShortVideosFollowModel *element in models) {
                for (ShortVideosFollowModel *tempModel in strongSelf.dataSources) {
                    if ([tempModel.user.uid isEqualToString:element.user.uid]) {
                        continue;
                    }
                }
                [sortModels addObject:element];
            }

            [strongSelf.dataSources addObjectsFromArray:sortModels];
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
    [collectionView registerClass:[HomeSectionKindShortVideoContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell"];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [collectionView registerClass:[ShortVideosFollowHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ShortVideosFollowHeader"];

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
    return self.dataSources.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSources.count > section) {
        ShortVideosFollowModel *model = self.dataSources[section];
        return MIN(3, model.videos.count);
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeSectionKindShortVideoContentViewCell *cell = (HomeSectionKindShortVideoContentViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell" forIndexPath:indexPath];
    if (self.dataSources.count > indexPath.section) {
        ShortVideosFollowModel *model = self.dataSources[indexPath.section];
        if (model.videos.count > indexPath.item) {
            ShortVideoModel *video = model.videos[indexPath.item];
            [cell updateForOtherUserMsg:video];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        if (self.dataSources.count - 3 <= indexPath.section) {
//            [self requestList];
//        }

        ShortVideosFollowHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ShortVideosFollowHeader" forIndexPath:indexPath];
        if (self.dataSources.count > indexPath.section) {
            ShortVideosFollowModel *model = self.dataSources[indexPath.section];
            [headerView update:model.user];
        }
        return headerView;
    }

    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSources.count <= indexPath.section) {
        return;
    }

    ShortVideosFollowModel *model = self.dataSources[indexPath.section];
    NSArray<ShortVideoModel *> *videos = model.videos;
    ShortVideoListViewController *vc = [[ShortVideoListViewController alloc] initWithHost:@"ShortVideo.getMyVideos"];
    vc.toUid = model.user.uid;
    [vc updateData:model.videos selectIndex:indexPath.item fetchMore:YES];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:[collectionView cellForItemAtIndexPath:indexPath]];

    _weakify(self)
    vc.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSString *videoId) {
        _strongifyReturn(self)
        NSInteger currentIndex = -1;
        for (int i = 0; i < videos.count; i++) {
            ShortVideoModel *model = videos[i];
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

        return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:indexPath.section]].contentView;;
    };
    [MobClick event:@"shortvideo_follow_detail_click" attributes:@{@"eventType": @(1)}];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (collectionView.width - (8*2) - (15*2) - 1)/3;
    CGFloat height = width * 180 / 142.0;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.width - 30, 50);
}

@end
