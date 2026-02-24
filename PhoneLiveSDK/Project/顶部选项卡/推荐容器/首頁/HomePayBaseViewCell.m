//
//  HomePayBaseViewCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomePayBaseViewCell.h"
#import "ShortVideoModel.h"

@implementation HomePayBaseViewCell

- (void)updateDataForVip:(NSInteger)is_vip pay:(NSInteger)coin_cost ticket:(NSInteger)ticket_cost canPlay:(NSInteger)can_play {
    self.vipTagButton.hidden = !(is_vip > 0);
    self.payTagButton.hidden = ![ShortVideoModel showPayTagIfNeed:coin_cost ticket_cost:ticket_cost];//!(coin_cost > 0 || ticket_cost > 0);
    NSString *payTitle = can_play > 0 ? YZMsg(@"movie_pay_Purchased") : YZMsg(@"movie_pay");
    [self.payTagButton setTitle:payTitle forState:UIControlStateNormal];
}

#pragma mark - Lazy
- (UIButton *)vipTagButton {
    if (!_vipTagButton) {
        _vipTagButton = [UIView vk_button:@"VIP" image:nil font:vkFontMedium(10) color:vkColorHex(0x664208)];
        [_vipTagButton setBackgroundImage:[ImageBundle imagewithBundleName:@"video_tag_vip"] forState:UIControlStateNormal];
        _vipTagButton.userInteractionEnabled = NO;
    }
    return _vipTagButton;
}

- (UIButton *)payTagButton {
    if (!_payTagButton) {
        _payTagButton = [UIView vk_button:YZMsg(@"movie_pay") image:nil font:vkFontMedium(10) color:vkColorHex(0xFFFFFF)];
        [_payTagButton setBackgroundImage:[ImageBundle imagewithBundleName:@"video_tag_pay"] forState:UIControlStateNormal];
        _payTagButton.userInteractionEnabled = NO;
    }
    return _payTagButton;
}

- (UIStackView *)tagStackView {
    if (!_tagStackView) {
        _tagStackView = [UIStackView new];
        _tagStackView.axis = UILayoutConstraintAxisHorizontal;
        _tagStackView.spacing = 2;

        [_tagStackView addArrangedSubview:self.vipTagButton];
        [_tagStackView addArrangedSubview:self.payTagButton];

        [_tagStackView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(28);
        }];
    }
    return _tagStackView;
}
@end

@implementation HomePayBaseViewTableViewCell

- (void)updateDataForVip:(NSInteger)is_vip pay:(NSInteger)coin_cost ticket:(NSInteger)ticket_cost canPlay:(NSInteger)can_play {
    self.vipTagButton.hidden = !(is_vip > 0);
    self.payTagButton.hidden = ![ShortVideoModel showPayTagIfNeed:coin_cost ticket_cost:ticket_cost];//!(coin_cost > 0 || ticket_cost > 0);
    NSString *payTitle = can_play > 0 ? YZMsg(@"movie_pay_Purchased") : YZMsg(@"movie_pay");
    [self.payTagButton setTitle:payTitle forState:UIControlStateNormal];
}

#pragma mark - Lazy
- (UIButton *)vipTagButton {
    if (!_vipTagButton) {
        _vipTagButton = [UIView vk_button:@"VIP" image:nil font:vkFontMedium(10) color:vkColorHex(0x664208)];
        [_vipTagButton setBackgroundImage:[ImageBundle imagewithBundleName:@"video_tag_vip"] forState:UIControlStateNormal];
        _vipTagButton.userInteractionEnabled = NO;
    }
    return _vipTagButton;
}

- (UIButton *)payTagButton {
    if (!_payTagButton) {
        _payTagButton = [UIView vk_button:YZMsg(@"movie_pay") image:nil font:vkFontMedium(10) color:vkColorHex(0xFFFFFF)];
        [_payTagButton setBackgroundImage:[ImageBundle imagewithBundleName:@"video_tag_pay"] forState:UIControlStateNormal];
        _payTagButton.userInteractionEnabled = NO;
    }
    return _payTagButton;
}

- (UIStackView *)tagStackView {
    if (!_tagStackView) {
        _tagStackView = [UIStackView new];
        _tagStackView.axis = UILayoutConstraintAxisHorizontal;
        _tagStackView.spacing = 2;

        [_tagStackView addArrangedSubview:self.vipTagButton];
        [_tagStackView addArrangedSubview:self.payTagButton];

        [_tagStackView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(28);
        }];
    }
    return _tagStackView;
}
@end
