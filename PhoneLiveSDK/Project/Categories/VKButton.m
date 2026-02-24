//
//  VKButton.m
//  phonelive2
//
//  Created by vick on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKButton.h"

const CGFloat VKButtonCornerRadiusAdjustsBounds = -1;

@implementation VKButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imagePosition = VKButtonImagePositionLeft;
        self.spacingBetweenImage = 5;
        self.imageSize = CGSizeZero;
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self setNeedsLayout];
}

- (void)setSpacingBetweenImage:(CGFloat)spacingBetweenImage {
    _spacingBetweenImage = spacingBetweenImage;
    [self setNeedsLayout];
}

- (void)setImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    [self setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
                        bounds.origin.y - touchAreaInsets.top,
                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.cornerRadius == VKButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
    } else if (self.cornerRadius > 0) {
        self.layer.cornerRadius = self.cornerRadius;
    }
    
    if (CGSizeEqualToSize(CGSizeZero, self.imageSize)) {
        [self.imageView sizeToFit];
    } else {
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                          self.imageView.frame.origin.y,
                                          self.imageSize.width,
                                          self.imageSize.height);
    }
    [self.titleLabel sizeToFit];
    
    switch (self.imagePosition) {
        case VKButtonImagePositionLeft:
            [self layoutHorizontalWithLeftView:self.imageView rightView:self.titleLabel];
            break;
        case VKButtonImagePositionRight:
            [self layoutHorizontalWithLeftView:self.titleLabel rightView:self.imageView];
            break;
        case VKButtonImagePositionTop:
            [self layoutVerticalWithUpView:self.imageView downView:self.titleLabel];
            break;
        case VKButtonImagePositionBottom:
            [self layoutVerticalWithUpView:self.titleLabel downView:self.imageView];
            break;
        default:
            break;
    }
}

- (void)layoutHorizontalWithLeftView:(UIView *)leftView rightView:(UIView *)rightView {
    CGRect leftViewFrame = leftView.frame;
    CGRect rightViewFrame = rightView.frame;
    
    CGFloat totalWidth = CGRectGetWidth(leftViewFrame) + self.spacingBetweenImage + CGRectGetWidth(rightViewFrame);
    
    leftViewFrame.origin.x = (CGRectGetWidth(self.frame) - totalWidth) / 2.0;
    leftViewFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(leftViewFrame)) / 2.0;
    leftView.frame = leftViewFrame;
    
    rightViewFrame.origin.x = CGRectGetMaxX(leftViewFrame) + self.spacingBetweenImage;
    rightViewFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(rightViewFrame)) / 2.0;
    rightView.frame = rightViewFrame;
}

- (void)layoutVerticalWithUpView:(UIView *)upView downView:(UIView *)downView {
    CGRect upViewFrame = upView.frame;
    CGRect downViewFrame = downView.frame;
    
    CGFloat totalHeight = CGRectGetHeight(upViewFrame) + self.spacingBetweenImage + CGRectGetHeight(downViewFrame);
    
    upViewFrame.origin.y = (CGRectGetHeight(self.frame) - totalHeight) / 2.0 + 2;
    upViewFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(upViewFrame)) / 2.0;
    upView.frame = upViewFrame;
    
    downViewFrame.origin.y = CGRectGetMaxY(upViewFrame) + self.spacingBetweenImage;
    downViewFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(downViewFrame)) / 2.0;
    downView.frame = downViewFrame;
}

@end
