//
//  LotteryBetHallView_ZP.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryBetHallView_ZP.h"
#import "LotteryHallColorCell.h"

@implementation LotteryBetHallView_ZP

- (void)setupView {
    [super setupView];
    
    LotteryHallColorCell *betView1 = [LotteryHallColorCell.alloc initWithKey:@"点数_大" superKey:@"轮盘" type:0];
    LotteryHallColorCell *betView2 = [LotteryHallColorCell.alloc initWithKey:@"点数_小" superKey:@"轮盘" type:0];
    LotteryHallColorCell *betView3 = [LotteryHallColorCell.alloc initWithKey:@"颜色_红色" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView4 = [LotteryHallColorCell.alloc initWithKey:@"颜色_黑色" superKey:@"轮盘" type:2];
    
    LotteryHallColorCell *betView5 = [LotteryHallColorCell.alloc initWithKey:@"点数_1-12" superKey:@"轮盘" type:0];
    LotteryHallColorCell *betView6 = [LotteryHallColorCell.alloc initWithKey:@"点数_13-24" superKey:@"轮盘" type:0];
    LotteryHallColorCell *betView7 = [LotteryHallColorCell.alloc initWithKey:@"点数_25-36" superKey:@"轮盘" type:0];
    
    LotteryHallColorCell *betView8 = [LotteryHallColorCell.alloc initWithKey:@"点数_0" superKey:@"轮盘" type:3];
    
    LotteryHallColorCell *betView9 = [LotteryHallColorCell.alloc initWithKey:@"点数_1" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView10 = [LotteryHallColorCell.alloc initWithKey:@"点数_2" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView11 = [LotteryHallColorCell.alloc initWithKey:@"点数_3" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView12 = [LotteryHallColorCell.alloc initWithKey:@"点数_4" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView13 = [LotteryHallColorCell.alloc initWithKey:@"点数_5" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView14 = [LotteryHallColorCell.alloc initWithKey:@"点数_6" superKey:@"轮盘" type:2];
    
    LotteryHallColorCell *betView15 = [LotteryHallColorCell.alloc initWithKey:@"点数_7" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView16 = [LotteryHallColorCell.alloc initWithKey:@"点数_8" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView17 = [LotteryHallColorCell.alloc initWithKey:@"点数_9" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView18 = [LotteryHallColorCell.alloc initWithKey:@"点数_10" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView19 = [LotteryHallColorCell.alloc initWithKey:@"点数_11" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView20 = [LotteryHallColorCell.alloc initWithKey:@"点数_12" superKey:@"轮盘" type:1];
    
    LotteryHallColorCell *betView21 = [LotteryHallColorCell.alloc initWithKey:@"点数_13" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView22 = [LotteryHallColorCell.alloc initWithKey:@"点数_14" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView23 = [LotteryHallColorCell.alloc initWithKey:@"点数_15" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView24 = [LotteryHallColorCell.alloc initWithKey:@"点数_16" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView25 = [LotteryHallColorCell.alloc initWithKey:@"点数_17" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView26 = [LotteryHallColorCell.alloc initWithKey:@"点数_18" superKey:@"轮盘" type:1];
    
    LotteryHallColorCell *betView27 = [LotteryHallColorCell.alloc initWithKey:@"点数_19" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView28 = [LotteryHallColorCell.alloc initWithKey:@"点数_20" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView29 = [LotteryHallColorCell.alloc initWithKey:@"点数_21" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView30 = [LotteryHallColorCell.alloc initWithKey:@"点数_22" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView31 = [LotteryHallColorCell.alloc initWithKey:@"点数_23" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView32 = [LotteryHallColorCell.alloc initWithKey:@"点数_24" superKey:@"轮盘" type:2];
    
    LotteryHallColorCell *betView33 = [LotteryHallColorCell.alloc initWithKey:@"点数_25" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView34 = [LotteryHallColorCell.alloc initWithKey:@"点数_26" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView35 = [LotteryHallColorCell.alloc initWithKey:@"点数_27" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView36 = [LotteryHallColorCell.alloc initWithKey:@"点数_28" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView37 = [LotteryHallColorCell.alloc initWithKey:@"点数_29" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView38 = [LotteryHallColorCell.alloc initWithKey:@"点数_30" superKey:@"轮盘" type:1];
    
    LotteryHallColorCell *betView39 = [LotteryHallColorCell.alloc initWithKey:@"点数_31" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView40 = [LotteryHallColorCell.alloc initWithKey:@"点数_32" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView41 = [LotteryHallColorCell.alloc initWithKey:@"点数_33" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView42 = [LotteryHallColorCell.alloc initWithKey:@"点数_34" superKey:@"轮盘" type:1];
    LotteryHallColorCell *betView43 = [LotteryHallColorCell.alloc initWithKey:@"点数_35" superKey:@"轮盘" type:2];
    LotteryHallColorCell *betView44 = [LotteryHallColorCell.alloc initWithKey:@"点数_36" superKey:@"轮盘" type:1];
    
    UIStackView *stackView1 = [UIStackView new];
    stackView1.spacing = 5;
    stackView1.distribution = UIStackViewDistributionFillEqually;
    [stackView1 addArrangedSubview:betView1];
    [stackView1 addArrangedSubview:betView2];
    [stackView1 addArrangedSubview:betView3];
    [stackView1 addArrangedSubview:betView4];
    [self.betStackView addArrangedSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView2 = [UIStackView new];
    stackView2.spacing = 5;
    stackView2.distribution = UIStackViewDistributionFillEqually;
    [stackView2 addArrangedSubview:betView5];
    [stackView2 addArrangedSubview:betView6];
    [stackView2 addArrangedSubview:betView7];
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView3 = [UIStackView new];
    stackView3.spacing = 5;
    stackView3.distribution = UIStackViewDistributionFillEqually;
    [stackView3 addArrangedSubview:betView8];
    [self.betStackView addArrangedSubview:stackView3];
    [stackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView4 = [UIStackView new];
    stackView4.spacing = 5;
    stackView4.distribution = UIStackViewDistributionFillEqually;
    [stackView4 addArrangedSubview:betView9];
    [stackView4 addArrangedSubview:betView10];
    [stackView4 addArrangedSubview:betView11];
    [stackView4 addArrangedSubview:betView12];
    [stackView4 addArrangedSubview:betView13];
    [stackView4 addArrangedSubview:betView14];
    [self.betStackView addArrangedSubview:stackView4];
    [stackView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView5 = [UIStackView new];
    stackView5.spacing = 5;
    stackView5.distribution = UIStackViewDistributionFillEqually;
    [stackView5 addArrangedSubview:betView15];
    [stackView5 addArrangedSubview:betView16];
    [stackView5 addArrangedSubview:betView17];
    [stackView5 addArrangedSubview:betView18];
    [stackView5 addArrangedSubview:betView19];
    [stackView5 addArrangedSubview:betView20];
    [self.betStackView addArrangedSubview:stackView5];
    [stackView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView6 = [UIStackView new];
    stackView6.spacing = 5;
    stackView6.distribution = UIStackViewDistributionFillEqually;
    [stackView6 addArrangedSubview:betView21];
    [stackView6 addArrangedSubview:betView22];
    [stackView6 addArrangedSubview:betView23];
    [stackView6 addArrangedSubview:betView24];
    [stackView6 addArrangedSubview:betView25];
    [stackView6 addArrangedSubview:betView26];
    [self.betStackView addArrangedSubview:stackView6];
    [stackView6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView7 = [UIStackView new];
    stackView7.spacing = 5;
    stackView7.distribution = UIStackViewDistributionFillEqually;
    [stackView7 addArrangedSubview:betView27];
    [stackView7 addArrangedSubview:betView28];
    [stackView7 addArrangedSubview:betView29];
    [stackView7 addArrangedSubview:betView30];
    [stackView7 addArrangedSubview:betView31];
    [stackView7 addArrangedSubview:betView32];
    [self.betStackView addArrangedSubview:stackView7];
    [stackView7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView8 = [UIStackView new];
    stackView8.spacing = 5;
    stackView8.distribution = UIStackViewDistributionFillEqually;
    [stackView8 addArrangedSubview:betView33];
    [stackView8 addArrangedSubview:betView34];
    [stackView8 addArrangedSubview:betView35];
    [stackView8 addArrangedSubview:betView36];
    [stackView8 addArrangedSubview:betView37];
    [stackView8 addArrangedSubview:betView38];
    [self.betStackView addArrangedSubview:stackView8];
    [stackView8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    UIStackView *stackView9 = [UIStackView new];
    stackView9.spacing = 5;
    stackView9.distribution = UIStackViewDistributionFillEqually;
    [stackView9 addArrangedSubview:betView39];
    [stackView9 addArrangedSubview:betView40];
    [stackView9 addArrangedSubview:betView41];
    [stackView9 addArrangedSubview:betView42];
    [stackView9 addArrangedSubview:betView43];
    [stackView9 addArrangedSubview:betView44];
    [self.betStackView addArrangedSubview:stackView9];
    [stackView9 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];
    
    self.views = @[betView1, betView2, betView3, betView4, betView5, betView6, betView7, betView8, betView9, betView10, betView11, betView12, betView13, betView14, betView15, betView16, betView17, betView18, betView19, betView20, betView21, betView22, betView23, betView24, betView25, betView26, betView27, betView28, betView29, betView30, betView31, betView32, betView33, betView34, betView35, betView36, betView37, betView38, betView39, betView40, betView41, betView42, betView43, betView44];
}

@end
