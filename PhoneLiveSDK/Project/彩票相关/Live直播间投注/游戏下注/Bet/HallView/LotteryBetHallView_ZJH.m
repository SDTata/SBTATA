//
//  LotteryBetHallView_ZJH.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryBetHallView_ZJH.h"
#import "LotteryHallBaseCell.h"

@implementation LotteryBetHallView_ZJH

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"猜胜负_玩家一" superKey:@"炸金花"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"猜胜负_玩家二" superKey:@"炸金花"];
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"猜胜负_玩家三" superKey:@"炸金花"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"牌型_豹子" superKey:@"炸金花"];
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"牌型_同花顺" superKey:@"炸金花"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"牌型_同花" superKey:@"炸金花"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"牌型_顺子" superKey:@"炸金花"];
    
    UIStackView *stackView1 = [UIStackView new];
    stackView1.spacing = 5;
    stackView1.distribution = UIStackViewDistributionFillEqually;
    [stackView1 addArrangedSubview:betView1];
    [stackView1 addArrangedSubview:betView2];
    [stackView1 addArrangedSubview:betView3];
    [self.betStackView addArrangedSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/4);
    }];
    
    UIStackView *stackView2 = [UIStackView new];
    stackView2.spacing = 5;
    stackView2.distribution = UIStackViewDistributionFillEqually;
    [stackView2 addArrangedSubview:betView4];
    [stackView2 addArrangedSubview:betView5];
    [stackView2 addArrangedSubview:betView6];
    [stackView2 addArrangedSubview:betView7];
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/5);
    }];
    
    self.views = @[betView1, betView2, betView3, betView4, betView5, betView6, betView7];
}

@end
