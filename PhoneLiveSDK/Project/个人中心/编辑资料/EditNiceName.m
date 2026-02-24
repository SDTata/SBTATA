//
//  EditNiceName.m
//  yunbaolive
//
//  Created by cat on 16/3/13.
//  Copyright © 2016年 cat. All rights reserved.
//
#import "EditNiceName.h"
@interface EditNiceName ()<UITextFieldDelegate>
{
    UITextField *input;
    float NavHeight;
    int setvisaaaa;
    UIActivityIndicatorView *testActivityIndicator;//菊花

}
@end
@implementation EditNiceName
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    setvisaaaa = 1;
    self.navigationController.navigationBarHidden = YES;

    [self navtion];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    setvisaaaa = 0;
}
-(void)navtion{
    
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor = navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"EditNiceName_NameEdit");
    [label setFont:navtionTitleFont];
    
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    // label.center = navtion.center;
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    [self.view addSubview:navtion];
    
    
    UIButton *BtnSave = [[UIButton alloc] initWithFrame:CGRectMake(_window_width-60,24+statusbarHeight,60,40)];
    [BtnSave setTitle:YZMsg(@"public_Save") forState:UIControlStateNormal];
    [BtnSave setTitleColor:RGB_COLOR(@"#FE0B78", 1) forState:0];
    BtnSave.titleLabel.font = [UIFont systemFontOfSize:14];
    [BtnSave addTarget:self action:@selector(nicknameSave) forControlEvents:UIControlEventTouchUpInside];
    
    [navtion addSubview:BtnSave];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];

}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    float NavHeight = 64 + statusbarHeight;//包涵通知栏的20px
    self.view.backgroundColor = RGB(244, 245, 246);
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, NavHeight, _window_width, 50)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    input = [[UITextField alloc] init];
    input.delegate = self;
    NavHeight = 54 + statusbarHeight;//包涵通知栏的20px
    input.frame = CGRectMake(20,0 , [UIScreen mainScreen].bounds.size.width  - 40, 50);
    input.layer.cornerRadius = 3;
    input.layer.masksToBounds = YES;
    input.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18.0];
    input.textColor = RGB_COLOR(@"#333333", 1);
    
    // // 获取用户昵称并确保不超过20个字符
     NSString *nicename = [Config getOwnNicename];
    // if (nicename.length > 20) {
    //     nicename = [nicename substringToIndex:20];
    // }
    input.text = nicename;
    
    // 添加文本变化监听
    [input addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [input setBackgroundColor:[UIColor whiteColor]];
    input.clearButtonMode = UITextFieldViewModeAlways;
    [backView addSubview:input];
    /////////////
    NSString * cost = [Config getChangeNameCost];
    UILabel *lab1 = [[UILabel alloc] init];
    if(cost && cost.integerValue<= 0){
        lab1.text = YZMsg(@"EditNiceName_FreeTip");
        [lab1 setTextColor:[UIColor colorWithRed:32.0/255 green:185.0/255 blue:35.0/255 alpha:1]];
    }else{
        NSString *currencyCoin = [YBToolClass getRateCurrency:cost showUnit:YES];
        lab1.text = [NSString stringWithFormat:YZMsg(@"EditNiceName_coast%@_%@"), currencyCoin,[common name_votes]];
        [lab1 setTextColor:[UIColor colorWithRed:223.0/255 green:26.0/255 blue:33.0/255 alpha:1]];
    }
    lab1.font = fontThin(15);
    lab1.numberOfLines = 0;
    lab1.frame = CGRectMake(20, backView.bottom, 300, 20);
    [self.view addSubview:lab1];
    [lab1 sizeToFit];
    /////////////
//    UILabel *lab = [[UILabel alloc] init];
//    lab.text = YZMsg(@"EditNiceName_nameLimitlenth");
//    lab.font = fontThin(15);
//    lab.numberOfLines = 0;
//    [lab setTextColor:[UIColor colorWithRed:45.0/255 green:45.0/255 blue:45.0/255 alpha:1]];
//    lab.frame = CGRectMake(20, lab1.bottom, 200, 20);
//    [self.view addSubview:lab];
    /////////////
    ///
    if(cost && cost.integerValue<= 0){
        
    }else{
        UILabel *lab2 = [[UILabel alloc] init];
        lab2.text = [NSString stringWithFormat:YZMsg(@"EditNiceName_ChangeCoastTip_%@%@"),cost,[common name_votes]];
        lab2.font = fontThin(15);
        [lab2 setTextColor:[UIColor colorWithRed:45.0/255 green:45.0/255 blue:45.0/255 alpha:1]];
        lab2.frame = CGRectMake(20, lab1.bottom, 300, 20);
        lab2.numberOfLines = 0;
        [self.view addSubview:lab2];
        [lab2 sizeToFit];
    }
   
    [input becomeFirstResponder];
}
-(void)nicknameSave
{
    if (input.text.length > 20) {
        [MBProgressHUD showError:YZMsg(@"EditContactInfo_InputLimit")];
        return ;
    }
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    testActivityIndicator.center = self.view.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor blackColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[input.text] forKeys:@[@"user_nicename"]];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"User.updateFields&uid=%@&token=%@&fields=%@",[Config getOwnID],[Config getOwnToken],jsonStr];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            LiveUser *user = [Config myProfile];
            user.user_nicename =strongSelf->input.text;
            [Config updateProfile:user];
            [strongSelf.navigationController popViewControllerAnimated:YES];
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:KGetBaseInfoNotification object:nil];

        }else{
            if(msg){
                [MBProgressHUD showError:msg];
            }else{
                [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_NoBalance")];
            }
            
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

    }];
    
}

// 监听文本变化事件
- (void)textFieldDidChange:(UITextField *)textField {
    // 如果文本长度超过20个字符，截断并提示
    if (textField.text.length > 20) {
        textField.text = [textField.text substringToIndex:20];
        [MBProgressHUD showError:YZMsg(@"EditContactInfo_InputLimit")];
    }
}

@end
