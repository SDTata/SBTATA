//
//  AnchorCmdListAlertCell.m
//  phonelive2
//
//  Created by vick on 2025/7/25.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorCmdListAlertCell.h"
#import "RemoteOrderModel.h"

@implementation AnchorCmdListAlertCell

+ (NSInteger)itemCount {
    return 2;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return 50;
}

- (void)updateView {
    [self.contentView vk_border:nil cornerRadius:14];
    
    AnchorCmdIconView *iconImgView = [AnchorCmdIconView new];
    [self.contentView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(32);
        make.centerY.mas_equalTo(0);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 4;
    [self.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconImgView.mas_right).offset(6);
        make.centerY.mas_equalTo(iconImgView.mas_centerY);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(14) color:vkColorHex(0x111118)];
    [stackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *timeLabel = [UIView vk_label:nil font:vkFont(10) color:vkColorHex(0x919191)];
    [stackView addArrangedSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UIImageView *editImgView = [UIImageView new];
    editImgView.hidden = YES;
    editImgView.image = [ImageBundle imagewithBundleName:@"live_cmd_edit_black"];
    [self.contentView addSubview:editImgView];
    self.editImgView = editImgView;
    [editImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.size.mas_equalTo(12);
    }];
    
    UIImageView *tickImgView = [UIImageView new];
    tickImgView.hidden = YES;
    tickImgView.image = [ImageBundle imagewithBundleName:@"live_cmd_tick_red"];
    [self.contentView addSubview:tickImgView];
    self.tickImgView = tickImgView;
    [tickImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(20);
    }];
    
    UILabel *priceLabel = [UIView vk_label:nil font:vkFont(12) color:vkColorHex(0x919191)];
    [self.contentView addSubview:priceLabel];
    self.priceLabel = priceLabel;
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(tickImgView.mas_bottom).offset(6);
    }];
}

- (void)updateData {
    RemoteOrderModel *model = self.itemModel;
    self.titleLabel.text = model.giftname;
    self.timeLabel.text = [NSString stringWithFormat:@"%@%@", model.shocktime, YZMsg(@"RemoteControllerCell_second")];
    self.priceLabel.text = [YBToolClass getRateCurrency:model.price showUnit:YES];
    [self.iconImgView setName:model.giftname icon:model.imagePath];
    self.editImgView.hidden = !self.isEditType;
    self.timeLabel.hidden = NO;
    self.priceLabel.hidden = NO;
    
    if (model.selected && !self.isEditType) {
        self.contentView.backgroundColor = vkColorHexA(0xFF63AC, 0.06);
        self.tickImgView.hidden = NO;
    } else {
        self.contentView.backgroundColor = vkColorHexA(0x919191, 0.08);
        self.tickImgView.hidden = YES;
    }
    
    if (model.isAdd) {
        self.editImgView.hidden = YES;
        self.timeLabel.hidden = YES;
        self.priceLabel.hidden = YES;
        self.tickImgView.hidden = YES;
        self.contentView.backgroundColor = vkColorHexA(0x919191, 0.08);
    }
}

@end
