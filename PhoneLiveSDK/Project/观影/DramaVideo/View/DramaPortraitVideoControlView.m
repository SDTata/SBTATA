//
//  DramaPortraitVideoControlView.m
//  DramaTest
//
//  Created by s5346 on 2024/5/1.
//

#import "DramaPortraitVideoControlView.h"
#import "GKDYTools.h"
#import "DramaPlayerManager.h"
#import "DouYinLoading.h"

@interface DramaPortraitVideoControlView () {
    BOOL isShowLoading;
}
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *starButton;
@property (nonatomic, strong) UIButton *ticketButton;
@property (nonatomic, strong) UILabel *ticketNumberLabel;
@property (nonatomic, strong) UIView *fullScreenBtn;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIView *payButton;
@property (nonatomic, strong) UIView *autoNextSwitchView;
@property (nonatomic, strong) UISwitch *autoNextSwitch;
@property (nonatomic, strong) DouYinLoading *douYinLoading;

@end

@implementation DramaPortraitVideoControlView

@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)hiddenPlayButton:(BOOL)isHidden {
    self.playImageView.hidden = isHidden;
}

- (void)setModel:(DramaVideoInfoModel *)model {
    _model = model;
    self.contentLabel.text = [NSString stringWithFormat:@"%@ %@", model.name, model.desc];
    self.payButton.hidden = !model.isNeedPay;
    [self updateVoiceStatus];
}

- (void)setInfoModel:(DramaInfoModel *)infoModel {
    [self.autoNextSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:DramaPlayerManagerAutoNextIfNeed]];
    self.nameLabel.text = infoModel.name;
    self.ticketNumberLabel.text = minnum(infoModel.skit_ticket_count);
    self.starButton.selected = infoModel.is_favorite;
}

- (void)hiddenFullScreen:(BOOL)isHidden {
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
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.contentLabel];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.voiceButton];
    [self.bottomView addSubview:self.starButton];
    [self.bottomView addSubview:self.ticketButton];
    [self.bottomView addSubview:self.ticketNumberLabel];
    [self.bottomView addSubview:self.autoNextSwitchView];
    [self addSubview:self.slider];
    [self addSubview:self.playImageView];
    [self addSubview:self.fullscreenBtn];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.payButton];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
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
        make.bottom.equalTo(self).offset(-5);
        make.height.mas_equalTo(20);
    }];

    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.center.equalTo(self);
    }];

    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-6);
        make.bottom.equalTo(self.slider.mas_top).offset(-10);
        make.width.height.mas_equalTo(44);
    }];

    [self.starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.voiceButton.mas_top).offset(-20);
        make.width.height.mas_equalTo(44);
    }];

    [self.ticketNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.starButton);
        make.bottom.equalTo(self.starButton.mas_top).offset(-15);
    }];

    [self.ticketButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ticketNumberLabel);
        make.bottom.equalTo(self.ticketNumberLabel.mas_top);
        make.width.height.mas_equalTo(44);
    }];

    [self.autoNextSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ticketButton);
        make.bottom.equalTo(self.ticketButton.mas_top).offset(-15);;
        make.width.height.mas_equalTo(44);
        make.top.equalTo(self.bottomView.mas_top).offset(20);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel);
        make.right.equalTo(self.voiceButton.mas_left).offset(-10);
        make.bottom.equalTo(self.slider.mas_top).offset(-10);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel);
        make.right.equalTo(self.voiceButton.mas_left).offset(-10);
        make.bottom.equalTo(self.nameLabel.mas_top).offset(-10);
    }];

    [self.fullscreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.slider.mas_top).offset(-130);
        make.height.mas_equalTo(40);
    }];

    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];

    [self updateVoiceStatus];
}

- (void)sliderDragging:(BOOL)isDragging {
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.alpha = !isDragging;
    }];
}

- (void)handleSingleTapped {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
        [self.slider showLargeSlider];
        self.playImageView.hidden = NO;
        self.playImageView.transform = CGAffineTransformMakeScale(3, 3);
        [UIView animateWithDuration:0.15 animations:^{
            self.playImageView.alpha = 0.7;
            self.playImageView.transform = CGAffineTransformIdentity;
        }];
    }else {
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
        if (strongSelf.player.muted) {
            [strongSelf.voiceButton setImage:[ImageBundle imagewithBundleName:@"sygb"] forState:UIControlStateNormal];
        } else {
            [strongSelf.voiceButton setImage:[ImageBundle imagewithBundleName:@"sykq"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark - Action
- (void)tapTicket {
    if ([self.delegate respondsToSelector:@selector(dramaPortraitVideoControlViewDelegateForTapTicket)]) {
        [self.delegate dramaPortraitVideoControlViewDelegateForTapTicket];
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

- (void)tapStar {
    if ([self.delegate respondsToSelector:@selector(dramaPortraitVideoControlViewDelegateForTapStar:)]) {
        [self.delegate dramaPortraitVideoControlViewDelegateForTapStar:!self.starButton.isSelected];
    }
}

- (void)tapFullscreen {
    if ([self.delegate respondsToSelector:@selector(dramaPortraitVideoControlViewDelegateForTapFullScreen)]) {
        [self.delegate dramaPortraitVideoControlViewDelegateForTapFullScreen];
    }
}

- (void)tapPay {
    if ([self.delegate respondsToSelector:@selector(dramaPortraitVideoControlViewDelegateForTapPay)]) {
        [self.delegate dramaPortraitVideoControlViewDelegateForTapPay];
    }
}

- (void)autoNext {
    if ([self.delegate respondsToSelector:@selector(dramaPortraitVideoControlViewDelegateForTapAutoNext:)]) {
        [self.delegate dramaPortraitVideoControlViewDelegateForTapAutoNext:self.autoNextSwitch.isOn];
    }
}

#pragma mark - ZFPlayerMediaControl
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
            self.playImageView.hidden = NO;
            break;
        case ZFPlayerPlayStatePlayFailed:
            break;
        case ZFPlayerPlayStatePlayStopped:
            self.playImageView.hidden = NO;
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
    if (!isShowLoading) {
        self.douYinLoading.hidden = YES;
        [self.slider hideLoading];
        return;
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
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

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIButton *)ticketButton {
    if (!_ticketButton) {
        _ticketButton = [[UIButton alloc] init];
        _ticketButton.imageEdgeInsets = UIEdgeInsetsMake(9, 7, 9, 7);
        [_ticketButton setImage:[ImageBundle imagewithBundleName:@"quan"] forState:UIControlStateNormal];
        [_ticketButton addTarget:self action:@selector(tapTicket) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ticketButton;
}

- (UILabel *)ticketNumberLabel {
    if (!_ticketNumberLabel) {
        _ticketNumberLabel = [[UILabel alloc] init];
        _ticketNumberLabel.textColor = [UIColor whiteColor];
        _ticketNumberLabel.font = [UIFont systemFontOfSize:14];
    }
    return _ticketNumberLabel;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc] init];
        _voiceButton.imageEdgeInsets = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
        if (self.player.isMuted) {
            [_voiceButton setImage:[ImageBundle imagewithBundleName:@"sygb"] forState:UIControlStateNormal];
        } else {
            [_voiceButton setImage:[ImageBundle imagewithBundleName:@"sykq"] forState:UIControlStateNormal];
        }

        [_voiceButton addTarget:self action:@selector(tapVoice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIButton *)starButton {
    if (!_starButton) {
        _starButton = [[UIButton alloc] init];
        _starButton.imageEdgeInsets = UIEdgeInsetsMake(6.5, 6, 6.5, 6);
        [_starButton setImage:[ImageBundle imagewithBundleName:@"sc-2"] forState:UIControlStateNormal];
        [_starButton setImage:[ImageBundle imagewithBundleName:@"sc-3"] forState:UIControlStateSelected];
        [_starButton addTarget:self action:@selector(tapStar) forControlEvents:UIControlEventTouchUpInside];
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

        WeakSelf
        _slider.slideBlock = ^(BOOL isDragging) {
            STRONGSELF
            [strongSelf sliderDragging:isDragging];
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

- (UIView *)payButton {
    if (!_payButton) {
        UIView *control = [[UIView alloc] init];
        control.userInteractionEnabled = YES;
        control.backgroundColor = RGB_COLOR(@"#191717", 1);
        control.layer.cornerRadius = 20;
        control.layer.masksToBounds = YES;
        control.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        control.layer.borderWidth = 0.5;
        [control mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@40);
        }];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPay)];
        [control addGestureRecognizer:tap];

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        label.text = YZMsg(@"DramaPortraitVideoControlView_unlock_pay");
        [control addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(control);
            make.left.right.equalTo(control).inset(15);
        }];

        control.hidden = YES;
        _payButton = control;
    }
    return _payButton;
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

@end
