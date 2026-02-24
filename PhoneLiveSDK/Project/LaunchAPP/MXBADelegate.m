//
//  MXBADelegate.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//
#import "MXBADelegate.h"
//#import "AppDelegate.h"
#import "TCNavigationController.h"
#import "YBUserInfoViewController.h"
#import "WMZDialog.h"
#import "KTVHTTPCache.h"
#if !TARGET_IPHONE_SIMULATOR
#import <CorgiGameSDK.h>
#endif
/******shark sdk *********/
//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
//#import <TencentOpenAPI/TencentOAuth.h>
//#import <TencentOpenAPI/QQApiInterface.h>
#import <SafariServices/SafariServices.h>
#import "FMBackModeManager.h"
#import "HotAndAttentionPreviewLogic.h"
#import "HHTools.h"
#import "CacheImageKey.h"
//微信SDK头文件
//#import "LivePlay.h"
/******shark sdk  end*********/
//#import <WXApi.h>
//#import <AlipaySDK/AlipaySDK.h>
#import "PhoneLoginVC.h"
#import "ZYTabBarController.h"
#import "EBBannerView.h"
#import "webH5.h"
#import "h5game.h"
#import "YBUserInfoViewController.h"
#import "SDImageCache.h"

#if !TARGET_IPHONE_SIMULATOR
#import "GrowingTracker.h"
#endif

//#import <Bugly/Bugly.h>
#import "MNFloatBtn.h"
// 开屏页
#import "XHLaunchAd.h"
#import "LaunchAdModel.h"

#import "myPopularizeVC.h"
#import "PayViewController.h"
#import "LobbyLotteryVC.h"
//#import <AppsFlyerLib/AppsFlyerTracker.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "DomainManager.h"
#import "NSString+Extention.h"
#import "LSSafeProtector.h"
#import "LaunchInitManager.h"
#import "LivePlayTableVC.h"

#import "LiveEncodeCommon.h"
#import <UMCommon/UMCommon.h>
#import "SDWebImageError.h"

#import "VKSupportUtil.h"
//#import <AppsFlyerLib/AppsFlyerLib.h>

@interface MXBADelegate ()<XHLaunchAdDelegate,SDWebImageManagerDelegate
#if !TARGET_IPHONE_SIMULATOR
,CorgiGameDelegate
#endif
>
{

    UIButton *_touchButton;
    UIView* _loginView;
    __block UIBackgroundTaskIdentifier backgroundUpdateTask;
    WMZDialog *myAlert; // 普通更新弹窗实例
    WMZDialog *forceAlert; // 强制更新弹窗实例
}

@property(nonatomic,strong)NSArray *scrollarrays;//轮播

@property(nonatomic,strong)NSDictionary *appConifgDic;

@end

@implementation MXBADelegate

static MXBADelegate *instance = nil;
+ (instancetype _Nullable)sharedAppDelegate
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[MXBADelegate alloc] init];
    });
    return instance;
}

static int launchADCount = 0;

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    [self configAppearance];
//    return YES;
//}
-(void)initSDK{
    
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(application:didFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(application:openURL:sourceApplication:annotation:) name:UIApplicationOpenURLOptionsSourceApplicationKey object:nil];
    [self setupSDImageCache];
#if !TARGET_IPHONE_SIMULATOR
    [CorgiGameSDK initWithDelegate:self];
#endif
    
#ifdef DEBUG
//    [LSSafeProtector openSafeProtectorWithIsDebug:NO block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
////        [Bugly reportExceptionWithCategory:3 name:exception.name reason:[NSString stringWithFormat:@"%@  崩溃位置:%@",exception.reason,exception.userInfo[@"location"]] callStack:@[exception.userInfo[@"callStackSymbols"]] extraInfo:exception.userInfo terminateApp:NO];
//
//
//        }];
//    [LSSafeProtector setLogEnable:NO];
#else
//    [LSSafeProtector openSafeProtectorWithIsDebug:NO block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
////        [Bugly reportException:exception];
////        [[NSNotificationCenter defaultCenter] postNotificationName:@"shajincheng" object:nil];
//    }];
//    [LSSafeProtector setLogEnable:NO];
    

    
#endif
    
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
    GrowingTrackConfiguration *configuration = [GrowingTrackConfiguration configurationWithProjectId:growingKey];
    configuration.dataCollectionServerHost = @"";
    configuration.dataSourceId = @"ios";
    configuration.urlScheme = @"com.tata.live";
    [GrowingTracker startWithConfiguration:configuration launchOptions:@{@"key":@"ios"}];
    
    
#endif

    [UMConfigure initWithAppkey:umengKey channel:[DomainManager sharedInstance].domainCode];
//    NSString *appsFlyerId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppsFlyerID"];
//    NSString *appsFlyerkey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppsFlyerKey"];
//    if (appsFlyerkey!= nil && appsFlyerkey.length>0 && appsFlyerId!= nil && appsFlyerId.length>0) {
//        [[AppsFlyerLib shared] setAppsFlyerDevKey:appsFlyerkey];
//        [[AppsFlyerLib shared] setAppleAppID:appsFlyerId];
//        [[AppsFlyerLib shared] waitForATTUserAuthorizationWithTimeoutInterval:60];
//    }
   
//    [Bugly startWithAppId:@"44555816cb"];
//    [Bugly setTag:[ios_buildVersion integerValue]];
    [[RookieTools shareInstance] languageChange];
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    [self setupHTTPCache];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"faker_data_rate"];
#if !TARGET_IPHONE_SIMULATOR && !DEBUG
//    [Growing setEnableDiagnose:NO];
    [[GrowingTracker sharedInstance] trackCustomEvent:@"login_1"];
#endif
    
      [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;

      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLiveing"];
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPlaying"];

      self.window = [[UIWindow alloc]initWithFrame:CGRectMake(0,0,_window_width, _window_height)];

      //后台运行定时器
      UIApplication* app = [UIApplication sharedApplication];

    WeakSelf
    backgroundUpdateTask = [app beginBackgroundTaskWithExpirationHandler:^{
        // 当后台任务即将超时时，这个处理程序会被调用
        dispatch_main_async_safe(^{
              STRONGSELF
              if(strongSelf == nil){
                  return;
              }
              if (strongSelf->backgroundUpdateTask != UIBackgroundTaskInvalid)
              {
                  [app endBackgroundTask:strongSelf->backgroundUpdateTask]; // 正确结束任务
                  strongSelf->backgroundUpdateTask = UIBackgroundTaskInvalid;
              }
          });
      }];
      
      // 执行后台任务的代码
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          // 这里执行您需要在后台完成的工作
          // ...
          
          // 完成后，在主线程结束后台任务
          dispatch_main_async_safe(^{
              STRONGSELF
              if(strongSelf == nil){
                  return;
              }
              if (strongSelf->backgroundUpdateTask != UIBackgroundTaskInvalid)
              {
                  [app endBackgroundTask:strongSelf->backgroundUpdateTask]; // 正确结束任务
                  strongSelf->backgroundUpdateTask = UIBackgroundTaskInvalid;
              }
          });
      });
     
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bannerDidClick:) name:EBBannerViewDidClickNotification object:nil];
    [SDWebImageManager sharedManager].delegate = self;
    
    /// 图片缓存Key自定义
    SDWebImageManager.sharedManager.cacheKeyFilter = [SDWebImageCacheKeyFilter cacheKeyFilterWithBlock:^NSString * _Nullable(NSURL * _Nonnull url) {
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        return components.path;
    }];
    
    // 创建一个请求修改器
    id<SDWebImageDownloaderRequestModifier> requestModifier = [[SDWebImageDownloaderRequestModifier alloc] initWithBlock:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull request) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        if (request.URL.host && ![request.URL.host containsString:@"127.0.0"]) {
            if ([SkyShield shareInstance].dohLists && [SkyShield shareInstance].dohLists.count>0) {
                [mutableRequest addValue:mutableRequest.URL.host forHTTPHeaderField:@"Host"];
                NSString *requestUrlS = mutableRequest.URL.absoluteString;
                if (requestUrlS) {
                    NSString *replaceHostUrl = [[SkyShield shareInstance] replaceUrlHostToDNS:requestUrlS];
                    NSURL *domainURL1 = [NSURL URLWithString:replaceHostUrl];
                    if (domainURL1) {
                        mutableRequest.URL = domainURL1;
                    }
                }
            }
        }
        return mutableRequest;
    }];

    // 设置到下载器
    [[SDWebImageDownloader sharedDownloader] setRequestModifier:requestModifier];
    
}
- (void) endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: backgroundUpdateTask];
    backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (BOOL)imageManager:(nonnull SDWebImageManager *)imageManager shouldBlockFailedURL:(nonnull NSURL *)imageURL withError:(nonnull NSError *)error {
    BOOL shouldBlockFailedURL = false;
    // Filter the error domain and check error codes
    if ([error.domain isEqualToString:SDWebImageErrorDomain]) {
        shouldBlockFailedURL = (   error.code == SDWebImageErrorInvalidURL
                                || error.code == SDWebImageErrorBadImageData
                                || error.code == SDWebImageErrorInvalidDownloadStatusCode);
    } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
        shouldBlockFailedURL = (   error.code != NSURLErrorNotConnectedToInternet
                                && error.code != NSURLErrorCancelled
                                && error.code != NSURLErrorTimedOut
                                && error.code != NSURLErrorInternationalRoamingOff
                                && error.code != NSURLErrorDataNotAllowed
                                && error.code != NSURLErrorCannotFindHost
                                && error.code != NSURLErrorCannotConnectToHost
                                && error.code != NSURLErrorNetworkConnectionLost);
    } else {
        shouldBlockFailedURL = NO;
    }
    return shouldBlockFailedURL;
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    NSString *appsFlyerId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppsFlyerID"];
//    NSString *appsFlyerkey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppsFlyerKey"];
//    if (appsFlyerkey!= nil && appsFlyerkey.length>0 && appsFlyerId!= nil && appsFlyerId.length>0) {
//        [[AppsFlyerLib shared] startWithCompletionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
//            NSLog(@"");
//        }];
//        [AppsFlyerLib shared].isDebug = true;
//    }
//   
}



- (void)setupSDImageCache {
    // 获取默认的 SDImageCache 实例
    
    SDImageCache *imageCache = [[SDImageCache alloc] init];

    // 设置最大缓存大小（以字节为单位），例如 100MB
    imageCache.config.maxDiskSize = 300 * 1024 * 1024;

    // 设置缓存的最大保存天数，超出这个时间的缓存将被删除
    imageCache.config.maxDiskAge = 7 * 24 * 60 * 60; // 7天

    // 设置内存缓存的大小，默认是没有限制的
    imageCache.config.maxMemoryCost = 550 * 1024 * 1024; // 50MB

    // 设置缓存清理策略，例如后台模式下自动清理过期的缓存
    imageCache.config.shouldCacheImagesInMemory = YES;
    imageCache.config.shouldUseWeakMemoryCache = NO;

    // 设置是否在应用进入后台时自动清理过期缓存
    imageCache.config.shouldRemoveExpiredDataWhenEnterBackground = YES;

    // 设置在接收内存警告时是否清除内存缓存
    imageCache.config.shouldRemoveExpiredDataWhenTerminate = YES;
    
    SDWebImageDownloaderConfig.defaultDownloaderConfig.maxConcurrentDownloads = 20;
    
    SDWebImageDownloaderConfig.defaultDownloaderConfig.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    

}



-(void)getConfig:(BOOL)checkVersion complete:(void (^_Nullable)(NSString * _Nullable errormsg))callback
{
    NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
    [pDic setValue: [NSString stringWithFormat:@"%@(%@)",APPVersionNumber,ios_buildVersion] forKey:@"version"];
    
    [pDic setValue:[NSString stringWithFormat:@"NodePackage_%@",[[NSBundle mainBundle] bundleIdentifier]]  forKey:@"package_name"];
    WeakSelf
    [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 10;
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getConfig" withBaseDomian:YES andParameter:pDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            NSDictionary *subdic = [info firstObject];
            [LiveEncodeCommon sharedInstance].isOpenEncode = [[subdic objectForKey:@"open_stream_encrypt"] boolValue];
//            [LiveEncodeCommon sharedInstance].isOpenEncodeSDK = [[subdic objectForKey:@"open_SDK_encrypt"] boolValue];
            [LiveEncodeCommon sharedInstance].isOpenEncodeSDK = YES;
            [LiveEncodeCommon sharedInstance].live_resolution = [ResolutionModel mj_objectWithKeyValues:[subdic objectForKey:@"live_resolution"]];
            [LiveEncodeCommon sharedInstance].show_lottery_profit_rank = [[subdic objectForKey:@"show_lottery_profit_rank"] boolValue];
            if (![subdic isEqual:[NSNull null]]) {
                liveCommon *commons = [[liveCommon alloc]initWithDic:subdic];
                [common saveProfile:commons];
            }
            [common closeGameShield:![[subdic objectForKey:@"openSkyShield"] boolValue]];
            
            [common setFuckActivity:[[subdic objectForKey:@"fuckactivity"] boolValue]];
            
            if ([[subdic objectForKey:@"ad_list"] isKindOfClass:[NSArray class]]) {
                [common save_ad_list:[subdic objectForKey:@"ad_list"]];
            }
            
            if ([[subdic objectForKey:@"loginTypes"] isKindOfClass:[NSArray class]]) {
                [common saveLoginTypes:[subdic objectForKey:@"loginTypes"]];
            }
            
            // 缓存客服地址
            if ([subdic isKindOfClass:[NSDictionary class]]) {
                NSArray *extensionPages = [subdic objectForKey:@"ExtensionPage"];
                [common saveExtensionPage:extensionPages];
              
//                NSString *chat_service_url = [subdic objectForKey:@"chat_service_url"];
//                [common saveServiceUrl:chat_service_url];
                NSDictionary * dict = [subdic objectForKey:@"region_exchange_info"];
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    LiveUser * user = [Config myProfile];
                    user.region_id = dict[@"id"];
                    user.region = dict[@"region"];
                    user.region_curreny = dict[@"region_curreny"];
                    user.region_curreny_char = dict[@"region_curreny_char"];
                    user.exchange_rate = dict[@"exchange_rate"];
                    [Config updateProfile:user];
                }
               
            }
        
            NSString *opString = [subdic objectForKey:@"op_domain"];
            if ([opString isKindOfClass:[NSString class]] && opString && opString.length>0) {
                [HHTools shareInstance].hostUrl =[NSString stringWithFormat:@"%@/op",[subdic objectForKey:@"op_domain"]];
            }
            NSString *redBagDes = subdic[@"default_sendred_des"];
            [common saveRedBagDes:redBagDes];
            [YBToolClass sharedInstance].decrypt_sdk_key = [subdic objectForKey:@"decrypt_sdk_key"];
            [YBToolClass sharedInstance].nplayer = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
            
            NSString *defaul_old_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_old_view"];
            if (defaul_old_view== nil) {
                [YBToolClass sharedInstance].default_old_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_old_view"];
            }else{
                [YBToolClass sharedInstance].default_old_view = [defaul_old_view boolValue];
            }
            
            NSString *default_oldZP_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldZP_view"];
            if (default_oldZP_view== nil) {
                [YBToolClass sharedInstance].default_oldZP_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldZP_view"];
            }else{
                [YBToolClass sharedInstance].default_oldZP_view = [default_oldZP_view boolValue];
            }
            
            NSString *default_oldLH_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldLH_view"];
            if (default_oldLH_view== nil) {
                [YBToolClass sharedInstance].default_oldLH_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldLH_view"];
            }else{
                [YBToolClass sharedInstance].default_oldLH_view = [default_oldLH_view boolValue];
            }
            
            NSString *default_oldBJL_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldBJL_view"];
            if (default_oldBJL_view== nil) {
                [YBToolClass sharedInstance].default_oldBJL_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldBJL_view"];
            }else{
                [YBToolClass sharedInstance].default_oldBJL_view = [default_oldBJL_view boolValue];
            }
            
            NSString *default_oldZJH_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldZJH_view"];
            if (default_oldZJH_view== nil) {
                [YBToolClass sharedInstance].default_oldZJH_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldZJH_view"];
            }else{
                [YBToolClass sharedInstance].default_oldZJH_view = [default_oldZJH_view boolValue];
            }
            
            NSString *default_oldSC_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldSC_view"];
            if (default_oldSC_view== nil) {
                [YBToolClass sharedInstance].default_oldSC_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldSC_view"];
            }else{
                [YBToolClass sharedInstance].default_oldSC_view = [default_oldSC_view boolValue];
            }
            
            NSString *default_oldLHC_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldLHC_view"];
            if (default_oldLHC_view== nil) {
                [YBToolClass sharedInstance].default_oldLHC_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldLHC_view"];
            }else{
                [YBToolClass sharedInstance].default_oldLHC_view = [default_oldLHC_view boolValue];
            }
            
            NSString *default_oldSSC_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldSSC_view"];
            if (default_oldSSC_view== nil) {
                [YBToolClass sharedInstance].default_oldSSC_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldSSC_view"];
            }else{
                [YBToolClass sharedInstance].default_oldSSC_view = [default_oldSSC_view boolValue];
            }
            
            NSString *default_oldNN_view = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_oldNN_view"];
            if (default_oldNN_view== nil) {
                [YBToolClass sharedInstance].default_oldNN_view = [[subdic objectForKey:@"default_old_view"] boolValue];
                [[NSUserDefaults standardUserDefaults] setObject:[subdic objectForKey:@"default_old_view"] forKey:@"default_oldNN_view"];
            }else{
                [YBToolClass sharedInstance].default_oldNN_view = [default_oldNN_view boolValue];
            }
            
            //配置faker_data_rate
            NSInteger fakerDataRate = [(NSString *)[subdic objectForKey:@"faker_data_rate"] integerValue];
            [[NSUserDefaults standardUserDefaults] setInteger:fakerDataRate forKey:@"faker_data_rate"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            NSString *maintain_switch = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"maintain_switch"]];
            NSString *maintain_tips = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"maintain_tips"]];
            if ([maintain_switch isEqual:@"1"]) {
                UIAlertView *alertMaintain = [[UIAlertView alloc]initWithTitle:YZMsg(@"AppDelegate_Information_maintain") message:maintain_tips delegate:self cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil, nil];
                [alertMaintain show];
            }
           
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf==nil) {
                    return;
                }
                [strongSelf downloadAllLevelImage:[subdic valueForKey:@"level"]];
            });

            //接口请求完成发送通知
            if (callback) {
                callback(nil);
            }
          
        }else{
            if (callback) {
                callback(msg);
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"home.getconfig" object:nil];
    } fail:^(NSError * _Nonnull error) {
        if (callback) {
            callback(error.localizedDescription);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"home.getconfig" object:nil];
    }];
    
}
-(NSDictionary *_Nullable)getAppConfig:(void (^)(NSString * _Nullable errormsg, NSDictionary * _Nullable json))callback
{
    if (callback == nil) {
        if (_appConifgDic && [_appConifgDic isKindOfClass:[NSDictionary class]]) {
            if (_appConifgDic.allKeys.count>0) {
                return _appConifgDic;
            }
        }
        NSData *cachedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"home_config"];
        NSDictionary *cachedConfig = nil;
        if (cachedData) {
            cachedConfig = [NSJSONSerialization JSONObjectWithData:cachedData options:0 error:nil];
        } else {
            NSString *filePath = [[XBundle mainBundle] pathForResource:@"home_config" ofType:@"json"];
            NSData *localData = [NSData dataWithContentsOfFile:filePath];
            if (localData) {
                [[NSUserDefaults standardUserDefaults] setObject:localData forKey:@"home_config"];
                cachedConfig = [NSJSONSerialization JSONObjectWithData:localData options:0 error:nil];
            }
        }
        return cachedConfig;
    } else {
    
        WeakSelf
        [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 2;
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getAppConfig" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 20;
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                if (callback) {
                    NSDictionary *config = info;
                    strongSelf.appConifgDic = config;
                    if (strongSelf.appConifgDic && [strongSelf.appConifgDic isKindOfClass:[NSDictionary class]]) {
                        if (strongSelf.appConifgDic.allKeys.count>0) {
                            NSData *data = [NSJSONSerialization dataWithJSONObject:config options:0 error:nil];
                            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"home_config"];
                        }
                    }
                    callback(nil, info);
                }
            } else {
                if (callback) {
                    callback(msg, nil);
                }
            }
        } fail:^(NSError * _Nonnull error) {
            [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 20;
            if (error && [error isKindOfClass:[NSError class]]) {
                callback(error.description, nil);
            } else {
                callback(@"Home.getAppConfig fail", nil);
            }
        }];
        return nil;
    }
}




-(void)checkAppVersionWithHandle:(BOOL)Handle{
    
   
    WeakSelf
    [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 30;
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getForceUpdate" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            NSDictionary *subdic = [info firstObject];
            if (![subdic isEqual:[NSNull null]]) {
               
                NSString *currentAppVersion =  [NSString stringWithFormat:@"%@(tag%@)",APPVersionNumber,ios_buildVersion];
          
                NSString *ipa_ver = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_ver"]];
                NSString *ipa_url = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_url"]];
                NSString *ipa_des =[NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_des"]];
                NSString *ipa_force_ver = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_force_ver"]];
                NSString *ipa_handle_ver = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_handle_ver"]];
                NSString *ipa_latest_url = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_latest_url"]];
              
                
                // 首先检查是否需要强制更新
                BOOL needForceUpdate = [self needUpdateWithLocalVersion:currentAppVersion serverVersion:ipa_force_ver];
              
                if (needForceUpdate) {
                  
                    [self showForceUpdateDialog:ipa_ver ipa_des:ipa_des ipa_url:ipa_url];
                } else {
                    // 检查是否需要普通更新或手动更新
                    NSString *checkVersion = Handle ? ipa_handle_ver : ipa_ver;
                    BOOL needUpdate = [self needUpdateWithLocalVersion:currentAppVersion serverVersion:checkVersion];
                    
                    if (needUpdate) {
                       
                        [self showNormalUpdateDialog:checkVersion ipa_des:ipa_des ipa_url:(Handle?ipa_latest_url:ipa_url)];
                    }else if(Handle){
                        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"version_newversion_now")  preferredStyle:UIAlertControllerStyleAlert];
                      
                       
                        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                         
                            
                        }];
                        [alertContro addAction:sureAction];
                        dispatch_main_async_safe(^{
                            if (kWindow.rootViewController.presentedViewController == nil) {
                                [kWindow.rootViewController presentViewController:alertContro animated:YES completion:nil];
                            }
                            
                        })
                        
                    }
                }
               
            }else{
                [MBProgressHUD showMessage:msg];
            }
            
          
        }else{
            [MBProgressHUD showMessage:msg];
        }
      
    } fail:^(NSError * _Nonnull error) {
       
    }];
    
    
}

- (void)downloadAllLevelImage:(NSArray *)arr {
    // 使用全局并发队列而不是串行队列，提高下载效率
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    // 创建一个信号量来控制并发下载数量，避免同时发起太多请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(5); // 最多5个并发下载
    
    // 将整个下载过程放到后台线程
    dispatch_async(backgroundQueue, ^{
        // 创建一个操作组，用于等待所有下载完成
        dispatch_group_t downloadGroup = dispatch_group_create();
        
        for (NSDictionary *dic in arr) {
            // 等待信号量，控制并发数
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            // 进入下载组
            dispatch_group_enter(downloadGroup);
            
            NSString *imageUrl = minstr([dic valueForKey:@"thumb"]);
            if (imageUrl.length == 0) {
                // 如果URL为空，释放信号量并继续
                dispatch_semaphore_signal(semaphore);
                dispatch_group_leave(downloadGroup);
                continue;
            }
            
            SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
            [downloader downloadImageWithURL:[NSURL URLWithString:imageUrl]
                                     options:SDWebImageDownloaderLowPriority
                                    progress:nil
                                   completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                // 下载完成后释放信号量，允许下一个下载开始
                dispatch_semaphore_signal(semaphore);
                
                // 离开下载组
                dispatch_group_leave(downloadGroup);
            }];
        }
        
        // 等待所有下载完成，但设置超时时间为60秒
        dispatch_group_wait(downloadGroup, dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC));
        
        // 所有下载完成或超时后的操作（如果需要）
        dispatch_async(dispatch_get_main_queue(), ^{
            // 如果需要在主线程更新UI，可以在这里进行
            // 例如：通知下载完成等
        });
    });
}


-(void)showLaunchAdWithModel:(LaunchAdModel*)model
{
    if (model == nil) {
        return;
    }
   
    if (launchADCount!=0) {
        return;
    }
    launchADCount ++;
   
    
    if (model.asset_type && [model.asset_type isEqualToString:@"3"]) {//视频用m3u8实现，目前不支持
        //配置广告数据
        XHLaunchVideoAdConfiguration *videoAdconfiguration = [XHLaunchVideoAdConfiguration new];
        //广告停留时间
        videoAdconfiguration.duration = model.duration;
        //广告frame
        videoAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/model.width*model.height);
        //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        videoAdconfiguration.videoNameOrURLString = model.content;
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        videoAdconfiguration.openModel = model;
        //广告显示完成动画
        videoAdconfiguration.showFinishAnimate = ShowFinishAnimateFlipFromLeft;
        //广告显示完成动画时间
        videoAdconfiguration.showFinishAnimateTime = 0.8;
        //跳过按钮类型
        videoAdconfiguration.skipButtonType = SkipTypeTimeText;
        //后台返回时,是否显示广告
        videoAdconfiguration.showEnterForeground = NO;
        //显示开屏广告
        [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguration delegate:self];
    }else{
        //配置广告数据
        XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
        //广告停留时间
        imageAdconfiguration.duration = model.duration;
        //广告frame
        imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/model.width*model.height);
        //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        imageAdconfiguration.imageNameOrURLString = model.content;
        //设置GIF动图是否只循环播放一次(仅对动图设置有效)
        imageAdconfiguration.GIFImageCycleOnce = NO;
        //缓存机制(仅对网络图片有效)
        //为告展示效果更好,可设置为XHLaunchAdImageCacheInBackground,先缓存,下次显示
        imageAdconfiguration.imageOption = XHLaunchAdImageDefault;
        //图片填充模式
        imageAdconfiguration.contentMode = UIViewContentModeScaleToFill;
        //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
        imageAdconfiguration.openModel = model;
        //广告显示完成动画
        imageAdconfiguration.showFinishAnimate = ShowFinishAnimateFlipFromLeft;
        //广告显示完成动画时间
        imageAdconfiguration.showFinishAnimateTime = 0.8;
        //跳过按钮类型
        imageAdconfiguration.skipButtonType = SkipTypeTimeText;
        //后台返回时,是否显示广告
        imageAdconfiguration.showEnterForeground = NO;
        //显示开屏广告
        [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
    }
    
    
   
}
//杀进程
- (void)applicationWillTerminate:(UIApplication *)application{
    @try {
        [[SkyShield shareInstance] skyShield_stop];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shajincheng" object:nil];
        
        // 安全保存 DomainManager
        DomainManager *domainManager = [DomainManager sharedInstance];
        if (domainManager && ArchiveDomainsPath) {
            NSString *path = DocumentPath(ArchiveDomainsPath);
            if (path) {
                [NSKeyedArchiver archiveRootObject:domainManager toFile:path];
            }
        }
        
        // 安全保存 CacheImageKey
        CacheImageKey *cacheImageKey = [CacheImageKey sharedManager];
        if (cacheImageKey) {
            [cacheImageKey saveImageKeyCache];
        }
        
        [self endBackgroundUpdateTask];
    } @catch (NSException *exception) {
        NSLog(@"applicationWillTerminate exception: %@", exception);
    }
}
//- (void)application:(UIApplication *)application
//didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
////    [JMessage registerDeviceToken:deviceToken];
//    [JPUSHService registerDeviceToken:deviceToken];
//    //    NSString *aliasStr = [NSString stringWithFormat:@"%@PUSH",[Config getOwnID]];
//    //    [JPUSHService setAlias:aliasStr callbackSelector:nil object:nil];
//}
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)(void))completionHandler {
    
    if(application.applicationState == UIApplicationStateInactive)
    {
        if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"1"]) {
            
            if([[userInfo valueForKey:@"userinfo"] valueForKey:@"uid"] != nil)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"jinruzhibojiantongzhi" object:[userInfo valueForKey:@"userinfo"]];
            }
        }else if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"2"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"system_notification" object:nil];
        }
//        [JPUSHService handleRemoteNotification:userInfo];
    }
    
}
#endif
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
//    [JPUSHService handleRemoteNotification:userInfo];
    
    if(application.applicationState == UIApplicationStateInactive)
    {
        if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"1"]) {
            
            if([[userInfo valueForKey:@"userinfo"] valueForKey:@"uid"] != nil)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"jinruzhibojiantongzhi" object:[userInfo valueForKey:@"userinfo"]];
            }
        }else if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"2"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"system_notification" object:nil];
            
        }
        
//        [JPUSHService handleRemoteNotification:userInfo];
    }
    
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"system_notificationUpdate" object:nil];
    //极光推送 新加附加附加参数 type 消息类型  1表示开播通知，2表示系统消息
    //    [EBBannerView showWithContent:minstr([[userInfo valueForKey:@"aps"] valueForKey:@"alert"])];
    if (application.applicationState == UIApplicationStateActive) {
        if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"1"]) {
            if([[userInfo valueForKey:@"userinfo"] valueForKey:@"uid"] != nil)
            {
                [[EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
                    make.content = minstr([[userInfo valueForKey:@"aps"] valueForKey:@"alert"]);
                    make.object = [userInfo valueForKey:@"userinfo"];
                }] show];
            }
        }else if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"2"]) {
            [[EBBannerView bannerWithBlock:^(EBBannerViewMaker *make) {
                make.content = minstr([[userInfo valueForKey:@"aps"] valueForKey:@"alert"]);
                make.object = nil;
            }] show];
            
        }
    }else{
//        [JPUSHService handleRemoteNotification:userInfo];
        if(application.applicationState == UIApplicationStateInactive)
        {
            
            if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"1"]) {
                
                if([[userInfo valueForKey:@"userinfo"] valueForKey:@"uid"] != nil)
                {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLiveing"]) {
                        [MBProgressHUD showError:YZMsg(@"AppDelegate_Living")];
                        return;
                    }else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isPlaying"]) {
                        //[NSString stringWithFormat:@"是否进入%@的直播间",minstr([[userInfo valueForKey:@"userinfo"]valueForKey:@"user_nicename"])]
                        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"AppDelegate_ifCancelLiveRoom")  preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [alertContro addAction:cancleAction];
                        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"qiehuanfangjian" object:[userInfo valueForKey:@"userinfo"]];
                            
                        }];
                        [alertContro addAction:sureAction];
                        dispatch_main_async_safe(^{
                            if (kWindow.rootViewController.presentedViewController == nil) {
                                [kWindow.rootViewController presentViewController:alertContro animated:YES completion:nil];
                            }
                            
                        })
                        
                        
                        return;
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"jinruzhibojiantongzhi" object:[userInfo valueForKey:@"userinfo"]];
                    }
                    
                }
            } else if ([minstr([userInfo valueForKey:@"type"]) isEqual:@"2"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"system_notification" object:nil];
            }
//            [JPUSHService handleRemoteNotification:userInfo];
        }
        completionHandler(UIBackgroundFetchResultNewData);
        
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
//    application.applicationIconBadgeNumber = 0;
    [NSKeyedArchiver archiveRootObject:[DomainManager sharedInstance] toFile:DocumentPath(ArchiveDomainsPath)];
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
            
    }];
    [[FMBackModeManager shared] activeBackMode];
    [FMBackModeManager shared].soundActive = NO;
    
    [[CacheImageKey sharedManager]saveImageKeyCache];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
//挂起
- (void)applicationWillResignActive:(UIApplication*)application {
    DomainManager *sss = [DomainManager sharedInstance];
    if(sss){
        [NSKeyedArchiver archiveRootObject:sss toFile:DocumentPath(ArchiveDomainsPath)];
    }
    [[CacheImageKey sharedManager]saveImageKeyCache];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if([Config getOwnID]){
        [self localLockBecomeActive];
    }
    
    [[FMBackModeManager shared]invalidBackModel];
    DomainManager *sss = [DomainManager sharedInstance];
    if(sss){
        [NSKeyedArchiver archiveRootObject:sss toFile:DocumentPath(ArchiveDomainsPath)];
    }
    [[CacheImageKey sharedManager]saveImageKeyCache];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[SkyShield shareInstance] skyShield_restart];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateUnreadMessages" object:nil];
}
- (void)localLockBecomeActive {
    if ([VKSupportUtil isLocalGestureEnableForUserId:[Config getOwnID]]) {
        [VKSupportUtil showLockGesture:[Config getOwnID] type:FQLockTypeLogin isPush:NO];
    }
   
    
}

#pragma mark --- 支付宝接入
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{

#if !TARGET_IPHONE_SIMULATOR
    [CorgiGameSDK handLinkURL:url];
#endif
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//        }];
//        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//            // 解析 auth code
//            NSString *result = resultDic[@"result"];
//            NSString *authCode = nil;
//            if (result.length>0) {
//                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                for (NSString *subResult in resultArr) {
//                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
//                        authCode = [subResult substringFromIndex:10];
//                        break;
//                    }
//                }
//            }
//            NSLog(@"授权结果 authCode = %@", authCode?:@"");
//
//        }];
    }
    
    return YES;
}
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.isAutoDirection) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
#if !TARGET_IPHONE_SIMULATOR
    [CorgiGameSDK handLinkURL:url];
#endif
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//            
//        }];
//        // 授权跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//            // 解析 auth code
//            NSString *result = resultDic[@"result"];
//            NSString *authCode = nil;
//            if (result.length>0) {
//                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                for (NSString *subResult in resultArr) {
//                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
//                        authCode = [subResult substringFromIndex:10];
//                        break;
//                    }
//                }
//            }
//            NSLog(@"授权结果 authCode = %@", authCode?:@"");
//        }];
    }
    return YES;
}


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
#if !TARGET_IPHONE_SIMULATOR
    [CorgiGameSDK continueUserActivity:userActivity];
#endif
    return YES;//[WXApi handleOpenUniversalLink:userActivity delegate:self];
}



#pragma mark ================ 通知点击事件 ===============
- (void)bannerDidClick:(NSNotification *)notifi{
    NSDictionary *dic = [notifi object];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLiveing"]) {
        [MBProgressHUD showError:YZMsg(@"AppDelegate_Living")];
        return;
    }else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isPlaying"]) {
        
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"AppDelegate_ifCancelLiveRoom") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertContro addAction:cancleAction];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([dic count] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"jinruzhibojiantongzhi" object:dic];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"system_notification" object:nil];
                
            }
            
        }];
        [alertContro addAction:sureAction];
        if (kWindow.rootViewController.presentedViewController == nil) {
            [kWindow.rootViewController presentViewController:alertContro animated:YES completion:nil];
        }
        return;
    }else{
        if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"jinruzhibojiantongzhi" object:dic];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"system_notification" object:nil];
            
        }
    }
    
}

-(void)checkNetworkStatue
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus<=0) {
        self.alertetworkStatueControl = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"launchAppP_noNetwork") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [self.alertetworkStatueControl addAction:cancleAction];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:appSettings options:@{} completionHandler:nil];
            
        }];
        [self.alertetworkStatueControl addAction:sureAction];
        if (kWindow.rootViewController.presentedViewController == nil) {
            [kWindow.rootViewController presentViewController:self.alertetworkStatueControl animated:YES completion:nil];
        }
    }
}
#pragma mark - XHLaunchAdDelegate

- (BOOL)xhLaunchAd:(XHLaunchAd *)launchAd clickAtOpenModel:(nonnull id)openModel clickPoint:(CGPoint)clickPoint
{
    if (![openModel isKindOfClass:[LaunchAdModel class]] ) {
        return NO;
    }
    LaunchAdModel *model = openModel;
    
    if([model.openUrl length] > 0)
    {
        if ([model.jump_type isEqualToString:@"1"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.openUrl] options:@{} completionHandler:^(BOOL success) {
                
            }];
            return NO;
        }else{
            NSString *urlString = model.openUrl;
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
            NSError *error = nil;
            NSAttributedString *decodedAttributedString = [[NSAttributedString alloc] initWithData:data
                                                                                           options:options
                                                                                documentAttributes:nil
                                                                                             error:&error];
            if (error) {
                NSLog(@"Error parsing HTML: %@", error.localizedDescription);
                return YES;
            }
            NSString *url = decodedAttributedString.string;
            
            if (url.length >9) {
                webH5 *VC = [[webH5 alloc]init];
                url = [YBToolClass decodeReplaceUrl:url];
                VC.urls = url;
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
                return YES;
            }
        }
       
    }else{
        return NO;
    }
    return NO;
}


// 配置App中的控件的默认属性
- (void)configAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UILabel appearance] setBackgroundColor:[UIColor clearColor]];
    [[UILabel appearance] setTextColor:[UIColor blackColor]];
    [[UIButton appearance] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
// 获取当前活动的navigationcontroller
- (UINavigationController *)navigationViewController
{
    UIWindow *window = self.window;
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        return (UINavigationController *)window.rootViewController;
    }
    else if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController) selectedViewController];
        if ([selectVc isKindOfClass:[UINavigationController class]])
        {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

- (UINavigationController *)homeNavigationViewController {
    UIWindow *window = self.window;
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        return (UINavigationController *)window.rootViewController;
    }
    else if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController) viewControllers].firstObject;
        if ([selectVc isKindOfClass:[UINavigationController class]])
        {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

- (void)homePushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    @autoreleasepool
    {
        UIWindow *window = self.window;
        if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
            ((UITabBarController *)window.rootViewController).selectedIndex = 0;
        }
        viewController.hidesBottomBarWhenPushed = YES;
        [[self homeNavigationViewController] pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)topViewController
{
    UINavigationController *nav = [self navigationViewController];
    
    
    UIViewController *topViewController = [self topPresentedViewControllerFrom: nav.topViewController];
    return topViewController;
}

- (UIViewController *)topPresentedViewControllerFrom:(UIViewController *)viewController {
    // 遍历直到找到最顶部的视图控制器
    if (viewController.presentedViewController) {
        return [self topPresentedViewControllerFrom:viewController.presentedViewController];
    }
    // 如果没有 presented viewController，返回当前视图控制器
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        return navController.topViewController;
    }
    return viewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    @autoreleasepool
    {
        viewController.hidesBottomBarWhenPushed = YES;
        UIViewController *topVC = [self topViewController];
        if (topVC!= nil && topVC.navigationController) {
            [topVC.navigationController pushViewController:viewController animated:animated];
        }else{
            [[self navigationViewController] pushViewController:viewController animated:animated];
        }
     
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated hidesBottomBarWhenPushed:(BOOL)isHide
{
    @autoreleasepool
    {
        viewController.hidesBottomBarWhenPushed = isHide;
        UIViewController *topVC = [self topViewController];
        if (topVC!= nil && topVC.navigationController) {
            [topVC.navigationController pushViewController:viewController animated:animated];
        }else{
            [[self navigationViewController] pushViewController:viewController animated:animated];
        }
     
    }
}

- (void)pushViewController:(UIViewController *)viewController cell:(UIView * _Nullable)cell {
    TTCTransitionDelegate *delegate = [[TTCTransitionDelegate alloc] init];
    delegate.smalCurPlayCell = cell;
    if ([viewController isKindOfClass:[LivePlayTableVC class]]) {
        delegate.closeGestureDisable = YES;
    }
    viewController.ttcTransitionDelegate = delegate;
    [self pushViewController:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController cell:(UIView * _Nullable)cell hidesBottomBarWhenPushed:(BOOL)isHide {
    TTCTransitionDelegate *delegate = [[TTCTransitionDelegate alloc] init];
    delegate.smalCurPlayCell = cell;
    if ([viewController isKindOfClass:[LivePlayTableVC class]]) {
        delegate.closeGestureDisable = YES;
    }
    viewController.ttcTransitionDelegate = delegate;
    [self pushViewController:viewController animated:YES hidesBottomBarWhenPushed: isHide];
}

- (UIViewController *)popViewController:(BOOL)animated
{
    UIViewController *topVC = [self topViewController];
    if (topVC!= nil && topVC.navigationController) {
        return [topVC.navigationController popViewControllerAnimated:animated];
    }else{
        return [[self navigationViewController] popViewControllerAnimated:animated];
    }
    
   
}
- (NSArray *)popToRootViewController
{
    UIViewController *topVC = [self topViewController];
    if (topVC!= nil && topVC.navigationController) {
        return [topVC.navigationController popToRootViewControllerAnimated:NO];
    }else{
        return [[self navigationViewController] popToRootViewControllerAnimated:NO];
    }
}
- (NSArray *)popToViewController:(UIViewController *)viewController
{
    UIViewController *topVC = [self topViewController];
    if (topVC!= nil && topVC.navigationController) {
        return [topVC.navigationController popToViewController:viewController animated:NO];
    }else{
        return [[self navigationViewController] popToViewController:viewController animated:NO];
    }
}
- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    
    UIViewController *top = [self topViewController];
    if ([top isKindOfClass:[YBUserInfoViewController class]]) {
        [self presentViewControllerFromTabbar:vc animated:animated completion:completion];
    }else{
        [top presentViewController:vc animated:animated completion:completion];

    }
    
   
}

- (void)presentViewControllerFromTabbar:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIWindow *window = self.window;
   if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        [((UITabBarController *)window.rootViewController) presentViewController:vc animated:animated completion:completion];
    }else{
        UIViewController *top = [self topViewController];
        
        if (vc.navigationController == nil)
        {
            TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:vc];
            if (top.presentedViewController == nil) {
                [top presentViewController:nav animated:animated completion:completion];
            }
        }
        else
        {
            if (top.presentedViewController == nil) {
                [top presentViewController:vc animated:animated completion:completion];
            }
        }
    }
}

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (vc.navigationController != [MXBADelegate sharedAppDelegate].navigationViewController)
    {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self popViewController:animated];
    }
}


// 预加载游戏大厅图片
- (void)getGameInfo{
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getPlats&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray *  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        dispatch_queue_t downloadQueue = dispatch_queue_create("com.donwload.imageloader", DISPATCH_QUEUE_SERIAL);

        // 创建一个全局队列来处理图片加载
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        // 将整个处理过程移到后台线程
        dispatch_async(backgroundQueue, ^{
            NSInteger countMax = info.count;
            for (int i=0; i<countMax; i++) {
                NSDictionary *meunInfo = [info objectAtIndex:i];
                NSArray *subRootArray = meunInfo[@"sub"];
                for (int j=0; j<subRootArray.count; j++) {
                    NSDictionary *subRootInfo = [subRootArray objectAtIndex:j];
                    if([subRootInfo objectForKey:@"sub"]){
                        NSArray *subs = [subRootInfo objectForKey:@"sub"];
                        NSInteger subCount = subs.count;
                        for (int z=0; z<subCount; z++) {
                            NSDictionary *subInfo = [subs objectAtIndex:z];
                            NSString *urlImg = subInfo[@"urlName"];
                            
                            // 检查缓存是否存在的操作也放在后台线程
                            NSDictionary *oldImgD = [CacheImageKey sharedManager].gameheightDic;
                            if (oldImgD!=nil && [oldImgD objectForKey:urlImg]!=nil) {
                                continue; // 使用continue而不是return，这样可以继续处理其他图片
                            }
                            
                            // 使用信号量控制并发数量，避免同时发起太多请求
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            
                            SDWebImageManager *manager = [SDWebImageManager sharedManager];
                            [manager loadImageWithURL:[NSURL URLWithString:urlImg]
                                              options:0
                                             progress:nil
                                            completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image && imageURL) {
                                    // 更新缓存的操作需要同步到主线程
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSDictionary *storedDict = [CacheImageKey sharedManager].gameheightDic;
                                        NSMutableDictionary *heightCellDic;
                                        if (storedDict) {
                                            heightCellDic = [storedDict mutableCopy];
                                        } else {
                                            heightCellDic = [NSMutableDictionary dictionary];
                                        }
                                        NSString *sizeString = NSStringFromCGSize(image.size);
                                        [heightCellDic setObject:sizeString forKey:imageURL.absoluteString];
                                        NSDictionary *dictToStore = [heightCellDic copy];
                                        [CacheImageKey sharedManager].gameheightDic = dictToStore;
                                    });
                                }
                                // 释放信号量，允许处理下一个请求
                                dispatch_semaphore_signal(semaphore);
                            }];
                            
                            // 等待当前请求完成后再继续，避免同时发起太多请求
                            // 设置超时时间为3秒，防止某个请求卡住整个流程
                            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
                        }
                    }
                }
            }
        });
    } fail:^(NSError * _Nonnull error) {
        
    }];
}

- (void)setupHTTPCache
{
    // 设置代理端口
    [KTVHTTPCache proxySetPort:23345];
    
    // 设置是否启用控制台日志
    [KTVHTTPCache logSetConsoleLogEnable:NO]; // 开发环境可以启用日志

    // 启动代理服务
    NSError *error = nil;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    } else {
        NSLog(@"Proxy Start Success");
    }

    // 设置 URL 转换器
    [KTVHTTPCache encodeSetURLConverter:^NSURL *(NSURL *URL) {
        // 在这里可以对 URL 进行进一步处理
        NSLog(@"URL Filter received URL : %@", URL);
        // 返回处理后的 URL
        return URL;
    }];

    // 设置不接受的内容类型处理
    [KTVHTTPCache downloadSetUnacceptableContentTypeDisposer:^BOOL(NSURL *URL, NSString *contentType) {
        // 根据内容类型过滤不需要的请求
        NSLog(@"Unsupported Content-Type Filter received URL : %@, %@", URL, contentType);
        return YES; // 返回 YES 以允许缓存该内容，返回 NO 以阻止缓存
    }];

    // 配置缓存路径和大小
    [KTVHTTPCache cacheSetMaxCacheLength:1024 * 1024 * 1024]; // 1 GB

    // 定期清理缓存（示例代码，实际清理逻辑可根据需要实现）
    [NSTimer scheduledTimerWithTimeInterval:3600 // 每小时清理一次
                                     target:self
                                   selector:@selector(clearCache)
                                   userInfo:nil
                                    repeats:YES];
}

// 清理缓存的方法
- (void)clearCache {
//    [KTVHTTPCache cacheClearAllData]; // 清理所有缓存数据
}

#pragma mark - 版本更新相关方法

// 判断是否需要更新
- (BOOL)needUpdateWithLocalVersion:(NSString *)localVersion serverVersion:(NSString *)serverVersion {
    if (serverVersion.length == 0) {
        return NO;
    }
    
    // 提取本地版本号和编译版本号
    NSString *localAppVersion = nil;
    NSString *localBuildVersion = nil;
    
    NSRange tagRange = [localVersion rangeOfString:@"(tag"];
    if (tagRange.location != NSNotFound) {
        localAppVersion = [localVersion substringToIndex:tagRange.location];
        NSString *tagPart = [localVersion substringFromIndex:tagRange.location + 4]; // 4是"(tag"的长度
        localBuildVersion = [tagPart substringToIndex:tagPart.length - 1]; // 去掉最后的括号
    } else {
        localAppVersion = localVersion;
    }
    
    // 提取服务器版本号和编译版本号
    NSString *serverAppVersion = nil;
    NSString *serverBuildVersion = nil;
    
    tagRange = [serverVersion rangeOfString:@"(tag"];
    if (tagRange.location != NSNotFound) {
        serverAppVersion = [serverVersion substringToIndex:tagRange.location];
        NSString *tagPart = [serverVersion substringFromIndex:tagRange.location + 4]; // 4是"(tag"的长度
        serverBuildVersion = [tagPart substringToIndex:tagPart.length - 1]; // 去掉最后的括号
    } else {
        serverAppVersion = serverVersion;
    }
    
    // 比较版本号
    NSComparisonResult versionResult = [self compareVersions:localAppVersion with:serverAppVersion];
    
    if (versionResult == NSOrderedAscending) {
        // 本地版本号小于服务器版本号，需要更新
        return YES;
    } else if (versionResult == NSOrderedSame && serverBuildVersion != nil && localBuildVersion != nil) {
        // 版本号相同，比较编译版本号
        NSInteger localBuild = [localBuildVersion integerValue];
        NSInteger serverBuild = [serverBuildVersion integerValue];
        return localBuild < serverBuild;
    }
    
    return NO;
}

// 比较两个版本号
- (NSComparisonResult)compareVersions:(NSString *)version1 with:(NSString *)version2 {
    // 将版本号分割为组件
    NSArray *components1 = [version1 componentsSeparatedByString:@"."];
    NSArray *components2 = [version2 componentsSeparatedByString:@"."];
    
    // 获取最长的组件数量
    NSUInteger maxLength = MAX(components1.count, components2.count);
    
    // 逐个比较组件
    for (NSUInteger i = 0; i < maxLength; i++) {
        NSInteger v1 = (i < components1.count) ? [components1[i] integerValue] : 0;
        NSInteger v2 = (i < components2.count) ? [components2[i] integerValue] : 0;
        
        if (v1 < v2) {
            return NSOrderedAscending;
        } else if (v1 > v2) {
            return NSOrderedDescending;
        }
    }
    
    return NSOrderedSame;
}

// 显示强制更新弹窗
- (void)showForceUpdateDialog:(NSString *)version ipa_des:(NSString *)ipa_des ipa_url:(NSString *)ipa_url {
 
    WeakSelf
    // 如果已经有强制更新弹窗在显示，则不再显示新的弹窗
    if (forceAlert) {
        return;
    }
    
  
    forceAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    .wEventOKFinishSet(^(id anyID, id otherData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        // 点击更新按钮
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ipa_url] options:@{} completionHandler:^(BOOL success) {
            // 强制更新不关闭弹窗
        }];
    })
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        // 标题
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLabel.text = [NSString stringWithFormat:@"%@V:%@",YZMsg(@"version_newversion_title"), version];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame = CGRectMake(15, 15, mainView.frame.size.width - 30, 30);
        [mainView addSubview:titleLabel];
        
        // 内容滚动视图
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 10, mainView.frame.size.width - 30, 200)];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        [mainView addSubview:scrollView];
        
        // 内容文本
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, 0)];
        textView.editable = NO;
        textView.scrollEnabled = NO; // 禁用文本视图的滚动，使用外部的scrollView滚动
        textView.textAlignment = NSTextAlignmentLeft;
        textView.font = [UIFont systemFontOfSize:15.0f];
        
        // 尝试将XML内容转换为富文本
        NSAttributedString *attributedString = nil;
        NSError *error = nil;
        NSData *data = [ipa_des dataUsingEncoding:NSUTF8StringEncoding];
        
        if ([ipa_des containsString:@"<"] && [ipa_des containsString:@">"]) {
            // 尝试解析XML/HTML
            attributedString = [[NSAttributedString alloc] initWithData:data
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                     documentAttributes:nil
                                                                  error:&error];
        }
        
        if (attributedString == nil || error) {
            // 如果解析失败，则使用纯文本
            textView.text = ipa_des;
        } else {
            textView.attributedText = attributedString;
        }
        
        // 计算文本高度
        CGSize size = [textView sizeThatFits:CGSizeMake(scrollView.frame.size.width, CGFLOAT_MAX)];
        textView.frame = CGRectMake(0, 0, scrollView.frame.size.width, size.height);
        
        // 设置滚动视图的内容大小
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, size.height);
        [scrollView addSubview:textView];
        
        // 调整滚动视图高度
        CGFloat scrollViewHeight = MIN(size.height, 200); // 最大高度为200
        scrollViewHeight = MAX(scrollViewHeight, 100); // 最小高度为100
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollViewHeight);
        
        // 更新按钮
        UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [updateButton setTitle:YZMsg(@"AppDelegate_GoUpdate") forState:UIControlStateNormal];
        updateButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        updateButton.frame = CGRectMake(15, CGRectGetMaxY(scrollView.frame) + 20, mainView.frame.size.width - 30, 44);
        updateButton.layer.cornerRadius = 5;
        updateButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [updateButton addTarget:self action:@selector(forceUpdateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        updateButton.tag = 1000; // 用于保存URL
        objc_setAssociatedObject(updateButton, "update_url", ipa_url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [mainView addSubview:updateButton];
        
        // 调整主视图大小
        CGRect frame = mainView.frame;
        frame.size.height = CGRectGetMaxY(updateButton.frame) + 20;
        mainView.frame = frame;
        
        return mainView;
    })

    .wAutoCloseSet(NO) // 强制更新不允许关闭
    .wShowCloseSet(NO) // 不显示关闭按钮
    .wStartView([MXBADelegate sharedAppDelegate].topViewController.view);
}

// 显示普通更新弹窗
- (void)showNormalUpdateDialog:(NSString *)version ipa_des:(NSString *)ipa_des ipa_url:(NSString *)ipa_url {
   
    WeakSelf
    // 如果已经有普通更新弹窗在显示，则先关闭它
    if (myAlert) {
       
        [myAlert closeView];
        myAlert = nil;
    }
    
  
    myAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        // 标题
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLabel.text = [NSString stringWithFormat:@"%@V:%@",YZMsg(@"version_newversion_title"), version];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.frame = CGRectMake(15, 15, mainView.frame.size.width - 30, 30);
        [mainView addSubview:titleLabel];
        
        // 内容滚动视图
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 10, mainView.frame.size.width - 30, 200)];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        [mainView addSubview:scrollView];
        
        // 内容文本
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, 0)];
        textView.editable = NO;
        textView.scrollEnabled = NO; // 禁用文本视图的滚动，使用外部的scrollView滚动
        textView.textAlignment = NSTextAlignmentLeft;
        textView.font = [UIFont systemFontOfSize:15.0f];
        
        // 尝试将XML内容转换为富文本
        NSAttributedString *attributedString = nil;
        NSError *error = nil;
        NSData *data = [ipa_des dataUsingEncoding:NSUTF8StringEncoding];
        
        if ([ipa_des containsString:@"<"] && [ipa_des containsString:@">"]) {
            // 尝试解析XML/HTML
            attributedString = [[NSAttributedString alloc] initWithData:data
                                                                options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                          NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                     documentAttributes:nil
                                                                  error:&error];
        }
        
        if (attributedString == nil || error) {
            // 如果解析失败，则使用纯文本
            textView.text = ipa_des;
        } else {
            textView.attributedText = attributedString;
        }
        
        // 计算文本高度
        CGSize size = [textView sizeThatFits:CGSizeMake(scrollView.frame.size.width, CGFLOAT_MAX)];
        textView.frame = CGRectMake(0, 0, scrollView.frame.size.width, size.height);
        
        // 设置滚动视图的内容大小
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, size.height);
        [scrollView addSubview:textView];
        
        // 调整滚动视图高度
        CGFloat scrollViewHeight = MIN(size.height, 200); // 最大高度为200
        scrollViewHeight = MAX(scrollViewHeight, 100); // 最小高度为100
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollViewHeight);
        
        // 按钮容器
        UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(scrollView.frame) + 20, mainView.frame.size.width - 30, 44)];
        [mainView addSubview:buttonContainer];
        
        // 取消按钮
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        cancelButton.frame = CGRectMake(0, 0, (buttonContainer.frame.size.width - 10) / 2, buttonContainer.frame.size.height);
        cancelButton.layer.cornerRadius = 5;
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
        [cancelButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(normalUpdateCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:cancelButton];
        
        // 更新按钮
        UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [updateButton setTitle:YZMsg(@"version_updateNow") forState:UIControlStateNormal];
        updateButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        updateButton.frame = CGRectMake(CGRectGetMaxX(cancelButton.frame) + 10, 0, (buttonContainer.frame.size.width - 10) / 2, buttonContainer.frame.size.height);
        updateButton.layer.cornerRadius = 5;
        updateButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [updateButton addTarget:self action:@selector(normalUpdateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        updateButton.tag = 1001; // 用于保存URL
        objc_setAssociatedObject(updateButton, "update_url", ipa_url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [buttonContainer addSubview:updateButton];
        
        // 调整主视图大小
        CGRect frame = mainView.frame;
        frame.size.height = CGRectGetMaxY(buttonContainer.frame) + 20;
        mainView.frame = frame;
        
        return mainView;
    }).wStartView([MXBADelegate sharedAppDelegate].topViewController.view);
}

// 强制更新按钮点击事件
- (void)forceUpdateButtonClicked:(UIButton *)sender {
    NSString *url = objc_getAssociatedObject(sender, "update_url");
    if (url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
            // 强制更新不关闭弹窗
        }];
    }
}

// 普通更新按钮点击事件
- (void)normalUpdateButtonClicked:(UIButton *)sender {
    NSString *url = objc_getAssociatedObject(sender, "update_url");
    if (url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
            // 普通更新关闭弹窗
          
        }];
        [myAlert closeView];
        myAlert = nil;
    }
}
#if !TARGET_IPHONE_SIMULATOR
//通过OpenInstall获取已经安装App被拉起时的参数（如果是通过渠道页面拉起App时，会返回渠道编号）
-(void)getWakeUpParams:(CorgiGameData *)appData{
    if (appData.data) {//(获取自定义参数)
        //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
    }
    if (appData.channelCode) {//(获取渠道编号参数)
        //e.g.可自己统计渠道相关数据等
        
    }
    NSLog(@"OpenInstallSDK:\n动态参数：%@;\n渠道编号：%@",appData.data,appData.channelCode);
}
#endif
// 普通更新取消按钮点击事件
- (void)normalUpdateCancelButtonClicked:(UIButton *)sender {
    // 关闭弹窗
    [myAlert closeView];
    myAlert = nil;
}

@end
