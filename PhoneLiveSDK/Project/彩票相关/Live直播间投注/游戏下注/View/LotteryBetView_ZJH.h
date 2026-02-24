//
//  LotteryBetView_ZJH.h
//  phonelive2
//
//  Created by vick on 2023/11/17.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryBetView.h"

typedef NS_ENUM(NSInteger, ZJHLotteryBetViewType) {
    ZJHLotteryBetViewTypeLeft,
    ZJHLotteryBetViewTypeCenter,
    ZJHLotteryBetViewTypeRight
};

@interface LotteryBetView_ZJH : UIView

@property (nonatomic, strong) UIView *areaView;

@property (nonatomic, assign) ZJHLotteryBetViewType type;

@property (nonatomic, assign) BOOL selected;

/// 发牌起点
@property (nonatomic, assign) CGFloat startX;

/// 结果
@property (nonatomic, copy) NSString *result;

/// 开牌结果
@property (nonatomic, strong) NSArray *pockers;

- (void)showPockerAnimation;

- (void)hidePockerAnimation;

- (void)openPockerAnimation;

- (void)openPocker;

@end
