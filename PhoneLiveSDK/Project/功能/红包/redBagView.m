//
//  redBagView.m
//  yunbaolive
//
//  Created by Boom on 2018/11/16.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "redBagView.h"

@implementation redBagView{
    UIImageView *redView;
    UIImageView *leftImgView;
    UIImageView *rightImgView;
    UITextField *coinT;
    UITextField *numT;
    UILabel *rightLabel;
    UITextView *contentT;
    UIButton *timeTypeBtn;
    NSString *type;
    NSString *type_grant;
    UIButton *sendBtn;
    UILabel *llllLabel;
    int minCoin;
}
- (void)hidSelf{
    if (coinT.isFirstResponder || numT.isFirstResponder || contentT.isFirstResponder) {
        [coinT resignFirstResponder];
        [numT resignFirstResponder];
        [contentT resignFirstResponder];
        return;
    }
    self.block(@"909");
}
- (void)hidKeyBoard{
    [coinT resignFirstResponder];
    [numT resignFirstResponder];
    [contentT resignFirstResponder];
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        type = @"1";
        type_grant = @"1";
        minCoin = ceil(10 * [Config getExchangeRate].floatValue);
        [self creatUI];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeBtnBackground:) name:UIControlEventEditingChanged object:nil];

    }
    return self;
}
- (void)creatUI{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidSelf)];
    [self addGestureRecognizer:tap];
    redView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.14, _window_height, _window_width*0.72, _window_width*0.72*76/54)];
    redView.layer.cornerRadius = 10.0;
    redView.layer.masksToBounds =YES;
    redView.userInteractionEnabled = YES;
    redView.image = [ImageBundle imagewithBundleName:@"sendRed_back"];
    redView.center = self.center;
    [self addSubview:redView];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidKeyBoard)];
    [redView addGestureRecognizer:tap2];

    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(5, redView.height*1/76, redView.width-10, redView.height*7/76)];
    titleL.text = YZMsg(@"redBagView_redbagTitle");
    titleL.textColor = normalColors;
    titleL.font = [UIFont boldSystemFontOfSize:17];
    titleL.adjustsFontSizeToFitWidth = YES;
    titleL.minimumScaleFactor = 0.5;
    titleL.textAlignment = NSTextAlignmentCenter;
    [redView addSubview:titleL];
    
    UILabel *titleL2 = [[UILabel alloc]initWithFrame:CGRectMake(12, titleL.bottom, redView.width-20, redView.height*3/76)];
    titleL2.text = YZMsg(@"redBagView_sendRedBag");
    titleL2.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    titleL2.font = [UIFont systemFontOfSize:11];
    titleL2.textAlignment = NSTextAlignmentCenter;
//    titleL2.adjustsFontSizeToFitWidth = YES;
//    titleL2.minimumScaleFactor = 0.5;
    titleL2.numberOfLines = 2;
    [redView addSubview:titleL2];
    [titleL2 sizeToFit];
    NSArray *arr = @[YZMsg(@"redBagView_LuckyRedBag"),YZMsg(@"redBagView_average")];
    for (int i = 0; i < 2; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(redView.width/2-100 + 100*i, titleL2.bottom, 100, titleL.height);
        [btn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000+i;
        [redView addSubview:btn];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, btn.height/2-5, 10, 10)];
        [btn addSubview:imgView];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.right+8, imgView.top-5, 77, 20)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.3;
        label.text = arr[i];
        [btn addSubview:label];
        if (i == 0) {
            leftImgView = imgView;
            leftImgView.image = [ImageBundle imagewithBundleName:@"type_seleted@3x"];
        }else{
            rightImgView = imgView;
            rightImgView.image = [ImageBundle imagewithBundleName:@"type_unseleted@3x"];
        }
    }
    int height = 10;
    for (int i = 0; i < 3; i ++) {
        if (i == 2) {
            height = 12;
        }
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(redView.width*0.075, titleL2.bottom+redView.height*8/76+i * (redView.height*11/76), redView.width*0.85, redView.height*height/76)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
        [redView addSubview:view];
//        if (i == 0) {
//            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, view.height/3, 40, view.height/3)];
//            imgView.contentMode = UIViewContentModeScaleAspectFit;
//            imgView.image = [ImageBundle imagewithBundleName:@"logFirst_钻石"];
//            [view addSubview:imgView];
//        }
//        if (i == 1) {
//            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, view.height/3, 40, view.height/3)];
//            label.font = [UIFont systemFontOfSize:14];
//            label.text = YZMsg(@"数量");
//            label.textAlignment = NSTextAlignmentCenter;
//            [view addSubview:label];
//        }
        if (i != 2) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width*0.3, view.height)];
            label.font = [UIFont systemFontOfSize:14];
            [label setAdjustsFontSizeToFitWidth:YES];
            if (i == 0) {
                label.numberOfLines = 2;
                llllLabel = label;
                label.text = [NSString stringWithFormat:@"%@\n(%@)",
                              YZMsg(@"redBagView_total_money"),
                              [Config getRegionCurreny]];
            }else{
                label.text = YZMsg(@"redBagView_amount");
            }
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];

            UITextField *textFiled = [[UITextField alloc]initWithFrame:CGRectMake(view.width*0.3, 0, view.width*0.4, view.height)];
            textFiled.font = [UIFont boldSystemFontOfSize:17];
            textFiled.textAlignment = NSTextAlignmentCenter;
            textFiled.keyboardType = UIKeyboardTypeNumberPad;
            textFiled.delegate = self;
            [view addSubview:textFiled];
            [textFiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [textFiled addTarget:self action:@selector(textFieldDidEnd:) forControlEvents:UIControlEventEditingDidEnd];

            UILabel *rLabel = [[UILabel alloc]initWithFrame:CGRectMake(view.width-70, 0, 60, view.height)];
            rLabel.textAlignment = NSTextAlignmentRight;
            rLabel.textColor = RGB_COLOR(@"#959697", 1);
            rLabel.font = [UIFont systemFontOfSize:14];
            [view addSubview:rLabel];
            if (i == 0) {
                coinT = textFiled;
                coinT.textColor = normalColors;
                coinT.text = [NSString stringWithFormat:@"%d", minCoin];

                rightLabel = rLabel;
                rLabel.text = [Config getRegionCurrenyChar];
            }else{
                numT = textFiled;
                numT.textColor = RGB_COLOR(@"#636465", 1);
                numT.text = @"10";
                rLabel.text = YZMsg(@"redDetails_peer_amount");
            }
        }else{
            contentT = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, view.width-20, view.height)];
            contentT.text = [common getRedBagDes];
            contentT.font = [UIFont systemFontOfSize:15];
            contentT.textColor = RGB_COLOR(@"#959697", 1);
            [view addSubview:contentT];
        }

    }
    timeTypeBtn = [UIButton buttonWithType:0];
    timeTypeBtn.frame = CGRectMake(redView.width/2-redView.height*9/76, redView.height*57/76, redView.height*18/76, redView.height*5/76);
    [timeTypeBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"redBagView_DelayTimeIcon")] forState:UIControlStateNormal];
    [timeTypeBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"redBagView_rightNowIcon")] forState:UIControlStateSelected];
    [timeTypeBtn addTarget:self action:@selector(timeTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    timeTypeBtn.selected = NO;
    [redView addSubview:timeTypeBtn];
    //
    sendBtn = [UIButton buttonWithType:0];
    sendBtn.frame = CGRectMake(redView.width*0.075, timeTypeBtn.bottom + redView.height*2/76, redView.width*0.85, redView.height*8/76);
    sendBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendBtn.titleLabel.minimumScaleFactor = 0.5;
    [sendBtn setBackgroundColor:normalColors];
    [sendBtn setTitle:[NSString stringWithFormat:@"%@ %@%@",YZMsg(@"redBagView_sendRedBagTitle"), [Config getRegionCurrenyChar],coinT.text] forState:0];
    [sendBtn setTitleColor:RGB_COLOR(@"#ee3b2f", 1) forState:0];
    [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.cornerRadius = redView.height*4/76;
    [redView addSubview:sendBtn];

}
- (void)typeBtnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        leftImgView.image = [ImageBundle imagewithBundleName:@"type_seleted@3x"];
        rightImgView.image = [ImageBundle imagewithBundleName:@"type_unseleted@3x"];
        rightLabel.text = [Config getRegionCurrenyChar];
        type = @"1";
        coinT.text = [NSString stringWithFormat:@"%d", minCoin];
        numT.text = @"10";
        
        [sendBtn setTitle:[NSString stringWithFormat:@"%@ %@%@",YZMsg(@"redBagView_sendRedBagTitle"), [Config getRegionCurrenyChar],coinT.text] forState:0];
        llllLabel.text = [NSString stringWithFormat:@"%@\n(%@)",
                          YZMsg(@"redBagView_total_money"),
                          [Config getRegionCurreny]];

    }else{
        rightImgView.image = [ImageBundle imagewithBundleName:@"type_seleted@3x"];
        leftImgView.image = [ImageBundle imagewithBundleName:@"type_unseleted@3x"];
        rightLabel.text = [NSString stringWithFormat:@"%@",[Config getRegionCurrenyChar]];
        type = @"0";
        coinT.text = [NSString stringWithFormat:@"%d", minCoin];
        numT.text = @"10";
        [sendBtn setTitle:[NSString stringWithFormat:@"%@ %@%@",YZMsg(@"redBagView_sendRedBagTitle"), [Config getRegionCurrenyChar],[NSString stringWithFormat:@"%d", minCoin*10]] forState:0];
        llllLabel.text = [NSString stringWithFormat:@"%@\n(%@)",
                          YZMsg(@"redBagView_peerMoney"),
                          [Config getRegionCurreny]];
    }
}
- (void)timeTypeBtnClick:(UIButton *)sender{
    timeTypeBtn.selected = !timeTypeBtn.selected;
    if (timeTypeBtn.selected) {
        type_grant = @"0";
    }else{
        type_grant = @"1";
    }
}
- (void)sendBtnClick{
    if (coinT.text == NULL || coinT.text == nil || coinT.text.length == 0) {
        [MBProgressHUD showError:YZMsg(@"redBagView_input_redbag_money")];
        return;
    }
    if (numT.text == NULL || numT.text == nil || numT.text.length == 0) {
        [MBProgressHUD showError:YZMsg(@"redBagView_input_redbag_amount")];
        return;
    }
    [MBProgressHUD showMessage:@""];

    NSDictionary *dic = @{
        @"stream":minstr(_zhuboModel.stream),
        @"type":type,
        @"type_grant":type_grant,
        @"coin":[YBToolClass getRmbCurrency:coinT.text],
        @"nums":numT.text,
    };
    NSString *url = [NSString stringWithFormat:@"Red.SendRed&des=%@",contentT.text];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        if (code == 0) {
            if (strongSelf.block) {
                strongSelf.block(strongSelf->type);
            }
            [MBProgressHUD showError:YZMsg(@"loginActivity_sendsuccess")];
        }else{
            [MBProgressHUD showError:msg];
        }
        
        
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
}

- (void)textFieldDidChange:(UITextField *)textField{
    NSString *str = textField.text;
    if (textField == coinT) {
        if (str.length > 8) {
            textField.text = [str substringToIndex:8];
            
        }
    }else{
        if (numT.text.length > 6) {
            textField.text = [str substringToIndex:6];
        }
    }

    NSString *coinStr;
    if ([type isEqual:@"1"]) {
        if ([coinT.text intValue] >= 10000) {
            if (([coinT.text intValue] * [numT.text intValue]) % 1000 == 0) {
                if (([coinT.text intValue] * [numT.text intValue]) % 10000 == 0) {
                    coinStr = [NSString stringWithFormat:@"%@ %@%dw",
                               YZMsg(@"redBagView_sendRedBagTitle"),
                               [Config getRegionCurrenyChar],
                               [coinT.text intValue]/10000];
                }else{
                    coinStr = [NSString stringWithFormat:@"%@ %@%.1fw",
                               YZMsg(@"redBagView_sendRedBagTitle"),
                               [Config getRegionCurrenyChar],
                               [coinT.text intValue]/10000.0];
                }
            }else{
                coinStr = [NSString stringWithFormat:@"%@ %@%.2fw",
                           YZMsg(@"redBagView_sendRedBagTitle"),
                           [Config getRegionCurrenyChar],
                           [coinT.text intValue] /10000.00];
            }
        }else{
            coinStr = [NSString stringWithFormat:@"%@ %@%d",
                       YZMsg(@"redBagView_sendRedBagTitle"),
                       [Config getRegionCurrenyChar],
                       [coinT.text intValue]];
        }

    }else{
        if ([coinT.text longLongValue] * [numT.text longLongValue] >= 10000) {
            if (([coinT.text longLongValue] * [numT.text longLongValue]) % 1000 == 0) {
                if (([coinT.text longLongValue] * [numT.text longLongValue]) % 10000 == 0) {
                    coinStr = [NSString stringWithFormat:@"%@ %@%lldw",
                               YZMsg(@"redBagView_sendRedBagTitle"),
                               [Config getRegionCurrenyChar],
                               ([coinT.text longLongValue] * [numT.text longLongValue])/10000];
                }else{
                    coinStr = [NSString stringWithFormat:@"%@ %@%.1fw",
                               YZMsg(@"redBagView_sendRedBagTitle"),
                               [Config getRegionCurrenyChar],
                               ([coinT.text longLongValue] * [numT.text longLongValue])/10000.0];
                }
            }else{
                coinStr = [NSString stringWithFormat:@"%@ %@%.2fw",
                           YZMsg(@"redBagView_sendRedBagTitle"),
                           [Config getRegionCurrenyChar],
                           ([coinT.text longLongValue] * [numT.text longLongValue])/10000.00];
            }
        }else{
            coinStr = [NSString stringWithFormat:@"%@ %@%d",
                       YZMsg(@"redBagView_sendRedBagTitle"),
                       [Config getRegionCurrenyChar],
                       [coinT.text intValue] * [numT.text intValue]];
        }
    }
    [sendBtn setTitle:coinStr forState:0];
}

- (void)textFieldDidEnd:(UITextField *)textField {
    int coinInt = [coinT.text intValue];
    if (coinInt >= minCoin) {
        return;
    }

    coinT.text = [NSString stringWithFormat:@"%d", minCoin];
    [self textFieldDidChange:coinT];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//
//}
//- (void)textFieldDidChange:(UITextField *)textField
//{
//    NSString *str = textField.text;
//    if (textField == coinT) {
//        if (str.length > 8) {
//            textField.text = [str substringToIndex:8];
//
//        }
//    }else{
//        if (numT.text.length > 6) {
//            textField.text = [str substringToIndex:6];
//        }
//    }
//}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
@end
