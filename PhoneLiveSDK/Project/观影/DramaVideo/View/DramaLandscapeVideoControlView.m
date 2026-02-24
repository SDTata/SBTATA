//
//  DramaLandscapeVideoControlView.m
//  DramaTest
//
//  Created by s5346 on 2024/5/14.
//

#import "DramaLandscapeVideoControlView.h"
#import "GradientView.h"
#import "DouYinLoading.h"

@interface DramaLandscapeVideoControlView () {
    BOOL isShowLoading;
}

@property (nonatomic, strong) GradientView *topContainerView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) GradientView *rightContainerView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *starButton;
@property (nonatomic, strong) UIButton *ticketButton;
@property (nonatomic, strong) UILabel *ticketNumberLabel;

@property (nonatomic, strong) GradientView *bottomContainerView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIView *autoNextSwitchView;
@property (nonatomic, strong) UISwitch *autoNextSwitch;
@property (nonatomic, strong) DouYinLoading *douYinLoading;

@end

@implementation DramaLandscapeVideoControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setModel:(DramaVideoInfoModel *)model {
    _model = model;
    self.contentLabel.text = [NSString stringWithFormat:@"%@ %@", model.name, model.desc];
    [self updateVoiceStatus];
}

- (void)setInfoModel:(DramaInfoModel *)infoModel {
    self.nameLabel.text = infoModel.name;
    self.ticketNumberLabel.text = minnum(infoModel.skit_ticket_count);
    self.starButton.selected = infoModel.is_favorite;
}

- (void)changeAutoNext:(BOOL)open {
    [self.autoNextSwitch setOn:open];
}

#pragma mark - UI
- (void)setupViews {
    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.backButton];
    [self.topContainerView addSubview:self.contentLabel];
    [self.topContainerView addSubview:self.nameLabel];

    [self addSubview:self.rightContainerView];
    [self.rightContainerView addSubview:self.voiceButton];
    [self.rightContainerView addSubview:self.starButton];
    [self.rightContainerView addSubview:self.ticketButton];
    [self.rightContainerView addSubview:self.ticketNumberLabel];
    [self.rightContainerView addSubview:self.autoNextSwitchView];

    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView addSubview:self.slider];
    [self.bottomContainerView addSubview:self.playBtn];
    [self.bottomContainerView addSubview:self.timeLabel];

    // top
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(5);
        make.size.equalTo(@44);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right).offset(5);
        make.right.equalTo(self).offset(-20);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentLabel);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(5);
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
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
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
        make.bottom.equalTo(self.ticketButton.mas_top).offset(-15);
        make.width.height.mas_equalTo(44);
    }];

    // bottom
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self);
        make.right.equalTo(self.rightContainerView.mas_left).offset(-10);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft).offset(10);
        make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight).offset(-10);
        make.bottom.equalTo(self.playBtn.mas_top).offset(-10);
        make.height.mas_equalTo(15);
        make.top.equalTo(self.bottomContainerView).offset(15);
    }];

    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider);
        make.bottom.equalTo(self.bottomContainerView).offset(-10);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.left.equalTo(self.playBtn.mas_right).offset(10);
    }];

    [self updateVoiceStatus];
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
    self.topContainerView.hidden = !self.topContainerView.isHidden;
    self.rightContainerView.hidden = self.topContainerView.isHidden;
    self.bottomContainerView.hidden = self.topContainerView.isHidden;
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
    if ([self.delegate respondsToSelector:@selector(dramaLandscapeVideoControlViewDelegateForTapBack)]) {
        [self.delegate dramaLandscapeVideoControlViewDelegateForTapBack];
    }
}

- (void)tapTicket {
    if ([self.delegate respondsToSelector:@selector(dramaLandscapeVideoControlViewDelegateForTapTicket)]) {
        [self.delegate dramaLandscapeVideoControlViewDelegateForTapTicket];
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
    if ([self.delegate respondsToSelector:@selector(dramaLandscapeVideoControlViewDelegateForTapStar:)]) {
        [self.delegate dramaLandscapeVideoControlViewDelegateForTapStar:!self.starButton.isSelected];
    }
}

- (void)playAction {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
    }else {
        [manager play];
    }
    self.playBtn.selected = manager.isPlaying;
}

- (void)autoNext {
    if ([self.delegate respondsToSelector:@selector(dramaLandscapeVideoControlViewDelegateForTapAutoNext:)]) {
        [self.delegate dramaLandscapeVideoControlViewDelegateForTapAutoNext:self.autoNextSwitch.isOn];
    }
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

        //        WeakSelf
        //        _slider.slideBlock = ^(BOOL isDragging) {
        //            STRONGSELF
        //            [strongSelf sliderDragging:isDragging];
        //        };
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
