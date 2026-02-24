//
//  LotteryResultView_NN.h
//  phonelive2
//
//  Created by vick on 2023/11/21.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NNLotteryResultType) {
    NNLotteryResultTypeLeft,
    NNLotteryResultTypeRight
};

@interface LotteryResultView_NN : UIView

@property (nonatomic, assign) NNLotteryResultType type;

/// 发牌起点
@property (nonatomic, assign) CGFloat startX;

/// 输赢状态
@property (nonatomic, assign) BOOL selected;

/// 结果
@property (nonatomic, copy) NSString *result;

/// 开牌结果
@property (nonatomic, strong) NSArray *pockers;

/// 初始化
- (void)setupPockerView;

/// 发牌动画
- (void)showPockerAnimation;

/// 收牌动画
- (void)hidePockerAnimation;

/// 开牌动画
- (void)openPockerAnimation;

/// 开牌无动画
- (void)openPocker;

@end
