//
//  ShortVideoLandscapeControlView.m
//  phonelive2
//
//  Created by s5346 on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoLandscapeControlView.h"
#import "GradientView.h"
#import "DouYinLoading.h"
#import "GKDYTools.h"
#import "ShortVideoFavoriteView.h"
#import "FocusView.h"
#import "SpeedUpTipView.h"
#import <UMCommon/UMCommon.h>

@interface ShortVideoLandscapeControlView () {
    BOOL isShowLoading;
}

@property (nonatomic, strong) GradientView *topContainerView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) GradientView *rightContainerView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) ShortVideoFavoriteView *likeButton;
@property (nonatomic, strong) UILabel *likeNumberLabel;
//@property (nonatomic, strong) UIButton *chatButton;
//@property (nonatomic, strong) UILabel *chatNumberLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) FocusView *addAnchorButton;

@property (nonatomic, strong) GradientView *bottomContainerView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) DouYinLoading *douYinLoading;
// 連擊愛心
@property (nonatomic, assign) NSTimeInterval lastTapTime;
@property (nonatomic, assign) CGPoint lastTapPoint;
@property (nonatomic, assign) BOOL isLoveAnimation;

@property (nonatomic, strong) SpeedUpTipView *speedView;
// 重試按鈕
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation ShortVideoLandscapeControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lastTapTime = 0;
        self.lastTapPoint = CGPointZero;
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self addGestureRecognizer:singleTapGesture];

        [self setupViews];
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

- (void)setModel:(ShortVideoModel *)model {
    _model = model;
    self.contentLabel.text = [NSString stringWithFormat:@"%@ %@", model.user_name, model.title];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.user_avatar]];
    [self.addAnchorButton resetView];
    self.addAnchorButton.hidden = model.is_follow;
    if ([model.uid isEqualToString:[Config getOwnID]]) {
        self.addAnchorButton.hidden = YES;
    }
    self.retryButton.hidden = YES;

    [self.likeButton like:model.is_like];
    self.likeNumberLabel.text = minnum(model.likes_count);

    [self updateVoiceStatus];
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
    [self addSubview:self.speedView];

    [self addSubview:self.rightContainerView];
    [self.rightContainerView addSubview:self.voiceButton];
    [self.rightContainerView addSubview:self.likeButton];
    [self.rightContainerView addSubview:self.likeNumberLabel];
//    [self.rightContainerView addSubview:self.chatButton];
//    [self.rightContainerView addSubview:self.chatNumberLabel];
    [self.rightContainerView addSubview:self.avatarImageView];
    [self.rightContainerView addSubview:self.addAnchorButton];
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

    [self.likeNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(rightSpaceToBottomView.mas_top);
        make.height.equalTo(@14);
    }];

    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.likeNumberLabel.mas_top).offset(2);
        make.width.height.mas_equalTo(44);
    }];

    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.likeButton.mas_top).offset(-29);
    }];

    [self.addAnchorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.centerY.equalTo(self.avatarImageView.mas_bottom);
        make.size.equalTo(@16);
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

- (void)gestureSingleTapped {
    self.topContainerView.hidden = !self.topContainerView.isHidden;
    self.rightContainerView.hidden = self.topContainerView.isHidden;
    self.bottomContainerView.hidden = self.topContainerView.isHidden;
}

- (void)handleGestureForPlay {
    if (self.isLoveAnimation) {
        return;
    }

    if (self.topContainerView.isHidden) {
        return;
    }

    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gestureSingleTapped) object: nil];
    if (!manager.isPlaying) {
        [self performSelector:@selector(gestureSingleTapped) withObject:nil afterDelay:1.0f];
    }

    [self playAction];
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
    if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapBack)]) {
        [self.delegate shortVideoLandscapeControlViewDelegateForTapBack];
    }
}

- (void)tapChat {
    if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapChat)]) {
        [self.delegate shortVideoLandscapeControlViewDelegateForTapChat];
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
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"mute":isMuted ? @(1) : @(0)};
    [MobClick event:@"shortvideo_mute_click" attributes:dict];
}

- (void)tapLike:(BOOL)isLike {
    if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapLike:)]) {
        [self.delegate shortVideoLandscapeControlViewDelegateForTapLike:isLike];
    }
}

- (void)playAction {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapPlay:)]) {
            [self.delegate shortVideoLandscapeControlViewDelegateForTapPlay:NO];
        }
        [manager pause];
    }else {
        if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapPlay:)]) {
            [self.delegate shortVideoLandscapeControlViewDelegateForTapPlay:YES];
        }
        [manager play];
    }
    self.playBtn.selected = manager.isPlaying;
}

- (void)tapAddAnchor {
    if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapFollowAnchor)]) {
        [self.delegate shortVideoLandscapeControlViewDelegateForTapFollowAnchor];
    }
}

- (void)gotoAnchor {
    if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapGotoAnchor)]) {
        [self.delegate shortVideoLandscapeControlViewDelegateForTapGotoAnchor];
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
        if (!self.topContainerView.isHidden) {
            [self gestureSingleTapped];
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
    if ([self.delegate respondsToSelector:@selector(shortVideoLandscapeControlViewDelegateForTapRetryLoadVideo)]) {
        [self.delegate shortVideoLandscapeControlViewDelegateForTapRetryLoadVideo];
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

//- (UIButton *)chatButton {
//    if (!_chatButton) {
//        _chatButton = [[UIButton alloc] init];
//        _chatButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
//        [_chatButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoChatIcon"] forState:UIControlStateNormal];
//        [_chatButton addTarget:self action:@selector(tapChat) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _chatButton;
//}

//- (UILabel *)chatNumberLabel {
//    if (!_chatNumberLabel) {
//        _chatNumberLabel = [[UILabel alloc] init];
//        _chatNumberLabel.textColor = [UIColor whiteColor];
//        _chatNumberLabel.font = [UIFont systemFontOfSize:14];
//    }
//    return _chatNumberLabel;
//}

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

- (ShortVideoFavoriteView *)likeButton {
    if (!_likeButton) {
        _likeButton = [[ShortVideoFavoriteView alloc] init];
        _likeButton.touchExtendInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
//        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
//        [_likeButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoLoveIcon"] forState:UIControlStateNormal];
//        [_likeButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoLoveOnIcon"] forState:UIControlStateSelected];
//        [_likeButton addTarget:self action:@selector(tapLike) forControlEvents:UIControlEventTouchUpInside];
        WeakSelf
        _likeButton.tapLikeblock = ^(BOOL isLike) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf tapLike:isLike];
        };
    }
    return _likeButton;
}

- (UILabel *)likeNumberLabel {
    if (!_likeNumberLabel) {
        _likeNumberLabel = [[UILabel alloc] init];
        _likeNumberLabel.textColor = [UIColor whiteColor];
        _likeNumberLabel.font = [UIFont systemFontOfSize:10];
    }
    return _likeNumberLabel;
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

- (DouYinLoading *)douYinLoading {
    if (!_douYinLoading) {
        _douYinLoading = [DouYinLoading showInView:self];
        _douYinLoading.hidden = YES;
        _douYinLoading.userInteractionEnabled = NO;
    }
    return _douYinLoading;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 22;
        _avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatarImageView.layer.borderWidth = 2;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAnchor)];
        [_avatarImageView addGestureRecognizer:tap];
    }
    return _avatarImageView;
}

- (FocusView *)addAnchorButton {
    if (!_addAnchorButton) {
        _addAnchorButton = [[FocusView alloc] init];
        _addAnchorButton.hidden = YES;
        WeakSelf
        _addAnchorButton.tapAddblock = ^(BOOL isAdd) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf tapAddAnchor];
        };
    }
    return _addAnchorButton;
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

#pragma mark - 连击爱心动画
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    //获取点击坐标，用于设置爱心显示位置
    CGPoint point = [sender locationInView:self];
    //获取当前时间
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    //判断当前点击时间与上次点击时间的时间间隔
    if(time - _lastTapTime > 0.5f) {
        //推迟0.25秒执行单击方法
        [self performSelector:@selector(handleGestureForPlay) withObject:nil afterDelay:0.5f];
        [self performSelector:@selector(gestureSingleTapped) withObject:nil afterDelay:0.5f];
    }else {
        self.isLoveAnimation = YES;
        //取消执行单击方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleGestureForPlay) object: nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gestureSingleTapped) object: nil];
        //执行连击显示爱心的方法
        [self showLikeViewAnim:point oldPoint:_lastTapPoint];
        [self performSelector:@selector(updateIsLoveAnimationStatus) withObject:nil afterDelay:0.5f];
    }
    //更新上一次点击位置
    _lastTapPoint = point;
    //更新上一次点击时间
    _lastTapTime =  time;
}

- (void)updateIsLoveAnimationStatus {
    self.isLoveAnimation = NO;
}

- (void)showLikeViewAnim:(CGPoint)newPoint oldPoint:(CGPoint)oldPoint {
    if (self.likeButton.isLike == NO) {
        [self.likeButton showLikeAnimation];
    }
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"ShortVideoLoveOnIcon"]];
    CGFloat k = ((oldPoint.y - newPoint.y)/(oldPoint.x - newPoint.x));
    k = fabs(k) < 0.5 ? k : (k > 0 ? 0.5f : -0.5f);
    CGFloat angle = M_PI_4 * -k;
    likeImageView.frame = CGRectMake(newPoint.x, newPoint.y, 80, 80);
    likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 0.8f, 1.8f);
    [self addSubview:likeImageView];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 1.0f, 1.0f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5f
                                               delay:0.5f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 3.0f, 3.0f);
                                              likeImageView.alpha = 0.0f;
                                          }
                                          completion:^(BOOL finished) {
                                              [likeImageView removeFromSuperview];
                                          }];
                     }];
}

@end
