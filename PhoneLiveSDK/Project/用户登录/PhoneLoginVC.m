#import "PhoneLoginVC.h"
#import "MXBADelegate.h"
#import "ZYTabBarController.h"
#import "webH5.h"
#import <UMCommon/UMCommon.h>
//#import <ShareSDK/ShareSDK.h>

#import "NSString+Extention.h"
#import "ChannelStatistics.h"
#import "DeviceUUID.h"
#import "GuestLogin.h"

#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif


#if !TARGET_IPHONE_SIMULATOR
#import <GrowingTracker.h>
#endif

#import "XYDeviceInfoUUID.h"
#import "LaunchInitManager.h"
#import "CaptchaManager.h"

typedef NS_ENUM(NSUInteger, PhoneLoginVCLoginMethod) {
    PhoneLoginVCLoginMethodForPhone,
    PhoneLoginVCLoginMethodForEmail,
    PhoneLoginVCLoginMethodForUserName,
};

@interface PhoneLoginVC ()<UITextFieldDelegate, ShowDropDownTextFieldDelegate> {
    NSTimer *messsageTimer;
    int messageIssssss;//短信倒计时  60s
    NSArray *platformsarray;
    NSString * regChannel;//注册渠道
    NSInteger getRegChannelCount;
    MBProgressHUD *hud;
    BOOL _flag;
    
    NSString *_codeNum;
    NSString *_phoneNum;
    PhoneLoginVCLoginMethod loginMethod;
}
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VIewH;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong)NSString *isreg;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *privateBtn;
@property (weak, nonatomic) IBOutlet UILabel *contactKefuLabel;
@property (weak, nonatomic) IBOutlet UIButton *nonameLoginBtn;

- (IBAction)EULA:(id)sender;
#pragma mark ================ 语言包的时候需要修改的label ===============

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *flagImgV;
@property (weak, nonatomic) IBOutlet UILabel *countryNameL;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeL;
@property (weak, nonatomic) IBOutlet UIView *countryBgView;
@property (weak, nonatomic) IBOutlet UIButton *switchToOther;
@property (weak, nonatomic) IBOutlet UIView *domainswicthView;
@property (weak, nonatomic) IBOutlet UILabel *switchLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *emailTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *userNameTypeButton;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property(nonatomic,strong)NSString *countryCodeNum;
@end
@implementation PhoneLoginVC

-(NSString*)encodeString:(NSString*)unencodedString{
    unencodedString = [unencodedString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return unencodedString;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (hud) {
        [hud hideAnimated:YES];
    }
    [self defaultSelectLocalLocation];


}
-(void)autoLoginWithPhoneNum:(NSString*)phoneNum codeNum:(NSString*)codeNum
{
    _phoneNum = phoneNum;
    _codeNum = codeNum;


}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    if (_flag) {
        [_doLoginBtn addGradientView:RGB_COLOR(@"#FF87E7", 1) endColor:RGB_COLOR(@"#FE278A", 1)];
        [self changeLoginMethodAction:self.phoneTypeButton];
        _flag = NO;
    }
    [super viewDidAppear:animated];

    if (hud) {
        [hud hideAnimated:YES];
    }

    [MBProgressHUD hideHUD];
}
-(void)kefuAction{
    [YBToolClass showService];
}
- (void)defaultSelectLocalLocation{
    NSString *locale = [[NSLocale currentLocale] countryCode];
    NSString *codeStr = [XYDeviceInfoUUID sharedInstance].locale;
    if(codeStr !=  nil && codeStr.length){
        locale = codeStr;
    }
    NSString *preferredLanguage = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    if(preferredLanguage!= nil && [preferredLanguage containsString:@"zh"]){
        locale = @"CN";
    }
    NSArray<NSDictionary *> *countryJson = [CountrySelectView jsonCountrys];
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

    if (![PublicObj checkNull:_phoneNum] && ![PublicObj checkNull:_codeNum]) {
        _phoneT.text = _phoneNum;
        _passWordT.text = _codeNum;
        [self ChangeBtnBackground];
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            [strongSelf ChangeBtnBackground];
            [strongSelf mobileLogin:nil];
        });
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
- (void)viewDidLoad {
    [super viewDidLoad];
    loginMethod = PhoneLoginVCLoginMethodForPhone;
    [XYDeviceInfoUUID getWANIPAddress:^(NSString * _Nullable value) {

    }];
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
    [[GrowingTracker sharedInstance] trackCustomEvent:@"login_9"];
#endif
    _flag = YES;
    NSString *imgPath = [XResourceBundle pathForResource:@"bg_dl" ofType:@"png"];
    UIImage *backImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:imgPath]];
    self.backgroundImageView.image = backImage;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    //    NSDictionary *dddd = [[YBToolClass sharedInstance] checkUserPhoneDevice];
    self.phoneT.clearButtonMode = UITextFieldViewModeAlways;
    self.phoneT.minimumFontSize = 0.5;
    self.phoneT.adjustsFontSizeToFitWidth = true;
    self.phoneT.dropDownDelegate = self;
    self.phoneT.delegate = self;

    NSString *phoneTypeButtonTitle = YZMsg(@"activity_login_phoneLogin");
    [self.phoneTypeButton setTitle:phoneTypeButtonTitle forState:UIControlStateNormal];
    NSDictionary *attributes = @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
    NSAttributedString *phoneAttributedTitle = [[NSAttributedString alloc] initWithString:phoneTypeButtonTitle attributes:attributes];
    [self.phoneTypeButton setAttributedTitle:phoneAttributedTitle forState:UIControlStateSelected];

#ifdef LIVE
    NSString *userNameButtonTitle = YZMsg(@"activity_login_userName");
    [self.userNameTypeButton setTitle:userNameButtonTitle forState:UIControlStateNormal];
    NSAttributedString *userNameAttributedTitle = [[NSAttributedString alloc] initWithString:userNameButtonTitle attributes:attributes];
    [self.userNameTypeButton setAttributedTitle:userNameAttributedTitle forState:UIControlStateSelected];
#else
    self.userNameTypeButton.hidden = true;
#endif
    
    NSString *emailTypeButtonTitle = YZMsg(@"activity_login_emailLogin");
    [self.emailTypeButton setTitle:emailTypeButtonTitle forState:UIControlStateNormal];
    NSAttributedString *emailAttributedTitle = [[NSAttributedString alloc] initWithString:emailTypeButtonTitle attributes:attributes];
    [self.emailTypeButton setAttributedTitle:emailAttributedTitle forState:UIControlStateSelected];


    //
    NSString *str = [YZMsg(@"activity_login_loginproblem") stringByAppendingString:YZMsg(@"activity_login_connectkefu")];
    NSInteger lethW = YZMsg(@"activity_login_loginproblem").length;
    NSInteger kefuLe = YZMsg(@"activity_login_connectkefu").length;
    NSMutableAttributedString *attStr11=[[NSMutableAttributedString alloc]initWithString:str];
    [attStr11 addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, lethW)];
    [attStr11 addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#FFFC00", 1) range:NSMakeRange([str rangeOfString:YZMsg(@"activity_login_connectkefu")].location,kefuLe)];

    self.contactKefuLabel.attributedText = attStr11;
    regChannel = @"ios";//[NSString stringWithFormat:@"defaulChannel-%@",[DomainManager sharedInstance].domainCode];
    [[ChannelStatistics sharedInstance]channelsRequest:^(ChannelsModel *data) {

    }];


    _contactKefuLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapKefu = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(kefuAction)];
    [_contactKefuLabel addGestureRecognizer:tapKefu];

    _countryBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *contrySelect = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(countrySelectAction)];
    [_countryBgView addGestureRecognizer:contrySelect];

    _versionLabel.text = [NSString stringWithFormat:@"%@V:%@（%@）",YZMsg(@"activity_login_versionTitle"),APPVersionNumber,ios_buildVersion];;
    _doLoginBtn.userInteractionEnabled = NO;


    if (@available(iOS 13.0, *)) {
        [_phoneT setValue:[UIColor whiteColor] forKeyPath:@"placeholderLabel.textColor"];
        [_passWordT setValue:[UIColor whiteColor] forKeyPath:@"placeholderLabel.textColor"];
        //        [_passWordT setValue:[UIFont systemFontOfSize:16] forKeyPath:@"placeholderLabel.font"];
    } else {
        [_phoneT setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [_passWordT setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    //    [_regBtn setTitle:YZMsg(@"立即注册") forState:0];
    //    _regBtn.hidden = YES;
    [_doLoginBtn setTitle:YZMsg(@"activity_login_login") forState:0];
    [_doLoginBtn setTitleColor:[UIColor whiteColor] forState:0];

    //[_doLoginBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
    //    [_forgotBtn setTitle:YZMsg(@"忘记密码") forState:0];
    //    _forgotBtn.hidden = YES;
    [_yanzhengmaBtn setTitle:YZMsg(@"loginActivity_sendmsgcode") forState:0];
    [_yanzhengmaBtn setTitleColor:[UIColor whiteColor] forState:0];
    _yanzhengmaBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _yanzhengmaBtn.titleLabel.minimumScaleFactor = 0.5;
    [_nonameLoginBtn setTitle:YZMsg(@"activity_login_guestLogin") forState:UIControlStateNormal];
    _nonameLoginBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _nonameLoginBtn.titleLabel.minimumScaleFactor = 0.5;
    [_nonameLoginBtn addTarget:self action:@selector(nonameLogin:) forControlEvents:UIControlEventTouchUpInside];
    messageIssssss = 60;

    _switchLineLabel.text = YZMsg(@"activity_login_standbyline");
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [_phoneT addTarget:self action:@selector(ChangeBtnBackground) forControlEvents:UIControlEventEditingChanged];
    [_passWordT addTarget:self action:@selector(ChangeBtnBackground) forControlEvents:UIControlEventEditingChanged];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeBtnBackground) name:UITextFieldTextDidChangeNotification object:nil];

    //    WeakSelf
    //隐私
    _privateBtn.titleLabel.textColor = [UIColor whiteColor];
    _privateBtn.titleLabel.numberOfLines = 0;
    _privateBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attStr=[[NSMutableAttributedString alloc]initWithString:YZMsg(@"activity_login_privateServer")];
    //    [attStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(8, 7)];
    [_privateBtn setAttributedTitle:attStr forState:0];
    //    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    //    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
    //        STRONGSELF
    //        if (strongSelf == nil) {
    //            return;
    //        }
    //        if (status == AFNetworkReachabilityStatusNotReachable) {
    ////            [strongSelf getLoginThird];
    //            return;
    //        }else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable){
    //            NSLog(@"nonetwork-------");
    ////            [strongSelf getLoginThird];
    //        }else if ((status == AFNetworkReachabilityStatusReachableViaWWAN)||(status == AFNetworkReachabilityStatusReachableViaWiFi)){
    ////            [strongSelf getLoginThird];
    //            NSLog(@"wifi-------");
    //        }
    //    }];

    UITapGestureRecognizer *gestureSwitch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchDomain)];
    [self.domainswicthView addGestureRecognizer:gestureSwitch];
    
    NSArray *loginTypes = [common getLoginTypes];
    self.phoneTypeButton.hidden = ![loginTypes containsObject:@"phone"];
    self.emailTypeButton.hidden = ![loginTypes containsObject:@"email"];
    self.nonameLoginBtn.hidden = ![loginTypes containsObject:@"guest"];
    if (self.phoneTypeButton.hidden) {
        [self changeLoginMethodAction:self.emailTypeButton];
    }
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.segmentView addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.segmentView);
    }];
    
    [self.stackView removeFromSuperview];
    [scrollView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(scrollView);
        make.height.mas_equalTo(scrollView);
    }];
}
-(void)switchDomain{
//    [self switchToOtherAction:self.switchToOther];
}
-(void)ChangeBtnBackground {
    self.phoneT.errorLabel.text = @"";
    BOOL isCheckSuccess = false;
    NSString *toBeString2 = _passWordT.text;
    switch (loginMethod) {
        case PhoneLoginVCLoginMethodForPhone:
        {
            if(_passWordT.text.length > 6) {
                _passWordT.text = [toBeString2 substringToIndex:6];
            }
            //    if (_phoneT.text.length >0 && _passWordT.text.length >0)
            //    {
            //        [_doLoginBtn setBackgroundColor:normalColors];
            //        _doLoginBtn.userInteractionEnabled = YES;
            //    }
            //    else
            //    {
            //        [_doLoginBtn setBackgroundColor:[normalColors colorWithAlphaComponent:0.5]];
            //        _doLoginBtn.userInteractionEnabled = NO;
            //    }

            if (_phoneT.text.length > 0 && [_phoneT.text hasPrefix:@"0"]) {
                _phoneT.text = [_phoneT.text substringFromIndex:1];
            }

            NSString *toBeString = _phoneT.text;
            if(_phoneT.text.length > 20){
                _phoneT.text = [toBeString substringToIndex:20];
            }

            if(messageIssssss >= 60){
                //        if (_phoneT.text.length == 11) {
                //            [_yanzhengmaBtn setTitleColor:RGB_COLOR(@"#ffffff", 1) forState:0];
                //            [_yanzhengmaBtn setBackgroundColor:[normalColors colorWithAlphaComponent:0.7]];
                //        }else{
                //            [_yanzhengmaBtn setTitleColor:RGB_COLOR(@"#cecdcd", 0.6) forState:0];
                //            [_yanzhengmaBtn setBackgroundColor:[normalColors colorWithAlphaComponent:0.25]];
                //        }
            }

            if (_phoneT.text.length > 6 && _passWordT.text.length >= 4)
            {
                //        [_doLoginBtn setTitleColor:RGB_COLOR(@"#ffffff", 1) forState:0];
//                [_doLoginBtn setBackgroundColor:[[UIColor systemPinkColor] colorWithAlphaComponent:0.7]];
                isCheckSuccess = true;
            }
            else
            {
                //        [_doLoginBtn setTitleColor:RGB_COLOR(@"#cecdcd", 0.6) forState:0];
                isCheckSuccess = false;
            }
        }
            break;
        case PhoneLoginVCLoginMethodForEmail:
            if (_phoneT.text.length != 0) {
                if (![self isValidEmail: _phoneT.text]) {
                    self.phoneT.errorLabel.text = YZMsg(@"login_email_error");
                }
            }

            if(_passWordT.text.length > 6) {
                _passWordT.text = [toBeString2 substringToIndex:6];
            }
            if ([self isValidEmail: _phoneT.text] && _passWordT.text.length >= 4) {
                isCheckSuccess = true;
            } else {
                isCheckSuccess = false;
            }
            break;
        case PhoneLoginVCLoginMethodForUserName:
            if (_phoneT.text.length >= 1 && _passWordT.text.length >= 1) {
                isCheckSuccess = true;
            } else {
                isCheckSuccess = false;
            }
            break;
        default:
            break;
    }
    [self changeLoginButtonBackgroundColor:isCheckSuccess];
    _doLoginBtn.userInteractionEnabled = isCheckSuccess;
}

- (void)changeLoginButtonBackgroundColor:(BOOL)isShowGrandient {
    [_doLoginBtn setBackgroundColor:isShowGrandient ? [UIColor clearColor] : [UIColor grayColor]];
    [_doLoginBtn.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CAGradientLayer class]]) {
            obj.hidden = !isShowGrandient;
        }
    }];
}

- (IBAction)mobileLogin:(id)sender {

    [self.view endEditing:YES];
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:20];


    if(([LaunchInitManager sharedInstance].wangyiToken == nil || [LaunchInitManager sharedInstance].wangyiToken.length<1) && !([DeviceUUID uuidFromWangyiDevice]!= nil && [DeviceUUID uuidFromWangyiDevice].length>0)){
//        WeakSelf
        [[LaunchInitManager sharedInstance] initWangyiToken:^(BOOL success) {
            //            STRONGSELF

        }];

    }

    __block  BOOL isLoginAction = false;
    WeakSelf
    [[ChannelStatistics sharedInstance]channelsRequest:^(ChannelsModel *data) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([ChannelStatistics sharedInstance].model && [ChannelStatistics sharedInstance].model.channelCode && [ChannelStatistics sharedInstance].model.channelCode.length>0) {
            strongSelf->regChannel = [ChannelStatistics sharedInstance].model.channelCode;
        }

        NSString *pushid;
//        if ([JPUSHService registrationID]) {
//            pushid = [JPUSHService registrationID];
//        }else{
//            pushid = @"";
//        }
        [XYDeviceInfoUUID getWANIPAddress:^(NSString * _Nullable ipaddress) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSString *auth_method = @"";
            if (strongSelf->loginMethod == PhoneLoginVCLoginMethodForPhone) {
                auth_method = @"0";
            } else if (strongSelf->loginMethod == PhoneLoginVCLoginMethodForEmail) {
                auth_method = @"1";
            } else if (strongSelf->loginMethod == PhoneLoginVCLoginMethodForUserName) {
                auth_method = @"2";
            }
            NSDictionary *Login = @{
                @"user_login":strongSelf.phoneT.text,
                @"user_pass":strongSelf.passWordT.text,
                @"mobile_code":strongSelf.passWordT.text,
                @"source":strongSelf->regChannel?strongSelf->regChannel:@"",
                @"pushid":pushid?pushid:@"",
                @"appid":[DomainManager sharedInstance].domainCode,
                @"device":[DeviceUUID uuidForPhoneDevice]?[DeviceUUID uuidForPhoneDevice]:@"",
                @"fp":[GuestLogin getEncodefp]?[GuestLogin getEncodefp]:@"",
                @"device_mac":@"",
                @"webUmidToken":data.webUmidToken?data.webUmidToken:@"",
                @"acd_token":[LaunchInitManager sharedInstance].wangyiToken?[LaunchInitManager sharedInstance].wangyiToken:@"",
                @"acd_device":[DeviceUUID uuidFromWangyiDevice]?[DeviceUUID uuidFromWangyiDevice]:@"",
                @"ali_device":@"",
                @"net_ip":ipaddress?ipaddress:@"",
                @"uaToken":data.uaToken?data.uaToken:@"",
                @"sub_plat":[DomainManager sharedInstance].domainCode,
                @"deviceToken":[LaunchInitManager sharedInstance].aliToken?[LaunchInitManager sharedInstance].aliToken:@"",
                @"auth_method": auth_method

            };
            [[YBNetworking sharedManager] postNetworkWithUrl:@"Login.userLogin" withBaseDomian:YES andParameter:Login data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                if (strongSelf == nil) {
                    return;
                }

                if (code == 0) {
                    if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                        [MBProgressHUD showError:msg];
                        return;
                    }
                    //            NSString *account = strongSelf.phoneT.text;
                    NSDictionary *infos = [info objectAtIndex:0];
                    LiveUser *userInfo = [[LiveUser alloc] initWithDic:infos];
                    [Config saveProfile:userInfo];
                    NSString *acd_device = infos[@"acd_device"];
                    if (acd_device && acd_device.length>0) {
                        [DeviceUUID setWangyiDevice:acd_device];
                    }
                    //                    NSString *ali_device = infos[@"ali_device"];
                    //                    if (ali_device && ali_device.length>0) {
                    //                        [DeviceUUID setAliDevice:ali_device];
                    //                    }
                    BOOL dfk = [infos[@"dfk"] boolValue];
                    BOOL dsm = [infos[@"dsm"] boolValue];

                    //                [strongSelf LoginJM];
                    strongSelf.navigationController.navigationBarHidden = YES;
                    //判断第一次登陆
                    NSString *isreg = minstr([infos valueForKey:@"isreg"]);
                    strongSelf.isreg = isreg;
                    [[NSUserDefaults standardUserDefaults] setObject:minstr([infos valueForKey:@"isagent"]) forKey:@"isagent"];
                    if (strongSelf->messsageTimer) {
                        [strongSelf->messsageTimer invalidate];
                        strongSelf->messsageTimer = nil;
                    }

                    if([isreg isEqualToString:@"1"] && !isLoginAction){
                        [[ChannelStatistics sharedInstance] reportRegister:userInfo.ID report:!(dfk || dsm)];
                    }
                    isLoginAction = true;
                    [[MXBADelegate sharedAppDelegate] getAppConfig:^(NSString *errormsg, NSDictionary *json) {
                        STRONGSELF
                        if (!strongSelf) return;
                        if (errormsg && json == nil && strongSelf->hud) {
                            [strongSelf->hud hideAnimated:YES];
                            [MBProgressHUD showError:errormsg];
                            return;
                        }
                        [[DomainManager sharedInstance]loadCacheHomeRecommand:^(NSString *hostStr) {
                            [strongSelf login];
                        }];
                    }];
                    [MobClick profileSignInWithPUID:[DomainManager sharedInstance].domainCode provider:[Config getOwnID]];
                }else{
                    if (strongSelf->hud) {
                        [strongSelf->hud hideAnimated:YES];
                    }
                    [MBProgressHUD showError:msg];
                }
            } fail:^(NSError * _Nonnull error) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (strongSelf->hud) {
                    [strongSelf->hud hideAnimated:YES];
                }

                if ([error isKindOfClass:[NSError class]]) {
                    [MBProgressHUD showError:[NSString stringWithFormat:@"request error%ld..%@",error.code,error.localizedDescription]];
                } else {
                    [MBProgressHUD showError: error.description];
                }
            }];
        }];

    }];


}
-(void)LoginJM{
//    if ([Config getOwnID]<=0) {
//        return;
//    }
//    NSString *aliasStr = [NSString stringWithFormat:@"%@PUSH",[Config getOwnID]];
//    //    [JPUSHService setAlias:aliasStr callbackSelector:nil object:nil];
//    [JMSGUser registerWithUsername:[NSString stringWithFormat:@"%@%@",JmessageName,[Config getOwnID]] password:aliasStr completionHandler:^(id resultObject, NSError *error) {
//        if (!error) {
//            NSLog(@"login-极光IM注册成功");
//        } else {
//            NSLog(@"login-极光IM注册失败，可能是已经注册过了");
//        }
//        if ([Config getOwnID]>0) {
//            NSString *aliasStr = [NSString stringWithFormat:@"%@PUSH",[Config getOwnID]];
//            [JMSGUser loginWithUsername:[NSString stringWithFormat:@"%@%@",JmessageName,[Config getOwnID]] password:aliasStr completionHandler:^(id resultObject, NSError *error) {
//                if (!error) {
//                    NSLog(@"login-极光IM登录成功");
//                } else {
//                    NSLog(@"login-极光IM登录失败");
//                }
//            }];
//        }
//
//    }];
}
-(void)login{
    if (hud) {
        [hud hideAnimated:YES];
    }
    
    //    [cityDefault saveisreg:self.isreg];
    ZYTabBarController *root = [[ZYTabBarController alloc]init];
    CATransition *animation = [CATransition animation];
    //动画时间
    animation.duration = 0.3;
    //过滤效果
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionReveal;
    animation.removedOnCompletion = YES;
    //设置方向-该属性从下往上弹出
    animation.subtype = kCATransitionFromBottom;
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = root;
}
//- (IBAction)regist:(id)sender {
//    hahazhucedeview *regist = [[hahazhucedeview alloc]init];
//    [self.navigationController pushViewController:regist animated:YES];
//}
//- (IBAction)forgetPass:(id)sender {
//    getpasswordview *getpass = [[getpasswordview alloc]init];
//    [self.navigationController pushViewController:getpass animated:YES];
//}

//- (IBAction)clickBackBtn:(UIButton *)sender {
//
//    [self.navigationController popViewControllerAnimated:YES];
//
//}
//获取验证码倒计时
-(void)daojishi{
    [_yanzhengmaBtn setTitle:[NSString stringWithFormat:@"%ds",messageIssssss] forState:UIControlStateNormal];
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
    }
    messageIssssss-=1;
}
//键盘的隐藏
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneT resignFirstResponder];
    [self.view endEditing:YES];
}
- (IBAction)EULA:(id)sender {
    webH5 *VC = [[webH5 alloc]init];
    NSString *paths = [[DomainManager sharedInstance].domainGetString stringByAppendingString:@"/index.php?g=portal&m=page&a=index&id=1"];
    paths = [paths stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    VC.urls = paths;
    VC.titles = YZMsg(@"login_tip_2");
    [self.navigationController pushViewController:VC animated:YES];
}

BOOL isGetCodeResponse;
- (IBAction)getYanZheng:(id)sender {
    [self.view endEditing:YES];
    switch (loginMethod) {
        case PhoneLoginVCLoginMethodForPhone:
            if (_phoneT.text.length == 0){
                [MBProgressHUD showError:YZMsg(@"loginActivity_login_input_phone")];
                return;
            }
            if (_phoneT.text.length<6){
                [MBProgressHUD showError:YZMsg(@"login_phone_error")];
                return;
            } else {
                NSDictionary *getcode = @{
                    @"mobile":_phoneT.text,
                    @"plat_id":[DomainManager sharedInstance].domainCode,
                    @"country_code":self.countryCodeNum,
                    @"sign":[[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"mobile=%@&76576076c1f5f657b634e966c8836a06",_phoneT.text]],
                    @"is_wy_verify": @"1"
                };
                [self sendYanZheng:getcode url:@"Login.getCode"];
            }
            break;
        case PhoneLoginVCLoginMethodForEmail:
            if (_phoneT.text.length == 0){
                [MBProgressHUD showError:YZMsg(@"loginActivity_login_input_email")];
                return;
            }
            if (![self isValidEmail:_phoneT.text]){
                [MBProgressHUD showError:YZMsg(@"login_email_error")];
                return;
            } else {
                NSDictionary *getcode = @{
                    @"recipient_email":_phoneT.text,
                    @"sign":[[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"recipient_email=%@&76576076c1f5f657b634e966c8836a06",_phoneT.text]],
                    @"is_wy_verify": @"1"
                };
                [self sendYanZheng:getcode url:@"Login.getCodeByEmail"];
            }
            break;
        default:
            break;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (loginMethod == PhoneLoginVCLoginMethodForEmail) {
        [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _phoneT && loginMethod == PhoneLoginVCLoginMethodForPhone) {
        if ([self.countryCodeNum integerValue] == 86 && ![string isEqualToString:@""]) {
            if (textField.text.length > 10) {
                return NO;
            }
        }
    }
    return YES;
}
- (IBAction)switchToOtherAction:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    if (sender.selected) {

//        [DomainManager sharedInstance].forceProxy = true;
//        [DomainManager domainSelectedSuccseBlock:^(NSString *bestDomain) {
//            dispatch_main_async_safe(^{
//                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
//            });
//
//        } logs:^(NSString *logstring) {
//
//        }];
//    }else{
//        [DomainManager sharedInstance].forceProxy = false;
//        [DomainManager domainSelectedSuccseBlock:^(NSString *bestDomain) {
//            dispatch_main_async_safe(^{
//                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
//            });
//        } logs:^(NSString *logstring) {
//
//        }];
//    }
}
- (void)nonameLogin:(UIButton *)sender{
     hud= [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    WeakSelf
    [[GuestLogin sharedInstance]loginWithGuest:^(BOOL success,NSString *errorMsg) {
        STRONGSELF
       
        if (success) {
            [[DomainManager sharedInstance]loadCacheHomeRecommand:^(NSString *hostStr) {
                [strongSelf login];
            }];
           
        }else{
            [strongSelf->hud hideAnimated:YES];
            [MBProgressHUD showError:errorMsg];
        }
    }];
}

- (IBAction)changeLoginMethodAction:(UIButton*)sender {
    if (sender == self.phoneTypeButton) {
        if (self.phoneTypeButton.isSelected) {
            return;
        }
        loginMethod = PhoneLoginVCLoginMethodForPhone;
        self.countryBgView.hidden = false;
        self.phoneT.isNeedShowDropDown = false;
        self.phoneT.text = @"";
        self.phoneT.placeholder = YZMsg(@"activity_login_inputPhoneNum");
        self.phoneT.keyboardType = UIKeyboardTypeNumberPad;
        self.passWordT.text = @"";
        self.passWordT.placeholder = YZMsg(@"activity_login_inputcode");
        self.yanzhengmaBtn.hidden = false;
        [self.doLoginBtn setTitle:YZMsg(@"activity_login_loginAndRegister") forState:UIControlStateNormal];
    } else if (sender == self.emailTypeButton) {
        if (self.emailTypeButton.isSelected) {
            return;
        }
        loginMethod = PhoneLoginVCLoginMethodForEmail;
        self.countryBgView.hidden = true;
        self.phoneT.isNeedShowDropDown = true;
        self.phoneT.text = @"";
        self.phoneT.placeholder = YZMsg(@"activity_login_inputEmail");
        self.phoneT.keyboardType = UIKeyboardTypeEmailAddress;
        self.passWordT.text = @"";
        self.passWordT.placeholder = YZMsg(@"activity_login_inputcode");
        self.yanzhengmaBtn.hidden = false;
        [self.doLoginBtn setTitle:YZMsg(@"activity_login_loginAndRegister") forState:UIControlStateNormal];
    } else if (sender == self.userNameTypeButton) {
        if (self.userNameTypeButton.isSelected) {
            return;
        }
        loginMethod = PhoneLoginVCLoginMethodForUserName;
        self.countryBgView.hidden = true;
        self.phoneT.isNeedShowDropDown = false;
        self.phoneT.text = @"";
        self.phoneT.placeholder = YZMsg(@"loginActivity_login_input_userName");
        self.phoneT.keyboardType = UIKeyboardTypeASCIICapable;
        self.passWordT.text = @"";
        self.passWordT.placeholder = YZMsg(@"activity_login_inputPassword");
        self.yanzhengmaBtn.hidden = true;
        [self.doLoginBtn setTitle:YZMsg(@"activity_login_login") forState:UIControlStateNormal];
    }

    [self.phoneT resignFirstResponder];
    self.phoneTypeButton.selected = false;
    self.emailTypeButton.selected = false;
    self.userNameTypeButton.selected = false;
    sender.selected = true;

    [self ChangeBtnBackground];
}

-(BOOL)isValidEmail:(NSString*)text {
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:text];
}

- (void)sendYanZheng:(NSDictionary*)param url:(NSString*)url {
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:30];
    messageIssssss = 60;
    _yanzhengmaBtn.userInteractionEnabled = NO;
    isGetCodeResponse = NO;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!strongSelf.yanzhengmaBtn.userInteractionEnabled && !isGetCodeResponse) {
            if (strongSelf->hud) {
                [strongSelf->hud hideAnimated:YES];
            }
            [MBProgressHUD showError:YZMsg(@"loginActivity_sendingcodetimeoutretry")];
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            if ([[YBNetworking sharedManager].manager.tasks count] > 0) {
                for (NSURLSessionDataTask *taskssss in [YBNetworking sharedManager].manager.tasks) {
                    [taskssss cancel];
                }
            }
//            [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
//
//            } logs:nil];
        }
    });
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:param data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
//        if (code == 1002) { // 測試
            isGetCodeResponse = YES;
            NSLog(@"billDebug 需要网易验证码验证");
            [CaptchaManager showCaptchaWithViewController:strongSelf
                                                onSuccess:^(NSString * _Nonnull validate, NSString * _Nonnull msg) {
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
                isGetCodeResponse = NO;
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
                    isGetCodeResponse = YES;
                } fail:^(NSError * _Nonnull error) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    [MBProgressHUD showError:YZMsg(@"loginActivity_senderrorretry")];
                    strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
                    NSLog(@"billDebug 验证码发送失败（二次请求网络错误）: %@", error.localizedDescription);
                    isGetCodeResponse = YES;
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

            // 已在回调中处理二次请求结果，这里直接返回，避免后续用旧的 value 再判断
            return;
        }

        if (code == 0) {
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
            if (strongSelf->messsageTimer == nil) {
                strongSelf->messsageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:strongSelf selector:@selector(daojishi) userInfo:nil repeats:YES];
            }
            [MBProgressHUD showError:YZMsg(@"loginActivity_sendsuccess")];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@..",msg]];
            strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;
        }
        isGetCodeResponse = YES;
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->hud) {
            [strongSelf->hud hideAnimated:YES];
        }
        isGetCodeResponse = YES;
        [MBProgressHUD hideHUD];
        strongSelf.yanzhengmaBtn.userInteractionEnabled = YES;

        if ([error isKindOfClass:[NSError class]]) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld msg:%@|%@",error.code,error.localizedDescription,[DomainManager sharedInstance].domainString]];
        } else {
            [MBProgressHUD showError: error.description];
        }
    }];
}

#pragma mark - ShowDropDownTextFieldDelegate
- (void)showDropDownTextFieldForSelected {
    [self ChangeBtnBackground];
}


@end
