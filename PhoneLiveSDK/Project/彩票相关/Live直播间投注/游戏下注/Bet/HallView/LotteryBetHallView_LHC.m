//
//  LotteryBetHallView_LHC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetHallView_LHC.h"
#import "LotteryHallBaseCell.h"

@implementation LotteryBetHallView_LHC

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_大" superKey:@"特码"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_小" superKey:@"特码"];
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_单" superKey:@"特码"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_双" superKey:@"特码"];
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_鼠" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_牛" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_虎" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView8 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_兔" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView9 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_龙" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView10 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_蛇" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView11 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_马" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView12 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_羊" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView13 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_猴" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView14 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_鸡" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView15 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_狗" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView16 = [LotteryHallBaseCell.alloc initWithKey:@"特肖_猪" superKey:@"特码生肖"];
    LotteryHallBaseCell *betView17 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_红波" superKey:@"特码"];
    LotteryHallBaseCell *betView18 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_蓝波" superKey:@"特码"];
    LotteryHallBaseCell *betView19 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_绿波" superKey:@"特码"];
    
    LotteryHallBaseCell *betView20 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_1" superKey:@"特码"];
    LotteryHallBaseCell *betView21 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_2" superKey:@"特码"];
    LotteryHallBaseCell *betView22 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_3" superKey:@"特码"];
    LotteryHallBaseCell *betView23 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_4" superKey:@"特码"];
    LotteryHallBaseCell *betView24 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_5" superKey:@"特码"];
    LotteryHallBaseCell *betView25 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_6" superKey:@"特码"];
    LotteryHallBaseCell *betView26 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_7" superKey:@"特码"];
    LotteryHallBaseCell *betView27 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_8" superKey:@"特码"];
    LotteryHallBaseCell *betView28 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_9" superKey:@"特码"];
    LotteryHallBaseCell *betView29 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_10" superKey:@"特码"];
    LotteryHallBaseCell *betView30 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_11" superKey:@"特码"];
    LotteryHallBaseCell *betView31 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_12" superKey:@"特码"];
    LotteryHallBaseCell *betView32 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_13" superKey:@"特码"];
    LotteryHallBaseCell *betView33 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_14" superKey:@"特码"];
    LotteryHallBaseCell *betView34 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_15" superKey:@"特码"];
    LotteryHallBaseCell *betView35 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_16" superKey:@"特码"];
    LotteryHallBaseCell *betView36 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_17" superKey:@"特码"];
    LotteryHallBaseCell *betView37 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_18" superKey:@"特码"];
    LotteryHallBaseCell *betView38 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_19" superKey:@"特码"];
    LotteryHallBaseCell *betView39 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_20" superKey:@"特码"];
    LotteryHallBaseCell *betView40 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_21" superKey:@"特码"];
    LotteryHallBaseCell *betView41 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_22" superKey:@"特码"];
    LotteryHallBaseCell *betView42 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_23" superKey:@"特码"];
    LotteryHallBaseCell *betView43 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_24" superKey:@"特码"];
    LotteryHallBaseCell *betView44 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_25" superKey:@"特码"];
    LotteryHallBaseCell *betView45 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_26" superKey:@"特码"];
    LotteryHallBaseCell *betView46 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_27" superKey:@"特码"];
    LotteryHallBaseCell *betView47 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_28" superKey:@"特码"];
    LotteryHallBaseCell *betView48 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_29" superKey:@"特码"];
    LotteryHallBaseCell *betView49 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_30" superKey:@"特码"];
    LotteryHallBaseCell *betView50 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_31" superKey:@"特码"];
    LotteryHallBaseCell *betView51 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_32" superKey:@"特码"];
    LotteryHallBaseCell *betView52 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_33" superKey:@"特码"];
    LotteryHallBaseCell *betView53 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_34" superKey:@"特码"];
    LotteryHallBaseCell *betView54 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_35" superKey:@"特码"];
    LotteryHallBaseCell *betView55 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_36" superKey:@"特码"];
    LotteryHallBaseCell *betView56 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_37" superKey:@"特码"];
    LotteryHallBaseCell *betView57 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_38" superKey:@"特码"];
    LotteryHallBaseCell *betView58 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_39" superKey:@"特码"];
    LotteryHallBaseCell *betView59 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_40" superKey:@"特码"];
    LotteryHallBaseCell *betView60 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_41" superKey:@"特码"];
    LotteryHallBaseCell *betView61 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_42" superKey:@"特码"];
    LotteryHallBaseCell *betView62 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_43" superKey:@"特码"];
    LotteryHallBaseCell *betView63 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_44" superKey:@"特码"];
    LotteryHallBaseCell *betView64 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_45" superKey:@"特码"];
    LotteryHallBaseCell *betView65 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_46" superKey:@"特码"];
    LotteryHallBaseCell *betView66 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_47" superKey:@"特码"];
    LotteryHallBaseCell *betView67 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_48" superKey:@"特码"];
    LotteryHallBaseCell *betView68 = [LotteryHallBaseCell.alloc initWithKey:@"特码B_49" superKey:@"特码"];
    
    UIStackView *stackView2 = [UIStackView new];
    stackView2.spacing = 5;
    stackView2.distribution = UIStackViewDistributionFillEqually;
    [stackView2 addArrangedSubview:betView17];
    [stackView2 addArrangedSubview:betView18];
    [stackView2 addArrangedSubview:betView19];
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/4);
    }];
    
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
    
    UIStackView *stackView3 = [UIStackView new];
    stackView3.spacing = 5;
    stackView3.distribution = UIStackViewDistributionFillEqually;
    [stackView3 addArrangedSubview:betView5];
    [stackView3 addArrangedSubview:betView6];
    [stackView3 addArrangedSubview:betView7];
    [stackView3 addArrangedSubview:betView8];
    [stackView3 addArrangedSubview:betView9];
    [stackView3 addArrangedSubview:betView10];
    [self.betStackView addArrangedSubview:stackView3];
    [stackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    UIStackView *stackView4 = [UIStackView new];
    stackView4.spacing = 5;
    stackView4.distribution = UIStackViewDistributionFillEqually;
    [stackView4 addArrangedSubview:betView11];
    [stackView4 addArrangedSubview:betView12];
    [stackView4 addArrangedSubview:betView13];
    [stackView4 addArrangedSubview:betView14];
    [stackView4 addArrangedSubview:betView15];
    [stackView4 addArrangedSubview:betView16];
    [self.betStackView addArrangedSubview:stackView4];
    [stackView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    UIStackView *stackView5 = [UIStackView new];
    stackView5.spacing = 5;
    stackView5.distribution = UIStackViewDistributionFillEqually;
    [stackView5 addArrangedSubview:betView20];
    [stackView5 addArrangedSubview:betView21];
    [stackView5 addArrangedSubview:betView22];
    [stackView5 addArrangedSubview:betView23];
    [stackView5 addArrangedSubview:betView24];
    [stackView5 addArrangedSubview:betView25];
    [stackView5 addArrangedSubview:betView26];
    [self.betStackView addArrangedSubview:stackView5];
    [stackView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView6 = [UIStackView new];
    stackView6.spacing = 5;
    stackView6.distribution = UIStackViewDistributionFillEqually;
    [stackView6 addArrangedSubview:betView27];
    [stackView6 addArrangedSubview:betView28];
    [stackView6 addArrangedSubview:betView29];
    [stackView6 addArrangedSubview:betView30];
    [stackView6 addArrangedSubview:betView31];
    [stackView6 addArrangedSubview:betView32];
    [stackView6 addArrangedSubview:betView33];
    [self.betStackView addArrangedSubview:stackView6];
    [stackView6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView7 = [UIStackView new];
    stackView7.spacing = 5;
    stackView7.distribution = UIStackViewDistributionFillEqually;
    [stackView7 addArrangedSubview:betView34];
    [stackView7 addArrangedSubview:betView35];
    [stackView7 addArrangedSubview:betView36];
    [stackView7 addArrangedSubview:betView37];
    [stackView7 addArrangedSubview:betView38];
    [stackView7 addArrangedSubview:betView39];
    [stackView7 addArrangedSubview:betView40];
    [self.betStackView addArrangedSubview:stackView7];
    [stackView7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView8 = [UIStackView new];
    stackView8.spacing = 5;
    stackView8.distribution = UIStackViewDistributionFillEqually;
    [stackView8 addArrangedSubview:betView41];
    [stackView8 addArrangedSubview:betView42];
    [stackView8 addArrangedSubview:betView43];
    [stackView8 addArrangedSubview:betView44];
    [stackView8 addArrangedSubview:betView45];
    [stackView8 addArrangedSubview:betView46];
    [stackView8 addArrangedSubview:betView47];
    [self.betStackView addArrangedSubview:stackView8];
    [stackView8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView9 = [UIStackView new];
    stackView9.spacing = 5;
    stackView9.distribution = UIStackViewDistributionFillEqually;
    [stackView9 addArrangedSubview:betView48];
    [stackView9 addArrangedSubview:betView49];
    [stackView9 addArrangedSubview:betView50];
    [stackView9 addArrangedSubview:betView51];
    [stackView9 addArrangedSubview:betView52];
    [stackView9 addArrangedSubview:betView53];
    [stackView9 addArrangedSubview:betView54];
    [self.betStackView addArrangedSubview:stackView9];
    [stackView9 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView10 = [UIStackView new];
    stackView10.spacing = 5;
    stackView10.distribution = UIStackViewDistributionFillEqually;
    [stackView10 addArrangedSubview:betView55];
    [stackView10 addArrangedSubview:betView56];
    [stackView10 addArrangedSubview:betView57];
    [stackView10 addArrangedSubview:betView58];
    [stackView10 addArrangedSubview:betView59];
    [stackView10 addArrangedSubview:betView60];
    [stackView10 addArrangedSubview:betView61];
    [self.betStackView addArrangedSubview:stackView10];
    [stackView10 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    UIStackView *stackView11 = [UIStackView new];
    stackView11.spacing = 5;
    stackView11.distribution = UIStackViewDistributionFillEqually;
    [stackView11 addArrangedSubview:betView62];
    [stackView11 addArrangedSubview:betView63];
    [stackView11 addArrangedSubview:betView64];
    [stackView11 addArrangedSubview:betView65];
    [stackView11 addArrangedSubview:betView66];
    [stackView11 addArrangedSubview:betView67];
    [stackView11 addArrangedSubview:betView68];
    [self.betStackView addArrangedSubview:stackView11];
    [stackView11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/8);
    }];
    
    self.views = @[betView1, betView2, betView3, betView4, betView5, betView6, betView7, betView8, betView9, betView10, betView11, betView12, betView13, betView14, betView15, betView16, betView17, betView18, betView19, betView20, betView21, betView22, betView23, betView24, betView25, betView26, betView27, betView28, betView29, betView30, betView31, betView32, betView33, betView34, betView35, betView36, betView37, betView38, betView39, betView40, betView41, betView42, betView43, betView44, betView45, betView46, betView47, betView48, betView49, betView50, betView51, betView52, betView53, betView54, betView55, betView56, betView57, betView58, betView59, betView60, betView61, betView62, betView63, betView64, betView65, betView66, betView67, betView68];
}

@end
