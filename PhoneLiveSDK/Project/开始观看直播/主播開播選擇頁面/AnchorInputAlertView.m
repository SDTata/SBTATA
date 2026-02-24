//
//  AnchorInputAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/29.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorInputAlertView.h"

@implementation AnchorInputAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self corner:VKCornerMaskAll radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VKPX(300));
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(26);
    }];
    
    UITextField *textField = [UITextField new];
    textField.font = vkFont(14);
    textField.textColor = vkColorHex(0x111118);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:textField];
    self.textField = textField;
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(24);
        make.height.mas_equalTo(36);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(textField.mas_bottom).offset(24);
        make.bottom.mas_equalTo(-26);
        make.height.mas_equalTo(38);
    }];
    
    UIButton *cancelButton = [UIView vk_button:YZMsg(@"public_cancel") image:nil font:vkFont(16) color:UIColor.blackColor];
    [cancelButton vk_border:vkColorHexA(0x919191, 0.2) cornerRadius:19];
    [cancelButton vk_addTapAction:self selector:@selector(clickCancelAction)];
    [stackView addArrangedSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    UIButton *confirmButton = [UIView vk_button:YZMsg(@"Livebroadcast_order_confirm") image:nil font:vkFont(16) color:UIColor.whiteColor];
    [confirmButton vk_border:nil cornerRadius:19];
    [confirmButton vk_addTapAction:self selector:@selector(clickConfirmAction)];
    [stackView addArrangedSubview:confirmButton];
    self.confirmButton = confirmButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.confirmButton.horizontalColors = @[vkColorHex(0xFF838E), vkColorHex(0xFF63AC)];
}

- (void)clickCancelAction {
    [self hideAlert:nil];
}

- (void)clickConfirmAction {
    if (self.textField.text.length <= 0) {
        [MBProgressHUD showError:self.textField.placeholder];
        return;
    }
    if (self.clickConfirmBlock) {
        self.clickConfirmBlock(self.textField.text);
    }
    [self hideAlert:nil];
}

@end
