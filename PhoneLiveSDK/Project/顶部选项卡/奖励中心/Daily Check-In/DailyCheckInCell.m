//
//  DailyCheckInCell.m
//  phonelive2
//
//  Created by s5346 on 2024/8/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DailyCheckInCell.h"

@interface DailyCheckInCell ()

@property(nonatomic, strong) UIImageView *bgImageView;
@property(nonatomic, strong) UILabel *bonusLabel;
@property(nonatomic, strong) UILabel *dayLabel;

@end

@implementation DailyCheckInCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(UserBonusItemModel*)model countDay:(int)countDay {
    int bonus_day = countDay % 7;
    if (bonus_day == 0 && countDay > 0) {
        bonus_day = 8;
    }
    BOOL isCheck = model.day.intValue <= bonus_day;

    self.bonusLabel.text = [NSString stringWithFormat:@"+%@", [YBToolClass getRateCurrency:model.coin showUnit:NO]];
    self.bgImageView.highlighted = isCheck;
    self.bonusLabel.hidden = isCheck;

    self.dayLabel.textColor = RGB_COLOR(@"#97a4b0", 1);
    if (isCheck) {
        if (model.day.intValue % 7 == 0) {
            self.bgImageView.image = [ImageBundle imagewithBundleName:@"DailyCheckIn_vip_gift_on_continuous"];
            [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.contentView);
                make.height.equalTo(@RatioBaseWidth375(45));
            }];

            self.dayLabel.textColor = RGB_COLOR(@"#d6a9ff", 1);
            self.dayLabel.text = [NSString stringWithFormat:@"%@%d%@",
                                  YZMsg(@"Consecutive Sign-ins"),
                                  countDay,
                                  YZMsg(@"public_Day")];
        } else {
            self.bgImageView.image = [ImageBundle imagewithBundleName:@"DailyCheckIn_vip_gift_on"];
            self.dayLabel.text = YZMsg(@"Signed In");
        }
    } else {
        if (model.day.intValue % 7 == 0) {
            self.bgImageView.image = [ImageBundle imagewithBundleName:@"DailyCheckIn_vip_gift_off_continuous"];
        } else {
            self.bgImageView.image = [ImageBundle imagewithBundleName:@"DailyCheckIn_vip_gift_off"];
        }

        [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.equalTo(@RatioBaseWidth375(38));
        }];

        self.dayLabel.text = [NSString stringWithFormat:@"%@%@", minstr(model.day), YZMsg(@"public_Day")];
    }
}

- (void)setupViews {
    [self.contentView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.equalTo(@RatioBaseWidth375(38));
    }];

    [self.bgImageView addSubview:self.bonusLabel];
    [self.bonusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.equalTo(@RatioBaseWidth375(38));
    }];

    [self.contentView addSubview:self.dayLabel];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - Lazy
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImageView;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [UILabel new];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.font = [UIFont systemFontOfSize:10];
        _dayLabel.textColor = RGB_COLOR(@"#97a4b0", 1);
    }
    return _dayLabel;
}

- (UILabel *)bonusLabel {
    if (!_bonusLabel) {
        _bonusLabel = [UILabel new];
        _bonusLabel.textAlignment = NSTextAlignmentCenter;
        _bonusLabel.font = [UIFont boldSystemFontOfSize:10];
        _bonusLabel.textColor = RGB_COLOR(@"#526377", 1);
    }
    return _bonusLabel;
}

@end
