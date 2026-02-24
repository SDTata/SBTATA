//
//  VKActionGridCell.m
//
//  Created by vick on 2023/5/10.
//

#import "VKActionGridCell.h"
#import <Masonry/Masonry.h>
#import "VKInline.h"

@implementation VKActionGridCell

+ (CGFloat)itemHeight {
    return 80;
}

- (void)updateView {
    
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 5;
    [self.contentView addSubview:stackView];
    self.stackView = stackView;
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *iconImgView = [UIImageView new];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    [stackView addArrangedSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = vkFont(14);
    titleLabel.textColor = vkColorHex(0x333333);
    [stackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.font = vkFont(12);
    messageLabel.textColor = vkColorHex(0x999999);
    [stackView addArrangedSubview:messageLabel];
    self.messageLabel = messageLabel;
}

- (void)updateData {
    VKActionModel *model = self.itemModel;
    
    self.iconImgView.hidden = !model.icon;
    
    if ([model.icon hasPrefix:@"http"]) {
        [self.iconImgView vk_setImageUrl:model.icon];
    } else if (model.icon) {
        self.iconImgView.image = [ImageBundle imagewithBundleName:model.icon];
    }
    
    if (!CGSizeEqualToSize(model.iconSize, CGSizeZero)) {
        [self.iconImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(model.iconSize);
        }];
    }
    
    if (model.selected && model.iconSelected) {
        self.iconImgView.image = [ImageBundle imagewithBundleName:model.iconSelected];
    }
    
    self.titleLabel.hidden = !model.title;
    self.titleLabel.text = model.title;
    
    self.messageLabel.hidden = !model.message;
    self.messageLabel.text = model.message;
    
    if (model.titleFont) {
        self.titleLabel.font = model.titleFont;
    }
    if (model.titleColor) {
        self.titleLabel.textColor = model.titleColor;
    }
    if (model.selected && model.titleSelected) {
        self.titleLabel.text = model.titleSelected;
    }
    if (model.selected && model.titleColorSelected) {
        self.titleLabel.textColor = model.titleColorSelected;
    }
    
    if (model.messageFont) {
        self.messageLabel.font = model.messageFont;
    }
    if (model.messageColor) {
        self.messageLabel.textColor = model.messageColor;
    }
    if (model.selected && model.messageSelected) {
        self.messageLabel.text = model.messageSelected;
    }
    if (model.selected && model.messageColorSelected) {
        self.messageLabel.textColor = model.messageColorSelected;
    }
    
    if (model.isHorizontal) {
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
    }
    
    if (model.backgroudColor) {
        self.contentView.backgroundColor = model.backgroudColor;
    }
    if (model.backCorner > 0) {
        self.contentView.layer.cornerRadius = model.backCorner;
        self.contentView.layer.masksToBounds = YES;
    }
}

@end
