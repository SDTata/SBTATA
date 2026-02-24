//
//  ArchorCmdEditAlertView.m
//  phonelive2
//
//  Created by vick on 2024/5/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ArchorCmdEditAlertView.h"

@interface ArchorCmdEditAlertView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *nameTF;
@property (nonatomic, strong) UITextField *priceTF;
@property (nonatomic, strong) UITextField *timeTF;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation ArchorCmdEditAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self updateView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self corner:VKCornerMaskTop radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(370+VK_BOTTOM_H);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.backgroundColor = vkColorHexA(0x919191, 0.08);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *nameLabel = [UIView vk_label:YZMsg(@"RemoteInterfaceView_cmd_name") font:vkFont(14) color:UIColor.blackColor];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.minimumScaleFactor = 0.1;
    [self addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(14);
    }];
    
    UITextField *nameTF = [UITextField new];
    nameTF.font = vkFont(14);
    nameTF.textColor = UIColor.blackColor;
    nameTF.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:nameTF];
    self.nameTF = nameTF;
    [nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(nameLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *timeLabel = [UIView vk_label:YZMsg(@"RemoteInterfaceView_cmd_time") font:vkFont(14) color:UIColor.blackColor];
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.minimumScaleFactor = 0.1;
    [self addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(nameTF.mas_bottom).offset(10);
    }];
    
    UITextField *timeTF = [UITextField new];
    timeTF.font = vkFont(14);
    timeTF.textColor = UIColor.blackColor;
    timeTF.keyboardType = UIKeyboardTypeNumberPad;
    timeTF.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:timeTF];
    self.timeTF = timeTF;
    [timeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(timeLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    NSString *string = [NSString stringWithFormat:@"%@(%@)", YZMsg(@"RemoteInterfaceView_cmd_price"), [Config getRegionCurreny]];
    UILabel *priceLabel = [UIView vk_label:string font:vkFont(14) color:UIColor.blackColor];
    priceLabel.adjustsFontSizeToFitWidth = YES;
    priceLabel.minimumScaleFactor = 0.1;
    [self addSubview:priceLabel];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(timeTF.mas_bottom).offset(10);
    }];
    
    UITextField *priceTF = [UITextField new];
    priceTF.font = vkFont(14);
    priceTF.textColor = UIColor.blackColor;
    priceTF.keyboardType = UIKeyboardTypeNumberPad;
    priceTF.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:priceTF];
    self.priceTF = priceTF;
    [priceTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(priceLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.spacing = 15;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-VK_BOTTOM_H-14);
        make.height.mas_equalTo(46);
    }];
    {
        UIButton *deleteButton = [UIView vk_button:YZMsg(@"RemoteInterfaceView_cmd_delete") image:nil font:vkFont(16) color:UIColor.blackColor];
        [deleteButton vk_border:vkColorHexA(0x919191, 0.2) cornerRadius:23];
        [deleteButton vk_addTapAction:self selector:@selector(clickDeleteAction)];
        [stackView addArrangedSubview:deleteButton];
        self.deleteButton = deleteButton;
        
        UIButton *editButton = [UIView vk_button:YZMsg(@"RemoteInterfaceView_cmd_edit") image:nil font:vkFont(16) color:UIColor.whiteColor];
        [editButton vk_border:nil cornerRadius:23];
        [editButton vk_addTapAction:self selector:@selector(clickEditAction)];
        [stackView addArrangedSubview:editButton];
        self.editButton = editButton;
        
        UIButton *addButton = [UIView vk_button:YZMsg(@"RemoteInterfaceView_cmd_confirm") image:nil font:vkFont(16) color:UIColor.whiteColor];
        [addButton vk_border:nil cornerRadius:23];
        [addButton vk_addTapAction:self selector:@selector(clickAddAction)];
        [stackView addArrangedSubview:addButton];
        self.addButton = addButton;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.editButton.horizontalColors = @[vkColorHex(0xFF838E), vkColorHex(0xFF63AC)];
    self.addButton.horizontalColors = @[vkColorHex(0xFF838E), vkColorHex(0xFF63AC)];
}

- (void)setModel:(RemoteOrderModel *)model {
    _model = model;
    [self updateView];
}

- (void)updateView {
    if (self.model) {
        self.titleLabel.text = @"修改指令";
        self.deleteButton.hidden = NO;
        self.editButton.hidden = NO;
        self.addButton.hidden = YES;
        self.nameTF.text = self.model.giftname;
        self.priceTF.text = [YBToolClass getRateCurrency:self.model.price showUnit:NO];
        self.timeTF.text = self.model.shocktime;
        if (self.model.cmdType.integerValue == 0) {
            self.nameTF.enabled = NO;
            self.nameTF.textColor = UIColor.lightGrayColor;
            self.deleteButton.hidden = YES;
        }
    } else {
        self.titleLabel.text = @"添加指令";
        self.deleteButton.hidden = YES;
        self.editButton.hidden = YES;
        self.addButton.hidden = NO;
    }
}

- (void)clickCloseAction {
    [self hideAlertWithPause:nil];
}

- (void)clickDeleteAction {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getLiveCmdDelete:self.model.ID block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [strongSelf doSuccessAction];
    }];
}

- (void)clickEditAction {
    if (![self checkInputStatus]) return;
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getLiveCmdEdit:self.model.ID
                                  type:self.model.cmdType
                                  name:self.nameTF.text
                                 price:[YBToolClass getRmbCurrency:self.priceTF.text]
                              duration:self.timeTF.text
                                 block:^(NetworkData *networkData)
     {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [strongSelf doSuccessAction];
    }];
}

- (void)clickAddAction {
    if (![self checkInputStatus]) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [LotteryNetworkUtil getLiveCmdAdd:self.nameTF.text
                                price:[YBToolClass getRmbCurrency:self.priceTF.text]
                             duration:self.timeTF.text
                                block:^(NetworkData *networkData)
     {
        [MBProgressHUD hideHUD];
        STRONGSELF
        if (!strongSelf) return;
      
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [strongSelf doSuccessAction];
    }];
}

- (void)doSuccessAction {
    [MBProgressHUD showSuccess:YZMsg(@"myRechargeCoinVC_OptionSuccess")];
    WeakSelf
    vkGcdAfter(1.0, ^{
        STRONGSELF
        if (!strongSelf) return;
        !strongSelf.refreshBlock ?: strongSelf.refreshBlock();
        [strongSelf clickCloseAction];
    });
}

- (BOOL)checkInputStatus {
    if (self.nameTF.text.length <= 0) {
        [MBProgressHUD showError:YZMsg(@"RemoteInterfaceView_cmd_input_name")];
        return NO;
    }
    if (self.priceTF.text.floatValue <= 0) {
        [MBProgressHUD showError:YZMsg(@"Livebroadcast_please_enterPrice")];
        return NO;
    }
    if (self.timeTF.text.floatValue <= 0) {
        [MBProgressHUD showError:YZMsg(@"RemoteInterfaceView_cmd_input_time")];
        return NO;
    }
    return YES;
}

@end
