//
//  KingSalaryHeaderView.m
//  phonelive2
//
//  Created by s5346 on 2024/8/23.
//  Copyright © 2024 toby. All rights reserved.
//

#import "KingSalaryHeaderView.h"

@implementation KingSalaryHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

#pragma mark - UI
- (void)setupViews {
    UILabel *label1 = [UILabel new];
    label1.font = [UIFont systemFontOfSize:12];
    label1.textColor = [UIColor whiteColor];
    label1.textAlignment = NSTextAlignmentCenter;
//    label1.adjustsFontSizeToFitWidth = YES;
//    label1.minimumScaleFactor = 0.3;
    label1.backgroundColor = RGB_COLOR(@"#a9bbff", 1);
    label1.text = YZMsg(@"kingsalary_kinglevel");

    UILabel *label2 = [UILabel new];
    label2.font = [UIFont systemFontOfSize:12];
    label2.textColor = [UIColor whiteColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
    label2.text = YZMsg(@"kingsalary_totalrecharge");
//    label2.adjustsFontSizeToFitWidth = YES;
//    label2.minimumScaleFactor = 0.3;
    
    [self createRightLineView:label2];

    UILabel *label3 = [UILabel new];
    label3.font = [UIFont systemFontOfSize:12];
    label3.textColor = [UIColor whiteColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
    label3.text = YZMsg(@"kingsalary_promotionbonus");
//    label3.adjustsFontSizeToFitWidth = YES;
//    label3.minimumScaleFactor = 0.3;
    [self createRightLineView:label3];

    UILabel *label4 = [UILabel new];
    label4.font = [UIFont systemFontOfSize:12];
    label4.textColor = [UIColor whiteColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
    label4.text = YZMsg(@"view_wangzhevipdes_zhou_fenglu");
//    label4.adjustsFontSizeToFitWidth = YES;
//    label4.minimumScaleFactor = 0.3;
    [self createRightLineView:label4];

    UILabel *label5 = [UILabel new];
    label5.font = [UIFont systemFontOfSize:12];
    label5.textColor = [UIColor whiteColor];
    label5.textAlignment = NSTextAlignmentCenter;
    label5.backgroundColor = RGB_COLOR(@"#aaaff9", 1);
    label5.text = YZMsg(@"monthfenglu");
//    label5.adjustsFontSizeToFitWidth = YES;
//    label5.minimumScaleFactor = 0.3;
    [self createRightLineView:label5];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[label1, label2, label3, label4, label5]];
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    UIView *leftLineView = [UIView new];
    leftLineView.backgroundColor = RGB_COLOR(@"#ffffff", 0.5);
    [stackView addSubview:leftLineView];
    [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1);
        make.right.bottom.equalTo(label1);
        make.height.equalTo(@1);
    }];

    UIView *rightLineView = [UIView new];
    rightLineView.backgroundColor = RGB_COLOR(@"#d2d7e6", 1);
    [stackView addSubview:rightLineView];
    [rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label2);
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


@end
