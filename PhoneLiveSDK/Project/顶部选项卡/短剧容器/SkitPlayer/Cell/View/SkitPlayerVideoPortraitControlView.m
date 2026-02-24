//
//  SkitPlayerVideoPortraitControlView.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPlayerVideoPortraitControlView.h"
#import "GKDYTools.h"
#import "SkitPlayerManager.h"
#import "DouYinLoading.h"
#import "StarAnimationView.h"
#import "TouchSuperView.h"
#import "SpeedUpTipView.h"
#import "VideoVipAlertView.h"
#import "VipPayAlertView.h"

@interface SkitPlayerVideoPortraitControlView () {
    BOOL isShowLoading;
}
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) TouchSuperView *bottomView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) StarAnimationView *starButton;
//@property (nonatomic, strong) UIButton *chatButton;
//@property (nonatomic, strong) UILabel *chatNumberLabel;

@property (nonatomic, strong) UIView *fullScreenBtn;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIView *autoNextSwitchView;
@property (nonatomic, strong) UISwitch *autoNextSwitch;
@property (nonatomic, strong) DouYinLoading *douYinLoading;

@property (nonatomic, strong) SpeedUpTipView *speedView;

// 付費
@property (nonatomic, strong) UIStackView *tagStackView;
@property (nonatomic, strong) UIButton *vipTagButton;
@property (nonatomic, strong) UIButton *payTagButton;
// 重試按鈕
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIView *cooldownAndPayButton;
@property (nonatomic, strong) UILabel *cooldownPreviewLabel;

// 选集
@property (nonatomic, strong) UIButton *skitButton;
@property (nonatomic, strong) UILabel *skitLabel;

@end

@implementation SkitPlayerVideoPortraitControlView

@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapped)];
        [self addGestureRecognizer:singleTapGesture];
        [self setupViews];
    }
    return self;
}

- (void)hiddenPlayButton:(BOOL)isHidden {
    self.playImageView.hidden = isHidden;
}

- (void)hiddenRetryButton:(BOOL)isHidden {
    self.retryButton.hidden = isHidden;
    if (!isHidden) {
        [self hiddenLoading:YES];
    }
}

- (void)hiddenLoading:(BOOL)isHidden {
    isShowLoading = !isHidden;
    self.douYinLoading.hidden = isHidden;
    if (isHidden) {
        [self.slider hideLoading];
    } else {
        [self.slider showLoading];
    }
}

- (void)updateShowPayStatus:(float)currentTime {
    if (self.model.isNeedPay) {
        int previewDuration = self.model.preview_duration <= 0 ? 20 : (CGFloat)self.model.preview_duration;
        self.blurEffectView.hidden = !(currentTime >= previewDuration);
        self.payCoverView.hidden = !(currentTime >= previewDuration);
        BOOL isMute = currentTime >= previewDuration;
        if (self.player.currentPlayerManager.muted != isMute) {
            self.player.currentPlayerManager.muted = isMute;
        }

        id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
        if (currentTime >= previewDuration && !manager.isPlaying) {
            [manager play];
        }
    }
}

- (void)setModel:(SkitVideoInfoModel *)model {
    if (![model.video_id isEqualToString:self.model.video_id]) {
        self.blurEffectView.hidden = YES;
        self.payCoverView.hidden = YES;
    }

    _model = model;
    [self updatePayCoverView];

    self.cooldownAndPayButton.hidden = !model.isNeedPay;
    self.retryButton.hidden = YES;

    // pay
    self.vipTagButton.hidden = !(model.is_vip > 0);
    self.payTagButton.hidden = ![ShortVideoModel showPayTagIfNeed:model.coin_cost ticket_cost:model.ticket_cost];

    if (![self.model.video_id isEqualToString:model.video_id]) {
        isShowLoading = NO;
        self.douYinLoading.hidden = YES;
        [self.slider hideLoading];
    }

    if (model.name.length > 0) {
//        self.contentLabel.text = [NSString stringWithFormat:@"%@ | %@", model.name, model.desc];
        self.contentLabel.text = [NSString stringWithFormat:@"%@", model.desc];
    }

    [self updateVoiceStatus];
}

- (void)updatePayCoverView {
    // 隱藏 VideoPayCoverView present
    [self hideAlert:nil];

    self.payCoverView.is_vip = self.model.is_vip;
    self.payCoverView.ticket_cost = self.model.ticket_cost;
    self.payCoverView.coin_cost = self.model.coin_cost;
    [self.payCoverView refresh];

    self.playImageView.hidden = YES;
    if (self.player.currentPlayerManager.assetURL != nil) {
        self.playImageView.hidden = self.player.currentPlayerManager.isPlaying == YES;
    }

    if (_model.isNeedPay == ShortVideoModelPayTypeFree) {
        [self.payTagButton setTitle:YZMsg(@"movie_pay_Purchased") forState:UIControlStateNormal];

        self.blurEffectView.hidden = YES;
        self.payCoverView.hidden = YES;
        self.player.currentPlayerManager.muted = NO;
    } else {
        self.douYinLoading.hidden = YES;
        [self.payTagButton setTitle:YZMsg(@"movie_pay") forState:UIControlStateNormal];

        CGFloat previewTime = self.model.preview_duration;
        NSString *remain = [GKDYTools convertTimeSecond:previewTime];
        self.cooldownPreviewLabel.text = [NSString stringWithFormat:YZMsg(@"short_video_preview"), remain];
    }
}

- (void)setInfoModel:(HomeRecommendSkit *)infoModel {
    [self.autoNextSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:SkitPlayerManagerAutoNextIfNeed]];
    self.nameLabel.text = infoModel.name;
    [self.starButton star:infoModel.is_favorite];
//    self.starButton.selected = infoModel.is_favorite;
}

- (void)hiddenFullScreen:(BOOL)isHidden {
    [self updateFullScreenPosition];
    self.fullscreenBtn.hidden = isHidden;
}

- (void)updateCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime {
    self.currentTimeLabel.text = [GKDYTools convertTimeSecond:currentTime];
    self.totalTimeLabel.text = [GKDYTools convertTimeSecond:totalTime];
    [self.slider updateCurrentTime:currentTime totalTime:totalTime];
}

- (void)changeAutoNext:(BOOL)open {
    [self.autoNextSwitch setOn:open];
}

#pragma mark - UI
- (void)setupViews {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPressGesture];
    
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.contentLabel];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.voiceButton];
    [self.bottomView addSubview:self.starButton];
//    [self.bottomView addSubview:self.chatButton];
//    [self.bottomView addSubview:self.chatNumberLabel];
    [self.bottomView addSubview:self.skitButton];
    [self.bottomView addSubview:self.skitLabel];
    [self.bottomView addSubview:self.autoNextSwitchView];
    [self.bottomView addSubview:self.tagStackView];
    [self addSubview:self.retryButton];
    [self addSubview:self.slider];
    [self addSubview:self.playImageView];
    [self addSubview:self.fullscreenBtn];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.speedView];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];

    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.slider.sliderView);
    }];

    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.slider.sliderView);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(4);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(-4);
//        make.bottom.equalTo(self).offset(-VK_BOTTOM_H - 5);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-5);
        make.height.mas_equalTo(60);
    }];

    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(RatioBaseWidth390(44)));
        make.center.equalTo(self);
    }];
    
    [self.skitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.skitButton);
//        make.bottom.equalTo(self.slider.mas_top).offset(-15);
        make.bottom.equalTo(self.slider.mas_top).offset(RatioBaseWidth390(-150));
    }];
    
    [self.skitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-6);
        make.bottom.equalTo(self.skitLabel.mas_top).offset(0);
        make.width.height.mas_equalTo(44);
    }];

    // 右
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-6);
        make.bottom.equalTo(self.skitButton.mas_top).offset(-15);
        make.width.height.mas_equalTo(44);
    }];

//    [self.chatNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.voiceButton);
//        make.bottom.equalTo(self.voiceButton.mas_top).offset(-20);
//    }];
//
//    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.voiceButton);
//        make.bottom.equalTo(self.chatNumberLabel.mas_top);
//        make.width.height.mas_equalTo(44);
//    }];

    [self.starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.voiceButton.mas_top).offset(-25);
        make.width.height.mas_equalTo(30);
    }];

    self.autoNextSwitchView.hidden = YES;
    [self.autoNextSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.starButton.mas_top).offset(-20);;
        make.width.height.mas_equalTo(44);
        make.top.equalTo(self.bottomView.mas_top).offset(20);
    }];

    // 底
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel);
        make.right.equalTo(self.voiceButton.mas_left).offset(-10);
        make.bottom.equalTo(self.bottomView).offset(-20);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel);
        make.right.equalTo(self.voiceButton.mas_left).offset(-10);
        make.bottom.equalTo(self.contentLabel.mas_top).offset(-0);
    }];

    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(14);
        make.bottom.equalTo(self.nameLabel.mas_top).offset(-5);
    }];

    [self.speedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(120);
        make.centerX.equalTo(self);
        make.height.equalTo(@44);
    }];

    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.center.equalTo(self);
    }];

    [self insertSubview:self.blurEffectView belowSubview:self.bottomView];

    [self insertSubview:self.payCoverView belowSubview:self.bottomView];
    [self.payCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];


    [self updateVoiceStatus];
}

- (void)updateFullScreenPosition {
    UIView *playerView = self.player.currentPlayerManager.view.playerView;
    if (playerView == nil ||
        playerView.superview == nil) {
        return;
    }

    [self.fullscreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(playerView.mas_bottom).offset(20).priorityLow();
        make.bottom.lessThanOrEqualTo(self.nameLabel.mas_top).offset(-4).priorityHigh();
        make.height.mas_equalTo(40);
    }];
}

- (void)sliderDragging:(BOOL)isDragging {
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.alpha = !isDragging;
    }];
}

- (void)handleSingleTapped {
    if (!self.payCoverView.isHidden) {
        return;
    }

    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapPlay:)]) {
            [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapPlay:NO];
        }
        [manager pause];
        [self.slider showLargeSlider];
        self.playImageView.hidden = NO;
        self.playImageView.transform = CGAffineTransformMakeScale(3, 3);
        [UIView animateWithDuration:0.15 animations:^{
            self.playImageView.alpha = 0.7;
            self.playImageView.transform = CGAffineTransformIdentity;
        }];
    }else {
        if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapPlay:)]) {
            [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapPlay:YES];
        }
        [manager play];
        [self.slider showSmallSlider];
        [UIView animateWithDuration:0.15 animations:^{
            self.playImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.playImageView.hidden = YES;
        }];
    }
}

- (void)updateVoiceStatus {
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.player.muted) {
            [strongSelf.voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOffIcon"] forState:UIControlStateNormal];
        } else {
            [strongSelf.voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOnIcon"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark - Action
- (void)tapChat {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapChat)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapChat];
    }
}

- (void)tapVoice {
    BOOL isMuted = self.player.isMuted;
    [self.player setMuted:!self.player.isMuted];
    // 防止原本是靜音，setMuted 打開還是會沒聲音
    if (isMuted && self.player.volume == 0) {
        [self.player setVolume:0.5];
    }
    [self updateVoiceStatus];
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapVoice:)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapVoice: !isMuted];
    }
}

- (void)tapStar:(BOOL)isStar {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapStar:)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapStar:isStar];
    }
}

- (void)tapFullscreen {
    if (self.model.isNeedPay) {
        [self.payCoverView clickLockAction];
        return;
    }

    /// VIP才能全屏
    if ([Config getVip_type].integerValue <= 0) {
        VipPayAlertView *view = [VipPayAlertView new];
        [view showFromBottom];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapFullScreen)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapFullScreen];
    }
}

- (void)autoNext {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapAutoNext:)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapAutoNext:self.autoNextSwitch.isOn];
    }
}

- (void)tapSkit:(BOOL)isStar {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapSkit)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapSkit];
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
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        [self.player.currentPlayerManager setRate:1.0];
        self.speedView.hidden = YES;
    }
}

- (void)retryLoadVideo {
    self.retryButton.hidden = YES;
    [self hiddenLoading:NO];
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoPortraitControlViewDelegateForTapRetryLoadVideo)]) {
        [self.delegate skitPlayerVideoPortraitControlViewDelegateForTapRetryLoadVideo];
    }
}

- (void)showBuyView {
    [self.payCoverView clickLockAction];
}

#pragma mark - ZFPlayerMediaControl
- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self handleSingleTapped];
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self handleDoubleTapped:gestureControl.doubleTap];
}

- (void)handleDoubleTapped:(UITapGestureRecognizer *)gesture {

}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.currentTimeLabel.text = [GKDYTools convertTimeSecond:currentTime];
    self.totalTimeLabel.text = [GKDYTools convertTimeSecond:totalTime];

    CGFloat previewTime = self.model.preview_duration;
    CGFloat remainTime = previewTime - currentTime;
    if (remainTime <= 0) {
        self.cooldownPreviewLabel.text = YZMsg(@"short_video_preview_end");
    } else {
        NSString *remain = [GKDYTools convertTimeSecond:remainTime];
        self.cooldownPreviewLabel.text = [NSString stringWithFormat:YZMsg(@"short_video_preview"), remain];
    }

}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer playStateChanged:(ZFPlayerPlaybackState)state {
    NSLog(@">>>>ZFPlayerPlaybackState %ld", state);
    switch (state) {
        case ZFPlayerPlayStateUnknown:
            break;
        case ZFPlayerPlayStatePlaying:
            self.playImageView.hidden = YES;
            break;
        case ZFPlayerPlayStatePaused:
//            self.playImageView.hidden = NO;
            break;
        case ZFPlayerPlayStatePlayFailed:
            break;
        case ZFPlayerPlayStatePlayStopped:
//            self.playImageView.hidden = NO;
            break;
        default:
            break;
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

#pragma mark - lazy
- (UIImageView *)playImageView {
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc] init];
        _playImageView.image = [ImageBundle imagewithBundleName:@"icon_play@3x"];
        _playImageView.alpha = 0.7;
        _playImageView.hidden = YES;
    }
    return _playImageView;
}

- (TouchSuperView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TouchSuperView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.numberOfLines = 0;
        _nameLabel.layer.shadowOpacity = 0.5;
        _nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _nameLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 2;
        _contentLabel.layer.shadowOpacity = 0.5;
        _contentLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _contentLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _contentLabel;
}

//- (UIButton *)chatButton {
//    if (!_chatButton) {
//        _chatButton = [[UIButton alloc] init];
//        _chatButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
//        [_chatButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoChatIcon"] forState:UIControlStateNormal];
//        [_chatButton addTarget:self action:@selector(tapChat) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _chatButton;
//}
//
//- (UILabel *)chatNumberLabel {
//    if (!_chatNumberLabel) {
//        _chatNumberLabel = [[UILabel alloc] init];
//        _chatNumberLabel.textColor = [UIColor whiteColor];
//        _chatNumberLabel.font = [UIFont systemFontOfSize:14];
//    }
//    return _chatNumberLabel;
//}

- (UIButton *)skitButton {
    if (!_skitButton) {
        _skitButton = [[UIButton alloc] init];
        _skitButton.imageEdgeInsets = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
        [_skitButton setImage:[ImageBundle imagewithBundleName:@"ic_skitepisode"] forState:UIControlStateNormal];
        [_skitButton addTarget:self action:@selector(tapSkit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skitButton;
}

- (UILabel *)skitLabel {
    if (!_skitLabel) {
        _skitLabel = [[UILabel alloc] init];
        _skitLabel.textColor = [UIColor whiteColor];
        _skitLabel.font = [UIFont systemFontOfSize:12];
        _skitLabel.text = YZMsg(@"选集");
    }
    return _skitLabel;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] init];
        _voiceButton.imageEdgeInsets = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
        if (self.player.isMuted) {
            [_voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOffIcon"] forState:UIControlStateNormal];
        } else {
            [_voiceButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoVoiceOnIcon"] forState:UIControlStateNormal];
        }

        [_voiceButton addTarget:self action:@selector(tapVoice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (StarAnimationView *)starButton {
    if (!_starButton) {
        _starButton = [[StarAnimationView alloc] init];
        WeakSelf
        _starButton.tapStarblock = ^(BOOL isStar) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf tapStar:isStar];
        };
    }
    return _starButton;
}

- (UIView *)fullscreenBtn {
    if (!_fullScreenBtn) {
        UIView *control = [[UIView alloc] init];
        control.userInteractionEnabled = YES;
        control.backgroundColor = RGB_COLOR(@"#191717", 1);
        control.layer.cornerRadius = 20;
        control.layer.masksToBounds = YES;
        control.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        control.layer.borderWidth = 0.5;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFullscreen)];
        [control addGestureRecognizer:tap];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.image = [ImageBundle imagewithBundleName:@"fullScreenChange"];
        [control addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(control).offset(15);
            make.centerY.equalTo(control);
            make.size.equalTo(@20);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        label.text = YZMsg(@"DramaPortraitVideoControlView_fullScreen_title");
        [control addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(control);
            make.left.equalTo(icon.mas_right).offset(4);
            make.right.equalTo(control).offset(-15);
        }];

        control.hidden = YES;
        _fullScreenBtn = control;
    }
    return _fullScreenBtn;
}

- (GKDYVideoSlider *)slider {
    if (!_slider) {
        _slider = [[GKDYVideoSlider alloc] init];
        _slider.sliderView.minimumTrackTintColor = RGB_COLOR(@"#9F57DF", 1);
        [_slider.sliderView setSliderBackgroundColor:RGB_COLOR(@"#9F57DF", 1)];
        _slider.smallSliderBtnHeight = 5.0;
        _slider.smallSliderHeight = 3.0;

        WeakSelf
        _slider.slideBlock = ^(BOOL isDragging) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf sliderDragging:isDragging];
        };

        _slider.seekCompletionTime = ^(float time) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.player.currentPlayerManager.playState != ZFPlayerPlayStatePaused) {
                strongSelf.playImageView.hidden = YES;
            }

            if (strongSelf.model.isNeedPay) {
                int previewDuration = strongSelf.model.preview_duration <= 0 ? 20 : strongSelf.model.preview_duration;
                strongSelf.payCoverView.hidden = !(time >= previewDuration);
            }
        };

    }
    return _slider;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:10];
        [_currentTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:10];
        [_totalTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _totalTimeLabel;
}

- (UISwitch *)autoNextSwitch {
    if (!_autoNextSwitch) {
        _autoNextSwitch = [[UISwitch alloc] init];
        [_autoNextSwitch addTarget:self action:@selector(autoNext) forControlEvents:UIControlEventValueChanged];
    }
    return _autoNextSwitch;
}

- (UIView *)autoNextSwitchView {
    if (!_autoNextSwitchView) {
        _autoNextSwitchView = [[UIView alloc] init];

        [_autoNextSwitchView addSubview:self.autoNextSwitch];
        [self.autoNextSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_autoNextSwitchView);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Auto Next";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.minimumScaleFactor = 0.5;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [_autoNextSwitchView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.autoNextSwitch.mas_bottom).offset(5);
            make.left.right.bottom.equalTo(_autoNextSwitchView);
        }];
    }
    return _autoNextSwitchView;
}

- (DouYinLoading *)douYinLoading {
    if (!_douYinLoading) {
        if (self.width != _window_width) {
            return nil;
        }
        _douYinLoading = [DouYinLoading showInView:self];
        _douYinLoading.hidden = YES;
        _douYinLoading.userInteractionEnabled = NO;
    }
    return _douYinLoading;
}

- (SpeedUpTipView *)speedView {
    if (!_speedView) {
        _speedView = [[SpeedUpTipView alloc] init];
        _speedView.hidden = YES;
    }
    return _speedView;
}

- (VideoPayCoverView *)payCoverView {
    if (!_payCoverView) {
        _payCoverView = [VideoPayCoverView new];
        _payCoverView.hidden = YES;
        _payCoverView.blurEffectView.hidden = YES;
        _payCoverView.videoType = 1;
    }
    return _payCoverView;
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

- (UIVisualEffectView *)blurEffectView {
    if (!_blurEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurEffectView.frame = CGRectMake(0, 0, _window_width, _window_height);
        _blurEffectView.alpha = 1.0;
    }
    return _blurEffectView;
}

- (UIView *)cooldownAndPayButton {
    if (!_cooldownAndPayButton) {
        _cooldownAndPayButton = [UIView new];
        _cooldownAndPayButton.backgroundColor = RGB_COLOR(@"#000000", 0.2);
        _cooldownAndPayButton.layer.cornerRadius = 4;
        _cooldownAndPayButton.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBuyView)];
        [_cooldownAndPayButton addGestureRecognizer:tap];

        CGFloat offset = 4;

//        UIView *memberView = [UIView new];
//        memberView.backgroundColor = RGB_COLOR(@"#EBE4C0", 1);
//        UILabel *memberLabel = [UILabel new];
//        memberLabel.text = @"專屬會員";
//        memberLabel.font = [UIFont systemFontOfSize:14];
//        [memberView addSubview:memberLabel];
//        [memberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.equalTo(memberView);
//            make.left.right.equalTo(memberView).inset(offset);
//        }];

        _cooldownPreviewLabel = [UILabel new];
        _cooldownPreviewLabel.textColor = [UIColor whiteColor];
        _cooldownPreviewLabel.font = [UIFont boldSystemFontOfSize:12];
        _cooldownPreviewLabel.text = [NSString stringWithFormat:YZMsg(@"short_video_preview"), @""];

        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor whiteColor];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@1);
            make.height.equalTo(@8);
        }];

        UILabel *buyLabel = [UILabel new];
        buyLabel.text = YZMsg(@"short_video_buy");
        buyLabel.textColor = RGB_COLOR(@"#EBE4C0", 1);
        buyLabel.font = [UIFont boldSystemFontOfSize:12];

        UIImageView *buyImgView = [UIImageView new];
        buyImgView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *image = [[ImageBundle imagewithBundleName:@"HotHeaderRightArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        buyImgView.image = image;
        buyImgView.tintColor = RGB_COLOR(@"#EBE4C0", 1);;

        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[_cooldownPreviewLabel, lineView, buyLabel, buyImgView]];
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.spacing = offset;
        [_cooldownAndPayButton addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_cooldownAndPayButton);
            make.top.bottom.equalTo(_cooldownAndPayButton).inset(2);
            make.left.equalTo(_cooldownAndPayButton).offset(offset);
        }];

        [buyImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(12);
            make.right.equalTo(stackView).offset(offset);
        }];
    }
    return _cooldownAndPayButton;
}

- (UIButton *)vipTagButton {
    if (!_vipTagButton) {
        _vipTagButton = [UIView vk_button:@"VIP" image:nil font:vkFontMedium(10) color:vkColorHex(0x664208)];
        [_vipTagButton setBackgroundImage:[ImageBundle imagewithBundleName:@"video_tag_vip"] forState:UIControlStateNormal];
        _vipTagButton.userInteractionEnabled = NO;
    }
    return _vipTagButton;
}

- (UIButton *)payTagButton {
    if (!_payTagButton) {
        _payTagButton = [UIView vk_button:YZMsg(@"movie_pay") image:nil font:vkFontMedium(10) color:vkColorHex(0xFFFFFF)];
        [_payTagButton setBackgroundImage:[ImageBundle imagewithBundleName:@"video_tag_pay"] forState:UIControlStateNormal];
        _payTagButton.userInteractionEnabled = NO;
    }
    return _payTagButton;
}

- (UIStackView *)tagStackView {
    if (!_tagStackView) {
        _tagStackView = [UIStackView new];
        _tagStackView.axis = UILayoutConstraintAxisHorizontal;
        _tagStackView.spacing = 2;
        _tagStackView.alignment = UIStackViewAlignmentCenter;

        [_tagStackView addArrangedSubview:self.vipTagButton];
        [_tagStackView addArrangedSubview:self.payTagButton];
        [_tagStackView addArrangedSubview:self.cooldownAndPayButton];

        [self.vipTagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(28);
        }];

        [self.payTagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(28);
        }];
    }
    return _tagStackView;
}

@end
