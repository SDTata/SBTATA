//
//  DramaAllListCell.m
//  phonelive2
//
//  Created by s5346 on 2024/5/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaAllListCell.h"

@interface DramaAllListCell ()

@property(nonatomic, strong) UIImageView *thumbImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UILabel *payLabel;
@property(nonatomic, strong) UIView *payView;

@end

@implementation DramaAllListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)updateData:(DramaVideoInfoModel*)model {
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:model.over]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ | %@", model.name, model.desc];
    self.timeLabel.text = @"";
    self.payView.hidden = !model.isNeedPay;
}

#pragma makr - UI
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];

    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    self.selectedBackgroundView = selectedBackgroundView;

    [self.contentView addSubview:self.thumbImageView];
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@64);
        make.height.equalTo(@86);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(14);
    }];

    self.payView.hidden = YES;
    [self.thumbImageView addSubview:self.payView];
    [self.payView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.thumbImageView).inset(3);
        make.height.equalTo(@16);
    }];

    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbImageView.mas_right).offset(14);
        make.top.equalTo(self.thumbImageView).offset(10);
        make.right.equalTo(self.contentView).offset(-20);
    }];

    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thumbImageView.mas_right).offset(14);
        make.bottom.equalTo(self.thumbImageView).offset(-10);
        make.right.equalTo(self.contentView).offset(-20);
    }];
}

#pragma mark - Lazy
- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.layer.cornerRadius = 8;
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = RGB_COLOR(@"#B7B7B7", 1);
    }
    return _timeLabel;
}

- (UILabel *)payLabel {
    if (!_payLabel) {
        _payLabel = [[UILabel alloc] init];
        _payLabel.font = [UIFont systemFontOfSize:10];
        _payLabel.textColor = [UIColor whiteColor];
        _payLabel.text = YZMsg(@"DramaAllListCell_pay");
    }
    return _payLabel;
}

- (UIView *)payView {
    if (!_payView) {
        _payView = [[UIView alloc] init];
        _payView.backgroundColor = RGB_COLOR(@"#B73AF5", 1);
        _payView.layer.cornerRadius = 8;
        _payView.layer.masksToBounds = YES;

        [_payView addSubview:self.payLabel];
        [self.payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_payView).inset(3);
            make.left.right.equalTo(_payView).inset(5);
        }];
    }
    return _payView;
}

@end
