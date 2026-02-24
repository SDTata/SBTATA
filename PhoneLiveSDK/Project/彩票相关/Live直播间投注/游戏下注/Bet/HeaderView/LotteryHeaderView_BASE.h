//
//  LotteryHeaderView_BASE.h
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryCodePopView_Base.h"
#import "LotteryBetModel.h"

@interface LotteryHeaderView_BASE : UIView

@property (nonatomic, strong) LotteryCodeView_Base *codeView;

@property (nonatomic, strong) LotteryCodePopView_Base *popCodeView;

@property (nonatomic, strong) UIButton *gameNameButton;

@property (nonatomic, strong) LotteryBetModel *betModel;

@property (nonatomic, assign) NSInteger lotteryType;

@property (nonatomic, assign) NSUInteger showAnimateTime;

@property (nonatomic, strong) NSArray *showKeys;

/// 走势图值
@property (nonatomic, copy) NSString *chartValue;

+ (instancetype)createWithType:(NSInteger)type;

- (void)setupView;

/// 开始投注，清空动画
- (void)doStart;

/// 结束投注，播放开始动画
- (void)doStop;

/// 提前播放动画
- (void)doPreAnimate;

/// 开奖通知，播放开奖动画
- (void)doWin:(NSDictionary *)win;

@end
