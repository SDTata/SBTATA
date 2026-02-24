//
//  BetAnimationView_YFKS.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BetAnimationView_YFKS.h"
#import "LiveGifImage.h"
#import "LotteryVoiceUtil.h"

@interface BetAnimationView_YFKS ()

@property (nonatomic, strong) YYAnimatedImageView *animationView;
@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImageView *foreImgView;

@end

@implementation BetAnimationView_YFKS

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
    
    CGFloat height = 100;
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"yfkz_shaigu"];
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
        make.height.mas_equalTo(height);
        make.width.mas_equalTo(backImgView.mas_height).multipliedBy(1.16);
    }];
    
    UIImageView *foreImgView = [UIImageView new];
    foreImgView.image = [ImageBundle imagewithBundleName:@"yfks_gaizi"];
    [self addSubview:foreImgView];
    self.foreImgView = foreImgView;
    [foreImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(backImgView.mas_height).multipliedBy(0.8);
        make.width.mas_equalTo(foreImgView.mas_height).multipliedBy(0.9);
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-18);
    }];
    
    self.animationView = [YYAnimatedImageView new];
    [self insertSubview:self.animationView belowSubview:foreImgView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(backImgView.mas_height).multipliedBy(0.6);
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-10);
    }];
    
    NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"shaizi_animation" ofType:@"gif"];
    LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
    [imgAnima setAnimatedImageLoopCount:0];
    self.animationView.image = imgAnima;
}

- (void)startAnimation {
    [UIView animateWithDuration:0.5 animations:^{
        self.foreImgView.alpha = 0.0;
        self.foreImgView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];
    self.animationView.hidden = NO;
    [self.animationView startAnimating];
    [LotteryVoiceUtil.shared startPlayAward:@"yaoshaiziaudio"];
}

- (void)stopAnimation {
    self.animationView.hidden = YES;
    [self.animationView stopAnimating];
    [LotteryVoiceUtil.shared stopPlayAward];
    
    NSArray *array = [self.winValue componentsSeparatedByString:@","];
    UIImageView *img1 = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 18, 18)];
    img1.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"shaizi_result_%@",array[0]]];
    UIImageView *img2 = [[UIImageView alloc]initWithFrame:CGRectMake(58, 20, 18, 18)];
    img2.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"shaizi_result_%@",array[1]]];
    UIImageView *img3 = [[UIImageView alloc]initWithFrame:CGRectMake(51, 30, 18, 18)];
    img3.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"shaizi_result_%@",array[2]]];
    
    [self.backImgView addSubview:img1];
    [self.backImgView addSubview:img2];
    [self.backImgView addSubview:img3];
}

- (void)clear {
    [UIView animateWithDuration:0.5 animations:^{
        self.foreImgView.alpha = 1.0;
        self.foreImgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.backImgView removeAllSubviews];
    }];
    self.animationView.hidden = YES;
    [self.animationView stopAnimating];
    [LotteryVoiceUtil.shared stopPlayAward];
}

@end
