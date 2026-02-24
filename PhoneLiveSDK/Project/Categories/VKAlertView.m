//
//  VKAlertView.m
//  phonelive2
//
//  Created by vick on 2024/9/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKAlertView.h"

@implementation VKAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    UIView *backMaskView = [UIView new];
    backMaskView.backgroundColor = UIColor.whiteColor;
    backMaskView.layer.cornerRadius = 20;
    backMaskView.layer.masksToBounds = YES;
    [self addSubview:backMaskView];
    self.backMaskView = backMaskView;
    [backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(VKPX(300));
    }];
    
    UIStackView *centerStackView = [UIStackView new];
    centerStackView.axis = UILayoutConstraintAxisVertical;
    centerStackView.alignment = UIStackViewAlignmentFill;
    centerStackView.spacing = 20;
    [backMaskView addSubview:centerStackView];
    self.centerStackView = centerStackView;
    [centerStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.backMaskView).insets(UIEdgeInsetsMake(20, 20, 20, 20));
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = vkFont(16);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColor.blackColor;
    [centerStackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.font = vkFont(14);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = UIColor.darkGrayColor;
    messageLabel.numberOfLines = 0;
    [centerStackView addArrangedSubview:messageLabel];
    self.messageLabel = messageLabel;
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_greaterThanOrEqualTo(30);
    }];
    
    UIStackView *buttonStackView = [UIStackView new];
    buttonStackView.axis = UILayoutConstraintAxisHorizontal;
    buttonStackView.alignment = UIStackViewAlignmentFill;
    buttonStackView.distribution = UIStackViewDistributionFillEqually;
    buttonStackView.spacing = 20;
    [centerStackView addArrangedSubview:buttonStackView];
    self.buttonStackView = buttonStackView;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font = vkFont(16);
    [cancelButton addTarget:self action:@selector(clickCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonStackView addArrangedSubview:cancelButton];
    self.cancelButton = cancelButton;
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    confirmButton.titleLabel.font = vkFont(16);
    [confirmButton addTarget:self action:@selector(clickConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonStackView addArrangedSubview:confirmButton];
    self.confirmButton = confirmButton;
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
    }];
    
    titleLabel.hidden = YES;
    messageLabel.hidden = YES;
    cancelButton.hidden = YES;
    confirmButton.hidden = YES;
    
    vkGcdAfter(0.0, ^{
        [confirmButton vk_border:nil cornerRadius:20];
        confirmButton.verticalColors = @[vkColorHex(0xd6a9ff), vkColorHex(0xbb67ff)];
        [confirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    });
}

- (void)clickCancelAction {
    [self hideAlert:self.cancelActionBlock];
}

- (void)clickConfirmAction {
    [self hideAlert:self.confirmActionBlock];
}

+ (void)showAlertTitle:(NSString *)title message:(NSString *)message cancelAction:(NSString *)cancelAction confirmAction:(NSString *)confirmAction cancelBlock:(void (^)(void))cancelBlock confirmBlock:(void (^)(void))confirmBlock {
    VKAlertView *alert = [[self class] new];
    alert.titleLabel.text = title;
    alert.titleLabel.hidden = !title;
    alert.messageLabel.text = message;
    alert.messageLabel.hidden = !message;
    [alert.cancelButton setTitle:cancelAction forState:UIControlStateNormal];
    alert.cancelButton.hidden = !cancelAction;
    [alert.confirmButton setTitle:confirmAction forState:UIControlStateNormal];
    alert.confirmButton.hidden = !confirmAction;
    alert.cancelActionBlock = cancelBlock;
    alert.confirmActionBlock = confirmBlock;
    [alert showFromCenter];
}

@end
