//
//  ProgressButton.h
//  phonelive2
//
//  Created by vick on 2024/12/7.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressButton : UIButton

/// 当前进度（0.0 ~ 1.0）
@property (nonatomic, assign) CGFloat progress;

/// 设置进度动画
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
