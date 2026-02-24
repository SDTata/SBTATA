//
//  SkitPlayerViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPlayerViewController.h"
#import "SkitPlayerManager.h"
#import "SkitAllHeaderView.h"
#import "SkitAllListView.h"
#import "SkitPreloadManager.h"
#import "VideoProgressManager.h"
#import "SkitPlayerVideoCell.h"
#import "VideoPayCoverView.h"

@interface SkitPlayerViewController () <UITableViewDelegate, UITableViewDataSource, SkitAllListViewDelegate, SkitPlayerManagerDelegate> {
    BOOL isLoading;
}
@property(nonatomic, strong) NSMutableArray<SkitVideoInfoModel*> *dataSources;
@property(nonatomic, strong) UITableView *tableView;
//@property(nonatomic, strong) SkitPlayerManager *manager;
@property(nonatomic, strong) UIView *allDramaListContainer;
@property(nonatomic, strong) SkitAllHeaderView *skitAllHeaderView;
@property(nonatomic, strong) UIView *emptyView;
@property(nonatomic, strong) NSString *selectVideoId;
@property(nonatomic, strong) SkitPreloadManager *preloadManager;
@property(nonatomic, assign) int currentIndex;
@property(nonatomic, weak) HomeRecommendSkit *infoModel;
@property(nonatomic, weak) SkitAllListView *skitAllListView;

@end

@implementation SkitPlayerViewController

- (instancetype)initWithModel:(HomeRecommendSkit*)model
{
    self = [super init];
    if (self) {
        _infoModel = model;
        self.currentIndex = 0;
        self.preloadManager = [[SkitPreloadManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
    [self fetchDataIsRefresh:YES skitId:self.infoModel.skit_id];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    [super shouldAutorotate];
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    [super supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        [cell.manager pauseVideo];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        [self.preloadManager reset];

        for (int i = 0; i<self.dataSources.count; i++) {
            SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell.manager reset];
        }
    }
}

- (void)dealloc {
    NSLog(@"SkitPlayerViewController release");
}

#pragma mark - Private
- (void)fetchDataIsRefresh:(BOOL)isRefresh skitId:(NSString*)skitId {
    if (isLoading) {
        return;
    }
    isLoading = YES;

    if (isRefresh) {
        self.dataSources = [NSMutableArray array];
    }

    WeakSelf
    [self requestDrama:skitId completion:^(BOOL success) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->isLoading = NO;
        strongSelf.emptyView.hidden = strongSelf.dataSources.count > 0;
        if (success) {
            [strongSelf updateDataSource:isRefresh];
            [strongSelf.skitAllHeaderView updateData:strongSelf.infoModel videoInfoModel:strongSelf.dataSources];
        }
    }];
}

- (void)updateDataSource:(BOOL)isFirst {
    self.tableView.rowHeight = CGRectGetHeight(self.tableView.frame);
    [self.tableView reloadData];

    if (isFirst) {
        int page = 0;
        DramaProgressModel *progressModel = [[DramaProgressModel alloc] initWithProgress:self.infoModel.p_progress];
        NSString *videoId = @"";
        for (int i = 0; i < self.dataSources.count; i++) {
            SkitVideoInfoModel *videoModel = self.dataSources[i];
            if (videoModel.episode_number == progressModel.episode_number) {
                page = i;
                videoId = videoModel.video_id;
                break;
            }
        }

        if (page == 0) {
            self.currentIndex = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadCell];
            });
        } else {
            int prePage = page - 1;
            if (prePage > 0 && self.dataSources.count > prePage) {
                SkitVideoInfoModel *videoModel = self.dataSources[prePage];
                [self selectVideo:videoModel.video_id];
            }
            int nextPage = page + 1;
            if (nextPage > 0 && self.dataSources.count > nextPage) {
                SkitVideoInfoModel *videoModel = self.dataSources[nextPage];
                [self selectVideo:videoModel.video_id];
            }
            [self selectVideo:videoId];
        }
    }
}

- (void)selectVideo:(NSString*)videoId {
    NSInteger index = [self.dataSources indexOfObjectPassingTest:^BOOL(SkitVideoInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.video_id == videoId;
    }];
    if (self.dataSources.count <= index) {
        return;
    }

    self.currentIndex = (int)index;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [self loadCell];
}

#pragma mark - UI
- (void)setupViews {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.allDramaListContainer];
    [self.allDramaListContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.equalTo(@66);
    }];

    [self.allDramaListContainer addSubview:self.skitAllHeaderView];
    [self.skitAllHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.allDramaListContainer).inset(12);
        make.left.right.equalTo(self.allDramaListContainer).inset(16);
    }];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.allDramaListContainer.mas_top);
    }];

    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[ImageBundle imagewithBundleName:@"fh-2"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.view).offset(8);
        make.size.equalTo(@44);
    }];

    UIButton *searchButton = [[UIButton alloc] init];
    [searchButton setImage:[ImageBundle imagewithBundleName:@"search_47"] forState:UIControlStateNormal];
    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.right.equalTo(self.view).offset(-8);
        make.size.equalTo(@44);
    }];

    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    self.tableView.rowHeight = CGRectGetHeight(self.tableView.frame);
}

- (void)loadCell {
    int index = self.currentIndex;
    if (index >= self.dataSources.count) {
        return;
    }

    if (self.dataSources.count > index + 1) {
        SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index + 1 inSection:0]];
        [cell.manager pauseVideo];
    }
    if (self.dataSources.count > index - 1 && index - 1 >= 0) {
        SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0]];
        [cell.manager pauseVideo];
    }

    SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    [self preloadVideo:index];
    if (index >= self.dataSources.count) {
        return;
    }

    SkitVideoInfoModel *model = self.dataSources[index];
    self.selectVideoId = model.video_id;
//    [self.manager setupVideoInfoWithCell:cell model:model infoModel:self.infoModel];
    [cell.manager startPlayVideo];
}

- (void)preloadVideo:(int)index {
    // TODO: bill wait to test
    return;
    [self.preloadManager reset];
    int nextIndex = index + 1;
    if (self.dataSources.count > nextIndex) {
        SkitVideoInfoModel *model = self.dataSources[nextIndex];
        [self.preloadManager addPreload:model];
    }

    int previusIndex = index - 1;
    if (self.dataSources.count > previusIndex && previusIndex >= 0) {
        SkitVideoInfoModel *model = self.dataSources[previusIndex];
        [self.preloadManager addPreload:model];
    }
}

#pragma mark - API
- (void)requestDrama:(NSString*)skitId completion:(nullable void (^)(BOOL success))completion {
    NSDictionary *dic = @{
        @"skit_pid": skitId
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Skit.getSkitListById" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            BOOL isFavorite = [minstr(info[@"is_favorite"]) boolValue];
            strongSelf.infoModel.is_favorite = isFavorite;

            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(NO);
                return;
            }

            NSArray *list = info[@"list"];
            if (![list isKindOfClass:[NSArray class]]) {
                completion(NO);
                return;
            }

            if (list.count <= 0) {
                completion(NO);
                return;
            }

            NSArray *models = [SkitVideoInfoModel mj_objectArrayWithKeyValuesArray:list];
            NSMutableArray *sortModels = [NSMutableArray array];
            for (SkitVideoInfoModel *element in models) {
                for (SkitVideoInfoModel *tempModel in strongSelf.dataSources) {
                    if ([tempModel.video_id isEqualToString:element.video_id]) {
                        continue;
                    }
                }
                [sortModels addObject:element];
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

+ (void)requestVideo:(NSString*)skitId autoDeduct:(BOOL)autoDeduct refresh_url:(BOOL)refresh_url completion:(nullable void (^)(SkitVideoInfoModel *newModel, BOOL success))completion {
    NSDictionary *dic = @{
        @"skit_id": skitId,
        @"refresh_url": minnum((refresh_url?1:0)),
        @"auto_deduct": autoDeduct ? @"true" : @"false"
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Skit.playSkit" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(nil, NO);
                return;
            }

            SkitVideoInfoModel *model = [SkitVideoInfoModel mj_objectWithKeyValues:info];

            if (model.video_url.length <= 0) {
                completion(nil, NO);
                return;
            }

            if (msg.length > 0) {
                MBProgressHUD *hud = [MBProgressHUD showSuccess:msg toView:[UIApplication sharedApplication].keyWindow];
                hud.userInteractionEnabled = false;
                hud.backgroundView.userInteractionEnabled = false;
            }

            if (autoDeduct) {
                [VideoTicketFloatView refreshFloatData];
            }

            completion(model, YES);
        } else {
            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(nil, NO);
                return;
            }

            SkitVideoInfoModel *model = [SkitVideoInfoModel mj_objectWithKeyValues:info];

            completion(model, NO);
//            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        completion(nil, NO);
    }];
}

#pragma mark - Action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)search {
    
}

- (void)showAllDrama {
    self.skitAllHeaderView.alpha = 0;
    SkitAllListView *view = [[SkitAllListView alloc] init];
    view.delegate = self;
    [view updateData:self.infoModel videoInfoModel:self.dataSources selectVideoId:self.selectVideoId];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.skitAllListView = view;
}

#pragma makr - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.scrollsToTop = NO;
        _tableView.allowsSelection = NO;
        _tableView.pagingEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_tableView registerClass:[SkitPlayerVideoCell self] forCellReuseIdentifier:@"SkitPlayerVideoCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)allDramaListContainer {
    if (!_allDramaListContainer) {
        _allDramaListContainer = [[UIView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllDrama)];
        [_allDramaListContainer addGestureRecognizer:tap];
    }
    return _allDramaListContainer;
}

- (SkitAllHeaderView *)skitAllHeaderView {
    if (!_skitAllHeaderView) {
        _skitAllHeaderView = [[SkitAllHeaderView alloc] init];
    }
    return _skitAllHeaderView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = [UIColor blackColor];
        _emptyView.hidden = YES;
        _emptyView.userInteractionEnabled = NO;

        UILabel *noDataLabel = [[UILabel alloc] init];
        noDataLabel.font = [UIFont systemFontOfSize:14];
        noDataLabel.textColor = UIColor.whiteColor;
        noDataLabel.text = YZMsg(@"DramaVideoViewController_video_not_available");
        [_emptyView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SkitPlayerVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SkitPlayerVideoCell" forIndexPath:indexPath];
    if (self.dataSources.count > indexPath.row) {
        SkitVideoInfoModel *model = self.dataSources[indexPath.row];
        [cell update:model infoModel:self.infoModel];
        [cell.manager setupVideoInfoWithCell:cell model:model infoModel:self.infoModel];
        cell.manager.delegate = self;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SkitPlayerVideoCell *shortCell = (SkitPlayerVideoCell*)cell;
    // 修正如果沒影片，滑出再滑入 controlView 會不見
    if (shortCell.controlView.superview == nil) {
        [shortCell.contentView addSubview:shortCell.controlView];
        shortCell.controlView.frame = cell.bounds;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        //UITableView禁止响应其他滑动手势
        scrollView.panGestureRecognizer.enabled = NO;

        int index = self.currentIndex;
        
        if(translatedPoint.y < -50 && index < (self.dataSources.count - 1)) {
            index ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50 && index > 0) {
            index --;   //向上滑动索引递减
        }

        if (self.currentIndex == index) {
            scrollView.panGestureRecognizer.enabled = YES;
            return;
        }

        self.currentIndex = index;
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            //UITableView滑动到指定cell
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } completion:^(BOOL finished) {
            [self loadCell];
            //UITableView可以响应其他滑动手势
            scrollView.panGestureRecognizer.enabled = YES;
        }];

    });
}

#pragma mark - SkitAllListViewDelegate
- (void)skitAllListViewDelegateForSelect:(NSString*)videoId {
    // TODO: bill change drama
    NSLog(@"bill change drama: %@", videoId);
    [self selectVideo:videoId];
}

- (void)skitAllListViewDelegateForClose {
    [UIView animateWithDuration:0.2 animations:^{
        self.skitAllHeaderView.alpha = 1;
    }];
}

#pragma mark - SkitPlayerManagerDelegate
- (void)skitPlayerManagerDelegateForEnd:(BOOL)isNext {
    SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    if (!isNext) {
        [cell.manager.player.currentPlayerManager play];
        if ([cell.manager.player.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
            [cell.manager.player.controlView videoPlayer:cell.manager.player loadStateChanged:ZFPlayerLoadStatePlayable];
        }
        return;
    }
    int nextIndex = self.currentIndex + 1;
    if (self.dataSources.count <= nextIndex) {
        [cell.manager.player.currentPlayerManager play];
        return;
    }

    SkitVideoInfoModel *model = self.dataSources[nextIndex];
    NSString *videoId = model.video_id;
    [self selectVideo:videoId];

    [self.skitAllListView updateData:self.infoModel videoInfoModel:self.dataSources selectVideoId:videoId];
}

- (void)skitPlayerManagerDelegateForChat {
    [MBProgressHUD showError:YZMsg(@"Please stay tuned")];
}

@end
