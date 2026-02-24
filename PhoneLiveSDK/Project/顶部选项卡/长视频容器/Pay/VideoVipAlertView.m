//
//  VideoVipAlertView.m
//  phonelive2
//
//  Created by vick on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoVipAlertView.h"
#import <UMCommon/UMCommon.h>
#import "VipPayAlertView.h"

@interface VideoVipAlertView ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation VideoVipAlertView

- (BOOL)alertPresentationVC {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = vkColorHex(0x1D001F);
    [self vk_border:nil cornerRadius:20];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VKPX(320));
    }];
    
    UIImageView *iconImgView = [UIImageView new];
    iconImgView.image = [ImageBundle imagewithBundleName:@"video_pay_vip"];
    [self addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(26);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(84);
    }];
    
    UILabel *messageLabel = [UIView vk_label:YZMsg(@"unlockremind_buyviptips1") font:vkFont(16) color:vkColorHex(0xF9DEA2)];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(iconImgView.mas_bottom).offset(20);
    }];
    
    UIButton *cancelButton = [UIView vk_button:YZMsg(@"public_cancel") image:nil font:vkFont(16) color:vkColorHex(0xC69DC7)];
    [cancelButton vk_border:nil cornerRadius:19];
    cancelButton.backgroundColor = vkColorHex(0x552E5C);
    [cancelButton vk_addTapAction:self selector:@selector(clickCancelAction)];
    [self addSubview:cancelButton];
    self.cancelButton = cancelButton;
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(28);
        make.bottom.mas_equalTo(-32);
        make.height.mas_equalTo(38);
        make.top.mas_equalTo(messageLabel.mas_bottom).offset(30);
    }];
    
    UIButton *confirmButton = [UIView vk_button:YZMsg(@"VIP_Activate_now") image:nil font:vkFont(16) color:vkColorHex(0x664208)];
    confirmButton.titleLabel.minimumScaleFactor = 0.5;
    confirmButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [confirmButton vk_border:nil cornerRadius:19];
    [confirmButton vk_addTapAction:self selector:@selector(clickConfirmAction)];
    [self addSubview:confirmButton];
    self.confirmButton = confirmButton;
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-28);
        make.left.mas_equalTo(cancelButton.mas_right).offset(26);
        make.height.width.top.mas_equalTo(cancelButton);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.confirmButton.horizontalColors = @[vkColorHex(0xFAE2B0), vkColorHex(0xF7CE7A)];
}

- (void)clickCancelAction {
    [self hideAlert:nil];
}

- (void)clickConfirmAction {
    [self hideAlert:^{
        VipPayAlertView *view = [VipPayAlertView new];
        [view showFromBottom];
    }];
    
    NSString *event;
    if (self.videoType == 1) { // 短剧
        event = @"skit_pay_vip_click";
    } else if (self.videoType == 2) { // 短视频
        event = @"";
    } else if (self.videoType == 3) { // 长视频(电影)
        event = @"longvideo_pay_vip_click";
    }
    [MobClick event:event attributes:@{@"eventType": @(1)}];
}

@end
