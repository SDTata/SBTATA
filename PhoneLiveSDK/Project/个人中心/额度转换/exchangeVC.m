//
//  exchangeVC
//  yunbaolive
//
//  Copyright © 2018年 cat. All rights reserved.
//

#import "exchangeVC.h"
#import "myWithdrawVC.h"
#import "myRechargeCoinVC.h"
#import "webH5.h"
#import "WMZDialog.h"

typedef void (^balanceback)(NSString *balance,NSString *game_plat,NSInteger idx,NSDictionary*dicPlat);

@interface NetworkForUpdateBalance : NSObject

@property(nonatomic,strong)NSString *game_plat;
@property(nonatomic,assign)NSInteger idx;
@property(nonatomic,strong)NSDictionary *dicPlat;
-(void)updateBalance:(balanceback)callabck;
@end

@implementation NetworkForUpdateBalance

-(void)updateBalance:(balanceback)callabck
{
    NSString *getBalanceNewUrl = [NSString stringWithFormat:@"User.getPlatGameBalance&uid=%@&token=%@&game_plat=%@",[Config getOwnID],[Config getOwnToken],self.game_plat];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getBalanceNewUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = info;
            if ([infoDic isKindOfClass:[NSDictionary class]]) {
                NSString *coin = minstr([infoDic objectForKey:@"coin"]);
                if (![PublicObj checkNull:coin]) {
                    callabck(coin,strongSelf.game_plat,strongSelf.idx,strongSelf.dicPlat);
                }else{
                    callabck(@"0.00",strongSelf.game_plat,strongSelf.idx,strongSelf.dicPlat);
                }
            }else{
                callabck(@"0.00",strongSelf.game_plat,strongSelf.idx,strongSelf.dicPlat);
            }
            
        }else{
            callabck(@"0.00",strongSelf.game_plat,strongSelf.idx,strongSelf.dicPlat);
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        callabck(@"0.00",strongSelf.game_plat,strongSelf.idx,strongSelf.dicPlat);
      
    }];

}

@end


@interface exchangeVC (){
    UIButton *chargeIntoCoinBtn;
    UIButton *withDrawingBtn;
    UITextField *votesT;
    
    UIButton *refreshCoinBtn;
    UIButton *oneKeyRecoverBtn;
    
    UILabel *leftCoinLable;
//    UILabel *leftCoin2Lable;
    
    
    //
    float left_coin;
    NSString* invite_url;// 分享链接
    
    BOOL bAutoExchange;
    NSMutableDictionary *cardDict;
    NSMutableDictionary *btnTag;
    NSMutableArray *platArray;
    
    
    BOOL bCreateUI;
    
    WMZDialog *myAlert;
    UITextField *alertTextField;
    NSString *convType;
    
    UIScrollView *screenView;
}

@property(nonatomic,strong)NSMutableArray *requestBalance;

@end

@implementation exchangeVC
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
    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0, statusbarHeight, _window_width/3, 64)];
    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:bigBTN];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];

    [self.view addSubview:navtion];
}


-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(244, 245, 246);
    UIImageView *bgImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bgImgV.image = [ImageBundle imagewithBundleName:@"exchange_bg_view"];
    [self.view addSubview:bgImgV];
    CGFloat y = 64 + statusbarHeight + 145;
    screenView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - y - 10)];
    screenView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:screenView];
    [self navtion];
    cardDict = [[NSMutableDictionary alloc] init];
    btnTag = [[NSMutableDictionary alloc] init];
    
    
//    [self creatUI];
    bCreateUI = false;
    [self requestData];
    screenView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}
- (void)requestData{
   MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *getBalanceNewUrl = [NSString stringWithFormat:@"User.getPlatGameBalance&uid=%@&token=%@&game_plat=user",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getBalanceNewUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        //当旋转结束时隐藏
        [MBProgressHUD hideHUD];
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            strongSelf->bAutoExchange = [common getAutoExchange];
            NSDictionary *infoDic = info;
            [strongSelf commonRefreshCoin:infoDic];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
       
        [MBProgressHUD hideHUD];
    }];
}
- (void)tapClick{
    [votesT resignFirstResponder];
}
- (void)creatUI{
    bCreateUI = true;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [screenView addGestureRecognizer:tap];
    
    //背景图
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 64 + statusbarHeight, _window_width-20, 140)];
    backImgView.image = [ImageBundle imagewithBundleName:@"exchange_balance_bottom"];
    [self.view addSubview:backImgView];
    
//    int xOffset = -0;
    int yOffset = -0;
    //账户余额
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, backImgView.height/5*1+yOffset, backImgView.width, 16)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    NSString *curreny = [NSString stringWithFormat:@" (%@)",[Config getRegionCurreny]];
    label.text = [NSString stringWithFormat:YZMsg(@"myWithdrawVC2_Account%@_Balance"),curreny];
    [backImgView addSubview:label];
    //账户余额1
    
    NSString *left_coin_str = [NSString stringWithFormat:@"%.2f",left_coin];
    left_coin_str = [YBToolClass getRateCurrency:left_coin_str showUnit:YES];
    CGFloat leftCoinLableW = [[YBToolClass sharedInstance] widthOfString:left_coin_str andFont:[UIFont boldSystemFontOfSize:26] andHeight:backImgView.height/4];
    leftCoinLable = [[UILabel alloc]initWithFrame:CGRectMake(label.left, backImgView.height/2 - 24/2, leftCoinLableW, 24)];
    leftCoinLable.textColor = [UIColor yellowColor];
    leftCoinLable.font = [UIFont boldSystemFontOfSize:26];
    leftCoinLable.text = left_coin_str;
    [backImgView addSubview:leftCoinLable];
    
    //账户余额2
//    NSString *left_coin2_str = @"";//[NSString stringWithFormat:@"(%.2f%@)", left_coin, [common name_coin]];
//    CGFloat label3W = [[YBToolClass sharedInstance] widthOfString:left_coin2_str andFont:[UIFont systemFontOfSize:14] andHeight:backImgView.height/4];
//    leftCoin2Lable = [[UILabel alloc]initWithFrame:CGRectMake(leftCoinLable.right + 3, leftCoinLable.y + 6, label3W, 14)];
//    leftCoin2Lable.textColor = [UIColor yellowColor];
//    leftCoin2Lable.font = [UIFont boldSystemFontOfSize:18];
//    leftCoin2Lable.text = left_coin2_str;
//    [backImgView addSubview:leftCoin2Lable];
    // 刷新余额按钮
    refreshCoinBtn = [UIButton buttonWithType:0];
    refreshCoinBtn.frame = CGRectMake(leftCoinLable.right+5, leftCoinLable.y - 2, 30, 30);
    [refreshCoinBtn setImage:[ImageBundle imagewithBundleName:@"zf_cx"] forState:UIControlStateNormal];
    [refreshCoinBtn addTarget:self action:@selector(refreshCoinBtnClick) forControlEvents:UIControlEventTouchUpInside];
    refreshCoinBtn.userInteractionEnabled = YES;
    [backImgView addSubview:refreshCoinBtn];
    
    // 自动兑换开关文本
    UILabel *switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, backImgView.height/5*4+yOffset - 14/2, 90, 14)];
    switchLabel.textAlignment = NSTextAlignmentLeft;
    switchLabel.adjustsFontSizeToFitWidth = YES;
    switchLabel.minimumScaleFactor = 0.3;
    switchLabel.textColor = [UIColor whiteColor];
    switchLabel.font = [UIFont systemFontOfSize:16];
    switchLabel.text = [NSString stringWithFormat:@"%@",YZMsg(@"exchangeVC_balanceAutoChange")];
    [backImgView addSubview:switchLabel];
    // 自动兑换开关按钮
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(switchLabel.right - 3, backImgView.height/5*4+yOffset - 14/2 - 7, 50, 30)];
    [mySwitch addTarget:self action:@selector(changeAutoExchange:) forControlEvents:(UIControlEventValueChanged)];
    [mySwitch setBackgroundColor:[UIColor colorWithRed:225/255.f green:225/255.f blue:225/255.f alpha:1.f]];
    [mySwitch setOnTintColor:[UIColor colorWithRed:237/255.f green:114/255.f blue:206/255.f alpha:1.f]];
    [mySwitch setThumbTintColor:[UIColor whiteColor]];
    mySwitch.layer.cornerRadius = 15.5f;
    mySwitch.layer.masksToBounds = YES;
    mySwitch.on = bAutoExchange;
    mySwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    [backImgView addSubview:mySwitch];
    backImgView.userInteractionEnabled = YES;

    // 一键回收
    oneKeyRecoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    oneKeyRecoverBtn.frame = CGRectMake(backImgView.width - 15 - 80, switchLabel.y - 15, 80, 40);
    oneKeyRecoverBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    oneKeyRecoverBtn.titleLabel.minimumScaleFactor = 0.5;
    
    [oneKeyRecoverBtn setTitle:YZMsg(@"exchangeVC_OneKeyBack") forState:0];
    [oneKeyRecoverBtn addTarget:self action:@selector(oneKeyRecoverClick) forControlEvents:UIControlEventTouchUpInside];
    oneKeyRecoverBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//    oneKeyRecoverBtn.titleLabel.textColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:153/255.f alpha:1.f];
    [oneKeyRecoverBtn.titleLabel setTextColor:RGB_COLOR(@"#FF3399", 1)];
    [oneKeyRecoverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  
    [oneKeyRecoverBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"exchange_back_money_button.png"] forState:UIControlStateNormal];
    oneKeyRecoverBtn.userInteractionEnabled = YES;
    oneKeyRecoverBtn.layer.cornerRadius = 15;                           //圆角弧度
    oneKeyRecoverBtn.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
    oneKeyRecoverBtn.layer.shadowOpacity = 0.25;                         //阴影的不透明度
    oneKeyRecoverBtn.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
    [backImgView addSubview:oneKeyRecoverBtn];
    
//    // testcode
//    for (int i=0; i<2; i++) {
//        NSDictionary *platInfo = @{
//                                   @"plat":@"ky",    //对应平台
//                                   @"name":@"开元",    //平台名称
//                                   @"logo":@"https://www.baidu.com/img/baidu_resultlogo@2.png",//可选
//                                   @"coin":@"3.0"    //余额
//                                   };
//        [self refreshCard:platInfo order:i+1];
//    }
}

- (void)inputSubMoney:(UIButton *)sender{
//    NSString *plat = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"plat"];
    convType = @"in";
    [self doConv:sender];
}

-(void)outputSubMoney:(UIButton *)sender{
//    NSString *plat = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"plat"];

    convType = @"out";
    [self doConv:sender];
}

- (void)doConv:(UIButton *)sender{
    WeakSelf
    myAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    //关闭事件 此时要置为不然会内存泄漏
    .wEventCloseSet(^(id anyID, id otherData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->myAlert = nil;
    })
    .wShowAnimationSet(AninatonZoomIn)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.25)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        STRONGSELF
        if (strongSelf == nil) {
            [UIView new];
        }
        UILabel *title = [UILabel new];
        title.font = [UIFont systemFontOfSize:15.0f];
        title.adjustsFontSizeToFitWidth = YES;
        title.minimumScaleFactor = 0.5;
        if([minstr(strongSelf->convType)isEqualToString:@"in"]){
            title.text = YZMsg(@"exchangeVC_SwitchIn");
        }else{
            title.text = YZMsg(@"exchangeVC_SwitchOut");
        }
        
        title.frame = CGRectMake(0, 0, mainView.frame.size.width, 30);
        [title setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:title];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, mainView.frame.size.width/3*2, 30)];
        textField.placeholder = YZMsg(@"exchangeVC_Input_Money");
        textField.font = [UIFont systemFontOfSize:15.0f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:textField];
        strongSelf->alertTextField = textField;
        
        // 全部
        UIButton *allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        allBtn.frame = CGRectMake(textField.right, textField.y, 65, 30);
        [allBtn setTitle:YZMsg(@"exchangeVC_all") forState:0];
        [allBtn addTarget:self action:@selector(allBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        allBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //    allBtn.titleLabel.textColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:153/255.f alpha:1.f];
        [allBtn.titleLabel setTextColor:RGB_COLOR(@"#FF3399", 1)];
        [allBtn setTitleColor:RGB_COLOR(@"#FF3399", 1) forState:UIControlStateNormal];
        [allBtn setBackgroundColor:[UIColor whiteColor]];
        //    [allBtn setImage:[ImageBundle imagewithBundleName:@"icon_refresh.png"] forState:UIControlStateNormal];
        allBtn.userInteractionEnabled = YES;
        allBtn.layer.cornerRadius = 15;                           //圆角弧度
        allBtn.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
        allBtn.layer.shadowOpacity = 0.25;                         //阴影的不透明度
        allBtn.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
        allBtn.tag = sender.tag;
        [mainView addSubview:allBtn];
        
        //        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [mainView addSubview:cancelBtn];
        //        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        //        cancelBtn.frame = CGRectMake(0, 80, mainView.frame.size.width/2, 40);
        //        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        //        [cancelBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        //        cancelBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        //        cancelBtn.layer.borderWidth = 1; //边框的宽度
        //        cancelBtn.layer.cornerRadius = 10;
        //        [cancelBtn addTarget:WEAK action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        confirmBtn.frame = CGRectMake(0, 80, mainView.frame.size.width, 40);
        [confirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        //        confirmBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        //        confirmBtn.layer.borderWidth = 1; //边框的宽度
        confirmBtn.layer.cornerRadius = 10;
        [confirmBtn addTarget:strongSelf action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        confirmBtn.tag = sender.tag;
        
        mainView.layer.masksToBounds = YES;
        mainView.layer.cornerRadius = 10;
        return confirmBtn;
    })
    .wStart();
}

- (void)allBtnClick:(UIButton*)sender{
    NSString *plat = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"plat"];
    float coin;
    if([minstr(convType) isEqualToString:@"in"]){
        coin = left_coin / 10.0;
    }else{
        coin = [self getCoinByPlat:plat];
    }
    
    NSString *text = [NSString stringWithFormat:@"%.2f", coin];
    alertTextField.text = [YBToolClass getRateCurrencyWithoutK:text];
}

- (float)getCoinByPlat:(NSString *)plat{
    NSInteger ret = 0;
    for (int i=0; i<platArray.count; i++) {
        NSDictionary *platInfo = [platArray objectAtIndex:i];
        if([minstr(plat) isEqualToString:minstr(platInfo[@"plat"])]){
            return [platInfo[@"coin"] floatValue];
        }
    }
    return ret;
}
- (void)commonRefreshCoin:(NSDictionary *)infoDic{
    left_coin = [minstr([infoDic valueForKey:@"coin"]) floatValue];
    LiveUser *user = [Config myProfile];
    user.coin = minstr([infoDic valueForKey:@"coin"]);
    [Config updateProfile:user];
    if (platArray) {
        [platArray removeAllObjects];
    }
    platArray = [NSMutableArray arrayWithArray:[infoDic valueForKey:@"game_plat_list"]];
    if(!bCreateUI){
        [self creatUI];
    }
    
    [self refreshCoinValue];
    if (self.requestBalance == nil) {
        self.requestBalance = [NSMutableArray array];
    }
    [self.requestBalance removeAllObjects];
    
    for (int i=0; i<platArray.count; i++) {
        NSDictionary *platInfo = [platArray objectAtIndex:i];
        
        NSInteger idx = i + 1;
        if(btnTag){
            for (NSString *key in btnTag) {
                if([minstr(btnTag[key][@"plat"]) isEqualToString:minstr(platInfo[@"plat"])]){
                    idx = [key integerValue];
                    break;
                }
            }
        }
        [self refreshCard:platInfo order:idx];
        
    }
    
}
//弹窗自定义方法
- (void)confirmAction:(UIButton*)sender{
    NSLog(@"点击方法");
    NSString *plat = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"plat"];
    
    if (alertTextField.text.length == 0 || [alertTextField.text isEqualToString:@"0"]) {
        [MBProgressHUD showError:YZMsg(@"profit2_input_money")];
    }else{
        //关闭
        [myAlert closeView];
        NSInteger operateValue = 0;
        if([minstr(convType) isEqualToString:@"in"]){
            operateValue = [[YBToolClass getRmbCurrency:alertTextField.text] integerValue]*10;
        }else{
            operateValue = [[YBToolClass getRmbCurrency:alertTextField.text] integerValue];
        }
        
        [MBProgressHUD showMessage:YZMsg(@"exchangeVC_option")];
        NSString *convertCoinUrl = [NSString stringWithFormat:@"User.convertCoin&uid=%@&token=%@&subplat=%@&operate=%@&value=%ld",[Config getOwnID],[Config getOwnToken],plat,convType,operateValue];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:convertCoinUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [MBProgressHUD hideHUD];
            if (code == 0 && info && ![info isEqual:[NSNull null]]) {
          
                [strongSelf requestData];
            }else{
               
                [MBProgressHUD showError:msg];
          
            }
        } fail:^(NSError * _Nonnull error) {
            [MBProgressHUD hideHUD];
        }];
    }
}

//弹窗自定义方法
- (void)closeAction:(UIButton*)sender{
    NSLog(@"点击方法");
    //关闭
    [myAlert closeView];
}

-(void)refreshSubCoinBtnClick:(UIButton *)sender{
//    NSString *plat = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"plat"];
    NSString *name = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"name"];
    
//    NSString *order_str = btnTag[[NSString stringWithFormat:@"%ld",sender.tag]][@"order"];
    [MBProgressHUD showMessage:[NSString stringWithFormat:YZMsg(@"exchangeVC_Refresh%@_Balance"),name]];
    
    [self requestData];
}

-(void)oneKeyRecoverClick{
    [MBProgressHUD showMessage:YZMsg(@"exchangeVC_OneKeyBack")];
    WeakSelf
    [GameToolClass backAllCoin:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = info;
            if([infoDic isKindOfClass:[NSArray class]]){
                infoDic =  [info firstObject];
            }
//            [strongSelf commonRefreshCoin:infoDic];
            [strongSelf requestData];
        }else if(msg && ![msg isEqual:[NSNull null]]&& msg.length > 0){
            
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
       //当旋转结束时隐藏
        [MBProgressHUD hideHUD];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
}
-(void)refreshCoinValue{
   
    NSString *left_coin_str = [NSString stringWithFormat:@"%.2f",floor(left_coin*100/10)/100];
    left_coin_str = [YBToolClass getRateCurrency:left_coin_str showUnit:YES];
    CGFloat leftCoinLableW = [[YBToolClass sharedInstance] widthOfString:left_coin_str andFont:[UIFont boldSystemFontOfSize:26] andHeight:10];
    CGRect tmpFrame = leftCoinLable.frame;
    tmpFrame.size.width = leftCoinLableW;
    leftCoinLable.frame = tmpFrame;
    leftCoinLable.text = left_coin_str;
    
//    NSString *left_coin2_str = @"";//[NSString stringWithFormat:@"(%.2f%@)", left_coin, [common name_coin]];
//    CGFloat leftCoin2LableW = [[YBToolClass sharedInstance] widthOfString:left_coin2_str andFont:[UIFont boldSystemFontOfSize:14] andHeight:10];
//    tmpFrame = leftCoin2Lable.frame;
//    tmpFrame.size.width = leftCoin2LableW;
//    tmpFrame.origin.x = leftCoinLable.right + 3;
//    leftCoin2Lable.frame = tmpFrame;
//    leftCoin2Lable.text = left_coin2_str;
    
    refreshCoinBtn.frame = CGRectMake(leftCoinLable.right+5, leftCoinLable.y - 2, 30, 30);
}
-(void)refreshCoinBtnClick{
    [MBProgressHUD showMessage:YZMsg(@"exchangeVC_RefreshAccountBalance")];
    [self requestData];
}

-(void)changeAutoExchange:(UISwitch *)swi{
    // TODO
    [common saveAutoExchange:(BOOL)swi.isOn];
    if(swi.isOn){
//        [MBProgressHUD showMessage:YZMsg(@"打开自动转换")];
    }else{
//        [MBProgressHUD showMessage:YZMsg(@"关闭自动转换")];
    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUD];
//    });
}

-(void)refreshCard:(NSDictionary *)cardInfo order:(NSInteger)order{
    
    CGSize cardSize = CGSizeMake(SCREEN_WIDTH-20, 90);
    float startY = 10 + (10 + cardSize.height) * (order - 1);
    NSString *index_str = [NSString stringWithFormat:@"%ld",order];
    btnTag[index_str] = @{@"plat":cardInfo[@"plat"], @"name":[cardInfo objectForKey:@"name"], @"order":index_str};
    if(![cardDict objectForKey:index_str]){
        //背景图
        UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, startY, cardSize.width, cardSize.height)];
        backImgView.image = [ImageBundle imagewithBundleName:@"exchange_game_bg"];//bg_conversion_head
        backImgView.alpha = 0.8f;
        [screenView addSubview:backImgView];
        screenView.contentSize = CGSizeMake(SCREEN_WIDTH, startY+cardSize.height+20);
        //Logo
        UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 32, 25)];
        NSString *logoImagePath = [cardInfo objectForKey:@"logo"];
        if(logoImagePath && logoImagePath.length > 0){
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager loadImageWithURL:[NSURL URLWithString:minstr(logoImagePath)]
                              options:1
                             progress:nil
                            completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    [logo setImage:image];
                }
            }];
        }else{
            [logo setImage:[ImageBundle imagewithBundleName:@"rank_nothing"]];
        }
        logo.contentMode = UIViewContentModeScaleAspectFit;
        [backImgView addSubview:logo];
        //
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(logo.right + 3, logo.y + 9, backImgView.width, 16)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        label.text = [NSString stringWithFormat:@"%@",YZMsg([cardInfo objectForKey:@"name"])];
        [backImgView addSubview:label];
        //子账户余额
        float coin_realy_value = 0;
        if([cardInfo objectForKey:@"coin"]){
            if(![[cardInfo objectForKey:@"coin"] isKindOfClass:[NSNull class]]){
                coin_realy_value = [[cardInfo objectForKey:@"coin"] floatValue]*100;
            }
            
        }
     
//        CGFloat  coin = coin_realy_value * 100;
        NSString *left_coin_str = [NSString stringWithFormat:@"%.2d",(int)coin_realy_value/100];
        left_coin_str = [YBToolClass getRateCurrency:left_coin_str showUnit:YES];
        CGFloat label2W = [[YBToolClass sharedInstance] widthOfString:left_coin_str andFont:[UIFont systemFontOfSize:26] andHeight:backImgView.height/4];
        UILabel *leftSubCoinLable = [[UILabel alloc]initWithFrame:CGRectMake(logo.left+2, logo.bottom+10, label2W, 24)];
        leftSubCoinLable.textColor = [UIColor blackColor];
        leftSubCoinLable.textAlignment = NSTextAlignmentLeft;
        leftSubCoinLable.font = [UIFont boldSystemFontOfSize:24];
        leftSubCoinLable.text = left_coin_str;
        [backImgView addSubview:leftSubCoinLable];
        
        // 刷新余额按钮
        UIButton *refreshCoinBtn = [UIButton buttonWithType:0];
        refreshCoinBtn.frame = CGRectMake(leftSubCoinLable.right+5, leftSubCoinLable.y - 2, 30, 30);
        [refreshCoinBtn setImage:[ImageBundle imagewithBundleName:@"exchange_refresh_black.png"] forState:UIControlStateNormal];
        [refreshCoinBtn addTarget:self action:@selector(refreshSubCoinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        refreshCoinBtn.tag = order;
        refreshCoinBtn.userInteractionEnabled = YES;
        [backImgView addSubview:refreshCoinBtn];
        
        // 转入
        UIButton* inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        inputBtn.frame = CGRectMake(backImgView.width - 10 - 80 - 10 - 80, leftSubCoinLable.top - 5, 80, 30);
        [inputBtn setTitle:YZMsg(@"exchangeVC_SwitchIn") forState:UIControlStateNormal];
        [inputBtn addTarget:self action:@selector(inputSubMoney:) forControlEvents:UIControlEventTouchUpInside];
        inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [inputBtn.titleLabel setTextColor:RGB_COLOR(@"#FF3399", 1)];
        [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//        [inputBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1.0]] forState:UIControlStateDisabled];
        [inputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"exchange_momey_in"] forState:UIControlStateNormal];
//        [inputBtn setBackgroundColor:[UIColor whiteColor]];
        inputBtn.userInteractionEnabled = YES;
        inputBtn.layer.cornerRadius = 15;                           //圆角弧度
        inputBtn.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
        inputBtn.layer.shadowOpacity = 0.25;                         //阴影的不透明度
        inputBtn.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
        inputBtn.tag = order;
        [backImgView addSubview:inputBtn];
        
        // 转出
        UIButton* outputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        outputBtn.frame = CGRectMake(backImgView.width - 10 - 80, leftSubCoinLable.top - 5, 80, 30);
        [outputBtn setTitle:YZMsg(@"exchangeVC_SwitchOut") forState:UIControlStateNormal];
        [outputBtn addTarget:self action:@selector(outputSubMoney:) forControlEvents:UIControlEventTouchUpInside];
        outputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [outputBtn.titleLabel setTextColor:RGB_COLOR(@"#FF3399", 1)];
        [outputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [outputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//        [outputBtn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1.0]] forState:UIControlStateDisabled];
        [outputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"exchange_momey_out"] forState:UIControlStateNormal];
//        [outputBtn setBackgroundColor:[UIColor whiteColor]];
        outputBtn.userInteractionEnabled = YES;
        outputBtn.layer.cornerRadius = 15;                           //圆角弧度
        outputBtn.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
        outputBtn.layer.shadowOpacity = 0.25;                         //阴影的不透明度
        outputBtn.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
        outputBtn.tag = order;
        outputBtn.enabled = YES;
        [backImgView addSubview:outputBtn];
        
        backImgView.userInteractionEnabled = YES;
        
        cardDict[index_str] = @{
            @"backImgView":backImgView,
            @"leftSubCoinLable":leftSubCoinLable,
            @"inputBtn":inputBtn,
            @"outputBtn":outputBtn,
            @"refreshCoinBtn":refreshCoinBtn,
        };
    }
    
    UIImageView *backImgView = cardDict[index_str][@"backImgView"];
    UIButton *outputBtn = cardDict[index_str][@"outputBtn"];
    UIButton *inputBtn = cardDict[index_str][@"inputBtn"];
    UILabel *leftSubCoinLable = cardDict[index_str][@"leftSubCoinLable"];
    UIButton *refreshCoinBtn = cardDict[index_str][@"refreshCoinBtn"];
    
    leftSubCoinLable.text = @"0.0";
    [self startRotatingButton:refreshCoinBtn];
    
    
    NetworkForUpdateBalance *balanceRefrsh = [NetworkForUpdateBalance new];
    balanceRefrsh.game_plat = cardInfo[@"game_plat"];
    balanceRefrsh.idx = order;
    balanceRefrsh.dicPlat = cardInfo;
    WeakSelf
    [balanceRefrsh updateBalance:^(NSString *balance, NSString *game_plat,NSInteger dix,NSDictionary *platDics) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSMutableDictionary *subDic = [NSMutableDictionary dictionaryWithDictionary:platDics];
        [subDic setObject:balance forKey:@"coin"];
        [strongSelf->platArray replaceObjectAtIndex:dix-1 withObject:subDic];
        
        NSString *index_strs = [NSString stringWithFormat:@"%ld",dix];
        NSDictionary *subDV = [strongSelf->cardDict objectForKey:index_strs];
        if (subDV) {
            UIButton *refreshCoinBtn1 = [subDV objectForKey:@"refreshCoinBtn"];
            UIButton *outputBtn1 = [subDV objectForKey:@"outputBtn"];
            UIButton *inputBtn1 = [subDV objectForKey:@"inputBtn"];
            UILabel *leftSubCoinLable1 = [subDV objectForKey:@"leftSubCoinLable"];
        
            [strongSelf stopRotatingButton:refreshCoinBtn1];
            // 更新账号余额
            if(strongSelf-> left_coin > 0){
                inputBtn1.enabled = YES;
            }else{
                inputBtn1.enabled = NO;
                inputBtn1.adjustsImageWhenDisabled = NO;
            }
            // 更新子游戏余额
            float sub_left_coin = [balance floatValue];
            if(![[subDic objectForKey:@"coin"] isKindOfClass:[NSNull class]]){
                sub_left_coin = [[subDic objectForKey:@"coin"] floatValue]*100;
            }
            if(sub_left_coin > 0){
                outputBtn1.enabled = YES;
            }else{
                outputBtn1.enabled = NO;
                inputBtn1.adjustsImageWhenDisabled = NO;
            }
            float coin_realy_value = [((![PublicObj checkNull:[subDic objectForKey:@"coin"]])?([subDic objectForKey:@"coin"]):0) floatValue];
            CGFloat  coin1 = coin_realy_value * 100;
            NSString *left_coin_str = [NSString stringWithFormat:@"%.2f",(int)coin1/ 100.0];
            left_coin_str = [YBToolClass getRateCurrency:left_coin_str showUnit:YES];
            
            CGFloat label2W = [[YBToolClass sharedInstance] widthOfString:left_coin_str andFont:[UIFont systemFontOfSize:26] andHeight:backImgView.height/4];
            leftSubCoinLable1.width = label2W;
            leftSubCoinLable1.text = left_coin_str;
            refreshCoinBtn1.frame = CGRectMake(leftSubCoinLable1.right+5, leftSubCoinLable1.y - 2, 30, 30);
        }
        
        
    }];
    [self.requestBalance addObject:balanceRefrsh];
}

- (void)startRotatingButton:(UIButton*)refreshCoinBtn {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [refreshCoinBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopRotatingButton:(UIButton*)refreshCoinBtn {
    [refreshCoinBtn.layer removeAnimationForKey:@"rotationAnimation"];
}



- (UIImage *)createImageWithColor:(UIColor *)color {
    //设置长宽
    CGRect rect = CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *original = resultImage;
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    // 开始一个Image的上下文
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:15.0f] addClip];
    // 绘制图片
    [original drawInRect:frame];
    // 接受绘制成功的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//提交充入账户申请
- (void)chargeIntoCoinBtnClick{
    myRechargeCoinVC *VC = [[myRechargeCoinVC alloc]init];
    VC.titleStr = YZMsg(@"myPopularizeVC_Charge_title");
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
}

//提交提现申请（新）
- (void)withDrawingBtnClick{
    myWithdrawVC *VC = [[myWithdrawVC alloc]init];
    VC.titleStr = YZMsg(@"public_WithDraw");
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
}

//复制推广链接
- (void)inputBtnClick{
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = invite_url;
    [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
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

