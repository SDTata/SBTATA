//
//  SkitPreload.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPreload.h"
#import "KTVHTTPCache.h"
#import "M3U8PlaylistModel.h"
#import "VideoProgressManager.h"
#import "SkitPlayerViewController.h"
#import "ZFIJKPlayerManager.h"
#import <FFAES/GTMBase64.h>
#import "ZFPlayer.h"

@interface SkitPreload ()

@property(nonatomic, strong) ZFPlayerController *player;
@property(nonatomic, strong) SkitVideoInfoModel *model;
//@property(nonatomic, assign) BOOL isNeedRequest;
@property(nonatomic, assign) NSInteger retryCount;

@end

@implementation SkitPreload

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initManager];
    }
    return self;
}

- (void)initManager {
    ZFIJKPlayerManager *manager = [[ZFIJKPlayerManager alloc] init];
    manager.shouldAutoPlay = NO; // 自动播放
    IJKFFOptions *options = manager.options;
    [options setFormatOptionIntValue:1 forKey:@"http-detect-range-support"];
    // 减少探测大小以加快启动时间
    [options setPlayerOptionIntValue:1024 * 4 forKey:@"probesize"];
    
    // 降低最大缓冲区大小，以避免在弱网情况下占用过多内存
    [options setPlayerOptionIntValue:5 * 1024 * 1024 forKey:@"max-buffer-size"];
    
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    // 设置读取超时为 5 秒（单位为微秒）
    [options setFormatOptionIntValue:5 * 1000 * 1000 forKey:@"timeout"];
    
    // 启用包缓冲，适应弱网环境
    [options setPlayerOptionIntValue:1 forKey:@"packet-buffering"];
    //
    //    // 启用硬件解码，提升性能
    [options setPlayerOptionIntValue:videotoolboxTATA forKey:@"videotoolbox"];
    ////
    //    // 允许适度丢帧，以保持播放流畅
    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];
    //
    //    // 使用 UDP 传输，适应实时传输协议（RTSP）
    [options setFormatOptionValue:@"udp" forKey:@"rtsp_transport"];
    //
    // 设置较低的缓冲区大小，以减少缓冲时间
    [options setPlayerOptionIntValue:3000 forKey:@"max_cached_duration"];
    
    // 设置较低的最小缓冲大小，以减少缓冲时间
    [options setPlayerOptionIntValue:500 forKey:@"min_frames"];
    //
    // 设置最大丢帧次数
    [options setPlayerOptionIntValue:12 forKey:@"max-fps"];
    
    // 弱网环境用
    [options setPlayerOptionIntValue:1 forKey:@"start-on-prepared"];
    // 自动拼接ts域名请求
    [options setPlayerOptionIntValue:1 forKey:@"hls_io_protocol_enable"];
    
    
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
    
    self.player = [[ZFPlayerController alloc] init];
    self.player.currentPlayerManager = manager;
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    self.player.allowOrentitaionRotation = NO;
    
    WeakSelf
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        STRONGSELF
        NSLog(@"---===preload playerPlayFailed222 %@", strongSelf.model.desc);
        if (strongSelf == nil) {
            return;
        }
        if ([error isKindOfClass:[NSNumber class]]) {
            if ([error integerValue] == 1) {
                
                [strongSelf.player stop];
                
                strongSelf.retryCount ++;
                if (strongSelf.retryCount <= 10) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        STRONGSELF
                        [strongSelf request:YES];
                    });
                }
            }
        }
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        STRONGSELF
        NSLog(@"---===preload playerReadyToPlay %@", strongSelf.model.desc);
    };
    
    // 加载状态
    self.player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        NSLog(@"---===preload playerLoadStateChanged %ld", loadState);
        //        STRONGSELF
        //        if (loadState == ZFPlayerLoadStatePlayable) {
        //            strongSelf.isNeedRequest = NO;
        //        }
    };
}

- (void)addModel:(SkitVideoInfoModel*)model {
    self.model = model;
    self.retryCount = 0;
    //    self.isNeedRequest = YES;
    [self request:NO];
}

- (void)playVideo {
    NSLog(@"---===preload %@", self.model.desc);
    NSURL *videoUrl = [NSURL URLWithString:self.model.video_url];
    NSLog(@"---===preload %@", self.model.video_url);
    //    NSURL *videoUrl = [NSURL URLWithString:@"https://www.w3schools.com/html/mov_bbb.mp4"];//測試
    NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:videoUrl];
    //    if (cacheUrl == nil || videoUrl == nil || self.model.isNeedPay || self.model.video_url.length <= 0 || self.model.encrypted_key.length <= 0) {
    //        [self request:NO];
    //        return;
    //    }
    
    // 设置播放地址
    self.player.assetURL = cacheUrl;
    [self.player.currentPlayerManager setCryption:self.model.encrypted_key];
}

- (void)clear {
    [self.player.currentPlayerManager stop];
    self.player = nil;
}

- (void)request:(BOOL)isRefresh {
    WeakSelf
    [SkitPlayerViewController requestVideo:self.model.video_id autoDeduct:NO refresh_url:isRefresh completion:^(SkitVideoInfoModel * _Nonnull newModel, BOOL success) {
        STRONGSELF
        if (strongSelf == nil||!success) {
            return;
        }
        
        if (newModel.video_url.length <= 0) {
            return;
        }
        strongSelf.model = newModel;
        [strongSelf playVideo];
    }];
}

@end
