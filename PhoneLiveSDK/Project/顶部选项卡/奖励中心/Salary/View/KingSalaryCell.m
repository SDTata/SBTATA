//
//  KingSalaryCell.m
//  phonelive2
//
//  Created by s5346 on 2024/8/23.
//  Copyright © 2024 toby. All rights reserved.
//

#import "KingSalaryCell.h"

@interface KingSalaryCell ()

@property(nonatomic, strong) UILabel *label1;
@property(nonatomic, strong) UILabel *label2;
@property(nonatomic, strong) UILabel *label3;
@property(nonatomic, strong) UILabel *label4;
@property(nonatomic, strong) UILabel *label5;

@end

@implementation KingSalaryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(SalaryLevelItem*)model {
    self.label1.text = [NSString stringWithFormat:YZMsg(@"VIPVC_KingLeve%@_title"),model.level];
    self.label2.text = [YBToolClass getRateCurrency:model.c_charge showUnit:YES];
    self.label3.text = [YBToolClass getRateCurrency:model.levelup_reward showUnit:YES];
    self.label4.text = [YBToolClass getRateCurrency:model.week_reward showUnit:YES];
    self.label5.text = [YBToolClass getRateCurrency:model.month_reward showUnit:YES];
}

#pragma mark - UI
- (void)setupViews {
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.label1, self.label2, self.label3, self.label4, self.label5]];
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    UIView *leftLineView = [UIView new];
    leftLineView.backgroundColor = RGB_COLOR(@"#ffffff", 0.5);
    [stackView addSubview:leftLineView];
    [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label1);
        make.right.bottom.equalTo(self.label1);
        make.height.equalTo(@1);
    }];

    UIView *rightLineView = [UIView new];
    rightLineView.backgroundColor = RGB_COLOR(@"#d2d7e6", 1);
    [stackView addSubview:rightLineView];
    [rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label2);
        make.right.bottom.equalTo(stackView);
        make.height.equalTo(@1);
    }];
}

- (void)createRightLineView:(UILabel*)label {
    UIView *lineView = [UIView new];
    lineView.backgroundColor = RGB_COLOR(@"#d2d7e6", 1);
    [label addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(label);
        make.width.equalTo(@1);
    }];
}

#pragma mark - Lazy
- (UILabel *)label1 {
    if (!_label1) {
        _label1 = [UILabel new];
        _label1.font = [UIFont systemFontOfSize:12];
        _label1.textColor = [UIColor whiteColor];
        _label1.textAlignment = NSTextAlignmentCenter;
        _label1.backgroundColor = RGB_COLOR(@"#a9bbff", 1);
    }
    return _label1;
}

- (UILabel *)label2 {
    if (!_label2) {
        _label2 = [UILabel new];
        _label2.font = [UIFont systemFontOfSize:12];
        _label2.textColor = [UIColor whiteColor];
        _label2.textAlignment = NSTextAlignmentCenter;
        _label2.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
        [self createRightLineView:_label2];
    }
    return _label2;
}

- (UILabel *)label3 {
    if (!_label3) {
        _label3 = [UILabel new];
        _label3.font = [UIFont systemFontOfSize:12];
        _label3.textColor = [UIColor whiteColor];
        _label3.textAlignment = NSTextAlignmentCenter;
        _label3.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
        [self createRightLineView:_label3];
    }
    return _label3;
}

- (UILabel *)label4 {
    if (!_label4) {
        _label4 = [UILabel new];
        _label4.font = [UIFont systemFontOfSize:12];
        _label4.textColor = [UIColor whiteColor];
        _label4.textAlignment = NSTextAlignmentCenter;
        _label4.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
        [self createRightLineView:_label4];
    }
    return _label4;
}

- (UILabel *)label5 {
    if (!_label5) {
        _label5 = [UILabel new];
        _label5.font = [UIFont systemFontOfSize:12];
        _label5.textColor = [UIColor whiteColor];
        _label5.textAlignment = NSTextAlignmentCenter;
        _label5.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
        [self createRightLineView:_label5];
    }
    return _label5;
}

@end
