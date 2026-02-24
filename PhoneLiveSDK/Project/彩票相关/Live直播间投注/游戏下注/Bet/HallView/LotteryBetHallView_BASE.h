//
//  LotteryBetHallView_BASE.h
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryBetModel.h"
#import "BetListModel.h"

@interface LotteryBetHallView_BASE : UIView

@property (nonatomic, strong) UIStackView *betStackView;

/// 投注选项
@property (nonatomic, strong) NSArray *views;

/// 彩种信息
@property (nonatomic, strong) LotteryBetModel *betModel;

/// 选中筹码
@property (nonatomic, strong) ChipsModel *chipModel;

/// 投注成功回调
@property (nonatomic, copy) VKBlock clickBetBlock;

+ (instancetype)createWithType:(NSInteger)type;

- (void)setupView;

/// 开始投注，清空所有筹码
- (void)doStart;

/// 结束投注，清空未确认筹码
- (void)doStop;

/// 开奖通知，播放开奖动画
- (void)doWin:(NSDictionary *)wins;

/// 续投
- (void)doContinue;

/// 投注记录续投
- (void)doContinue:(BetListDataModel *)model;

@end
