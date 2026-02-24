//
//  YBUserInfoContentCell.m
//  phonelive2
//
//  Created by user on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YBUserInfoContentCell.h"

@implementation YBUserInfoContentCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(RatioBaseWidth375(8));
            make.centerX.mas_equalTo(self.contentView);
            make.size.mas_equalTo(28);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(5);
            make.height.mas_equalTo(16);
            make.leading.trailing.mas_equalTo(self.contentView);
            make.bottom.lessThanOrEqualTo(self.contentView);
        }];
        //[self.contentView addSubview:self.subTitleLabel];
        [self.titleLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (void)setupData:(NSDictionary *)data {
    self.titleLabel.text = data[@"name"];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:minstr(data[@"thumb"])] placeholderImage:SmallIconPlaceHoldImage];
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(RatioBaseWidth375(8));
        make.centerX.mas_equalTo(self.contentView);
        make.size.mas_equalTo(28);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.lessThanOrEqualTo(self.contentView);
    }];
//    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.titleLabel.mas_bottom);
//        make.leading.trailing.mas_equalTo(self.contentView);
//    }];
}

- (SDAnimatedImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SDAnimatedImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = vkColorHex(0x526377);
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.textColor = vkColorRGB(151, 164, 176);
        _subTitleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
