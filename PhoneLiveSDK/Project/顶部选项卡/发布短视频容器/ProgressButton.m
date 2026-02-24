//
//  ProgressButton.m
//  phonelive2
//
//  Created by vick on 2024/12/7.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ProgressButton.h"

@interface ProgressButton ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation ProgressButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProgressLayer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupProgressLayer];
    }
    return self;
}

- (void)setupProgressLayer {
    // 创建进度条的图层
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.strokeColor = RGB(50, 4, 56).CGColor; // 进度条颜色
    self.progressLayer.fillColor = [UIColor grayColor].CGColor; // 填充色
    self.progressLayer.lineWidth = self.bounds.size.height; // 进度条的宽度等于按钮高度
    self.progressLayer.strokeEnd = 0; // 初始进度为 0
    [self.layer insertSublayer:self.progressLayer atIndex:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置进度条路径为从左到右的直线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height / 2)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height / 2)];
    self.progressLayer.lineWidth = self.bounds.size.height; // 进度条的宽度等于按钮高度
    self.progressLayer.path = path.CGPath;
}

- (void)setProgress:(CGFloat)progress {
    [self.layer insertSublayer:self.progressLayer atIndex:0];
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    // 限制进度在 0.0 ~ 1.0
    progress = MIN(MAX(progress, 0.0), 1.0);
    
    _progress = progress;
    
    // 更新进度条
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(self.progressLayer.strokeEnd);
        animation.toValue = @(progress);
        animation.duration = 0.25;
        self.progressLayer.strokeEnd = progress;
        [self.progressLayer addAnimation:animation forKey:@"progressAnimation"];
    } else {
        self.progressLayer.strokeEnd = progress;
    }
}


@end
