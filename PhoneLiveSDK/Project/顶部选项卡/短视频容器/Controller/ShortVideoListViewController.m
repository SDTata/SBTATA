//
//  ShortVideoListViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoListViewController.h"
#import "ShortVideoManager.h"
#import "ShortVideoTableViewCell.h"
#import "HomeSearchVC.h"
#import "ZYTabBarController.h"
#import "otherUserMsgVC.h"
#import "LiveStreamViewCell.h"
#import "EnterLivePlay.h"
#import "AnimRefreshHeader.h"
#import "VideoCommentsView.h"
#import "DirectionPanGestureRecognizer.h"
#import <UMCommon/UMCommon.h>
#import "ExpandCommentVideoView.h"

@interface ShortVideoListViewController ()<UITableViewDelegate, UITableViewDataSource, ShortVideoPlayerManagerDelegate, LiveStreamViewCellDelegate, VideoCommentsViewDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSString *hostString;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, assign) NSInteger page;
@property(nonatomic, strong) NSMutableArray *dataSources;
@property(nonatomic, assign) int currentIndex;
@property(nonatomic, strong) UIView *emptyView;
//@property(nonatomic, strong) ShortVideoManager *manager;
@property(nonatomic, strong) ShortVideoTableViewCell *shortCell;
@property (nonatomic, strong) VideoCommentsView *commentsView;
@property (nonatomic, assign) CGFloat commentViewHeight;
@property (nonatomic, strong) NSLayoutConstraint *videoViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *videoViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentViewBottomConstraint;
@property (nonatomic, strong) ExpandCommentVideoView *coverImgView;
@property (nonatomic, strong) UIView *coverTouchView;
@property (nonatomic, assign) BOOL isFromMessageList;
@property (nonatomic, assign) BOOL isViewAppearing;
@property (nonatomic, strong) NSString *fromMessageCommentId;
@property (nonatomic, strong) NSString *fromMessageCommentMessageId;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSInteger remainingSeconds;
@property (nonatomic, strong) NSMutableSet<ShortVideoTableViewCell*> *cacheShortVideoCells;
@property (nonatomic, strong) NSMutableSet<LiveStreamViewCell*> *cacheLiveCells;
@property (nonatomic, strong) NSMutableArray<ShortVideoModel*> *insertDataSources;
@property (nonatomic, assign) BOOL isUpdateTableViewLayout;
@property (nonatomic, strong) NSMutableArray *liveIds;
@end

@implementation ShortVideoListViewController

- (instancetype)initWithHost:(NSString*)host
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadLiveplayAttion:) name:@"reloadLiveplayAttion" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterBackground)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterForeground)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        self.hostString = host;
        self.cacheShortVideoCells = [NSMutableSet set];
        self.cacheLiveCells = [NSMutableSet set];
        self.insertDataSources = [NSMutableArray array];
        self.liveIds = [NSMutableArray array];
    }
    return self;
}

- (void)appWillEnterBackground {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    if ([cell isKindOfClass:[LiveStreamViewCell class]]) {
        [(LiveStreamViewCell*)cell mute];
    }
}

- (void)appDidEnterForeground {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    if ([cell isKindOfClass:[LiveStreamViewCell class]]) {
        if (self.isViewAppearing) {
            [(LiveStreamViewCell*)cell play];
        } else {
            [(LiveStreamViewCell*)cell mute];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hostString.length <= 0) {
        [self hideTabBar];
    }

    [self changeStyle];

    if (self.countdownTimer == nil) {
        if (self.dataSources.count > 0) {
            if (self.isUpdateTableViewLayout) {
                self.isUpdateTableViewLayout = NO;
                [self.tableView reloadData];
                WeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    [strongSelf loadCell];
                });
            } else {
                [self.tableView reloadData];
                WeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    [strongSelf loadCell];
                });
            }
        }
    } else {
        [self cancelCountdown];
        [self loadCell];
    }
    
    //禁用屏幕左滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.isViewAppearing = YES;
    [self changeStyle];

    [self cellPause:NO index:self.currentIndex];

    self.tableView.scrollEnabled = YES;

    WeakSelf
    vkGcdAfter(0.1, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.hostString.length <= 0) {
            return;
        }
        if (!strongSelf.commentsView.isHidden) {
            [strongSelf showCommentView];
            [strongSelf hideTabBar];
        } else {
            [strongSelf showTabBar];
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isViewAppearing = NO;

    if (self.dataSources.count <= self.currentIndex) {
        return;
    }

    [self pauseAll];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.superPagerVC != nil || [self.navigationController.viewControllers containsObject:self]) {
        [self startCountdown];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isViewAppearing = YES;
    
    // 确保视图已添加到层次结构后再进行布局
    [self setupViews];
    
    // 延迟执行布局相关操作，确保视图已经添加到层次结构中
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.toUid.length <= 0) {
            [self refresh];
        }
    });
}

- (void)handleRefresh {
    [self.tableView.mj_header beginRefreshing];
}

- (void)showVideoCommentWithID:(NSString *)comment_id messageId:(NSString *)message_id {
    self.isFromMessageList = YES;
    self.fromMessageCommentId = comment_id;
    self.fromMessageCommentMessageId = message_id;
}

- (void)reloadLiveplayAttion:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *isattention = minstr([dic valueForKey:@"isattent"]);
        NSString *uid = minstr([dic valueForKey:@"uid"]);
        for (int i = 0; i<self.dataSources.count; i++) {
            ShortVideoModel *model = self.dataSources[i];
            if (![model isKindOfClass:[ShortVideoModel class]]) {
                continue;
            }
            if ([model.uid isEqualToString:uid]) {
                model.is_follow = isattention.integerValue;
                break;
            }
        }
    }
}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    self.tableView.rowHeight = CGRectGetHeight(self.tableView.frame);
//}

// 外部指定 index
- (void)updateData:(NSArray<ShortVideoModel*>*)models selectIndex:(NSInteger)index fetchMore:(BOOL)fetchMore {
    if (self.dataSources.count == models.count) {
        return;
    }

    [self pauseAll];
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.tableView.rowHeight = CGRectGetHeight(strongSelf.tableView.frame);
        if (strongSelf.tableView.rowHeight == 0) {
            strongSelf.tableView.rowHeight = SCREEN_HEIGHT;
        }
        strongSelf.dataSources = [NSMutableArray arrayWithArray:models];

        [strongSelf.tableView reloadData];

        strongSelf.isLoading = NO;
        if (index >= 0) {
            strongSelf.currentIndex = (int)index;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [strongSelf.tableView setContentOffset:CGPointMake(0, strongSelf.tableView.rowHeight * index)];
            vkGcdAfter(0.5, ^{
                [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                [strongSelf loadCell];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf cellPause:NO index:strongSelf.currentIndex];
            });
        }
        if (fetchMore) {
            [strongSelf fetchMoreList];
        }
    });
}

- (void)insertModelAndOrderToIndex:(ShortVideoModel*)model {
    [self pauseAll];
    int index = -1;
    for (int i = 0; i<self.dataSources.count; i++) {
        ShortVideoModel *oldModel = self.dataSources[i];
        if (![oldModel isKindOfClass:[ShortVideoModel class]]) {
            continue;
        }
        if ([oldModel.video_id isEqualToString:model.video_id]) {
            index = i;
            break;
        }
    }

    if (index == -1) {
        [self.insertDataSources addObject:model];
        if (!self.isViewLoaded) {
            return;
        }
        index = 0;
        [self.dataSources insertObject:model atIndex:0];
        [self.tableView reloadData];
    }

    self.currentIndex = (int)index;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [self loadCell];
}

- (void)changeStyle {
    if ([self.delegate respondsToSelector:@selector(changeSegmentStyle:)]) {
        if (self.dataSources.count <= 0) {
            [self.delegate changeSegmentStyle:SegmentStyleLine];
            self.tableView.backgroundColor = [UIColor clearColor];
            self.view.backgroundColor = [UIColor clearColor];
        } else {
            [self.delegate changeSegmentStyle:SegmentStyleLineWithWhite];
            self.tableView.backgroundColor = [UIColor blackColor];
            self.view.backgroundColor = [UIColor blackColor];
        }
    }
}

- (void)refresh {
    if (self.hostString.length <= 0) {
        [self.tableView reloadData];
        return;
    }

    for (int i = 0; i<self.dataSources.count; i++) {
        [self cellPause:YES index:i];
    }

    self.dataSources = [NSMutableArray array];
    self.liveIds = [NSMutableArray array];
    self.hasMore = YES;
    self.page = 1;
    [self fetchDataIsRefresh:YES page:1];
}

- (void)fetchMoreList {
    if (self.hostString.length <= 0) {
        if (self.fetchMoreBlock) {
            self.isLoading = YES;
            self.fetchMoreBlock();
        }
        return;
    }
    NSInteger page = self.page + 1;
    [self fetchDataIsRefresh:NO page:page];
}

- (void)fetchDataIsRefresh:(BOOL)isRefresh page:(NSInteger)page {
    if (self.isLoading || !self.hasMore) {
        return;
    }
    self.isLoading = YES;

    WeakSelf
    [self requestList:page completion:^(BOOL success) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableView.mj_header endRefreshing];
        strongSelf.isLoading = NO;
        strongSelf.hasMore = success;
        strongSelf.emptyView.hidden = strongSelf.dataSources.count > 0;
        if (success) {
            strongSelf.page = page;
            [strongSelf updateDataSource:isRefresh];
            if (page == 1 && isRefresh && (strongSelf.dataSources.count < 3 && strongSelf.dataSources.count > 0)) {
                [strongSelf fetchMoreList];
            }
        } else if (page == 1) {
            [strongSelf.tableView reloadData];
            strongSelf.tableView.scrollEnabled = YES;
        }
        [strongSelf changeStyle];
    }];
}

- (void)updateDataSource:(BOOL)isFirst {
    self.tableView.rowHeight = CGRectGetHeight(self.tableView.frame);
    [self pauseAll];
    [self.tableView reloadData];

    if (isFirst && self.insertDataSources.count > 0) {
        ShortVideoModel *model = self.insertDataSources.firstObject;
        [self insertModelAndOrderToIndex:model];
        return;
    }

    if (isFirst) {
        self.currentIndex = 0;
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.tableView setContentOffset:CGPointMake(0, 1) animated:YES];
            [strongSelf loadCell];
        });
    } else {
        if (self.isViewAppearing) {
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf cellPause:NO index:strongSelf.currentIndex];
            });
        }
    }
}

- (void)selectVideo:(NSString*)videoId {
    NSInteger index = [self.dataSources indexOfObjectPassingTest:^BOOL(ShortVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)back {
//    if (!self.isFromMessageList) {
        [self.navigationController popViewControllerAnimated:YES];
//    }
//    [[MXBADelegate sharedAppDelegate] popViewController:YES];
}

- (void)pauseAll {
    for (ShortVideoTableViewCell *cell in self.cacheShortVideoCells) {
        [[cell manager] pauseVideo];
    }
    for (LiveStreamViewCell *cell in self.cacheLiveCells) {
        [cell mute];
    }
}

- (void)cellPause:(BOOL)isPause index:(int)index {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if ([cell isKindOfClass:[ShortVideoTableViewCell class]]) {
        if (isPause) {
            [[(ShortVideoTableViewCell*)cell manager] pauseVideo];
        } else {
            [[(ShortVideoTableViewCell*)cell manager] startPlayVideo];
        }
    } else if ([cell isKindOfClass:[LiveStreamViewCell class]]) {
        if (isPause) {
            [(LiveStreamViewCell*)cell mute];
        } else {
            [(LiveStreamViewCell*)cell play];
        }
    }
}

- (void)cellStopForIndex:(int)index {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if ([cell isKindOfClass:[ShortVideoTableViewCell class]]) {
        [[(ShortVideoTableViewCell*)cell manager] stopVideo];
    } else if ([cell isKindOfClass:[LiveStreamViewCell class]]) {
        [(LiveStreamViewCell*)cell stop];
    }
}

- (void)removeAllCellPlayerManager {
    for (ShortVideoTableViewCell *cell in self.cacheShortVideoCells) {
        [cell removePlayerManager];
    }
    self.cacheShortVideoCells = [NSMutableSet set];

    for (LiveStreamViewCell *cell in self.cacheLiveCells) {
        [cell removePlayer];
    }
    self.cacheLiveCells = [NSMutableSet set];
}

- (void)updateBlock {
    if (self.currentIndexBlock) {
        if (self.dataSources.count > self.currentIndex) {
            ShortVideoModel *model = self.dataSources[self.currentIndex];
            self.currentIndexBlock(model.video_id);
        }
    }

    if (self.getViewCurrentIndexBlock) {
        if (self.dataSources.count > self.currentIndex) {
            ShortVideoModel *model = self.dataSources[self.currentIndex];
            UIView *cell = self.getViewCurrentIndexBlock(model.video_id);
            self.ttcTransitionDelegate.smalCurPlayCell = cell;
        }
    }
}

#pragma mark - 倒數計時
- (void)startCountdown {
    [self cancelCountdown];
    self.remainingSeconds = 5;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateCountdown)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)updateCountdown {
    if (self.remainingSeconds > 0) {
        NSLog(@"<>>>剩餘時間: %ld 秒", (long)self.remainingSeconds);
        self.remainingSeconds--;
    } else {
        [self removeAllCellPlayerManager];
        [self cancelCountdown];
    }
}

- (void)cancelCountdown {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
}

#pragma mark - API
- (void)requestList:(NSInteger)page completion:(nullable void (^)(BOOL success))completion {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"p"] = minnum(page);
    if (self.toUid.length > 0) {
        dic[@"to_uid"] = self.toUid;
    }

    if ([self.hostString containsString:HotHost]) {
        dic[@"refresh"] = page <=1?@"1":@"0";
    }
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:self.hostString withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSArray *list = nil;
        if (code == 0) {
            if ([strongSelf.hostString isEqualToString:@"ShortVideo.getMyVideos"]) {
                if (![info isKindOfClass:[NSDictionary class]]) {
                    completion(NO);
                    return;
                }

                NSArray *video_list = info[@"video_list"];
                if (![video_list isKindOfClass:[NSArray class]]) {
                    completion(NO);
                    return;
                }
                list = video_list;
            } else {
                list = info;
            }

            if (![list isKindOfClass:[NSArray class]]) {
                completion(NO);
                return;
            }

            if (list.count <= 0) {
                completion(NO);
                return;
            }

            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *tempDic in list) {
                if (![tempDic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                if ([minstr(tempDic[@"video_type"]) isEqualToString:@"live"]) {
                    hotModel *model = [hotModel mj_objectWithKeyValues:tempDic];
                    if (![strongSelf.liveIds containsObject:model.zhuboID]) {
                        [strongSelf.liveIds addObject:model.zhuboID];
                        [models addObject:model];
                    }
                } else {
                    ShortVideoModel *model = [ShortVideoModel mj_objectWithKeyValues:tempDic];
                    [models addObject:model];
                }
            }

            NSMutableArray *newArray = [NSMutableArray arrayWithArray:models];
            for (ShortVideoModel *model in models) {
                if (![model isKindOfClass:[ShortVideoModel class]]) {
                    continue;
                }

                for (ShortVideoModel *insertModel in strongSelf.insertDataSources) {
                    if ([insertModel.video_id isEqualToString:model.video_id]) {
                        [newArray removeObject:model];
                    }
                }
            }

            models = newArray;

//            NSMutableArray *newArray = [NSMutableArray array];
//            for (ShortVideoModel *model in models) {
//                BOOL isNew = YES;
//                for (ShortVideoModel *oldModel in strongSelf.dataSources) {
//                    if ([oldModel.video_id isEqualToString:model.video_id]) {
//                        isNew = NO;
//                        break;
//                    }
//                }
//                if (isNew) {
//                    [newArray addObject:model];
//                }
//            }

            if (models.count > 0) {
                [strongSelf.dataSources addObjectsFromArray:models];
                completion(YES);
                return;
            }
            completion(NO);
        } else {
            completion(NO);
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

+ (void)requestVideo:(NSString*)videoId autoDeduct:(BOOL)autoDeduct refresh_url:(BOOL)refresh_url completion:(nullable void (^)(ShortVideoModel *newModel, BOOL success, NSString *errorMsg))completion {
    if (videoId == nil) {
        return;
    }
    NSDictionary *dic = @{
        @"video_id": videoId,
        @"refresh_url": minnum((refresh_url?1:0)),
        @"auto_deduct": autoDeduct ? @"true" : @"false"
    };
//    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"ShortVideo.playVideo" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
        if (code == 0) {
            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(nil, NO, nil);
                return;
            }

            ShortVideoModel *model = [ShortVideoModel mj_objectWithKeyValues:info];

            if (model.video_url.length <= 0) {
                completion(nil, NO, nil);
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

            completion(model, YES, msg);
        } else {
            if (![info isKindOfClass:[NSDictionary class]]) {
                completion(nil, NO, nil);
                return;
            }

            ShortVideoModel *model = [ShortVideoModel mj_objectWithKeyValues:info];
            completion(model, NO, msg);
        }
    } fail:^(NSError * _Nonnull error) {
        completion(nil, NO, nil);
    }];
}

#pragma mark - UI
- (void)setupViews {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    WeakSelf
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.hostString.length > 0 && strongSelf.toUid.length <= 0) {
            make.top.left.right.equalTo(strongSelf.view);
            // 使用mas_updateConstraints而不是添加新约束
            if (strongSelf.tabBarController) {
                CGFloat tabBarHeight = ((ZYTabBarController *)strongSelf.tabBarController).tabBar.frame.size.height;
                make.bottom.equalTo(strongSelf.view).offset(-tabBarHeight);
            } else {
                make.bottom.equalTo(strongSelf.view);
            }
        } else {
            make.left.top.right.equalTo(strongSelf.view);
            make.bottom.equalTo(strongSelf.view).offset(-kSafeBottomHeight);
        }
    }];

    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    self.tableView.rowHeight = CGRectGetHeight(self.tableView.frame);

    if (self.hostString.length <= 0 || self.toUid.length > 0) {
        UIButton *backButton = [[UIButton alloc] init];
        [backButton setImage:[ImageBundle imagewithBundleName:@"fh-2"] forState:UIControlStateNormal];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButton];
        WeakSelf
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            make.top.equalTo(strongSelf.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(strongSelf.view).offset(8);
            make.size.equalTo(@44);
        }];
    }

    // 初始化视频视图
    self.coverImgView = [[ExpandCommentVideoView alloc] init];
    [self.coverImgView setHidden:YES];
    [self.view addSubview:self.coverImgView];
    self.videoViewHeightConstraint = [self.coverImgView.heightAnchor constraintEqualToConstant:self.tableView.height];
    self.videoViewWidthConstraint = [self.coverImgView.widthAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width];
    self.videoViewTopConstraint = [self.coverImgView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:[UIApplication sharedApplication].keyWindow.safeAreaInsets.top];
    [NSLayoutConstraint activateConstraints:@[
//        [self.coverImgView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
//        [self.coverImgView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
//        [self.coverImgView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.coverImgView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        self.videoViewHeightConstraint,
        self.videoViewWidthConstraint,
        self.videoViewTopConstraint
    ]];
    
    self.coverTouchView = [[UIView alloc] init];
    self.coverTouchView.userInteractionEnabled = YES;
    [self.coverTouchView setHidden:YES];
    [self.coverTouchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverImgViewGesture:)]];
    [self.view addSubview:self.coverTouchView];
    [self.coverTouchView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        make.top.left.right.equalTo(strongSelf.view);
        make.height.mas_equalTo(strongSelf.coverImgView);
    }];
    
    // 初始化评论视图
    self.commentsView = [[VideoCommentsView alloc] init];
    self.commentsView.delelgate = self;
    [self.commentsView setHidden:YES];
    self.commentsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.commentsView];
    
    // 设置 commentView 高度为屏幕高度的 75%
    self.commentViewHeight = UIScreen.mainScreen.bounds.size.height * 0.7;
    self.commentViewBottomConstraint = [self.commentsView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.commentViewHeight];

    [NSLayoutConstraint activateConstraints:@[
        [self.commentsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.commentsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.commentsView.heightAnchor constraintEqualToConstant:self.commentViewHeight],
        self.commentViewBottomConstraint
    ]];
    
    // 添加滑动手势识别器
    DirectionPanGestureRecognizer *panGesture = [[DirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.direction = DirectionPangestureRecognizerVertical;
    panGesture.delegate = self;
    [self.commentsView addGestureRecognizer:panGesture];
}

- (void)updateTableViewLayout:(CGFloat)height {
    self.isUpdateTableViewLayout = YES;
    // 使用mas_updateConstraints避免约束冲突
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-height);
    }];
    [self.view layoutIfNeeded];
    self.tableView.height = self.view.height - height;
    self.tableView.rowHeight = self.tableView.height;
}

- (void)loadCell {
    int index = self.currentIndex;

    if (index >= self.dataSources.count) {
        return;
    }

    [self updateBlock];

    [self cellStopForIndex:index + 2];
    [self cellStopForIndex:index - 2];
    [self cellPause:YES index:index + 1];
    [self cellPause:YES index:index - 1];

    ShortVideoModel *model = self.dataSources[index];
    if ([model.video_type isEqualToString:@"live"]) {
        LiveStreamViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        hotModel *model = self.dataSources[index];
        [cell update:model];
        [cell play];
        return;
    }

    ShortVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell layoutSubviews];
//    cell.controlView.slider.player = self.manager.player;

//    self.selectVideoId = model.video_id;
//    [cell.manager setupVideoInfoWithCell:cell model:model];
    if (self.isViewAppearing) {
        [cell.manager startPlayVideo];
    }
    
    if (self.isFromMessageList) {
        self.commentsView.video_id = model.video_id;
        self.commentsView.isVideoOwner = [model.uid isEqualToString:[Config getOwnID]];
        self.commentsView.focus_comment_id = self.fromMessageCommentId;
        self.commentsView.message_id = self.fromMessageCommentMessageId;
        self.commentsView.comments_count = [NSString stringWithFormat: @"%ld", (long)model.comments_count];
        self.commentsView.page = 1;
        [self.commentsView loadlistData];
        [self showCommentView];
    }
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.scrollsToTop = NO;
        _tableView.allowsSelection = NO;
        _tableView.pagingEnabled = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        // 确保在注册cell时使用正确的类引用方式
//        [_tableView registerClass:[ShortVideoTableViewCell class] forCellReuseIdentifier:@"ShortVideoTableViewCell"];
        [_tableView registerClass:[LiveStreamViewCell class] forCellReuseIdentifier:@"LiveStreamViewCell"];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.decelerationRate = UIScrollViewDecelerationRateFast;

        if (self.hostString.length > 0) {
            WeakSelf
            AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                NSLog(@"<>>>%@",NSStringFromUIEdgeInsets(strongSelf.tableView.contentInset));
                strongSelf.insertDataSources = [NSMutableArray array];
                [strongSelf refresh];
            }];
            refreshHeader.ignoredScrollViewContentInsetTop = -(80);
            [_tableView setMj_header:refreshHeader];
        }
    }
    return _tableView;
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
        if ([self.hostString containsString:HotHost]) {
            noDataLabel.text = YZMsg(@"public_noEmpty");
        }else if ([self.hostString containsString:FollowedHost]){
            noDataLabel.text = YZMsg(@"DramaFavoriteViewController_empty_follow");
        }else if ([self.hostString containsString:LikeHost]){
            noDataLabel.text = YZMsg(@"DramaFavoriteViewController_empty_like");
        }else{
            noDataLabel.text = YZMsg(@"Not Search Any Result");
        }
        
        
        [_emptyView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}

//- (ShortVideoManager *)manager {
//    if (!_manager) {
//        _manager = [[ShortVideoManager alloc] initWithTableView:self.tableView];
//        _manager.delegate = self;
//    }
//    return _manager;
//}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = ((ZYTabBarController *)self.tabBarController).bgView.frame.size.height;
    if (self.dataSources.count > indexPath.row) {
        ShortVideoModel *model = self.dataSources[indexPath.row];
        if ([model.video_type isEqualToString:@"live"]) {
            LiveStreamViewCell *cell = (LiveStreamViewCell*)[tableView dequeueReusableCellWithIdentifier:@"LiveStreamViewCell" forIndexPath:indexPath];
            WeakSelf
            cell.delegate = weakSelf;
            [cell update:self.dataSources[indexPath.row]];
            [self.cacheLiveCells addObject:cell];
            return cell;
        } else {
            ShortVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShortVideoTableViewCell"];
            if (cell == nil) {
                cell = [[ShortVideoTableViewCell alloc] initWithTabbarHeight:height+1 style: UITableViewCellStyleDefault reuseIdentifier:@"ShortVideoTableViewCell"];
            }
            [cell update:model isShowCreateTime:self.showCreateTime];
          
            [self.cacheShortVideoCells addObject:cell];
            WeakSelf
            [cell.manager setupVideoInfoWithCell:cell model:model isShowCreateTime:self.showCreateTime];
            cell.manager.delegate = weakSelf;
            return cell;
        }
    }
    return [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSources.count - 3 == indexPath.row) {
        [self fetchMoreList];
    }
    
    if (![cell isKindOfClass:[ShortVideoTableViewCell class]]) {
        return;
    }
    self.shortCell = (ShortVideoTableViewCell*)cell;
    // 修正如果沒影片，滑出再滑入 controlView 會不見
    if (self.shortCell.controlView.superview == nil) {
        [self.shortCell.contentView addSubview:self.shortCell.controlView];
        self.shortCell.controlView.frame = self.shortCell.contentView.bounds;
        [self hideCommentView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        scrollView.panGestureRecognizer.enabled = NO;

        int index = self.currentIndex;
        if(translatedPoint.y < -50 && index < (self.dataSources.count - 1)) {
            index ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50 && index > 0) {
            index --;   //向上滑动索引递减
        }

        if (self.dataSources.count <= index) {
            return;
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        scrollView.panGestureRecognizer.enabled = NO;
        CGFloat offsetY = self.tableView.contentOffset.y;
        CGFloat viewH = CGRectGetHeight(self.tableView.frame);
        int index = offsetY / viewH;

        if (self.dataSources.count <= index) {
            scrollView.panGestureRecognizer.enabled = YES;
            return;
        }

        if (self.currentIndex == index) {
            scrollView.panGestureRecognizer.enabled = YES;
            return;
        }

        self.currentIndex = index;
WeakSelf
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            //UITableView滑动到指定cell
            [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [strongSelf pauseAll];
        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf loadCell];
            //UITableView可以响应其他滑动手势
            scrollView.panGestureRecognizer.enabled = YES;
        }];

    });
}

#pragma mark - ShortVideoPlayerManagerDelegate
- (void)shortVideoPlayerManagerDelegateForEnd:(BOOL)isNext {
    ShortVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    if (!isNext) {
        if ([cell isKindOfClass:[ShortVideoTableViewCell class]]) {
            if (cell.manager.player.currentPlayerManager.totalTime<=30) {
                [cell.manager.player.currentPlayerManager reloadPlayer];
            }
            [cell.manager.player seekToTime:cell.manager.player.currentPlayerManager.totalTime>30?1:0 completionHandler:^(BOOL finished) {
                [cell.manager.player.currentPlayerManager play];
            }];
            if ([cell.manager.player.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                [cell.manager.player.controlView videoPlayer:cell.manager.player loadStateChanged:ZFPlayerLoadStatePlayable];
            }
        }
        return;
    }
    int nextIndex = self.currentIndex + 1;
    if (self.dataSources.count <= nextIndex) {
        return;
    }

    self.currentIndex = nextIndex;

//    ShortVideoModel *model = self.dataSources[nextIndex];
//    NSString *videoId = model.video_id;
//    [self selectVideo:videoId];
    self.tableView.panGestureRecognizer.enabled = NO;
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } completion:^(BOOL finished) {
        [self loadCell];
        self.tableView.panGestureRecognizer.enabled = YES;
    }];
}

- (void)shortVideoPlayerManagerDelegateForTapHashtag:(NSString*)hashtag {
    HomeSearchVC *searchVC = [HomeSearchVC new];
    searchVC.type = 2;
    searchVC.key = [hashtag stringByReplacingOccurrencesOfString:@"#" withString:@""];;
    searchVC.isFromHashTag = YES;
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    //[self.navigationController presentViewController:nav animated:YES completion:nil];
    [self.navigationController pushViewController:searchVC animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"tag":hashtag};
    [MobClick event:@"shortvideo_videotag_click" attributes:dict];
}

// 点击打开评论
- (void)shortVideoPlayerManagerDelegateForTapChat {
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = (NSIndexPath*)[visible objectAtIndex:0];
    ShortVideoModel *model = self.dataSources[indexPath.row];
    self.commentsView.video_id = model.video_id;
    self.commentsView.isVideoOwner = [model.uid isEqualToString:[Config getOwnID]];
    self.commentsView.comments_count = [NSString stringWithFormat: @"%ld", (long)model.comments_count];
    self.commentsView.page = 1;
    [self.commentsView loadlistData];
    [self showCommentView];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail":@"评论按钮"};
    [MobClick event:@"shortvideo_menue_click" attributes:dict];
}

- (void)shortVideoPlayerManagerDelegateForTapGotoAnchor {
    ShortVideoModel *model = self.dataSources[self.currentIndex];
    otherUserMsgVC *person = [[otherUserMsgVC alloc]init];
    person.userID = model.uid;
    // TODO: bill test
//    person.userID = @"5446094";
    [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail":@"用户详情"};
    [MobClick event:@"shortvideo_menue_click" attributes:dict];
}

- (void)shortVideoPlayerManagerDelegateForTapLike {
    if (self.currentIndexBlock) {
        if (self.dataSources.count > self.currentIndex) {
            ShortVideoModel *model = self.dataSources[self.currentIndex];
            self.currentIndexBlock(model.video_id);
        }
    }

    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.getViewCurrentIndexBlock) {
            if (strongSelf.dataSources.count > strongSelf.currentIndex) {
                ShortVideoModel *model = strongSelf.dataSources[strongSelf.currentIndex];
                UIView *cell = strongSelf.getViewCurrentIndexBlock(model.video_id);
                strongSelf.ttcTransitionDelegate.smalCurPlayCell = cell;
            }
        }
    });
}

#pragma mark - ShortVideoTableViewCellDelegate
#pragma mark ================ 隐藏和显示tabbar ===============
- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController setTabbarHiden: YES];
}
- (void)showTabBar {
    if (self.tabBarController.tabBar.hidden == NO || self.isFromMessageList) {
        return;
    }
    if (self.navigationController.viewControllers.count > 1) {
        return;
    }
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController setTabbarHiden: NO];
}

#pragma mark - LiveStreamViewCellDelegate
- (void)liveStreamViewCellDelegateForTapLiveStream:(hotModel*)model nplayer:(NodePlayer*)nplayer cell:(LiveStreamViewCell*)cell {
    [[EnterLivePlay sharedInstance]showLivePlayFromLiveModel:model nplayer:nplayer cell:cell];
}

#pragma mark - 评论相关设定
- (void)handleCoverImgViewGesture:(UITapGestureRecognizer *)sender {
    if (self.commentsView.isHidden) {
        return;
    }
    [self hideCommentView];
    [self showTabBar];
}

- (void)showCommentView {
    self.superPagerVC.listContainerView.scrollView.scrollEnabled = NO;
    self.superPagerVC.categoryView.hidden = YES;

    dispatch_main_async_safe(^{
        if (self.currentIndex >= self.dataSources.count) {return;}
        ShortVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        ShortVideoModel *model = self.dataSources[self.currentIndex];
        [cell.manager showVideoInfoWithExpandCoverView:self.coverImgView model:model];
        if (self.hostString.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
        }
        self.tableView.userInteractionEnabled = NO;
        [self.commentsView setHidden:NO];
        [self.coverImgView setHidden:NO];
        [self.coverTouchView setHidden:NO];
        if (self.commentViewBottomConstraint.constant > 0) {
            [self hideTabBar];
        } else if (self.commentViewBottomConstraint.constant == 0) {
            [self showTabBar];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.commentViewBottomConstraint.constant = 0;
            self.videoViewHeightConstraint.constant = UIScreen.mainScreen.bounds.size.height * 0.3;
            CGFloat ratio = isnan(model.meta.ratio) ? 1.0 : model.meta.ratio;
            if (model.meta.isProtrait) {
                self.videoViewWidthConstraint.constant = self.videoViewHeightConstraint.constant * ratio;
            } else {
                self.videoViewWidthConstraint.constant = UIScreen.mainScreen.bounds.size.width;
            }
            self.videoViewTopConstraint.constant = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)hideCommentView {
    self.superPagerVC.listContainerView.scrollView.scrollEnabled = YES;
    self.superPagerVC.categoryView.hidden = NO;

    if (self.coverImgView.isHidden || self.coverImgView == nil) {
        return;
    }

    dispatch_main_async_safe(^{
        if (self.hostString.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:NO]}];
        }

        ShortVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        ShortVideoModel *model = self.dataSources[self.currentIndex];
        [UIView animateWithDuration:0.3 animations:^{
            self.commentViewBottomConstraint.constant = self.commentViewHeight;
            self.videoViewHeightConstraint.constant = self.tableView.height;
            CGFloat ratio = isnan(model.meta.ratio) ? 1.0 : model.meta.ratio;
            if (model.meta.isProtrait) {
                self.videoViewWidthConstraint.constant = self.videoViewHeightConstraint.constant * ratio;
            }
            self.videoViewTopConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [cell.manager hideVideoInfoWithExpandCoverView];
            [self.commentsView setHidden:YES];
            self.tableView.userInteractionEnabled = YES;
            [self.coverImgView setHidden:YES];
            [self.coverTouchView setHidden:YES];
        }];
    });
}

- (void)handlePanGesture:(DirectionPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat yTranslation = translation.y;

    if (gesture.state == UIGestureRecognizerStateChanged) {
        // 更新 commentView 和 videoView 的布局约束
        CGFloat newCommentViewBottomConstant = self.commentViewBottomConstraint.constant + yTranslation;
        newCommentViewBottomConstant = MIN(self.commentViewHeight, MAX(0, newCommentViewBottomConstant));
        self.commentViewBottomConstraint.constant = newCommentViewBottomConstant;

        CGFloat newVideoViewHeightConstant = self.view.frame.size.height - (self.commentViewHeight - newCommentViewBottomConstant);
        if (newVideoViewHeightConstant > self.tableView.height) {
            newVideoViewHeightConstant = self.tableView.height;
        }
        self.videoViewHeightConstraint.constant = newVideoViewHeightConstant;
        ShortVideoModel *model = self.dataSources[self.currentIndex];
        if (model.meta.isProtrait) {
            CGFloat height = self.videoViewHeightConstraint.constant;
            CGFloat ratio = model.meta.ratio;

            // 检查 `height` 和 `ratio` 是否为有限值
            if (isfinite(height) && isfinite(ratio) && height > 0 && ratio > 0) {
                self.videoViewWidthConstraint.constant = height * ratio;
            } else {
                // 设置默认值或进行错误处理
                NSLog(@"Invalid height (%f) or ratio (%f), setting default width", height, ratio);
                self.videoViewWidthConstraint.constant = 0; // 或者设置为一个合理的默认值
            }
        }

        CGFloat top = self.videoViewTopConstraint.constant - yTranslation/100.0;
        if (top < 0) {
            top = 0;
        } else if (top > [UIApplication sharedApplication].keyWindow.safeAreaInsets.top) {
            top = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        }
        self.videoViewTopConstraint.constant = top;

        [self.view layoutIfNeeded];
        // 重置手势识别器的平移
        [gesture setTranslation:CGPointZero inView:self.view];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [gesture velocityInView:self.view].y;
        CGFloat finalPosition = self.commentViewBottomConstraint.constant;

        if (finalPosition > self.commentViewHeight / 2 || velocity > 1000) {
            // 如果滑动超过一半高度或速度很大，则隐藏评论视图
            [self hideCommentView];
            [self showTabBar];
        } else {
            // 否则恢复到原位
            [self showCommentView];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 判断是否是系统的侧滑返回手势
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO; // 禁止侧滑返回
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        VKBaseTableView *tableView = (VKBaseTableView *)[otherGestureRecognizer view];
        CGPoint val = [tableView.panGestureRecognizer velocityInView:tableView];
        if (val.y > 0) {
            CGPoint point = tableView.contentOffset;
            return (point.y == 0);
        } else {
            return NO;
        }
    }
    return NO;
}

#pragma mark - VideoCommentsViewDelegate
- (void)tapAvatarImageView:(NSString *)uid {
    otherUserMsgVC *person = [otherUserMsgVC new];
    person.userID = uid;
    [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
}
- (void)tapUserName:(NSString *)uid {
    otherUserMsgVC *person = [otherUserMsgVC new];
    person.userID = uid;
    [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
}
@end
