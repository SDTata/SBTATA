//
//  VideoPayAlertView.m
//  phonelive2
//
//  Created by vick on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoPayAlertView.h"
#import "VKButton.h"
#import <UMCommon/UMCommon.h>
#import "UIView+Shake.h"
#import "VipPayAlertView.h"
#import "GameHomeMainVC.h"

@interface VideoPayAlertView ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIButton *ticketButton;
@property (nonatomic, strong) UIButton *amountButton;

@property (nonatomic, strong) UIView *balanceBackView;
@property (nonatomic, strong) VKButton *ticketBalanceButton;
@property (nonatomic, strong) VKButton *amountBalanceButton;

@property (nonatomic, strong) VKButton *openVipButton;
@property (nonatomic, strong) VKButton *buyMoreButton;

@property (nonatomic, strong) UIView *topBackView;

@end

@implementation VideoPayAlertView

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

- (UIView *)balanceBackView {
    if (!_balanceBackView) {
        _balanceBackView = [UIView new];
//        _balanceBackView.backgroundColor = vkColorHex(0xFFF7F0);
//        [_balanceBackView vk_border:nil cornerRadius:16];
        
        VKButton *amountBalanceButton = [VKButton new];
        [amountBalanceButton vk_button:nil image:@"video_pay_wallet" font:vkFont(12) color:vkColorHex(0x111118)];
        amountBalanceButton.userInteractionEnabled = NO;
        amountBalanceButton.spacingBetweenImage = 5;
        amountBalanceButton.imagePosition = VKButtonImagePositionLeft;
        amountBalanceButton.backgroundColor = vkColorHex(0xFFF7F0);
        [amountBalanceButton vk_border:nil cornerRadius:8];
        [_balanceBackView addSubview:amountBalanceButton];
        self.amountBalanceButton = amountBalanceButton;
        [amountBalanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        
        VKButton *ticketBalanceButton = [VKButton new];
        [ticketBalanceButton vk_button:nil image:@"video_pay_ticket" font:vkFont(12) color:vkColorHex(0x111118)];
        ticketBalanceButton.userInteractionEnabled = NO;
        ticketBalanceButton.spacingBetweenImage = 5;
        ticketBalanceButton.imagePosition = VKButtonImagePositionLeft;
        ticketBalanceButton.backgroundColor = vkColorHex(0xFFF7F0);
        [ticketBalanceButton vk_border:nil cornerRadius:8];
        [_balanceBackView addSubview:ticketBalanceButton];
        self.ticketBalanceButton = ticketBalanceButton;
        [ticketBalanceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(amountBalanceButton.mas_right).offset(24);
            make.top.bottom.width.mas_equalTo(amountBalanceButton);
        }];
    }
    return _balanceBackView;
}

- (void)setupView {
    UIView *backMaskView = [UIView new];
    backMaskView.backgroundColor = vkColorHex(0xF0F0F0);
    [backMaskView vk_border:nil cornerRadius:20];
    [self addSubview:backMaskView];
    [backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(85);
        make.width.mas_equalTo(VKPX(320));
    }];
    
    UIImageView *iconImgView = [UIImageView new];
    iconImgView.image = [ImageBundle imagewithBundleName:@"video_pay_top_ic"];
    [self addSubview:iconImgView];
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.height.mas_equalTo(170);
    }];
    
    UIView *topBackView = [UIView new];
    [backMaskView addSubview:topBackView];
    self.topBackView = topBackView;
    [topBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *messageLabel = [UIView vk_label:nil font:vkFontBold(22) color:vkColorHex(0x111118)];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [backMaskView addSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(topBackView.mas_bottom).offset(12);
    }];
    
    VKButton *openVipButton = [VKButton new];
    [openVipButton vk_button:YZMsg(@"movie_open_vip") image:@"HotHeaderRightArrowIcon" font:vkFont(12) color:vkColorHex(0x552E5C)];
    openVipButton.spacingBetweenImage = 5;
    openVipButton.imagePosition = VKButtonImagePositionRight;
    openVipButton.cornerRadius = VKButtonCornerRadiusAdjustsBounds;
    [openVipButton vk_addTapAction:self selector:@selector(clickOpenVipAction)];
    openVipButton.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
    [backMaskView addSubview:openVipButton];
    self.openVipButton = openVipButton;
    [openVipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(messageLabel.mas_bottom).offset(10);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = 12;
    [backMaskView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(100);
        make.top.mas_equalTo(openVipButton.mas_bottom).offset(10);
    }];
    
    UIButton *ticketButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ticketButton.titleLabel.numberOfLines = 0;
    ticketButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [ticketButton vk_border:vkColorHex(0xFFC663) cornerRadius:8];
    [ticketButton vk_addTapAction:self selector:@selector(clickTicketAction)];
    [stackView addArrangedSubview:ticketButton];
    self.ticketButton = ticketButton;
    [ticketButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VKPX(135));
    }];
    
    UIButton *amountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    amountButton.titleLabel.numberOfLines = 0;
    amountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    amountButton.layer.borderColor = vkColorHex(0xFFC663).CGColor;
    [amountButton vk_border:vkColorHex(0xFFC663) cornerRadius:8];
    [amountButton vk_addTapAction:self selector:@selector(clickAmountAction)];
    [stackView addArrangedSubview:amountButton];
    self.amountButton = amountButton;
    [amountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VKPX(135));
    }];
    
    [backMaskView addSubview:self.balanceBackView];
    [self.balanceBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.right.mas_equalTo(-18);
        make.top.mas_equalTo(stackView.mas_bottom).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    VKButton *buyMoreButton = [VKButton new];
    [buyMoreButton vk_button:YZMsg(@"movie_ticket_tip") image:@"video_pay_arrow_pink" font:vkFont(12) color:vkColorHex(0xF251BB)];
    buyMoreButton.spacingBetweenImage = 5;
    buyMoreButton.imagePosition = VKButtonImagePositionRight;
    [buyMoreButton vk_addTapAction:self selector:@selector(clickBuyMoreAction)];
    [backMaskView addSubview:buyMoreButton];
    self.buyMoreButton = buyMoreButton;
    [buyMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.balanceBackView.mas_bottom).offset(10);
    }];
    
    UIButton *cancelButton = [UIView vk_button:YZMsg(@"public_cancel") image:nil font:vkFont(16) color:vkColorHex(0xF2DEC2)];
    [cancelButton vk_border:nil cornerRadius:19];
    cancelButton.backgroundColor = vkColorHex(0x383733);
    [cancelButton vk_addTapAction:self selector:@selector(clickCancelAction)];
    [backMaskView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(28);
        make.bottom.mas_equalTo(-32);
        make.height.mas_equalTo(38);
        make.top.mas_equalTo(buyMoreButton.mas_bottom).offset(10);
    }];
    
    UIButton *confirmButton = [UIView vk_button:YZMsg(@"publictool_sure") image:nil font:vkFont(16) color:vkColorHex(0x382814)];
    [confirmButton vk_border:nil cornerRadius:19];
    [confirmButton vk_addTapAction:self selector:@selector(clickConfirmAction)];
    [backMaskView addSubview:confirmButton];
    self.confirmButton = confirmButton;
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-28);
        make.left.mas_equalTo(cancelButton.mas_right).offset(26);
        make.height.width.top.mas_equalTo(cancelButton);
    }];
}

- (void)showFromCenter {
    [super showFromCenter];
        
    NSMutableAttributedString *ticketText = [NSMutableAttributedString new];
    [ticketText vk_appendString:[NSString stringWithFormat:@"%ld", self.ticket_cost] color:vkColorHex(0x111118) font:vkFontBold(26)];
    [ticketText vk_appendString:YZMsg(@"movie_ticket_unit") color:vkColorHex(0x111118) font:vkFont(14)];
    [ticketText vk_appendString:@"\n"];
    [ticketText vk_setLineSpacing:10 alignment:NSTextAlignmentCenter];
    [ticketText vk_appendString:YZMsg(@"movie_ticket_name") color:vkColorHex(0x919191) font:vkFont(12)];
    [self.ticketButton setAttributedTitle:ticketText forState:UIControlStateNormal];
    
    NSMutableAttributedString *amountText = [NSMutableAttributedString new];
    NSString *amount = [NSString stringWithFormat:@"%ld", self.coin_cost];
    amount = [YBToolClass getRateBalance:amount showUnit:NO];
    [amountText vk_appendString:amount color:vkColorHex(0x111118) font:vkFontBold(26)];
    [amountText vk_appendString:[Config getRegionCurrenyChar] color:vkColorHex(0x111118) font:vkFont(12)];
    [amountText vk_appendString:@"\n"];
    [amountText vk_setLineSpacing:10 alignment:NSTextAlignmentCenter];
    [amountText vk_appendString:YZMsg(@"movie_money_pay_title") color:vkColorHex(0x919191) font:vkFont(14)];
    [self.amountButton setAttributedTitle:amountText forState:UIControlStateNormal];
    
    NSArray *videoTickets = [Config getVideoTickets];
    NSNumber *total = [videoTickets valueForKeyPath:@"@sum.ticket_count"];
    [self.ticketBalanceButton setTitle:[NSString stringWithFormat:@"%@:%@%@", YZMsg(@"movie_ticket_name"), total, YZMsg(@"movie_ticket_unit")] forState:UIControlStateNormal];
    [self.amountBalanceButton setTitle:[NSString stringWithFormat:@"%@:%@", YZMsg(@"LobbyBetConfirm_balance"), [YBToolClass getRateBalance:Config.myProfile.coin showUnit:YES]] forState:UIControlStateNormal];
    
    self.ticketButton.hidden = self.ticket_cost <= 0;
    self.amountButton.hidden = self.coin_cost <= 0;
    self.openVipButton.hidden = !(self.is_vip && [Config getVip_type].integerValue <= 0);
    
    if (!self.ticketButton.hidden) {
        NSMutableAttributedString *titleTip = [NSMutableAttributedString new];
        [titleTip vk_appendString:YZMsg(@"movie_pay_title") color:vkColorHex(0x111118) font:vkFontBold(22)];
        [titleTip vk_appendString:@"\n"];
        [titleTip vk_appendString:YZMsg(@"movie_money_pay_tip3") color:vkColorHex(0x919191) font:vkFont(12)];
        self.messageLabel.attributedText = titleTip;
    } else {
        NSMutableAttributedString *titleTip = [NSMutableAttributedString new];
        [titleTip vk_appendString:YZMsg(@"movie_money_pay_tip") color:vkColorHex(0x111118) font:vkFontBold(22)];
        [titleTip vk_appendString:@"\n"];
        [titleTip vk_appendString:YZMsg(@"movie_money_pay_tip2") color:vkColorHex(0x919191) font:vkFont(12)];
        self.messageLabel.attributedText = titleTip;
    }
    
    /// 默认选中
    if (!self.ticketButton.hidden) {
        [self clickTicketAction];
    } else {
        [self clickAmountAction];
    }
    
    [self shakeOpenVip];
}

/// 抖动效果
- (void)shakeOpenVip {
    if (self.openVipButton.isHidden) {
        return;
    }
    WeakSelf
    [self.openVipButton shakeWithOptions:kDefaultShakeOptions force:0.15 duration:0.3 iterationDuration:0.02 completionHandler:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf performSelector:@selector(shakeOpenVip) withObject:nil afterDelay:1.5f];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topBackView.verticalColors = @[vkColorHex(0xFFE9CC), vkColorHex(0xF0F0F0)];
    self.openVipButton.horizontalColors = @[vkColorHex(0xFAE2B0), vkColorHex(0xF7CE7A)];
}

- (void)clickTicketAction {
    self.ticketButton.layer.borderWidth = 1.0;
    self.ticketButton.selected = YES;
    self.ticketButton.backgroundColor = vkColorHex(0xFFF7F0);
    self.amountButton.layer.borderWidth = 0.0;
    self.amountButton.selected = NO;
    self.amountButton.backgroundColor = vkColorHexA(0x919191, 0.08);
    
    NSArray *videoTickets = [Config getVideoTickets];
    NSNumber *total = [videoTickets valueForKeyPath:@"@sum.ticket_count"];
    self.buyMoreButton.hidden = total.integerValue >= self.ticket_cost;
    [self.buyMoreButton setTitle:YZMsg(@"movie_ticket_tip") forState:UIControlStateNormal];
    self.confirmButton.enabled = (self.buyMoreButton.hidden && self.openVipButton.hidden);
    self.confirmButton.backgroundColor = self.confirmButton.enabled ? vkColorHex(0xFFC663) : vkColorHex(0xFFEBC1);
}

- (void)clickAmountAction {
    self.ticketButton.layer.borderWidth = 0.0;
    self.ticketButton.selected = NO;
    self.ticketButton.backgroundColor = vkColorHexA(0x919191, 0.08);
    self.amountButton.layer.borderWidth = 1.0;
    self.amountButton.selected = YES;
    self.amountButton.backgroundColor = vkColorHex(0xFFF7F0);
    
    self.buyMoreButton.hidden = [NSString toAmount:Config.myProfile.coin].doubleValue >= [NSString toAmount:[@(self.coin_cost) stringValue]].doubleValue;
    [self.buyMoreButton setTitle:YZMsg(@"movie_amount_tip") forState:UIControlStateNormal];
    self.confirmButton.enabled = (self.buyMoreButton.hidden && self.openVipButton.hidden);
    self.confirmButton.backgroundColor = self.confirmButton.enabled ? vkColorHex(0xFFC663) : vkColorHex(0xFFEBC1);
}

- (void)clickOpenVipAction {
    [self hideAlert:^{
        VipPayAlertView *view = [VipPayAlertView new];
        [view showFromBottom];
    }];
}

- (void)clickBuyMoreAction {
    WeakSelf
    [self hideAlert:^{
        STRONGSELF
        if (!strongSelf) return;
        if (strongSelf.ticketButton.selected) {
            
            GameHomeMainVC *VC = [[GameHomeMainVC alloc] init];
            [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            
        } else if (strongSelf.amountButton.selected) {
            
            [YBUserInfoManager.sharedManager pushToRecharge];
        }
    }];
}

- (void)clickCancelAction {
    [self hideAlert:nil];
}

- (void)clickConfirmAction {
    NSInteger type = self.ticketButton.selected ? 0 : 1;
    _weakify(self)
    [self hideAlert:^{
        _strongify(self)
        !self.clickPayBlock ?: self.clickPayBlock(type);
    }];
    NSString *event;
    if (self.videoType == 1) {
        event = self.is_vip ? @"skit_pay_vip_click" : @"skit_pay_type_click";
    } else if (self.videoType == 2) {
        event = @"";
    } else if (self.videoType == 3) {
        event = self.is_vip ? @"longvideo_pay_vip_type_click" : @"longvideo_pay_type_click";
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"pay_type": type == 0 ? @"观影卷" : @"余额"};
    [MobClick event:event attributes:dict];
}
@end
