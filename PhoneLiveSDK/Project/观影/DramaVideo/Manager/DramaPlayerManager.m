//
//  DramaPlayerManager.m
//  DramaTest
//
//  Created by s5346 on 2024/5/1.
//

#import "DramaPlayerManager.h"
#import "ZFPlayer.h"
#import "ZFIJKPlayerManager.h"
//#import <ZFPlayer/ZFAVPlayerManager.h>
#import "DramaLandscapeVideoControlView.h"
#import "DramaProgressModel.h"
#import "KTVHTTPCache.h"
#import "VideoProgressManager.h"

@interface DramaPlayerManager () <DramaPortraitVideoControlViewDelegate, DramaLandscapeVideoControlViewDelegate> {
}

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) DramaLandscapeVideoControlView *landscapeControlView;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, weak) DramaPortraitVideoControlView *protraitControlView;
@property (nonatomic, weak) DramaVideoInfoModel* model;
@property (nonatomic, weak) DramaInfoModel* infoModel;

@end

@implementation DramaPlayerManager

- (instancetype)initWithTableView:(UITableView*)tableView {
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{DramaPlayerManagerAutoNextIfNeed: @YES}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self initPlayer:tableView];
    }
    return self;
}

- (void)reset {
    [self.player stop];
    self.player = nil;
}

- (void)dealloc {
    NSLog(@"DramaPlayerManager release");
}

#pragma mark - private


- (void)initPlayer:(UITableView*)tableView {
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

    
    ZFPlayerController *player = [ZFPlayerController playerWithScrollView:tableView playerManager:manager containerViewTag:100];
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    player.allowOrentitaionRotation = NO; // 禁止自动旋转
//    [player.currentPlayerManager setScalingMode:ZFPlayerScalingModeAspectFill];
    self.player = player;

    WeakSelf
    // 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        NSLog(@"---===playerDidToEnd");
        STRONGSELF
        BOOL isNext = [strongSelf autoNextIfNeed];
        if ([strongSelf.delegate respondsToSelector:@selector(dramaPlayerManagerDelegateForEnd:)]) {
            [strongSelf.delegate dramaPlayerManagerDelegateForEnd:isNext];
        }
    };

    player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        STRONGSELF
        CGSize size = strongSelf.player.currentPlayerManager.view.coverImageView.image.size;
        if (size.width > size.height) {
            strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    };

    player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
        if (size.width <= 0 && size.height <= 0) {
            return;
        }
        NSLog(@">>>> %@", NSStringFromCGSize(size));
        STRONGSELF
        BOOL isFill = size.width < size.height;
        [strongSelf.protraitControlView hiddenFullScreen:isFill];
        ZFPlayerScalingMode mode = isFill ? ZFPlayerScalingModeAspectFill : ZFPlayerScalingModeAspectFit;
        if (strongSelf.player.currentPlayerManager.scalingMode != mode) {
            [strongSelf.player.currentPlayerManager setScalingMode:mode];
        }
        if (strongSelf.player.currentPlayerManager.view.scalingMode != mode) {
            [strongSelf.player.currentPlayerManager.view setScalingMode:mode];
        }
        strongSelf.player.currentPlayerManager.view.coverImageView.contentMode = isFill ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    };

    // 開始播放
    player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        STRONGSELF
        NSLog(@">>>>>playerReadyToPlay");
        DramaProgressModel *progressModel = [VideoProgressManager loadProgress:strongSelf.model.skit_id episodeNumber:strongSelf.model.episode_number];
        [self.player seekToTime:progressModel.currentTime completionHandler:nil];

        if (strongSelf.isFullScreen) {
            [strongSelf dramaPortraitVideoControlViewDelegateForTapFullScreen];
        }
    };

    // 加载状态
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        NSLog(@"---===playerLoadStateChanged %ld", loadState);
        STRONGSELF
        if (loadState == ZFPlayerLoadStateStalled || loadState == ZFPlayerLoadStatePlayable) {
//            [strongSelf.player.currentPlayerManager play];
        }
    };

    // 播放时间
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        STRONGSELF
        [strongSelf.protraitControlView.slider updateCurrentTime:currentTime totalTime:duration];
        [strongSelf.landscapeControlView.slider updateCurrentTime:currentTime totalTime:duration];
    };

    // 方向即将改变
    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        STRONGSELF
        strongSelf.player.controlView.hidden = YES;
    };

    // 方向已经改变
    player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        STRONGSELF
        [strongSelf changeFullScreen:isFullScreen];
    };
}

- (void)setupVideoInfoWithCell:(VideoTableViewCell *)cell model:(DramaVideoInfoModel*)model infoModel:(DramaInfoModel*)infoModel {
    [cell.controlView layoutIfNeeded];
    if (![self.model.video_id isEqualToString:model.video_id]) {
        self.player.assetURL = [NSURL URLWithString:@""];
        [self initVideo];
    }

    self.model = model;
    self.infoModel = infoModel;
    [cell update:model infoModel:infoModel];
    self.landscapeControlView.model = model;
    self.landscapeControlView.infoModel = infoModel;
    [self changeFullScreen:self.isFullScreen];

    // 设置播放内容视图
    self.player.containerView = cell.coverImgView;

    cell.controlView.slider.player = self.player;
    cell.controlView.delegate = self;
    self.protraitControlView = cell.controlView;
    self.player.controlView = cell.controlView;

    // 设置封面图片
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.over]];

    [cell.controlView hiddenPlayButton:YES];
}

- (void)playVideo:(DramaVideoInfoModel*)model {
    if (![self.model.video_id isEqualToString:model.video_id]) {
        return;
    }
    if (model.play_url.length > 0) {
        NSURL *videoUrl = [NSURL URLWithString:model.play_url];
        NSURL *cacheUrl = [KTVHTTPCache proxyURLWithOriginalURL:videoUrl];
        // 播放内容一致，不做处理
        if ([self.player.assetURL.absoluteString isEqualToString:cacheUrl.absoluteString]) return;

        // 设置播放地址
        self.player.assetURL = cacheUrl;
        [self.player.currentPlayerManager setCryption:@""];
        
        [self.player.currentPlayerManager play];
    }
}

- (void)initVideo {
    [self.protraitControlView updateCurrentTime:0 totalTime:0];
    [self.landscapeControlView.slider updateCurrentTime:0 totalTime:0];
}

- (void)changeFullScreen:(BOOL)isFullScreen {
    if (isFullScreen) {
        self.landscapeControlView.hidden = NO;
        self.player.controlView = self.landscapeControlView;
    }else {
        self.protraitControlView.hidden = NO;
        self.player.controlView = self.protraitControlView;
    }
    self.isFullScreen = isFullScreen;
}

- (void)changeAutoNext:(BOOL)open {
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:DramaPlayerManagerAutoNextIfNeed];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.landscapeControlView changeAutoNext:open];
    [self.protraitControlView changeAutoNext:open];
}

- (BOOL)autoNextIfNeed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:DramaPlayerManagerAutoNextIfNeed];
}

#pragma mark - lazy
- (DramaLandscapeVideoControlView *)landscapeControlView {
    if (!_landscapeControlView) {
        _landscapeControlView = [[DramaLandscapeVideoControlView alloc] init];
        _landscapeControlView.delegate = self;
    }
    return _landscapeControlView;
}

#pragma mark - API
- (void)requestAddStar:(BOOL)isAdd {
    NSDictionary *dic = @{
        @"skit_pid": self.model.skit_id,
        @"action": isAdd ? @0 : @1
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.toggleFavoriteSkit" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf.infoModel.is_favorite = isAdd;
            strongSelf.protraitControlView.infoModel = strongSelf.infoModel;
            strongSelf.landscapeControlView.infoModel = strongSelf.infoModel;

            if (isAdd == NO) {
                NSDictionary *userInfo = @{@"skitId": strongSelf.model.skit_id};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DramaFavoriteViewControllerRemoveSkit"
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        } else {
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - DramaPortraitVideoControlViewDelegate
- (void)dramaPortraitVideoControlViewDelegateForTapTicket {

}

- (void)dramaPortraitVideoControlViewDelegateForTapStar:(BOOL)isAdd {
    [self requestAddStar:isAdd];
}

- (void)dramaPortraitVideoControlViewDelegateForTapFullScreen {
    [self.player enterFullScreen:YES animated:YES completion:^{
        self.player.controlView.hidden = NO;
        self.landscapeControlView.slider.player = self.player;
    }];
}

- (void)dramaPortraitVideoControlViewDelegateForTapPay {
    if ([self.delegate respondsToSelector:@selector(dramaPlayerManagerDelegateForTapPay:)]) {
        [self.delegate dramaPlayerManagerDelegateForTapPay:self.model];
    }
}

- (void)dramaPortraitVideoControlViewDelegateForTapAutoNext:(BOOL)open {
    [self changeAutoNext:open];
}

#pragma mark - DramaLandscapeVideoControlViewDelegate
- (void)dramaLandscapeVideoControlViewDelegateForTapBack {
    [self.player enterFullScreen:NO animated:YES completion:^{
        self.player.controlView.hidden = NO;
    }];
}

- (void)dramaLandscapeVideoControlViewDelegateForTapStar:(BOOL)isAdd {
    [self requestAddStar:isAdd];
}

- (void)dramaLandscapeVideoControlViewDelegateForTapAutoNext:(BOOL)open {
    [self changeAutoNext:open];
}

- (void)dramaLandscapeVideoControlViewDelegateForTapTicket {
}

@end
