//
//  myProfitVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "myWithdrawVC.h"
//#import "profitTypeVC.h"
#import "profitTypeVC.h"
#import "webH5.h"
#import "UIButton+Additions.h"
#import "withdrawPopView.h"
#import "BindPhoneNumberViewController.h"
#import "UIView+GYPop.h"
@interface myWithdrawVC (){
    UILabel *allVotesL;
    UILabel *nowVotesL;
    UITextField *votesT;
    UILabel *moneyLabel;
    UILabel *typeLabel;
    //
    int cash_rate;
    int invite_count;
    int invite_coin;
    int invite_reward_num;
    int total_charge; //
    int left_coin;
    int withdrawed_coin;// 已经提现成功的钻石数量
    int withdrawing_coin;// 正在申请提现的钻石数量
    int charge_into_coin;// 已经充入账户的钻石数量
    float charge_reward_rate;
    float withdraw_rate;
    float charge_into_rate;
    float withdraw_limit;// 最低提现额
    NSString* invite_url;// 分享链接
    int charge_coin;//
    //
    UIButton *inputBtn;
    UILabel *tipsLabel;
    NSDictionary *typeDic;
    UIImageView *seletTypeImgView;
}
@property (nonatomic, strong) withdrawPopView *withdrawPopView;


@end

@implementation myWithdrawVC
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
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
    
    
//    UIButton *historyBtn = [UIButton buttonWithType:0];
//    historyBtn.frame = CGRectMake(_window_width-75, 24+statusbarHeight, 65, 40);
//    [historyBtn setTitle:YZMsg(@"提现记录") forState:0];
//    [historyBtn setTitleColor:[UIColor grayColor] forState:0];
//    historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [historyBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [navtion addSubview:historyBtn];

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}
- (void)addBtnClick:(UIButton *)sender{
    webH5 *web = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=cash&a=index&uid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    web.urls = url;
    [self.navigationController pushViewController:web animated:YES];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(244, 245, 246);
    [self navtion];
//    [self creatUI];
    [self requestData];
}
- (void)requestData{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getPopularizeInfo" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            //获取收益
//            nowVotesL.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"votes"]];
//            self.withdraw.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"todaycash"]];
//            allVotesL.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"votestotal"]];//收益 魅力值
            
            strongSelf->withdraw_rate = [minstr([info valueForKey:@"withdraw_rate"]) floatValue]*100;        // 钻石提现兑换比例
            strongSelf->charge_reward_rate = [minstr([info valueForKey:@"charge_reward_rate"]) floatValue]*100;
            strongSelf->charge_into_rate = [minstr([info valueForKey:@"charge_into_rate"]) floatValue]*100;
            
            strongSelf->invite_count = [minstr([info valueForKey:@"invite_count"]) intValue];      // 邀请数量
            strongSelf->invite_coin = [minstr([info valueForKey:@"invite_coin"]) intValue];        // 邀新获取的钻石数量
            strongSelf->invite_reward_num = [minstr([info valueForKey:@"invite_reward_num"]) intValue];        // 邀请一人奖励钻石数量
            strongSelf->total_charge = [minstr([info valueForKey:@"total_charge"]) intValue];      // 邀新总充值
            strongSelf->left_coin = [minstr([info valueForKey:@"left_coin"]) intValue];      // 当前剩余的推广钻石
            strongSelf->withdrawed_coin = [minstr([info valueForKey:@"withdrawed_coin"]) intValue];// 已经提现成功的钻石数量
            strongSelf->withdrawing_coin = [minstr([info valueForKey:@"withdrawing_coin"]) intValue];// 正在申请提现的钻石数量
            strongSelf->charge_into_coin = [minstr([info valueForKey:@"charge_into_coin"]) intValue];// 已经充入账户的钻石数量
            strongSelf->invite_url = minstr([info valueForKey:@"invite_url"]);// 邀请链接
            strongSelf->charge_coin = [minstr([info valueForKey:@"charge_coin"]) intValue];
            strongSelf->withdraw_limit = [minstr([info valueForKey:@"withdraw_limit"]) floatValue]; // 最低提现额
            
//            NSString *tips = minstr([[info firstObject] valueForKey:@"tips"]);
//            
//            CGFloat height = [[YBToolClass sharedInstance] heightOfString:tips andFont:[UIFont systemFontOfSize:11] andWidth:_window_width*0.7-30];
//            tipsLabel.text = tips;
//            tipsLabel.height = height;
            NSLog(@"收益数据........%@",info);
            [strongSelf creatUI];
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
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.04, 64+statusbarHeight+10, _window_width*0.92, _window_width*0.92*24/69)];
    backImgView.image = [ImageBundle imagewithBundleName:@"liveprofit_top"];//liveprofit_top.png
    [self.view addSubview:backImgView];
    
//    int xOffset = -0;
//    int yOffset = -0;
    //推广收益钻石
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:YZMsg(@"myRechargeCoinVC_Promotion%@_tile"),[common name_votes]]];
    [backImgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(backImgView.mas_centerY).offset(-5);
    }];
    
    //推广收益钻石数
    NSString *money = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%d",left_coin] showUnit:YES];
    UILabel *label2 = [UILabel new];
    label2.textColor = [UIColor whiteColor];
    label2.font = [UIFont systemFontOfSize:18];
    label2.text = money;
    [backImgView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(label.mas_bottom).offset(10);
    }];
    
//    //钻石图标
//    UIImageView *labelImg = [[UIImageView alloc]initWithFrame:CGRectMake(label2.x - 30, label2.y, 30, 30)];
//    labelImg.image = [ImageBundle imagewithBundleName:@"logFirst_钻石.png"];
//    [backImgView addSubview:labelImg];
    
    //输入提现金额的视图
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, backImgView.bottom+10, backImgView.width, backImgView.height)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [self.view addSubview:textView];
    NSArray *arr = @[[[NSString stringWithFormat:YZMsg(@"myProfitVC_WithDraw_input%@"),[common name_votes]] stringByAppendingFormat:@" %@",[Config getRegionCurrenyChar]],[YZMsg(@"myProfitVC_To_account_num") stringByAppendingFormat:@" %@",[Config getRegionCurrenyChar]]];
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
            [textView addSubview:votesT];
        }else{
            moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, textView.width*0.95-label.right, textView.height/2)];
            moneyLabel.textColor = [UIColor redColor];
            moneyLabel.font = [UIFont boldSystemFontOfSize:17];
            moneyLabel.text = @"0";
            [textView addSubview:moneyLabel];
        }
    }
    
    //选择提现账户
    
    UIView *typeView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, textView.bottom+10, backImgView.width, 50)];
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
    
    inputBtn = [UIButton buttonWithType:0];
    inputBtn.frame = CGRectMake(_window_width*0.15, typeView.bottom + 30, _window_width*0.7, 40);
//    [inputBtn addGradientButton:NULL endColor:NULL];
    [inputBtn setBackgroundImage:nil];
    [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    [inputBtn setTitle:YZMsg(@"myProfitVC_withDraw_now") forState:0];
    [inputBtn addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
    inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    inputBtn.layer.cornerRadius = 15;
    inputBtn.layer.masksToBounds = YES;
    inputBtn.userInteractionEnabled = NO;
    [self.view addSubview:inputBtn];
    
    tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(inputBtn.left+15, inputBtn.bottom + 15, inputBtn.width-30, 100)];
    tipsLabel.font = [UIFont systemFontOfSize:11];
    tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
    tipsLabel.numberOfLines = 0;
    [self.view addSubview:tipsLabel];
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
//    NSDictionary *dic = @{@"accountid":minstr([typeDic valueForKey:@"id"]),@"cashvote":votesT.text};
//    [YBToolClass postNetworkWithUrl:@"User.SetCash" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        if (code == 0) {
//            votesT.text = @"";
//            [MBProgressHUD showError:msg];
//            [self requestData];
//        }else{
//            [MBProgressHUD showError:msg];
//        }
//    } fail:^{
//
//    }];
    WeakSelf
    NSString *coin = [YBToolClass getRmbCurrency:votesT.text];
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.withdraw" withBaseDomian:YES andParameter:@{@"coin":coin, @"bank_id":minstr([typeDic valueForKey:@"id"]), @"account":minstr([typeDic valueForKey:@"account"]), @"name":minstr([typeDic valueForKey:@"name"])} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
- (void)ChangeMoenyLabelValue{
    
    NSString *priceEdit = [YBToolClass getRmbCurrency:votesT.text];
    
    NSString *coin = priceEdit;
    if(withdraw_rate > 0){
        NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                             decimalNumberHandlerWithRoundingMode:NSRoundDown
                                             scale:2
                                             raiseOnExactness:NO
                                             raiseOnOverflow:NO
                                             raiseOnUnderflow:NO
                                             raiseOnDivideByZero:YES];
        NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", coin.floatValue]];
        NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", withdraw_rate]];
        NSDecimalNumber *number100 = [NSDecimalNumber decimalNumberWithString:@"100"];
        coin = [[coinNumber decimalNumberByMultiplyingBy:rateNumber] decimalNumberByDividingBy:number100 withBehavior:roundDown].stringValue;
    }
    moneyLabel.text = [YBToolClass getRateCurrency:coin showUnit:false];
    if (priceEdit.floatValue > 0 && priceEdit.floatValue >= withdraw_limit) {
        if (!inputBtn.userInteractionEnabled) {
            inputBtn.userInteractionEnabled = YES;
            [inputBtn setBackgroundColor:[UIColor clearColor]];
            [inputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"btn_anniu"]];
        }

    }else{
        if (inputBtn.userInteractionEnabled) {
            inputBtn.userInteractionEnabled = NO;
            [inputBtn setBackgroundImage:nil];
            [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
            // 提示
            if(priceEdit.floatValue < withdraw_limit){
                [MBProgressHUD showError:[[NSString stringWithFormat:YZMsg(@"myWithdrawVC_minWithDrawAmount%.2f"),[[YBToolClass getRateCurrency:min2float(withdraw_limit) showUnit:false] floatValue]] stringByAppendingFormat:@" %@",[Config getRegionCurrenyChar]]];
            }else{
                [MBProgressHUD hideHUD];
            }
        }
        
    }
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


@end
