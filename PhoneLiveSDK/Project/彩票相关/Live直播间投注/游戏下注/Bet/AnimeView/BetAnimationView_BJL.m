//
//  BetAnimationView_BJL.m
//  phonelive2
//
//  Created by vick on 2024/1/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BetAnimationView_BJL.h"
#import "PockerView.h"
#import "LotteryVoiceUtil.h"

@interface BetAnimationView_BJL ()

@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UIImageView *rightImgView;

@property (nonatomic, strong) UIView *leftBackView1;
@property (nonatomic, strong) UIView *leftBackView2;
@property (nonatomic, strong) UIView *leftBackView3;

@property (nonatomic, strong) UIView *rightBackView1;
@property (nonatomic, strong) UIView *rightBackView2;
@property (nonatomic, strong) UIView *rightBackView3;

@end

@implementation BetAnimationView_BJL

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (UIImageView *)leftImgView {
    if (!_leftImgView) {
        _leftImgView = [UIImageView new];
        _leftImgView.contentMode = UIViewContentModeScaleAspectFit;
        _leftImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"bjl_title_player_img")];
        
        _leftBackView1 = [UIView new];
        [_leftBackView1 vk_border:vkColorRGB(115, 215, 145) cornerRadius:3];
        _leftBackView1.tag = 1010;
        [_leftImgView addSubview:_leftBackView1];
        
        _leftBackView2 = [UIView new];
        [_leftBackView2 vk_border:vkColorRGB(115, 215, 145) cornerRadius:3];
        _leftBackView2.tag = 2010;
        [_leftImgView addSubview:_leftBackView2];
        
        _leftBackView3 = [UIView new];
        [_leftBackView3 vk_border:vkColorRGB(115, 215, 145) cornerRadius:3];
        _leftBackView3.tag = 3010;
        [_leftImgView addSubview:_leftBackView3];
        
        [_leftBackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(-12);
            make.width.mas_equalTo(self.leftBackView2.mas_height);
            make.height.mas_equalTo(self.leftBackView2.mas_width);
        }];
        
        [_leftBackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(self.leftBackView2.mas_height).multipliedBy(0.75);
            make.left.mas_equalTo(self.leftBackView1.mas_right).offset(3);
        }];
        
        [_leftBackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(self.leftBackView2.mas_width);
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(self.leftBackView2.mas_right).offset(3);
        }];
    }
    return _leftImgView;
}

- (UIImageView *)rightImgView {
    if (!_rightImgView) {
        _rightImgView = [UIImageView new];
        _rightImgView.contentMode = UIViewContentModeScaleAspectFit;
        _rightImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"bjl_title_banker_img")];
        
        _rightBackView1 = [UIView new];
        [_rightBackView1 vk_border:vkColorRGB(115, 215, 145) cornerRadius:3];
        _rightBackView1.tag = 4010;
        [_rightImgView addSubview:_rightBackView1];
        
        _rightBackView2 = [UIView new];
        [_rightBackView2 vk_border:vkColorRGB(115, 215, 145) cornerRadius:3];
        _rightBackView2.tag = 5010;
        [_rightImgView addSubview:_rightBackView2];
        
        _rightBackView3 = [UIView new];
        [_rightBackView3 vk_border:vkColorRGB(115, 215, 145) cornerRadius:3];
        _rightBackView3.tag = 6010;
        [_rightImgView addSubview:_rightBackView3];
        
        [_rightBackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(self.rightBackView2.mas_width);
        }];
        
        [_rightBackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(self.rightBackView2.mas_height).multipliedBy(0.75);
            make.left.mas_equalTo(self.rightBackView1.mas_right).offset(3);
        }];
        
        [_rightBackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(12);
            make.left.mas_equalTo(self.rightBackView2.mas_right).offset(3);
            make.width.mas_equalTo(self.rightBackView2.mas_height);
            make.height.mas_equalTo(self.rightBackView2.mas_width);
        }];
    }
    return _rightImgView;
}

- (void)setupView {
    
    [self addSubview:self.leftImgView];
    [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
    }];
    
    [self addSubview:self.rightImgView];
    [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImgView.mas_right).offset(10);
        make.right.top.bottom.mas_equalTo(0);
    }];
}

- (void)startAnimation {
    [self performSelector:@selector(startAddPocker:) withObject:self.leftBackView3 afterDelay:0];
    [self performSelector:@selector(startAddPocker:) withObject:self.rightBackView1 afterDelay:0.5];
    [self performSelector:@selector(startAddPocker:) withObject:self.leftBackView2 afterDelay:1.0];
    [self performSelector:@selector(startAddPocker:) withObject:self.rightBackView2 afterDelay:1.5];
}

- (void)startAddPocker:(UIView *)view {
    CGFloat pHeight = MAX(view.height, view.width) - 2;
    CGFloat pWidth = MIN(view.height, view.width) - 2;
    
    PockerView *pocker = [[PockerView alloc] initWithFrame:CGRectMake(-view.superview.x-40, -40, pWidth, pHeight)];
    pocker.tag = view.tag + 1;
    [view.superview addSubview:pocker];
    [UIView animateWithDuration:0.3 animations:^{
        pocker.center = view.center;
    } completion:nil];
    
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared startPlayHint:@"fapaiaudio"];
}

- (void)stopAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSArray *first = self.winValue.firstObject;
    NSArray *last = self.winValue.lastObject;
    
    [self showPocker:self.leftBackView3 name:first[0]];
    [self showPocker:self.leftBackView2 name:first[1]];
    [self showPocker:self.rightBackView1 name:last[0]];
    [self showPocker:self.rightBackView2 name:last[1]];
    
    /// 需要补牌
    if (first.count >= 3) {
        [self repairPocker:self.leftBackView1 name:first.lastObject];
    }
    if (last.count >= 3) {
        [self repairPocker:self.rightBackView3 name:last.lastObject];
    }
}

/// 补牌
- (void)repairPocker:(UIView *)winView name:(NSString *)winName {
    [self performSelector:@selector(startAddPocker:) withObject:winView afterDelay:1.0];
    vkGcdAfter(1.3, ^{
        PockerView *pocker = [self showPocker:winView name:winName];
        [UIView animateWithDuration:0.5 animations:^{
            pocker.transform = CGAffineTransformMakeRotation(M_PI/2.0);
        } completion:nil];
    });
}

- (PockerView *)showPocker:(UIView *)view name:(NSString *)name {
    PockerView *pocker = [view.superview viewWithTag:view.tag + 1];
    [pocker setPokerName:LotteryPoker(name)];
    [pocker rotateWithPokerView];
    return pocker;
}

- (void)clear {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (PockerView *view in self.leftImgView.subviews) {
        if ([view isKindOfClass:[PockerView class]]) {
            [view showClosePoker:CGPointMake(85, -40)];
        }
    }
    for (PockerView *view in self.rightImgView.subviews) {
        if ([view isKindOfClass:[PockerView class]]) {
            [view showClosePoker:CGPointMake(-45, -40)];
        }
    }
}

@end
