//
//  PockerView.m
//  翻牌
//
//  Created by 斌 on 2017/4/20.
//  Copyright © 2017年 斌. All rights reserved.
//

#import "PockerView.h"
#import "LotteryVoiceUtil.h"

@implementation PockerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialInstance];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        [self initialInstance];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self initialInstance];
}
- (void)initialInstance{
    self.backgroundColor = [UIColor clearColor];
    // 牌的背面
    self.imgview1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.imgview1.image = [ImageBundle imagewithBundleName:@"poker_bg"];
    [self addSubview:_imgview1];
    self.imgview1.layer.cornerRadius = 2;
    self.imgview1.clipsToBounds = YES;
    
    // 牌的正面
    self.imgview2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.imgview2.layer.cornerRadius = 2;
    self.imgview2.clipsToBounds = YES;
}
- (void)setPokerName:(NSString *)pokerName{
    self.imgview2.image = [ImageBundle imagewithBundleName:pokerName];
}

- (void)showOpenPoker {
    [self.imgview1 removeFromSuperview];
    [self addSubview:self.imgview2];
}

- (void)rotateWithPokerView {
    [UIView beginAnimations:@"aa" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [self.imgview1 removeFromSuperview];
    [self addSubview:self.imgview2];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:NO];
    [UIView commitAnimations];
    
    [LotteryVoiceUtil.shared startPlayHint:@"fanpaiaudio"];
}

- (void)showClosePoker:(CGPoint)point {
    [UIView animateWithDuration:0.5 animations:^{
        self.x = point.x;
        self.y = point.y;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

@end
