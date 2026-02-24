//
//  LotteryMenuBarView.h
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryBetModel.h"
#import "ChartView.h"
#import "BetListModel.h"

@interface LotteryMenuBarView : UIView

@property (nonatomic, strong) ChartView *chartView;

@property (nonatomic, assign) BOOL canClosed;

@property (nonatomic, strong) LotteryBetModel *betModel;

@property (nonatomic, copy) void (^clickActionBlock)(NSInteger index);

@property (nonatomic, copy) void (^clickContinueBlock)(BetListDataModel *model);

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (instancetype)initWithType:(NSInteger)lotteryType viewStyle:(NSInteger)viewStyle;

/// 刷新投注记录
- (void)refreshBetRecord;

/// 刷新开奖历史
- (void)refreshOpenHistory;

@end
