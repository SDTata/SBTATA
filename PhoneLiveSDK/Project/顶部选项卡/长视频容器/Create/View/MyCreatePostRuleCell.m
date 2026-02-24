//
//  MyCreatePostRuleCell.m
//  phonelive2
//
//  Created by vick on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreatePostRuleCell.h"
#import "PostVideoViewController.h"

@implementation MyCreatePostRuleSectionCell

+ (CGFloat)itemHeight {
    return 30;
}

- (void)updateView {
    UIButton *titleButton = [UIView vk_button:nil image:nil font:vkFont(14) color:UIColor.whiteColor];
    [titleButton vk_border:nil cornerRadius:5];
    titleButton.backgroundColor = vkColorHex(0xAF99C9);
    titleButton.userInteractionEnabled = NO;
    titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self addSubview:titleButton];
    self.titleButton = titleButton;
    [titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)updateData {
    RuleSection *model = self.itemModel;
    [self.titleButton setTitle:model.title forState:UIControlStateNormal];
}

@end

@implementation MyCreatePostRuleCell

- (void)updateView {
    UIView *pointView = [UIView new];
    pointView.backgroundColor = vkColorHex(0x4D4D4D);
    [pointView vk_border:nil cornerRadius:2.5];
    [self.contentView addSubview:pointView];
    [pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(5);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(12) color:vkColorHex(0x4D4D4D)];
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
    self.titleLabel.text = self.itemModel;
}

@end
