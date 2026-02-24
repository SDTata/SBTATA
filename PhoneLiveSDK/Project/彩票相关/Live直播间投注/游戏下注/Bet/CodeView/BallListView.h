//
//  BallListView.h
//  phonelive2
//
//  Created by vick on 2025/2/14.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallView.h"

@interface BallListView : UIStackView

/// 号码尺寸，默认14
@property (nonatomic, assign) CGSize size;

/// 设置号码
@property (nonatomic, strong) NSArray *codes;

/// 配置样式
@property (nonatomic, copy) void (^setupStyleBlock)(BallView *ballView);

@end
