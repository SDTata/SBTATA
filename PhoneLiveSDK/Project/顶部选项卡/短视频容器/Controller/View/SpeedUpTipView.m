//
//  SpeedUpTipView.m
//  phonelive2
//
//  Created by s5346 on 2024/8/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SpeedUpTipView.h"

@implementation SpeedUpTipView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];

    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.3;
    backgroundView.layer.cornerRadius = 22;
    backgroundView.layer.masksToBounds = YES;
    [self addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    UIImageView *leftArrowImageView = [[UIImageView alloc] init];
    leftArrowImageView.image = [ImageBundle imagewithBundleName:@"SpeenRightArrow"];
    [self addSubview:leftArrowImageView];
    [leftArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.width.equalTo(@10);
        make.height.equalTo(@15);
        make.centerY.equalTo(self);
    }];

    UIImage *originalImage = [ImageBundle imagewithBundleName:@"SpeenRightArrow"];
    UIImage *tintedImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:tintedImage];
    rightArrowImageView.tintColor = [UIColor lightGrayColor];
    [self insertSubview:rightArrowImageView belowSubview:leftArrowImageView];
    [rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftArrowImageView.mas_right).offset(-3);
        make.width.equalTo(@10);
        make.height.equalTo(@15);
        make.centerY.equalTo(self);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"2.0x 播放中";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightArrowImageView.mas_right).offset(10);
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
    }];
}

@end
