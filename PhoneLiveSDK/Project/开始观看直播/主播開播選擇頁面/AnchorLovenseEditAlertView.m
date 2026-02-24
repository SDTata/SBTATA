//
//  AnchorLovenseEditAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/23.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorLovenseEditAlertView.h"

@interface AnchorLovenseEditAlertView ()

@property (nonatomic, strong) UISwitch *openButton;

@end

@implementation AnchorLovenseEditAlertView

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
    [self corner:VKCornerMaskTop radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(140+VK_BOTTOM_H);
    }];
    
    UILabel *titleLabel = [UIView vk_label:@"Lovense" font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.backgroundColor = vkColorHexA(0x919191, 0.08);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *openLabel = [UIView vk_label:@"连接" font:vkFont(14) color:vkColorHex(0x111118)];
    [self addSubview:openLabel];
    [openLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
    }];
    
    UISwitch *openButton = [UISwitch new];
    openButton.onTintColor = vkColorHex(0xFF63AC);
    [openButton addTarget:self action:@selector(showToyConnectViewForSwitch:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:openButton];
    self.openButton = openButton;
    [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(openLabel.mas_centerY);
    }];
}

- (void)showToyConnectViewForSwitch:(UISwitch*)sender {
    if (self.clickSwitchBlock) {
        self.clickSwitchBlock(sender);
    }
    if (sender.isOn) {
        [self hideAlert:nil];
    }
}

@end
