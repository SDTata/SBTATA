//
//  PayReqViewController.m
//
//

#import "PayReqViewController.h"
#import "RechargePopView.h"
#import "BindPhoneNumberViewController.h"
#import "UIView+GYPop.h"
#import "PayPwdAlertView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kPayTransferCollectionViewCell @"PayTransferCollectionViewCell"
#define kImageDefaultName @"tempShop2"

@interface PayReqViewController ()<UITextFieldDelegate>{
    NSMutableDictionary *allData;
    BOOL bUICreated; // UI是否创建
    NSIndexPath *curselectIndex;
    
    NSInteger write_Amount;
    NSString *write_Name;
    NSMutableDictionary *requireKeys;
    NSString *lastNameString;
    BOOL isVipPay;
    
    BOOL canClickButton;
    
    NSString *damaStr;
    NSInteger currentViewType;
    NSString *selectAmount;
    NSString *cardId;
    NSString *balanceQuota;
}
@property (nonatomic, strong) RechargePopView *rechargePopView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;

@end

@implementation PayReqViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
}
- (void)refreshSelectPayChannel:(NSNotification *)notification {
    NSArray *arr = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = arr.count;
    
    isVipPay = NO;
    
    currentViewType = 0;
    
    for (int i=0; i<maxCount; i++) {
        if([minstr(arr[i][@"type"]) isEqualToString:@"channelClass"]){
            currentViewType = [arr[i][@"viewType"]  intValue];
        }
    }
    
    for (int i=0; i<maxCount; i++) {
        if([arr[i][@"type"] isEqualToString:@"channelClass"]){
            if(currentViewType == 5){
                isVipPay = YES;
                self.psdView.hidden = NO;
            }else{
                self.psdView.hidden = YES;
            }
        }
        
        if([minstr(arr[i][@"type"]) isEqualToString:@"reqClass"]){
            NSDictionary *contentDict = arr[i][@"content"];
            allData = [NSMutableDictionary dictionaryWithDictionary:contentDict];
            break;
        }
        
        if([minstr(arr[i][@"type"]) isEqualToString:@"needFlow"] && currentViewType == 6){
            NSDictionary *contentDict = arr[i][@"content"];
            if(contentDict && contentDict[@"flow"]){
                damaStr = [NSString stringWithFormat:@"%@",contentDict[@"flow"]];
               
            }
        }
    }
    
    
    if(allData && allData[@"tip"]){
        NSString *tip = allData[@"tip"];
        CGFloat tipHeight = 0;
        if(tip && ![tip isKindOfClass:[NSNull class]] && tip.length > 0){
            self.tipLabel.text = tip;
            self.tipLabel.hidden = NO;
            tipHeight = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.contentView.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(12)} context:nil].size.height;
        }else{
            self.tipLabel.text = YZMsg(@"PayReq_warning");
            self.tipLabel.hidden = NO;
            tipHeight = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.contentView.width - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(12)} context:nil].size.height;
        }
        if(isVipPay){
            self.viewHeight.constant = 88 + tipHeight;
            self.topHeight.constant = 35;
        }else{
            self.viewHeight.constant = 68 + tipHeight;
            self.topHeight.constant = 15;
        }
        self.view.height = self.viewHeight.constant;
    }
}

-(NSDictionary *)getRequestParams{
    if(isVipPay){
        NSLog(@"密码:%@",self.psdTextField.text);
        NSString * psdStr = minstr(self.psdTextField.text);
        return @{@"password":psdStr};
    }else{
        return @{};
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.psdTextField = [UITextField new];
    self.psdTextField.hidden = YES;
    [self.view addSubview:self.psdTextField];
    
    [self.reqBtn setTitle:YZMsg(@"PayReq_chargeNow") forState:UIControlStateNormal];
    self.reqBtn.backgroundColor = RGB(181, 65, 245);
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.gamesCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayChannel:) name:@"Pay_RefreshPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Pay_TextFieldChange:) name:@"Pay_TextFieldChange" object:nil];
    
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(refreshUI) withObject:nil afterDelay:0.4];
    
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:YZMsg(@"public_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelWithKeyBoard)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:YZMsg(@"publictool_sure") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithKeyBoard)]];
    [keyboardToolbar sizeToFit];
    self.psdTextField.inputAccessoryView = keyboardToolbar;
    
    self.psdTextField.delegate = self;
    
    [self.psdTextField addTarget:self action:@selector(textFeildChange) forControlEvents:UIControlEventEditingChanged];
    canClickButton = true;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)exitView{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentView.bottom = _window_height + strongSelf.contentView.frame.origin.y;
    } completion:^(BOOL finished) {
       STRONGSELF
       if (strongSelf == nil) {
           return;
       }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_RefreshPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_TextFieldChange" object:nil];
    
    
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    
    BOOL canReq = [self judgeCanReq];
    if(canReq){
        NSLog(@"可请求");
        [self.reqBtn setEnabled:true];
        canClickButton = true;
        self.reqBtn.backgroundColor = [UIColor colorWithRed:181/255.0 green:65/255.0 blue:245/255.0 alpha:1];
        self.reqBtn.titleLabel.textColor = [UIColor whiteColor];
        [self.reqBtn addTarget:self action:@selector(doReq:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        NSLog(@"不可请求");
        canClickButton = false;
//        [self.reqBtn setEnabled:false];
        self.reqBtn.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1];
        self.reqBtn.titleLabel.textColor = [UIColor colorWithRed:175/255.0 green:175/255.0 blue:175/255.0 alpha:1];
    }
}

-(void)initUI{
    bUICreated = true;
    curselectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.reqBtn addTarget:self action:@selector(doReq:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setReqKey:(NSArray *)arr{
    if(!requireKeys){
        requireKeys = [NSMutableDictionary dictionary];
    }
    if(arr){
        NSInteger maxCount = arr.count;
        for (int i =0; i < maxCount; i ++) {
            [requireKeys setObject:@0 forKey:arr[i]];
        }
    }
}

- (BOOL)judgeCanReq {
    for (NSString *key in requireKeys) {
        NSInteger bOK = [[requireKeys valueForKey:key] integerValue];
        if(!bOK){
            return false;
        }
    }

    if (currentViewType == 6 &&
        [selectAmount floatValue] > [balanceQuota floatValue]) {
        return false;
    }
    
    return true;
}

- (void)Pay_TextFieldChange:(NSNotification *)notification {
    [self getDefaultAccount];

    CGFloat amount = [(notification.userInfo[@"amount"]) floatValue];
    selectAmount = @"";
    NSString *amountStr = notification.userInfo[@"amount"];
    if(amountStr && ![amountStr isKindOfClass:[NSNull class]]){
        selectAmount = amountStr;
        NSLog(@"%@", [NSString stringWithFormat:@"当前选中金额:%.2f",amount]);
        if(amount && amount > 0){
            [requireKeys setObject:@1 forKey:@"amount"];
        }else{
            [requireKeys setObject:@0 forKey:@"amount"];
        }
    }
    
    NSString *nameStr = notification.userInfo[@"name"];
    if(nameStr && ![nameStr isKindOfClass:[NSNull class]]){
        NSLog(@"%@", [NSString stringWithFormat:@"当前汇款姓名:%@",nameStr]);
        if(nameStr && nameStr.length > 0){
            [requireKeys setObject:@1 forKey:@"name"];
        }else{
            [requireKeys setObject:@0 forKey:@"name"];
        }
    }
    if(isVipPay){
        NSString *psdStr = notification.userInfo[@"password"];
        if(psdStr && ![psdStr isKindOfClass:[NSNull class]]){
            if(psdStr && psdStr.length >= 6){
                [requireKeys setObject:@1 forKey:@"password"];
            }else{
                [requireKeys setObject:@0 forKey:@"password"];
            }
        }else{
            if(self.psdTextField.text && self.psdTextField.text.length >= 6){
                [requireKeys setObject:@1 forKey:@"password"];
            }else{
                [requireKeys setObject:@0 forKey:@"password"];
            }
        }
    }
    if (damaStr && damaStr.length>0 && [damaStr doubleValue]>0.001) {
        [requireKeys setObject:@0 forKey:@"password"];
    }else{
        [requireKeys setObject:@1 forKey:@"password"];
    }
    
    
    
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(refreshUI) withObject:nil afterDelay:0.4];

}

- (void)doReq:(UIButton *)sender {
    //[MBProgressHUD showError:@"TODO 拉起支付"];
    if(!canClickButton){
        return;
    }
    
    if (!isVipPay) {
        [self startPay];
        return;
    }
    
    PayPwdAlertView *view = [PayPwdAlertView new];
    [view showFromCenter];
    
    WeakSelf
    view.clickConfirmBlock = ^(NSString *text) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.psdTextField.text = text;
        [strongSelf textFeildChange];
        [strongSelf startPay];
    };
}

- (void)startPay {
    // 免提直充
    if (currentViewType == 6) {
        NSDecimalNumber *v = [NSDecimalNumber decimalNumberWithString:selectAmount];
        NSDecimalNumber *num =  [v decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];

        NSString *commitOrderUrl = [NSString stringWithFormat:@"User.gameWithdraw"];
        NSDictionary *params = @{@"coin":num.stringValue, @"cardId":cardId, @"uid":[Config getOwnID], @"token":[Config getOwnToken]};
        [MBProgressHUD showMessage:@""];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:commitOrderUrl withBaseDomian:YES andParameter:params data:nil success:^(int code,id info,NSString *msg) {
            STRONGSELF
            [MBProgressHUD hideHUD];
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                if(msg.length > 0){
                    [GameToolClass showTip:YZMsg(@"public_warningAlert") tipString:msg];
                }else{
                    [GameToolClass showTip:YZMsg(@"h5game_submit_successfully") tipString:YZMsg(@"myWithdrawVC2_WithDrawWaitTip")];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_getInfo" object:nil];
                }
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:YZMsg(@"PayVC_OrderError")];

        }];
        return;
    }

    NSDictionary *withdrawInfo = [Config getWithdrawInfo];
    if (![withdrawInfo isKindOfClass:[NSDictionary class]] || withdrawInfo == nil) {
        withdrawInfo = @{};
    }
    BOOL isWithdrawable = [withdrawInfo[@"isWithdrawable"] boolValue];
    if (!isWithdrawable) {
        [self.view gy_creatPopViewWithContentView:self.rechargePopView withContentViewSize:CGSizeMake(_window_width * 0.8,186)];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_NeedRequest" object:nil];
    }
}

-(void)cancelWithKeyBoard{
    [self.psdTextField resignFirstResponder];
}

-(void)doneWithKeyBoard{
    [self.psdTextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

}

-(void)textFeildChange {
    if( ![self.psdTextField.text isEqualToString:minstr(lastNameString)] ){
        lastNameString = self.psdTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_TextFieldChange" object:nil userInfo:@{@"password" : minstr(self.psdTextField.text)}];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    if (@available(iOS 15.0, *)) {
        UITouch *touch = [touches.allObjects lastObject];
        CGPoint point = [touch locationInView:self.reqBtn];
        BOOL result = CGRectContainsPoint(self.reqBtn.bounds, point);
        if (result) {
            [self doReq:self.reqBtn];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
    //设置长宽
//    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
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
                                cornerRadius:radius] addClip];
    // 绘制图片
    [original drawInRect:frame];
    // 接受绘制成功的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(RechargePopView *)rechargePopView{
    if (!_rechargePopView) {
        _rechargePopView = [[RechargePopView alloc] init];
        NSDictionary *withdrawInfo = [Config getWithdrawInfo];
        if (![withdrawInfo isKindOfClass:[NSDictionary class]] || withdrawInfo == nil) {
            withdrawInfo = @{};
        }
        NSString *msg = withdrawInfo[@"msg"];
        NSString *jump = withdrawInfo[@"jump"];
        _rechargePopView.billingLab.text = msg;
        WeakSelf
        self.rechargePopView.submitBtnClickBlock  = ^(UIButton * _Nonnull sender) {
            [weakSelf.view gy_popViewdismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_NeedRequest" object:nil];
        };
        self.rechargePopView.cancelBtnClickBlock =  ^(UIButton * _Nonnull sender) {
            [weakSelf.view gy_popViewdismiss];
            if ([jump isKindOfClass:[NSString class]] && jump.length > 0) {
                NSDictionary *data = @{@"scheme": jump};
                [[YBUserInfoManager sharedManager] pushVC:data viewController:nil];
            }
        };
    }
    return _rechargePopView;
}

-(void)getDefaultAccount{
    cardId = @"";
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetUserAccountList" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if ([info isKindOfClass:[NSArray class]]) {
                NSArray *arrayBanks = info;
                if (arrayBanks.count>0) {
                    for (NSDictionary *subBankDic in arrayBanks) {
                        NSInteger bankType = [subBankDic[@"type"] integerValue];
                        if (bankType == 12) {
                            strongSelf->cardId = minstr(subBankDic[@"id"]);
                            break;
                        }
                    }
                }
            }
        }

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

    }];
}

-(void)setBalanceQuota:(NSString*)quota {
    balanceQuota = quota;
    [self judgeCanReq];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
