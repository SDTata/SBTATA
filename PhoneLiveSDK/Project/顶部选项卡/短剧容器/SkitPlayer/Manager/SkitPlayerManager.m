//
//  SkitPlayerManager.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPlayerManager.h"
#import "ZFPlayer.h"
#import "ZFIJKPlayerManager.h"
//#import <ZFPlayer/ZFAVPlayerManager.h>
#import "SkitPlayerVideoPortraitControlView.h"
#import "SkitPlayerVideoLandscapeControlView.h"
#import "DramaProgressModel.h"
#import "KTVHTTPCache.h"
#import "VideoProgressManager.h"
#import <FFAES/GTMBase64.h>
#import "SkitPlayerViewController.h"
#import "KTVHCURLTool.h"
#import <UMCommon/UMCommon.h>

#define MaxRetryTime 5
#define MaxRetryDelayTime 5.0

@interface SkitPlayerManager () <SkitPlayerVideoPortraitControlViewDelegate, SkitPlayerVideoLandscapeControlViewDelegate> {
}

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) SkitPlayerVideoLandscapeControlView *landscapeControlView;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, weak) SkitPlayerVideoPortraitControlView *protraitControlView;
@property (nonatomic, weak) SkitVideoInfoModel* model;
@property (nonatomic, weak) HomeRecommendSkit* infoModel;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) BOOL isPlayForIntoBackground;
@property (nonatomic, assign) int retryTime;
@property (nonatomic, assign) BOOL pauseFromSystem;
@property (nonatomic, weak) SkitPlayerVideoCell *tempCell;
@property (nonatomic, assign) BOOL firstReadyToPlay;
@property (nonatomic, assign) BOOL isDelayToPause;

@end

@implementation SkitPlayerManager

- (instancetype)init {
    self = [super init];
    if (self) {

        [[NSUserDefaults standardUserDefaults] registerDefaults:@{SkitPlayerManagerAutoNextIfNeed: @YES}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self initPlayer];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(requestData) name:KVipPayNotificationMsg object:nil];


    return self;
}

- (void)reset {
    [self.player stop];
    self.player = nil;
}

- (void)dealloc {
    NSLog(@"SkitPlayerManager release");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KVipPayNotificationMsg object:nil];
}

- (void)appWillEnterBackground {
    self.isPlayForIntoBackground = self.isPlay;
    self.isPlay = NO;
    [self.player.currentPlayerManager pause];
    [self saveProgress:self.player.currentTime
                 total:self.player.totalTime
               episode:self.model.episode_number
                skitId:self.model.skit_id
               videoId:self.model.video_id];
}

- (void)appWillEnterForeground {
    self.firstReadyToPlay = YES;
    self.isPlay = self.isPlayForIntoBackground;
    if (self.isPlay) {
        [self.player.currentPlayerManager play];
    }

//    NSURL *videoUrl = [NSURL URLWithString:self.model.video_url];
//    self.player.assetURL = videoUrl;
//    [self.player.currentPlayerManager setCryption:self.model.encrypted_key];
}

- (void)requestData {
    [self requestPlayVideo:NO];
}

- (void)pauseVideoFromSystem {
    [self saveProgress:self.protraitControlView.slider.currentTime
                 total:self.protraitControlView.slider.totalTime
               episode:self.model.episode_number
                skitId:self.model.skit_id
               videoId:self.model.video_id];
    
    if (!self.player.currentPlayerManager.isPlaying) {
        return;
    }
    self.isPlay = NO;
    self.pauseFromSystem = YES;
    [self.protraitControlView handleSingleTapped];
}

- (void)startPlayVideoFromSystem {
    if (!self.pauseFromSystem) {
        return;
    }
    self.pauseFromSystem = NO;
    [self startPlayVideo];
}

- (void)startPlayVideo {
    NSLog(@"bill>> start %@", self.model.name);
    self.isPlay = YES;
    self.player.currentPlayerManager.muted = NO;

    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused ||
        self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying) {
        [self.protraitControlView.slider showBriefTimeSlider:2.0];
        [self.player.currentPlayerManager play];
        if (self.model.isNeedPay) {
            [self requestPlayVideo:NO];
        } else {
            [self requestPlayVideoUpdate];
        }
    } else {
        [self requestPlayVideo:NO];
    }
}

- (void)pauseVideo {
    if (self.isPlay) {
        [self saveProgress:self.player.currentTime
                     total:self.player.totalTime
                   episode:self.model.episode_number
                    skitId:self.model.skit_id
                   videoId:self.model.video_id];
    }
    self.isPlay = NO;
    self.retryTime = 0;
    [self.player.currentPlayerManager pause];
    [self.protraitControlView hiddenPlayButton:YES];
}

- (void)setupVideoInfoWithCell:(SkitPlayerVideoCell *)cell model:(SkitVideoInfoModel*)model infoModel:(HomeRecommendSkit*)infoModel {
    self.firstReadyToPlay = YES;
    [cell.controlView layoutIfNeeded];
    if (![self.model.video_id isEqualToString:model.video_id]) {
        self.isPlay = NO;
        self.player.assetURL = nil;
        [self initVideo];
//        [self.player.currentPlayerManager stop];
    }

    self.tempCell = cell;
    self.model = model;
    self.infoModel = infoModel;
    [cell update:model infoModel:infoModel];
    self.protraitControlView = cell.controlView;
    self.protraitControlView.model = model;
    self.protraitControlView.infoModel = infoModel;
    self.landscapeControlView.model = model;
    self.landscapeControlView.infoModel = infoModel;
    cell.controlView.model = model;
    cell.controlView.infoModel = infoModel;

    // 设置播放内容视图
    self.player.containerView = cell.coverImgView;

    cell.controlView.slider.player = self.player;
    cell.controlView.delegate = self;
    self.player.controlView = cell.controlView;
    [self changeFullScreen:self.isFullScreen];

    // 设置封面图片
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error != nil) {
            [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:infoModel.cover_path]];
        }
    }];

    [self changeVideoScale];

    [cell.controlView hiddenPlayButton:YES];
    [cell.controlView hiddenFullScreen:YES];

//    self.isPlay = YES;
    [self playVideo:model];

    if (model.isNeedPay != ShortVideoModelPayTypeFree) {
        if (self.isFullScreen) {
            [self skitPlayerVideoLandscapeControlViewDelegateForTapBack];
        }
        if (self.protraitControlView.superview == nil || cell.controlView.superview != cell) {
            [cell.contentView addSubview:cell.controlView];
            cell.controlView.frame = cell.bounds;
        }
    }

    _weakify(self)
    self.protraitControlView.payCoverView.clickPayBlock = ^(NSInteger type) {
        _strongify(self)
        if (type == 0) {
            [self clickPayTicketAction:self.model.video_id];
        } else {
            [self clickPayAmountAction:self.model.video_id];
        }
    };
}

- (void)initPlayer {
    // 初始化播放器
    ZFIJKPlayerManager *manager = [[ZFIJKPlayerManager alloc] init];
    manager.shouldAutoPlay = NO; // 自动播放

    IJKFFOptions *options = manager.options;
    [options setFormatOptionIntValue:1 forKey:@"http-detect-range-support"];
    // 减少探测大小以加快启动时间
    [options setPlayerOptionIntValue:1024 * 4 forKey:@"probesize"];

    // 降低最大缓冲区大小，以避免在弱网情况下占用过多内存
    [options setPlayerOptionIntValue:5 * 1024 * 1024 forKey:@"max-buffer-size"];


    // 启用包缓冲，适应弱网环境
    [options setPlayerOptionIntValue:1 forKey:@"packet-buffering"];

    // 启用硬件解码，提升性能
    [options setPlayerOptionIntValue:videotoolboxTATA forKey:@"videotoolbox"];

    // 允许适度丢帧，以保持播放流畅
    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];

    // 使用 UDP 传输，适应实时传输协议（RTSP）
    [options setFormatOptionValue:@"udp" forKey:@"rtsp_transport"];


    // 设置较低的缓冲区大小，以减少缓冲时间
    [options setPlayerOptionIntValue:3000 forKey:@"max_cached_duration"];

    // 设置较低的最小缓冲大小，以减少缓冲时间
    [options setPlayerOptionIntValue:500 forKey:@"min_frames"];

    // 设置最大丢帧次数
    [options setPlayerOptionIntValue:12 forKey:@"max-fps"];

    // 弱网环境用
    [options setPlayerOptionIntValue:1 forKey:@"start-on-prepared"];
    // 自动拼接ts域名请求
    [options setPlayerOptionIntValue:1 forKey:@"hls_io_protocol_enable"];

    ZFPlayerController *player = [[ZFPlayerController alloc] init];
    player.currentPlayerManager = manager;
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    player.allowOrentitaionRotation = NO; // 禁止自动旋转
    player.pauseWhenAppResignActive = YES;
    player.pauseByEvent = NO;
//    [player.currentPlayerManager setScalingMode:ZFPlayerScalingModeAspectFill];
    self.player = player;
    WeakSelf
    // 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        NSLog(@"---===playerDidToEnd");
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
       
        BOOL isNext = YES;//[strongSelf autoNextIfNeed];
        if (isNext) {
            if (strongSelf.player.currentPlayerManager.totalTime<=30) {
                [strongSelf.player.currentPlayerManager reloadPlayer];
            }
            [strongSelf.player seekToTime:strongSelf.player.totalTime>30?1:0 completionHandler:^(BOOL finished) {
                if ([strongSelf.player.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                    [strongSelf.player.controlView videoPlayer:strongSelf.player loadStateChanged:ZFPlayerLoadStatePlayable];
                }
            }];
        }
        if ([strongSelf.delegate respondsToSelector:@selector(skitPlayerManagerDelegateForEnd:)]) {
            [strongSelf.delegate skitPlayerManagerDelegateForEnd:isNext];
        }

        [strongSelf saveProgress:strongSelf.player.totalTime>30?1:0
                           total:strongSelf.player.totalTime
                         episode:strongSelf.model.episode_number
                          skitId:strongSelf.model.skit_id
                         videoId:strongSelf.model.video_id];
    };

    player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        STRONGSELF
        NSLog(@"<>---===playerPlayFailed:%@", strongSelf.model.video_id);
        if (strongSelf == nil) {
            return;
        }
        if ([error isKindOfClass:[NSNumber class]]) {
            if ([error integerValue] == 1) {
                strongSelf.retryTime += 1;
                if (strongSelf.retryTime < MaxRetryTime) {
                    float delayTime = strongSelf.retryTime / 4.0 * 0.2;
                    if (delayTime > MaxRetryDelayTime) {
                        delayTime = MaxRetryDelayTime;
                    }
                    vkGcdAfter(delayTime, ^{
                        [strongSelf requestPlayVideo:YES];
                    });
                } else {
                    [strongSelf.protraitControlView hiddenLoading:YES];
                    [strongSelf.protraitControlView hiddenRetryButton:NO];
                    [strongSelf.landscapeControlView hiddenLoading:YES];
                    [strongSelf.landscapeControlView hiddenRetryButton:NO];
                }
            }
        }
    };

    player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        CGSize size = strongSelf.player.currentPlayerManager.view.coverImageView.image.size;
        if (size.width > size.height) {
            strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    };

    player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
//        if (size.width <= 0 && size.height <= 0) {
//            return;
//        }
//        NSLog(@">>>> %@", NSStringFromCGSize(size));
//        STRONGSELF
//        BOOL isFill = size.width < size.height;
//        [strongSelf.protraitControlView hiddenFullScreen:isFill];
//        ZFPlayerScalingMode mode = isFill ? ZFPlayerScalingModeAspectFill : ZFPlayerScalingModeAspectFit;
//        if (strongSelf.player.currentPlayerManager.scalingMode != mode) {
//            [strongSelf.player.currentPlayerManager setScalingMode:mode];
//        }
//        if (strongSelf.player.currentPlayerManager.view.scalingMode != mode) {
//            [strongSelf.player.currentPlayerManager.view setScalingMode:mode];
//        }
//        strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = isFill ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    };

    // 開始播放
    player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@">>>>>playerReadyToPlay");
        DramaProgressModel *progressModel = [VideoProgressManager loadProgress:strongSelf.model.skit_id episodeNumber:strongSelf.model.episode_number];
        NSInteger currentTime = progressModel.currentTime;
        if (currentTime >= (strongSelf.model.video_duration.intValue - 2)) {
            currentTime = 0;
        }

        [strongSelf.player seekToTime:currentTime completionHandler:^(BOOL finished) {
            if (strongSelf == nil) {
                return;
            }

            [strongSelf.player.currentPlayerManager play];
            if (strongSelf.isPlay) {
                [strongSelf.protraitControlView.slider showBriefTimeSlider:2.0];
//                [strongSelf.player.currentPlayerManager play];
            } else {

            }
        }];

        [strongSelf.protraitControlView hiddenFullScreen:strongSelf.model.meta.isProtrait];
    };

    // 加载状态
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        NSLog(@"---===playerLoadStateChanged %ld", loadState);
//        STRONGSELF
//        if (loadState == ZFPlayerLoadStateStalled || loadState == ZFPlayerLoadStatePlayable) {
////            [strongSelf.player.currentPlayerManager play];
//        }
    };

    // 播放时间
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        strongSelf.tempCell.coverImgView.image = nil;
        [strongSelf.protraitControlView.slider updateCurrentTime:currentTime totalTime:duration];
        [strongSelf.landscapeControlView.slider updateCurrentTime:currentTime totalTime:duration];

        if (!strongSelf.isPlay && strongSelf.firstReadyToPlay == YES) {
            strongSelf.firstReadyToPlay = NO;
            [strongSelf.player.currentPlayerManager play];
            strongSelf.player.currentPlayerManager.muted = YES;
            NSLog(@"bill>> %@", strongSelf.model.name);
            strongSelf.isDelayToPause = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!strongSelf.isPlay) {
                    [strongSelf.player.currentPlayerManager pause];
                    NSLog(@"bill>>pause %@", strongSelf.model.name);
                    [strongSelf.protraitControlView updateShowPayStatus:currentTime];
                }
                strongSelf.isDelayToPause = NO;
            });
        } else {
            if (strongSelf.isPlay) {
                [strongSelf.protraitControlView updateShowPayStatus:currentTime];
            } else {
                if (!strongSelf.isDelayToPause) {
                    [strongSelf.player.currentPlayerManager pause];
                }
            }
        }
    };

    // 方向即将改变
    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.player.controlView.hidden = YES;
        if (isFullScreen) {
            self.player.currentPlayerManager.view.coverImageView.hidden = YES;
            [strongSelf.player.currentPlayerManager setScalingMode:ZFPlayerScalingModeAspectFill];
        } else {
            self.player.currentPlayerManager.view.coverImageView.hidden = NO;
            [strongSelf changeVideoScale];
        }
    };

    // 方向已经改变
    player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf changeFullScreen:isFullScreen];
    };
    
    /// 停止的时候找出最合适的播放
    player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([strongSelf.delegate respondsToSelector:@selector(skitPlayerManagerDelegateStartPlayIndexPath:)]) {
            [strongSelf.delegate skitPlayerManagerDelegateStartPlayIndexPath:indexPath];
        }
    };
}

- (void)changeVideoScale {
    // 調整 Scale
    UIViewContentMode imageModel = self.model.meta.isProtrait ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    self.player.currentPlayerManager.view.coverImageView.contentMode = imageModel;
    ZFPlayerScalingMode mode = self.model.meta.isProtrait ? ZFPlayerScalingModeAspectFill : ZFPlayerScalingModeAspectFit;
    [self.player.currentPlayerManager.view setScalingMode:mode];
    [self.player.currentPlayerManager setScalingMode:mode];
}

- (void)playVideo:(SkitVideoInfoModel*)model {
    if (![self.model.video_id isEqualToString:model.video_id]) {
        return;
    }
//    model.video_url = @"http://t.zafsou.com/media/video/202407/1_ff51ef52e6c7fb9b53a689faadb8dca9/playlist1.m3u8";
    if (model.video_url.length > 0) {
        
        NSString *urlKey = [[KTVHCURLTool tool] cacheUrlKeyMd5Path:model.video_url];
        NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",urlKey]]];

//        NSURL *videoUrl = [NSURL URLWithString:model.video_url];
////        NSURL *videoUrl = [NSURL URLWithString:@"https://www.w3schools.com/html/mov_bbb.mp4"];//測試
//        NSURL *cacheUrl = videoUrl;
//        NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:videoUrl];
        // 播放内容一致，不做处理
//        if ([self.player.assetURL.absoluteString isEqualToString:cacheUrl.absoluteString]) return;

        // 设置播放地址
        self.player.assetURL = cacheUrl;
        [self.player.currentPlayerManager setCryption:model.encrypted_key];
        if (self.isPlay) {
            [self.player.currentPlayerManager play];
        } else {
//            [self.player.currentPlayerManager prepareToPlay];
        }
    } else {
        [self requestPlayVideo:NO];
    }
    
    self.protraitControlView.model = model;
}

- (void)initVideo {
    [self.protraitControlView updateCurrentTime:0 totalTime:0];
    [self.landscapeControlView.slider updateCurrentTime:0 totalTime:0];
}

- (void)changeFullScreen:(BOOL)isFullScreen {
    if (isFullScreen) {
        self.landscapeControlView.model = self.model;
        self.landscapeControlView.hidden = NO;
        self.player.controlView = self.landscapeControlView;
    }else {
        self.protraitControlView.model = self.model;
        self.protraitControlView.hidden = NO;
        self.player.controlView = self.protraitControlView;
        [self changeVideoScale];
        [self.protraitControlView hiddenFullScreen:self.model.meta.isProtrait];
        if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlayFailed) {
            [self.protraitControlView hiddenFullScreen:YES];
            [self requestPlayVideo:YES];
        }
    }
    self.isFullScreen = isFullScreen;
}

- (void)changeAutoNext:(BOOL)open {
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:SkitPlayerManagerAutoNextIfNeed];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.landscapeControlView changeAutoNext:open];
    [self.protraitControlView changeAutoNext:open];
}

- (BOOL)autoNextIfNeed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SkitPlayerManagerAutoNextIfNeed];
}

#pragma mark - Pay
- (void)clickPayTicketAction:(NSString*)videoId {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getSkitUseTicket:videoId block:^(NetworkData *networkData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [VideoTicketFloatView refreshFloatData];
        [MBProgressHUD showSuccess:YZMsg(@"PayVC_PaySuccess")];
        vkGcdAfter(1.0, ^{
            [strongSelf requestPlayVideo:NO];
        });
    }];
}

- (void)clickPayAmountAction:(NSString*)videoId {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getSkitUseCoin:videoId block:^(NetworkData *networkData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }

        [MBProgressHUD showSuccess:networkData.msg];
        vkGcdAfter(1.0, ^{
            [strongSelf requestPlayVideo:NO];
        });
    }];
}

#pragma mark - lazy
- (SkitPlayerVideoLandscapeControlView *)landscapeControlView {
    if (!_landscapeControlView) {
        _landscapeControlView = [[SkitPlayerVideoLandscapeControlView alloc] init];
        _landscapeControlView.delegate = self;
    }
    return _landscapeControlView;
}

#pragma mark - API
- (void)requestPlayVideo:(BOOL)isRefresh {
    if (self.player.currentPlayerManager.playState != ZFPlayerPlayStatePlaying) {
        [self.player.currentPlayerManager pause];
        [self.protraitControlView hiddenLoading:NO];
        [self.landscapeControlView hiddenLoading:NO];
    }

    BOOL autoDeduct = NO;
    if (self.isPlay && self.model.isNeedPay != ShortVideoModelPayTypeFree) {
        autoDeduct = YES;
    }
    
    WeakSelf
    [SkitPlayerViewController requestVideo:self.model.video_id autoDeduct:autoDeduct refresh_url:isRefresh completion:^(SkitVideoInfoModel * _Nonnull newModel, BOOL success) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (![strongSelf.model.video_id isEqualToString:newModel.video_id]) {
            return;
        }

        if (newModel == nil) {
            return;
        }

//        if (!success) {
//            strongSelf.protraitControlView.model = strongSelf.model;
//            return;
//        }
        strongSelf.model.name = newModel.name;
        strongSelf.model.is_vip = newModel.is_vip;
        strongSelf.model.can_play = newModel.can_play;
        strongSelf.model.coin_cost = newModel.coin_cost;
        [strongSelf.model changeEncrypted_key:newModel.encrypted_key];

        strongSelf.protraitControlView.model = strongSelf.model;
        strongSelf.landscapeControlView.model = strongSelf.model;

        if (isRefresh || strongSelf.model.video_url.length <= 0) {
            strongSelf.model.video_url = newModel.video_url;
            if (newModel.video_url.length <= 0) {
                [strongSelf.protraitControlView hiddenRetryButton:NO];
                [strongSelf.landscapeControlView hiddenRetryButton:NO];
                return;
            }
            [strongSelf playVideo:strongSelf.model];
            return;
        }

        if (strongSelf.isPlay) {
            if (strongSelf.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying) {
                return;
            }
            if (strongSelf.player.currentPlayerManager.assetURL == nil) {
                [strongSelf playVideo:strongSelf.model];
            } else {
                [strongSelf.protraitControlView hiddenLoading:YES];
                [strongSelf.landscapeControlView hiddenLoading:YES];
                [strongSelf.player.currentPlayerManager play];
            }
        }
    }];
}

- (void)requestPlayVideoUpdate {
    WeakSelf
    [SkitPlayerViewController requestVideo:self.model.video_id autoDeduct:NO refresh_url:NO completion:^(SkitVideoInfoModel * _Nonnull newModel, BOOL success) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (![strongSelf.model.video_id isEqualToString:newModel.video_id]) {
            return;
        }

        if (newModel == nil) {
            return;
        }

        strongSelf.model.name = newModel.name;
        strongSelf.model.is_vip = newModel.is_vip;
        strongSelf.model.can_play = newModel.can_play;
        strongSelf.model.coin_cost = newModel.coin_cost;
        [strongSelf.model changeEncrypted_key:newModel.encrypted_key];

        strongSelf.protraitControlView.model = strongSelf.model;
        strongSelf.landscapeControlView.model = strongSelf.model;

        if (strongSelf.model.video_url.length <= 0) {
            strongSelf.model.video_url = newModel.video_url;
            if (!strongSelf.model.isNeedPay) {
                [strongSelf playVideo:strongSelf.model];
            }
        }
    }];
}

- (void)requestAddStar:(BOOL)isAdd {
    WeakSelf
    [LotteryNetworkUtil getSkitToggleFavoriteSkit:self.model.skit_id isAddL:isAdd block:^(NetworkData *networkData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        strongSelf.infoModel.is_favorite = isAdd;
        strongSelf.protraitControlView.infoModel = strongSelf.infoModel;
        strongSelf.landscapeControlView.infoModel = strongSelf.infoModel;

        if (isAdd == NO) {
            NSDictionary *userInfo = @{@"skitId": strongSelf.model.skit_id};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SkitFavoriteViewControllerRemoveSkit"
                                                                object:nil
                                                              userInfo:userInfo];
        }

        NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
        newDic[@"skit_id"] = strongSelf.infoModel.skit_id;
        newDic[@"is_favorite"] = @(strongSelf.infoModel.is_favorite);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSkitFavorite" object:newDic];
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

    self.infoModel.p_progress = p_progress;
    NSDictionary *infoDic = @{@"skitId": skitId,
                              @"progress": p_progress};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SkitListUpdate" object:infoDic];

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Skit.updateWatchingProcess" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {

        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {

    }];
}

#pragma mark - SkitPlayerVideoPortraitControlViewDelegate
- (void)skitPlayerVideoPortraitControlViewDelegateForTapChat {
    if ([self.delegate respondsToSelector:@selector(skitPlayerManagerDelegateForChat)]) {
        [self.delegate skitPlayerManagerDelegateForChat];
    }
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapSkit {
    if ([self.delegate respondsToSelector:@selector(skitPlayerManagerDelegateForSkit)]) {
        [self.delegate skitPlayerManagerDelegateForSkit];
    }
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapStar:(BOOL)isAdd {
    [self requestAddStar:isAdd];
    [MobClick event:@"skit_play_favorite_click" attributes:@{@"eventType": @(1)}];
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapFullScreen {
    [self.player enterFullScreen:YES animated:YES completion:^{
        self.player.controlView.hidden = NO;
        self.landscapeControlView.slider.player = self.player;
    }];
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapAutoNext:(BOOL)open {
    [self changeAutoNext:open];
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapRetryLoadVideo {
    [self requestPlayVideo:YES];
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapVoice:(BOOL)isMuted {
    if ([self.delegate respondsToSelector:@selector(skitPlayerManagerDelegateForTapVoice:)]) {
        [self.delegate skitPlayerManagerDelegateForTapVoice: isMuted];
    }
}

- (void)skitPlayerVideoPortraitControlViewDelegateForTapPlay:(BOOL)isPlay {
    self.isPlay = isPlay;
    if (!isPlay) {
        [self.protraitControlView hiddenLoading:YES];
        [self.landscapeControlView hiddenLoading:YES];
    }
}

#pragma mark - SkitPlayerVideoLandscapeControlViewDelegate
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapBack {
    [self.player enterFullScreen:NO animated:YES completion:^{
        self.player.controlView.hidden = NO;
    }];
}

- (void)skitPlayerVideoLandscapeControlViewDelegateForTapStar:(BOOL)isAdd {
    [self requestAddStar:isAdd];
}

- (void)skitPlayerVideoLandscapeControlViewDelegateForTapAutoNext:(BOOL)open {
    [self changeAutoNext:open];
}

- (void)skitPlayerVideoLandscapeControlViewDelegateForTapChat {
    if ([self.delegate respondsToSelector:@selector(skitPlayerManagerDelegateForChat)]) {
        [self.delegate skitPlayerManagerDelegateForChat];
    }
}

- (void)skitPlayerVideoLandscapeControlViewDelegateForTapRetryLoadVideo {
    [self requestPlayVideo:YES];
}

- (void)skitPlayerVideoLandscapeControlViewDelegateForTapPlay:(BOOL)isPlay {
    self.isPlay = isPlay;
    if (!isPlay) {
        [self.protraitControlView hiddenLoading:YES];
        [self.landscapeControlView hiddenLoading:YES];
    }
}

@end
