//
//  BindPhoneNumberViewController.m
//  phonelive2
//
//  Created by lucas on 2021/4/19.
//  Copyright © 2021 toby. All rights reserved.
//

#import "BindPhoneNumberViewController.h"
#import "ChannelStatistics.h"
#import "XYDeviceInfoUUID.h"
#import "CaptchaManager.h"
#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif

@interface BindPhoneNumberViewController ()<UITextFieldDelegate, ShowDropDownTextFieldDelegate> {
    NSTimer *messsageTimer;
    int messageIssssss;//短信倒计时  60s
    NSArray *platformsarray;
    NSString * regChannel;//注册渠道
    NSInteger getRegChannelCount;
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *flagImgV;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *countryNameL;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeL;
@property (weak, nonatomic) IBOutlet UIView *countryBgView;
@property (weak, nonatomic) IBOutlet UILabel *bindPhoneTitleLable;

@property (weak, nonatomic) IBOutlet UILabel *bindphonesubtitle;
@property (weak, nonatomic) IBOutlet UILabel *areaLbale;

@property (weak, nonatomic) IBOutlet UILabel *phoneTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeTitleLabel;

@property(nonatomic,strong)NSString *countryCodeNum;
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isGetCodeResponse;


@end

@implementation BindPhoneNumberViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bindingType = BindingTypeForPhone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [XYDeviceInfoUUID getWANIPAddress:^(NSString * _Nullable) {
        
    }];

    switch (self.bindingType) {
        case BindingTypeForPhone:
            self.phoneIconImageView.image = [ImageBundle imagewithBundleName:@"icon_bdsj"];
            self.bindPhoneTitleLable.text = YZMsg(@"activity_bind_phone_number_bindphonetitle");
            self.bindphonesubtitle.text = YZMsg(@"activity_bind_phone_number_bindphonesubtitle");
            self.phoneTitleLabel.text = YZMsg(@"activity_bind_phone_number_phone");
            self.phoneT.isNeedShowDropDown = false;
            self.phoneT.placeholder = YZMsg(@"activity_login_inputPhoneNum");
            self.phoneT.keyboardType = UIKeyboardTypeNumberPad;
            _countryBgView.hidden = false;
            break;
        case BindingTypeForEmail:
            self.phoneIconImageView.image = [ImageBundle imagewithBundleName:@"icon_email"];
            self.bindPhoneTitleLable.text = YZMsg(@"activity_bind_phone_number_bindEmailTitle");
            self.bindphonesubtitle.text = YZMsg(@"activity_bind_phone_number_bindEmailSubtitle");
            self.phoneTitleLabel.text = YZMsg(@"activity_bind_phone_number_Email");
            self.phoneT.isNeedShowDropDown = true;
            self.phoneT.dropDownDelegate = self;
            self.phoneT.placeholder = YZMsg(@"activity_login_inputEmail");
            self.phoneT.keyboardType = UIKeyboardTypeEmailAddress;
            self.countryBgView.hidden = true;
            break;
        default:
            break;
    }

    self.phoneT.delegate = self;
    self.codeTitleLabel.text = YZMsg(@"activity_login_inputcode");
    self.areaLbale.text = YZMsg(@"activity_login_country_region");
    self.passWordT.placeholder = YZMsg(@"loginActivity_login_input_pwd");
    
    self.RechargeBtn.layer.masksToBounds = YES;
    self.RechargeBtn.layer.cornerRadius = 22;
    self.yanzhengmaBtn.layer.masksToBounds = YES;
    self.yanzhengmaBtn.layer.cornerRadius = 15;
    self.yanzhengmaBtn.layer.borderColor = RGB_COLOR(@"#EAEAEA", 1).CGColor;
    self.yanzhengmaBtn.layer.borderWidth = 0.5;
    self.RechargeBtn.enabled = NO;
    [self.yanzhengmaBtn setTitle:YZMsg(@"loginActivity_sendmsgcode") forState:UIControlStateNormal];
    self.yanzhengmaBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.yanzhengmaBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.RechargeBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeBtnBackground) name:UITextFieldTextDidChangeNotification object:nil];
    
    _countryBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *contrySelect = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(countrySelectAction)];
    [_countryBgView addGestureRecognizer:contrySelect];
    messageIssssss = 60;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self defaultSelectLocalLocation];
}
- (void)defaultSelectLocalLocation{
    NSString *locale = [[NSLocale currentLocale] countryCode];
    NSString *codeStr = [XYDeviceInfoUUID sharedInstance].locale;
    if(codeStr != nil && codeStr.length){
        locale = codeStr;
    }
    NSString *preferredLanguage = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    if(preferredLanguage!= nil && [preferredLanguage containsString:@"zh"]){
        locale = @"CN";
    }
    NSArray<NSDictionary *> *countryJson = [CountrySelectView shared].searchCountrys;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"locale == '%@'",locale]];
    NSArray<NSDictionary *> *selects = [countryJson filteredArrayUsingPredicate:predicate];
    if (selects.count == 1) {
        NSDictionary *selectLocale = selects.firstObject;
        self.countryNameL.text = selectLocale[@"locale"];
        UIImage *imgFlag = [UIImage imageNamed:[NSString stringWithFormat:@"CountryPicker.bundle/%@",selectLocale[@"locale"]]];
        if(imgFlag!= nil){
            self.flagImgV.image = imgFlag;
        }
        self.countryCodeL.text = [NSString stringWithFormat:@"+%@",selectLocale[@"code"]];
        self.countryCodeNum = [NSString stringWithFormat:@"%@",selectLocale[@"code"]];
    }
}
-(void)countrySelectAction{
    CountrySelectView *countrySelectV = [CountrySelectView shared];
    if ([[RookieTools shareInstance] currentLanguage] == AppLanguageType_CN_fan) {
        [countrySelectV setDisplayLanguage:DisplayLanguageTypeFanti];
    }else if([[RookieTools shareInstance] currentLanguage] == AppLanguageType_EN){
        [countrySelectV setDisplayLanguage:DisplayLanguageTypeEnglish];
    }else{
        [countrySelectV setDisplayLanguage:DisplayLanguageTypeChinese];
    }
    [countrySelectV show];
    WeakSelf
    countrySelectV.selectedCountryCallBack = ^(NSDictionary<NSString *,id> * _Nonnull countryDic) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.countryNameL.text = countryDic[@"locale"];
        
        strongSelf.flagImgV.image = (UIImage*)countryDic[@"countryImage"];
        strongSelf.countryCodeL.text = [NSString stringWithFormat:@"+%@",countryDic[@"code"]];
        strongSelf.countryCodeNum = [NSString stringWithFormat:@"%@",countryDic[@"code"]];
    };
}

-(void)ChangeBtnBackground {
    self.phoneT.errorLabel.text = @"";
    NSString *toBeString2 = _passWordT.text;
    if(_passWordT.text.length > 6) {
        _passWordT.text = [toBeString2 substringToIndex:6];
    }

    switch (self.bindingType) {
        case BindingTypeForPhone:
        {
            if (_phoneT.text.length > 0 && [_phoneT.text hasPrefix:@"0"]) {
                _phoneT.text = [_phoneT.text substringFromIndex:1];
            }

            NSString *toBeString = _phoneT.text;
            if(_phoneT.text.length > 20){
                _phoneT.text = [toBeString substringToIndex:20];
            }

            if (_phoneT.text.length > 6 && _passWordT.text.length >= 4)
            {
        //        [_doLoginBtn setTitleColor:RGB_COLOR(@"#ffffff", 1) forState:0];
                _RechargeBtn.backgroundColor =  RGB_COLOR(@"#FF34CD", 1);
                _RechargeBtn.enabled = YES;
            }
            else
            {
                    [_RechargeBtn setBackgroundColor:RGB_COLOR(@"#CFCFCF", 1)];
                    _RechargeBtn.enabled = NO;
            }
        }
            break;
        case BindingTypeForEmail:
            if (_phoneT.text.length != 0) {
                if (![self isValidEmail: _phoneT.text]) {
                    self.phoneT.errorLabel.text = YZMsg(@"login_email_error");
                }
            }

            if ([self isValidEmail: _phoneT.text] && _passWordT.text.length >= 4) {
                _RechargeBtn.backgroundColor =  RGB_COLOR(@"#FF34CD", 1);
                _RechargeBtn.enabled = YES;
            } else {
                [_RechargeBtn setBackgroundColor:RGB_COLOR(@"#CFCFCF", 1)];
                _RechargeBtn.enabled = NO;
            }
            break;
        default:
            break;
    }
}

//获取验证码倒计时
-(void)daojishi{
    _yanzhengmaBtn.userInteractionEnabled = NO;
//    [_yanzhengmaBtn setTitleColor:[UIColor whiteColor] forState:0];
//    [_yanzhengmaBtn setBackgroundColor:[normalColors colorWithAlphaComponent:0.5]];
    if (messageIssssss<=0) {
//        [_yanzhengmaBtn setTitleColor:RGB_COLOR(@"#ffffff", 1) forState:0];
        [_yanzhengmaBtn setTitle:YZMsg(@"loginActivity_resend") forState:UIControlStateNormal];
//        [_yanzhengmaBtn setBackgroundColor:[normalColors colorWithAlphaComponent:0.7]];
        _yanzhengmaBtn.userInteractionEnabled = YES;
        [messsageTimer invalidate];
        messsageTimer = nil;
        messageIssssss = 60;
    }else{
        [_yanzhengmaBtn setTitle:[NSString stringWithFormat:@"%ds",messageIssssss] forState:UIControlStateNormal];
    }
    messageIssssss-=1;
}
//键盘的隐藏
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneT resignFirstResponder];
    [self.view endEditing:YES];
}


- (IBAction)yanZhengAction:(id)sender {
        [self.view endEditing:YES];
    switch (self.bindingType) {
        case BindingTypeForPhone:
            [self getCodeForPhone];
            break;
        case BindingTypeForEmail:
            [self getCodeForEmail];
            break;
        default:
            break;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.bindingType == BindingTypeForEmail) {
        [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _phoneT && self.bindingType == BindingTypeForPhone) {
        if ([self.countryCodeNum integerValue] == 86 && ![string isEqualToString:@""]) {
            if (textField.text.length > 10) {
                return NO;
            }
        }
    }
    return YES;
}

- (IBAction)RechargeAction:(id)sender {
    [self.view endEditing:YES];
    switch (self.bindingType) {
        case BindingTypeForPhone:
            [self setupPhone];
            break;
        case BindingTypeForEmail:
            [self setupEmail];
            break;
        default:
            break;
    }
}
-(void)warningLogin:(NSString*)msg{
    WeakSelf
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_systemMsgTitle") message:[NSString stringWithFormat:@"%@%@",msg,YZMsg(@"activity_bind_phone_number_Login")] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:cancleAction];
    
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [[YBToolClass sharedInstance]logOutRequestIfAutologin:strongSelf.phoneT.text codeNum:strongSelf.passWordT.text];
    }];
    
    [alertC addAction:suerA];
    
    if (currentVC.presentedViewController != nil)
    {
        [currentVC dismissViewControllerAnimated:NO completion:nil];
    }
    if (currentVC.presentedViewController == nil) {
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
    
    
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getCodeForPhone {
    if (_phoneT.text.length == 0){
        [MBProgressHUD showError:YZMsg(@"loginActivity_login_input_phone")];
        return;
    }
    if (_phoneT.text.length<6){
        [MBProgressHUD showError:YZMsg(@"login_phone_error")];
        return;
    }
    else{
        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [hud hideAnimated:YES afterDelay:30];
        messageIssssss = 60;
        _yanzhengmaBtn.userInteractionEnabled = NO;
        self.isGetCodeResponse = NO;
        NSDictionary *getcode = @{
                                  @"mobile":_phoneT.text,
                                  @"country_code":self.countryCodeNum,
                                  @"sign":[[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"mobile=%@&76576076c1f5f657b634e966c8836a06",_phoneT.text]],
                                  @"is_wy_verify": @"1"
                                  };
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (!strongSelf.yanzhengmaBtn.userInteractionEnabled && !strongSelf.isGetCodeResponse) {
                if (strongSelf->hud) {
                    [strongSelf->hud hideAnimated:YES];
                }
                [MBProgressHUD showError:YZMsg (@"loginActivity_sendingcodetimeoutretry")];
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                if ([[YBNetworking sharedManager].manager.tasks count] > 0) {
                    for (NSURLSessionDataTask *taskssss in [YBNetworking sharedManager].manager.tasks) {
                        [taskssss cancel];
                    }
                }
                [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {

                } logs:nil];
            }
        });
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Login.getCode" withBaseDomian:YES andParameter:getcode data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf->hud) {
                [strongSelf->hud hideAnimated:YES];
            }

            [MBProgressHUD hideHUD];

            // 如果后端返回code=20001（需要网易验证码），则触发验证码并带着token重试
            if (code == 20001) {
//            if (code == 1001) { // 測試
                [self captchaVerify:getcode url:@"Login.getCode"];
                return;
            }

            if (code == 0) {
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                if (strongSelf->messsageTimer == nil) {
                    strongSelf->messsageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:strongSelf selector:@selector(daojishi) userInfo:nil repeats:YES];
                }
                [MBProgressHUD showError:YZMsg(@"loginActivity_sendsuccess")];
            }else{
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",msg]];
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            }
            strongSelf.isGetCodeResponse = YES;
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.isGetCodeResponse = YES;
            [MBProgressHUD hideHUD];
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld_msg:%@",error.code,error.localizedDescription]];
        }];
    }
}

- (void)getCodeForEmail {
    if (_phoneT.text.length == 0){
        [MBProgressHUD showError:YZMsg(@"loginActivity_login_input_email")];
        return;
    }
    if (![self isValidEmail:_phoneT.text]){
        [MBProgressHUD showError:YZMsg(@"login_email_error")];
        return;
    }
    else{
        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [hud hideAnimated:YES afterDelay:30];
        messageIssssss = 60;
        _yanzhengmaBtn.userInteractionEnabled = NO;
        self.isGetCodeResponse = NO;
        NSDictionary *getcode = @{
            @"recipient_email":_phoneT.text,
            @"sign":[[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"recipient_email=%@&76576076c1f5f657b634e966c8836a06",_phoneT.text]],
            @"is_wy_verify": @"1"
        };
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (!strongSelf.yanzhengmaBtn.userInteractionEnabled && !strongSelf.isGetCodeResponse) {
                if (strongSelf->hud) {
                    [strongSelf->hud hideAnimated:YES];
                }
                [MBProgressHUD showError:YZMsg (@"loginActivity_sendingcodetimeoutretry")];
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                if ([[YBNetworking sharedManager].manager.tasks count] > 0) {
                    for (NSURLSessionDataTask *taskssss in [YBNetworking sharedManager].manager.tasks) {
                        [taskssss cancel];
                    }
                }
                [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {

                } logs:nil];
            }
        });
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Login.getCodeByEmail" withBaseDomian:YES andParameter:getcode data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf->hud) {
                [strongSelf->hud hideAnimated:YES];
            }

            [MBProgressHUD hideHUD];

            // 如果后端返回code=20001（需要网易验证码），则触发验证码并带着token重试
            if (code == 20001) {
//            if (code == 0) { // 測試
                [self captchaVerify:getcode url:@"Login.getCodeByEmail"];
                return;
            }

            if (code == 0) {
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                if (strongSelf->messsageTimer == nil) {
                    strongSelf->messsageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:strongSelf selector:@selector(daojishi) userInfo:nil repeats:YES];
                }
                [MBProgressHUD showError:YZMsg(@"loginActivity_sendsuccess")];
            }else{
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",msg]];
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            }
            strongSelf.isGetCodeResponse = YES;
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.isGetCodeResponse = YES;
            [MBProgressHUD hideHUD];
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld_msg:%@",error.code,error.localizedDescription]];
        }];
    }
}

-(BOOL)isValidEmail:(NSString*)text {
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:text];
}

- (void)setupPhone {
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];

        NSDictionary *parmas = @{
                                @"mobile":self.phoneT.text,
                                @"code":self.passWordT.text,
                                @"token":[Config getOwnToken],
                                @"uid":[Config getOwnID],
                                @"country_code":self.countryCodeNum,
                                };
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setMobile" withBaseDomian:YES andParameter:parmas data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf->hud) {
                [strongSelf->hud hideAnimated:YES];
            }

            if (code == 0) {
                if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                    [MBProgressHUD showError:msg];
                    return;
                }
    //            NSString *account = strongSelf.phoneT.text;
                NSDictionary *infos = [info objectAtIndex:0];
                LiveUser *userInfo = [Config myProfile];
                userInfo.mobile = strongSelf.phoneT.text;
                userInfo.isBindMobile = true;
                [Config saveProfile:userInfo];

                [[NSUserDefaults standardUserDefaults] setObject:minstr([infos valueForKey:@"isagent"]) forKey:@"isagent"];
                if (strongSelf->messsageTimer) {
                    [strongSelf->messsageTimer invalidate];
                    strongSelf->messsageTimer = nil;
                }
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }else if(code == 1006){
                [strongSelf warningLogin:msg];

            }else{
               [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if ([error isKindOfClass:[NSError class]]) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld_msg:%@",error.code,error.localizedDescription]];
            } else {
                [MBProgressHUD showError: error.description];
            }
        }];

}

- (void)setupEmail {
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];

        NSDictionary *parmas = @{
                                @"email":self.phoneT.text,
                                @"code":self.passWordT.text,
                                @"token":[Config getOwnToken],
                                @"uid":[Config getOwnID]
                                };
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setEmail" withBaseDomian:YES andParameter:parmas data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf->hud) {
                [strongSelf->hud hideAnimated:YES];
            }

            if (code == 0) {
                if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                    [MBProgressHUD showError:msg];
                    return;
                }
    //            NSString *account = strongSelf.phoneT.text;
                NSDictionary *infos = [info objectAtIndex:0];
                LiveUser *userInfo = [Config myProfile];
                userInfo.user_email = strongSelf.phoneT.text;
//                userInfo.isBindMobile = true;
                [Config saveProfile:userInfo];

                [[NSUserDefaults standardUserDefaults] setObject:minstr([infos valueForKey:@"isagent"]) forKey:@"isagent"];
                if (strongSelf->messsageTimer) {
                    [strongSelf->messsageTimer invalidate];
                    strongSelf->messsageTimer = nil;
                }
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }else if(code == 1006){
                [strongSelf warningLogin:msg];

            }else{
               [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }

            if ([error isKindOfClass:[NSError class]]) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld_msg:%@",error.code,error.localizedDescription]];
            } else {
                [MBProgressHUD showError: error.description];
            }
    //        if (strongSelf->hud) {
    //            [strongSelf->hud hideAnimated:YES];
    //        }

        }];
}

- (void)captchaVerify:(NSDictionary*)param url:(NSString*)url {
    self.isGetCodeResponse = YES;
    NSLog(@"billDebug 需要网易验证码验证");

    WeakSelf
    [CaptchaManager showCaptchaWithViewController:self
                                        onSuccess:^(NSString * _Nonnull validate, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        // 验证验证码结果
        if (![CaptchaManager validateCaptchaResult:validate msg:msg]) {
            [MBProgressHUD showError:YZMsg(@"验证结果无效，请重新验证")];
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            return;
        }

        NSLog(@"billDebug 验证码验证成功，准备重试发送验证码");

        // 构建带有验证码token的参数
        NSMutableDictionary *retryParam = [param mutableCopy];
        retryParam[@"netease_token"] = validate;

        // 重新发送验证码请求
        strongSelf.isGetCodeResponse = NO;
        [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:retryParam data:nil success:^(int retryCode, id  _Nonnull retryInfo, NSString * _Nonnull retryMsg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }

            // 二次请求结果在这里直接处理
            if (retryCode == 0) {
                // 发送成功，开始倒计时
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                if (strongSelf->messsageTimer == nil) {
                    strongSelf->messsageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:strongSelf selector:@selector(daojishi) userInfo:nil repeats:YES];
                }
                [MBProgressHUD showError:YZMsg(@"loginActivity_sendsuccess")];
                NSLog(@"billDebug 验证码发送成功（二次请求），开始倒计时");
            } else {
                // 发送失败
                NSString *errorMsg = retryMsg ?: YZMsg(@"loginActivity_senderrorretry");
                [MBProgressHUD showError:errorMsg];
                strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                NSLog(@"billDebug 验证码发送失败（二次请求）: %@", errorMsg);
            }
            strongSelf.isGetCodeResponse = YES;
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [MBProgressHUD showError:YZMsg(@"loginActivity_senderrorretry")];
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            NSLog(@"billDebug 验证码发送失败（二次请求网络错误）: %@", error.localizedDescription);
            strongSelf.isGetCodeResponse = YES;
        }];
    } onError:^(NSString * _Nonnull errorMsg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD showError:errorMsg];
        strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
        NSLog(@"billDebug 验证码验证失败: %@", errorMsg);
    } onCancel:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD showError:YZMsg(@"验证已取消")];
        strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
        NSLog(@"billDebug 用户取消验证码");
    }];
}

#pragma mark - ShowDropDownTextFieldDelegate
- (void)showDropDownTextFieldForSelected {
    [self ChangeBtnBackground];
}
@end
