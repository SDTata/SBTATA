//
//  LaunchInitManager.m
//  phonelive
//
//  Created by test on 3/22/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LaunchInitManager.h"
#import "MXBADelegate.h"
#import <GTMBase64.h>
#import "zlib.h"
#import "HHTools.h"
#import "UINavModalWebView.h"
#import "webH5.h"
#import "PhoneLoginVC.h"
#import "ZYTabBarController.h"
#import "GuestLogin.h"
#import "ChannelStatistics.h"
#import "DeviceUUID.h"
#import "HHTraceSDK.h"
#import "AliyunLogProducer.h"
#import "VKSupportUtil.h"
#import "FQLockGestureViewController.h"
#import "FQLockHelper.h"
#import "LaunchAdModel.h"
#import <UMCommon/UMCommon.h>
#if !TARGET_IPHONE_SIMULATOR
#import "GrowingTracker.h"
#endif

#import <AdSupport/ASIdentifierManager.h>
#import <AdSupport/AdSupport.h>
#if defined(__IPHONE_14_0)
#import <AppTrackingTransparency/AppTrackingTransparency.h>//适配iOS14
#endif


/** 启动图来源 */
typedef NS_ENUM(NSInteger,LaunchImageSourceType) {
    /** LaunchImage(default) */
    LaunchImageSourceType_launchImage = 1,
    /** LaunchScreen.storyboard */
    LaunchImageSourceType_launchScreen = 2,
};

@interface LaunchImageView : UIImageView

@end

@implementation LaunchImageView
#pragma mark - private
- (instancetype)initWithSourceType:(LaunchImageSourceType)sourceType{
    self = [super init];
    if (self) {
        id ddd = [UIApplication sharedApplication].keyWindow;
        if (ddd == nil) {
            self.frame = [[UIScreen mainScreen] bounds];
        }else{
            self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        }
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundColor = [UIColor whiteColor];
        switch (sourceType) {
            case LaunchImageSourceType_launchImage:{
                self.image = [self imageFromLaunchImage];
            }
                break;
            case LaunchImageSourceType_launchScreen:{
                self.image = [self imageFromLaunchScreen];
            }
                break;
            default:
                break;
        }
    }
    return self;
}

-(UIImage *)imageFromLaunchImage{
    UIImage *imageP = [self launchImageWithType:@"Portrait"];
    if(imageP) return imageP;
    UIImage *imageL = [self launchImageWithType:@"Landscape"];
    if(imageL)  return imageL;
    NSLog(@"获取LaunchImage失败!请检查是否添加启动图,或者规格是否有误.");
    return nil;
}

-(UIImage *)imageFromLaunchScreen{
    NSString *UILaunchStoryboardName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchStoryboardName"];
    if(UILaunchStoryboardName == nil){
        NSLog(@"从 LaunchScreen 中获取启动图失败!");
        return nil;
    }
    UIViewController *LaunchScreenSb = [[UIStoryboard storyboardWithName:UILaunchStoryboardName bundle:nil] instantiateInitialViewController];
    if(LaunchScreenSb){
        UIView * view = LaunchScreenSb.view;
        if (view.subviews.count>0) {
            UIImage *image = ((UIImageView*)view.subviews.firstObject).image;
            self.contentMode =  ((UIImageView*)view.subviews.firstObject).contentMode;
            return image;
        }
    }
    NSLog(@"从 LaunchScreen 中获取启动图失败!");
    return nil;
}

-(UIImage *)launchImageWithType:(NSString *)type{
    //比对分辨率,获取启动图 fix #158:https://github.com/CoderZhuXH/XHLaunchAd/issues/158
    
    if ([DomainManager currentLaunchImgName]) {
        return [ImageBundle imagewithBundleName:[DomainManager currentLaunchImgName]];
    }else{
        return [self imageFromLaunchScreen];
    }
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize screenDipSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * screenScale, [UIScreen mainScreen].bounds.size.height * screenScale);
    NSString *viewOrientation = type;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict){
        UIImage *image = [UIImage imageNamed:dict[@"UILaunchImageName"]];
        CGSize imageDpiSize = CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
        if([viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]){
            if([dict[@"UILaunchImageOrientation"] isEqualToString:@"Landscape"]){
                imageDpiSize = CGSizeMake(imageDpiSize.height, imageDpiSize.width);
            }
            if(CGSizeEqualToSize(screenDipSize, imageDpiSize)){
                return image;
            }
        }
    }
    return nil;
}
@end
@interface LaunchInitViewController : UIViewController
@property(nonatomic,strong)LaunchImageView *launchImageView;
@property (nonatomic,strong)UILabel *progressLab;//启动进度
@property (nonatomic,strong)UIProgressView *progressView;//进度条
@property (nonatomic,strong)UILabel *versionLab;//版本
@property (nonatomic,strong)UIButton *logButton;//日志复制按钮
@property (nonatomic,strong)UIButton *serviceButton;//联系客服按钮
@property (nonatomic,copy)NSString *logString;//日志复制
@property(nonatomic,strong)NSString *logContentSt;//日志
@property(nonatomic,strong)Log* logAliyun;
@property(nonatomic,strong)LogProducerClient *clientLog;
@end

@implementation LaunchInitViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.launchImageView = [[LaunchImageView alloc] initWithSourceType:LaunchImageSourceType_launchImage];
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:self.launchImageView];

    WeakSelf
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        STRONGSELF
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        BOOL requireGestureUnlock = [[infoDictionary objectForKey:@"RequireGestureUnlock"] boolValue];
//        if (requireGestureUnlock && [Config getOwnID] && [FQLockHelper isLocalGestureEnableForUserId:[Config getOwnID]]) {
//            FQLockGestureViewController *lockVC = [[FQLockGestureViewController alloc] init];
//            lockVC.lockType = FQLockTypeLogin;
//            lockVC.userID = [Config getOwnID];
//            lockVC.localLockBlock = ^(BOOL complete) {
//                if (complete) {
//                    [strongSelf login_2];
//                }
//            };
//            lockVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [strongSelf presentViewController:lockVC animated: NO completion:nil];  lockVC = nil;
//        } else {
//            [strongSelf login_2];
//        }
//    });
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        [strongSelf login_2];
    });

}

- (void)login_2 {
    [[LaunchInitManager sharedInstance] startMonitor];
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
    [[GrowingTracker sharedInstance] trackCustomEvent:@"login_2"];
#endif
    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
    [self addProgerss];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}
- (void)startProcess{
    if (_progressView) {
        [_progressView setProgress:0 animated:YES];
    }
    
    __block NSInteger index = 1;
    __block NSInteger numberOfIndex = 0;
    
    self.logString = @"";
    
    NSString* endpoint = @"cn-shanghai.log.aliyuncs.com";
    NSString* project = @"a000-ios";
    NSString* logstore = @"a000-ios";
    
    
    LogProducerConfig* configLog = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:aliaccesskeyid accessKeySecret:aliaccesskeysecret];
    // 设置主题
    [configLog SetTopic:@"iOS启动日志"];
    // 设置tag信息，此tag会附加在每条日志上
    
    [configLog AddTag:@"plat_ID" value:[DomainManager sharedInstance].domainCode];
    [configLog AddTag:@"device_ID" value:[DeviceUUID uuidForPhoneDevice]];
    [configLog AddTag:@"system_version" value:[NSString stringWithFormat:@"%@ %@",APPVersionNumber,ios_buildVersion]];
    [configLog AddTag:@"user_ID" value:[Config getOwnID]?[Config getOwnID]:@""];
    
    
    
    
    self.clientLog = [[LogProducerClient alloc] initWithLogProducerConfig:configLog];
    self.logAliyun = [[Log alloc] init];
    self.logContentSt = @"";
    WeakSelf
    DomainManager.sharedInstance.logsCallback = ^(NSString *logstring) {
        STRONGSELF
        dispatch_async(dispatch_get_main_queue(), ^{
        if (strongSelf == nil ||strongSelf.logContentSt == nil ||strongSelf.logString == nil) {
            return;
        }
      
            strongSelf.logString = [NSString stringWithFormat:@"%@\n%@",strongSelf.logString,logstring];
            index = index + 1;
            numberOfIndex++;
            NSTimeInterval logTime = [[NSDate date] timeIntervalSince1970]*1000;
            strongSelf.logContentSt = [strongSelf.logContentSt stringByAppendingFormat:@"\n%@  时间:%.0f",logstring,logTime];
            if (numberOfIndex>100) {
                numberOfIndex = 0;
                
                [strongSelf.logAliyun PutContent:@"内容" value:strongSelf.logContentSt];
                // addLog第二个参数flush，是否立即发送，1代表立即发送，不设置时默认为0
                LogProducerResult res = [strongSelf.clientLog AddLog:strongSelf.logAliyun flush:0];
                if (res!= 0) {
                    NSLog(@"日志发送失败");
                }
            }
            
            if (index>35.0) {
                index = 35.0;
            }
            if (logstring!= nil && [logstring containsString:@"successEnter"]) {
                index = 35.0;
            }
            CGFloat process = (index / 35.0) * 0.9;
            NSLog(@"index:%zd logString:%@",index,logstring);
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                // UI更新代码
//                if (strongSelf == nil) {
//                    return;
//                }
                [strongSelf updateProcess:process tip:logstring];
//            }];
            
        });
        
        
    };
}
- (void)updateProcess:(CGFloat)process tip:(NSString *)tip{
    if (_progressView.progress>process) {
        return;
    }
    NSString *tipStr = [[tip substringToIndex:tip.length>10?10:tip.length] stringByAppendingString:@"....."];
    _progressLab.text = tipStr;
    [_progressView setProgress:process animated:YES];
}
-(void)addProgerss{
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(AD(20), _window_height-kSafeBottomHeight - AD(81), _window_width - AD(40), AD(76))];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    backgroundView.clipsToBounds = YES;
    backgroundView.layer.cornerRadius = 5;
    [self.view addSubview:backgroundView];
    _serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceButton.userInteractionEnabled = YES;
    _serviceButton.frame = CGRectMake(_window_width - AD(40) - AD(60), AD(7), AD(60), AD(20));
    [_serviceButton setTitle:YZMsg(@"activity_login_connectkefu1") forState:UIControlStateNormal];
    _serviceButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_serviceButton setTitleColor:RGB(32, 151, 192) forState:UIControlStateNormal];
    [_serviceButton addTarget:self action:@selector(contactService:) forControlEvents:UIControlEventTouchUpInside];
    _serviceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _serviceButton.titleLabel.minimumScaleFactor = 0.5;
    [backgroundView addSubview:_serviceButton];
    _progressLab = [[UILabel alloc]initWithFrame:CGRectMake(AD(80), AD(7), _window_width - AD(40)-AD(160), AD(12))];
    _progressLab.font = [UIFont systemFontOfSize:12];
    _progressLab.textColor = [UIColor whiteColor];
    _progressLab.textAlignment = NSTextAlignmentCenter;
    _progressLab.text = @"";
    [backgroundView addSubview:_progressLab];
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(AD(30), AD(27), _window_width - AD(40)-AD(60),AD(10))];
    _progressView.progressTintColor = RGB_COLOR(@"#FF693C", 1);
    _progressView.progress = 0;
    _progressView.layer.masksToBounds = YES;
    _progressView.layer.cornerRadius = AD(2);
    _progressView.layer.masksToBounds=YES;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    self.progressView.transform = transform;//设定宽高
    self.progressView.contentMode = UIViewContentModeScaleAspectFill;
    [backgroundView addSubview:_progressView];
    _versionLab = [[UILabel alloc]initWithFrame:CGRectMake(AD(80), AD(39), _window_width - AD(40)-AD(160), AD(12))];
    _versionLab.font =[UIFont systemFontOfSize:12];
    _versionLab.textColor = [UIColor whiteColor];
    _versionLab.textAlignment =NSTextAlignmentCenter;
    _versionLab.text = [NSString stringWithFormat:@"V%@（%@）",APPVersionNumber,APP_BUILD];
    [backgroundView addSubview:_versionLab];
    _logButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _logButton.userInteractionEnabled = YES;
    _logButton.frame = CGRectMake((_window_width - AD(40) - AD(150))/2.0, AD(51), AD(150), AD(20));
    [_logButton setTitle:YZMsg(@"launchAppP_logscopy") forState:UIControlStateNormal];
    _logButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_logButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_logButton addTarget:self action:@selector(copyLog:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:_logButton];
}

- (void)copyLog:(UIButton *)sender{
    NSString *logsStr = self.logString;
    if(logsStr != nil && logsStr.length>0){
        if(logsStr.length>1400){
            logsStr = [logsStr substringFromIndex:logsStr.length-1400];
        }
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
      
        pasteboard.string = logsStr;
        [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success") toView: [UIApplication sharedApplication].keyWindow ];
        
        [self.logAliyun PutContent:@"内容" value:self.logContentSt];
        // addLog第二个参数flush，是否立即发送，1代表立即发送，不设置时默认为0
        LogProducerResult res = [self.clientLog AddLog:self.logAliyun flush:0];
        if (res!= 0) {
            NSLog(@"日志发送失败");
        }
    }
}

- (NSData *)gzipDeflate:(NSString*)str
{
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)[compressed length] - strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

- (void)contactService:(UIButton *)sender{
    WeakSelf
    [common getServiceUrl:^(NSString *kefuUrl) {
        STRONGSELF
        if(strongSelf == nil){
            return;
        }
        NSString *serverUrl = kefuUrl;
        if(!serverUrl){
            serverUrl = [DomainManager sharedInstance].kefuServer;
        }
        serverUrl = [YBToolClass replaceUrlParams:serverUrl];
        webH5 *visitorClient = [[webH5 alloc]init];
        //    serverUrl = [serverUrl stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
        visitorClient.urls = serverUrl;
        UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
        returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
        [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
        [returnBtn addTarget:[YBToolClass sharedInstance] action:@selector(closeService:) forControlEvents:UIControlEventTouchUpInside];
        visitorClient.returnBtn = returnBtn;
        visitorClient.titles = YZMsg(@"activity_login_connectkefu1");
        UINavModalWebView * navController = [[UINavModalWebView alloc] initWithRootViewController:visitorClient];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        visitorClient.navigationItem.title = YZMsg(@"activity_login_connectkefu1");
        UIWindow *serviceWindow;
        if (![LaunchInitManager sharedInstance].serviceWindow) {
            serviceWindow = [[UIWindow alloc]init];
            [serviceWindow makeKeyAndVisible];
            serviceWindow.rootViewController = navController;
            serviceWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
            serviceWindow.rootViewController.view.userInteractionEnabled = YES;
            serviceWindow.windowLevel = UIWindowLevelAlert;
            serviceWindow.hidden = NO;
            serviceWindow.alpha = 1;
            [LaunchInitManager sharedInstance].serviceWindow = serviceWindow;
        }else{
            serviceWindow = [LaunchInitManager sharedInstance].serviceWindow;
            [serviceWindow makeKeyAndVisible];
            serviceWindow.rootViewController = navController;
            serviceWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
            serviceWindow.rootViewController.view.userInteractionEnabled = YES;
            serviceWindow.windowLevel = UIWindowLevelAlert;
            serviceWindow.hidden = NO;
            serviceWindow.alpha = 1;
        }
    }];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end

@interface LaunchInitManager()
@property(nonatomic,strong)UIWindow *window;
@end
@implementation LaunchInitManager
/** 单例类方法 */
static LaunchInitManager* manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[LaunchInitManager alloc]init];;
        }
    });
    return manager;
}
- (instancetype)init{
    if (self = [super init]) {
        //[self startMonitor];
        [self initWindow];
    }
    return self;
}
- (void)initWindow{
    _window = [[UIWindow alloc]init];
    [_window makeKeyAndVisible];
    _window.rootViewController = [LaunchInitViewController new];
    _window.rootViewController.view.backgroundColor = [UIColor clearColor];
    _window.rootViewController.view.userInteractionEnabled = YES;
    _window.windowLevel =UIWindowLevelAlert;
    _window.hidden = NO;
    _window.alpha = 1;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(successEnterApp) name:@"SuccessEnterAppNotification" object:nil];
}
BOOL isSuccessEnter = false;
- (void)startMonitor{
    WeakSelf
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:nil];
        STRONGSELF
        if (@available(iOS 14.5, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf begainStarApp];
            }];
            return;
        }
        [strongSelf begainStarApp];
        
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(void)begainStarApp{
    
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
    [[GrowingTracker sharedInstance] trackCustomEvent:@"login_3"];
#endif
    
    
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus<=0 ) {
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf begainStarApp];
        });
        return;
    }
    [self initSecurityDevice];
}

- (void)initSecurityDevice{
    
    
    [self initWangyi:^(BOOL success) {
        
    }];
    
    [self begainLaunch];
}
int numberOfseesiongetWangyi = 0;
-(void)initWangyi:(void (^)(BOOL success))callback{
    if([DeviceUUID uuidFromWangyiDevice]!= nil && [DeviceUUID uuidFromWangyiDevice].length>0){
        return;
    }
    [self wangyiCreateA:callback];
}
-(void)wangyiCreateA:(void (^)(BOOL success))callback{
    WeakSelf
    numberOfseesiongetWangyi++;
    [VKSupportUtil getNTESInit:[DomainManager sharedInstance].domainCode pid:yidunPJID block:^(int code, NSString *msg, NSString *content) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 200) {
            [strongSelf initWangyiToken:callback];
        }else{
            if (numberOfseesiongetWangyi<5) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf initWangyi:callback];
                });
            }else{
                if(callback){
                    callback(false);
                }
            }
        }
    }];
}

int numberOfseesiongetWangyiToken = 0;
-(void)initWangyiToken:(void (^)(BOOL success))callback{
    numberOfseesiongetWangyiToken++;
    WeakSelf
    [VKSupportUtil getNTESToken:yidunToken timeout:3000 block:^(int code, NSString *token) {
        dispatch_main_async_safe(^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 200) {
                strongSelf.wangyiToken = token;
                if(callback){
                    callback(YES);
                }
            }if (code == 201) {
                [strongSelf wangyiCreateA:^(BOOL success) {
                    [strongSelf initWangyiToken:callback];
                }];
            }else{
                if (numberOfseesiongetWangyiToken<5) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf initWangyiToken:callback];
                    });
                }else{
                    if(callback){
                        callback(false);
                    }
                }
            }
        });
        
    }];
    
}


-(void)begainLaunch{
    [self startProcess];
    dispatch_main_async_safe(^{
        LaunchInitViewController *vcStart;
        if ([self.window.rootViewController isKindOfClass:[LaunchInitViewController class]]) {
            vcStart = (LaunchInitViewController *)self.window.rootViewController;
        }
        WeakSelf
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
        [[GrowingTracker sharedInstance] trackCustomEvent:@"login_4"];
#endif
        [[DomainManager sharedInstance] getHostCallback:^(NSString *bestDomain) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
            [[GrowingTracker sharedInstance] trackCustomEvent:@"login_5"];
#endif
            if (vcStart!= nil) {
                [vcStart.logAliyun PutContent:@"内容" value:vcStart.logContentSt];
                [vcStart.clientLog AddLog:vcStart.logAliyun flush:0];
                
            }
            dispatch_main_async_safe(^{
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf successEnterApp];
            });
            
        } logs:^(NSString *logstring) {
            
        }];
        
        
    });
}
-(void)successEnterApp{
    if (isSuccessEnter) {
        return;
    }
    isSuccessEnter = true;
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
    [[GrowingTracker sharedInstance] trackCustomEvent:@"login_6"];
#endif
    
    if ([Config getOwnID]) {
        [[DomainManager sharedInstance]loadCacheHomeRecommand:^(NSString *hostStr) {
           
        }];
    }
    
    [HHTools shareInstance].hostUrl = [NSString stringWithFormat:@"%@%@",[[DomainManager sharedInstance].domainGetString stringByReplacingOccurrencesOfString:serverVersion withString:@""],@"/op"];
    [[HHTrace shareInstance] putContentLog:[@"没开代理，准备加载渠道" stringByAppendingString:[HHTools shareInstance].hostUrl]];
    WeakSelf
    [StartGetHHTrace getInstallTrace:^(HHTraceData * _Nullable traceData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        [UMConfigure initWithAppkey:umengKey channel:[PublicObj checkNull:traceData.channel]?[DomainManager sharedInstance].domainCode:traceData.channel];
        
        [[HHTrace shareInstance] putContentLog:[@"渠道加载完成" stringByAppendingString:traceData.channel]];
        [strongSelf successEnterAppGetConifg];
    } :^(NSString * _Nonnull failString) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        [UMConfigure initWithAppkey:umengKey channel:[DomainManager sharedInstance].domainCode];
        [[HHTrace shareInstance] putContentLog:[@"渠道加载失败" stringByAppendingString:failString]];
        [strongSelf successEnterAppGetConifg];
    }];
    
    
    
}


-(void)successEnterAppGetConifg
{
    WeakSelf
    [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
        STRONGSELF
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (strongSelf == nil) {
                return;
            }
        dispatch_main_async_safe((^{
            [strongSelf scueessGetConfigCallback];
        }));
            
        });
    }];
}

-(void)scueessGetConfigCallback
{
    [HHTrace reportInstallTrace:^(HHTraceData * _Nullable traceData) {
        
    } :^(NSString * _Nonnull failString) {
        
    }];
    

        MXBADelegate *delegate =[MXBADelegate sharedAppDelegate];
        LaunchInitViewController *root = (LaunchInitViewController *)self.window.rootViewController;
        root.logString = [NSString stringWithFormat:@"%@\n%@",root.logString,YZMsg(@"launchAppP_islauching")];
        [root updateProcess:1 tip:YZMsg(@"launchAppP_islauching")];
        if ([Config getOwnID]) {
            WeakSelf
            [[MXBADelegate sharedAppDelegate] getAppConfig:^(NSString *errormsg, NSDictionary *json) {
                STRONGSELF
                if (!strongSelf) return;
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
                [[GrowingTracker sharedInstance] trackCustomEvent:@"login_7"];
#endif
                
                [strongSelf launchAd];
                root.logString = [NSString stringWithFormat:@"%@\n%@",root.logString,[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"10000"]];
                [root updateProcess:1 tip:[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"10000"]];
                [strongSelf loadHomePage];
            }];
        }else{
            root.logString = [NSString stringWithFormat:@"%@\n%@",root.logString,[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"10001"]];
            [root updateProcess:1 tip:[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"10001"]];
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
            [[GrowingTracker sharedInstance] trackCustomEvent:@"login_8"];
#endif
            WeakSelf
            [[GuestLogin sharedInstance]loginWithGuest:^(BOOL success,NSString *errorMsg) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (success) {
                    [strongSelf launchAd];
                    root.logString = [NSString stringWithFormat:@"%@\n%@",root.logString,[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"20000"]];
                    [root updateProcess:1 tip:[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"20000"]];
                    [[DomainManager sharedInstance]loadCacheHomeRecommand:^(NSString *hostStr) {
                        [strongSelf loadHomePage];
                    }];
                    
                   
                  
                    
                }else{
                    [strongSelf launchAd];
                    //////////
                    root.logString = [NSString stringWithFormat:@"%@\n%@",root.logString,[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"00001"]];
                    [root updateProcess:1 tip:[YZMsg(@"launchAppP_islauching") stringByAppendingString:@"00001"]];
                    PhoneLoginVC *login = [[PhoneLoginVC alloc]initWithNibName:@"PhoneLoginVC" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
                    delegate.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:login];
                    [ delegate.window makeKeyAndVisible];
                    if (delegate.window.rootViewController.view.hidden) {
                        delegate.window.rootViewController.view.hidden = NO;
                    }
                    [strongSelf hiddenAndReleaseLaunchProcess];
                  
                    
                }
            }];
        }

    NSDictionary *dict = @{ @"eventType": @(1)};
    [MobClick event:@"home_launchAd_click" attributes:dict];
}

-(void)launchAd{
    MXBADelegate *delegate =[MXBADelegate sharedAppDelegate];
    NSArray *ad_list = [common ad_list];
    NSDictionary *adDic = nil;
    if(![ad_list isEqual:[NSNull null]] && ad_list.count > 0){
        for (NSDictionary *_ad in ad_list) {
            if([[_ad valueForKey:@"type"] isEqual:@"launch"]){
                adDic = _ad;
                break;
            }
        }
    }
    if (adDic!= nil) {
        NSString *asset = adDic[@"asset"];
        NSString *jump_url = adDic[@"jump_url"];
        NSString *jump_type = minstr(adDic[@"jump_type"]);//1 外部跳转 2 内部跳转
        NSString *stand_time_str = adDic[@"stand_time"];
        NSInteger stand_time = [stand_time_str integerValue];
        NSString *asset_type = adDic[@"asset_type"];
        //广告数据转模型
        LaunchAdModel *model = [[LaunchAdModel alloc] initWithDict:@{
            @"content":asset?asset:@"",
            @"openUrl":jump_url?jump_url:@"",
            @"duration":minnum(stand_time),
            @"asset_type":asset_type?asset_type:@"",
            @"contentSize":[NSString stringWithFormat:@"%f*%f",_window_width, _window_height],
            @"jump_type":jump_type?jump_type:@""
        }];
    
        [delegate showLaunchAdWithModel:model];
    }else{
        [delegate showLaunchAdWithModel:nil];
    }
}

- (UIWindow*)showAndStartLaunchProcess{
    LaunchInitViewController *vc;
    if (!_window) {
        _window = [[UIWindow alloc]init];
        vc = [LaunchInitViewController new];
        _window.rootViewController = vc;
        _window.rootViewController.view.backgroundColor = [UIColor clearColor];
        _window.rootViewController.view.userInteractionEnabled = NO;
        _window.windowLevel = UIWindowLevelStatusBar + 2;
        _window.userInteractionEnabled = YES;
        _window.hidden = YES;
        _window.alpha = 1;
    }else{
        if ([_window.rootViewController isKindOfClass:[LaunchInitViewController class]]) {
            vc = (LaunchInitViewController *)_window.rootViewController;
        }
    }
    if (vc) {
        _window.hidden = NO;
        //        [vc startProcess];
    }
    return _window;
}
-(void)startProcess{
    dispatch_main_async_safe(^{
        if ([self.window.rootViewController isKindOfClass:[LaunchInitViewController class]]) {
            LaunchInitViewController *vc = (LaunchInitViewController *)self.window.rootViewController;
            [vc startProcess];
        }
    });
}

- (void)hiddenAndReleaseLaunchProcess{
   
    if (self.window.rootViewController) {
        self.window.rootViewController = nil;
    }
    self.window.hidden = YES;
    self.window.rootViewController = nil;
    self.window = nil;
   
    
}

-(void)loadHomePage{
    if ([DomainManager sharedInstance].isFinishedLoadHomePageData||[common getHomeRecommendData].count>0) {
        MXBADelegate *delegate =[MXBADelegate sharedAppDelegate];
        delegate.window.rootViewController = [ZYTabBarController new];
        [ delegate.window makeKeyAndVisible];
        if (delegate.window.rootViewController.view.hidden) {
            delegate.window.rootViewController.view.hidden = NO;
        }
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.window.rootViewController) {
                strongSelf.window.rootViewController = nil;
            }
            strongSelf.window.hidden = YES;
            strongSelf.window.rootViewController = nil;
            strongSelf.window = nil;
        });
        
    }else{
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf loadHomePage];
        });
    }
   
    
}
@end
