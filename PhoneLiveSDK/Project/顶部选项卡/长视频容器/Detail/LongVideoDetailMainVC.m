//
//  LongVideoDetailMainVC.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoDetailMainVC.h"
#import "LongVideoDetailVideoVC.h"
#import "LongVideoDetailGameVC.h"
#import "MoviePlayerManager.h"
#import "HomeRecommendGameModel.h"
#import <UMCommon/UMCommon.h>

@interface LongVideoDetailMainVC () <MoviePlayerManagerDelegate>

@property (nonatomic, strong) UIImageView *videoCoverView;
@property (nonatomic, strong) MoviePlayerManager *videoManager;
@property (nonatomic, strong) MASConstraint *videoHeightConstraint;
@property (nonatomic, assign) NSTimeInterval startTime; // 页面初始化时间
@property (nonatomic, assign) NSTimeInterval duration; // 页面停留总时长
@end

@implementation LongVideoDetailMainVC

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    VKLOG(@"LongVideoDetailMainVC - dealloc");
    NSString *formattedDuration = [self formatDurationToHMS:self.duration];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"duration": formattedDuration};
    [MobClick event:@"longvideo_watch_duration_click" attributes:dict];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (NSString *)formatDurationToHMS:(NSTimeInterval)duration {
    NSInteger hours = duration / 3600;                      // 小时
    NSInteger minutes = ((NSInteger)duration % 3600) / 60;  // 分钟
    NSInteger seconds = (NSInteger)duration % 60;           // 秒

    // 格式化为 "小时:分钟:秒"
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (MoviePlayerManager *)videoManager {
    if (!_videoManager) {
        _videoManager = [[MoviePlayerManager alloc] initWithContainerView:self.videoCoverView];
        _videoManager.delegate = self;
    }
    return _videoManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.videoManager play];
    [GameFloatView showNormalGameView];
    //禁用屏幕左滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoManager pause];
    [GameFloatView showSmallGameView];
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    self.duration = endTime - self.startTime;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    /// 有弹窗时禁止关闭手势
    if (self.childViewControllers.count > 2) {
        self.ttcTransitionDelegate.closeGestureDisable = YES;
    } else {
        self.ttcTransitionDelegate.closeGestureDisable = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self loadListData];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadListData) name:KVipPayNotificationMsg object:nil];
    // 初始化时记录时间戳
    self.startTime = [[NSDate date] timeIntervalSince1970];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)setupView {
    self.view.backgroundColor = UIColor.blackColor;
    
    UIImageView *videoCoverView = [UIImageView new];
    videoCoverView.layer.masksToBounds = YES;
    videoCoverView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:videoCoverView];
    self.videoCoverView = videoCoverView;
    [videoCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(LongVideoDetailMainVCVideoHeight);
    }];
    
    self.categoryView.segmentStyle = SegmentStyleLine;
    self.categoryView.backgroundColor = UIColor.whiteColor;
    [self.view insertSubview:self.categoryView belowSubview:self.videoCoverView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(videoCoverView.mas_bottom).offset(0);
        make.height.mas_equalTo(36);
    }];
    
    self.listContainerView.backgroundColor = UIColor.whiteColor;
    [self.view insertSubview:self.listContainerView belowSubview:self.videoCoverView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.categoryView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(0);
    }];
    
    self.ttcTransitionDelegate.bigCurPlayCell = videoCoverView;
}

- (UIViewController *)renderViewControllerWithIndex:(NSInteger)index {
    NSString *title = self.categoryView.titles[index];
    if ([title isEqualToString:YZMsg(@"movie_game_menu")]) {
        LongVideoDetailGameVC *vc = [LongVideoDetailGameVC new];
        vc.gameList = self.categoryView.values[index];
        return vc;
    }
    LongVideoDetailVideoVC *vc = [LongVideoDetailVideoVC new];
    vc.videoList = self.categoryView.values[index];
    return vc;
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    self.ttcTransitionDelegate.closeGestureDisable = (index > 0);
}

- (void)loadListData {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getMoviePlay:self.videoId isRefresh:NO block:^(NetworkData *networkData) {
        [MBProgressHUD hideHUD];
        if (!networkData.status && !networkData.data) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        if (networkData.msg.length > 0) {
            [MBProgressHUD showSuccess:networkData.msg];
        }

        if (strongSelf.originalModel != nil) {
            if (strongSelf.originalModel.can_play == 0 && strongSelf.originalModel.ticket_cost > 0) {
                [VideoTicketFloatView refreshFloatData];
            }
        }

        [strongSelf handleNetworkData:networkData];
    }];
}

- (void)handleNetworkData:(NetworkData *)networkData {
    NSArray *movies = [ShortVideoModel arrayFromJson:networkData.data[@"relate_movies"]];
    NSArray *games = networkData.data[@"game_list"];
    
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    if (games.count > 0) {
        [titles addObject:YZMsg(@"movie_game_menu")];
        [values addObject:games];
    }
    if (movies.count > 0) {
        [titles addObject:YZMsg(@"movie_video_menu")];
        [values addObject:movies];
    }
    self.categoryView.titles = titles;
    self.categoryView.values = values;
    [self.categoryView reloadData];
    
    ShortVideoModel *model = [ShortVideoModel modelFromJSON:networkData.data[@"movie"]];
    [self.videoCoverView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    [self.videoManager.player.currentPlayerManager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    
    if (model.video_url.length > 0) {
        [self.videoManager playWithModel:model];
        if (!model.can_play) {
            [self.videoManager startTrying];
        } else {
            [self.videoManager closeTrying];
        }
    } else {
        [self.videoManager stopTrying];
    }
}

/// 观影劵付费
- (void)clickPayTicketAction {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getMovieUseTicket:self.videoId block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [VideoTicketFloatView refreshFloatData];
        [MBProgressHUD showSuccess:YZMsg(@"PayVC_PaySuccess")];
        vkGcdAfter(1.0, ^{
            STRONGSELF
            if (!strongSelf) return;
            [strongSelf loadListData];
        });
    }];
}

/// 余额付费
- (void)clickPayAmountAction {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getMovieBuyMovie:self.videoId block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD showSuccess:networkData.msg];
        vkGcdAfter(1.0, ^{
            STRONGSELF
            if (!strongSelf) return;
            [strongSelf loadListData];
        });
    }];
}

- (void)clickBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MoviePlayerManagerDelegate
- (void)moviePlayerManagerDelegatePlayFinish {
    /// 试看结束
    if (!self.videoManager.videoModel.can_play) {
        /// 如果全屏，恢復原樣
        if (self.videoManager.player.isFullScreen) {
            self.videoManager.player.currentPlayerManager.view.coverImageView.hidden = NO;
            [self.videoManager.player enterFullScreen:NO animated:YES];
        } else if (self.videoCoverView.height != LongVideoDetailMainVCVideoHeight) {
            [self moviePlayerManagerDelegatePlayPortraitFullScreen];
        }
    }
}

- (void)moviePlayerManagerDelegatePlayPortraitFullScreen {
    [MobClick event:@"longvideo_full_click" attributes:@{@"eventType": @(1)}];
    [GameFloatView sendToBack:self frontView:self.videoCoverView];
    ZFPlayerScalingMode mode = ZFPlayerScalingModeAspectFit;
    if (self.videoCoverView.height == LongVideoDetailMainVCVideoHeight) {
        mode = ZFPlayerScalingModeAspectFill;
        self.videoManager.player.currentPlayerManager.view.coverImageView.hidden = YES;
        [self.videoCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.equalTo(self.view);
        }];
    } else {
        self.videoManager.player.currentPlayerManager.view.coverImageView.hidden = NO;
        [self.videoCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(LongVideoDetailMainVCVideoHeight);
        }];
    }

    [UIView animateWithDuration:0.5 animations:^{
        [self.videoManager.player.currentPlayerManager setScalingMode:mode];
        [self.view layoutIfNeeded];
    }];
}

- (void)moviePlayerManagerDelegatePlayTapTryAction:(NSInteger)type {
    if (type == 0) {
        [self clickPayTicketAction];
    } else {
        [self clickPayAmountAction];
    }
}

- (void)movieControlViewDelegateForTapVoice:(BOOL)isMuted {
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"mute": isMuted ? @(1) : @(0)};
    [MobClick event:@"longvideo_mute_click" attributes:dict];
}
@end
