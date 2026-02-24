//
//  SCCarView.h
//  phonelive2
//
//  Created by vick on 2023/12/19.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCCarView : UIView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat releaseX;

- (instancetype)initWithIndex:(NSInteger)index;

/// 开始动画
- (void)speedStartAnimation;

/// 停止动画
- (void)speedStopAnimation;

/// 加速动画
- (void)speedUpAnimation;

/// 减速动画
- (void)speedDownAnimation;

@end
