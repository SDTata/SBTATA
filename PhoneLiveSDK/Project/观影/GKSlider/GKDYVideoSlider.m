//
//  GKDYVideoSlider.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoSlider.h"
#import "GKDYTools.h"
#import <Masonry/Masonry.h>

@interface GKDYVideoSlider()<GKSliderViewPreviewDelegate> {
    BOOL isShowLoading;
    BOOL isAnimation;
}

@property (nonatomic, assign) CGFloat startLocationX;

@property (nonatomic, assign) float startValue;

@property (nonatomic, assign) BOOL isSeeking;

@end

@implementation GKDYVideoSlider

- (instancetype)init {
    if (self = [super init]) {
        self.previewMargin = 60;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_offset(4);
    }];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delaysTouchesBegan = YES;
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delaysTouchesBegan = NO;
    panGesture.cancelsTouchesInView = YES;
    [self addGestureRecognizer:panGesture];
    [tapGesture requireGestureRecognizerToFail:panGesture];

    self.sliderView.hidden = YES;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf showSmallSlider];
        strongSelf.sliderView.hidden = NO;
    });
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.currentTime = currentTime;
    self.totalTime = totalTime;
    if (self.isDragging) return;
    if (self.isSeeking) return;
    CGFloat value = totalTime == 0 ? 0 : currentTime / totalTime;
    self.sliderView.value = value;
}

- (void)showLoading {
    if (isShowLoading == YES) {
        return;
    }
    isShowLoading = YES;

    if (isAnimation == YES) {
        return;
    }

    [self.sliderView showLineLoading];
}

- (void)hideLoading {
    isShowLoading = NO;
    [self.sliderView hideLineLoading];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:gesture.view];
    if (self.tapEvent) {
        self.tapEvent(location);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (self.totalTime <= 0) {
        return;
    }
    CGPoint location = [gesture locationInView:gesture.view];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.startLocationX = location.x;
            self.startValue = self.sliderView.value;
            if (self.sliderView.preview) {
                [self hiddenPreviewIfNeed:NO];
            }
            self.isDragging = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSmallSlider) object:nil];
            [self showLargeSlider];
            !self.slideBlock ?: self.slideBlock(self.isDragging);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat diff = location.x - self.startLocationX;
            CGFloat progress = self.startValue + diff / gesture.view.frame.size.width;
            if (progress < 0) progress = 0;
            if (progress > 1) progress = 1;
            self.sliderView.value = progress;
            if (self.sliderView.preview && [self.sliderView.previewDelegate respondsToSelector:@selector(sliderView:preview:valueChanged:)]) {
                [self.sliderView.previewDelegate sliderView:self.sliderView preview:self.sliderView.preview valueChanged:self.sliderView.value];
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSmallSlider) object:nil];
            [self showDragSlider];
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.isDragging = NO;
            if (self.sliderView.preview) {
                [self hiddenPreviewIfNeed:YES];
            }
            [self showLargeSlider];
            [self performSelector:@selector(showSmallSlider) withObject:nil afterDelay:1.0f];
            !self.slideBlock ?: self.slideBlock(self.isDragging);
            [self seekTo:self.sliderView.value];
        }
            break;
            
        default:
            break;
    }
}

- (void)hiddenPreviewIfNeed:(BOOL)isHidden {
    [UIView animateWithDuration:0.2 animations:^{
        self.sliderView.preview.alpha = isHidden ? 0 : 1;
    }];
}

- (void)seekTo:(float)value {
    NSTimeInterval time = self.totalTime * value;
    
    self.isSeeking = YES;
    WeakSelf
    if (time == 0) {
        time = 0;
    }

    if (value == 1) {
        time = self.totalTime - 2;
    }
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isSeeking = NO;
        !strongSelf.seekCompletionTime ?: strongSelf.seekCompletionTime(time);
        strongSelf.player.currentPlayerManager.playerPlayTimeChanged(strongSelf.player.currentPlayerManager, time, strongSelf.totalTime);
    }];
}

- (void)showBriefTimeSlider:(CGFloat)second {
    [self showLargeSlider];
    [self performSelector:@selector(showSmallSlider) withObject:nil afterDelay:second];
}

#pragma mark - Slider
- (void)showSmallSlider {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.sliderView.sliderBtn.frame;
        frame.size = CGSizeMake(self.smallSliderBtnHeight, self.smallSliderBtnHeight);
        self.sliderView.sliderBtn.frame = frame;
        self.sliderView.sliderBtn.layer.cornerRadius = self.smallSliderBtnHeight/2.0;
        self.sliderView.sliderHeight = self.smallSliderHeight;
        [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(4);
        }];

        self.sliderView.bgCornerRadius = self.smallSliderHeight/2.0;

        [self layoutIfNeeded];
    }];
}

- (void)showLargeSlider {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSmallSlider) object:nil];
    isAnimation = YES;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.sliderView.sliderBtn.frame;
        frame.size = CGSizeMake(10, 10);
        self.sliderView.sliderBtn.frame = frame;
        self.sliderView.sliderBtn.layer.cornerRadius = 5;
        if (self.sliderView.sliderHeight < 6) {
            self.sliderView.sliderHeight = 6;
        }
        [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(8);
        }];
        self.sliderView.bgCornerRadius = 3;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.sliderView.sliderHeight > 6) {
            self.sliderView.sliderHeight = 6;
        }
        self->isAnimation = NO;
        if (self.isDragging == NO) {
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (strongSelf->isShowLoading) {
                    [strongSelf.sliderView showLineLoading];
                }
            });
        }
    }];
}

- (void)showDragSlider {
    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(8, 16);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 4;
    self.sliderView.sliderHeight = 10;
    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
    }];
    self.sliderView.bgCornerRadius = 5;
}

#pragma mark - GKSliderViewPreviewDelegate
- (UIView *)sliderViewSetupPreview:(GKSliderView *)sliderView {
    GKSliderButton *preview = [[GKSliderButton alloc] init];
    NSString *currentTime = [GKDYTools convertTimeSecond:self.currentTime];
    NSString *totalTime = [GKDYTools convertTimeSecond:self.totalTime];
    [preview setTitle:[NSString stringWithFormat:@"%@ / %@", currentTime, totalTime] forState:UIControlStateNormal];
    [preview setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    preview.titleLabel.font = [UIFont systemFontOfSize:18];
    [preview sizeToFit];
    CGRect frame = preview.frame;
    frame.size.width += 20;
    preview.frame = frame;
    return preview;
}

- (CGFloat)sliderViewPreviewMargin:(GKSliderView *)sliderView {
    return self.previewMargin;
}

- (void)sliderView:(GKSliderView *)sliderView preview:(UIView *)preview valueChanged:(float)value {
    GKSliderButton *button = (GKSliderButton *)preview;
    NSString *currentTime = [GKDYTools convertTimeSecond:self.totalTime * value];
    NSString *totalTime = [GKDYTools convertTimeSecond:self.totalTime];
    NSString *showTimeString = [NSString stringWithFormat:@"%@  /  %@", currentTime, totalTime];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:showTimeString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, currentTime.length)];
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
}

#pragma mark - lazy
- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        _sliderView.isSliderAllowTapped = NO;
        _sliderView.sliderHeight = 6;
        _sliderView.maximumTrackTintColor = [UIColor lightGrayColor];
        _sliderView.minimumTrackTintColor = [UIColor whiteColor];
        _sliderView.sliderBtn.layer.masksToBounds = YES;
        _sliderView.sliderBtn.backgroundColor = UIColor.whiteColor;
        _sliderView.isPreviewChangePosition = NO;
        _sliderView.userInteractionEnabled = NO;
        _sliderView.previewDelegate = self;
        _sliderView.clipsToBounds = YES;
        _sliderView.layer.cornerRadius = 3;
        _sliderView.layer.masksToBounds = YES;
        _sliderView.lineHeight = 3;
    }
    return _sliderView;
}

@end
