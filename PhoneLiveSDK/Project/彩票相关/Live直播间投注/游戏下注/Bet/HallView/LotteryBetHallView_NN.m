//
//  LotteryBetHallView_NN.m
//  phonelive2
//
//  Created by vick on 2023/12/12.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetHallView_NN.h"
#import "LotteryHallBaseCell.h"

@implementation LotteryBetHallView_NN

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方胜" superKey:@"猜胜负"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"红方胜" superKey:@"猜胜负"];
    LotteryHallBaseCell *betView111 = [LotteryHallBaseCell.alloc initWithKey:@"龙" superKey:@"牌1VS牌5"];
    LotteryHallBaseCell *betView222 = [LotteryHallBaseCell.alloc initWithKey:@"虎" superKey:@"牌1VS牌5"];
    
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_无牛" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛一" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛二" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛三" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛四" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView8 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛五" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView9 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛六" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView10 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛七" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView11 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛八" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView12 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛九" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView13 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_牛牛" superKey:@"猜蓝方牛"];
    LotteryHallBaseCell *betView14 = [LotteryHallBaseCell.alloc initWithKey:@"蓝方_花色牛" superKey:@"猜蓝方牛"];

    LotteryHallBaseCell *betView15 = [LotteryHallBaseCell.alloc initWithKey:@"红方_无牛" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView16 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛一" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView17 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛二" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView18 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛三" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView19 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛四" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView20 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛五" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView21 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛六" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView22 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛七" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView23 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛八" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView24 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛九" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView25 = [LotteryHallBaseCell.alloc initWithKey:@"红方_牛牛" superKey:@"猜红方牛"];
    LotteryHallBaseCell *betView26 = [LotteryHallBaseCell.alloc initWithKey:@"红方_花色牛" superKey:@"猜红方牛"];
    
    UIStackView *stackView1 = [UIStackView new];
    stackView1.spacing = 5;
    stackView1.distribution = UIStackViewDistributionFillEqually;
    [stackView1 addArrangedSubview:betView1];
    [stackView1 addArrangedSubview:betView2];
    [self.betStackView addArrangedSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/5);
    }];
    
    UIStackView *stackView11 = [UIStackView new];
    stackView11.spacing = 5;
    stackView11.distribution = UIStackViewDistributionFillEqually;
    [stackView11 addArrangedSubview:betView111];
    [stackView11 addArrangedSubview:betView222];
    [self.betStackView addArrangedSubview:stackView11];
    [stackView11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/5);
    }];
    
    UILabel *titleLabel1 = [UILabel new];
    titleLabel1.textAlignment = NSTextAlignmentCenter;
    titleLabel1.text = @"猜蓝方牛";
    titleLabel1.font = vkFontBold(18);
    titleLabel1.textColor = UIColor.whiteColor;
    titleLabel1.backgroundColor = vkColorHexA(0xFFFFFF, 0.1);
    titleLabel1.layer.cornerRadius = 18;
    titleLabel1.layer.masksToBounds = YES;
    [self.betStackView addArrangedSubview:titleLabel1];
    [titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(36);
    }];
    
    UIStackView *stackView2 = [UIStackView new];
    stackView2.spacing = 5;
    stackView2.distribution = UIStackViewDistributionFillEqually;
    [stackView2 addArrangedSubview:betView3];
    [stackView2 addArrangedSubview:betView4];
    [stackView2 addArrangedSubview:betView5];
    [stackView2 addArrangedSubview:betView6];
    [stackView2 addArrangedSubview:betView7];
    [stackView2 addArrangedSubview:betView8];
    [self.betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    UIStackView *stackView3 = [UIStackView new];
    stackView3.spacing = 5;
    stackView3.distribution = UIStackViewDistributionFillEqually;
    [stackView3 addArrangedSubview:betView9];
    [stackView3 addArrangedSubview:betView10];
    [stackView3 addArrangedSubview:betView11];
    [stackView3 addArrangedSubview:betView12];
    [stackView3 addArrangedSubview:betView13];
    [stackView3 addArrangedSubview:betView14];
    [self.betStackView addArrangedSubview:stackView3];
    [stackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    UILabel *titleLabel2 = [UILabel new];
    titleLabel2.textAlignment = NSTextAlignmentCenter;
    titleLabel2.text = @"猜红方牛";
    titleLabel2.font = vkFontBold(18);
    titleLabel2.textColor = UIColor.whiteColor;
    titleLabel2.backgroundColor = vkColorHexA(0xFFFFFF, 0.1);
    titleLabel2.layer.cornerRadius = 18;
    titleLabel2.layer.masksToBounds = YES;
    [self.betStackView addArrangedSubview:titleLabel2];
    [titleLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(36);
    }];
    
    UIStackView *stackView4 = [UIStackView new];
    stackView4.spacing = 5;
    stackView4.distribution = UIStackViewDistributionFillEqually;
    [stackView4 addArrangedSubview:betView15];
    [stackView4 addArrangedSubview:betView16];
    [stackView4 addArrangedSubview:betView17];
    [stackView4 addArrangedSubview:betView18];
    [stackView4 addArrangedSubview:betView19];
    [stackView4 addArrangedSubview:betView20];
    [self.betStackView addArrangedSubview:stackView4];
    [stackView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    UIStackView *stackView5 = [UIStackView new];
    stackView5.spacing = 5;
    stackView5.distribution = UIStackViewDistributionFillEqually;
    [stackView5 addArrangedSubview:betView21];
    [stackView5 addArrangedSubview:betView22];
    [stackView5 addArrangedSubview:betView23];
    [stackView5 addArrangedSubview:betView24];
    [stackView5 addArrangedSubview:betView25];
    [stackView5 addArrangedSubview:betView26];
    [self.betStackView addArrangedSubview:stackView5];
    [stackView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(VK_SCREEN_W/7);
    }];
    
    self.views = @[betView1, betView2, betView111, betView222, betView3, betView4, betView5, betView6, betView7, betView8, betView9, betView10, betView11, betView12, betView13, betView14, betView15, betView16, betView17, betView18, betView19, betView20, betView21, betView22, betView23, betView24, betView25, betView26];
}

@end
