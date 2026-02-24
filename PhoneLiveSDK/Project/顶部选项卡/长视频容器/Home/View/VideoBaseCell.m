//
//  VideoBaseCell.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoBaseCell.h"

@implementation VideoBaseCell

- (SDAnimatedImageView *)videoImgView {
    if (!_videoImgView) {
        _videoImgView = [SDAnimatedImageView new];
        _videoImgView.layer.masksToBounds = YES;
//        _videoImgView.layer.cornerRadius = 10;
        _videoImgView.contentMode = UIViewContentModeScaleAspectFill;
        _videoImgView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    }
    return _videoImgView;
}

- (UILabel *)videoTitleLabel {
    if (!_videoTitleLabel) {
        _videoTitleLabel = [UILabel new];
        _videoTitleLabel.font = vkFont(14);
        _videoTitleLabel.textColor = vkColorHex(0x1A1A1A);
    }
    return _videoTitleLabel;
}

- (UILabel *)videoDetailLabel {
    if (!_videoDetailLabel) {
        _videoDetailLabel = [UILabel new];
        _videoDetailLabel.font = vkFont(12);
        _videoDetailLabel.textColor = vkColorHex(0x8C8C8C);
    }
    return _videoDetailLabel;
}

- (UIButton *)playCountButton {
    if (!_playCountButton) {
        _playCountButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_playCountButton setImage:[ImageBundle imagewithBundleName:@"HomeSkitViewIcon"] forState:UIControlStateNormal];
        [_playCountButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _playCountButton.titleLabel.font = vkFont(10);
        _playCountButton.userInteractionEnabled = NO;
        _playCountButton.layer.backgroundColor = vkColorHexA(0x000000, 0.5).CGColor;
        _playCountButton.layer.cornerRadius = 5;
        _playCountButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 8);
        _playCountButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
        [_playCountButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_playCountButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _playCountButton;
}

- (UIButton *)playTimeButton {
    if (!_playTimeButton) {
        _playTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playTimeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _playTimeButton.titleLabel.font = vkFont(10);
        _playTimeButton.userInteractionEnabled = NO;
        _playTimeButton.layer.backgroundColor = vkColorHexA(0x000000, 0.5).CGColor;
        _playTimeButton.layer.cornerRadius = 5;
        _playTimeButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    }
    return _playTimeButton;
}

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

- (void)updateView {
    [self.contentView addSubview:self.videoImgView];
    [self.contentView addSubview:self.videoTitleLabel];
    [self.contentView addSubview:self.videoDetailLabel];
    [self.contentView addSubview:self.tagStackView];
    [self.contentView addSubview:self.playCountButton];
    [self.contentView addSubview:self.playTimeButton];
}

- (void)updateData {
    self.videoModel = self.itemModel;
    self.videoTitleLabel.text = self.videoModel.title;
    self.videoDetailLabel.text = self.videoModel.description_;
    [self.videoImgView sd_setImageWithURL:[NSURL URLWithString:self.videoModel.cover_path]];
    
    self.vipTagButton.hidden = !(self.videoModel.is_vip > 0);
    self.payTagButton.hidden = ![ShortVideoModel showPayTagIfNeed:self.videoModel.coin_cost ticket_cost:self.videoModel.ticket_cost];//!(self.videoModel.coin_cost > 0 || self.videoModel.ticket_cost > 0);
    NSString *payTitle = self.videoModel.can_play > 0 ? YZMsg(@"movie_pay_Purchased") : YZMsg(@"movie_pay");
    [self.payTagButton setTitle:payTitle forState:UIControlStateNormal];

    [self.playCountButton setTitle:[YBToolClass formatLikeNumber:minnum(self.videoModel.browse_count)] forState:UIControlStateNormal];
    [self.playTimeButton setTitle:self.videoModel.playTimeShow forState:UIControlStateNormal];
}

@end
