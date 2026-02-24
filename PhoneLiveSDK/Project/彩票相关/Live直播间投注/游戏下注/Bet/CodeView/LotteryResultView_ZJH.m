//
//  LotteryResultView_ZJH.m
//  phonelive2
//
//  Created by vick on 2025/2/15.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryResultView_ZJH.h"

@interface LotteryResultView_ZJH ()

@property (nonatomic, strong) UIImageView *cardView1;
@property (nonatomic, strong) UIImageView *cardView2;
@property (nonatomic, strong) UIImageView *cardView3;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation LotteryResultView_ZJH

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
    
    UIImageView *cardView2 = [UIImageView new];
    [self addSubview:cardView2];
    self.cardView2 = cardView2;
    [cardView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cardView1.mas_right).offset(-5);
        make.top.bottom.width.height.mas_equalTo(cardView1);
    }];
    
    UIImageView *cardView3 = [UIImageView new];
    [self addSubview:cardView3];
    self.cardView3 = cardView3;
    [cardView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(cardView2.mas_right).offset(-5);
        make.top.bottom.width.height.mas_equalTo(cardView1);
    }];
    
    UILabel *resultLabel = [UILabel new];
    resultLabel.textColor = UIColor.whiteColor;
    resultLabel.backgroundColor = vkColorHexA(0x000000, 0.3);
    resultLabel.font = vkFont(12);
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:resultLabel];
    self.resultLabel = resultLabel;
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    NSString *key = [NSString stringWithFormat:@"player%ld", resultModel.who_win+1];
    NSDictionary *player = resultModel.vs[key];
    self.cards = player[@"pai"];
    self.result = player[@"pai_type_str"];
}

- (void)setResultDict:(NSDictionary *)resultDict {
    NSInteger whoWin = [resultDict[@"zjh"][@"whoWin"] integerValue];
    self.cards = LotteryResults(resultDict[@"result"])[whoWin];
    self.result = resultDict[@"zjh"][@"pai_type_str"][whoWin];
}

- (void)setCards:(NSArray<NSString *> *)cards {
    self.cardView1.image = [ImageBundle imagewithBundleName:LotteryPoker([cards safeObjectWithIndex:0])];
    self.cardView2.image = [ImageBundle imagewithBundleName:LotteryPoker([cards safeObjectWithIndex:1])];
    self.cardView3.image = [ImageBundle imagewithBundleName:LotteryPoker([cards safeObjectWithIndex:2])];
}

- (void)setResult:(NSString *)result {
    self.resultLabel.text = result;
}

@end
