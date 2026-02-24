//
//  ShortVideoPortraitControlView.m
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoPortraitControlView.h"
#import "GKDYTools.h"
#import "DouYinLoading.h"
#import "ShortVideoFavoriteView.h"
#import "TouchSuperView.h"
#import "FocusView.h"
#import "SpeedUpTipView.h"
#import "PassthroughTextView.h"
#import "VideoVipAlertView.h"
#import <UMCommon/UMCommon.h>
#import "VipPayAlertView.h"

@interface ShortVideoPortraitControlView ()<UITextViewDelegate> {
    BOOL isShowLoading;
}
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) TouchSuperView *bottomView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) ShortVideoFavoriteView *likeButton;
@property (nonatomic, strong) UILabel *likeNumberLabel;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UILabel *chatNumberLabel;

@property (nonatomic, strong) UIView *fullScreenBtn;
@property (nonatomic, strong) DouYinLoading *douYinLoading;
@property (nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property (nonatomic, strong) FocusView *addAnchorButton;

@property (nonatomic, strong) PassthroughTextView *hashtagLabel;
@property (nonatomic, strong) MASConstraint *heightConstraint;
// 連擊愛心
@property (nonatomic, assign) NSTimeInterval lastTapTime;
@property (nonatomic, assign) CGPoint lastTapPoint;
@property (nonatomic, strong) SpeedUpTipView *speedView;
// 創作時間
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) MASConstraint *createTimeHeightConstraint;

// 付費
@property (nonatomic, strong) UIStackView *tagStackView;
@property (nonatomic, strong) UIButton *vipTagButton;
@property (nonatomic, strong) UIButton *payTagButton;
// 重試按鈕
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIView *cooldownAndPayButton;
@property (nonatomic, strong) UILabel *cooldownPreviewLabel;

@end

@implementation ShortVideoPortraitControlView

@synthesize player = _player;

- (instancetype)initWithTabbarHeight:(CGFloat)height frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.lastTapTime = 0;
        self.lastTapPoint = CGPointZero;
        self.tabbarHeight = height;
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self addGestureRecognizer:singleTapGesture];

        [self setupViews];
    }
    return self;
}

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

        self.player.currentPlayerManager.muted = currentTime >= previewDuration;

        id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
        if (currentTime >= previewDuration && !manager.isPlaying) {
            [manager play];
        }
    }
}

- (void)setModel:(ShortVideoModel *)model {
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

    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.user_avatar] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    [self.addAnchorButton resetView];
    self.addAnchorButton.hidden = model.is_follow;
    if ([model.uid isEqualToString:[Config getOwnID]]) {
        self.addAnchorButton.hidden = YES;
    }
    self.nameLabel.text = model.user_name;
    [self.likeButton like:model.is_like];
//    self.likeButton.selected = model.is_like;
    self.likeNumberLabel.text = [YBToolClass formatLikeNumber:minnum(model.likes_count)];
    self.chatNumberLabel.text = minnum(model.comments_count);

    // hashtag
    self.hashtagLabel.attributedText = [self attributedStringWithHashtags:model.topics desc:model.description_];
    [self updateTextViewHeight];

    [self updateVoiceStatus];
    [self showCreateTimeIfNeed];
}

- (void)updatePayCoverView {
    self.payCoverView.is_vip = _model.is_vip;
    self.payCoverView.ticket_cost = _model.ticket_cost;
    self.payCoverView.coin_cost = _model.coin_cost;
    [self.payCoverView refresh];

    self.playImageView.hidden = YES;
    if (self.player.currentPlayerManager.assetURL != nil) {
        self.playImageView.hidden = self.player.currentPlayerManager.isPlaying == YES;
    }

    if (_model.isNeedPay == ShortVideoModelPayTypeFree) {
        [self.payTagButton setTitle:YZMsg(@"movie_pay_Purchased") forState:UIControlStateNormal];
        self.slider.smallSliderBtnHeight = 0.0;
        self.slider.smallSliderHeight = 0.0;

        self.blurEffectView.hidden = YES;
        self.payCoverView.hidden = YES;
        self.player.currentPlayerManager.muted = NO;
    } else {
        self.douYinLoading.hidden = YES;
        [self.payTagButton setTitle:YZMsg(@"movie_pay") forState:UIControlStateNormal];
        self.slider.smallSliderBtnHeight = 5.0;
        self.slider.smallSliderHeight = 3.0;

        CGFloat previewTime = self.model.preview_duration;
        NSString *remain = [GKDYTools convertTimeSecond:previewTime];
        self.cooldownPreviewLabel.text = [NSString stringWithFormat:YZMsg(@"short_video_preview"), remain];
    }
}

- (void)updateCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime {
    //    self.currentTimeLabel.text = [GKDYTools convertTimeSecond:currentTime];
    //    self.totalTimeLabel.text = [GKDYTools convertTimeSecond:totalTime];
    [self.slider updateCurrentTime:currentTime totalTime:totalTime];
}

- (void)hiddenFullScreen:(BOOL)isHidden {
    [self updateFullScreenPosition];
    self.fullscreenBtn.hidden = isHidden;
}

- (void)showCreateTimeIfNeed {
    CGFloat height = 16;
    self.createTimeLabel.text = @"";
    if (self.showCreateTime) {
        height = 40;
        self.createTimeLabel.text = minstr(self.model.updated_at);
    }
    self.createTimeHeightConstraint.mas_equalTo(height);
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

#pragma mark - UI
- (void)setupViews {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPressGesture];

    [self addSubview:self.bottomView];
    [self addSubview:self.retryButton];
    [self addSubview:self.slider];
    [self.bottomView addSubview:self.hashtagLabel];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.voiceButton];
    [self.bottomView addSubview:self.likeButton];
    [self.bottomView addSubview:self.likeNumberLabel];
    [self.bottomView addSubview:self.chatButton];
    [self.bottomView addSubview:self.chatNumberLabel];
    [self.bottomView addSubview:self.avatarImageView];
    [self.bottomView addSubview:self.addAnchorButton];
    [self.bottomView addSubview:self.createTimeLabel];
    [self.bottomView addSubview:self.tagStackView];

    [self addSubview:self.playImageView];
    [self addSubview:self.fullscreenBtn];
    [self addSubview:self.speedView];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(_window_width - 8));
//        make.left.equalTo(self).offset(4);
//        make.right.equalTo(self).offset(-4);
        make.bottom.equalTo(self.bottomView);
        make.height.equalTo(@60);
    }];

    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(RatioBaseWidth390(44)));
        make.center.equalTo(self);
    }];

    // 右
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-6);
        make.bottom.equalTo(self.slider.mas_top).offset(-10);
        make.width.height.equalTo(@44);
    }];

    [self.chatNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.voiceButton.mas_top).offset(-15);
        make.height.equalTo(@14);
    }];

    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.chatNumberLabel);
        make.bottom.equalTo(self.chatNumberLabel.mas_top).offset(2);
        make.width.height.equalTo(@44);
    }];

    [self.likeNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.chatButton.mas_top).offset(-15);
        make.height.equalTo(@14);
    }];

    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.likeNumberLabel.mas_top).offset(2);
        make.width.height.equalTo(@44);
    }];

    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@44);
        make.centerX.equalTo(self.voiceButton);
        make.bottom.equalTo(self.likeButton.mas_top).offset(-29);
        make.top.equalTo(self.bottomView.mas_top).offset(20);
    }];

    [self.addAnchorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatarImageView);
        make.centerY.equalTo(self.avatarImageView.mas_bottom);
        make.size.equalTo(@16);
    }];

    // 底
    [self.createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bottomView).inset(14);
        make.bottom.equalTo(self.bottomView).offset(-4);
        self.createTimeHeightConstraint = make.height.equalTo(@0);
    }];

    [self.hashtagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(14);
        make.right.equalTo(self.voiceButton.mas_left).offset(-4);
        make.bottom.equalTo(self.createTimeLabel.mas_top);
        self.heightConstraint = make.height.equalTo(@0);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(14);
        make.right.equalTo(self.voiceButton).offset(-4);
        make.bottom.equalTo(self.hashtagLabel.mas_top).offset(-5);
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

//    self.fullscreenBtn.x = self.width/2;
//    self.fullscreenBtn.y = playerView.bottom+20;
//    self.fullscreenBtn.height = 40;
    if (self.fullscreenBtn.superview && self.superview && playerView && playerView.superview) {
        [self.fullscreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(playerView.mas_bottom).offset(20);
            make.height.mas_equalTo(40);
        }];
    } else {
        NSLog(@"fullscreenBtn 未添加到视图层次结构中，跳过 mas_remakeConstraints 设置。");
    }
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
        if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapPlay:)]) {
            [self.delegate shortVideoPortraitControlViewDelegateForTapPlay:NO];
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
        if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapPlay:)]) {
            [self.delegate shortVideoPortraitControlViewDelegateForTapPlay:YES];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateTextViewHeight];
}

#pragma mark - Action
- (void)tapChat {
    if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapChat)]) {
        [self.delegate shortVideoPortraitControlViewDelegateForTapChat];
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
    if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapLike:)]) {
        [self.delegate shortVideoPortraitControlViewDelegateForTapLike:isLike];
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

    if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapFullScreen)]) {
        [self.delegate shortVideoPortraitControlViewDelegateForTapFullScreen];
    }
}

- (void)tapAddAnchor {
    if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapFollowAnchor)]) {
        [self.delegate shortVideoPortraitControlViewDelegateForTapFollowAnchor];
    }
}

- (void)gotoAnchor {
    if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapGotoAnchor)]) {
        [self.delegate shortVideoPortraitControlViewDelegateForTapGotoAnchor];
    }
}

- (void)retryLoadVideo {
    self.retryButton.hidden = YES;
    [self hiddenLoading:NO];
    if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapRetryLoadVideo)]) {
        [self.delegate shortVideoPortraitControlViewDelegateForTapRetryLoadVideo];
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
        [self.slider showLargeSlider];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        [self.player.currentPlayerManager setRate:1.0];
        self.speedView.hidden = YES;
        [self.slider showBriefTimeSlider:2.5];
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
//    [self handleSingleTapped];
}

- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location {
    NSLog(@"<>>>start");
}

- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location {
    NSLog(@"<>>>end");
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    //    self.currentTimeLabel.text = [GKDYTools convertTimeSecond:currentTime];
    //    self.totalTimeLabel.text = [GKDYTools convertTimeSecond:totalTime];

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

        _nameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAnchor)];
        [_nameLabel addGestureRecognizer:tap];
    }
    return _nameLabel;
}

- (PassthroughTextView *)hashtagLabel {
    if (!_hashtagLabel) {
        _hashtagLabel = [[PassthroughTextView alloc] init];
        _hashtagLabel.textColor = [UIColor whiteColor];
        _hashtagLabel.backgroundColor = [UIColor clearColor];
        _hashtagLabel.delegate = self;
        _hashtagLabel.editable = NO;
        _hashtagLabel.dataDetectorTypes = UIDataDetectorTypeLink;
        _hashtagLabel.scrollEnabled = NO;
        _hashtagLabel.textContainerInset = UIEdgeInsetsZero;
        _hashtagLabel.textContainer.lineFragmentPadding = 0;
        _hashtagLabel.dataDetectorTypes = UIDataDetectorTypeLink;
        _hashtagLabel.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        _hashtagLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _hashtagLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        _hashtagLabel.layer.shadowOpacity = 0.5;
        _hashtagLabel.underlyingView = self.slider;

        for (UIGestureRecognizer *gestureRecognizer in _hashtagLabel.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)gestureRecognizer;
                if (tapGesture.numberOfTapsRequired == 2) {
                    [_hashtagLabel removeGestureRecognizer:tapGesture];
                }
            }
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [_hashtagLabel removeGestureRecognizer:gestureRecognizer];
            }
        }
    }
    return _hashtagLabel;
}

- (UIButton *)chatButton {
    if (!_chatButton) {
        _chatButton = [[UIButton alloc] init];
        _chatButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [_chatButton setImage:[ImageBundle imagewithBundleName:@"ShortVideoChatIcon"] forState:UIControlStateNormal];
        [_chatButton addTarget:self action:@selector(tapChat) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatButton;
}

- (UILabel *)chatNumberLabel {
    if (!_chatNumberLabel) {
        _chatNumberLabel = [[UILabel alloc] init];
        _chatNumberLabel.textColor = [UIColor whiteColor];
        _chatNumberLabel.font = [UIFont systemFontOfSize:10];
        _chatNumberLabel.layer.shadowOpacity = 0.5;
        _chatNumberLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _chatNumberLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
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
        _likeNumberLabel.layer.shadowOpacity = 0.5;
        _likeNumberLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _likeNumberLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _likeNumberLabel;
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
                NSInteger previewDuration = strongSelf.model.preview_duration <= 0 ? 20 : strongSelf.model.preview_duration;
                strongSelf.payCoverView.hidden = !(time >= previewDuration);
            }
        };

        _slider.tapEvent = ^(CGPoint point) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            point.x -= 10;

            if ([strongSelf.hashtagLabel isLinkAtPoint:point]) {
                NSUInteger charIndex = [strongSelf.hashtagLabel characterIndexAtPoint:point];
                if (charIndex != NSNotFound) {
                    NSAttributedString *attrString = strongSelf.hashtagLabel.attributedText;
                    NSRange effectiveRange;
                    NSString *urlString = [attrString attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&effectiveRange];
                    NSURL *url = [NSURL URLWithString:urlString];
                    if ([[url scheme] isEqualToString:@"search"]) {
                        if ([strongSelf.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapHashtag:)]) {
                            NSString *hashtag = [[url host] stringByRemovingPercentEncoding];
                            [strongSelf.delegate shortVideoPortraitControlViewDelegateForTapHashtag:hashtag];
                        }
                    }
                }
            }
        };
    }
    return _slider;
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

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
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

- (UILabel *)createTimeLabel {
    if (!_createTimeLabel) {
        _createTimeLabel = [[UILabel alloc] init];
        _createTimeLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        _createTimeLabel.font = [UIFont systemFontOfSize:12];
        _createTimeLabel.layer.shadowOpacity = 0.5;
        _createTimeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _createTimeLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _createTimeLabel;
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

- (VideoPayCoverView *)payCoverView {
    if (!_payCoverView) {
        _payCoverView = [VideoPayCoverView new];
        _payCoverView.hidden = YES;
        _payCoverView.blurEffectView.hidden = YES;
        _payCoverView.videoType = 2;
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
        _blurEffectView.alpha = 0.92;
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

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([[URL scheme] isEqualToString:@"search"]) {
        if ([self.delegate respondsToSelector:@selector(shortVideoPortraitControlViewDelegateForTapHashtag:)]) {
            NSString *hashtag = [[URL host] stringByRemovingPercentEncoding];
            [self.delegate shortVideoPortraitControlViewDelegateForTapHashtag:hashtag];
        }
    }
    return NO;
}

#pragma mark - Hashtag
- (NSAttributedString *)attributedStringWithHashtags:(NSArray*)hashtags desc:(NSString*)desc {
    NSMutableArray *newHashtags = [NSMutableArray array];
    for (NSDictionary *tagDic in hashtags) {
        if ([tagDic isKindOfClass:[NSDictionary class]]) {
            if ([tagDic[@"name"] isKindOfClass:[NSString class]]) {
                NSString *tag = tagDic[@"name"];
                if (tag.length > 0) {
                    [newHashtags addObject:[NSString stringWithFormat:@"#%@", tag]];
                }
            }
        }
    }

    if (desc.length <= 0) {
        desc = @"";
    }

    NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:14.0],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };

    if (newHashtags.count <= 0) {
        return [[NSMutableAttributedString alloc] initWithString:desc attributes:attributes];
    }

    NSString *rawString = [newHashtags componentsJoinedByString:@" "];
    rawString = [NSString stringWithFormat:@"%@\n%@", desc, rawString];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:rawString attributes: attributes];
    // 添加链接
    for (NSString *tag in newHashtags) {
        NSRange range = [rawString rangeOfString:tag];
        NSString *modifiedTag = tag;
        if ([tag rangeOfString:@"\\#"].location == 0) {
            modifiedTag = [tag stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }

        NSString *urlString = [NSString stringWithFormat:@"search://%@", modifiedTag];
        urlString =  [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [attributedString addAttribute:NSLinkAttributeName value:urlString range:range];
        [attributedString addAttribute:NSUnderlineStyleAttributeName
                                         value:@(NSUnderlineStyleSingle)
                                         range:range];
        [attributedString addAttribute:NSUnderlineColorAttributeName
                                         value:[UIColor whiteColor]
                                         range:range];
    }

    return attributedString;
}

- (void)updateTextViewHeight {
    if (self.hashtagLabel.text.length <= 0) {
        [self updateHeightConstraintTo:0];
        return;
    }

    CGSize sizeThatFitsTextView = [self.hashtagLabel sizeThatFits:CGSizeMake(self.hashtagLabel.frame.size.width, MAXFLOAT)];
    CGFloat height = sizeThatFitsTextView.height;
    self.hashtagLabel.frame = CGRectMake(self.hashtagLabel.frame.origin.x, self.hashtagLabel.frame.origin.y, self.hashtagLabel.frame.size.width, height);
    [self updateHeightConstraintTo:height];
}

- (void)updateHeightConstraintTo:(CGFloat)newHeight {
    self.heightConstraint.mas_equalTo(newHeight);
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

#pragma mark - 连击爱心动画
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    //获取点击坐标，用于设置爱心显示位置
    CGPoint point = [sender locationInView:self];
    //获取当前时间
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    //判断当前点击时间与上次点击时间的时间间隔
    if(time - _lastTapTime > 0.25f) {
        //推迟0.25秒执行单击方法
        [self performSelector:@selector(handleSingleTapped) withObject:nil afterDelay:0.25f];
    }else {
        //取消执行单击方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleSingleTapped) object: nil];
        //执行连击显示爱心的方法
        [self showLikeViewAnim:point oldPoint:_lastTapPoint];
    }
    //更新上一次点击位置
    _lastTapPoint = point;
    //更新上一次点击时间
    _lastTapTime =  time;
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
