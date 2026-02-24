//
//  DramaVideoViewController.m
//  DramaTest
//
//  Created by s5346 on 2024/5/1.
//

#import "DramaVideoViewController.h"
#import "DramaPlayerManager.h"
#import "VideoTableViewCell.h"
#import "DramaAllHeaderView.h"
#import "DramaAllListView.h"
#import "DramaPreloadManager.h"
#import "VideoProgressManager.h"

@interface DramaVideoViewController () <UITableViewDelegate, UITableViewDataSource, DramaAllListViewDelegate, DramaPlayerManagerDelegate> {
    BOOL isLoading;
}
@property(nonatomic, strong) NSMutableArray<DramaVideoInfoModel*> *dataSources;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) DramaPlayerManager *manager;
@property(nonatomic, strong) UIView *allDramaListContainer;
@property(nonatomic, strong) DramaAllHeaderView *dramaAllHeaderView;
@property(nonatomic, strong) UIView *emptyView;
@property(nonatomic, strong) NSString *selectVideoId;
@property(nonatomic, strong) DramaPreloadManager *preloadManager;
@property(nonatomic, assign) int currentIndex;
@property(nonatomic, weak) DramaInfoModel *infoModel;
@property(nonatomic, weak) DramaAllListView *dramaAllListView;

@end

@implementation DramaVideoViewController

- (instancetype)initWithModel:(DramaInfoModel*)model
{
    self = [super init];
    if (self) {
        _infoModel = model;
        self.currentIndex = 0;
        self.preloadManager = [[DramaPreloadManager alloc] init];
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
        [self saveProgress:self.manager.player.currentTime
                     total:self.manager.player.totalTime
                   episode:self.manager.model.episode_number
                    skitId:self.manager.model.skit_id
                   videoId:self.manager.model.video_id];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        [self.preloadManager reset];
        [self.manager reset];
    }
}

- (void)dealloc {
    NSLog(@"DramaVideoViewController release");
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
        strongSelf->isLoading = NO;
        if (success) {
            [strongSelf updateDataSource:isRefresh];
            [strongSelf.dramaAllHeaderView updateData:strongSelf.infoModel videoInfoModel:strongSelf.dataSources];
        } else {
            strongSelf.emptyView.hidden = NO;
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
            DramaVideoInfoModel *videoModel = self.dataSources[i];
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
            [self selectVideo:videoId];
        }
    }
}

- (void)selectVideo:(NSString*)videoId {
    NSInteger index = [self.dataSources indexOfObjectPassingTest:^BOOL(DramaVideoInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)showPayInfo:(DramaVideoInfoModel*)model cell:(VideoTableViewCell*)cell {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:YZMsg(@"DramaVideoViewController_video_buy_ticket"), (int)model.need_ticket_count] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WeakSelf
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf loadVideo:model cell:cell];
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
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

    [self.allDramaListContainer addSubview:self.dramaAllHeaderView];
    [self.dramaAllHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
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

    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    self.tableView.rowHeight = CGRectGetHeight(self.tableView.frame);
}

- (void)loadCell {
    [self saveProgress:self.manager.player.currentTime
                 total:self.manager.player.totalTime
               episode:self.manager.model.episode_number
                skitId:self.manager.model.skit_id
               videoId:self.manager.model.video_id];

    int index = self.currentIndex;
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.controlView.slider.player = self.manager.player;

    [self preloadVideo:index];
    if (index >= self.dataSources.count) {
        return;
    }

    DramaVideoInfoModel *model = self.dataSources[index];
    self.selectVideoId = model.video_id;
    [self.manager setupVideoInfoWithCell:cell model:model infoModel:self.infoModel];

    if (model.isNeedPay) {
        [self showPayInfo:model cell:cell];
    } else {
        [self loadVideo:model cell:cell];
    }
}

- (void)loadVideo:(DramaVideoInfoModel*)model cell:(VideoTableViewCell*)cell {
    if (model.play_url.length > 0) {
        [self.manager setupVideoInfoWithCell:cell model:model infoModel:self.infoModel];
        [self.manager playVideo:model];
        return;
    }

    WeakSelf
    [self requestVideo:model.video_id completion:^(NSString *url, int ticketCount, BOOL success) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (!success) {
            return;
        }

        model.play_url = url;
        strongSelf.infoModel.skit_ticket_count = ticketCount;
        model.is_buy = YES;
        [strongSelf.manager setupVideoInfoWithCell:cell model:model infoModel:strongSelf.infoModel];
        [strongSelf.manager playVideo:model];
    }];
}

- (void)preloadVideo:(int)index {
    [self.preloadManager reset];
    int nextIndex = index + 1;
    if (self.dataSources.count > nextIndex) {
        DramaVideoInfoModel *model = self.dataSources[nextIndex];
        [self.preloadManager addPreload:model];
    }

    int previusIndex = index - 1;
    if (self.dataSources.count > previusIndex && previusIndex >= 0) {
        DramaVideoInfoModel *model = self.dataSources[previusIndex];
        [self.preloadManager addPreload:model];
    }
}

#pragma mark - API
- (void)requestDrama:(NSString*)skitId completion:(nullable void (^)(BOOL success))completion {
    NSDictionary *dic = @{
        @"skit_pid": skitId
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getSkitListById" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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

            NSArray *models = [DramaVideoInfoModel mj_objectArrayWithKeyValuesArray:list];
            NSArray *sortModels = [models sortedArrayUsingComparator:^NSComparisonResult(DramaVideoInfoModel*  _Nonnull obj1, DramaVideoInfoModel* _Nonnull obj2) {
                return [@(obj1.episode_number) compare:@(obj2.episode_number)];
            }];
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

- (void)requestVideo:(NSString*)skitId completion:(nullable void (^)(NSString *url, int ticketCount, BOOL success))completion {
    NSDictionary *dic = @{
        @"skit_id": skitId
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.watchSkit" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(@"", 0, NO);
                return;
            }

            NSDictionary *dic = info[@"skit_info"];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                completion(@"", 0, NO);
                return;
            }

            NSString *url = minstr(dic[@"url"]);
            int ticketCount = [minstr(info[@"skit_ticket_count"]) intValue];
            completion(url, ticketCount, YES);
        } else {
            completion(@"", 0, NO);
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        completion(@"", 0, NO);
    }];
}

- (void)saveProgress:(NSTimeInterval)currentTime total:(NSTimeInterval)totalTime episode:(NSInteger)episode skitId:(NSString*)skitId videoId:(NSString*)videoId {
    if (currentTime <= 0) {
        return;
    }

    if ((int)currentTime == (int)totalTime) {
        currentTime = 0;
    }

    NSString *p_progress = [NSString stringWithFormat:@"%ld|%d|%d",
                            episode,
                            (int)currentTime,
                            (int)totalTime];

    NSString *progress = [NSString stringWithFormat:@"%d|%d",
                          (int)currentTime,
                          (int)totalTime];

    [VideoProgressManager saveUserProgress:progress skitId:skitId episodeNumber:episode];

    NSDictionary *dic = @{
        @"skit_id": videoId,
        @"p_progress": p_progress,
        @"progress": p_progress
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.updateWatchingProcess" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf.infoModel.p_progress = p_progress;
            NSDictionary *infoDic = @{@"skitId": skitId,
                                      @"progress": p_progress};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DramaListUpdate"
                                                                object:nil
                                                              userInfo:infoDic];
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {

    }];
}

#pragma mark - Action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAllDrama {
    self.dramaAllHeaderView.alpha = 0;
    DramaAllListView *view = [[DramaAllListView alloc] init];
    view.delegate = self;
    [view updateData:self.infoModel videoInfoModel:self.dataSources selectVideoId:self.selectVideoId];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.dramaAllListView = view;
}

#pragma makr - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.allowsSelection = NO;
        _tableView.pagingEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_tableView registerClass:[VideoTableViewCell self] forCellReuseIdentifier:@"cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (DramaPlayerManager *)manager {
    if (!_manager) {
        _manager = [[DramaPlayerManager alloc] initWithTableView:self.tableView];
        _manager.delegate = self;
    }
    return _manager;
}

- (UIView *)allDramaListContainer {
    if (!_allDramaListContainer) {
        _allDramaListContainer = [[UIView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllDrama)];
        [_allDramaListContainer addGestureRecognizer:tap];
    }
    return _allDramaListContainer;
}

- (DramaAllHeaderView *)dramaAllHeaderView {
    if (!_dramaAllHeaderView) {
        _dramaAllHeaderView = [[DramaAllHeaderView alloc] init];
    }
    return _dramaAllHeaderView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = [UIColor blackColor];
        _emptyView.hidden = YES;

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
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.dataSources.count > indexPath.row) {
        [cell update:self.dataSources[indexPath.row] infoModel:self.infoModel];
    }
    return cell;
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

#pragma mark - DramaAllListViewDelegate
- (void)dramaAllListViewDelegateForSelect:(NSString*)videoId {
    // TODO: bill change drama
    NSLog(@"bill change drama: %@", videoId);
    [self selectVideo:videoId];
}

- (void)dramaAllListViewDelegateForClose {
    [UIView animateWithDuration:0.2 animations:^{
        self.dramaAllHeaderView.alpha = 1;
    }];
}

#pragma mark - DramaPlayerManagerDelegate
- (void)dramaPlayerManagerDelegateForEnd:(BOOL)isNext {
    NSTimeInterval currentTime = self.manager.player.totalTime;
    NSTimeInterval totalTime = self.manager.player.totalTime;
    NSInteger episode_number = self.manager.model.episode_number;
    NSString *skitId = self.manager.model.skit_id;
    NSString *endVideoId = self.manager.model.video_id;
    if (!isNext) {
        [self saveProgress:currentTime total:totalTime episode:episode_number skitId:skitId videoId:endVideoId];
        [self.manager.player.currentPlayerManager reloadPlayer];
        if ([self.manager.player.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
            [self.manager.player.controlView videoPlayer:self.manager.player loadStateChanged:ZFPlayerLoadStatePlayable];
        }
        return;
    }
    int nextIndex = self.currentIndex + 1;
    if (self.dataSources.count <= nextIndex) {
        [self saveProgress:currentTime total:totalTime episode:episode_number skitId:skitId videoId:endVideoId];
        return;
    }

    DramaVideoInfoModel *model = self.dataSources[nextIndex];
    NSString *videoId = model.video_id;
    [self selectVideo:videoId];

    [self.dramaAllListView updateData:self.infoModel videoInfoModel:self.dataSources selectVideoId:videoId];
    [self saveProgress:currentTime total:totalTime episode:episode_number skitId:skitId videoId:endVideoId];
}

- (void)dramaPlayerManagerDelegateForTapPay:(DramaVideoInfoModel*)model {
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat viewH = CGRectGetHeight(self.tableView.frame);

    int index = offsetY / viewH;
    VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    [self showPayInfo:model cell:cell];
}

@end
