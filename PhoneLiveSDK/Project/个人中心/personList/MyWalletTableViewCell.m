//
//  MyWalletTableViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyWalletTableViewCell.h"

@interface MyWalletTableViewCell()
@property(nonatomic, strong) SDAnimatedImageView *logoImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *balanceLabel;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) SDAnimatedImageView *rightArrowImageView;
@end

@implementation MyWalletTableViewCell

- (void)updateData {
    NSDictionary *data = self.itemModel;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:data[@"icon"]]];
    self.titleLabel.text = data[@"name"];
    NSString *balance = data[@"balance"] ? data[@"balance"] : @"0";
    self.balanceLabel.text = [NSString stringWithFormat:@"余额: %@", balance];
}
- (void)updateView {
    UIView *borderView = [UIView new];
    [self.contentView addSubview: borderView];
    borderView.backgroundColor = vkColorRGB(234, 231, 238);
    borderView.layer.cornerRadius = 16;
    borderView.layer.borderWidth = 1;
    borderView.layer.borderColor = [UIColor grayColor].CGColor;
    [borderView addSubview:self.logoImageView];
    [borderView addSubview:self.titleLabel];
    [borderView addSubview:self.balanceLabel];
    [borderView addSubview:self.refreshButton];
    [borderView addSubview:self.rightArrowImageView];
    
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).inset(12);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.leading.mas_equalTo(borderView).offset(20);
        make.top.mas_equalTo(borderView).offset(10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.logoImageView.mas_trailing).offset(20);
        make.centerY.mas_equalTo(self.logoImageView);
        make.trailing.mas_equalTo(self.rightArrowImageView.mas_leading).inset(10);
    }];
    
    [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.logoImageView);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(borderView).inset(10);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.balanceLabel.mas_trailing).offset(10);
        make.trailing.mas_lessThanOrEqualTo(self.rightArrowImageView.mas_leading).inset(12);
        make.centerY.mas_equalTo(self.balanceLabel);
        make.size.mas_equalTo(30);
    }];
    
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(borderView).inset(20);
        make.centerY.mas_equalTo(borderView);
        make.width.mas_equalTo(6);
        make.height.mas_equalTo(12);
    }];
}

- (SDAnimatedImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[SDAnimatedImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImageView.clipsToBounds = YES;
    }
    return _logoImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.textColor = vkColorRGB(77, 77, 77);
        _balanceLabel.font = [UIFont systemFontOfSize:14];
    }
    return _balanceLabel;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _refreshButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_refreshButton addTarget:self action:@selector(buttonAciton:) forControlEvents:UIControlEventTouchUpInside];
        [_refreshButton setImage:[ImageBundle imagewithBundleName:@"h5_refresh"] forState:UIControlStateNormal];
    }
    return _refreshButton;
}

- (SDAnimatedImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[SDAnimatedImageView alloc] init];
        _rightArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightArrowImageView.image = [ImageBundle imagewithBundleName:@"arrows_43"];
    }
    return _rightArrowImageView;
}

- (void)buttonAciton:(UIButton *)sender {
    if (self.clickCellActionBlock) {
        self.clickCellActionBlock(self.indexPath, self.itemModel, 0);
    }
}
@end
