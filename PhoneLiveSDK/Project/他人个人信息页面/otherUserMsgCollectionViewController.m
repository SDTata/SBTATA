//
//  otherUserMsgCollectionViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/8/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import "otherUserMsgCollectionViewController.h"
#import "HomeSectionKindShortVideoContentViewCell.h"
#import "personLiveCell.h"
#import "ShortVideoListViewController.h"
#import "hietoryPlay.h"
#import <UMCommon/UMCommon.h>

@interface otherUserMsgCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *dataSources;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, assign) otherUserMsgCollectionViewControllerType viewType;
@property(nonatomic, assign) int page;
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, weak) ShortVideoListViewController *shortVideoViewController;
@property(nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) MASConstraint *emptyLabelHeightConstraint;

@end

@implementation otherUserMsgCollectionViewController

- (instancetype)initWithType:(otherUserMsgCollectionViewControllerType)type userID:(NSString*)userID
{
    self = [super init];
    if (self) {
        self.viewType = type;
        self.userID = userID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoLike:) name:@"updateShortVideoLike" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeModel:) name:@"ShortVideoLikeForRemove" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addModel:) name:@"ShortVideoLikeForAdd" object:nil];

    [self setupViews];
    [self refresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh {
    self.page = 0;
    self.dataSources = [NSMutableArray array];
    self.hasMore = YES;
    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        [self requestLiveList];
    } else {
        [self requestList];
    }
}

- (void)scroll:(BOOL)isScroll {
    self.collectionView.scrollEnabled = isScroll;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateEmptyHeight];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self updateEmptyHeight];
}

- (void)updateEmptyHeight {
    CGFloat height = 50;
    if ([self.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForGetEmptyHeight)]) {
        height = [self.delegate otherUserMsgCollectionViewControllerForGetEmptyHeight];
    }

    self.emptyLabelHeightConstraint.mas_equalTo(height);
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
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

- (void)removeModel:(NSNotification *)notification {
    if (self.viewType != otherUserMsgCollectionViewControllerTypeLike) {
        return;
    }
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
    if (self.viewType != otherUserMsgCollectionViewControllerTypeLike) {
        return;
    }
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
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];

    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - API
- (void)requestList {
    if (self.viewType == otherUserMsgCollectionViewControllerVideo) {
        [self requestWorkListAPI];
    } else if (self.viewType == otherUserMsgCollectionViewControllerTypeLike) {
        [self requestLikeListAPI];
    }
}

- (void)requestWorkListAPI {
    if (self.hasMore == NO) {
        return;
    }
    int page = self.page + 1;

    NSString *urlkey = @"ShortVideo.getMyVideos";;
    NSDictionary *dic =  @{@"to_uid":_userID,@"p":@(page)};

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:urlkey withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if ([strongSelf.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForEndRefresh)]) {
            [strongSelf.delegate otherUserMsgCollectionViewControllerForEndRefresh];
        }

        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                strongSelf.hasMore = NO;
                return;
            }

            NSArray *video_list = info[@"video_list"];
            if (![video_list isKindOfClass:[NSArray class]]) {
                strongSelf.hasMore = NO;
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                return;
            }

            NSArray *models = [ShortVideoModel mj_objectArrayWithKeyValuesArray:video_list];
            if (models.count > 0) {
                strongSelf.page = page;
            } else {
                strongSelf.hasMore = NO;
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
            [strongSelf updateEmptyHeight];

            if (sortModels.count > 0) {
                [strongSelf.collectionView.mj_footer endRefreshing];
            } else {
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([strongSelf.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForEndRefresh)]) {
            [strongSelf.delegate otherUserMsgCollectionViewControllerForEndRefresh];
        }
        [strongSelf.collectionView.mj_footer endRefreshing];
    }];

}

- (void)requestLikeListAPI {
    if (self.hasMore == NO) {
        return;
    }
    int page = self.page + 1;

    NSString *urlkey = @"ShortVideo.getLikedVideos";
    NSDictionary *dic = @{@"to_uid":_userID,@"p":@(page)};

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:urlkey withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if ([strongSelf.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForEndRefresh)]) {
            [strongSelf.delegate otherUserMsgCollectionViewControllerForEndRefresh];
        }

        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                strongSelf.hasMore = NO;
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                return;
            }

            NSArray *models = [ShortVideoModel mj_objectArrayWithKeyValuesArray:info];
            if (models.count > 0) {
                strongSelf.page = page;
            } else {
                strongSelf.hasMore = NO;
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
            [strongSelf updateEmptyHeight];

            if (sortModels.count > 0) {
                [strongSelf.collectionView.mj_footer endRefreshing];
            } else {
                [strongSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([strongSelf.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForEndRefresh)]) {
            [strongSelf.delegate otherUserMsgCollectionViewControllerForEndRefresh];
        }
        [strongSelf.collectionView.mj_footer endRefreshing];
    }];
}

- (void)requestLiveList {
    if (self.hasMore == NO) {
        return;
    }
    int page = self.page + 1;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getLiverecord" withBaseDomian:YES andParameter:@{@"touid":_userID,@"p":@(page)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([strongSelf.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForEndRefresh)]) {
            [strongSelf.delegate otherUserMsgCollectionViewControllerForEndRefresh];
        }

        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                strongSelf.hasMore = NO;
                return;
            }

            [strongSelf.dataSources addObjectsFromArray:info];
            [strongSelf.collectionView reloadData];
            strongSelf.emptyView.hidden = strongSelf.dataSources.count > 0;
            [strongSelf updateEmptyHeight];
            if (((NSArray*)info).count > 0) {
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
        if ([strongSelf.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForEndRefresh)]) {
            [strongSelf.delegate otherUserMsgCollectionViewControllerForEndRefresh];
        }
        [strongSelf.collectionView.mj_footer endRefreshing];
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
    collectionView.scrollEnabled = NO;
    collectionView.bounces = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"personLiveCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"personLiveCELL"];
    [collectionView registerClass:[HomeSectionKindShortVideoContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell"];

    WeakSelf
    MJRefreshAutoNormalFooter *aaa = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
    aaa.ignoredScrollViewContentInsetBottom = -40;
    collectionView.mj_footer = aaa;

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
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.font = [UIFont systemFontOfSize:14];
        noDataLabel.textColor = [UIColor blackColor];
        if (self.viewType == otherUserMsgCollectionViewControllerVideo) {
            noDataLabel.text = YZMsg(@"otherUserMsgVC_no_work");
        } else if (self.viewType == otherUserMsgCollectionViewControllerTypeLike) {
            noDataLabel.text = YZMsg(@"otherUserMsgVC_no_like");
        } else if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
            noDataLabel.text = YZMsg(@"otherUserMsgVC_no_live");
        }

        [_emptyView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_emptyView);
            make.left.right.equalTo(_emptyView).inset(20);
            self.emptyLabelHeightConstraint = make.height.equalTo(@50);
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
    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        personLiveCell *cell = (personLiveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"personLiveCELL" forIndexPath:indexPath];
        cell.model = [[LiveNodeModel alloc]initWithDic:self.dataSources[indexPath.item]];
        return cell;
    }

    HomeSectionKindShortVideoContentViewCell *cell = (HomeSectionKindShortVideoContentViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell" forIndexPath:indexPath];
    if (self.dataSources.count > indexPath.item) {
        [cell updateForOtherUserMsg:self.dataSources[indexPath.item]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSources.count - 1 == indexPath.row) {
        if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
            [self requestLiveList];
        } else {
            [self requestList];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSources.count <= indexPath.item) {
        return;
    }

    NSString *type = @"";
    if (self.viewType == otherUserMsgCollectionViewControllerVideo) {
        type = @"作品";
    } else if (self.viewType == otherUserMsgCollectionViewControllerTypeLike) {
        type = @"喜欢";
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type": type};
    [MobClick event:@"user_profile_video_click" attributes:dict];

    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        NSDictionary *subdics = self.dataSources[indexPath.item];
        [MBProgressHUD showMessage:@""];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getAliCdnRecord" withBaseDomian:YES andParameter:@{@"id":minstr([subdics valueForKey:@"id"])} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD hideHUD];
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:minstr(strongSelf.chatname),@"name",minstr(strongSelf.icon),@"icon",minstr(strongSelf.userID),@"id",strongSelf.level_anchor,@"level", nil];
                hietoryPlay *history = [[hietoryPlay alloc]init];
                history.url = [[info firstObject] valueForKey:@"url"];
                history.selectDic = userDic;
    //            [self presentViewController:history animated:YES completion:nil];
                [[MXBADelegate sharedAppDelegate] pushViewController:history animated:YES];

            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
//            [MBProgressHUD hideHUD];
        }];
        return;
    }

    ShortVideoListViewController *vc = [[ShortVideoListViewController alloc] initWithHost:@""];
    vc.showCreateTime = YES;
    [vc updateData:self.dataSources selectIndex:indexPath.item fetchMore:NO];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:[collectionView cellForItemAtIndexPath:indexPath]];
    _weakify(self)
    vc.fetchMoreBlock = ^{
        _strongify(self)
        if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
            [self requestLiveList];
        } else {
            [self requestList];
        }
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

        return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]].contentView;;
    };

    self.shortVideoViewController = vc;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (collectionView.width - 8 - 14*2 - 1)/2;
    CGFloat height = width * 226 / 177.0;
    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        return CGSizeMake(_window_width, 50);
    }
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        return UIEdgeInsetsZero;
    }
    return UIEdgeInsetsMake(0, 14, 0, 14);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        return 0;
    }
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.viewType == otherUserMsgCollectionViewControllerTypeLive) {
        return 0;
    }
    return 8;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y != 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(otherUserMsgCollectionViewControllerForScrollToTop)]) {
        [self.delegate otherUserMsgCollectionViewControllerForScrollToTop];
    }
}
@end
