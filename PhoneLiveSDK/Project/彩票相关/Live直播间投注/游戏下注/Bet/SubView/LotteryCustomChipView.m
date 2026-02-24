//
//  LotteryCustomChipView.m
//  phonelive2
//
//  Created by vick on 2024/12/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryCustomChipView.h"

@interface LotteryCustomChipView ()

@property (nonatomic, strong) UIButton *maxButton;
@property (nonatomic, strong) UIButton *halfButton;
@property (nonatomic, strong) UIButton *doubleButton;
@property (nonatomic, strong) UITextField *amountLabel;
@property (nonatomic, assign) double baseRMB;

@end

@implementation LotteryCustomChipView

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
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VKPX(300));
        make.height.mas_equalTo(160);
    }];
    
    UITextField *amountLabel = [UITextField new];
    self.baseRMB = [common getCustomChipNum] ? [common getCustomChipNum] : 2;
    amountLabel.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", self.baseRMB] showUnit: NO];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.textColor = RGB(91, 100, 126);
    amountLabel.font = vkFont(16);
    amountLabel.keyboardType = UIKeyboardTypeNumberPad;
    [amountLabel addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [amountLabel becomeFirstResponder];
    
    UILabel *unitLabel = [UILabel new];
    unitLabel.textColor = RGB(91, 100, 126);
    unitLabel.font = vkFont(16);
    unitLabel.frame = CGRectMake(0, 0, 40, 60);
    unitLabel.text = [Config getRegionCurrenyChar];
    amountLabel.leftView = unitLabel;
    amountLabel.leftViewMode = UITextFieldViewModeAlways;
    
    [self addSubview:amountLabel];
    self.amountLabel = amountLabel;
    
    UIButton *maxButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 60)];
    [maxButton setTitle: YZMsg(@"MaxMoney") forState: UIControlStateNormal];
    [maxButton setTitleColor:RGB(115, 119, 119) forState:UIControlStateNormal];
    [maxButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [maxButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [maxButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_max_button_normal"] forState:UIControlStateNormal];
    [maxButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_max_button_selected"] forState:UIControlStateSelected];
    [maxButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_max_button_selected"] forState:UIControlStateHighlighted];
    maxButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    maxButton.tag = 1;
    [maxButton addTarget:self action:@selector(customChipAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:maxButton];
    self.maxButton = maxButton;
    
    UIButton *halfButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-50, 10, 40, 29)];
    [halfButton setTitle: @"1/2" forState: UIControlStateNormal];
    [halfButton setTitleColor:RGB(115, 119, 119) forState:UIControlStateNormal];
    [halfButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [halfButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [halfButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_normal"] forState:UIControlStateNormal];
    [halfButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateSelected];
    [halfButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateHighlighted];
    halfButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    halfButton.tag = 2;
    [halfButton addTarget:self action:@selector(customChipAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:halfButton];
    self.halfButton = halfButton;
    
    UIButton *doubleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-50, 42, 40, 29)];
    [doubleButton setTitle: @"2x" forState: UIControlStateNormal];
    [doubleButton setTitleColor:RGB(115, 119, 119) forState:UIControlStateNormal];
    [doubleButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [doubleButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [doubleButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_normal"] forState:UIControlStateNormal];
    [doubleButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateSelected];
    [doubleButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateHighlighted];
    doubleButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    doubleButton.tag = 3;
    [doubleButton addTarget:self action:@selector(customChipAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doubleButton];
    self.doubleButton = doubleButton;
    
    [maxButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(18);
        make.leading.mas_equalTo(self.mas_leading).offset(20);
        make.height.mas_equalTo(74);
        make.width.mas_equalTo(46);
    }];
    
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(100);
        make.height.centerY.mas_equalTo(maxButton);
    }];
    
    [halfButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).inset(20);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(46);
        make.top.mas_equalTo(maxButton);
    }];
    
    [doubleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(halfButton.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing).inset(20);
        make.height.mas_equalTo(36);
        make.width.mas_equalTo(46);
        make.bottom.mas_equalTo(maxButton);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [cancelBtn setTitle:YZMsg(@"public_back") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_cancel_button"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(clickCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(maxButton.mas_leading);
        make.trailing.mas_equalTo(self.mas_centerX).inset(5);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.mas_bottom).inset(10);
    }];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    confirmBtn.frame = CGRectMake(self.frame.size.width/2, 100+30, self.frame.size.width/2, 40);
    [confirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
    [confirmBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_confirm_button"] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(clickConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(halfButton.mas_trailing);
        make.leading.mas_equalTo(self.mas_centerX).offset(5);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.mas_bottom).inset(10);
    }];
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.baseRMB = textField.text.integerValue;
   
    
}

- (void)customChipAction:(UIButton *)sender {
    if (sender.tag == 1) {
        self.baseRMB = 50000;
        [self.maxButton setSelected:YES];
        [self.halfButton setSelected:NO];
        [self.doubleButton setSelected:NO];
    } else if (sender.tag == 2){
        self.baseRMB = (self.baseRMB > 2) ? (self.baseRMB/2 > 2 ? self.baseRMB/2 : 2) : 2;
        [self.maxButton setSelected:NO];
        [self.halfButton setSelected:YES];
        [self.doubleButton setSelected:NO];
    } else {
        self.baseRMB = (self.baseRMB >= 2 && self.baseRMB < 50000 )? (self.baseRMB*2 < 50000 ? self.baseRMB*2 : 50000) : 50000;
        [self.maxButton setSelected:NO];
        [self.halfButton setSelected:NO];
        [self.doubleButton setSelected:YES];
    }
    self.amountLabel.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", self.baseRMB] showUnit: NO];
}

- (void)clickCancelAction {
    [self hideAlert:nil];
}

- (void)clickConfirmAction {
    if (self.baseRMB <= 0) {
        return;
    }
    NSString *rmbStr = [YBToolClass getRmbCurrency:[NSString stringWithFormat:@"%.5f",self.baseRMB]];
    if ([rmbStr doubleValue]<2) {
        self.baseRMB =  [[YBToolClass getRateCurrency:@"2" showUnit: NO] doubleValue];
    }
    
    [common saveCustomChipNum:self.baseRMB];
    [common saveCustomChipStr:[[[Config getRegionCurreny] stringByAppendingString:@"+"] stringByAppendingString: [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", self.baseRMB] showUnit: NO]]];
    if (self.clickConfirmBlock) {
        self.clickConfirmBlock(self.baseRMB);
    }
    [self hideAlert:nil];
}

@end
