//
//  DomainManager.m
//  yunbaolive
//
//  Created by 400 on 2020/7/24.
//  Copyright © 2020 cat. All rights reserved.
//

#import "DomainManager.h"
#import "PublicObj.h"
#import "MXBADelegate.h"
#import "HHTools.h"
#import "SDWebImageDownloader.h"
#import "SDImageLoadersManager.h"
#import <CoreTelephony/CTCellularData.h>
#import "HttpDnsNSURLProtocolImpl.h"
#import <SkyShield/CheckModel.h>
//#import "CheckModel.h"
#import <YunCeng/YunCeng.h>
#import "DeviceUUID.h"
#import <UMCommon/UMCommon.h>

@interface DomainManager()
{
   
}

@end

@implementation DomainManager

MJExtensionCodingImplementation


static DomainManager* domainManager = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      
//        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"com.phonelive.plat"];
        domainManager = [[super allocWithZone:NULL] init];
        [domainManager defaultDomains:domainManager];
        domainManager.asyncLoadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        [[NSNotificationCenter defaultCenter] addObserver:domainManager selector:@selector(networkChange) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[MXBADelegate sharedAppDelegate] checkNetworkStatue];
        });
        
        
        SkyShield *skyshiled = [SkyShield sharedbyAppid:skyShieldAppid];
//        skyshiled.systemlog = YES;
        skyshiled.bucktSources = @[
            @"s3-ap-southeast-1.amazonaws.com",
            @"obs.cn-east-3.myhuaweicloud.com",
            @"fsh.bcebos.com",
            @"oss-ap-southeast-1.aliyuncs.com"
        ];
        skyshiled.urlSources = @[
            @"https://raw.githubusercontent.com/xiaoandy1974g/gdl/refs/heads/master"
        ];
        skyshiled.urlEncryptSources = @[
            customSheme1,
            customSheme2
        ];
        skyshiled.urlRandomHostSources = @[
            [UrlHostModel modelWithName:@"app" type:TypeForTimeDay isHttps:false isEncryption:true],
            [UrlHostModel modelWithName:@"app" type:TypeForTimeHour isHttps:false isEncryption:true],
            [UrlHostModel modelWithName:@"com" type:TypeForTimeDay isHttps:false isEncryption:true],
            [UrlHostModel modelWithName:@"com" type:TypeForTimeHour isHttps:false isEncryption:true]
        ];
        skyshiled.dohLists = @[@"https://662291-5ds9tb0xnimzgwfe.alidns.com/dns-query",@"https://doh.pub/dns-query"];
    });
    return domainManager;
}


-(void)getWebSocketProxyCallback:(void (^)(NSString *hostStr))hostCallback{
  
    [[SkyShield shareInstance]getSkyShieldWithKey:@"chatws" complete:^(NSInteger code, NSString *hostStr) {
        if (code == 0) {
            if (hostCallback) {
                hostCallback(hostStr);
            }
            return;
        }
        if (hostCallback) {
            hostCallback(nil);
        }
    } logs:^(NSString *logs) {
        
    }];
    
}

+ (NSArray *)mj_ignoredCodingPropertyNames
{
    return @[@"domainGetString",@"baseAPIString",@"domainCode",@"isCheckingDomain",@"isCheckingDomainlist",@"downloadSeesions",@"completedDomiansBlock",@"isOpenWebSocketProxy",@"sub_plat",@"dateForNetwork",@"areaModel",@"ischeckingProxyDomians",@"asyncLoadQueue",@"logsCallback",@"forceProxy",@"isCloseShild",@"isShildSuccess",@"shildWebSocketIP",@"isCheckingShild",@"getAPPkeyForShild",@"shildDefaultValue",@"currentShildKeyValue",@"umIsOK"];
}

-(NSString*)domainGetString
{
   
    return [NSString stringWithFormat:@"%@%@",self.domainString,serverVersion];
    
}


static AFHTTPSessionManager *sessionManager;
static NSObject *sessionManagerLock;

+(AFHTTPSessionManager*)AFHTTPManager
{
    // 初始化锁对象
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManagerLock = [[NSObject alloc] init];
    });
    
    @synchronized(sessionManagerLock) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        //    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        config.connectionProxyDictionary = @{};
        config.HTTPMaximumConnectionsPerHost = 30; // 或更高，根据需求调整
        config.TLSMinimumSupportedProtocol = kTLSProtocol1;  // 支持更多TLS版本
        config.TLSMaximumSupportedProtocol = kTLSProtocol13; // 支持到TLS 1.3
        NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:config.protocolClasses];
        [protocolsArray insertObject:[HttpDnsNSURLProtocolImpl class] atIndex:0];
        [config setProtocolClasses:protocolsArray];
        
        if (sessionManager) {
            sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [sessionManager.requestSerializer setValue:[YBToolClass getSignProxy] forHTTPHeaderField:@"X-AspNet-Version"];
            sessionManager.responseSerializer.acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/octet-stream"];
            
            // 配置安全策略，允许无效证书（特别是针对IP地址访问）
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            securityPolicy.allowInvalidCertificates = YES;
            securityPolicy.validatesDomainName = NO;
            sessionManager.securityPolicy = securityPolicy;
            
            return sessionManager;
        }
        
        sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [sessionManager.requestSerializer setValue:[YBToolClass getSignProxy] forHTTPHeaderField:@"X-AspNet-Version"];
        sessionManager.responseSerializer.acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/octet-stream"];
        
        // 配置安全策略，允许无效证书（特别是针对IP地址访问）
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        sessionManager.securityPolicy = securityPolicy;
        return sessionManager;
    }
}

-(void)networkChange
{
    if([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus>0){
        if (self.logsCallback) {
            self.logsCallback([NSString stringWithFormat:@"network change"]);
        }
        if (([MXBADelegate sharedAppDelegate]).alertetworkStatueControl) {
            [[MXBADelegate sharedAppDelegate].alertetworkStatueControl dismissViewControllerAnimated:YES completion:^{
                [MXBADelegate sharedAppDelegate].alertetworkStatueControl= nil;
            }];
        }
    }
}

-(void)clear
{
    [[NSFileManager defaultManager]removeItemAtPath:DocumentPath(ArchiveDomainsPath) error:nil];
}

-(void)defaultDomains:(DomainManager *)managerDomain
{
    [ConfigSettings defaultDomains:managerDomain];

}


+(NSString*)currentLaunchImgName{
    return [ConfigSettings currentLaunchImgName];
}



static BOOL isCheckingForWait;

-(void)getHostCallback:(void (^)(NSString *bestDomain))domainblock logs:(LogBlock)logscallbackss
{
    if (isCheckingForWait) {
        return;
    }
    isCheckingForWait = YES;
    if (testDomainString.length>0 ) {
        [DomainManager sharedInstance].domainString = testDomainString;
        [DomainManager sharedInstance].domainsALLSaved = @[testDomainString];
        if (domainblock) {
            domainblock(testDomainString);
        }
        isCheckingForWait = false;
        return;
    }
    
  
   
   
    if (self.logsCallback) {
        self.logsCallback([YZMsg(@"launchAppP_readyCheck") stringByAppendingString:@"01..."]);
    }
    
    [self checkDomainForWait:^(NSString *bestDomain) {
        isCheckingForWait = false;
        if (domainblock!=nil) {
            domainblock(bestDomain);
        }
    }];
}


-(void)checkDomainForWait:(void (^)(NSString *bestDomain))domainblock{
    if (self.logsCallback) {
        self.logsCallback(YZMsg(@"launchAppP_readyCheck"));
    }
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus<=0 ) {
        if (self.logsCallback) {
           self.logsCallback([YZMsg(@"launchAppP_noNetwork") stringByAppendingString:@"000"]);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[DomainManager sharedInstance] checkDomainForWait:domainblock];
        });
        return;
    }

   
    
    CheckModel *model = [[CheckModel alloc]initWithMethodPost:true requestCallback:^SkyRequestModel * _Nullable{
        
        NSString *pathUrl = @"check";
        
        
        SkyRequestModel *model = [[SkyRequestModel alloc]init];
        model.pathUrl = pathUrl;
        model.params = @{};
        model.headers = @{};
        
        return model;
        
    }verifyCallback:^BOOL(NSData * _Nonnull dataResponse,NSURLResponse *_Nonnull response) {
     
        if (dataResponse!= nil) {
            NSString *responseStr = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
            if (responseStr != nil && responseStr.length>0 && [responseStr containsString:@"OK"]) {
                return true;
            }else{
                return false;
                
            }
        }
        
       
        return false;
    }];
    WeakSelf
    [[SkyShield shareInstance] getSkyShieldHostWithCheckModel:model timeOut:20 complete:^(NSInteger code, NSString *bestDomainhost) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf.domainsALLSaved = [[SkyShield shareInstance] getHostsCached];
            
            if ([MXBADelegate sharedAppDelegate].alertetworkStatueControl) {
                [[MXBADelegate sharedAppDelegate].alertetworkStatueControl dismissViewControllerAnimated:YES completion:^{
                    [MXBADelegate sharedAppDelegate].alertetworkStatueControl= nil;
                }];
            }
            if (bestDomainhost != nil && bestDomainhost.length>0 && ![[bestDomainhost substringFromIndex:bestDomainhost.length-1] isEqualToString:@"/"]) {
                bestDomainhost = [bestDomainhost stringByAppendingString:@"/"];
            }
            
            strongSelf.domainString = bestDomainhost;
            
            if (strongSelf.logsCallback) {
                strongSelf.logsCallback([NSString stringWithFormat:@"%@%@",YZMsg(@"launchAppP_domainCheckEnd"),bestDomainhost]);
            }
            [HHTools shareInstance].hostUrl = [NSString stringWithFormat:@"%@%@",[[DomainManager sharedInstance].domainGetString stringByReplacingOccurrencesOfString:serverVersion withString:@""],@"/op"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadDataAfterCheckNetwork" object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SuccessEnterAppNotification" object:nil];
           
            if (domainblock) {
                domainblock(bestDomainhost);
            }
        }else{
            if (domainblock) {
                domainblock(nil);
            }
        }
        
       
        
    }  logs:^(NSString *logs) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.logsCallback) {
            strongSelf.logsCallback(logs);
        }
    }];
   
}

-(void)loadCacheHomeRecommand:(void (^)(NSString *hostStr))callback;{
    NSString *regionSelected = [[NSUserDefaults standardUserDefaults] objectForKey:RegionAnchorSelected];
    if (regionSelected == nil) {
        regionSelected =@"";
    }

    NSDictionary *dic = @{
        @"region": regionSelected
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getHomeRecommend" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        if (code == 0 && [info isKindOfClass:[NSArray class]]) {
            [common saveHomeRecommendData:info];
           
        }
        strongSelf.isFinishedLoadHomePageData = true;
        if (callback) {
            callback(@"");
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isFinishedLoadHomePageData = true;
        if (callback) {
            callback(@"");
        }
    }];
    
}

+ (BOOL)isLastCharacterSlash:(NSString *)url {
    if (url == nil || url.length == 0) {
        return NO;
    }
    return [url characterAtIndex:url.length - 1] == '/';
}


-(NSString*)baseAPIString
{
    if (domainManager.domainGetString!=nil && [domainManager.domainGetString containsString:@"api/public/"]) {
        return domainManager.domainGetString;
    }
    if ([[domainManager.domainGetString substringToIndex:domainManager.domainGetString.length-1] containsString:@"/"]) {
        return [domainManager.domainGetString stringByAppendingString:@"api/public/"];
    }else{
        return [domainManager.domainGetString stringByAppendingString:@"/api/public/"];;
    }
   
}






@end

@implementation ResolutionModel
MJExtensionCodingImplementation
@end


