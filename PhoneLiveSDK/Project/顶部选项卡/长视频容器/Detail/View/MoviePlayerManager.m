//
//  MoviePlayerManager.m
//  phonelive2
//
//  Created by vick on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MoviePlayerManager.h"
#import "ZFIJKPlayerManager.h"
#import "KTVHTTPCache.h"
#import <GTMBase64.h>
#import "MovieControlView.h"
#import "VideoProgressManager.h"
#import "KTVHCURLTool.h"

#define MaxRetryTime 4
#define MaxRetryDelayTime 5.0

@interface MoviePlayerManager () <MovieControlViewDelegate>

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) MovieControlView *controlView;
@property (nonatomic, assign) int retryTime;

@end

@implementation MoviePlayerManager

- (instancetype)initWithContainerView:(UIView *)containerView {
    self = [super init];
    if (self) {
        [self initPlayer:containerView];
    }
    return self;
}

- (void)reset {
    [self.player stop];
    self.player = nil;
}

- (void)play {
    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
        [self.player.currentPlayerManager play];
    }
}

- (void)pause {
    [self.player.currentPlayerManager pause];
    self.retryTime = 0;
    
    /// 缓存播放进度
    NSString *progress = [NSString stringWithFormat:@"%d|%d", (int)self.player.currentTime, (int)self.player.totalTime];
    [VideoProgressManager saveUserProgress:progress skitId:self.videoModel.video_id episodeNumber:0];
}

- (void)startTrying {
    self.player.currentPlayerManager.muted = NO;
    [self.controlView startTrying];
}

- (void)stopTrying {
    self.player.currentPlayerManager.muted = YES;
    [self.controlView stopTrying];
}

- (void)closeTrying {
    self.player.currentPlayerManager.muted = NO;
    [self.controlView closeTrying];
}

- (void)dealloc {
    NSLog(@"MoviePlayerManager release");
}

#pragma mark - private
- (MovieControlView *)controlView {
    if (!_controlView) {
        _controlView = [MovieControlView new];
        _controlView.delegate = self;
    }
    return _controlView;
}


- (void)initPlayer:(UIView *)containerView {
    
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


    
    ZFPlayerController *player = [ZFPlayerController playerWithPlayerManager:manager containerView:containerView];
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    player.allowOrentitaionRotation = NO; // 禁止自动旋转
    player.controlView = self.controlView;
    self.player = player;
    
    WeakSelf
    /// 播放失败回调
    player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([error isKindOfClass:[NSNumber class]]) {
            if ([error integerValue] == 1) {
                [strongSelf.player.currentPlayerManager stop];
                
                strongSelf.retryTime += 1;
                if (strongSelf.retryTime < MaxRetryTime) {
                    float delayTime = strongSelf.retryTime / 4.0 * 0.2;
                    if (delayTime > MaxRetryDelayTime) {
                        delayTime = MaxRetryDelayTime;
                    }
                    vkGcdAfter(delayTime, ^{
                        [strongSelf refreshPlayUrl];
                    });
                } else {
                    /// 试看状态，不显示重试
                    if (strongSelf.controlView.tryingFloatView.isHidden) {
                        [strongSelf.controlView hiddenRetryButton:NO];
                    }
                }
            }
        }
    };
    
    /// 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        STRONGSELF
        if ([strongSelf.delegate respondsToSelector:@selector(moviePlayerManagerDelegatePlayFinish)]) {
            [strongSelf.delegate moviePlayerManagerDelegatePlayFinish];
        }
    };
    
    // 方向即将改变
    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (isFullScreen) {
            [strongSelf.player.currentPlayerManager setScalingMode:ZFPlayerScalingModeAspectFill];
        } else {
            [strongSelf changeVideoScale];
        }
    };
    
    /// 播放进度
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!strongSelf.videoModel.can_play) {
            /// 试看结束
            if (currentTime >= strongSelf.videoModel.preview_duration) {
                [strongSelf stopTrying];
                if ([strongSelf.delegate respondsToSelector:@selector(moviePlayerManagerDelegatePlayFinish)]) {
                    [strongSelf.delegate moviePlayerManagerDelegatePlayFinish];
                }
            /// 重新试看
            } else {
                [strongSelf startTrying];
            }
        }
    };
}

- (void)changeVideoScale {
    UIViewContentMode imageModel = self.videoModel.meta.isProtrait ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
    self.player.currentPlayerManager.view.coverImageView.contentMode = imageModel;
    ZFPlayerScalingMode mode = self.videoModel.meta.isProtrait ? ZFPlayerScalingModeAspectFit : ZFPlayerScalingModeAspectFill;
    [self.player.currentPlayerManager.view setScalingMode:mode];
    [self.player.currentPlayerManager setScalingMode:mode];
    self.player.orientationObserver.fullScreenMode = self.videoModel.meta.isProtrait ? ZFFullScreenModePortrait : ZFFullScreenModeLandscape;
}

- (void)refreshPlayUrl {
    WeakSelf
    [LotteryNetworkUtil getMoviePlay:self.videoModel.video_id isRefresh:YES block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status && !networkData.data) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        if (networkData.msg.length > 0) {
            [MBProgressHUD showSuccess:networkData.msg];
        }

        if (self.videoModel.can_play == 0 && self.videoModel.ticket_cost > 0) {
            [VideoTicketFloatView refreshFloatData];
        }
        ShortVideoModel *model = [ShortVideoModel modelFromJSON:networkData.data[@"movie"]];
        [strongSelf playWithModel:model];
    }];
}

- (void)playWithModel:(ShortVideoModel *)model {
    if (model.video_url.length <= 0) {
        return;
    }
    self.videoModel = model;
    self.controlView.model = model;
    [self changeVideoScale];
    
//    NSURL *videoUrl = [NSURL URLWithString:model.video_url];
//    NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:videoUrl];
    
    NSString *urlKey = [[KTVHCURLTool tool] cacheUrlKeyMd5Path:model.video_url];
    NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",urlKey]]];
    
//    // 播放内容一致，不做处理
//    if ([self.player.assetURL.absoluteString isEqualToString:cacheUrl.absoluteString]) {
//        return;
//    }
    
    // 设置播放地址
    self.player.assetURL = cacheUrl;
    [self.player.currentPlayerManager setCryption:model.encrypted_key];
    
    /// 播放进度
    NSDictionary *progressDic = [VideoProgressManager loadUserProgress:self.videoModel.video_id];
    NSInteger currentTime = [progressDic[@"0"] integerValue];
    if (currentTime >= (model.video_duration - 2)) {
        currentTime = 0;
    }
    [self.player seekToTime:currentTime completionHandler:nil];
    
    [self.player.currentPlayerManager play];
}

#pragma mark - MovieControlViewDelegate
- (void)movieControlViewDelegateForTapRetryLoadVideo {
    [self refreshPlayUrl];
}

- (void)movieControlViewDelegateForTapPortraitFullScreen {
    if ([self.delegate respondsToSelector:@selector(moviePlayerManagerDelegatePlayPortraitFullScreen)]) {
        [self.delegate moviePlayerManagerDelegatePlayPortraitFullScreen];
    }
}

- (void)movieControlViewDelegateForTapTryAction:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(moviePlayerManagerDelegatePlayTapTryAction:)]) {
        [self.delegate moviePlayerManagerDelegatePlayTapTryAction:type];
    }
}

- (void)movieControlViewDelegateForTapVoice:(BOOL)isMuted {
    if ([self.delegate respondsToSelector:@selector(movieControlViewDelegateForTapVoice:)]) {
        [self.delegate movieControlViewDelegateForTapVoice: isMuted];
    }
}
@end
