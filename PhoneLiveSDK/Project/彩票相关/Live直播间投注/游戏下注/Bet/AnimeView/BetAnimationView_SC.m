//
//  BetAnimationView_SC.m
//  phonelive2
//
//  Created by vick on 2023/12/15.
//  Copyright © 2023 toby. All rights reserved.
//

#import "BetAnimationView_SC.h"
#import "SCCarView.h"
#import "LotteryVoiceUtil.h"

UIKIT_STATIC_INLINE UIButton *createLightBtn(NSString *normal, NSString *selected) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[ImageBundle imagewithBundleName:normal] forState:UIControlStateNormal];
    [button setImage:[ImageBundle imagewithBundleName:selected] forState:UIControlStateSelected];
    button.userInteractionEnabled = NO;
    return button;
}

#define kCarViewTag 1000

@interface BetAnimationView_SC ()

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImageView *startImgView;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL isFinish;
@property (nonatomic, assign) BOOL isGameOver;

@property (nonatomic, strong) UIView *lightMaskView;

@end

@implementation BetAnimationView_SC

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isFinish = YES;
        self.isGameOver = YES;
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    [LotteryVoiceUtil.shared stopPlayAward];
    VKLOG(@"%@ - dealloc", NSStringFromClass(self.class));
}

- (UIView *)lightMaskView {
    if (!_lightMaskView) {
        _lightMaskView = [UIView new];
        _lightMaskView.backgroundColor = vkColorHexA(0x000000, 0.5);
        [_lightMaskView vk_border:UIColor.whiteColor cornerRadius:10];
        _lightMaskView.hidden = YES;
        
        [_lightMaskView addSubview:createLightBtn(@"sc_red_n", @"sc_red_s")];
        [_lightMaskView addSubview:createLightBtn(@"sc_red_n", @"sc_red_s")];
        [_lightMaskView addSubview:createLightBtn(@"sc_yellow_n", @"sc_yellow_s")];
        [_lightMaskView addSubview:createLightBtn(@"sc_yellow_n", @"sc_yellow_s")];
        [_lightMaskView addSubview:createLightBtn(@"sc_green_n", @"sc_green_s")];
        [_lightMaskView addSubview:createLightBtn(@"sc_green_n", @"sc_green_s")];
        
        [_lightMaskView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:10 tailSpacing:10];
        [_lightMaskView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.top.mas_equalTo(5);
            make.bottom.mas_equalTo(-5);
        }];
    }
    return _lightMaskView;
}

- (void)setupView {
    
    CGFloat height = 120;
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"sc_road"];
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(-3);
        make.bottom.mas_equalTo(3);
        make.height.mas_equalTo(height);
        make.width.mas_equalTo(backImgView.mas_height).multipliedBy(backImgView.image.size.width/backImgView.image.size.height);
    }];
    
    UIImageView *startImgView = [UIImageView new];
    startImgView.image = [ImageBundle imagewithBundleName:@"sc_line"];
    startImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:startImgView];
    self.startImgView = startImgView;
    [startImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    for (NSInteger i=0; i<10; i++) {
        SCCarView *carImgView = [[SCCarView alloc] initWithIndex:i+1];
        carImgView.tag = kCarViewTag + i;
        [self addSubview:carImgView];
        
        CGFloat carHeight = 17;
        CGFloat y = carHeight * i - 5 * i - 10;
        CGFloat x = -3.5 * i - 10;
        [carImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(carHeight);
            make.width.mas_equalTo(carImgView.mas_height).multipliedBy(3.0);
            make.right.mas_equalTo(x);
            make.top.mas_equalTo(y);
        }];
    }
    
    /// 红绿灯
    [self addSubview:self.lightMaskView];
    [self.lightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
}

#pragma mark - 倒计时
- (void)setCountDownTime:(NSUInteger)countDownTime {
    for (UIButton *btn in self.lightMaskView.subviews) {
        btn.selected = NO;
    }
    if (countDownTime < 3 && countDownTime >= 0) {
        UIButton *btn1 = self.lightMaskView.subviews[countDownTime*2];
        UIButton *btn2 = self.lightMaskView.subviews[countDownTime*2+1];
        btn1.selected = YES;
        btn2.selected = YES;
        self.lightMaskView.hidden = NO;
    } else {
        self.lightMaskView.hidden = YES;
    }
}

- (void)startAnimation {
    
    [self setCountDownTime:2];
    
    _weakify(self)
    vkGcdAfter(1.0, ^{
        _strongify(self)
        [self setCountDownTime:1];
    });
    
    vkGcdAfter(2.0, ^{
        _strongify(self)
        [self setCountDownTime:0];
    });
    
    vkGcdAfter(3.0, ^{
        _strongify(self)
        [self setCountDownTime:-1];
    });
}

- (void)startCarAnimation {
    
    self.lightMaskView.hidden = YES;
    self.isFinish = NO;
    self.isGameOver = NO;
    
    [self createTimer];
    
    [self startAnimationNew:YES];
    
    _weakify(self)
    [UIView animateWithDuration:2.0 animations:^{
        _strongify(self)
        self.startImgView.x = VK_SCREEN_W + 200;
    } completion:nil];
    
    [LotteryVoiceUtil.shared startPlayAward:@"sc_game"];
}

- (void)stopAnimation {
    
    if (!self.isFinish) {
        self.startImgView.x = -400;
        _weakify(self)
        [UIView animateWithDuration:4.0 animations:^{
            _strongify(self)
            self.startImgView.x = VK_SCREEN_W/2;
        } completion:^(BOOL finished) {
            _strongify(self)
            [self deleteTimer];
            
            [LotteryVoiceUtil.shared stopPlayAward];
        }];
    }
    
    self.isFinish = YES;
}

- (void)clear {
    
    self.lightMaskView.hidden = YES;
    self.isFinish = YES;
    self.isGameOver = YES;
    
    [self deleteTimer];
    
    _weakify(self)
    [UIView animateWithDuration:2.0 animations:^{
        _strongify(self)
        self.startImgView.x = VK_SCREEN_W - 150;
    } completion:nil];
    
    for (NSInteger i=0; i<10; i++) {
        SCCarView *carImgView = [self viewWithTag:kCarViewTag + i];
        [carImgView speedStopAnimation];
        
        CGFloat x = CGRectGetWidth(self.frame) -3.5 * i - 10 - CGRectGetWidth(carImgView.frame);
        [self isMovieX:x imageView:carImgView index:i];
    }
}

- (void)createTimer {
    [self deleteTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(carMovieAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)deleteTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)carMovieAction {
    CGFloat movieX = 50;
    if (self.backImgView.frame.origin.x > -movieX) {
        self.backImgView.x = -self.backImgView.width + CGRectGetWidth(self.frame);
    } else {
        self.backImgView.x = self.backImgView.x + movieX;
    }
}

///  动画开始
- (void)startAnimationNew:(BOOL)isFirst {
    
    for (NSInteger i = 0; i<10; i++) {
        SCCarView *imageView = [self viewWithTag:kCarViewTag + i];
        if (!self.isFinish) {
            CGFloat movieX = 0;
            if (isFirst) {
                /// 第一次启动，全部加速
                [imageView speedUpAnimation];
                [imageView speedStartAnimation];
                movieX = [self getXLocal];
                [self isMovieX:movieX imageView:imageView index:i];
            } else {
                /// 不是第一次启动，而且在前半段 ，后退
                if (imageView.frame.origin.x < self.frame.size.width/2.0f) {
                    movieX = [self getXRetreat];
                    if (movieX > self.frame.size.width) {
                        movieX = self.frame.size.width;
                    }
                    [imageView speedDownAnimation];
                    [self isMovieX:movieX imageView:imageView index:i];
                } else {
                    /// 在后半段，前进
                    BOOL isMovie = arc4random() % 50 > 35 ? NO : YES;
                    if (isMovie) {
                        movieX = [self getXLocal];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [imageView speedUpAnimation];
                        });
                    }else{
                        movieX = imageView.frame.origin.x - 10;
                        [imageView speedDownAnimation];
                    }
                    if (movieX < 0) movieX = 5;
                    [self isMovieX:movieX imageView:imageView index:i];
                }
            }

        } else {
            
            if (self.isGameOver) {
                return;
            }
            
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (NSInteger i = 0; i<10; i++) {
                [array addObject:[NSString stringWithFormat:@"%ld", i+1]];
            }
            
            NSString *result = [array componentsJoinedByString:@","];
            if ([self.winValue isEqualToString:result]) {
                self.isGameOver = YES;
                return;
            }
            
            if (!self.winValue) {
                return;
            }
            
            NSArray *items = [self.winValue componentsSeparatedByString:@","];
            NSInteger index = [items[i] integerValue] - 1;
            SCCarView *iv = [self viewWithTag:kCarViewTag + index];
            
            CGFloat mx = i * 20 + 50;
            if (mx > iv.frame.origin.x) {
                [imageView speedUpAnimation];
            } else {
                [imageView speedDownAnimation];
            }
            [imageView speedStartAnimation];
            [self isMovieX:mx imageView:iv index:i];
        }
    }
}

- (void)isMovieX:(CGFloat)movieX imageView:(SCCarView *)imageView index:(NSInteger)index {
    _weakify(self)
    [UIView animateWithDuration:2 animations:^{
        imageView.x = movieX;
    } completion:^(BOOL finished) {
        _strongify(self)
        
        [imageView speedDownAnimation];
        
        /// 最后一辆车   游戏没结束
        if (index == 9 && !self.isGameOver) {
            [self startAnimationNew:NO];
        }
    }];
}

///  获取指定前进位置
- (CGFloat)getXLocal {
    return arc4random() % 150 + 15;
}

/// 获取指定后退位置
- (CGFloat)getXRetreat {
    return arc4random() % (int)(self.frame.size.width - 100);
}

@end
