//
//  BetAnimationView_LH.m
//  phonelive2
//
//  Created by vick on 2024/1/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BetAnimationView_LH.h"
#import "PockerView.h"
#import "LotteryVoiceUtil.h"

@interface BetAnimationView_LH ()

@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UIImageView *rightImgView;

@end

@implementation BetAnimationView_LH

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    UIImageView *leftImgView = [UIImageView new];
    leftImgView.contentMode = UIViewContentModeScaleAspectFit;
    [leftImgView vk_border:vkColorRGB(115, 215, 145) cornerRadius:5];
    leftImgView.layer.masksToBounds = NO;
    leftImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"lh_title_dragon_img")];
    [self addSubview:leftImgView];
    self.leftImgView = leftImgView;
    [leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.left.top.bottom.mas_equalTo(0);
    }];
    
    UIImageView *rightImgView = [UIImageView new];
    rightImgView.contentMode = UIViewContentModeScaleAspectFit;
    [rightImgView vk_border:vkColorRGB(115, 215, 145) cornerRadius:5];
    rightImgView.layer.masksToBounds = NO;
    rightImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"lh_title_tiger_img")];
    [self addSubview:rightImgView];
    self.rightImgView = rightImgView;
    [rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(leftImgView);
        make.left.mas_equalTo(leftImgView.mas_right).offset(10);
        make.right.mas_equalTo(0);
    }];
}

- (void)startAnimation {
    [self performSelector:@selector(startAddPocker:) withObject:self.leftImgView afterDelay:0];
    [self performSelector:@selector(startAddPocker:) withObject:self.rightImgView afterDelay:1.0];
}

- (void)startAddPocker:(UIView *)view {
    CGFloat pHeight = view.height;
    CGFloat pWidth = pHeight * 0.8;
    CGFloat x = (view.width - pWidth) / 2;
    
    PockerView *pocker = [[PockerView alloc] initWithFrame:CGRectMake(-view.x-40, -40, pWidth, pHeight)];
    [view addSubview:pocker];
    [UIView animateWithDuration:0.5 animations:^{
        pocker.x = x;
        pocker.y = 0;
    } completion:nil];
    
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared startPlayHint:@"fapaiaudio"];
}

- (void)stopAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSArray *winWays = [self.winValue componentsSeparatedByString:@","];
    for (PockerView *pocker in self.leftImgView.subviews) {
        [pocker setPokerName:LotteryPoker(winWays.firstObject)];
        [pocker rotateWithPokerView];
    }
    for (PockerView *pocker in self.rightImgView.subviews) {
        [pocker setPokerName:LotteryPoker(winWays.lastObject)];
        [pocker rotateWithPokerView];
    }
}

- (void)clear {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (PockerView *view in self.leftImgView.subviews) {
        [view showClosePoker:CGPointMake(75, -40)];
    }
    for (PockerView *view in self.rightImgView.subviews) {
        [view showClosePoker:CGPointMake(-35, -40)];
    }
}

@end
