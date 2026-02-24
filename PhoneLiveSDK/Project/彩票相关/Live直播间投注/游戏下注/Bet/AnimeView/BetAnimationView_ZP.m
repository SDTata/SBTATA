//
//  BetAnimationView_ZP.m
//  phonelive2
//
//  Created by vick on 2024/1/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BetAnimationView_ZP.h"
#import "LotteryVoiceUtil.h"

#define perSection    M_PI*2/37

@interface BetAnimationView_ZP ()

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIView *ballBackView;

@end

@implementation BetAnimationView_ZP

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    [LotteryVoiceUtil.shared stopPlayAward];
    VKLOG(@"%@ - dealloc", NSStringFromClass(self.class));
}

- (void)setupView {
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"game_desk_zp_small"];
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    CGFloat value = VKPX(14);
    UIView *ballBackView = [UIView new];
    [backImgView addSubview:ballBackView];
    self.ballBackView = ballBackView;
    [ballBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(backImgView).insets(UIEdgeInsetsMake(value, value, value, value));
    }];
    
    UIImageView *ballView = [UIImageView new];
    ballView.image = [ImageBundle imagewithBundleName:@"zp_ball"];
    [ballBackView addSubview:ballView];
    [ballView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(5);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
}

- (void)startAnimation {
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    layer.toValue = @(M_PI*2*20);
    layer.duration = 20;
    layer.repeatCount = MAXFLOAT;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    layer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.backImgView.layer addAnimation:layer forKey:nil];
    
    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    ballLayer.toValue = @(-M_PI*2*40);
    ballLayer.duration = 20;
    ballLayer.repeatCount = MAXFLOAT;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    ballLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.ballBackView.layer addAnimation:ballLayer forKey:nil];
    
    [LotteryVoiceUtil.shared startPlayAward:@"lunpanaudio_begain"];
}

- (void)stopAnimation {
    [self backToStartPosition];
    
//    int x = arc4random() % 37;
    CGFloat value = M_PI*4 + perSection * (37 - self.winValue);
    
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    layer.toValue = @(M_PI*2);
    layer.duration = 2;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    layer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.backImgView.layer addAnimation:layer forKey:nil];
    
    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    ballLayer.toValue = @(-value);
    ballLayer.duration = 2;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    ballLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.ballBackView.layer addAnimation:ballLayer forKey:nil];
    
    vkGcdAfter(2.0, ^{
        [LotteryVoiceUtil.shared stopPlayAward];
    });
}

- (void)backToStartPosition {
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    layer.toValue = @(0);
    layer.duration = 0.001;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    [self.backImgView.layer addAnimation:layer forKey:nil];
    
    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    ballLayer.toValue = @(0);
    ballLayer.duration = 0.001;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    [self.ballBackView.layer addAnimation:ballLayer forKey:nil];
}

- (void)clear {
    
}

@end
