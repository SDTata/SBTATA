//
//  BetAnimationView_LHC.m
//  phonelive2
//
//  Created by vick on 2023/12/15.
//  Copyright © 2023 toby. All rights reserved.
//

#import "BetAnimationView_LHC.h"
#import "LotteryVoiceUtil.h"

#define kBallViewTag 1000

@interface BetAnimationView_LHC ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property (nonatomic, strong) UIImageView *fanImgView;
@property (nonatomic, strong) UIView *ballContainerView;
@property (nonatomic, strong) UIImageView *bottomImgView;

@property (nonatomic, strong) NSMutableArray *balls;

@end

@implementation BetAnimationView_LHC

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupBallView];
        });
    }
    return self;
}

- (void)dealloc {
    [LotteryVoiceUtil.shared stopPlayAward];
    VKLOG(@"%@ - dealloc", NSStringFromClass(self.class));
}

- (NSMutableArray *)balls {
    if (!_balls) {
        _balls = [NSMutableArray array];
        
        for (NSInteger i=0; i<49; i++) {
            [_balls addObject:[NSString stringWithFormat:@"lhc_%ld", i+1]];
        }
    }
    return _balls;
}

- (void)setupView {
    
    CGFloat height = 140;
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"lhc_bg_3"];
    [self addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(height);
        make.width.mas_equalTo(backImgView.mas_height).multipliedBy(0.9);
    }];
    
    UIImageView *foreImgView = [UIImageView new];
    foreImgView.image = [ImageBundle imagewithBundleName:@"lhc_bg_1"];
    [self addSubview:foreImgView];
    [foreImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(backImgView.mas_width).multipliedBy(0.91);
        make.height.mas_equalTo(foreImgView.mas_width);
    }];
    
    UIImageView *fanImgView = [UIImageView new];
    fanImgView.image = [ImageBundle imagewithBundleName:@"lhc_bg_2"];
    [self insertSubview:fanImgView belowSubview:foreImgView];
    self.fanImgView = fanImgView;
    [fanImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(foreImgView);
        make.width.height.mas_equalTo(foreImgView);
    }];
    
    UIView *ballContainerView = [UIView new];
    [self insertSubview:ballContainerView belowSubview:foreImgView];
    self.ballContainerView = ballContainerView;
    [ballContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(foreImgView);
    }];
    
    UIImageView *bottomImgView = [UIImageView new];
    bottomImgView.image = [ImageBundle imagewithBundleName:@"lhc_bg_4"];
    [self addSubview:bottomImgView];
    self.bottomImgView = bottomImgView;
    [bottomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(bottomImgView.mas_width).multipliedBy(0.13);
        make.width.mas_equalTo(backImgView.mas_width).multipliedBy(0.75);
        make.centerY.mas_equalTo(backImgView.mas_bottom).offset(-height*0.025);
    }];
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.ballContainerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.ballContainerView.layer.cornerRadius = CGRectGetHeight(self.ballContainerView.frame)/2;
    self.ballContainerView.layer.masksToBounds = YES;
}

- (void)setupBallView
{
    for (UIView *view in self.ballContainerView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat ballWidth = 11;
    CGFloat width = CGRectGetWidth(self.ballContainerView.frame);
    for (int i = 0; i < self.balls.count; i++) {
        UIImageView *ballImageView = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:self.balls[i]]];
        ballImageView.frame = CGRectMake(width/2, width/2, ballWidth, ballWidth);
        [self.ballContainerView addSubview:ballImageView];
    }
    
    self.ballContainerView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.ballContainerView.alpha = 1;
    }];
    
    [self stopBallAnimation];
}

- (void)clear {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (UIView *view in self.subviews) {
        if (view.tag >= kBallViewTag) {
            [view removeFromSuperview];
        }
    }
}

/// 结束旋转
- (void)stopAnimation {
    [self showWinBalls];
    
    _weakify(self)
    vkGcdAfter(3.0, ^{
        _strongify(self)
        [self stopBallAnimation];
        [self stopFanAnimation];
        
        [LotteryVoiceUtil.shared stopPlayAward];
    });
}

/// 开始旋转
- (void)startAnimation {
    [self startBallAnimation];
    [self startFanAnimation];
    
    [LotteryVoiceUtil.shared startPlayAward:@"lhc_game"];
}

/// 球号旋转
- (void)startBallAnimation {
    if (self.dynamicAnimator.behaviors.count > 0) {
        [self.dynamicAnimator removeAllBehaviors];
    }
    
    /// 碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:self.ballContainerView.subviews];
    collision.collisionMode = UICollisionBehaviorModeBoundaries;
    collision.translatesReferenceBoundsIntoBoundary = YES;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.ballContainerView.bounds];
    [collision addBoundaryWithIdentifier:@"collisionCircle" forPath:path];
    [self.dynamicAnimator addBehavior:collision];
    
    for (int i = 0; i < self.ballContainerView.subviews.count; i++) {
        /// 推力
        UIPushBehavior *push = [[UIPushBehavior alloc]initWithItems:@[self.ballContainerView.subviews[i]] mode:UIPushBehaviorModeInstantaneous];
        [push setTargetOffsetFromCenter:UIOffsetMake(5 + 5 * i, 0) forItem:self.ballContainerView.subviews[0]];
        /// x正右负左  y正下负上
        push.pushDirection = CGVectorMake(i % 2 == 0 ? 1 : -1, -1);
        push.angle = M_PI / self.ballContainerView.subviews.count * (arc4random() % 6);
        push.magnitude = 0.05;
        push.active = YES;
        [self.dynamicAnimator addBehavior:push];
    }
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:self.ballContainerView.subviews];
    item.elasticity = 1.0;
    [self.dynamicAnimator addBehavior:item];
}

/// 球号停止
- (void)stopBallAnimation {
    if (self.dynamicAnimator.behaviors.count > 0) {
        [self.dynamicAnimator removeAllBehaviors];
    }
    
    /// 重力
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:self.ballContainerView.subviews];
    gravity.magnitude = 0.1;
    [self.dynamicAnimator addBehavior:gravity];
    
    /// 碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:self.ballContainerView.subviews];
    collision.collisionMode = UICollisionBehaviorModeEverything;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.ballContainerView.bounds];
    [collision addBoundaryWithIdentifier:@"collisionCircle" forPath:path];
    [self.dynamicAnimator addBehavior:collision];
    
    UIDynamicItemBehavior *item = [[UIDynamicItemBehavior alloc] initWithItems:self.ballContainerView.subviews];
    item.elasticity = 0.1;
    [self.dynamicAnimator addBehavior:item];
}

/// 风扇旋转
- (void)startFanAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    animation.duration = 2;
    animation.repeatCount = HUGE_VALF;
    [self.fanImgView.layer addAnimation:animation forKey:@"rotationAnimation"];
}

/// 风扇停止
- (void)stopFanAnimation {
    [self.fanImgView.layer removeAllAnimations];
}

/// 添加赢球号码
- (void)showWinBalls {
    NSArray *balls = [self.winValue componentsSeparatedByString:@","];
    for (NSInteger i=0; i<balls.count; i++) {
        NSString *ball = balls[i];
        UIImageView *ballImageView = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc_%ld", ball.integerValue]]];
        ballImageView.tag = kBallViewTag + i;
        [self insertSubview:ballImageView belowSubview:self.ballContainerView];
        [ballImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(12);
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(self.ballContainerView.mas_bottom);
        }];
        [self performSelector:@selector(startBallScroll:) withObject:ballImageView afterDelay:0.4 * i];
    }
}

/// 球号滚到底部
- (void)startBallScroll:(UIView *)ballImageView {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [ballImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bottomImgView.mas_left).offset(2);
            make.bottom.mas_equalTo(self.bottomImgView.mas_bottom).offset(-2);
            make.width.height.mas_equalTo(12);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSInteger index = ballImageView.tag - kBallViewTag;
        CGFloat offset = index * 11 + 2;
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [ballImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.bottomImgView.mas_right).offset(-offset);
                make.bottom.mas_equalTo(self.bottomImgView.mas_bottom).offset(-2);
                make.width.height.mas_equalTo(12);
            }];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }];
}

@end
