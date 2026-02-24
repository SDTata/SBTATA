//
//  FocusView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "FocusView.h"

@interface FocusView ()<CAAnimationDelegate>

@end

@implementation FocusView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 16, 16)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled || self.hidden || self.alpha <= 0.01) {
        return nil;
    }

    CGRect touchRect = CGRectInset(self.bounds, -12, -12);

    if (CGRectContainsPoint(touchRect, point)) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.backgroundColor = RGB_COLOR(@"#F251BB", 1).CGColor;
        self.image = [ImageBundle imagewithBundleName:@"AvatarAddIcon"];
        self.contentMode = UIViewContentModeCenter;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginAnimation)]];
    }
    return self;
}

-(void)beginAnimation {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.duration = 1.25f;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnim setValues:@[
                           [NSNumber numberWithFloat:1.0f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:0.0f]]];
    
    CAKeyframeAnimation *rotationAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    [rotationAnim setValues:@[
                              [NSNumber numberWithFloat:-1.5f*M_PI],
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.0f]]];
    
    CAKeyframeAnimation * opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    [opacityAnim setValues:@[
                             [NSNumber numberWithFloat:0.8f],
                             [NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:1.0f]]];
    
    [animationGroup setAnimations:@[scaleAnim,
                                    rotationAnim,
                                    opacityAnim]];
    [self.layer addAnimation:animationGroup forKey:nil];
}


- (void)animationDidStart:(CAAnimation *)anim {
    self.userInteractionEnabled = NO;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.layer.backgroundColor = RGB_COLOR(@"#F251BB", 1).CGColor;
    self.image = [ImageBundle imagewithBundleName:@"ShortVideoAddAvatarDone"];
    if (self.tapAddblock) {
        self.tapAddblock(YES);
    }
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeCenter;
    [self setHidden:YES];
}


- (void)resetView {
    self.layer.backgroundColor = RGB_COLOR(@"#F251BB", 1).CGColor;
    self.image = [ImageBundle imagewithBundleName:@"AvatarAddIcon"];
    [self.layer removeAllAnimations];
    [self setHidden:NO];
}

@end
