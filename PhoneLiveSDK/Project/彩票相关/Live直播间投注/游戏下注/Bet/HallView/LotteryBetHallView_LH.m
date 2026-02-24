//
//  LotteryBetHallView_LH.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryBetHallView_LH.h"
#import "LotteryHallBaseCell.h"

@implementation LotteryBetHallView_LH

- (void)setupView {
    [super setupView];
    
    LotteryHallBaseCell *betView1 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_龙" superKey:@"龙虎"];
    LotteryHallBaseCell *betView2 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_和" superKey:@"龙虎"];
    LotteryHallBaseCell *betView3 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_虎" superKey:@"龙虎"];
    LotteryHallBaseCell *betView4 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_龙单" superKey:@"龙虎"];
    LotteryHallBaseCell *betView5 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_龙双" superKey:@"龙虎"];
    LotteryHallBaseCell *betView6 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_虎单" superKey:@"龙虎"];
    LotteryHallBaseCell *betView7 = [LotteryHallBaseCell.alloc initWithKey:@"龙虎_虎双" superKey:@"龙虎"];
    
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
