//
//  LotteryBetHallView_YFKS.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryBetHallView_YFKS.h"
#import "LotteryHallBaseCell.h"
#import "LotteryHallDiceCell.h"

@implementation LotteryBetHallView_YFKS

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"总和_大" superKey:@"猜总和"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"总和_小" superKey:@"猜总和"];
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"总和_单" superKey:@"猜总和"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"总和_双" superKey:@"猜总和"];
    
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"总和_4" superKey:@"猜总和"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"总和_5" superKey:@"猜总和"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"总和_6" superKey:@"猜总和"];
    LotteryHallBaseCell *betView8 = [LotteryHallBaseCell.alloc initWithKey:@"总和_7" superKey:@"猜总和"];
    LotteryHallBaseCell *betView9 = [LotteryHallBaseCell.alloc initWithKey:@"总和_8" superKey:@"猜总和"];
    LotteryHallBaseCell *betView10 = [LotteryHallBaseCell.alloc initWithKey:@"总和_9" superKey:@"猜总和"];
    LotteryHallBaseCell *betView11 = [LotteryHallBaseCell.alloc initWithKey:@"总和_10" superKey:@"猜总和"];
    LotteryHallBaseCell *betView12 = [LotteryHallBaseCell.alloc initWithKey:@"总和_11" superKey:@"猜总和"];
    LotteryHallBaseCell *betView13 = [LotteryHallBaseCell.alloc initWithKey:@"总和_12" superKey:@"猜总和"];
    LotteryHallBaseCell *betView14 = [LotteryHallBaseCell.alloc initWithKey:@"总和_13" superKey:@"猜总和"];
    LotteryHallBaseCell *betView15 = [LotteryHallBaseCell.alloc initWithKey:@"总和_14" superKey:@"猜总和"];
    LotteryHallBaseCell *betView16 = [LotteryHallBaseCell.alloc initWithKey:@"总和_15" superKey:@"猜总和"];
    LotteryHallBaseCell *betView17 = [LotteryHallBaseCell.alloc initWithKey:@"总和_16" superKey:@"猜总和"];
    LotteryHallBaseCell *betView18 = [LotteryHallBaseCell.alloc initWithKey:@"总和_17" superKey:@"猜总和"];
    
    LotteryHallDiceCell *betView19 = [LotteryHallDiceCell.alloc initWithKey:@"豹子_1" superKey:@"猜围骰" count:3];
    LotteryHallDiceCell *betView20 = [LotteryHallDiceCell.alloc initWithKey:@"豹子_2" superKey:@"猜围骰" count:3];
    LotteryHallDiceCell *betView21 = [LotteryHallDiceCell.alloc initWithKey:@"豹子_3" superKey:@"猜围骰" count:3];
    LotteryHallBaseCell *betView22 = [LotteryHallBaseCell.alloc initWithKey:@"豹子_1-6" superKey:@"猜围骰"];
    LotteryHallDiceCell *betView23 = [LotteryHallDiceCell.alloc initWithKey:@"豹子_4" superKey:@"猜围骰" count:3];
    LotteryHallDiceCell *betView24 = [LotteryHallDiceCell.alloc initWithKey:@"豹子_5" superKey:@"猜围骰" count:3];
    LotteryHallDiceCell *betView25 = [LotteryHallDiceCell.alloc initWithKey:@"豹子_6" superKey:@"猜围骰" count:3];
    
    LotteryHallDiceCell *betView26 = [LotteryHallDiceCell.alloc initWithKey:@"对子_1" superKey:@"猜对子" count:2];
    LotteryHallDiceCell *betView27 = [LotteryHallDiceCell.alloc initWithKey:@"对子_2" superKey:@"猜对子" count:2];
    LotteryHallDiceCell *betView28 = [LotteryHallDiceCell.alloc initWithKey:@"对子_3" superKey:@"猜对子" count:2];
    LotteryHallDiceCell *betView29 = [LotteryHallDiceCell.alloc initWithKey:@"对子_4" superKey:@"猜对子" count:2];
    LotteryHallDiceCell *betView30 = [LotteryHallDiceCell.alloc initWithKey:@"对子_5" superKey:@"猜对子" count:2];
    LotteryHallDiceCell *betView31 = [LotteryHallDiceCell.alloc initWithKey:@"对子_6" superKey:@"猜对子" count:2];
    
    LotteryHallDiceCell *betView32 = [LotteryHallDiceCell.alloc initWithKey:@"单骰_1" superKey:@"猜单骰" count:1];
    LotteryHallDiceCell *betView33 = [LotteryHallDiceCell.alloc initWithKey:@"单骰_2" superKey:@"猜单骰" count:1];
    LotteryHallDiceCell *betView34 = [LotteryHallDiceCell.alloc initWithKey:@"单骰_3" superKey:@"猜单骰" count:1];
    LotteryHallDiceCell *betView35 = [LotteryHallDiceCell.alloc initWithKey:@"单骰_4" superKey:@"猜单骰" count:1];
    LotteryHallDiceCell *betView36 = [LotteryHallDiceCell.alloc initWithKey:@"单骰_5" superKey:@"猜单骰" count:1];
    LotteryHallDiceCell *betView37 = [LotteryHallDiceCell.alloc initWithKey:@"单骰_6" superKey:@"猜单骰" count:1];
    
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
    [stackView2 addArrangedSubview:betView8];
    [stackView2 addArrangedSubview:betView9];
    [stackView2 addArrangedSubview:betView10];
    [stackView2 addArrangedSubview:betView11];
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView3 = [UIStackView new];
    stackView3.spacing = 5;
    stackView3.distribution = UIStackViewDistributionFillEqually;
    [stackView3 addArrangedSubview:betView12];
    [stackView3 addArrangedSubview:betView13];
    [stackView3 addArrangedSubview:betView14];
    [stackView3 addArrangedSubview:betView15];
    [stackView3 addArrangedSubview:betView16];
    [stackView3 addArrangedSubview:betView17];
    [stackView3 addArrangedSubview:betView18];
    [self.betStackView addArrangedSubview:stackView3];
    [stackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView4 = [UIStackView new];
    stackView4.spacing = 5;
    stackView4.distribution = UIStackViewDistributionFillEqually;
    [stackView4 addArrangedSubview:betView19];
    [stackView4 addArrangedSubview:betView20];
    [stackView4 addArrangedSubview:betView21];
    [stackView4 addArrangedSubview:betView22];
    [stackView4 addArrangedSubview:betView23];
    [stackView4 addArrangedSubview:betView24];
    [stackView4 addArrangedSubview:betView25];
    [self.betStackView addArrangedSubview:stackView4];
    [stackView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/3.3);
    }];
    
    UIStackView *stackView5 = [UIStackView new];
    stackView5.spacing = 5;
    stackView5.distribution = UIStackViewDistributionFillEqually;
    [stackView5 addArrangedSubview:betView26];
    [stackView5 addArrangedSubview:betView27];
    [stackView5 addArrangedSubview:betView28];
    [stackView5 addArrangedSubview:betView29];
    [stackView5 addArrangedSubview:betView30];
    [stackView5 addArrangedSubview:betView31];
    [self.betStackView addArrangedSubview:stackView5];
    [stackView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/4.3);
    }];
    
    UIStackView *stackView6 = [UIStackView new];
    stackView6.spacing = 5;
    stackView6.distribution = UIStackViewDistributionFillEqually;
    [stackView6 addArrangedSubview:betView32];
    [stackView6 addArrangedSubview:betView33];
    [stackView6 addArrangedSubview:betView34];
    [stackView6 addArrangedSubview:betView35];
    [stackView6 addArrangedSubview:betView36];
    [stackView6 addArrangedSubview:betView37];
    [self.betStackView addArrangedSubview:stackView6];
    [stackView6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    self.views = @[betView1, betView2, betView3, betView4, betView5, betView6, betView7, betView8, betView9, betView10, betView11, betView12, betView13, betView14, betView15, betView16, betView17, betView18, betView19, betView20, betView21, betView22, betView23, betView24, betView25, betView26, betView27, betView28, betView29, betView30, betView31, betView32, betView33, betView34, betView35, betView36, betView37];
}

@end
