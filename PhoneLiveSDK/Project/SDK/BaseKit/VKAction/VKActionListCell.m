//
//  VKActionListCell.m
//
//  Created by vick on 2023/5/10.
//

#import "VKActionListCell.h"
#import <Masonry/Masonry.h>
#import "SDWebImage.h"
#import "VKInline.h"

@implementation VKActionListCell

+ (CGFloat)itemHeight {
    return 50;
}

- (void)updateView {
    
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *backMaskView = [UIView new];
    [self.contentView addSubview:backMaskView];
    self.backMaskView = backMaskView;
    [backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 10;
    [backMaskView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIImageView *iconImgView = [UIImageView new];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    [stackView addArrangedSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    UIStackView *textStackView = [UIStackView new];
    textStackView.axis = UILayoutConstraintAxisVertical;
    textStackView.alignment = UIStackViewAlignmentFill;
    textStackView.distribution = UIStackViewDistributionFill;
    textStackView.spacing = 5;
    [stackView addArrangedSubview:textStackView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = vkFont(16);
    titleLabel.textColor = vkColorHex(0x333333);
    [textStackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.font = vkFont(12);
    messageLabel.textColor = vkColorHex(0x999999);
    [textStackView addArrangedSubview:messageLabel];
    self.messageLabel = messageLabel;
    
    UILabel *valueLabel = [UILabel new];
    valueLabel.font = vkFont(14);
    valueLabel.textColor = vkColorHex(0x999999);
    [valueLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [stackView addArrangedSubview:valueLabel];
    self.valueLabel = valueLabel;
    
    UIImageView *arrowImgView = [UIImageView new];
    arrowImgView.contentMode = UIViewContentModeScaleAspectFit;
    arrowImgView.image = [ImageBundle imagewithBundleName:@"HotHeaderRightArrowIcon"];
    [stackView addArrangedSubview:arrowImgView];
    self.arrowImgView = arrowImgView;
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
}

- (void)updateData {
    VKActionModel *model = self.itemModel;
    
    self.iconImgView.hidden = !model.icon;
    
    if ([model.icon hasPrefix:@"http"]) {
        [self.iconImgView vk_setImageUrl:model.icon];
    } else if (model.icon) {
        self.iconImgView.image = [UIImage imageNamed:model.icon];
    }
    
    if (!CGSizeEqualToSize(model.iconSize, CGSizeZero)) {
        [self.iconImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(model.iconSize);
        }];
    }
    
    if (model.selected && model.iconSelected) {
        self.iconImgView.image = [UIImage imageNamed:model.iconSelected];
    }
    
    self.titleLabel.hidden = !model.title;
    self.titleLabel.text = model.title;
    
    self.messageLabel.hidden = !model.message;
    self.messageLabel.text = model.message;
    
    self.arrowImgView.hidden = !model.showArrow;
    
    self.valueLabel.hidden = !model.value;
    self.valueLabel.text = model.value;
    
    if (model.titleFont) {
        self.titleLabel.font = model.titleFont;
    }
    if (model.titleColor) {
        self.titleLabel.textColor = model.titleColor;
    }
    if (model.selected && model.titleColorSelected) {
        self.titleLabel.textColor = model.titleColorSelected;
    }
    if (model.selected && model.titleSelected) {
        self.titleLabel.text = model.titleSelected;
    }
    
    if (model.messageFont) {
        self.messageLabel.font = model.messageFont;
    }
    if (model.messageColor) {
        self.messageLabel.textColor = model.messageColor;
    }
    if (model.selected && model.messageColorSelected) {
        self.messageLabel.textColor = model.messageColorSelected;
    }
    if (model.selected && model.messageSelected) {
        self.messageLabel.text = model.messageSelected;
    }
    
    if (model.messageFont) {
        self.messageLabel.font = model.messageFont;
    }
    if (model.messageColor) {
        self.messageLabel.textColor = model.messageColor;
    }
    if (model.selected && model.messageColorSelected) {
        self.messageLabel.textColor = model.messageColorSelected;
    }
    if (model.selected && model.messageSelected) {
        self.messageLabel.text = model.messageSelected;
    }
    
    if (model.valueFont) {
        self.valueLabel.font = model.valueFont;
    }
    if (model.valueColor) {
        self.valueLabel.textColor = model.valueColor;
    }
    if (model.selected && model.valueColorSelected) {
        self.valueLabel.textColor = model.valueColorSelected;
    }
    if (model.selected && model.valueSelected) {
        self.valueLabel.text = model.valueSelected;
    }
    
    if (model.backgroudColor) {
        self.backMaskView.backgroundColor = model.backgroudColor;
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(model.backInsets, UIEdgeInsetsZero)) {
        [self.backMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView).insets(model.backInsets);
        }];
    }
    if (model.backCorner > 0) {
        self.backMaskView.layer.cornerRadius = model.backCorner;
        self.backMaskView.layer.masksToBounds = YES;
    }
}

@end
