//
//  AnchorAmountAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/29.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorAmountAlertView.h"

@implementation AnchorAmountAlertView

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
    
    UILabel *titleLabel = [UIView vk_label:@"设置收费金额" font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(26);
    }];
    
    self.pickerView = [UIPickerView new];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.height.mas_equalTo(150);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.pickerView.mas_bottom).offset(14);
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
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSArray *arrays = [common live_time_coin];
    for (int i=0; i<arrays.count; i++) {
        NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(arrays[i]) showUnit:YES];
        NSString *path = [NSString stringWithFormat:@"%@/%@",currencyCoin,YZMsg(@"coastselectview_minue")];
        [dataArray addObject:path];
    }
    self.dataArray = dataArray;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.confirmButton.horizontalColors = @[vkColorHex(0xFF838E), vkColorHex(0xFF63AC)];
}

- (void)clickCancelAction {
    [self hideAlert:nil];
}

- (void)clickConfirmAction {
    [self hideAlert:nil];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dataArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"选择了：%@", self.dataArray[row]);
}

@end
