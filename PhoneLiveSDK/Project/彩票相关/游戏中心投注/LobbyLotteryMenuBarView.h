//
//  LobbyLotteryMenuBarView.h
//  phonelive2
//
//  Created by user on 2023/12/19.
//  Copyright © 2023 toby. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LotteryBetModel.h"
#import "ChartView.h"
#import "LotteryCodeView_Base.h"

@interface LobbyLotteryMenuBarView : UIView

@property (nonatomic, strong) LotteryCodeView_Base *codeView;

@property (nonatomic, strong) ChartView *chartView;

@property (nonatomic, assign) BOOL canClosed;

@property (nonatomic, strong) LotteryBetModel *betModel;

@property (nonatomic, copy) void (^clickActionBlock)(NSInteger index);

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *timeTitleLabel;

@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;

- (instancetype)initWithType:(NSInteger)lotteryType;
- (void)setIconAndName:(NSString *)iconUrl withName: (NSString *)lotteryName;
@end


