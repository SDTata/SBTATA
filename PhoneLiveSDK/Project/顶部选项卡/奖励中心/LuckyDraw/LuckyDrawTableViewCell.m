//
//  LuckyDrawTableViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LuckyDrawTableViewCell.h"

@interface LuckyDrawTableViewCell()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIView *separator;
@end

@implementation LuckyDrawTableViewCell
- (void)updateView {
    self.contentView.backgroundColor = UIColor.whiteColor;
    UIImageView *iconImgView = [UIImageView new];
    [self.contentView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(32);
        make.centerY.mas_equalTo(-2);
    }];
    
    UIView *rightnumberBgView = [UIView new];
    [rightnumberBgView vk_border:nil cornerRadius:12];
    //[rightnumberBgView vk_border:vkColorRGB(236, 223, 243) cornerRadius:12];
    //[rightnumberBgView vk_addTapAction:self selector:@selector(clickAction)];
    [self.contentView addSubview:rightnumberBgView];
    self.rightnumberBgView = rightnumberBgView;
    [rightnumberBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(iconImgView.mas_centerY);
        make.width.mas_equalTo(@RatioBaseWidth375(54));
        make.height.mas_equalTo(@RatioBaseWidth375(24));
    }];
    [rightnumberBgView setVerticalColors:@[vkColorRGB(244, 234, 255), vkColorRGB(245, 238, 249)]];
    
    UILabel *rightnumberLabel = [UILabel new];
    rightnumberLabel.textAlignment = NSTextAlignmentCenter;
    rightnumberLabel.font = vkFontMedium(12);
    rightnumberLabel.textColor = vkColorRGB(200, 125, 250);
    rightnumberLabel.text = @"0";
    [rightnumberBgView addSubview:rightnumberLabel];
    self.rightnumberLabel = rightnumberLabel;
    [rightnumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(rightnumberBgView);
        make.width.mas_equalTo(rightnumberBgView);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 5;
    [self.contentView addSubview:stackView];
    self.stackView = stackView;
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconImgView.mas_right).offset(10);
        make.right.mas_equalTo(rightnumberBgView.mas_left).offset(-30);
        make.centerY.mas_equalTo(iconImgView.mas_centerY);
        make.top.mas_greaterThanOrEqualTo(10);
        make.bottom.mas_lessThanOrEqualTo(-10);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(12) color:UIColor.blackColor];
    [stackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIProgressView *progressView = [UIProgressView new];
    progressView.trackTintColor = vkColorRGB(210, 215, 230);
    progressView.progressTintColor = vkColorRGB(214, 169, 255);
    progressView.hidden = YES;
    progressView.height = 5;
    [stackView addArrangedSubview:progressView];
    self.progressView = progressView;
    
    UILabel *messageLabel = [UIView vk_label:nil font:vkFontName(10, @"PingFangSC-Regular") color:vkColorRGB(151, 164, 176)];
    messageLabel.hidden = YES;
    [stackView addArrangedSubview:messageLabel];
    self.messageLabel = messageLabel;
    
    UILabel *numberLabel = [UIView vk_label:nil font:vkFont(10) color:vkColorHex(0x97a4b0)];
    numberLabel.hidden = YES;
    [stackView addArrangedSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    UIView *separator = [UIView new];
    separator.backgroundColor = vkColorRGB(232, 235, 237);
    [self.contentView addSubview:separator];
    self.separator = separator;
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(stackView.mas_bottom).offset(6);
        make.left.mas_equalTo(stackView);
        make.right.mas_equalTo(rightnumberBgView);
    }];
}

- (void)updateData {
    NSDictionary *data = self.itemModel;
    if (data[@"reset_time"]) {
        [self configResetTime:data[@"reset_time"]];
        return;
    }

    self.titleLabel.hidden = NO;

    self.numberLabel.hidden = YES;
    int curValue = [data[@"curValue"] intValue];  // 当前值
    int maxValue = [data[@"maxValue"] intValue];  // 最大值
    float progress = MIN(1.0, (float)curValue / (float)maxValue);
    NSString *placeholderImage = progress == 1 ? @"Luckydraw_cell_achieve" : @"Luckydraw_cell_recharge";
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:data[@"icon"]] placeholderImage:[ImageBundle imagewithBundleName:placeholderImage]];
    self.rightnumberBgView.backgroundColor = progress != 1 ? [UIView colors:@[vkColorHex(0xd6a9ff), vkColorHex(0xbb67ff)] size:CGSizeMake(70, 24) isHorizontal:NO] : vkColorHex(0xe3e6f1);
    self.progressView.progress = progress;
    self.progressView.hidden = NO;
    self.titleLabel.text = data[@"title"];
    self.messageLabel.text = data[@"description"];
    self.messageLabel.hidden = NO;
    self.rightnumberLabel.text = progress == 1 ? YZMsg(@"taskfinished") : YZMsg(@"taskgofinish");
    self.rightnumberLabel.textColor = progress == 1 ? vkColorHex(0x97a4b0) : UIColor.whiteColor;
    if (progress != 1) {
        [self.rightnumberLabel vk_addTapAction:self selector:@selector(clickAction)];
    }
    self.separator.hidden = NO;
    
    if ([data[@"title"] isEqualToString:@"绑定手机"]) {
        self.separator.hidden = YES;
        self.messageLabel.hidden = YES;
    }
}

- (void)configResetTime:(NSString *)resetTime {
    NSString *resetTips = YZMsg(@"luckyDraw_reset_time");
    NSString *combinedStr = [NSString stringWithFormat:resetTips, resetTime];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: combinedStr attributes:
                                                   @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:12.0],
                                                     NSKernAttributeName: @(0.2)}];

    // 找到 resetTime 的范围
    NSRange str2Range = [combinedStr rangeOfString:resetTime];

    // 设置 str1 和 str3 的颜色为黑色（str1 不包括占位符）
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:82.0/255.0 green:99.0/255.0 blue:119.0/255.0 alpha:1.0] range:NSMakeRange(0, str2Range.location)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:82.0/255.0 green:99.0/255.0 blue:119.0/255.0 alpha:1.0] range:NSMakeRange(NSMaxRange(str2Range), combinedStr.length - NSMaxRange(str2Range))];
    // 设置 str2 的颜色为紫色
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:200.0/255.0 green:125.0/255.0 blue:250.0/255.0 alpha:1.0] range:str2Range];

    self.titleLabel.attributedText = attributedString;
    self.titleLabel.numberOfLines = 0;
    self.messageLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.rightnumberBgView.hidden = YES;
    self.separator.hidden = YES;
    self.iconImgView.image = [ImageBundle imagewithBundleName:@"Luckydraw_cell_notice_fill"];
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImgView.mas_right).offset(10);
        make.right.mas_equalTo(self.rightnumberBgView);
        make.centerY.mas_equalTo(self.iconImgView.mas_centerY);
        make.top.mas_greaterThanOrEqualTo(10);
        make.bottom.mas_lessThanOrEqualTo(-10);
    }];
    [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(17);
        make.centerY.mas_equalTo(-2);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.separator.hidden = NO;
    self.progressView.hidden = NO;
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImgView.mas_right).offset(10);
        make.right.mas_equalTo(self.rightnumberBgView.mas_left).offset(-30);
        make.centerY.mas_equalTo(self.iconImgView.mas_centerY);
        make.top.mas_greaterThanOrEqualTo(10);
        make.bottom.mas_lessThanOrEqualTo(-10);
    }];
    [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(32);
        make.centerY.mas_equalTo(-2);
    }];
}

- (void)clickAction {
    if (self.clickCellActionBlock) {
        self.clickCellActionBlock(self.indexPath, self.itemModel, 0);
    }
}

@end
