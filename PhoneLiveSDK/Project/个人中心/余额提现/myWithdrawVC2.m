//
//  myProfitVC.m
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "myWithdrawVC2.h"
//#import "profitTypeVC.h"
#import "profitTypeVC.h"
#import "webH5.h"
#import "withdrawPopView.h"
#import "RechargePopView.h"
#import "BindPhoneNumberViewController.h"
#import "UIView+GYPop.h"
#import "PayAmountCollectionViewCell.h"
#import <UMCommon/UMCommon.h>

@interface myWithdrawVC2 (){

    UITextField *votesT;
    
    UILabel *typeLabel;
    NSString *left_coin;
    NSString *balanceNum;
 
    
    UIScrollView *scrollBgView;
    UIImageView *backImgView;
    UIView *textInputBgView;
    UIView *typeBankBgView;
    
    
    UIButton *inputBtn;
    UILabel *tipsLabel;
    UILabel *tip2Label;
    
    
    UILabel *tipFreeDrawTitleLabel;
    UILabel *tipFreeMoneyLabel;
    
    UIView *choiseMoneyView;
    
    
    NSDictionary *typeDic;
    UIImageView *seletTypeImgView;
    
    UILabel *leftCoinLable;
    UILabel *leftCoin2Lable;
   
    
    UIButton *refreshCoinBtn;
    NSString *noWithdrawAmount;
    NSString *minWithdraw;
    NSString *maxWithdraw;
    NSString *tip;
    NSString *needFlow;
    UIButton *tipBtn;
    
    UILabel *withdrawAmountLabel;
    UILabel *noWithdrawAmountLabel;
    BOOL bNeedObserverFieldDidChange;
    
    NSInteger selectedBankType;
    NSInteger selectedSubBankType;
    NSInteger curselectIndexMoney;
    
    
    NSArray *withdraw_configArray;
    NSArray *quickAmountArray;
    

    
    
    
}

@property (nonatomic, strong) withdrawPopView *withdrawPopView;
@property (nonatomic, strong) NSArray <WithDrawTypeModel *> *types;

@end

@implementation myWithdrawVC2
-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =[UIColor clearColor];
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
    
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
    CGSize size = [YZMsg(@"myProfitVC_WithDrawRecord") sizeWithAttributes:attrs];
    UIButton *historyBtn = [UIButton buttonWithType:0];
    historyBtn.frame = CGRectMake(_window_width-(size.width + 18), 24+statusbarHeight, size.width + 8, 40);
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
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=Withdraw&a=index&uid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    web.urls = url;
    [self.navigationController pushViewController:web animated:YES];
    [MobClick event:@"withdraw_history_click" attributes:@{@"eventType": @(1)}];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
//    if(bNeedObserverFieldDidChange){
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidEndEditingNotification object:nil];
//        bNeedObserverFieldDidChange = false;
//    }
}
- (void)viewWillDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
//    bNeedObserverFieldDidChange = true;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bgImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    selectedSubBankType = -1;
    bgImgV.image = [ImageBundle imagewithBundleName:@"withdraw_bg"];
    [self.view addSubview:bgImgV];
    
    if (!scrollBgView) {
        scrollBgView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        scrollBgView.scrollEnabled  = YES;
        scrollBgView.alwaysBounceVertical = YES;
        scrollBgView.backgroundColor = [UIColor clearColor];
        scrollBgView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 13.0, *)) {
            scrollBgView.automaticallyAdjustsScrollIndicatorInsets = YES;
        } else {
            // Fallback on earlier versions
        }
        [self.view addSubview:scrollBgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
        [scrollBgView addGestureRecognizer:tap];
    }
    
    
    [self navtion];
//    [self creatUI];

    [self requestData];
    
}

- (void)startAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.5;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [refreshCoinBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    refreshCoinBtn.userInteractionEnabled = NO;
}

- (void)stopAnimation {
    [refreshCoinBtn.layer removeAnimationForKey:@"rotationAnimation"];
    refreshCoinBtn.userInteractionEnabled = YES;
}

- (void)requestData{
    [self startAnimation];
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf stopAnimation];
        });
        //        [testActivityIndicator stopAnimating]; // 结束旋转
        //        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            if (![infoDic isKindOfClass:[NSDictionary class]]) {
                return;
            }
            [strongSelf commonRefresh:infoDic];
            NSMutableArray *tys = [NSMutableArray array];
            NSArray *support_withdraw_type = infoDic[@"support_withdraw_type"];
            for (NSDictionary *d_type in support_withdraw_type) {
                WithDrawTypeModel *type = [[WithDrawTypeModel alloc] init];
                type.title = d_type[@"title"];
                type.id = d_type[@"id"];
                type.num = d_type[@"num"];
                type.status = d_type[@"status"];
                [tys addObject:type];
            }
            self.types = tys;

        }else{
            [MBProgressHUD showError:msg];
        }
        [MBProgressHUD hideHUD];
    } fail:^(NSError * _Nonnull error) {
        //        [testActivityIndicator stopAnimating]; // 结束旋转
        //        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

        [MBProgressHUD hideHUD];
    }];
}
- (void)tapClick{
    [votesT resignFirstResponder];
}
- (void)creatUIWithArray:(NSArray *)ArrayType{
    
    //背景图
    if (!backImgView) {
        backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10 , 64+statusbarHeight,_window_width-20, 150)];
        backImgView.image = [ImageBundle imagewithBundleName:@"exchange_balance_bottom"];
        [scrollBgView addSubview:backImgView];
        backImgView.userInteractionEnabled = YES;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(35, 45 , backImgView.width-100, 16)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16];
        NSString *curreny = [NSString stringWithFormat:@"(%@)",[Config getRegionCurreny]];
        label.text = [NSString stringWithFormat:YZMsg(@"myWithdrawVC2_Account%@_Balance"), curreny];
        [backImgView addSubview:label];
        //账户余额1
    //    CGFloat leftCoinLableW = [[YBToolClass sharedInstance] widthOfString:left_coin_str andFont:[UIFont systemFontOfSize:28] andHeight:30];
        leftCoinLable = [[UILabel alloc]initWithFrame:CGRectMake(label.left, 90, 130, 35)];
        leftCoinLable.textColor = [UIColor yellowColor];
        leftCoinLable.font = [UIFont boldSystemFontOfSize:35];
        leftCoinLable.textAlignment = NSTextAlignmentLeft;
        [backImgView addSubview:leftCoinLable];
        
//        NSString *left_coin2_str = [NSString stringWithFormat:@"%@", left_coin];
//        leftCoinLable.text = left_coin2_str;
//        [leftCoinLable sizeToFit];
        
        //账户余额2
        
    //    CGFloat label3W = [[YBToolClass sharedInstance] widthOfString:left_coin2_str andFont:[UIFont systemFontOfSize:14] andHeight:backImgView.height/4];
        leftCoin2Lable = [[UILabel alloc]initWithFrame:CGRectMake(leftCoinLable.right + 5,  leftCoinLable.top+14,200, 28)];
        leftCoin2Lable.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        leftCoin2Lable.font = [UIFont systemFontOfSize:16];
        
//        NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
//        NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
//                                          decimalNumberHandlerWithRoundingMode:NSRoundDown
//                                          scale:2
//                                          raiseOnExactness:NO
//                                          raiseOnOverflow:NO
//                                          raiseOnUnderflow:NO
//                                          raiseOnDivideByZero:YES];
//        NSDecimalNumber *coin_realy_value = [[NSDecimalNumber decimalNumberWithString:balanceNum]decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
//
//    //    CGFloat  coin = coin_realy_value* rate * 100/100.0;
//        NSString *coinStr = [NSString stringWithFormat:@"≈%@%@(%@)",[Config getRegionCurrenyChar],coin_realy_value.stringValue,[Config getRegionCurreny]];
//        leftCoin2Lable.text = coinStr;
        leftCoin2Lable.textAlignment = NSTextAlignmentLeft;
        leftCoin2Lable.adjustsFontSizeToFitWidth = YES;
        leftCoin2Lable.minimumScaleFactor = 0.5;
        [backImgView addSubview:leftCoin2Lable];
//        [leftCoin2Lable sizeToFit];
        
        // 刷新余额按钮
        refreshCoinBtn = [UIButton buttonWithType:0];
        refreshCoinBtn.frame = CGRectMake(leftCoin2Lable.right+3, leftCoin2Lable.top-2, 22, 22);
        [refreshCoinBtn setImage:[ImageBundle imagewithBundleName:@"zf_cx"] forState:UIControlStateNormal];
        [refreshCoinBtn addTarget:self action:@selector(refreshCoinBtnClick) forControlEvents:UIControlEventTouchUpInside];
        refreshCoinBtn.userInteractionEnabled = YES;
        [backImgView addSubview:refreshCoinBtn];
        [refreshCoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftCoinLable.mas_right).offset(10);
            make.centerY.mas_equalTo(leftCoinLable.mas_centerY);
            make.width.height.mas_equalTo(30);
        }];
    }
    
    ///插入选择视图
    
    float bottomTypeChoise = backImgView.bottom+10;
    NSDictionary *withDrawcharge_config = nil;
    for (int i = 0;i<ArrayType.count;i++) {
        
        
        NSDictionary *bigTypeDict = ArrayType[i];
        // 解析withdrawal_big_type
        NSDictionary *withdrawalBigType = bigTypeDict[@"withdrawal_big_type"];
      
        UIButton *buttonTitle = [scrollBgView viewWithTag:i+100];
        if (!buttonTitle) {
            
            NSString *bigTypeTitle = withdrawalBigType[@"title"];
            NSString *bigTypeIcon = withdrawalBigType[@"icon"];
            NSString *bigTypeSelectedIcon = withdrawalBigType[@"icon_selected"];
            
            buttonTitle = [UIButton buttonWithType:UIButtonTypeCustom];
            [scrollBgView addSubview:buttonTitle];
            [buttonTitle setBackgroundColor:RGB(244, 239, 248)];
            
            UIImage *imgSub = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"withdrawbttype_%d",i+1]];
            UIEdgeInsets insets = UIEdgeInsetsMake(25, 25.0, 25.0, 25.0);
            imgSub = [imgSub resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];

            [buttonTitle setBackgroundImage:imgSub forState:UIControlStateSelected];
            [buttonTitle setTitle:bigTypeTitle forState:UIControlStateNormal];
            buttonTitle.titleLabel.font = [UIFont systemFontOfSize:12];
            buttonTitle.layer.cornerRadius = 6;
            buttonTitle.layer.masksToBounds = YES;

            
            
            [buttonTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [buttonTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
          
            int widthBig = SCREEN_WIDTH/ArrayType.count - 16;
            
            buttonTitle.frame = CGRectMake(SCREEN_WIDTH/ArrayType.count *i + 8, backImgView.bottom+10, widthBig, 65);
         
            __weak UIButton *weak__buttonTitle = buttonTitle;
            
            buttonTitle.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [buttonTitle sd_setImageWithURL:[NSURL URLWithString:bigTypeIcon] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                weak__buttonTitle.titleEdgeInsets = UIEdgeInsetsMake(weak__buttonTitle.imageView.frame.size.height-20, -weak__buttonTitle.imageView.frame.size.width, 0, 0);//实现文字下移
                weak__buttonTitle.imageEdgeInsets = UIEdgeInsetsMake(-weak__buttonTitle.imageView.frame.size.height+20+40 , 0, 25, - weak__buttonTitle.titleLabel.bounds.size.width);//实现图片上移
           
            }];
            
            [buttonTitle sd_setImageWithURL:[NSURL URLWithString:bigTypeSelectedIcon] forState:UIControlStateSelected];
            [buttonTitle addTarget:self action:@selector(choiseBankTypeAction:) forControlEvents:UIControlEventTouchUpInside];
            buttonTitle.tag = i+100;
        }
        
        if (selectedBankType == i) {
            buttonTitle.selected = YES;
        }else{
            buttonTitle.selected = NO;
        }
    }
    if (ArrayType.count>0) {
        bottomTypeChoise = bottomTypeChoise + 65+10;
    }
    
    if (ArrayType.count>selectedBankType) {
        
    }
    NSDictionary *subTypeDict = [ArrayType safeObjectWithIndex:selectedBankType];
    
    float heightFrom = backImgView.bottom+10+65+10;
    // 解析users_bank_types数组
    NSArray *usersBankTypes = subTypeDict[@"users_bank_types"];
    
    for(UIView *subV in  scrollBgView.subviews){
        if (subV.tag>=2000 && subV.tag<=3000) {
            [subV removeFromSuperview];
        }
    }
    
    CGFloat widthBig = (SCREEN_WIDTH - 20)/2 - 4;
    
    UIButton *lastBUtton = nil;
    for (int i = 0; i<usersBankTypes.count;i++) {
        NSDictionary *bankTypeDict = usersBankTypes[i];
        
        NSString *bankSubTypeTitle = bankTypeDict[@"title"];
        NSString *bankSubTypeIcon = bankTypeDict[@"icon"];
        int numberSelected = 0;
        if (![PublicObj checkNull:bankTypeDict[@"num"]]) {
            numberSelected = [bankTypeDict[@"num"] intValue];
        }
        if(numberSelected == 12){
            if (bankTypeDict[@"no_withdrawcharge_config"]) {
                if ([bankTypeDict[@"no_withdrawcharge_config"] isKindOfClass:[NSArray class]]) {
                    NSArray *withDrawcharge_configA = bankTypeDict[@"no_withdrawcharge_config"];
                    withDrawcharge_config = withDrawcharge_configA[0];
                }else{
                    withDrawcharge_config = bankTypeDict[@"no_withdrawcharge_config"];
                }
                
            }
        }
        
        if (selectedSubBankType == -1 && i==0) {
            selectedSubBankType = numberSelected;
        }
        
        // 创建用户银行类型按钮，例如 "VIPPAY测试"、"USDT"
        UIButton *subButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [scrollBgView addSubview:subButton];
        [subButton setBackgroundColor:RGB(244, 239, 248)];
        UIImage *imgSub = [ImageBundle imagewithBundleName:@"withdrow_selected"];
        UIEdgeInsets insets = UIEdgeInsetsMake(25, 25.0, 25.0, 25.0);
        imgSub = [imgSub resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];

        [subButton setBackgroundImage:imgSub forState:UIControlStateSelected];
        [subButton setTitle:bankSubTypeTitle forState:UIControlStateNormal];
        subButton.titleLabel.font = [UIFont systemFontOfSize:13];
        subButton.layer.cornerRadius = 6;
        subButton.layer.masksToBounds = YES;
        [subButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        subButton.frame = CGRectMake(10+i%2*(8+widthBig),heightFrom + 30*floor(i/2)+10*floor(i/2) , widthBig, 30);
        /*
        if (![PublicObj checkNull:bankSubTypeIcon]) {
            [subButton sd_setImageWithURL:[NSURL URLWithString:bankSubTypeIcon] forState:UIControlStateNormal];
        }
         */
        
        if (selectedSubBankType == numberSelected) {
            subButton.selected = YES;
        }else{
            subButton.selected = NO;
        }
        
        [subButton addTarget:self action:@selector(choiseSubBankTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        subButton.tag = numberSelected+2000;
        lastBUtton = subButton;
        
    }
    if (lastBUtton) {
        bottomTypeChoise = lastBUtton.bottom+10;
    }
  
    
    NSArray *arr = @[[NSString stringWithFormat:@"%@",YZMsg(@"myWithdrawVC2_inputHowMany")],YZMsg(@"myWithdrawVC2_CanWithDrawNum")];
    //输入提现金额的视图
    if (!textInputBgView) {
        textInputBgView = [[UIView alloc]initWithFrame:CGRectMake(10, bottomTypeChoise+10, SCREEN_WIDTH - 20, 100 * (arr.count / 2))];
        textInputBgView.backgroundColor = RGB(244, 239, 248);
        textInputBgView.layer.cornerRadius = 10.0;
        textInputBgView.layer.masksToBounds = YES;
        [scrollBgView addSubview:textInputBgView];
        
        for (int i = 0; i<arr.count; i++) {
            CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:arr[i] andFont:[UIFont boldSystemFontOfSize:15] andHeight:textInputBgView.height/arr.count];
            if (labelW > (textInputBgView.right - (i == 0?135:75) - textInputBgView.width*0.1)) {
                labelW = textInputBgView.right - (i == 0?135:75) - textInputBgView.width*0.1;
            }
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(textInputBgView.width*0.05, textInputBgView.height/arr.count*i, labelW, textInputBgView.height/arr.count)];
            label.textColor = RGB_COLOR(@"#333333", 1);
            label.font = [UIFont boldSystemFontOfSize:15];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.5;
            label.numberOfLines = 2;
            label.text = arr[i];
            [textInputBgView addSubview:label];
            if (i == 0) {
                UILabel *symbolLabel = [[UILabel alloc]initWithFrame:CGRectMake(textInputBgView.right - 150 - textInputBgView.width*0.05, 0, 30, textInputBgView.height/arr.count)];
                symbolLabel.textColor = [UIColor redColor];
                symbolLabel.adjustsFontSizeToFitWidth = YES;
                symbolLabel.minimumScaleFactor = 0.5;
                symbolLabel.tag = 1020;
                symbolLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20.0f];
                symbolLabel.text = [Config getRegionCurrenyChar];
                
//                UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(3,15, 20, 20)];
//                [imgView setImage:[ImageBundle imagewithBundleName:@"yfks_zs"]];
//                imgView.hidden = YES;
//                imgView.tag = 1021;
//                [symbolLabel addSubview:imgView];

                [textInputBgView addSubview:symbolLabel];
                
                [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(textInputBgView.width*0.05, textInputBgView.height/arr.count*(i+1)-0.5, textInputBgView.width*0.9, 1) andColor:[UIColor whiteColor] andView:textInputBgView];
                votesT = [[UITextField alloc]initWithFrame:CGRectMake(textInputBgView.right - 120 - textInputBgView.width*0.05, 0, 110, textInputBgView.height/arr.count)];
                votesT.textColor = [UIColor redColor];
                votesT.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20.0f];
                votesT.placeholder = @"0";
                votesT.keyboardType = UIKeyboardTypeNumberPad;
                [votesT addTarget:self action:@selector(ChangeMoenyLabelValue) forControlEvents:UIControlEventEditingDidEnd];
                [textInputBgView addSubview:votesT];
                
                [symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(140);
                    make.centerY.mas_equalTo(label.mas_centerY);
                }];
                
                [votesT mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(symbolLabel.mas_right).offset(0);
                    make.centerY.mas_equalTo(symbolLabel.mas_centerY);
                    make.width.mas_equalTo(VKPX(180));
                    make.height.mas_equalTo(36);
                }];
                
            }else if(i == 1){
                withdrawAmountLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right+20, label.top, textInputBgView.width*0.95-label.right - 30, textInputBgView.height/arr.count)];
                withdrawAmountLabel.textColor = RGB_COLOR(@"#333333", 1);//[UIColor grayColor];
    //            withdrawAmountLabel.font = [UIFont boldSystemFontOfSize:17];
                withdrawAmountLabel.font= [UIFont fontWithName:@"PingFangSC-Medium" size:20.0f];
                [textInputBgView addSubview:withdrawAmountLabel];
                
                [withdrawAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(140);
                    make.centerY.mas_equalTo(label.mas_centerY);
                }];
                
    //            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(textView.width*0.05, textView.height/arr.count*(i+1)-0.5, textView.width*0.9, 1) andColor:RGB(244, 245, 246) andView:textView];
                
                tipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                //    btnttttt.backgroundColor = [UIColor clearColor];
                [tipBtn setImage:[ImageBundle imagewithBundleName:@"icon_desc.png"] forState:UIControlStateNormal];
                [tipBtn addTarget:self action:@selector(showExchangeTip) forControlEvents:UIControlEventTouchUpInside];
                
                [textInputBgView addSubview:tipBtn];
            }else{
                noWithdrawAmountLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right, label.top, textInputBgView.width*0.95-label.right, textInputBgView.height/arr.count)];
                noWithdrawAmountLabel.textColor = [UIColor grayColor];
                noWithdrawAmountLabel.font = [UIFont boldSystemFontOfSize:17];
                [textInputBgView addSubview:noWithdrawAmountLabel];
                
                
            }
        }
        
        if (!tipsLabel) {
            tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, textInputBgView.bottom+10, backImgView.width-36,15)];
            tipsLabel.font = [UIFont systemFontOfSize:11];
            tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
            tipsLabel.numberOfLines = 0;
            [scrollBgView addSubview:tipsLabel];
        }
    }
    
    
    
    textInputBgView.frame = CGRectMake(10, bottomTypeChoise, SCREEN_WIDTH - 20, 100 * (arr.count / 2));
    tipsLabel.frame = CGRectMake(18, textInputBgView.bottom+10, backImgView.width-36,15);
    votesT.text = @"0";
   
    
    //选择提现账户
    if (!typeBankBgView) {
        typeBankBgView = [[UIView alloc]initWithFrame:CGRectMake(10, tipsLabel.bottom + 10, SCREEN_WIDTH-20, 50)];
        typeBankBgView.backgroundColor = RGB(244, 239, 248);
        typeBankBgView.layer.cornerRadius = 10.0;
        typeBankBgView.tag = 1200;
        typeBankBgView.layer.masksToBounds = YES;
        [scrollBgView addSubview:typeBankBgView];
        
        typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textInputBgView.width*0.05, 0, typeBankBgView.width*0.95-40, 50)];
        typeLabel.textColor = RGB_COLOR(@"#333333", 1);
        typeLabel.font = [UIFont boldSystemFontOfSize:15];
        typeLabel.text = YZMsg(@"myProfitVC_choise_withDraw_account");
        [typeBankBgView addSubview:typeLabel];
        seletTypeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeLabel.left, 15, 20, 20)];
        seletTypeImgView.hidden = YES;
        [typeBankBgView addSubview:seletTypeImgView];
        
        UIImageView *rightImgView = [[UIImageView alloc]initWithFrame:CGRectMake(typeBankBgView.width-30, 16, 10, 18)];
        rightImgView.image = [ImageBundle imagewithBundleName:@"arrows_43"];
        rightImgView.userInteractionEnabled = YES;
        [typeBankBgView addSubview:rightImgView];

        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(0, 0, typeBankBgView.width, typeBankBgView.height);
        [btn addTarget:self action:@selector(selectPayType) forControlEvents:UIControlEventTouchUpInside];
        [typeBankBgView addSubview:btn];
        
    }
    if (!tip2Label) {
        tip2Label = [[UILabel alloc]initWithFrame:CGRectMake(20, typeBankBgView.bottom + 8, SCREEN_WIDTH-44, 40)];
        tip2Label.font = [UIFont systemFontOfSize:11];
        tip2Label.tag = 1201;
        tip2Label.textColor = RGB_COLOR(@"#999999", 1);
        [tip2Label setTextAlignment:NSTextAlignmentLeft];
        tip2Label.text = YZMsg(@"AddCard_Transfor_tip");
        tip2Label.numberOfLines = 0;
        [tip2Label sizeToFit];
        [scrollBgView addSubview:tip2Label];
    }
   
    if (!tipFreeMoneyLabel) {
        tipFreeMoneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, typeBankBgView.bottom + 8, SCREEN_WIDTH-44, 40)];
        tipFreeMoneyLabel.font = [UIFont boldSystemFontOfSize:14];
        tipFreeMoneyLabel.textColor = RGB(175 ,82 ,222);
        [tipFreeMoneyLabel setTextAlignment:NSTextAlignmentLeft];
        tipFreeMoneyLabel.numberOfLines = 2;
        [scrollBgView addSubview:tipFreeMoneyLabel];
    }
    
    UILabel *symp =  [textInputBgView viewWithTag:1020];
    if (symp) {
        UIView *imgdia = [symp  viewWithTag: 1021];
        if (imgdia) {
            if (selectedSubBankType == 12) {
                imgdia.hidden = NO;
                symp.text = @"";

            }else{
                imgdia.hidden = YES;
                symp.text =[NSString stringWithFormat:@"%@%@",[Config getRegionCurrenyChar],@" "];
            }
        }
    }
    
    if (selectedSubBankType == 12) {
        typeBankBgView.hidden = YES;
        tip2Label.hidden = YES;
        tipFreeMoneyLabel.hidden = NO;
        if (!tipFreeDrawTitleLabel) {
            tipFreeDrawTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, tipsLabel.bottom + 8, SCREEN_WIDTH-44, 40)];
            tipFreeDrawTitleLabel.font = [UIFont systemFontOfSize:15];
            tipFreeDrawTitleLabel.textColor = [UIColor blackColor];
            [tipFreeDrawTitleLabel setTextAlignment:NSTextAlignmentLeft];
            tipFreeDrawTitleLabel.text = YZMsg(@"myProfitVC_WithDrawMoneyChoise");
            tipFreeDrawTitleLabel.numberOfLines = 0;
            [tipFreeDrawTitleLabel sizeToFit];
            [scrollBgView addSubview:tipFreeDrawTitleLabel];
        }
        tipFreeDrawTitleLabel.hidden = NO;
        
        if (!choiseMoneyView) {
            choiseMoneyView = [[UIView alloc] initWithFrame:CGRectMake(10, tipFreeDrawTitleLabel.bottom+4, SCREEN_WIDTH-40, 40)];
            choiseMoneyView.backgroundColor = [UIColor clearColor];
            [scrollBgView addSubview:choiseMoneyView];
        }
        choiseMoneyView.hidden = NO;
        [choiseMoneyView removeAllSubviews];
        widthBig = (SCREEN_WIDTH - 30)/4 - 4;
     
        if ([withDrawcharge_config isKindOfClass:[NSDictionary class]]) {
           
            quickAmountArray = withDrawcharge_config[@"quick_amount"];
            
            for (int i = 0;i<quickAmountArray.count; i++) {
                
                NSString *titleMon = quickAmountArray[i][@"title"];
                NSString *titleRate = quickAmountArray[i][@"subTitle"];
                
                
                PayAmountCollectionViewCell *amountCellView=[[[XBundle currentXibBundleWithResourceName:@"PayAmountCollectionViewCell"] loadNibNamed:@"PayAmountCollectionViewCell" owner:self options:nil] firstObject];
                
                
                amountCellView.frame = CGRectMake(i%4*(8+widthBig), 30*floor(i/4)+10*floor(i/4) , widthBig, 35);
                amountCellView.tag = 20001+i;
                [choiseMoneyView addSubview:amountCellView];
                
                amountCellView.title.text = [NSString toAmount:titleMon].toRate.toUnit;
                amountCellView.extraData = titleMon;
                
                UITapGestureRecognizer *tapAmount = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(amountChoise:)];
                
                [amountCellView addGestureRecognizer:tapAmount];
                
                NSString *subTitle = titleRate;

                if(!subTitle || [subTitle isKindOfClass:[NSNull class]] || !subTitle.length){
                    amountCellView.subTitle.hidden = YES;
                    amountCellView.heightSubLabelConstraint.constant = 0;
                }else{
                    amountCellView.heightSubLabelConstraint.constant = 15;
                    amountCellView.subTitle.text = subTitle;
                    amountCellView.subTitle.hidden = NO;
                }
                
                if(curselectIndexMoney == i){
                    [amountCellView setSelectedStatus:true];
                    votesT.text = [NSString toAmount:amountCellView.extraData];
                    
                    [self updateCurrenyLabel];
                    [self ChangeMoenyLabelValue];
                }else{
                    [amountCellView setSelectedStatus:false];
                }
                [choiseMoneyView addSubview:amountCellView];
                
                if (i==quickAmountArray.count-1) {
                    choiseMoneyView.height = amountCellView.bottom;
                }
            }
        }
        
       
        tipFreeMoneyLabel.frame = CGRectMake(10, choiseMoneyView.bottom+5, SCREEN_WIDTH-20, 40);
        

        
        //标题 提现金额
        // 列表
        //到账金额
        //刷新
        
        
//        cell=[[[XBundle currentXibBundleWithResourceName:@"RankCell"] loadNibNamed:@"RankCell" owner:self options:nil] firstObject];
        
    }else{
        if (typeBankBgView.hidden) {
            typeBankBgView.hidden = NO;
        }
        if (tip2Label.hidden) {
            tip2Label.hidden = NO;
        }
        if (tipFreeDrawTitleLabel) {
            tipFreeDrawTitleLabel.hidden = YES;
        }
        if (choiseMoneyView) {
            [choiseMoneyView removeAllSubviews];
            choiseMoneyView.hidden = YES;
        }
        tipFreeMoneyLabel.hidden = YES;
    }
   
    
    typeBankBgView.frame = CGRectMake(10, tipsLabel.bottom + 10, SCREEN_WIDTH-20, 50);
    tip2Label.frame = CGRectMake(20, typeBankBgView.bottom + 8, SCREEN_WIDTH-44, 40);
    if (!inputBtn) {
        inputBtn = [UIButton buttonWithType:0];
        inputBtn.frame = CGRectMake(_window_width*0.04, SCREEN_HEIGHT-80, _window_width*0.92, 44);
        [inputBtn setBackgroundImage:nil];
        [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
        [inputBtn setTitle:YZMsg(@"myProfitVC_withDraw_now") forState:0];

        [inputBtn addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
        inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        inputBtn.layer.cornerRadius = 22;
        inputBtn.layer.masksToBounds = YES;
        inputBtn.userInteractionEnabled = YES;
        [self.view addSubview:inputBtn];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeMoenyLabelValue) name:UITextFieldTextDidChangeNotification object:nil];
//    bNeedObserverFieldDidChange = false;
    
    [scrollBgView setContentSize:CGSizeMake(SCREEN_WIDTH,  8+48+64 + ((!choiseMoneyView||choiseMoneyView.hidden)?tip2Label.bottom+10:choiseMoneyView.bottom+30))];

    [self refreshUI];
    
    [self getDefaultAccount];
}

-(void)amountChoise:(UIGestureRecognizer*)gest
{
    PayAmountCollectionViewCell *cell = (PayAmountCollectionViewCell*)gest.view;
    if (curselectIndexMoney == cell.tag-20001) {
        return;
    }
    votesT.text = [NSString toAmount:cell.extraData].toRate;
    curselectIndexMoney = cell.tag-20001;
    
    if (withdraw_configArray) {
        [self creatUIWithArray:withdraw_configArray];
    }
    [self ChangeMoenyLabelValue];
    
}

-(void)updateCurrenyLabel{
    NSArray *quick_amount = quickAmountArray;
    
    for (NSInteger i = (quick_amount.count-1); i>=0; i--) {
      
        
        NSString *title = [NSString stringWithFormat:@"%@",quick_amount[i][@"title"]];
        if (title && [title floatValue]>0.00) {
            if ([votesT.text floatValue]>=[title floatValue]) {
                NSString *give_rate = quick_amount[i][@"give_rate"];
                
                NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:give_rate];
                
                NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                                    decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                    scale:2
                                                    raiseOnExactness:NO
                                                    raiseOnOverflow:NO
                                                    raiseOnUnderflow:NO
                                                    raiseOnDivideByZero:YES];
                NSDecimalNumber *numberOrig = [NSDecimalNumber decimalNumberWithString:votesT.text];
                
                NSDecimalNumber *numberByMultiplying= [numberOrig decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
                
                
                
                NSDecimalNumber *amountDecimal = [numberByMultiplying decimalNumberByAdding:numberOrig withBehavior:roundDown];
                
                NSString *calculateN = [NSString stringWithFormat:@"%.2f",amountDecimal.floatValue];
                
                
                NSString *resultStr=  [NSString stringWithFormat:YZMsg(@"curreny_unit_alert_charge"),[PublicObj removeFloatAllZero:calculateN],[common name_coin]];
                
                if (needFlow && needFlow.length>0) {
                    NSDecimalNumber *numb = [NSDecimalNumber decimalNumberWithString:needFlow];
                    if (numb.doubleValue>0) {
                        resultStr = [NSString stringWithFormat:YZMsg(@"ChargeNumberTip%@"), [NSString toAmount:needFlow].toRate.toUnit];
                    }
                }
                tipFreeMoneyLabel.text = resultStr;
                break;
                
            }
        }
    }
    
}




-(void)choiseBankTypeAction:(UIButton*)buttonBankTp
{
    if (selectedBankType == (buttonBankTp.tag-100)) {
        return;
    }
    selectedBankType = buttonBankTp.tag-100;
    selectedSubBankType = -1;
    if (withdraw_configArray) {
        [self creatUIWithArray:withdraw_configArray];
    }
    
}

-(void)choiseSubBankTypeAction:(UIButton*)buttonBankTp
{
    if (selectedSubBankType == (buttonBankTp.tag - 2000)) {
        return;
    }
    selectedSubBankType = buttonBankTp.tag-2000;
    
    if (withdraw_configArray) {
        [self creatUIWithArray:withdraw_configArray];
    }
    
}


- (void)showExchangeTip{
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"myWithdrawVC2_limitDes") message:YZMsg(@"myWithdrawVC2_WithDrawDesTip") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertC addAction:suerA];
    if (currentVC.presentedViewController == nil) {
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
    
}

- (void)commonRefresh:(NSDictionary *)infoDic{
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    
    if ( selectedSubBankType==12) {
        rate = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    }
    
    balanceNum =  [infoDic valueForKey:@"balance"];
    needFlow = [infoDic valueForKey:@"needFlow"];
    left_coin = minstr([infoDic valueForKey:@"new_coin"]);
    noWithdrawAmount = minstr([infoDic valueForKey:@"noWithdrawAmount"]);
    
    minWithdraw = [minstr([infoDic valueForKey:@"minWithdraw"]) stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                      decimalNumberHandlerWithRoundingMode:NSRoundDown
                                      scale:0
                                      raiseOnExactness:NO
                                      raiseOnOverflow:NO
                                      raiseOnUnderflow:NO
                                      raiseOnDivideByZero:YES];
    
    NSDecimalNumber *minWithdrawNumber = [[NSDecimalNumber decimalNumberWithString:[minstr([infoDic valueForKey:@"minWithdraw"]) stringByReplacingOccurrencesOfString:@"," withString:@""]] decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
//    minWithdraw = minWithdraw*rate*100/100.0;
    minWithdraw = minWithdrawNumber.stringValue;
    
    NSDecimalNumber *maxWithdrawNumber = [[NSDecimalNumber decimalNumberWithString: [minstr([infoDic valueForKey:@"maxWithdraw"]) stringByReplacingOccurrencesOfString:@"," withString:@""]] decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
    
    maxWithdraw = maxWithdrawNumber.stringValue;
//    maxWithdraw = maxWithdraw*rate*100/100.0;
    LiveUser *user = [Config myProfile];
    user.coin = minstr([infoDic valueForKey:@"coin"]);
    tip = minstr([infoDic valueForKey:@"tip"]);
    double valueNeedFlow = [needFlow doubleValue];
    if (valueNeedFlow>=0.01) {
        tip = [NSString stringWithFormat:YZMsg(@"WithDrawNumberTip%@"), [NSString toAmount:needFlow].toRate.toUnit];
    }
    [Config updateProfile:user];
    withdraw_configArray = [infoDic objectForKey:@"withdraw_config"];
    
  
    [self creatUIWithArray:withdraw_configArray];
    
   
   
    
    
    
    
}
-(void)refreshUI{
    
    
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                      decimalNumberHandlerWithRoundingMode:NSRoundDown
                                      scale:2
                                      raiseOnExactness:NO
                                      raiseOnOverflow:NO
                                      raiseOnUnderflow:NO
                                      raiseOnDivideByZero:YES];
//    NSDecimalNumber *leftCoin = [[NSDecimalNumber decimalNumberWithString:balanceNum]decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
    
    leftCoinLable.text = [NSString toAmount:left_coin].toRate.toUnit;
//    leftCoin2Lable.text =  [NSString stringWithFormat:@"≈%@(%@)", [YBToolClass getRateCurrency:balanceNum showUnit:YES], [Config getRegionCurreny]];
//    float coin_int = [balanceNum floatValue];
    [leftCoinLable sizeToFit];
//    leftCoin2Lable.left = leftCoinLable.right+5;
//    [leftCoin2Lable sizeToFit];
    
    NSDecimalNumber *subDecimal = [[NSDecimalNumber decimalNumberWithString:balanceNum] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:noWithdrawAmount]];
    
    if (subDecimal.floatValue<0) {
        subDecimal = [NSDecimalNumber decimalNumberWithString:@"0"];
    }

//    if (selectedSubBankType != 12) {
        NSDecimalNumber *withdrawAmount_value = [subDecimal decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
        
       
        UIImageView *imgView = [withdrawAmountLabel viewWithTag:1021];
        if (imgView) {
            imgView.hidden = YES;
        }
        withdrawAmountLabel.text = [NSString toAmount:withdrawAmount_value.stringValue].toUnit;
    
//    }else{
//        withdrawAmountLabel.text = [NSString stringWithFormat:@"    %@",subDecimal.stringValue];
//        UIImageView *imgView = [withdrawAmountLabel viewWithTag:1021];
//        if (!imgView) {
//            imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,15, 20, 20)];
//            [imgView setImage:[ImageBundle imagewithBundleName:@"yfks_zs"]];
//            imgView.tag = 1021;
//            [withdrawAmountLabel addSubview:imgView];
//        }else{
//            imgView.hidden = NO;
//        }
//
//
//
//    }
    
    
    if(noWithdrawAmountLabel){
//        NSDecimalNumber *noWithdrawAmount_value = [[NSDecimalNumber decimalNumberWithString:noWithdrawAmount] decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
//        CGFloat  noWithdrawAmount_value = noWithdrawAmount* rate * 100;
        noWithdrawAmountLabel.text = [NSString toAmount:noWithdrawAmount].toRate.toUnit;
        [tipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(25);
            make.centerY.mas_equalTo(noWithdrawAmountLabel.mas_centerY);
            make.right.mas_equalTo(textInputBgView.mas_right).offset(-10);
        }];
    }else{
        [tipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(25);
            make.centerY.mas_equalTo(withdrawAmountLabel.mas_centerY);
            make.right.mas_equalTo(textInputBgView.mas_right).offset(-10);
        }];
    }
    
    
    tipsLabel.text = tip;
    [tipsLabel sizeToFit];
    UIView *typeView = [scrollBgView viewWithTag:1200];
    if (typeView) {
        typeView.top = tipsLabel.bottom + 10;
        inputBtn.top = SCREEN_HEIGHT-70;
    }
    UILabel *tip2Label = [scrollBgView viewWithTag:1201];
    if (tip2Label) {
        tip2Label.top = typeView.bottom + 8;
    }
    
    
}
-(void)refreshCoinBtnClick{
//    [MBProgressHUD showMessage:YZMsg(@"myWithdrawVC2_UpdatingBalance")];
    [self requestData];
}


-(void)getDefaultAccount{
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetUserAccountList" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSDictionary *dicBank = nil;
        if (code == 0) {
            if ([info isKindOfClass:[NSArray class]]) {
                NSArray *arrayBanks = info;
                if (arrayBanks.count>0) {
                    for (NSDictionary *subBankDic in arrayBanks) {
                        NSInteger bankType = [subBankDic[@"type"] integerValue];
                        if (bankType == strongSelf->selectedSubBankType ) {
                            dicBank = subBankDic;
                            [strongSelf setDefaultBank:subBankDic];
                            break;
                        }
                    }
                }
            }
        }else{
            
        }
        if (dicBank == nil) {
            [strongSelf setDefaultBank:nil];
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf setDefaultBank:nil];
    }];
}

//选择z提现方式
- (void)selectPayType{
    profitTypeVC *vc = [[profitTypeVC alloc]init];
    vc.types = self.types;
    vc.typeNum = selectedSubBankType;
    if (typeDic) {
        vc.selectID = minstr([typeDic valueForKey:@"id"]);
    }else{
        vc.selectID = YZMsg(@"myProfitVC_NoWithDrawError");
    }
    [vc setnOnlyCard];
    WeakSelf
    vc.block = ^(NSDictionary * _Nonnull dic) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf setDefaultBank:dic];

    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)setDefaultBank:(NSDictionary *)dic{
   
    typeDic = dic;
    
    if (dic == nil) {
        seletTypeImgView.hidden = YES;
        typeLabel.frame = CGRectMake(textInputBgView.width*0.05, 0, typeBankBgView.width*0.95-40, 50);
        typeLabel.text = YZMsg(@"myProfitVC_choise_withDraw_account");
        return;
    }
    seletTypeImgView.hidden = NO;
    typeLabel.x = seletTypeImgView.right + 5;
    int type = [minstr([dic valueForKey:@"type"]) intValue];
    switch (type) {
        case 1:
           seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_alipay"];
           typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;
        case 2:
           seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_wx"];
           typeLabel.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];

            break;
        case 3:
           seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
           typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;
            
        default:
           seletTypeImgView.image = [ImageBundle imagewithBundleName:@"profit_card"];
           typeLabel.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;
    }
}
//提交申请
- (void)inputBtnClick{
//    RechargePopView * popView = [[RechargePopView alloc] init];
//    [self.view gy_creatPopViewWithContentView:popView withContentViewSize:CGSizeMake(_window_width * 0.8,186)];
   
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"withdraw_name": selectedSubBankType == 3 ? @"银行卡" : @"免提直充"};
    [MobClick event:@"withdraw_sure_click" attributes:dict];

    NSDictionary *withdrawInfo = [Config getWithdrawInfo];
    if (![withdrawInfo isKindOfClass:[NSDictionary class]] || withdrawInfo == nil) {
        withdrawInfo = @{};
    }
    BOOL isWithdrawable = [withdrawInfo[@"isWithdrawable"] boolValue];
    if (!isWithdrawable) {
        [self.view gy_creatPopViewWithContentView:self.withdrawPopView withContentViewSize:CGSizeMake(_window_width * 0.8,186)];
        return;
    }
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
//    float coin_int = [balanceNum floatValue];
//    float CoinBalanceNu = coin_int*rate*100/100.0;
    
    NSDecimalNumber *coin_int = [NSDecimalNumber decimalNumberWithString:balanceNum];
    NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                      decimalNumberHandlerWithRoundingMode:NSRoundDown
                                      scale:2
                                      raiseOnExactness:NO
                                      raiseOnOverflow:NO
                                      raiseOnUnderflow:NO
                                      raiseOnDivideByZero:YES];
    
    NSDecimalNumber *CoinBalanceNu = [coin_int decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
    if (selectedSubBankType == 12) {
        CoinBalanceNu = coin_int;

    }
   
    NSDecimalNumber *subDecimal = [[NSDecimalNumber decimalNumberWithString:balanceNum] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:noWithdrawAmount]];
    if (subDecimal.floatValue<0) {
        subDecimal = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    NSDecimalNumber *withdrawAmount_value = [subDecimal decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
    if (selectedSubBankType == 12) {
        withdrawAmount_value = subDecimal;

    }
    
//    CGFloat  withdrawAmount_value = MAX(0, coin_int - noWithdrawAmount)* rate * 100/100.0;
  
//    float v = [votesT.text longLongValue];
    NSDecimalNumber *v = [NSDecimalNumber decimalNumberWithString:votesT.text];
                                   
    BOOL bCanClickBtn = true;
    if([v compare: CoinBalanceNu] == NSOrderedDescending){
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_NoBalance")];
        bCanClickBtn = false;
    }else if([v compare:withdrawAmount_value] == NSOrderedDescending){
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"myWithdrawVC2_WithDrawOver%@%f"),[Config getRegionCurrenyChar],withdrawAmount_value.doubleValue]];
        bCanClickBtn = false;
    }else if ([v compare: [NSDecimalNumber decimalNumberWithString:maxWithdraw]] == NSOrderedDescending) {
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"myWithdrawVC2_MaxWithDrawMoney%@%@"),[Config getRegionCurrenyChar],[NSDecimalNumber decimalNumberWithString:maxWithdraw].doubleValue]];
        votesT.text = [NSString stringWithFormat:@"%@", maxWithdraw];
        bCanClickBtn = false;
    }else if([v compare: [NSDecimalNumber decimalNumberWithString:minWithdraw]] == NSOrderedAscending){
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"myWithdrawVC2_MinWithDrawMoney%@%.1f"),[Config getRegionCurrenyChar],[NSDecimalNumber decimalNumberWithString:minWithdraw].doubleValue]];
        bCanClickBtn = false;
    }
    if(!bCanClickBtn) return;
    
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
    
    NSDecimalNumber  *num =  [v decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
    NSDecimalNumber  *leftCoin = [num decimalNumberByDividingBy:rate];
    
//    if (selectedSubBankType == 12) {
//        leftCoin = num;
//    }

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.gameWithdraw" withBaseDomian:YES andParameter:@{@"coin":leftCoin.stringValue, @"cardId":minstr([typeDic valueForKey:@"id"]), @"uid":[Config getOwnID], @"token":[Config getOwnToken]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf->votesT.text = @"0";
            if(msg.length > 0){
                [GameToolClass showTip:YZMsg(@"public_warningAlert") tipString:msg];
            }else{
                [GameToolClass showTip:YZMsg(@"h5game_submit_successfully") tipString:YZMsg(@"myWithdrawVC2_WithDrawWaitTip")];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf == nil) {
                    return;
                }
                [MBProgressHUD hideHUD];
                [strongSelf requestData];
            });
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
    
}
- (void)ChangeMoenyLabelValue{
    if(votesT.text.length<=0){
        votesT.text = @"0";
        return;
    }
    NSDecimalNumber  *v = [NSDecimalNumber decimalNumberWithString:votesT.text];
    
    NSDecimalNumber  *balance = [NSDecimalNumber decimalNumberWithString:balanceNum];
//    float coin_int = [balanceNum floatValue];
    
    
    
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    if (selectedSubBankType == 12) {
        rate = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    }
    
    NSDecimalNumberHandler*roundDown = [NSDecimalNumberHandler
                                      decimalNumberHandlerWithRoundingMode:NSRoundDown
                                      scale:0
                                      raiseOnExactness:NO
                                      raiseOnOverflow:NO
                                      raiseOnUnderflow:NO
                                      raiseOnDivideByZero:YES];
     
    NSDecimalNumber *subDecimal = [balance decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:noWithdrawAmount]];
    if (subDecimal.floatValue<0) {
        subDecimal = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    NSDecimalNumber *withdrawAmount_value = [subDecimal decimalNumberByMultiplyingBy:rate withBehavior:roundDown];
    
//    if(v_f - v > 0){
//        votesT.text = v.stringValue;
//    }
//    float coin_realy_value = left_coin / 10.0;
    
    BOOL bCanClickBtn = false;
    if([v compare: withdrawAmount_value] == NSOrderedDescending){
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"myWithdrawVC2_WithDrawOver%@%f"),[Config getRegionCurrenyChar],[withdrawAmount_value doubleValue]]];
        votesT.text = withdrawAmount_value.stringValue;
        bCanClickBtn = false;
    }else if ([v compare: [NSDecimalNumber decimalNumberWithString:maxWithdraw]] == NSOrderedDescending) {
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"myWithdrawVC2_MaxWithDrawMoney%@%.1f"),[Config getRegionCurrenyChar],maxWithdraw]];
        votesT.text = maxWithdraw;
        bCanClickBtn = false;
    }else if([v compare: [NSDecimalNumber decimalNumberWithString:minWithdraw]] == NSOrderedAscending){
        bCanClickBtn = false;
    }else{
        bCanClickBtn = true;
    }
    
    if(bCanClickBtn){
//        inputBtn.userInteractionEnabled = YES;
        [inputBtn setBackgroundColor:[UIColor clearColor]];
        [inputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"submit_withdraw"]];
    }else{
//        inputBtn.userInteractionEnabled = NO;
        [inputBtn setBackgroundImage:nil];
        [inputBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
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
