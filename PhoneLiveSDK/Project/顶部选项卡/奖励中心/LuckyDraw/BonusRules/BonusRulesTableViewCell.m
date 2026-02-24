//
//  BonusRulesTableViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BonusRulesTableViewCell.h"
#import "PostVideoViewController.h"

@implementation BonusRulesSectionCell

+ (CGFloat)itemHeight {
    return 50;
}

- (void)updateView {
    UIView *pointView = [UIView new];
    pointView.backgroundColor = vkColorRGB(214, 169, 255);
    [pointView vk_border:nil cornerRadius:2.5];
    [self.contentView addSubview:pointView];
    [pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(14);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(16) color:UIColor.blackColor];
    titleLabel.numberOfLines = 0;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pointView.mas_right).offset(5);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
        make.right.mas_equalTo(-16);
    }];
}

- (void)updateData {
    RuleSection *model = self.itemModel;
    self.titleLabel.text = model.title;
}
@end

@implementation BonusRulesTableViewCell

- (void)updateView {
    UILabel *numberLabel =  [UIView vk_label:nil font:vkFontMedium(14) color: vkColorRGB(200, 125, 250)];
    [numberLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:numberLabel];
    self.numberLabel = numberLabel;
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(5);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(12) color: vkColorRGB(59, 67, 76)];
    titleLabel.numberOfLines = 0;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(numberLabel.mas_right).offset(5);
        make.top.mas_equalTo(numberLabel).offset(2);
        make.bottom.mas_equalTo(-5);
        make.right.mas_equalTo(-16);
    }];
}

- (void)updateData {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld.",self.indexPath.row+1];
    if ([((NSString *)self.itemModel) containsString:@"在线客服"]) {
        [self addOnlineServiceAttributedString: self.itemModel];
    } else {
        self.titleLabel.text = self.itemModel;
    }
}

// 設置“在線客服”字體顏色和下劃線
- (void)addOnlineServiceAttributedString:(NSString *)title {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange onlineServiceRange = [title rangeOfString:@"在线客服"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:vkColorRGB(200, 125, 250) range:onlineServiceRange];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:onlineServiceRange];
    
    self.titleLabel.attributedText = attributedString;
    // 使“在線客服”可點擊
    self.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onlineServiceTapped)];
    [self.titleLabel addGestureRecognizer:tapGesture];
}

- (void)onlineServiceTapped {
    if (self.clickCellActionBlock) {
        self.clickCellActionBlock(self.indexPath, self.itemModel, 1);
    }
}
@end
