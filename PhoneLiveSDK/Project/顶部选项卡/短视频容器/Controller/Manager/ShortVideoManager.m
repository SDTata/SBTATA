//
//  ShortVideoManager.m
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoManager.h"
#import "ZFPlayer.h"
#import "ZFIJKPlayerManager.h"
#import "DramaProgressModel.h"
#import "KTVHTTPCache.h"
#import <FFAES/GTMBase64.h>
#import "ShortVideoListViewController.h"
#import "ShortVideoLandscapeControlView.h"
#import "ShortVideoTableViewCell.h"
#import "ShortVideoProgressManager.h"
#import "KTVHCURLTool.h"
#import <UMCommon/UMCommon.h>

//#import "ZFIJKFrameExtractor.h"

#define MaxRetryTime 5
#define MaxRetryDelayTime 5.0
@interface ShortVideoManager () <ShortVideoPortraitControlViewDelegate, ShortVideoLandscapeControlViewDelegate>

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ShortVideoLandscapeControlView *landscapeControlView;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, weak) ShortVideoPortraitControlView *protraitControlView;
@property (nonatomic, weak) ShortVideoModel* model;
@property (nonatomic, weak) ShortVideoTableViewCell *tempCell;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) BOOL isPlayForIntoBackground;
@property (nonatomic, assign) int retryTime;
@property (nonatomic, strong) NSDate *startShowRecoderTime;
@property (nonnull, assign) ExpandCommentVideoView * expandCommentVideoView;
@property (assign,nonatomic) BOOL isFollowing;
@property (nonatomic, assign) BOOL firstReadyToPlay;
@property (nonatomic, assign) BOOL isDelayToPause;
// ✅ 性能优化：限制slider更新频率
@property (nonatomic, assign) CFTimeInterval lastSliderUpdateTime;
@property (nonatomic, assign) BOOL lastPreviewStatus;
//@property (nonatomic, strong) ZFIJKFrameExtractor *frameExtractor;
@end

@implementation ShortVideoManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{DramaPlayerManagerAutoNextIfNeed: @YES}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self initPlayer];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadLiveplayAttion:) name:@"reloadLiveplayAttion" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadComment:) name:@"reloadComment" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    return self;
}

- (void)reset {
    [self.player stop];
    self.player = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadLiveplayAttion" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadComment" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    NSLog(@"ShortVideoManager release");
}

- (void)reloadLiveplayAttion:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *isattention = minstr([dic valueForKey:@"isattent"]);
        NSString *uid = minstr([dic valueForKey:@"uid"]);
        if ([uid isEqualToString:self.model.uid]) {
            self.model.is_follow = [isattention intValue];
            self.protraitControlView.model = self.model;
            self.landscapeControlView.model = self.model;
        }
    }
}

- (void)reloadComment:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *commentCount = minstr([dic valueForKey:@"commentCount"]);
    int commentCountInt = commentCount.intValue;
    if (commentCountInt <= 0) {
        return;
    }
    self.model.comments_count = commentCount.intValue;
    self.protraitControlView.model = self.model;
}

- (void)appWillEnterBackground {
    self.isPlayForIntoBackground = self.isPlay;
    self.isPlay = NO;
    [self.player.currentPlayerManager pause];
    [self saveProgress:self.player.currentTime
                 total:self.player.totalTime
               videoId:self.model.video_id
                 title:self.model.title];
}

- (void)appWillEnterForeground {
    self.firstReadyToPlay = YES;
    self.isPlay = self.isPlayForIntoBackground;
//    NSURL *videoUrl = [NSURL URLWithString:self.model.video_url];
//    self.player.assetURL = videoUrl;
//    [self.player.currentPlayerManager setCryption:self.model.encrypted_key];
//    
    if (self.isPlay) {
        [self.player.currentPlayerManager play];
    }
}

- (void)startPlayVideo {
    self.isPlay = YES;
    self.startShowRecoderTime = [NSDate date];

    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
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
    self.retryTime = 0;
    self.isPlay = NO;
    [self.player.currentPlayerManager pause];
    [self.protraitControlView hiddenPlayButton:YES];

    [self saveProgress:self.player.currentTime
                 total:self.player.totalTime
               videoId:self.model.video_id
                 title:self.model.title];

    if (self.startShowRecoderTime != nil && self.player.assetURL != nil) {
        NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:self.startShowRecoderTime];
        [LotteryNetworkUtil getShortVideoPlayEndvideoId:self.model.video_id playTime:timeDifference];
    }
    self.startShowRecoderTime = nil;
}

- (void)stopVideo {
    [self.player.currentPlayerManager stop];
}

- (void)setupVideoInfoWithCell:(ShortVideoTableViewCell *)cell model:(ShortVideoModel*)model isShowCreateTime:(BOOL)isShow {
    self.firstReadyToPlay = YES;
    [cell.controlView layoutIfNeeded];
    if (![self.model.video_id isEqualToString:model.video_id]) {
        self.isPlay = NO;
        self.player.assetURL = nil;
        [self initVideo];
    }
    
    self.tempCell = cell;
    self.model = model;
    [cell update:model isShowCreateTime:isShow];
    self.landscapeControlView.model = model;
    [self changeFullScreen:self.isFullScreen];
    self.retryTime = 0;

    // 设置播放内容视图
    self.player.containerView = cell.coverImgView;

    cell.controlView.slider.player = self.player;
    cell.controlView.delegate = self;
    self.protraitControlView = cell.controlView;
    self.player.controlView = cell.controlView;
    [self.player.controlView setHidden:NO];

    // 设置封面图片
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];

    [self changeVideoScale];

    [cell.controlView hiddenPlayButton:YES];
    [cell.controlView hiddenFullScreen:YES];

    [self playVideo:model];

    _weakify(self)
    self.protraitControlView.payCoverView.clickPayBlock = ^(NSInteger type) {
        _strongify(self)
        if (type == 0) {
            [self clickPayTicketAction:model.video_id];
        } else {
            [self clickPayAmountAction:model.video_id];
        }
    };
}

#pragma mark - private
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

   
//

    
    ZFPlayerController *player = [[ZFPlayerController alloc] init];
    player.currentPlayerManager = manager;
//    ZFPlayerController *player = [ZFPlayerController playerWithScrollView:tableView playerManager:manager containerViewTag:100];
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch | ZFPlayerDisableGestureTypesDoubleTap;
    player.allowOrentitaionRotation = NO; // 禁止自动旋转
    player.pauseWhenAppResignActive = YES;
    player.pauseByEvent = NO;
    [player.currentPlayerManager setScalingMode:ZFPlayerScalingModeAspectFill];
    player.currentPlayerManager.view.backgroundColor = [UIColor clearColor];
    self.player = player;

    WeakSelf
    // 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        NSLog(@"---===playerDidToEnd");
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        [strongSelf.protraitControlView.slider updateCurrentTime:strongSelf.player.totalTime-0.1 totalTime:strongSelf.player.totalTime];
        [strongSelf.landscapeControlView.slider updateCurrentTime:strongSelf.player.totalTime-0.1 totalTime:strongSelf.player.totalTime];

        
        BOOL isNext = NO;//[strongSelf autoNextIfNeed];
        if (isNext) {
            [strongSelf.player seekToTime:strongSelf.player.totalTime>30?1:0 completionHandler:^(BOOL finished) {
                if ([strongSelf.player.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                    [strongSelf.player.controlView videoPlayer:strongSelf.player loadStateChanged:ZFPlayerLoadStatePlayable];
                }
            }];
        }
        if ([strongSelf.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForEnd:)]) {
            [strongSelf.delegate shortVideoPlayerManagerDelegateForEnd:isNext];
        }

        [strongSelf saveProgress:strongSelf.player.totalTime>30?1:0
                           total:strongSelf.player.totalTime
                         videoId:strongSelf.model.video_id
                           title:strongSelf.model.title];
    };

    player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
//        STRONGSELF
        NSLog(@"---===playerPrepareToPlay");
//        CGSize size = strongSelf.player.currentPlayerManager.view.coverImageView.image.size;
//        if (size.width > size.height) {
//            strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
//        } else {
//            strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
//        }
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

        // ✅ 立即设置UI，不阻塞渲染线程
        [strongSelf.protraitControlView hiddenFullScreen:strongSelf.model.meta.isProtrait];

        // ✅ 将耗时的seekToTime操作延迟到异步执行
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) return;

            // ✅ 在异步block中执行seek，不阻塞主线程
            ShortVideoProgressModel *progressModel = [ShortVideoProgressManager
                                                       loadProgress:strongSelf.model.video_id
                                                             title:strongSelf.model.title];
            NSInteger currentTime = progressModel.currentTime;
            if (currentTime >= (strongSelf.model.video_duration - 2)) {
                currentTime = 0;
            }

            [strongSelf.player seekToTime:currentTime completionHandler:^(BOOL finished) {
                if (strongSelf == nil) return;

                if (strongSelf.isPlay) {
                    [strongSelf.player.currentPlayerManager play];
                    [strongSelf.protraitControlView.slider showBriefTimeSlider:2.0];
                }
            }];
        });
    };

    // 加载状态
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        NSLog(@"---===playerLoadStateChanged %ld", loadState);
    };
    

    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        STRONGSELF
        NSLog(@"---===playerPlayFailed: %@", strongSelf.model.video_id);
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

    // 播放时间
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        // ✅ 只清除图片一次，不要每一帧都清除
        if (currentTime > 0.5 && strongSelf.tempCell.coverImgView.image != nil) {
            strongSelf.tempCell.coverImgView.image = nil;
        }

        // ✅ 限制slider更新频率：最多每100ms更新一次（而不是每帧30-60ms）
        CFTimeInterval currentMachTime = CACurrentMediaTime();
        if (currentMachTime - strongSelf->_lastSliderUpdateTime >= 0.1) {
            // ✅ 只更新当前可见的slider
            if (strongSelf.isFullScreen) {
                [strongSelf.landscapeControlView.slider updateCurrentTime:currentTime totalTime:duration];
            } else {
                [strongSelf.protraitControlView.slider updateCurrentTime:currentTime totalTime:duration];
            }
            strongSelf->_lastSliderUpdateTime = currentMachTime;
        }

        if (!strongSelf.isPlay && strongSelf.firstReadyToPlay == YES) {
            strongSelf.firstReadyToPlay = NO;
            [strongSelf.player.currentPlayerManager play];
            strongSelf.player.currentPlayerManager.muted = YES;
            strongSelf.isDelayToPause = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!strongSelf.isPlay) {
                    [strongSelf.player.currentPlayerManager pause];
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

        // ✅ 只在状态改变时更新preview状态，不要每帧都检查
        int previewDuration = strongSelf.model.preview_duration <= 0 ? 20 : (CGFloat)strongSelf.model.preview_duration;
        BOOL shouldShowBlue = (currentTime >= previewDuration) && !strongSelf.model.can_play;

        if (strongSelf.lastPreviewStatus != shouldShowBlue) {
            [strongSelf.expandCommentVideoView showBlueIfNeed:shouldShowBlue];
            strongSelf.lastPreviewStatus = shouldShowBlue;
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

//    self.frameExtractor = [[ZFIJKFrameExtractor alloc] initWithPlayerController:self.player];
//    [self.frameExtractor start];
}

- (void)changeVideoScale {
    // 調整 Scale
    UIViewContentMode imageModel = self.model.meta.isProtrait ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    self.player.currentPlayerManager.view.coverImageView.contentMode = imageModel;
    ZFPlayerScalingMode mode = self.model.meta.isProtrait ? ZFPlayerScalingModeAspectFill : ZFPlayerScalingModeAspectFit;
    [self.player.currentPlayerManager.view setScalingMode:mode];
    [self.player.currentPlayerManager setScalingMode:mode];
}

- (void)changeVideoScale:(BOOL)isProtrait {
    // 調整 Scale
    UIViewContentMode imageModel = isProtrait ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    self.player.currentPlayerManager.view.coverImageView.contentMode = imageModel;
    ZFPlayerScalingMode mode = isProtrait ? ZFPlayerScalingModeAspectFill : ZFPlayerScalingModeAspectFit;
    [self.player.currentPlayerManager.view setScalingMode:mode];
    [self.player.currentPlayerManager setScalingMode:mode];
}

- (void)playVideo:(ShortVideoModel*)model {
    if (![self.model.video_id isEqualToString:model.video_id] || self.player.currentPlayerManager.isPlaying) {
        return;
    }

    if (model.video_url.length > 0) {
//        NSURL *videoUrl = [NSURL URLWithString:model.video_url];
//        NSURL *videoUrl = [NSURL URLWithString:@"https://v.cdnlz12.com/20240513/14146_1a667199/index.m3u8"];
//        NSURL *videoUrl = [NSURL URLWithString:@"https://www.w3schools.com/html/mov_bbb.mp4"];//測試
//        NSURL *cacheUrl = videoUrl;
        NSString *urlKey = [[KTVHCURLTool tool] cacheUrlKeyMd5Path:model.video_url];
        NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",urlKey]]];
        // 播放内容一致，不做处理
//        if ([self.player.assetURL.absoluteString isEqualToString:cacheUrl.absoluteString]) return;

        // 设置播放地址
        self.player.assetURL = cacheUrl;

        [self.player.currentPlayerManager setCryption:model.encrypted_key];

        if (self.isPlay ) {
            [self.player.currentPlayerManager play];
        }
    } else {
        [self requestPlayVideo:NO];
    }
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
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:DramaPlayerManagerAutoNextIfNeed];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self.landscapeControlView changeAutoNext:open];
//    [self.protraitControlView changeAutoNext:open];
}

- (BOOL)autoNextIfNeed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DramaPlayerManagerAutoNextIfNeed];
}

#pragma mark - comment expand
- (void)showVideoInfoWithExpandCoverView:(ExpandCommentVideoView *)containerView model:(ShortVideoModel*)model {
    if (!self.model) {
        self.model = model;
    }
    self.expandCommentVideoView = containerView;
    [self.tempCell setHidden:YES];
    self.player.containerView = containerView.coverImageView;
    [self.protraitControlView setHidden:YES];
    [self.player.controlView setHidden:YES];
    [self.player.currentPlayerManager.view needAutoUpdateCoverImage:YES];

//    [self changeVideoScale:NO];
}

- (void)hideVideoInfoWithExpandCoverView {
    [self.tempCell setHidden:NO];
    self.player.containerView = self.tempCell;
    [self.protraitControlView setHidden:NO];
    [self.player.controlView setHidden:NO];
    [self.player.currentPlayerManager.view needAutoUpdateCoverImage:NO];

//    [self changeVideoScale:self.model.meta.isProtrait];
}

#pragma mark - Pay
- (void)clickPayTicketAction:(NSString*)videoId {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getShortVideoUseTicket:videoId block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        [VideoTicketFloatView refreshFloatData];
        strongSelf.model.can_play = 1;
        [MBProgressHUD showSuccess:YZMsg(@"PayVC_PaySuccess")];
        vkGcdAfter(1.0, ^{
            STRONGSELF
            if (!strongSelf) return;
            strongSelf.protraitControlView.model = strongSelf.model;
            strongSelf.landscapeControlView.model = strongSelf.model;
            [strongSelf requestPlayVideo:NO];
        });
    }];
}

- (void)clickPayAmountAction:(NSString*)videoId {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getShortVideoUseCoin:videoId block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        strongSelf.model.can_play = 1;
        [MBProgressHUD showSuccess:networkData.msg];
        vkGcdAfter(1.0, ^{
            STRONGSELF
            if (!strongSelf) return;
            strongSelf.protraitControlView.model = strongSelf.model;
            strongSelf.landscapeControlView.model = strongSelf.model;
            [strongSelf requestPlayVideo:NO];
        });
    }];
}

#pragma mark - lazy
- (ShortVideoLandscapeControlView *)landscapeControlView {
    if (!_landscapeControlView) {
        _landscapeControlView = [[ShortVideoLandscapeControlView alloc] init];
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
    [ShortVideoListViewController requestVideo:self.model.video_id autoDeduct:autoDeduct refresh_url:isRefresh completion:^(ShortVideoModel * _Nonnull newModel, BOOL success, NSString *errorMsg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (newModel == nil) {
//            if (errorMsg.length > 0 && strongSelf.isPlay) {
//                if (!newModel.isNeedPay) {
//                    [MBProgressHUD showError:errorMsg];
//                }
//            }
            vkGcdAfter(0.5, ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (strongSelf.isPlay) {
                    [strongSelf requestPlayVideo:isRefresh];
                }
            });
            return;
        }

        strongSelf.model.title = newModel.title;
        strongSelf.model.is_follow = newModel.is_follow;
        strongSelf.model.is_like = newModel.is_like;
        strongSelf.model.is_vip = newModel.is_vip;
        strongSelf.model.can_play = newModel.can_play;
        strongSelf.model.likes_count = newModel.likes_count;
        strongSelf.model.coin_cost = newModel.coin_cost;
        strongSelf.model.browse_count = newModel.browse_count;
        strongSelf.model.comments_count = newModel.comments_count;
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
    [ShortVideoListViewController requestVideo:self.model.video_id autoDeduct:NO refresh_url:NO completion:^(ShortVideoModel * _Nonnull newModel, BOOL success, NSString *errorMsg) {
        STRONGSELF
        if (strongSelf == nil ) {
            return;
        }

        if (!success) {
            return;
        }

        strongSelf.model.title = newModel.title;
        strongSelf.model.is_follow = newModel.is_follow;
        strongSelf.model.is_like = newModel.is_like;
        strongSelf.model.is_vip = newModel.is_vip;
        strongSelf.model.can_play = newModel.can_play;
        strongSelf.model.likes_count = newModel.likes_count;
        strongSelf.model.coin_cost = newModel.coin_cost;
        strongSelf.model.browse_count = newModel.browse_count;
        strongSelf.model.comments_count = newModel.comments_count;
        [strongSelf.model changeEncrypted_key:newModel.encrypted_key];

        strongSelf.protraitControlView.model = strongSelf.model;
        strongSelf.landscapeControlView.model = strongSelf.model;

//        if (strongSelf.model.video_url.length <= 0) {
            strongSelf.model.video_url = newModel.video_url;
            if (!strongSelf.model.isNeedPay) {
                [strongSelf playVideo:strongSelf.model];
            }
//        }
    }];
}

- (void)requestAddLike:(BOOL)isLike {
    WeakSelf
    [LotteryNetworkUtil getShortVideoFavoriteBlock:isLike videoId:self.model.video_id block:^(NetworkData *networkData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            strongSelf.protraitControlView.model = strongSelf.model;
            strongSelf.landscapeControlView.model = strongSelf.model;
            return;
        }

        if ([strongSelf.model.video_id isEqualToString:minstr(networkData.data[@"video_id"])]) {
            strongSelf.model.is_like = [minstr(networkData.data[@"is_like"]) intValue];
            strongSelf.model.likes_count = strongSelf.model.likes_count + (strongSelf.model.is_like == 1 ? 1 : -1);
            strongSelf.protraitControlView.model = strongSelf.model;
            strongSelf.landscapeControlView.model = strongSelf.model;
        }

        NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
        newDic[@"video_id"] = strongSelf.model.video_id;
        newDic[@"is_like"] = @(strongSelf.model.is_like);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateShortVideoLike" object:newDic];
        if (strongSelf.model.is_like) {
            NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
            newDic[@"model"] = strongSelf.model;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShortVideoLikeForAdd" object:newDic];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShortVideoLikeForRemove" object:newDic];
        }

        if (strongSelf.model.is_like &&
            [strongSelf.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapLike)]) {
            [strongSelf.delegate shortVideoPlayerManagerDelegateForTapLike];
        }
    }];
}

- (void)requestFollow {
    self.isFollowing = YES;
    NSDictionary *dic = @{
        @"touid": self.model.uid,
        @"is_follow": @(1)
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isFollowing = NO;
        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                return;
            }

            NSDictionary *dic = [info firstObject];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                return;
            }

            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            newDic[@"uid"] = strongSelf.model.uid;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLiveplayAttion" object:newDic];
        } else {
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isFollowing = NO;
    }];
}

#pragma mark - ShortVideoPortraitControlViewDelegate
- (void)shortVideoPortraitControlViewDelegateForTapChat {
    if ([self.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapChat)]) {
        [self.delegate shortVideoPlayerManagerDelegateForTapChat];
    }
}

- (void)shortVideoPortraitControlViewDelegateForTapLike:(BOOL)isLike {
    [self requestAddLike:isLike];
    [MobClick event:@"shortvideo_likevideo_click" attributes:@{@"eventType": @(1)}];
}

- (void)shortVideoPortraitControlViewDelegateForTapFullScreen {
    WeakSelf
    [self.player enterFullScreen:YES animated:YES completion:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.player.controlView.hidden = NO;
        strongSelf.landscapeControlView.slider.player = strongSelf.player;
    }];
    [MobClick event:@"shortvideo_fullvideo_click" attributes:@{@"eventType": @(1)}];
}

- (void)shortVideoPortraitControlViewDelegateForTapFollowAnchor {
    [self requestFollow];
    [MobClick event:@"shortvideo_followuser_click" attributes:@{@"eventType": @(1)}];
}

- (void)shortVideoPortraitControlViewDelegateForTapGotoAnchor {
    if (self.isFollowing) return; // 打关注API过程不让用户点进去个人页
    if ([self.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapGotoAnchor)]) {
        [self.delegate shortVideoPlayerManagerDelegateForTapGotoAnchor];
    }
}

- (void)shortVideoPortraitControlViewDelegateForTapHashtag:(NSString*)hashtag {
    if ([self.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapHashtag:)]) {
        [self.delegate shortVideoPlayerManagerDelegateForTapHashtag:hashtag];
    }
}

- (void)shortVideoPortraitControlViewDelegateForTapRetryLoadVideo {
    [self requestPlayVideo:YES];
}

- (void)shortVideoPortraitControlViewDelegateForTapPlay:(BOOL)isPlay {
    self.isPlay = isPlay;
    if (!isPlay) {
        [self.protraitControlView hiddenLoading:YES];
        [self.landscapeControlView hiddenLoading:YES];
    }
}

#pragma mark - ShortVideoLandscapeControlViewDelegate
- (void)shortVideoLandscapeControlViewDelegateForTapBack {
    WeakSelf
    [self.player enterFullScreen:NO animated:YES completion:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.player.controlView.hidden = NO;
    }];
}

- (void)shortVideoLandscapeControlViewDelegateForTapLike:(BOOL)isAdd {
    [self requestAddLike:isAdd];
}


- (void)shortVideoLandscapeControlViewDelegateForTapChat {
    if ([self.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapChat)]) {
        [self.delegate shortVideoPlayerManagerDelegateForTapChat];
    }
}

- (void)shortVideoLandscapeControlViewDelegateForTapFollowAnchor {
    [self requestFollow];
    [MobClick event:@"shortvideo_followuser_click" attributes:@{@"eventType": @(1)}];
}

- (void)shortVideoLandscapeControlViewDelegateForTapGotoAnchor {
    if (self.player.controlView == self.landscapeControlView) {
        WeakSelf
        [self.player enterFullScreen:NO animated:YES completion:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.player.controlView.hidden = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapGotoAnchor)]) {
                [strongSelf.delegate shortVideoPlayerManagerDelegateForTapGotoAnchor];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(shortVideoPlayerManagerDelegateForTapGotoAnchor)]) {
            [self.delegate shortVideoPlayerManagerDelegateForTapGotoAnchor];
        }
    }
}

- (void)shortVideoLandscapeControlViewDelegateForTapRetryLoadVideo {
    [self requestPlayVideo:YES];
}

- (void)shortVideoLandscapeControlViewDelegateForTapPlay:(BOOL)isPlay {
    self.isPlay = isPlay;
    if (!isPlay) {
        [self.protraitControlView hiddenLoading:YES];
        [self.landscapeControlView hiddenLoading:YES];
    }
}

#pragma mark - progress
- (void)saveProgress:(NSTimeInterval)currentTime total:(NSTimeInterval)totalTime videoId:(NSString*)videoId title:(NSString*)title {
//    if (currentTime <= 0) {
//        return;
//    }

    if ((int)currentTime == (int)totalTime) {
        currentTime = 0;
    }

    NSString *progress = [NSString stringWithFormat:@"%d|%d",
                          (int)currentTime,
                          (int)totalTime];

    [ShortVideoProgressManager saveUserProgress:progress videoId:videoId title:title];
}

@end
