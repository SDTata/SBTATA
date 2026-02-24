//
//  ShortVideoFavoriteView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "ShortVideoFavoriteView.h"

static const NSInteger kFavoriteViewLikeBeforeTag  = 0x01;
static const NSInteger kFavoriteViewLikeAfterTag   = 0x02;

@interface ShortVideoFavoriteView ()

@end

@implementation ShortVideoFavoriteView

//- (instancetype)init {
//    return [self initWithFrame:CGRectMake(0, 0, 50, 45)];
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.touchExtendInsets, UIEdgeInsetsZero) || !self.userInteractionEnabled || self.hidden || self.alpha == 0) {
        return [super pointInside:point withEvent:event];
    }

    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.touchExtendInsets);
    return CGRectContainsPoint(hitFrame, point);
}

- (BOOL)isLike {
    return self.favoriteAfter.isHidden == NO;
}
- (void)like:(BOOL)isLike {
    self.favoriteAfter.hidden = !isLike;
}

- (void)showLikeAnimation {
    [self startLikeAnim:YES];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.enable = YES;
        _favoriteBefore = [[UIImageView alloc]initWithFrame:frame];
        _favoriteBefore.contentMode = UIViewContentModeCenter;
        _favoriteBefore.image = [ImageBundle imagewithBundleName:@"ShortVideoLoveIcon"];
        _favoriteBefore.userInteractionEnabled = YES;
        _favoriteBefore.tag = kFavoriteViewLikeBeforeTag;
        [_favoriteBefore addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        [self addSubview:_favoriteBefore];
        [_favoriteBefore mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        _favoriteAfter = [[UIImageView alloc]initWithFrame:frame];
        _favoriteAfter.contentMode = UIViewContentModeCenter;
        _favoriteAfter.image = [ImageBundle imagewithBundleName:@"ShortVideoLoveOnIcon"];
        _favoriteAfter.userInteractionEnabled = YES;
        _favoriteAfter.tag = kFavoriteViewLikeAfterTag;
        [_favoriteAfter setHidden:YES];
        [_favoriteAfter addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        [self addSubview:_favoriteAfter];
        [_favoriteAfter mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoHandle)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)autoHandle {
    if (self.favoriteAfter.isHidden) {
        [self startLikeAnim:YES];
    } else {
        [self startLikeAnim:NO];
    }
}

- (void)handleGesture:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case kFavoriteViewLikeBeforeTag: {
            [self startLikeAnim:YES];
            break;
        }
        case kFavoriteViewLikeAfterTag: {
            [self startLikeAnim:NO];
            break;
        }
    }
}

-(void)startLikeAnim:(BOOL)isLike {
    if (!self.enable) {
        return;
    }
    self.enable = NO;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        self.enable = YES;
    });
    if (self.tapLikeblock) {
        self.tapLikeblock(isLike);
    }
    
    _favoriteBefore.userInteractionEnabled = NO;
    _favoriteAfter.userInteractionEnabled = NO;
    if(isLike) {
        CGFloat length = 30;
        CGFloat duration = 0.5;
        for(int i=0;i<6;i++) {
            CAShapeLayer *layer = [[CAShapeLayer alloc]init];
            layer.position = _favoriteBefore.center;
            layer.fillColor = RGB_COLOR(@"#F12F54", 1).CGColor; //RGBA(241.0, 47.0, 84.0, 1.0)

            UIBezierPath *startPath = [UIBezierPath bezierPath];
            [startPath moveToPoint:CGPointMake(-2, -length)];
            [startPath addLineToPoint:CGPointMake(2, -length)];
            [startPath addLineToPoint:CGPointMake(0, 0)];
            
            UIBezierPath *endPath = [UIBezierPath bezierPath];
            [endPath moveToPoint:CGPointMake(-2, -length)];
            [endPath addLineToPoint:CGPointMake(2, -length)];
            [endPath addLineToPoint:CGPointMake(0, -length)];

            layer.path = startPath.CGPath;
            layer.transform = CATransform3DMakeRotation(M_PI / 3.0f * i, 0.0, 0.0, 1.0);
            [self.layer addSublayer:layer];
            
            CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
            group.removedOnCompletion = NO;
            group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            group.fillMode = kCAFillModeForwards;
            group.duration = duration;
            
            CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnim.fromValue = @(0.0);
            scaleAnim.toValue = @(1.0);
            scaleAnim.duration = duration * 0.2f;
            
            CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            pathAnim.fromValue = (__bridge id)layer.path;
            pathAnim.toValue = (__bridge id)endPath.CGPath;
            pathAnim.beginTime = duration * 0.2f;
            pathAnim.duration = duration * 0.8f;
            
            [group setAnimations:@[scaleAnim, pathAnim]];
            [layer addAnimation:group forKey:nil];
        }
        [_favoriteAfter setHidden:NO];
        _favoriteAfter.alpha = 0.0f;
        _favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI/3*2), 0.5f, 0.5f);
        [UIView animateWithDuration:0.4f
                              delay:0.2f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.favoriteBefore.alpha = 0.0f;
                             self.favoriteAfter.alpha = 1.0f;
                             self.favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
                         }
                         completion:^(BOOL finished) {
                             self.favoriteBefore.alpha = 1.0f;
                             self.favoriteBefore.userInteractionEnabled = YES;
                             self.favoriteAfter.userInteractionEnabled = YES;
                         }];
    }else {
        _favoriteAfter.alpha = 1.0f;
        _favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
        [UIView animateWithDuration:0.35f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_4), 0.1f, 0.1f);
                         }
                         completion:^(BOOL finished) {
                             [self.favoriteAfter setHidden:YES];
                             self.favoriteBefore.userInteractionEnabled = YES;
                             self.favoriteAfter.userInteractionEnabled = YES;
            self.favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
                         }];
    }
}

- (void)resetView {
    [_favoriteBefore setHidden:NO];
    [_favoriteAfter setHidden:YES];
    [self.layer removeAllAnimations];
}

@end
