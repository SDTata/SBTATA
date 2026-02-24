//
//  GradientProgressView.m
//  phonelive2
//
//  Created by s5346 on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GradientProgressView.h"

@interface GradientProgressView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GradientProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.progressTintColor = RGB_COLOR(@"#999999", 0.3);
        [self setupGradientLayer];
    }
    return self;
}

- (void)setupGradientLayer {
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    self.gradientLayer.colors = @[(id)RGB_COLOR(@"#bb67ff", 1).CGColor, (id)RGB_COLOR(@"#d6a9ff", 1).CGColor];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    self.gradientLayer.mask = self.layer.mask;

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:2.5].CGPath;
    self.gradientLayer.mask = maskLayer;

    [self.layer addSublayer:self.gradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;
    rect.size.width = rect.size.width * self.progress;
    self.gradientLayer.frame = rect;

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.5].CGPath;
    self.gradientLayer.mask = maskLayer;
}

- (void)progress:(CGFloat)progress {
    self.progress = progress;
    CGRect rect = self.bounds;
    rect.size.width = rect.size.width * progress;
    self.gradientLayer.frame = rect;
}

@end
