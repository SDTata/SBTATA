//
//  LotteryBetResultePopView.m
//  phonelive2
//
//  Created by lucas on 2021/11/1.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LotteryBetResultePopView.h"

#define perSection    M_PI*2/37

@interface LotteryBetResultePopView ()<CAAnimationDelegate>
@property (nonatomic,strong) UIImageView * imgV;
@property (nonatomic,strong) UIImageView * ballImgV;

@end

@implementation LotteryBetResultePopView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgV = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"game_desk_zp_big"]];
        self.imgV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.imgV];
        
        self.ballImgV = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"zp_ball"]];
        self.ballImgV.frame = CGRectMake(self.frame.size.width/2 - 5, 40, 10, 10);
        [self addSubview:self.ballImgV];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
//
    CGFloat start = - M_PI/2 - 2.5 * perSection;
    CGFloat angle = 5 * perSection;
    CGFloat end = start + angle;
    UIBezierPath *pathL = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)
                                                        radius:150
                                                    startAngle:start
                                                      endAngle:end
                                                     clockwise:YES];
    [pathL addLineToPoint:CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)];
    [pathL closePath];

    CAShapeLayer *slayerL = [CAShapeLayer layer];
    slayerL.path = pathL.CGPath;
    slayerL.fillColor = [UIColor redColor].CGColor;
    slayerL.strokeColor = [UIColor redColor].CGColor;
    slayerL.lineCap = kCALineCapButt;
    self.layer.mask = slayerL;

}

-(void)animationWithSelectonIndex:(NSInteger)index{
    
    [self backToStartPosition];
//    int x = arc4random() % 37;
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    layer.toValue = @(M_PI* 4 - perSection*index);
    layer.duration = 2;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    layer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    layer.delegate = self;
    [self.imgV.layer addAnimation:layer forKey:nil];
    
}

-(void)backToStartPosition{
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    layer.toValue = @(0);
    layer.duration = 0.001;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    [self.imgV.layer addAnimation:layer forKey:nil];
}

@end
