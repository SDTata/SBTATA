//
//  myPopularizeVC
//  yunbaolive
//
//  Created by Boom on 2018/9/26.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "myPopularizeVC.h"
#import "myWithdrawVC.h"
#import "myRechargeCoinVC.h"
#import "webH5.h"
#import "UIButton+Additions.h"

@interface myPopularizeVC (){
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
    NSString *invite_rule;// 推广规则
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
    
    
    UIView *navtion;
    UIScrollView *scrollView;
}

@end

@implementation myPopularizeVC

typedef NS_ENUM(NSInteger, DirectionStyle){
    DirectionStyleToUnder = 0,  //向下
    DirectionStyleToUn = 1      //向上
};

-(void)navtion{
    
    UIImageView * bj = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bj.image = [ImageBundle imagewithBundleName:@"withdraw_bg"];
    [self.view addSubview: bj];
    [self.view sendSubviewToBack:bj];
    
    navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
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
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    returnBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
//    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
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

//    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
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
   
    [self navtion];
  
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            strongSelf->nowVotesL.text = [NSString stringWithFormat:@"%@",[info valueForKey:@"left_coin"]];
            //self.withdraw.text = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"todaycash"]];
            strongSelf->allVotesL.text = [NSString stringWithFormat:@"%@",[info valueForKey:@"invite_coin"]];//收益 魅力值
            
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
            strongSelf->invite_rule = minstr([info valueForKey:@"invite_rule"]);// 推广规则
            strongSelf->charge_coin = [minstr([info valueForKey:@"charge_coin"]) intValue];
            

            NSLog(@"推广/收益数据：%@",info);
            [strongSelf.view removeAllSubviews];
            [strongSelf navtion];
            [strongSelf creatUI];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
- (void)tapClick{
    [votesT resignFirstResponder];
}
- (void)creatUI{
    
    scrollView = [[UIScrollView alloc]  initWithFrame:CGRectMake(20, 20 + 44 +statusbarHeight, _window_width -40, _window_height - 20 - 44 - statusbarHeight)];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.layer.cornerRadius = 20.0;
    scrollView.layer.masksToBounds = YES;
    [self.view addSubview:scrollView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
    [self.view bringSubviewToFront:navtion];
    
//    //背景图
//    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height - 20 - 44 - statusbarHeight)];
//    bgImgView.image = [ImageBundle imagewithBundleName:@"tgzq_di3"];
//    bgImgView.contentMode = UIViewContentModeScaleToFill;
//    [scrollView addSubview:bgImgView];
    
    //背景图
    UIImageView *backImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, _window_width- 40,  150)];
    [scrollView addSubview:backImgView];
    
//    int xOffset = -0;
//    int yOffset = -0;
    UILabel *label2 =[[UILabel alloc]initWithFrame:CGRectMake(backImgView.left, 30 ,_window_width- 40, 25)];
    label2.textColor = [UIColor blackColor];
    label2.font = [UIFont boldSystemFontOfSize:22];
    label2.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%d",left_coin] showUnit:YES];
    label2.textAlignment = NSTextAlignmentCenter;
    [backImgView addSubview:label2];
    
    //推广收益钻石
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(backImgView.left,label2.bottom + 10, _window_width- 40,20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = RGB_COLOR(@"#767676", 1);
    label.font = [UIFont systemFontOfSize:15];
    label.text = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:YZMsg(@"myRechargeCoinVC_Promotion%@_tile"),[common name_votes]]];
    [backImgView addSubview:label];

    //钻石图标
//    UIImageView *labelImg = [[UIImageView alloc]initWithFrame:CGRectMake(label2.x - 30, label2.y, 30, 30)];
//    labelImg.image = [ImageBundle imagewithBundleName:@"logFirst_钻石.png"];
//    [backImgView addSubview:labelImg];
        
    chargeIntoCoinBtn = [UIButton buttonWithType:0];
    chargeIntoCoinBtn.frame = CGRectMake(backImgView.left+20, backImgView.bottom - 35, 80, 30);
    // [chargeIntoCoinBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    [chargeIntoCoinBtn setBackgroundColor:[UIColor whiteColor]];
    [chargeIntoCoinBtn setTitle:YZMsg(@"myPopularizeVC_Charge_title") forState:0];
  
    [chargeIntoCoinBtn addTarget:self action:@selector(chargeIntoCoinBtnClick) forControlEvents:UIControlEventTouchUpInside];
    chargeIntoCoinBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [chargeIntoCoinBtn setTitleColor:[UIColor colorWithRed:161/255.0 green:108/255.0 blue:201/255.0 alpha:1]   forState:UIControlStateNormal];
    chargeIntoCoinBtn.titleLabel.layer.shadowRadius = 1;
    chargeIntoCoinBtn.titleLabel.layer.shadowColor = [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1].CGColor;
    chargeIntoCoinBtn.titleLabel.layer.shadowOffset = CGSizeMake(0.4f, 0.4f);
    chargeIntoCoinBtn.titleLabel.layer.shadowOpacity = 0.3f;
    [chargeIntoCoinBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    chargeIntoCoinBtn.layer.cornerRadius = 7;
    chargeIntoCoinBtn.layer.masksToBounds = YES;
    chargeIntoCoinBtn.userInteractionEnabled = YES;
    [scrollView addSubview:chargeIntoCoinBtn];
    chargeIntoCoinBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    chargeIntoCoinBtn.titleLabel.minimumScaleFactor = 0.2;
//    [chargeIntoCoinBtn sizeToFit];
    chargeIntoCoinBtn.frame = CGRectMake(backImgView.left+30, backImgView.bottom - 35, SCREEN_WIDTH/2 -60, 30);
    [chargeIntoCoinBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"zf_dk2_xz"] forState:UIControlStateNormal];
    
    withDrawingBtn = [UIButton buttonWithType:0];
    withDrawingBtn.frame = CGRectMake(backImgView.right - 100, backImgView.bottom - 35, 80, 30);
    [withDrawingBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"zf_dk2_xz"] forState:UIControlStateNormal];
    // [withDrawingBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    [withDrawingBtn setBackgroundColor:[UIColor whiteColor]];
    [withDrawingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [withDrawingBtn setTitle:YZMsg(@"myProfitVC_withDraw_now") forState:0];
    [withDrawingBtn addTarget:self action:@selector(withDrawingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    withDrawingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [withDrawingBtn setTitleColor:[UIColor colorWithRed:161/255.0 green:108/255.0 blue:201/255.0 alpha:1]  forState:UIControlStateNormal];
    withDrawingBtn.titleLabel.layer.shadowRadius = 1;
    withDrawingBtn.titleLabel.layer.shadowColor = [UIColor colorWithRed:126/255.0 green:126/255.0 blue:126/255.0 alpha:1].CGColor;
    withDrawingBtn.titleLabel.layer.shadowOffset = CGSizeMake(0.4, 0.4);
    withDrawingBtn.titleLabel.layer.shadowOpacity = 0.3f;
    withDrawingBtn.layer.cornerRadius = 7;
    withDrawingBtn.layer.masksToBounds = YES;
    withDrawingBtn.userInteractionEnabled = YES;
    withDrawingBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    withDrawingBtn.titleLabel.minimumScaleFactor = 0.2;
//    [withDrawingBtn sizeToFit];
    withDrawingBtn.frame = CGRectMake(backImgView.right -  (SCREEN_WIDTH/2 -60)-30, backImgView.bottom - 35, SCREEN_WIDTH/2 -60, 30);
    [scrollView addSubview:withDrawingBtn];
    
//    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(backImgView.left, backImgView.bottom, backImgView.width, 20)];
//    [labTitle setFont:[UIFont systemFontOfSize:13.f]];
//    [labTitle setTextColor:RGB_COLOR(@"#476ae5", 1)];
//    [labTitle setTextAlignment:NSTextAlignmentCenter];
//    [labTitle setText:YZMsg(@"myPopularizeVC_DetailPopularize")];
//    [scrollView addSubview:labTitle];
//
    NSArray *arr = @[
         [NSString stringWithFormat:YZMsg(@"myPopularizeVC_invite%d"),invite_count],
         //                     [NSString stringWithFormat:@"%@%@%@",YZMsg(@"输入要提取的"),@"钻石",YZMsg(@"数")],
         [NSString stringWithFormat:YZMsg(@"myPopularizeVC_Charge%d_%@"), [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%d", charge_coin] showUnit:YES], @""],
         YZMsg(@"myPopularizeVC_WithDrawSuccess"),
         YZMsg(@"myPopularizeVC_WithDraw_Applying"),
         YZMsg(@"myPopularizeVC_Charge_title"),
     ];
    //推广相关信息视图
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(backImgView.left, backImgView.bottom+25, backImgView.width, backImgView.height*0.8*arr.count/2)];
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;
    [scrollView addSubview:textView];
    
    
    // int twidth = textView.width;
    // int theight = textView.height;
    for (int i = 0; i<arr.count; i++) {
        int cellH = textView.height/arr.count;
        int cellY = textView.height/arr.count*i;
        int imgSizeWH = cellH*0.6;
        // img
        UIImageView *labelImg = [[UIImageView alloc]initWithFrame:CGRectMake(textView.width*0.05, cellY + (cellH - imgSizeWH) / 2, imgSizeWH, imgSizeWH)];
        labelImg.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"share_%d.png",(i+1)]];
        [textView addSubview:labelImg];
        
        UIView *line= [[UIView alloc]initWithFrame:CGRectMake(20, cellY + imgSizeWH + 20, textView.width - 40, 1)];
        line.backgroundColor = RGB(228, 228, 228);
        [textView addSubview:line];
        // title label
        CGFloat labelW = [[YBToolClass sharedInstance] widthOfString:arr[i] andFont:[UIFont systemFontOfSize:15] andHeight:cellH];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.08 + imgSizeWH, cellY, labelW+20, cellH)];
        label.textColor = RGB_COLOR(@"#767676", 1);
        label.font = [UIFont systemFontOfSize:12];
        label.text = arr[i];
        [textView addSubview:label];
        // content label
        int showNum = 0;
        NSString* numOperation = @"";
        NSString* numColor = @"";
        switch (i) {
            case 0:
                showNum = invite_coin;
                numOperation = @"+";
                numColor = @"#6bc236";
                break;
            case 1:
                showNum = charge_coin;
                numOperation = @"+";
                numColor = @"#6bc236";
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
                numOperation = @"";
                numColor = @"#fb3157";
                break;
            default:
                break;
        }
        
        inviteCoinLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, label.y, textView.width*0.95, cellH)];
        inviteCoinLabel.textColor = RGB_COLOR(numColor, 1);
        inviteCoinLabel.font = [UIFont boldSystemFontOfSize:14];
        inviteCoinLabel.text = [NSString stringWithFormat:@"%@%@", numOperation, [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%d", showNum] showUnit:YES]];
        [inviteCoinLabel setTextAlignment:NSTextAlignmentRight];
        [textView addSubview:inviteCoinLabel];
    }
    
    // 复制链接
    inputBtn = [UIButton buttonWithType:0];
    inputBtn.frame = CGRectMake(20, textView.bottom + 20, _window_width - 80, 50);
    [inputBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"tgzq_anniu"] forState:UIControlStateNormal];
//    inputBtn.backgroundColor = [UIColor colorWithPatternImage:[ImageBundle imagewithBundleName:@"tgzq_anniu"]];
    [inputBtn setTitle:YZMsg(@"myPopularizeVC_copy_link") forState:0];
    [inputBtn addTarget:self action:@selector(inputBtnClick) forControlEvents:UIControlEventTouchUpInside];
    inputBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [inputBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    inputBtn.layer.cornerRadius = 20;
//    inputBtn.layer.masksToBounds = YES;
    [inputBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
    inputBtn.userInteractionEnabled = YES;
    [scrollView addSubview:inputBtn];
    
    // Tips
    tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(textView.width*0.05, inputBtn.bottom + 15, textView.width*0.9, 100)];
    tipsLabel.font = [UIFont systemFontOfSize:12];
    tipsLabel.textColor = RGB_COLOR(@"#666666", 1);
    tipsLabel.numberOfLines = 0;
    
    NSString * tips = [NSString stringWithFormat:@"%@", invite_rule];
    CGFloat height = [[YBToolClass sharedInstance] heightOfString:tips andFont:[UIFont systemFontOfSize:12] andWidth:textView.width*0.9];
    tipsLabel.text = tips;
    tipsLabel.height = height;
    
    [scrollView addSubview:tipsLabel];
    
    scrollView.contentSize = CGSizeMake(_window_width -40, tipsLabel.bottom + 20);
//    CGRect frame = scrollView.frame;
//    frame.size = CGSizeMake(_window_width, _window_height);
//    frame.origin.y = 10 + 44 +statusbarHeight;
//    scrollView.frame = frame;
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

/**
 *  渐变色
 *  @param red              红色
 *  @param green            绿色
 *  @param blue             蓝色
 *  @param startAlpha       开始的透明度
 *  @param endAlpha         结束的透明度
 *  @param direction        那个方向
 *  @param frame            大小
 */
- (UIImage *)LW_gradientColorWithRed:(CGFloat)red
                               green:(CGFloat)green
                                blue:(CGFloat)blue
                              endRed:(CGFloat)endRed
                            endGreen:(CGFloat)endGreen
                             endBlue:(CGFloat)endBlue
                          startAlpha:(CGFloat)startAlpha
                            endAlpha:(CGFloat)endAlpha
                           direction:(DirectionStyle)direction
                               frame:(CGRect)frame
{
    //底部上下渐变效果背景
    // The following methods will only return a 8-bit per channel context in the DeviceRGB color space. 通过图片上下文设置颜色空间间
    UIGraphicsBeginImageContext(frame.size);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:10] addClip];
    //获得当前的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建颜色空间 /* Create a DeviceRGB color space. */
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    //通过矩阵调整空间变换
    CGContextScaleCTM(context, frame.size.width, frame.size.height);
    
    //通过颜色组件获得渐变上下文
    CGGradientRef backGradient;
    //253.0/255.0, 163.0/255.0, 87.0/255.0, 1.0,
    if (direction == DirectionStyleToUnder) {
        //向下
        //设置颜色 矩阵
        CGFloat colors[] = {
            red, green, blue, startAlpha,
            endRed, endGreen, endBlue, endAlpha,
        };
        backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    } else {
        //向上
        CGFloat colors[] = {
            endRed, endGreen, endBlue, endAlpha,
            red, green, blue, startAlpha,
        };
        backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    }
    
    //释放颜色渐变
    CGColorSpaceRelease(rgb);
    //通过上下文绘画线色渐变
    CGContextDrawLinearGradient(context, backGradient, CGPointMake(0.5, 0), CGPointMake(0.5, 1), kCGGradientDrawsBeforeStartLocation);
    //通过图片上下文获得照片
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
