//
//  DomainManager.h
//  yunbaolive
//
//  Created by 400 on 2020/7/24.
//  Copyright © 2020 cat. All rights reserved.
//
/** app来源 */

#import <Foundation/Foundation.h>
#import "MJExtension.h"
#import "AFHTTPSessionManager.h"
#import "ConfigSettings.h"

#import <SkyShield/SkyShield.h>
//#import "SkyShield.h"

typedef void (^LogBlock)(NSString *logstring);

#define APPTestDomain @""

#define APP_DOCUMENT                [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define DocumentPath(path)          [APP_DOCUMENT stringByAppendingPathComponent:path]

#define ArchiveDomainsPath [NSString stringWithFormat:@"ArchiveDomainsPath_%@_%@_%@",[[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] infoDictionary] objectForKey:@"CFBundleVersion"],[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] objectForInfoDictionaryKey:@"com.phonelive.plat"]]


@interface ResolutionModel : NSObject

@property(nonatomic,assign)int width;
@property(nonatomic,assign)int height;
@property(nonatomic,assign)BOOL bAuto;
@end


@interface DomainManager : NSObject<NSCoding>

+(AFHTTPSessionManager *)AFHTTPManager;


@property(nonatomic,strong)NSArray *domainsALLSaved;
@property(nonatomic,strong)NSString *kefuServer;

@property(nonatomic,copy)LogBlock logsCallback;//打印日志

@property (nonatomic, strong) dispatch_queue_t asyncLoadQueue;



@property(nonatomic,strong)NSString *platName;

@property(nonatomic,strong)NSString *sub_plat;



@property(nonatomic,assign)BOOL umIsOK;

///主域名 设置用
@property(nonatomic,strong)NSString *domainString;

///请求API
@property(nonatomic,strong)NSString *baseAPIString;

///主域名获取
@property(nonatomic,strong)NSString *domainGetString;

///备用已经检测过的域名
@property(nonatomic,strong)NSArray *domainsCacheSuccess;

@property(nonatomic,strong)NSString *domainCode;

@property(nonatomic,assign)BOOL isFinishedLoadHomePageData;

/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;


/**
 *  测试域名网络状态
 *  @param domainblock 返回最优的域名Str
 */
-(void)getHostCallback:(void (^)(NSString *bestDomain))domainblock logs:(LogBlock)logscallback;

//-(void)clear;

-(void)getWebSocketProxyCallback:(void (^)(NSString *hostStr))hostCallback;

//启动页
+(NSString*)currentLaunchImgName;

-(void)loadCacheHomeRecommand:(void (^)(NSString *hostStr))callback;
@end


