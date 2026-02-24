//
//  LotteryBetHallView_SSC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetHallView_SSC.h"
#import "LotteryHallBaseCell.h"

@implementation LotteryBetHallView_SSC

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"总和_大" superKey:@"猜总和"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"总和_小" superKey:@"猜总和"];
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"总和_单" superKey:@"猜总和"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"总和_双" superKey:@"猜总和"];
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"龙" superKey:@"猜龙虎"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"和" superKey:@"猜龙虎"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"虎" superKey:@"猜龙虎"];
    
    UIStackView *stackView1 = [UIStackView new];
    stackView1.spacing = 5;
    stackView1.distribution = UIStackViewDistributionFillEqually;
    [stackView1 addArrangedSubview:betView1];
    [stackView1 addArrangedSubview:betView2];
    [stackView1 addArrangedSubview:betView3];
    [stackView1 addArrangedSubview:betView4];
    [self.betStackView addArrangedSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/5);
    }];
    
    UIStackView *stackView2 = [UIStackView new];
    stackView2.spacing = 5;
    stackView2.distribution = UIStackViewDistributionFillEqually;
    [stackView2 addArrangedSubview:betView5];
    [stackView2 addArrangedSubview:betView6];
    [stackView2 addArrangedSubview:betView7];
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/4);
    }];
    
    self.views = @[betView1, betView2, betView3, betView4, betView5, betView6, betView7];
}

@end
