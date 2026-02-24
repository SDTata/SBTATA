//
//  MovieControlView.m
//  phonelive2
//
//  Created by vick on 2024/7/16.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MovieControlView.h"
#import "GradientView.h"
#import "DouYinLoading.h"
#import "GKDYTools.h"
#import "ShortVideoFavoriteView.h"
#import "GKDYVideoSlider.h"
#import "SpeedUpTipView.h"
#import "VideoVipAlertView.h"
#import <UMCommon/UMCommon.h>
#import "VideoPayCoverView.h"
#import "VipPayAlertView.h"

@interface MovieControlView () {
    BOOL isShowLoading;
}

@property (nonatomic, strong) UIView *topContainerView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) GKDYVideoSlider *slider;
@property (nonatomic, strong) DouYinLoading *douYinLoading;
@property (nonatomic, strong) SpeedUpTipView *speedView;

// 重試按鈕
@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, strong) UILabel *tryTimeLabel;

@property (nonatomic, strong) VideoPayCoverView *payCoverView;
@property (nonatomic, strong) UIButton *openButton;

@end

@implementation MovieControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - UI
- (void)setupViews {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPressGesture];
    
    [self addSubview:self.payCoverView];
    [self.payCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.backButton];
    [self.topContainerView addSubview:self.contentLabel];
    [self.topContainerView addSubview:self.voiceButton];
    
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView addSubview:self.slider];
    [self.bottomContainerView addSubview:self.playBtn];
    [self.bottomContainerView addSubview:self.timeLabel];
    [self.bottomContainerView addSubview:self.fullScreenBtn];
    
    [self addSubview:self.speedView];
    [self addSubview:self.retryButton];
    [self addSubview:self.tryingFloatView];
    
    // top
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(40+VK_STATUS_H);
        make.top.mas_equalTo(0);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft);
        make.size.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.left.mas_equalTo(self.backButton.mas_right).offset(5);
        make.right.mas_equalTo(-40);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight);
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    // bottom
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(50);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft).offset(10);
        make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight).offset(-10);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(40);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider);
        make.bottom.equalTo(self.bottomContainerView).offset(-20);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.slider);
        make.centerY.equalTo(self.playBtn.mas_centerY);
        make.size.mas_equalTo(30);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.left.equalTo(self.playBtn.mas_right).offset(10);
    }];
    
    [self.tryingFloatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomContainerView.mas_top).offset(-3);
        make.left.mas_equalTo(8);
        make.height.mas_equalTo(26);
    }];
    
    [self.speedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(VK_STATUS_H + VKPX(50));
        make.centerX.equalTo(self);
        make.height.equalTo(@44);
    }];
    
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.center.equalTo(self);
    }];
    
    [self updateVoiceStatus];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.player.isFullScreen && self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) {
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
    } else {
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40+VK_STATUS_H);
        }];
    }
    self.topContainerView.verticalColors = @[vkColorHexA(0x000000, 1.0), vkColorHexA(0x000000, 0.0)];
}

- (void)updateVoiceStatus {
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf.player.muted) {
            [strongSelf.voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOffIcon"] forState:UIControlStateNormal];
        } else {
            [strongSelf.voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOnIcon"] forState:UIControlStateNormal];
        }
    });
}

- (void)setModel:(ShortVideoModel *)model {
    _model = model;
    self.contentLabel.text = model.title;
    [self updateVoiceStatus];
    
    self.payCoverView.is_vip = model.is_vip;
    self.payCoverView.ticket_cost = model.ticket_cost;
    self.payCoverView.coin_cost = model.coin_cost;
    [self.payCoverView refresh];
    
    if (model.is_vip && [Config getVip_type].integerValue <= 0) {
        [self.openButton setTitle:YZMsg(@"vip_pay_button") forState:UIControlStateNormal];
    } else {
        [self.openButton setTitle:YZMsg(@"short_video_buy") forState:UIControlStateNormal];
    }
    
    self.tryTimeLabel.text = [NSString stringWithFormat:YZMsg(@"movie_trying_load_tip"), [GKDYTools convertTimeSecond:model.preview_duration]];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideMenuView) withObject:nil afterDelay:3];
}

- (void)hiddenRetryButton:(BOOL)isHidden {
    self.retryButton.hidden = isHidden;
}

- (void)hiddenFullScreen:(BOOL)isHidden {
    self.fullScreenBtn.hidden = isHidden;
}

- (void)startTrying {
    self.payCoverView.hidden = YES;
    self.tryingFloatView.hidden = NO;
    [self hiddenFullScreen:NO];
}

- (void)stopTrying {
    self.payCoverView.hidden = NO;
    self.tryingFloatView.hidden = NO;
    [self hiddenFullScreen:NO];

    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (!manager.isPlaying) {
        [manager play];
    }
}

- (void)closeTrying {
    self.payCoverView.hidden = YES;
    self.tryingFloatView.hidden = YES;
    [self hiddenFullScreen:NO];
}

#pragma mark - ZFPlayerMediaControl
- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;

    self.slider.player = player;
    self.playBtn.selected = player.currentPlayerManager.isPlaying;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer {
    if (videoPlayer.isFullScreen) {
    }
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
//    if (!self.topContainerView.hidden) {
//        self.topContainerView.hidden = YES;
//        self.bottomContainerView.hidden = YES;
//        return;
//    }
    if (!self.topContainerView.hidden) {
        [self handleSingleTapped];
    }
    self.topContainerView.hidden = NO;
    self.bottomContainerView.hidden = NO;
    
    /// 3秒后自动隐藏菜单
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (!self.topContainerView.hidden && self.player.currentPlayerManager.isPlaying) {
        [self performSelector:@selector(hideMenuView) withObject:nil afterDelay:3];
    }
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self handleSingleTapped];
    
    self.topContainerView.hidden = NO;
    self.bottomContainerView.hidden = NO;
    
    /// 3秒后自动隐藏菜单
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (!self.topContainerView.hidden && self.player.currentPlayerManager.isPlaying) {
        [self performSelector:@selector(hideMenuView) withObject:nil afterDelay:3];
    }
}

// 長按加速
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (!self.player.currentPlayerManager.isPlaying) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.player.currentPlayerManager setRate:2.0];
        self.speedView.hidden = NO;
        self.topContainerView.hidden = NO;
        self.bottomContainerView.hidden = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        [self.player.currentPlayerManager setRate:1.0];
        self.speedView.hidden = YES;
        [self performSelector:@selector(hideMenuView) withObject:nil afterDelay:3];
    }
}

- (void)hideMenuView {
    if (!self.tryingFloatView.isHidden || !self.payCoverView.isHidden) {
        return;
    }
    self.topContainerView.hidden = YES;
    self.bottomContainerView.hidden = YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [GKDYTools convertTimeSecond:currentTime], [GKDYTools convertTimeSecond:totalTime]];
    [self.slider updateCurrentTime:currentTime totalTime:totalTime];
    
    NSInteger timeOffset = self.model.preview_duration - currentTime;
    if (timeOffset <= 0) {
        self.tryTimeLabel.text = YZMsg(@"movie_trying_end_tip");
    } else {
        self.tryTimeLabel.text = [NSString stringWithFormat:YZMsg(@"movie_trying_load_tip"), [GKDYTools convertTimeSecond:timeOffset]];
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer playStateChanged:(ZFPlayerPlaybackState)state {
    if (state == ZFPlayerPlayStatePlaying) {
        self.playBtn.selected = YES;
    } else {
        self.playBtn.selected = NO;
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state {
    NSLog(@">>>>ZFPlayerLoadState %ld", state);
    switch (state) {
        case ZFPlayerLoadStateUnknown:
            isShowLoading = NO;
            [self showLoadingIfNeed];
            break;
        case ZFPlayerLoadStatePrepare:
            isShowLoading = YES;
            [self showLoadingIfNeed];
            break;
        case ZFPlayerLoadStatePlayable:
            isShowLoading = NO;
            [self showLoadingIfNeed];
            break;
        case ZFPlayerLoadStatePlaythroughOK:
            isShowLoading = NO;
            [self showLoadingIfNeed];
            break;
        case ZFPlayerLoadStateStalled:
            isShowLoading = YES;
            [self showLoadingIfNeed];
            break;
        default:
            break;
    }
}

- (void)showLoadingIfNeed {
    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
        return;
    }
    if (!isShowLoading) {
        self.douYinLoading.hidden = YES;
        [self.slider hideLoading];
        return;
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (!strongSelf) return;
        strongSelf.douYinLoading.hidden = !strongSelf->isShowLoading;
        if (strongSelf->isShowLoading) {
            [strongSelf.slider showLoading];
        } else {
            [strongSelf.slider hideLoading];
        }
    });
}

- (void)handleSingleTapped {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [self.slider hideLoading];
        [manager pause];
        [self.slider showLargeSlider];
//        self.playImageView.hidden = NO;
//        self.playImageView.transform = CGAffineTransformMakeScale(3, 3);
//        [UIView animateWithDuration:0.15 animations:^{
//            self.playImageView.alpha = 0.7;
//            self.playImageView.transform = CGAffineTransformIdentity;
//        }];
    }else {
        [manager play];
        [self.slider showSmallSlider];
//        [UIView animateWithDuration:0.15 animations:^{
//            self.playImageView.alpha = 0;
//        } completion:^(BOOL finished) {
//            self.playImageView.hidden = YES;
//        }];
    }
}

#pragma mark - Action
- (void)back {
    if (self.player.isFullScreen) {
        [self.player enterFullScreen:NO animated:YES];
        return;
    }
    [GameFloatView showSmallGameView];
    [[MXBADelegate sharedAppDelegate] popViewController:YES];
}

- (void)tapVoice {
    BOOL isMuted = self.player.isMuted;
    [self.player setMuted:!self.player.isMuted];
    // 防止原本是靜音，setMuted 打開還是會沒聲音
    if (isMuted && self.player.volume == 0) {
        [self.player setVolume:0.5];
    }
    [self updateVoiceStatus];
    [self.delegate movieControlViewDelegateForTapVoice: !isMuted];
}

- (void)playAction {
    if (!self.payCoverView.isHidden) {
        return;
    }
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
    }else {
        [manager play];
    }
    self.playBtn.selected = manager.isPlaying;
}

- (void)clickTryAction {
    [self.payCoverView clickLockAction];
}

- (void)clickFullScreenAction {
    
    if (GameFloatView.gameIsShow) {
        [MBProgressHUD showError:YZMsg(@"video_game_can_full")];
        return;
    }
    
    /// 试看中，点击弹窗付费
    if (!self.tryingFloatView.isHidden) {
        [self clickTryAction];
        return;
    }
    
    /// VIP才能全屏
    if ([Config getVip_type].integerValue <= 0) {
        VipPayAlertView *view = [VipPayAlertView new];
        [view showFromBottom];
        return;
    }
    
    [MobClick event:@"longvideo_full_click" attributes:@{@"eventType": @(1)}]; // [self.delegate movieControlViewDelegateForTapPortraitFullScreen]; 被注解掉了，先在这埋点，之后厘清原因后再调整
    
//    if (self.model.meta.isProtrait) {
//        if ([self.delegate respondsToSelector:@selector(movieControlViewDelegateForTapPortraitFullScreen)]) {
//            [self.delegate movieControlViewDelegateForTapPortraitFullScreen];
//        }
//    } else {
        if (self.player.isFullScreen) {
            self.player.currentPlayerManager.view.coverImageView.hidden = NO;
            [self.player enterFullScreen:NO animated:YES];
        } else {
            self.player.currentPlayerManager.view.coverImageView.hidden = YES;
            [self.player enterFullScreen:YES animated:YES];
        }
//    }
}

- (void)retryLoadVideo {
    self.retryButton.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(movieControlViewDelegateForTapRetryLoadVideo)]) {
        [self.delegate movieControlViewDelegateForTapRetryLoadVideo];
    }
}

#pragma mark - Lazy
// top
- (UIView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [UIView new];
//        _topContainerView.backgroundColor = vkColorRGBA(0, 0, 0, 0.1);
    }
    return _topContainerView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[ImageBundle imagewithBundleName:@"person_back_white"] forState:UIControlStateNormal];
//        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor whiteColor];
//        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] init];
        _voiceButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        if (self.player.isMuted) {
            [_voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOffIcon"] forState:UIControlStateNormal];
        } else {
            [_voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOnIcon"] forState:UIControlStateNormal];
        }
        [_voiceButton addTarget:self action:@selector(tapVoice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

// bottom
- (UIView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [UIView new];
        _bottomContainerView.backgroundColor = vkColorRGBA(0, 0, 0, 0.3);
    }
    return _bottomContainerView;
}

- (GKDYVideoSlider *)slider {
    if (!_slider) {
        _slider = [[GKDYVideoSlider alloc] init];
        _slider.sliderView.minimumTrackTintColor = RGB_COLOR(@"#9F57DF", 1);
        [_slider.sliderView setSliderBackgroundColor:RGB_COLOR(@"#9F57DF", 1)];
        _slider.smallSliderBtnHeight = 5.0;
        _slider.smallSliderHeight = 3.0;
        _slider.previewMargin = 50;

        WeakSelf
        _slider.slideBlock = ^(BOOL isDragging) {
            STRONGSELF
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
            if (!isDragging) {
                [strongSelf performSelector:@selector(hideMenuView) withObject:nil afterDelay:3];
            }
        };
    }
    return _slider;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[ImageBundle imagewithBundleName:@"icon_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[ImageBundle imagewithBundleName:@"icon_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = UIColor.whiteColor;
    }
    return _timeLabel;
}

- (UIView *)tryingFloatView {
    if (!_tryingFloatView) {
        _tryingFloatView = [UIView new];
        _tryingFloatView.backgroundColor = vkColorHexA(0x604520, 0.8);
        [_tryingFloatView vk_border:nil cornerRadius:4];
        
        UIButton *openButton = [UIView vk_button:nil image:nil font:vkFontBold(10) color:vkColorHex(0x382814)];
        openButton.backgroundColor = vkColorHex(0xFFC663);
        [openButton vk_border:nil cornerRadius:9];
        openButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        [openButton vk_addTapAction:self selector:@selector(clickTryAction)];
        [_tryingFloatView addSubview:openButton];
        self.openButton = openButton;
        [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-6);
            make.centerY.mas_equalTo(0);
            make.height.mas_equalTo(18);
        }];
        
        UILabel *tryTimeLabel = [UIView vk_label:nil font:vkFont(10) color:vkColorHex(0xFFDCAB)];
        [_tryingFloatView addSubview:tryTimeLabel];
        self.tryTimeLabel = tryTimeLabel;
        [tryTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(6);
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(openButton.mas_left).offset(-4);
        }];
    }
    return _tryingFloatView;
}

//- (DouYinLoading *)douYinLoading {
//    if (!_douYinLoading) {
//        _douYinLoading = [DouYinLoading showInView:self];
//        _douYinLoading.hidden = YES;
//        _douYinLoading.userInteractionEnabled = NO;
//    }
//    return _douYinLoading;
//}

- (SpeedUpTipView *)speedView {
    if (!_speedView) {
        _speedView = [[SpeedUpTipView alloc] init];
        _speedView.hidden = YES;
    }
    return _speedView;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn vk_addTapAction:self selector:@selector(clickFullScreenAction)];
        [_fullScreenBtn setImage:[ImageBundle imagewithBundleName:@"video_fullscreen_btn"] forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [UIButton new];
        _retryButton.backgroundColor = RGB_COLOR(@"#ffffff", 0.3);
        [_retryButton addTarget:self action:@selector(retryLoadVideo) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setImage:[ImageBundle imagewithBundleName:@"icon_unvideo"] forState:UIControlStateNormal];
        _retryButton.layer.cornerRadius = 22;
        _retryButton.layer.masksToBounds = YES;
        _retryButton.hidden = YES;
    }
    return _retryButton;
}

- (VideoPayCoverView *)payCoverView {
    if (!_payCoverView) {
        _payCoverView = [[VideoPayCoverView alloc]initWithFrame:CGRectZero videotype:3];
        _payCoverView.videoType = 3;
        _payCoverView.hidden = YES;
        
        [_payCoverView.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(20);
        }];
       

        _weakify(self)
        _payCoverView.clickPayBlock = ^(NSInteger type) {
            _strongify(self)
            if (self.delegate && [self.delegate respondsToSelector:@selector(movieControlViewDelegateForTapTryAction:)]) {
                [self.delegate movieControlViewDelegateForTapTryAction:type];
            }
        };
    }
    return _payCoverView;
}

@end
