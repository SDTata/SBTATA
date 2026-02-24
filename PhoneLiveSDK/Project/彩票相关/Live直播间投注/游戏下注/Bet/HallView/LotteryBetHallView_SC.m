//
//  LotteryBetHallView_SC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetHallView_SC.h"
#import "LotteryHallBaseCell.h"

@implementation LotteryBetHallView_SC

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_大" superKey:@"猜双面"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_小" superKey:@"猜双面"];
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_单" superKey:@"猜双面"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_双" superKey:@"猜双面"];
    LotteryHallBaseCell *betView111 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_大单" superKey:@"猜双面"];
    LotteryHallBaseCell *betView222 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_大双" superKey:@"猜双面"];
    LotteryHallBaseCell *betView333 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_小单" superKey:@"猜双面"];
    LotteryHallBaseCell *betView444 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_小双" superKey:@"猜双面"];
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_1" superKey:@"猜车号"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_2" superKey:@"猜车号"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_3" superKey:@"猜车号"];
    LotteryHallBaseCell *betView8 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_4" superKey:@"猜车号"];
    LotteryHallBaseCell *betView9 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_5" superKey:@"猜车号"];
    LotteryHallBaseCell *betView10 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_6" superKey:@"猜车号"];
    LotteryHallBaseCell *betView11 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_7" superKey:@"猜车号"];
    LotteryHallBaseCell *betView12 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_8" superKey:@"猜车号"];
    LotteryHallBaseCell *betView13 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_9" superKey:@"猜车号"];
    LotteryHallBaseCell *betView14 = [LotteryHallBaseCell.alloc initWithKey:@"冠军_10" superKey:@"猜车号"];
    
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
    
    UIStackView *stackView11 = [UIStackView new];
    stackView11.spacing = 5;
    stackView11.distribution = UIStackViewDistributionFillEqually;
    [stackView11 addArrangedSubview:betView111];
    [stackView11 addArrangedSubview:betView222];
    [stackView11 addArrangedSubview:betView333];
    [stackView11 addArrangedSubview:betView444];
    [self.betStackView addArrangedSubview:stackView11];
    [stackView11 mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/6);
    }];
    
    UIStackView *stackView3 = [UIStackView new];
    stackView3.spacing = 5;
    stackView3.distribution = UIStackViewDistributionFillEqually;
    [stackView3 addArrangedSubview:betView10];
    [stackView3 addArrangedSubview:betView11];
    [stackView3 addArrangedSubview:betView12];
    [stackView3 addArrangedSubview:betView13];
    [stackView3 addArrangedSubview:betView14];
    [self.betStackView addArrangedSubview:stackView3];
    [stackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/6);
    }];
    
    self.views = @[betView1, betView2, betView3, betView4, betView111, betView222, betView333, betView444, betView5, betView6, betView7, betView8, betView9, betView10, betView11, betView12, betView13, betView14];
}

@end
