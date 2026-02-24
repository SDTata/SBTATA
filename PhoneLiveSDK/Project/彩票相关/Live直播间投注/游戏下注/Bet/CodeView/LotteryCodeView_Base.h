//
//  LotteryCodeView_Base.h
//  phonelive2
//
//  Created by vick on 2023/12/1.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryBetModel.h"
#import "BallListView.h"

@interface LotteryCodeView_Base : UIView

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) BallListView *codeListView;

@property (nonatomic, strong) BallListView *textListView;

/// 开奖结果
@property (nonatomic, strong) LotteryResultModel *resultModel;

/// 开奖通知
@property (nonatomic, strong) NSDictionary *resultDict;

/// 内边距
@property (nonatomic, assign) UIEdgeInsets inset;

/// 根据游戏类型创建
+ (instancetype)createWithType:(NSInteger)type;

- (void)setupView;

/// 拦截号码处理
- (NSArray *)setupCodes:(NSArray *)codes;

/// 拦截结果处理
- (NSArray *)setupTexts:(NSArray *)texts;

@end
