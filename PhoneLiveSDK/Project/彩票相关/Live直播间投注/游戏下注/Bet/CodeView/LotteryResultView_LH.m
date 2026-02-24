//
//  LotteryResultView_LH.m
//  phonelive2
//
//  Created by vick on 2025/2/15.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryResultView_LH.h"

@interface LotteryResultView_LH ()

@property (nonatomic, strong) UIImageView *cardView1;
@property (nonatomic, strong) UIImageView *cardView2;

@end

@implementation LotteryResultView_LH

- (void)setupView {
    UIImageView *cardView1 = [UIImageView new];
    [self addSubview:cardView1];
    self.cardView1 = cardView1;
    [cardView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-0);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(24);
    }];
    
    UILabel *vsLabel = [UILabel new];
    vsLabel.textColor = UIColor.yellowColor;
    vsLabel.font = vkFont(12);
    vsLabel.text = @"VS";
    [self addSubview:vsLabel];
    [vsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cardView1.mas_right).offset(10);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *cardView2 = [UIImageView new];
    [self addSubview:cardView2];
    self.cardView2 = cardView2;
    [cardView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.bottom.width.height.mas_equalTo(cardView1);
        make.left.mas_equalTo(vsLabel.mas_right).offset(10);
    }];
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    NSDictionary *dragon = resultModel.vs[@"dragon"];
    NSDictionary *tiger = resultModel.vs[@"tiger"];
    self.leftCard = dragon[@"pai"];
    self.rightCard = tiger[@"pai"];
}

- (void)setResultDict:(NSDictionary *)resultDict {
    NSArray <NSArray *> *array = LotteryResults(resultDict[@"result"]);
    self.leftCard = array.firstObject.firstObject;
    self.rightCard = array.lastObject.firstObject;
}

- (void)setLeftCard:(NSString *)leftCard {
    self.cardView1.image = [ImageBundle imagewithBundleName:LotteryPoker(leftCard)];
}

- (void)setRightCard:(NSString *)rightCard {
    self.cardView2.image = [ImageBundle imagewithBundleName:LotteryPoker(rightCard)];
}

@end
