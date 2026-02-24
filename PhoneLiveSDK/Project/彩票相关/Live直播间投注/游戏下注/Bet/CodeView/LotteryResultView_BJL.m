//
//  LotteryResultView_BJL.m
//  phonelive2
//
//  Created by vick on 2025/2/15.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryResultView_BJL.h"

@interface LotteryResultView_BJL ()

@property (nonatomic, strong) UIImageView *leftCardView1;
@property (nonatomic, strong) UIImageView *leftCardView2;
@property (nonatomic, strong) UIImageView *leftCardView3;
@property (nonatomic, strong) UILabel *leftResultLabel;

@property (nonatomic, strong) UIImageView *rightCardView1;
@property (nonatomic, strong) UIImageView *rightCardView2;
@property (nonatomic, strong) UIImageView *rightCardView3;
@property (nonatomic, strong) UILabel *rightResultLabel;

@end

@implementation LotteryResultView_BJL

- (void)setupView {
    UIImageView *leftCardView3 = [UIImageView new];
    leftCardView3.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    [self addSubview:leftCardView3];
    self.leftCardView3 = leftCardView3;
    [leftCardView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(5);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(24);
    }];
    
    UIImageView *leftCardView2 = [UIImageView new];
    [self addSubview:leftCardView2];
    self.leftCardView2 = leftCardView2;
    [leftCardView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftCardView3.mas_right).offset(7);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(24);
    }];
    
    UIImageView *leftCardView1 = [UIImageView new];
    [self addSubview:leftCardView1];
    self.leftCardView1 = leftCardView1;
    [leftCardView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftCardView2.mas_right).offset(1);
        make.top.bottom.width.height.mas_equalTo(leftCardView2);
    }];
    
    UILabel *vsLabel = [UILabel new];
    vsLabel.textColor = UIColor.yellowColor;
    vsLabel.font = vkFont(12);
    vsLabel.text = @"VS";
    [self addSubview:vsLabel];
    [vsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftCardView1.mas_right).offset(4);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *rightCardView1 = [UIImageView new];
    [self addSubview:rightCardView1];
    self.rightCardView1 = rightCardView1;
    [rightCardView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(vsLabel.mas_right).offset(4);
        make.top.bottom.width.height.mas_equalTo(leftCardView1);
    }];
    
    UIImageView *rightCardView2 = [UIImageView new];
    [self addSubview:rightCardView2];
    self.rightCardView2 = rightCardView2;
    [rightCardView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rightCardView1.mas_right).offset(1);
        make.top.bottom.width.height.mas_equalTo(rightCardView1);
    }];
    
    UIImageView *rightCardView3 = [UIImageView new];
    rightCardView3.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    [self addSubview:rightCardView3];
    self.rightCardView3 = rightCardView3;
    [rightCardView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rightCardView2.mas_right).offset(6);
        make.width.height.mas_equalTo(rightCardView2);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(5);
    }];
    
    UILabel *leftResultLabel = [UILabel new];
    leftResultLabel.textColor = UIColor.whiteColor;
    leftResultLabel.backgroundColor = vkColorHexA(0x000000, 0.3);
    leftResultLabel.font = vkFont(12);
    leftResultLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:leftResultLabel];
    self.leftResultLabel = leftResultLabel;
    [leftResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftCardView3.mas_left).offset(-5);
        make.right.mas_equalTo(leftCardView1.mas_right);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    
    UILabel *rightResultLabel = [UILabel new];
    rightResultLabel.textColor = UIColor.yellowColor;
    rightResultLabel.backgroundColor = vkColorHexA(0x000000, 0.3);
    rightResultLabel.font = vkFont(12);
    rightResultLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:rightResultLabel];
    self.rightResultLabel = rightResultLabel;
    [rightResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rightCardView1.mas_left);
        make.right.mas_equalTo(rightCardView3.mas_right).offset(5);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    NSDictionary *blue = resultModel.vs[@"blue"];
    NSDictionary *red = resultModel.vs[@"red"];
    self.leftCards = blue[@"pai"];
    self.rightCards = red[@"pai"];
    self.leftResult = blue[@"dian"];
    self.rightResult = red[@"dian"];
}

- (void)setResultDict:(NSDictionary *)resultDict {
    NSArray *array = LotteryResults(resultDict[@"result"]);
    self.leftCards = array.firstObject;
    self.rightCards = array.lastObject;
    self.leftResult = resultDict[@"bjl"][@"xian_dian_str"];
    self.rightResult = resultDict[@"bjl"][@"zhuang_dian_str"];
}

- (void)setLeftCards:(NSArray<NSString *> *)leftCards {
    self.leftCardView1.image = [ImageBundle imagewithBundleName:LotteryPoker([leftCards safeObjectWithIndex:0])];
    self.leftCardView2.image = [ImageBundle imagewithBundleName:LotteryPoker([leftCards safeObjectWithIndex:1])];
    self.leftCardView3.image = [ImageBundle imagewithBundleName:LotteryPoker([leftCards safeObjectWithIndex:2])];
}

- (void)setRightCards:(NSArray<NSString *> *)rightCards {
    self.rightCardView1.image = [ImageBundle imagewithBundleName:LotteryPoker([rightCards safeObjectWithIndex:0])];
    self.rightCardView2.image = [ImageBundle imagewithBundleName:LotteryPoker([rightCards safeObjectWithIndex:1])];
    self.rightCardView3.image = [ImageBundle imagewithBundleName:LotteryPoker([rightCards safeObjectWithIndex:2])];
}

- (void)setLeftResult:(NSString *)leftResult {
    self.leftResultLabel.text = [NSString stringWithFormat:@"%@%@", @"闲家", leftResult];
}

- (void)setRightResult:(NSString *)rightResult {
    self.rightResultLabel.text = [NSString stringWithFormat:@"%@%@", @"庄家", rightResult];
}

@end
