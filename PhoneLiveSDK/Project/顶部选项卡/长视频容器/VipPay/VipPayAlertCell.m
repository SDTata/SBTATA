//
//  VipPayAlertCell.m
//  phonelive2
//
//  Created by vick on 2025/2/10.
//  Copyright © 2025 toby. All rights reserved.
//

#import "VipPayAlertCell.h"
#import "VipPayModel.h"

@implementation VipPayAlertCell

+ (NSInteger)itemCount {
    return 3;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+(CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return VKPX(120);
}

- (void)updateView {
    [self.contentView vk_border:vkColorHexA(0x919191, 0.08) cornerRadius:10];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontBold(14) color:vkColorHex(0x111118)];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(19);
    }];
    
    UILabel *detailLabel = [UIView vk_label:nil font:vkFont(12) color:vkColorHex(0x919191)];
    [self.contentView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_left);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(8);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = vkColorHex(0x919191);
    [detailLabel addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    UILabel *unitLabel = [UIView vk_label:nil font:vkFontBold(16) color:vkColorHex(0x111118)];
    [self.contentView addSubview:unitLabel];
    self.unitLabel = unitLabel;
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_left);
        make.bottom.mas_equalTo(-20);
    }];
    
    UILabel *amountLabel = [UIView vk_label:nil font:vkFontBold(28) color:vkColorHex(0x111118)];
    amountLabel.minimumScaleFactor = 0.1;
    amountLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:amountLabel];
    self.amountLabel = amountLabel;
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(unitLabel.mas_right).offset(5);
        make.bottom.mas_equalTo(unitLabel.mas_bottom).offset(5);
        make.right.mas_lessThanOrEqualTo(-10);
    }];
}

- (void)updateData {
    VipPayListModel *model = self.itemModel;
    self.titleLabel.text = model.length_name;
    self.detailLabel.text = [NSString toAmount:model.orig_coin_price].toRate.toUnit;
    self.detailLabel.hidden = [[NSString toAmount:model.orig_coin_price] intValue] == 0;
    self.unitLabel.text = [Config getRegionCurrenyChar];
    self.amountLabel.text = [NSString toAmount:model.coin].toRate;
    
    if (model.selected) {
        self.contentView.backgroundColor = vkColorHexA(0xFFF7F0, 1.0);
        self.contentView.layer.borderColor = vkColorHexA(0xFFC663, 1.0).CGColor;
        self.amountLabel.textColor = vkColorHex(0xEB7D45);
        self.unitLabel.textColor = vkColorHex(0xEB7D45);
    } else {
        self.contentView.backgroundColor = vkColorHexA(0x919191, 0.08);
        self.contentView.layer.borderColor = vkColorHexA(0x919191, 0.08).CGColor;
        self.amountLabel.textColor = vkColorHex(0x111118);
        self.unitLabel.textColor = vkColorHex(0x111118);
    }
}

@end
