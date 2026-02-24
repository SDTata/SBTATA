//
//  TaskSignInAlertView.m
//  phonelive2
//
//  Created by vick on 2024/9/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskSignInAlertView.h"

@interface TaskSignInAlertView ()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *amountLabel;

@end

@implementation TaskSignInAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"task_sign_bg"];
    [self addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-30);
        make.height.mas_equalTo(VKPX(320));
    }];
    
    UIButton *closeButton = [UIView vk_buttonImage:@"live_hundred_bull_history_dialog_close" selected:nil];
    [closeButton vk_addTapAction:self selector:@selector(clickCloseAction)];
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(30);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"task_reward_alert_tip") font:vkFontBold(28) color:vkColorHex(0xbb67ff)];
    [backImgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(VKPX(68));
        make.top.mas_equalTo(VKPX(132));
    }];
    
    UILabel *messageLabel = [UIView vk_label:nil font:vkFontMedium(16) color:UIColor.blackColor];
    [backImgView addSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(VKPX(10));
    }];
    
    UIView *amountBackView = [UIView new];
    amountBackView.backgroundColor = vkColorHex(0xe3e6f1);
    [amountBackView vk_border:vkColorHexA(0xffffe5, 0.9) cornerRadius:15];
    [backImgView addSubview:amountBackView];
    [amountBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(150);
        make.top.mas_equalTo(messageLabel.mas_bottom).offset(VKPX(10));
    }];
    {
        UILabel *amountLabel = [UIView vk_label:nil font:vkFontMedium(14) color:vkColorHex(0x97a4b0)];
        amountLabel.textAlignment = NSTextAlignmentCenter;
        [amountBackView addSubview:amountLabel];
        self.amountLabel = amountLabel;
        [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.left.mas_equalTo(10);
            make.centerY.mas_equalTo(0);
        }];
    }
    
    UILabel *tipLabel = [UIView vk_label:YZMsg(@"task_reward_alert_success") font:vkFont(14) color:UIColor.whiteColor];
    [backImgView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(amountBackView.mas_bottom).offset(VKPX(40));
    }];
}

- (void)setRewardModel:(RewardHomeModel *)rewardModel {
    _rewardModel = rewardModel;
    
    self.messageLabel.text = rewardModel.name;
    self.amountLabel.attributedText = rewardModel.itemText;
}

- (void)clickCloseAction {
    [self hideAlert:nil];
}

@end
