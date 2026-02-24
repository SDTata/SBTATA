//
//  SkitPlayerVideoLandscapeControlView.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPlayerVideoLandscapeControlView.h"
#import "GradientView.h"
#import "DouYinLoading.h"
#import "StarAnimationView.h"
#import "SpeedUpTipView.h"

@interface SkitPlayerVideoLandscapeControlView () {
    BOOL isShowLoading;
}

@property (nonatomic, strong) GradientView *topContainerView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) GradientView *rightContainerView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) StarAnimationView *starButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UILabel *chatNumberLabel;

@property (nonatomic, strong) GradientView *bottomContainerView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIView *autoNextSwitchView;
@property (nonatomic, strong) UISwitch *autoNextSwitch;
@property (nonatomic, strong) DouYinLoading *douYinLoading;

@property (nonatomic, strong) SpeedUpTipView *speedView;
// 重試按鈕
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation SkitPlayerVideoLandscapeControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self addGestureRecognizer:singleTapGesture];
    }
    return self;
}

- (void)hiddenRetryButton:(BOOL)isHidden {
    self.retryButton.hidden = isHidden;
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

- (void)setModel:(SkitVideoInfoModel *)model {
    _model = model;
    self.contentLabel.text = [NSString stringWithFormat:@"%@ | %@", model.name, model.desc];
//    self.chatNumberLabel.text = @"1234";
    self.playBtn.selected = self.player.currentPlayerManager.isPlaying;
    self.retryButton.hidden = YES;

    [self updateVoiceStatus];
}

- (void)setInfoModel:(HomeRecommendSkit *)infoModel {
    self.nameLabel.text = infoModel.name;
    [self.starButton star:infoModel.is_favorite];
//    self.starButton.selected = infoModel.is_favorite;
}

- (void)changeAutoNext:(BOOL)open {
    [self.autoNextSwitch setOn:open];
}

#pragma mark - UI
- (void)setupViews {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPressGesture];

    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.backButton];
    [self.topContainerView addSubview:self.contentLabel];
    [self.topContainerView addSubview:self.nameLabel];

    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView addSubview:self.slider];
    [self.bottomContainerView addSubview:self.playBtn];
    [self.bottomContainerView addSubview:self.timeLabel];

    [self addSubview:self.rightContainerView];
    [self.rightContainerView addSubview:self.voiceButton];
    [self.rightContainerView addSubview:self.chatButton];
    [self.rightContainerView addSubview:self.chatNumberLabel];
    [self.rightContainerView addSubview:self.starButton];
    [self.rightContainerView addSubview:self.autoNextSwitchView];

    [self addSubview:self.speedView];
    [self addSubview:self.retryButton];


    // top
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(5);
        make.size.equalTo(@44);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right).offset(5);
        make.right.equalTo(self).offset(-20);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(5);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self.topContainerView).offset(-10);
    }];

    // right
    [self.rightContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.equalTo(@64);
    }];

    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-14);
        make.bottom.equalTo(self.rightContainerView).offset(-3);
        make.width.height.mas_equalTo(44);
    }];

    UIView *rightSpaceToBottomView = [UIView new];
    rightSpaceToBottomView.backgroundColor = UIColor.redColor;
    [self.rightContainerView insertSubview:rightSpaceToBottomView belowSubview:self.voiceButton];
    [rightSpaceToBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(self.rightContainerView);
        make.height.equalTo(self.rightContainerView).multipliedBy(0.34);
    }];

    [self.chatNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(rightSpaceToBottomView.mas_top);
    }];

    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.chatNumberLabel.mas_top);
        make.width.height.mas_equalTo(44);
    }];

    [self.starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.chatButton.mas_top).offset(-25);
        make.width.height.mas_equalTo(30);
    }];

    self.autoNextSwitchView.hidden = YES;
    [self.autoNextSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.chatButton);
        make.bottom.equalTo(self.chatButton.mas_top).offset(-20);
        make.width.height.mas_equalTo(44);
    }];

    // bottom
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerView.mas_left).offset(10);
        make.right.equalTo(self.rightContainerView.mas_left).offset(-10);
        make.bottom.equalTo(self.playBtn.mas_top).offset(-5);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.bottomContainerView).offset(15);
    }];

    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider).offset(15);
        make.bottom.equalTo(self.bottomContainerView).offset(-5);
        make.size.equalTo(@40);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.left.equalTo(self.playBtn.mas_right).offset(10);
    }];

    [self.speedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContainerView.mas_bottom).offset(10);
        make.centerX.equalTo(self);
        make.height.equalTo(@44);
    }];

    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.center.equalTo(self);
    }];

    [self updateVoiceStatus];
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

#pragma mark - ZFPlayerMediaControl
- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;

    self.playBtn.selected = player.currentPlayerManager.isPlaying;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer {
    if (videoPlayer.isFullScreen) {
    }
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self hiddenInfoView];
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [GKDYTools convertTimeSecond:currentTime], [GKDYTools convertTimeSecond:totalTime]];
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
    if (!isShowLoading) {
        self.douYinLoading.hidden = YES;
        [self.slider hideLoading];
        return;
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.douYinLoading.hidden = !strongSelf->isShowLoading;
        if (strongSelf->isShowLoading) {
            [strongSelf.slider showLoading];
        } else {
            [strongSelf.slider hideLoading];
        }
    });
}

#pragma mark - Action
- (void)back {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapBack)]) {
        [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapBack];
    }
}

- (void)tapChat {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapChat)]) {
        [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapChat];
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
}

- (void)tapStar:(BOOL)isStar {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapStar:)]) {
        [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapStar:isStar];
    }
}

- (void)playAction {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapPlay:)]) {
            [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapPlay:NO];
        }
        [manager pause];
    }else {
        if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapPlay:)]) {
            [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapPlay:YES];
        }
        [manager play];
    }
    self.playBtn.selected = manager.isPlaying;
}

- (void)autoNext {
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapAutoNext:)]) {
        [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapAutoNext:self.autoNextSwitch.isOn];
    }
}

- (void)hiddenInfoView {
    self.topContainerView.hidden = !self.topContainerView.isHidden;
    self.rightContainerView.hidden = self.topContainerView.isHidden;
    self.bottomContainerView.hidden = self.topContainerView.isHidden;
}

// 長按加速
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (!self.player.currentPlayerManager.isPlaying) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.player.currentPlayerManager setRate:2.0];
        self.speedView.hidden = NO;
        if (!self.topContainerView.isHidden) {
            [self hiddenInfoView];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        [self.player.currentPlayerManager setRate:1.0];
        self.speedView.hidden = YES;
    }
}

- (void)retryLoadVideo {
    self.retryButton.hidden = YES;
    [self hiddenLoading:NO];
    if ([self.delegate respondsToSelector:@selector(skitPlayerVideoLandscapeControlViewDelegateForTapRetryLoadVideo)]) {
        [self.delegate skitPlayerVideoLandscapeControlViewDelegateForTapRetryLoadVideo];
    }
}

- (void)handleGesture:(UITapGestureRecognizer *)sender {
    if (self.topContainerView.isHidden) {
        [self hiddenInfoView];
        return;
    }

    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenInfoView) object: nil];
    if (!manager.isPlaying) {
        [self performSelector:@selector(hiddenInfoView) withObject:nil afterDelay:1.0f];
    }

    [self playAction];
}

#pragma mark - Lazy
// top
- (GradientView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[GradientView alloc] initWithStyle:GradientViewStyleTop];
    }
    return _topContainerView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[ImageBundle imagewithBundleName:@"fh-2"] forState:UIControlStateNormal];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

// right
- (GradientView *)rightContainerView {
    if (!_rightContainerView) {
        _rightContainerView = [[GradientView alloc] initWithStyle:GradientViewStyleRight];
    }
    return _rightContainerView;
}

- (UIButton *)chatButton {
    if (!_chatButton) {
        _chatButton = [[UIButton alloc] init];
        _chatButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [_chatButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoChatIcon"] forState:UIControlStateNormal];
        [_chatButton addTarget:self action:@selector(tapChat) forControlEvents:UIControlEventTouchUpInside];
        _chatButton.hidden = YES;
    }
    return _chatButton;
}

- (UILabel *)chatNumberLabel {
    if (!_chatNumberLabel) {
        _chatNumberLabel = [[UILabel alloc] init];
        _chatNumberLabel.textColor = [UIColor whiteColor];
        _chatNumberLabel.font = [UIFont systemFontOfSize:14];
        _chatNumberLabel.hidden = YES;
    }
    return _chatNumberLabel;
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

// bottom
- (GradientView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[GradientView alloc] initWithStyle:GradientViewStyleBottom];
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
    }
    return _slider;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[ImageBundle imagewithBundleName:@"icon_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[ImageBundle imagewithBundleName:@"icon_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _playBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
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

@end
