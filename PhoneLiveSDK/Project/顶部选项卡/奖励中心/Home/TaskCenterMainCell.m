//
//  TaskCenterMainCell.m
//  phonelive2
//
//  Created by vick on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskCenterMainCell.h"
#import "RewardHomeModel.h"

@implementation TaskCenterMainCell

- (ZJJTimeCountDownLabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [ZJJTimeCountDownLabel new];
        _timeLabel.textStyle = ZJJTextStlyeCustom;
        _timeLabel.font = vkFontMedium(12);
        _timeLabel.textColor = vkColorHex(0x97a4b0);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = vkColorHex(0xe3e6f1);
        _timeLabel.timeKey = @"timer";
    }
    return _timeLabel;
}

- (void)updateView {
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"task_center_cell"];
    backImgView.userInteractionEnabled = YES;
    [self.contentView addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-0);
        make.height.mas_greaterThanOrEqualTo(60);
    }];
    
    SDAnimatedImageView *iconImgView = [SDAnimatedImageView new];
    iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    iconImgView.layer.masksToBounds = YES;
    [backImgView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.size.mas_equalTo(32);
        make.centerY.mas_equalTo(-2);
    }];
    
    UIButton *actionButton = [UIView vk_button:nil image:nil font:vkFontMedium(12) color:UIColor.whiteColor];
    [actionButton setTitleColor:vkColorHex(0x97a4b0) forState:UIControlStateDisabled];
    [actionButton vk_border:nil cornerRadius:12];
    [actionButton vk_addTapAction:self selector:@selector(clickAction)];
    [backImgView addSubview:actionButton];
    self.actionButton = actionButton;
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(iconImgView.mas_centerY);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(24);
    }];
    
    self.timeLabel.hidden = YES;
    [actionButton addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 5;
    [backImgView addSubview:stackView];
    [backImgView sendSubviewToBack:stackView];
    self.stackView = stackView;
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70);
//        make.right.mas_equalTo(actionButton.mas_left).offset(-30);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(iconImgView.mas_centerY);
        make.top.mas_greaterThanOrEqualTo(10);
        make.bottom.mas_lessThanOrEqualTo(-20);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(14) color:UIColor.blackColor];
    titleLabel.hidden = YES;
    [stackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIProgressView *progressView = [UIProgressView new];
    progressView.trackTintColor = vkColorHex(0xd2d7e6);
    progressView.progressTintColor = vkColorHex(0xbb67ff);
    progressView.hidden = YES;
    [stackView addArrangedSubview:progressView];
    self.progressView = progressView;
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-100);
    }];
    
    UILabel *messageLabel = [UIView vk_label:nil font:vkFont(10) color:vkColorHex(0x97a4b0)];
    messageLabel.hidden = YES;
    messageLabel.numberOfLines = 0;
    [stackView addArrangedSubview:messageLabel];
    self.messageLabel = messageLabel;
    
    UILabel *numberLabel = [UIView vk_label:nil font:vkFont(10) color:vkColorHex(0x97a4b0)];
    numberLabel.hidden = YES;
    numberLabel.adjustsFontSizeToFitWidth = YES;
    numberLabel.minimumScaleFactor = 0.1;
    [stackView addArrangedSubview:numberLabel];
    self.numberLabel = numberLabel;
}

- (void)updateData {
    RewardHomeModel *model = self.itemModel;
    self.rewardModel = model;
    
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon_url]];
    
    self.titleLabel.text = model.name;
    self.titleLabel.hidden = (model.name.length <= 0);
    
    self.messageLabel.text = model.description_;
    self.messageLabel.hidden = (model.description_.length <= 0);
    
    self.progressView.progress = model.progress.total <= 0 ? 0 : model.progress.current/model.progress.total;
    self.progressView.hidden = model.progress.total <= 0;
    
    if (model.rewardType == RewardTypeDaySign) {
        /// 每日签到单独处理
        NSInteger current = model.progress.current > 7 ? (int)model.progress.current % 7 : model.progress.current;
        self.progressView.progress = model.progress.total <= 0 ? 0 : current /model.progress.total;
    }
    
    self.numberLabel.attributedText = model.itemText;
    self.numberLabel.hidden = (model.itemText.length <= 0);
    
    [self.actionButton setTitle:model.action_text forState:UIControlStateNormal];
    self.actionButton.enabled = model.canClick;
    self.actionButton.backgroundColor = model.canClick ? [UIView colors:@[vkColorHex(0xd6a9ff), vkColorHex(0xbb67ff)] size:CGSizeMake(70, 24) isHorizontal:NO] : vkColorHex(0xe3e6f1);
    
    NSTimeInterval timeInterval = model.timer.integerValue - NSDate.date.timeIntervalSince1970;
    if (timeInterval > 0) {
        ZJJTimeCountDown *countDown = self.extraData;
        [self.timeLabel setupCellWithModel:self.itemModel indexPath:self.indexPath];
        self.timeLabel.attributedText = [countDown countDownWithTimeLabel:self.timeLabel];
        self.timeLabel.hidden = NO;
    } else {
        self.timeLabel.hidden = YES;
    }
}

- (void)clickAction {
    if (self.clickCellActionBlock) {
        self.clickCellActionBlock(self.indexPath, self.itemModel, 0);
    }
}

@end
