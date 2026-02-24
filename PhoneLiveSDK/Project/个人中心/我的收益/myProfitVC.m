//
//  myProfitVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "myProfitVC.h"
#import "profitTypeVC.h"
#import "webH5.h"
#import "UIButton+Additions.h"
#import "withdrawPopView.h"
#import "BindPhoneNumberViewController.h"
#import "UIView+GYPop.h"
@interface myProfitVC () <UITextFieldDelegate> {
    UILabel *nowVotesL;
    UITextField *votesT;
    UILabel *moneyLabel;
    UILabel *typeLabel;
    NSString *cash_rate;
    UIButton *inputBtn;
    UILabel *tipsLabel;
    NSDictionary *typeDic;
    UIImageView *seletTypeImgView;
}
@property (nonatomic, strong) withdrawPopView *withdrawPopView;


@end

@implementation myProfitVC
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc]init];
    label.text = _titleStr;
    [label setFont:navtionTitleFont];
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0, statusbarHeight, _window_width/2, 64)];
    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:bigBTN];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    UIButton *btnttttt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnttttt.backgroundColor = [UIColor clearColor];
    [btnttttt addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    btnttttt.frame = CGRectMake(0,0,100,64);
    [navtion addSubview:btnttttt];
    
    
    UIButton *historyBtn = [UIButton buttonWithType:0];
    historyBtn.frame = CGRectMake(_window_width-75, 24+statusbarHeight, 65, 40);
    [historyBtn setTitle:YZMsg(@"myProfitVC_WithDrawRecord") forState:0];
    [historyBtn setTitleColor:[UIColor grayColor] forState:0];
    historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    historyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    historyBtn.titleLabel.minimumScaleFactor = 0.5;
    [historyBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:historyBtn];

    [self.view addSubview:navtion];
}
- (void)addBtnClick:(UIButton *)sender{
    webH5 *web = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=cash&a=index&uid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnToken]];
    if (_isCreator) {
        url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=Crcash&a=index&uid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnToken]];
    }
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    web.urls = url;
    [self.navigationController pushViewController:web animated:YES];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bgImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bgImgV.image = [ImageBundle imagewithBundleName:@"withdraw_bg"];
    [self.view addSubview:bgImgV];

    self.view.backgroundColor = RGB(244, 245, 246);
    [self navtion];
    [self creatUI];
    [self requestData];
}
- (void)requestData{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getProfit" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            //获取收益
            NSString *f_str =  [[info firstObject] valueForKey:@"votes"];
            if (strongSelf.isCreator) {
                f_str =  [[info firstObject] valueForKey:@"creator_coin"];
            }
            NSString *l_str = [NSString stringWithFormat:@"≈%@(%@)", [YBToolClass getRateCurrency:f_str showUnit:YES], [Config getRegionCurreny]];
            NSString *str = [NSString stringWithFormat:@"%@ %@", f_str, l_str];
            NSMutableAttributedString *mub_str = [[NSMutableAttributedString alloc] initWithString:str];
            [mub_str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mub_str.length)];
            [mub_str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22] range:NSMakeRange(0, f_str.length)];
            [mub_str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(f_str.length+1, l_str.length)];
            strongSelf->nowVotesL.attributedText = mub_str;
//            self.withdraw.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"todaycash"]];
            //strongSelf->allVotesL.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"votestotal"]];//收益 魅力值
            if (strongSelf.isCreator) {
                strongSelf->cash_rate = minstr([[info firstObject] valueForKey:@"creator_cash_rate"]);
            }else{
                strongSelf->cash_rate = minstr([[info firstObject] valueForKey:@"cash_rate"]);
            }
            
            NSString *tips = minstr([[info firstObject] valueForKey:@"tips"]);
            
            if (strongSelf.isCreator) {
                NSString *tips = minstr([[info firstObject] valueForKey:@"creator_tips"]);
            }
            CGFloat height = [[YBToolClass sharedInstance] heightOfString:tips andFont:[UIFont systemFontOfSize:11] andWidth:_window_width*0.7-30];
            strongSelf->tipsLabel.text = tips;
            strongSelf->tipsLabel.height = height;
            NSLog(@"收益数据........%@",info);
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
- (void)tapClick{
    [votesT resignFirstResponder];
}
- (void)creatUI{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    
    //黄色背景图
    /*
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.04, 64+statusbarHeight+10, _window_width*0.92, _window_width*0.92*24/69)];
    backImgView.image = [ImageBundle imagewithBundleName:@"profitBg"];
    [self.view addSubview:backImgView];
    
    for (int i = 0; i < 4; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(backImgView.width/2*(i%2), backImgView.height/4*(i/2+1), backImgView.width/2, backImgView.height/4)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        if (i<2) {
            label.font = [UIFont systemFontOfSize:15];
            if (i == 0) {
                label.text = [NSString stringWithFormat:YZMsg(@"myProfitVC_totalNum%@"),[common name_votes]];
            }else{
                label.text = [NSString stringWithFormat:YZMsg(@"myProfitVC_WithDrawTotal%@"),[common name_votes]];
                [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(backImgView.width/2-0.5, backImgView.height/4, 1, backImgView.height/2) andColor:[UIColor whiteColor] andView:backImgView];
            }
        }else{
            label.font = [UIFont boldSystemFontOfSize:22];
            label.text = @"0";
            if (i == 2) {
                allVotesL = label;
            }else{
                nowVotesL = label;
            }
        }
        [backImgView addSubview:label];
    }
     */
    //背景图
    CGFloat space = _window_width*0.04;
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(space, 64+statusbarHeight+10, _window_width - (space * 2), _window_width*24/69)];
//    backImgView.clipsToBounds = true;
    backImgView.image = [ImageBundle imagewithBundleName:@"exchange_balance_bottom"];
    backImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backImgView];
    
    for (int i = 0; i < 2; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_window_width*0.06, backImgView.height/4*(i+1), _window_width * 0.88, backImgView.height/4)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor whiteColor];
        if (i==0) {
            label.font = [UIFont systemFontOfSize:15];
            label.text = [NSString stringWithFormat:YZMsg(@"myProfitVC_WithDrawTotal%@"),[common name_votes]];
        }else{
            label.font = [UIFont boldSystemFontOfSize:22];
            label.text = @"0";
            nowVotesL = label;
        }
        [backImgView addSubview:label];
    }
    //输入提现金额的视图
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, backImgView.bottom+10, backImgView.width, backImgView.height)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [self.view addSubview:textView];
    NSArray *arr = @[[NSString stringWithFormat:YZMsg(@"myProfitVC_WithDraw_input%@"),[common name_votes]],YZMsg(@"myProfitVC_To_account_num")];
    for (int i = 0; i<2; i++) {
        CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:arr[i] andFont:[UIFont systemFontOfSize:15] andHeight:textView.height/2];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, textView.height/2*i, labelW+20, textView.height/2)];
        label.textColor = RGB_COLOR(@"#333333", 1);
        label.font = [UIFont systemFontOfSize:15];
        label.text = arr[i];
        [textView addSubview:label];
        if (i == 0) {
            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(textView.width*0.05, textView.height/2-0.5, textView.width*0.9, 1) andColor:RGB(244, 245, 246) andView:textView];
            votesT = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, textView.width*0.95-label.right, textView.height/2)];
            votesT.textColor = normalColors;
            votesT.font = [UIFont boldSystemFontOfSize:17];
            votesT.placeholder = @"0";
            votesT.keyboardType = UIKeyboardTypeNumberPad;
            votesT.delegate = self;
            [textView addSubview:votesT];
        }else{
            moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, textView.width*0.95-label.right, textView.height/2)];
            moneyLabel.textColor = [UIColor redColor];
            moneyLabel.font = [UIFont boldSystemFontOfSize:17];
            moneyLabel.text = @"0";
            [textView addSubview:moneyLabel];
        }
    }
    //提示
    tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, textView.bottom+5, _window_width - 20, 30)];
    tipsLabel.font = [UIFont systemFontOfSize:11];
    tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
    tipsLabel.numberOfLines = 0;
    [self.view addSubview:tipsLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidChangeNotification object:nil];
    
    //选择提现账户
    
    UIView *typeView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left + 10, tipsLabel.bottom+5, backImgView.width - 20, 50)];
    typeView.backgroundColor = [UIColor whiteColor];
    typeView.layer.cornerRadius = 5.0;
    typeView.layer.masksToBounds = YES;
    [self.view addSubview:typeView];
    typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, 0, typeView.width*0.95-40, 50)];
    typeLabel.textColor = RGB_COLOR(@"#333333", 1);
    typeLabel.font = [UIFont systemFontOfSize:15];
    typeLabel.text = YZMsg(@"myProfitVC_choise_withDraw_account");
    [typeView addSubview:typeLabel];
    seletTypeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeLabel.left, 15, 20, 20)];
    seletTypeImgView.hidden = YES;
    [typeView addSubview:seletTypeImgView];
    
    UIImageView *rightImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeView.width-30, 18, 14, 14)];
    rightImgView.image = [ImageBundle imagewithBundleName:@"person_right"];
    rightImgView.userInteractionEnabled = YES;
    [typeView addSubview:rightImgView];

    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(0, 0, typeView.width, typeView.height);
    [btn addTarget:self action:@selector(selectPayType) forControlEvents:UIControlEventTouchUpInside];
    [typeView addSubview:btn];
    //提示2
    UILabel *tip2Label = [[UILabel alloc]initWithFrame:CGRectMake(10, typeView.bottom + 5, _window_width-20, 30)];
    tip2Label.font = [UIFont systemFontOfSize:11];
    tip2Label.tag = 1201;
    tip2Label.textColor = RGB_COLOR(@"#666666", 1);
    [tip2Label setTextAlignment:NSTextAlignmentCenter];
    tip2Label.text = YZMsg(@"AddCard_Transfor_tip");
    tip2Label.numberOfLines = 0;
    [tip2Label sizeToFit];
    [self.view addSubview:tip2Label];
    
    inputBtn = [UIButton buttonWithType:0];
    inputBtn.frame = CGRectMake(space, tip2Label.bottom + 5, _window_width - (space * 2), 40);
//    [inputBtn addGradientButton:NULL endColor:NULL];
//    [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
//    [inputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"btn_anniu"]];

    UIImage *submitWithdraw = [ImageBundle imagewithBundleName:@"submit_withdraw"];
    UIEdgeInsets insets = UIEdgeInsetsMake(submitWithdraw.size.height/2.0,
                                           submitWithdraw.size.width/2.0,
                                           submitWithdraw.size.height/2.0,
                                           submitWithdraw.size.width/2.0);
    submitWithdraw = [submitWithdraw resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
//    [inputBtn setBackgroundImage:submitWithdraw];
    [inputBtn setBackgroundImage:submitWithdraw forState:UIControlStateNormal];

    [inputBtn setTitle:YZMsg(@"myProfitVC_withDraw_now") forState:0];
    [inputBtn addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
    inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    inputBtn.layer.cornerRadius = 6;
    inputBtn.layer.masksToBounds = YES;
    inputBtn.userInteractionEnabled = NO;
    [self.view addSubview:inputBtn];

}
//选择z提现方式
- (void)selectPayType{
    profitTypeVC *vc = [[profitTypeVC alloc]init];
    if (typeDic) {
        vc.selectID = minstr([typeDic valueForKey:@"id"]);
    }else{
        vc.selectID = YZMsg(@"myProfitVC_NoWithDrawError");
    }
    vc.typeNum = -1;
    WeakSelf
    vc.block = ^(NSDictionary * _Nonnull dic) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->typeDic = dic;
        strongSelf->seletTypeImgView.hidden = NO;
        strongSelf->typeLabel.x = strongSelf->seletTypeImgView.right + 5;
        int type = [minstr([dic valueForKey:@"type"]) intValue];
        switch (type) {
            case 1:
                strongSelf->seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_alipay"];
                strongSelf->typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
            case 2:
                strongSelf->seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_wx"];
                strongSelf->typeLabel.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];

                break;
            case 3:
                strongSelf->seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
                strongSelf->typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
                
            default:
                strongSelf->seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
                strongSelf->typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
                break;
        }

    };
    [self.navigationController pushViewController:vc animated:YES];
}
//提交申请
- (void)inputBtnClick{
    NSDictionary *withdrawInfo = [Config getWithdrawInfo];
    if (![withdrawInfo isKindOfClass:[NSDictionary class]] || withdrawInfo == nil) {
        withdrawInfo = @{};
    }
    BOOL isWithdrawable = [withdrawInfo[@"isWithdrawable"] boolValue];
    if (!isWithdrawable) {
        [self.view gy_creatPopViewWithContentView:self.withdrawPopView withContentViewSize:CGSizeMake(_window_width * 0.8,186)];
        return;
    }
    if(!typeDic){
        [MBProgressHUD showError:YZMsg(@"myProfitVC_choise_withDraw_account")];
        return;
    }
    NSString *moneyRMB = [YBToolClass getRmbCurrency:votesT.text];
    
    NSDictionary *dic = @{@"accountid":minstr([typeDic valueForKey:@"id"]),@"cashvote":moneyRMB};
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:_isCreator?@"User.setCrcash":@"User.setCash" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf->votesT.text = @"";
            [MBProgressHUD showError:msg];
            [strongSelf requestData];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}

- (void)ChangeMoenyLabelValue {
    if (votesT.text.length < 1) {
        votesT.text = @"0"; // 如果没有输入内容，显示 0
    }

    NSDecimalNumber *finalMoney = [NSDecimalNumber decimalNumberWithString:votesT.text];
    if (cash_rate.floatValue > 0) {
        finalMoney = [finalMoney decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:cash_rate]];
    }
    
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                         decimalNumberHandlerWithRoundingMode:NSRoundDown
                                         scale:2
                                         raiseOnExactness:NO
                                         raiseOnOverflow:NO
                                         raiseOnUnderflow:NO
                                         raiseOnDivideByZero:YES];

    NSDecimalNumber *leftCoin = [finalMoney decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
    NSString *result = [NSString stringWithFormat:@"%.0f", leftCoin.doubleValue];
    moneyLabel.text = result;

    inputBtn.userInteractionEnabled = (finalMoney.doubleValue > 0);
}


-(withdrawPopView *)withdrawPopView{
    if (!_withdrawPopView) {
        _withdrawPopView = [[withdrawPopView alloc] init];
        NSDictionary *withdrawInfo = [Config getWithdrawInfo];
        if (![withdrawInfo isKindOfClass:[NSDictionary class]] || withdrawInfo == nil) {
            withdrawInfo = @{};
        }
        NSString *msg = withdrawInfo[@"msg"];
        NSString *jump = withdrawInfo[@"jump"];
        _withdrawPopView.billingLab.text = msg;
        WeakSelf
        self.withdrawPopView.submitBtnClickBlock  = ^(UIButton * _Nonnull sender) {
            [weakSelf.view gy_popViewdismiss];
            if ([jump isKindOfClass:[NSString class]] && jump.length > 0) {
                NSDictionary *data = @{@"scheme": jump};
                [[YBUserInfoManager sharedManager] pushVC:data viewController:nil];
            }
        };
        self.withdrawPopView.cancelBtnClickBlock =  ^(UIButton * _Nonnull sender) {
            [weakSelf.view gy_popViewdismiss];
        };
    }
    return _withdrawPopView;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@"0"]) {
        textField.text = @""; // 开始编辑时，清空默认的 "0"
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 检查是否是 `votesT` 输入框
    if (textField == votesT) {
        // 获取替换后的完整字符串
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];

        // 如果输入框当前是 "0"，并且用户输入的不是删除键（即非空字符串）
        if ([textField.text isEqualToString:@"0"] && ![string isEqualToString:@""]) {
            textField.text = string; // 将 "0" 替换为用户输入的内容
            return NO; // 阻止默认行为
        }

        // 如果更新后的文本为空字符串，允许它设置为空，稍后结束编辑时会恢复为 "0"
        if (updatedText.length == 0) {
            return YES;
        }

        // 如果用户输入的内容是非数字字符，则阻止输入
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([string rangeOfCharacterFromSet:nonNumberSet].location != NSNotFound) {
            return NO;
        }
    }
    return YES; // 允许其他情况的输入
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == votesT && textField.text.length == 0) {
        textField.text = @"0"; // 恢复为默认值
    }
}

@end
