//
//  CustomRoundedBlurView.m
//  phonelive2
//
//  Created by user on 2023/12/4.
//  Copyright © 2023 toby. All rights reserved.
//

#import "CustomRoundedBlurView.h"

@implementation CustomRoundedBlurView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 添加模糊效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.alpha = 0.5f;
        blurView.frame = self.bounds;
        [self addSubview:blurView];
        
        // 裁剪到左上和右上圓角
        UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;
        CGSize radii = CGSizeMake(15.0, 15.0);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radii];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        
        blurView.layer.mask = maskLayer;
    }
    return self;
}


@end
