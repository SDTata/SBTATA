//
//  myPopularizeVC
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "myRechargeCoinVC.h"
#import "webH5.h"
#import "UIButton+Additions.h"

@interface myRechargeCoinVC (){
    UILabel *allVotesL;
    UILabel *nowVotesL;
    UIButton *chargeIntoCoinBtn;
    UIButton *withDrawingBtn;
    UITextField *votesT;
    UILabel *moneyLabel;
    UILabel *typeLabel;
    //
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
    NSString* invite_url;// 分享链接
    int charge_coin;//
    //
    UIButton *inputBtn;
    UILabel *tipsLabel;
    NSDictionary *typeDic;
    UIImageView *seletTypeImgView;
    
    UILabel *inviteCoinLabel;
    UILabel *chargeCoinLabel;
    UILabel *successDrawingLabel;
    UILabel *withDrawingLabel;
    UILabel *chargeIntoCoinLabel;
}

@end

@implementation myRechargeCoinVC
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
//    [historyBtn setTitle:YZMsg(@"推广记录") forState:0];
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
            //获取推广收益数据
//            nowVotesL.text = [NSString stringWithFormat:@"%@",[info valueForKey:@"left_coin"]];
            //self.withdraw.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"todaycash"]];
//            allVotesL.text = [NSString stringWithFormat:@"%@",[info valueForKey:@"invite_coin"]];//收益 魅力值
            
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
            strongSelf->charge_coin = [minstr([info valueForKey:@"charge_coincharge_coin"]) intValue];


            NSString *tips = minstr(msg);
            CGFloat height = [[YBToolClass sharedInstance] heightOfString:tips andFont:[UIFont systemFontOfSize:11] andWidth:_window_width*0.7-30];
            strongSelf->tipsLabel.text = tips;
            strongSelf->tipsLabel.height = height;
            NSLog(@"推广/收益数据：%@",info);
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
    
    //背景图
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.04, 64+statusbarHeight+10, _window_width*0.92, _window_width*0.92*24/59)];
    backImgView.image = [ImageBundle imagewithBundleName:@"liveprofit_top"];
    [self.view addSubview:backImgView];
    
//    int xOffset = -0;
//    int yOffset = -0;
    //推广收益钻石
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = [NSString stringWithFormat:YZMsg(@"myRechargeCoinVC_Promotion%@_tile"),[common name_votes]];
    [backImgView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(backImgView.mas_centerY).offset(-5);
    }];
    
    //推广收益钻石数
    NSString *money = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%d", left_coin] showUnit:YES];
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
    
    NSArray *arr = @[
         [[NSString stringWithFormat:YZMsg(@"myRechargeCoinVC_Charge%@_num"),[common name_votes]] stringByAppendingFormat:@" %@",[Config getRegionCurrenyChar]],
         [YZMsg(@"myRechargeCoinVC_CanHaveHowMuch") stringByAppendingFormat:@" %@",[Config getRegionCurrenyChar]]
     ];
    //推广相关信息视图
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, backImgView.bottom+10, backImgView.width, backImgView.height*arr.count/2)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [self.view addSubview:textView];
    
    
    // int twidth = textView.width;
    // int theight = textView.height;
    for (int i = 0; i<arr.count; i++) {
        int cellH = textView.height/arr.count;
        int cellY = textView.height/arr.count*i;
        int imgSizeWH = cellH*0.6;
        // img
        UIImageView *labelImg = [[UIImageView alloc]initWithFrame:CGRectMake(textView.width*0.05, cellY + (cellH - imgSizeWH) / 2, imgSizeWH, imgSizeWH)];
        labelImg.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"share_%d",(i+1)]];
        [textView addSubview:labelImg];
        // title label
        CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:arr[i] andFont:[UIFont systemFontOfSize:15] andHeight:cellH];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.08 + imgSizeWH, cellY, labelW+20, cellH)];
        label.textColor = RGB_COLOR(@"#767676", 1);
        label.font = [UIFont systemFontOfSize:13];
        label.text = arr[i];
        [textView addSubview:label];
        // content label
        int showNum = 0;
        NSString* numOperation = @"";
        NSString* numColor = @"";
        switch (i) {
            case 0:
                [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(textView.width*0.05, textView.height/2-0.5, textView.width*0.9, 1) andColor:RGB(244, 245, 246) andView:textView];
                votesT = [[UITextField alloc]initWithFrame:CGRectMake(label.right, 0, textView.width*0.95-label.right, textView.height/2)];
                votesT.textColor = normalColors;
                votesT.font = [UIFont boldSystemFontOfSize:17];
                votesT.placeholder = @"0";
                votesT.keyboardType = UIKeyboardTypeNumberPad;
                [textView addSubview:votesT];
                break;
            case 1:
                moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, textView.width*0.95-label.right, textView.height/2)];
                moneyLabel.textColor = [UIColor redColor];
                moneyLabel.font = [UIFont boldSystemFontOfSize:17];
                moneyLabel.text = @"0";
                [textView addSubview:moneyLabel];
                break;
            case 2:
                showNum = withdrawed_coin;
                numOperation = @"";
                numColor = @"#fb3157";
                break;
            case 3:
                showNum = withdrawing_coin;
                numOperation = @"";
                numColor = @"#fb3157";
                break;
            case 4:
                showNum = charge_into_coin;
                numOperation = @"";
                numColor = @"#fb3157";
                break;
            default:
                break;
        }
        
//        inviteCoinLabel = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.8, label.y, textView.width*0.95-50, cellH)];
//        inviteCoinLabel.textColor = RGB_COLOR(numColor, 1);
//        inviteCoinLabel.font = [UIFont boldSystemFontOfSize:17];
//        inviteCoinLabel.text = [NSString stringWithFormat:@"%@%d%@",numOperation,showNum,@"钻石"];
//        [textView addSubview:inviteCoinLabel];
    }
    
    // 充入钻石
    inputBtn = [UIButton buttonWithType:0];
    inputBtn.frame = CGRectMake(_window_width*0.15, textView.bottom + 15, _window_width*0.7, 40);

    [inputBtn setBackgroundImage:nil];
    [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    
    [inputBtn setTitle:[NSString stringWithFormat:@"%@%@",YZMsg(@"myRechargeCoinVC_ChargeIn"),[common name_votes]] forState:0];
    [inputBtn addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
    inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    inputBtn.layer.cornerRadius = 10;
    inputBtn.layer.masksToBounds = YES;
    inputBtn.userInteractionEnabled = NO;
    [self.view addSubview:inputBtn];
    
    // Tips
    tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(inputBtn.left+15, inputBtn.bottom + 15, inputBtn.width-30, 100)];
    tipsLabel.font = [UIFont systemFontOfSize:11];
    tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
    tipsLabel.numberOfLines = 0;
    [self.view addSubview:tipsLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidChangeNotification object:nil];

}
//充入钻石
- (void)inputBtnClick{
    WeakSelf
    NSString *coin = [YBToolClass getRmbCurrency:votesT.text];
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.ChargeInto" withBaseDomian:YES andParameter:@{@"charge_coin": coin} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showSuccess:YZMsg(@"myRechargeCoinVC_OptionSuccess")];
            [strongSelf requestData];
        }else{
            [MBProgressHUD showError:YZMsg(msg)];
        }
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD showError:YZMsg(@"myRechargeCoinVC_OptionError")];
    }];
}
- (void)ChangeMoenyLabelValue{
   
    NSString *priceEdit = [YBToolClass getRmbCurrency:votesT.text];
    NSString *coin = priceEdit;
    if(charge_into_rate > 0){
        NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                             decimalNumberHandlerWithRoundingMode:NSRoundDown
                                             scale:2
                                             raiseOnExactness:NO
                                             raiseOnOverflow:NO
                                             raiseOnUnderflow:NO
                                             raiseOnDivideByZero:YES];
        NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", coin.floatValue]];
        NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", charge_into_rate]];
        NSDecimalNumber *number100 = [NSDecimalNumber decimalNumberWithString:@"100"];
        coin = [[coinNumber decimalNumberByDividingBy:rateNumber] decimalNumberByMultiplyingBy:number100 withBehavior:roundDown].stringValue;
    }
    moneyLabel.text = [YBToolClass getRateCurrency:coin showUnit:false];;
    if (coin.floatValue > 0) {
        if (!inputBtn.userInteractionEnabled) {
            inputBtn.userInteractionEnabled = YES;
            [inputBtn setBackgroundColor:[UIColor clearColor]];
            [inputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"btn_anniu"]];
        }
    }else{
        if (inputBtn.userInteractionEnabled) {
            [inputBtn setBackgroundImage:nil];
            [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
            inputBtn.userInteractionEnabled = NO;
        }
       
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
