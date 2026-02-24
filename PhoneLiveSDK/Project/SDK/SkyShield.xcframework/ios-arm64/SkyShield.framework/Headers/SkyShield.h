//
//  SkyShield.h
//  yunbaolive
//
//  Created by Tibbers on 2020/7/24.
//  Copyright 2020 cat. All rights reserved.
//

/**
 * SkyShield SDK头文件
 * 提供iOS应用的安全防护功能，包括URL保护、域名管理和网络安全
 */

#import <Foundation/Foundation.h>
#import "UrlHostModel.h"
#import "CheckModel.h"
#import "SkyshieldDataForUpload.h"
/**
 * 结果状态码定义
 */
#define SKY_RESULT_OK 0       ///< 操作成功
#define SKY_RESULT_ERROR 1    ///< 操作错误
#define SKY_RESULT_NON 2      ///< 无结果

/**
 * 存储键名定义
 */
#define kKeyPortCache @"port_num_cache"         ///< 端口缓存键
#define kKeyStoredHostUrlLast @"host_url_last"  ///< 最后使用的主机URL键
#define kKeyWebApi @"webApi"                    ///< Web API键

static NSString *  kPreferencesName = @"SkyShieldPreferences";  ///< 偏好设置名称
#define  kKeyStoredDunKeyLast @"DunKey_last"    ///< 最后使用的盾键

#define SSWeakSelf __weak typeof(self) weakSelf = self;
#define SSStrongSelf __strong __typeof(weakSelf)strongSelf = weakSelf;

#ifdef DEBUG

#define NSShildLog(FORMAT, ...) do { \
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; \
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]; \
    NSString *dateString = [formatter stringFromDate:[NSDate date]]; \
    fprintf(stderr, "%s %s:%d\t%s\n", [dateString UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]); \
} while (0)

#else

#define NSShildLog(...)

#endif


/**
 * SkyShield安全防护SDK主类
 * 提供应用安全防护的核心功能
 */
@interface SkyShield : NSObject

/** 自定义bucket源数组（规则请看文档） */
@property (nonatomic, strong) NSArray <NSString *> *bucktSources;

/** 自定义URL源数组（规则请看文档） */
@property (nonatomic, strong) NSArray <NSString *> *urlSources;

/** 自定义加密头URL源数组（规则请看文档） */
@property (nonatomic, strong) NSArray <NSString *> *urlEncryptSources;

/** 自定义域名源数组（规则请看文档） */
@property (nonatomic, strong) NSArray <UrlHostModel *> *urlRandomHostSources;

/** 超时时间（秒） */
@property (nonatomic, assign) NSInteger timeoutNum;

/** DOH列表 */
@property (nonatomic, strong) NSArray <NSString *> *dohLists;


@property (atomic, strong) NSString *appId;


@property(nonatomic,assign)BOOL systemlog;
/**
 * 初始化SDK单例
 * @param appid 应用ID
 * @return SkyShield实例
 * @note 重复初始化可替换appid
 */
+ (instancetype)sharedbyAppid:(NSString*)appid;

/**
 * 获取SDK单例
 * @return SkyShield实例
 */
+(instancetype)shareInstance;

/**
 * 获取安全域名
 * @param checkModel 需要检查的模型
 * @param timeout 超时时间
 * @param hostCallback 结果回调，code为0表示成功
 * @param logscallback 检测日志回调
 */
- (void)getSkyShieldHostWithCheckModel:(CheckModel*)checkModel 
                       timeOut:(NSInteger)timeout
                     complete:(void (^)(NSInteger code, NSString *hostStr))hostCallback 
                        logs:(void(^)(NSString *logs))logscallback;

/**
 * 获取Shield配置
 * @param shieldKey Shield密钥
 * @param hostCallback 结果回调，返回json格式的端口号和本地域名
 * @param logscallback 日志回调
 * @note 如果返回不是json格式，则为错误信息
 */
- (void)getSkyShieldWithKey:(NSString*)shieldKey 
                  complete:(void (^)(NSInteger code, NSString *hostStr))hostCallback 
                     logs:(void(^)(NSString *logs))logscallback;

/**
 * 停止Shield服务
 * @note app关闭时必须调用此方法释放资源
 */
- (void)skyShield_stop;


/**
 * 重新启动Shield服务
 * @note 从后台恢复APP时需要调用此方法重新启动服务，避免被系统回收
 */
- (void)skyShield_restart;

/**
 * 备用方法，在初始化完成后，如果出现网络报错无法自动切换线路，可以用此方法重新手动获取刷新线路。
 * @param checkModel 需要检查的模型
 * @param hostCallback 结果回调
 * @param logscallback 日志回调
 */
- (void)skyShield_reload:(CheckModel*)checkModel Complete:(void (^)(NSInteger code, NSString *hostStr))hostCallback
                          logs:(void(^)(NSString *logs))logscallback;

/**
 * 设置日志信息
 * @param jsonStr JSON格式的日志信息
 * @note 用于日志上报
 */
- (void)skyShield_setInfoJSON:(NSString*)jsonStr;


/**
 * 缓存域名
 * 域名列表
 */
-(NSArray*)getHostsCached;


/**
 * 缓存域名
 * 服务器时间减去本地时间差
 */
-(long)getCaculateTime;


-(NSString*)replaceUrlHostToDNS:(NSString*)originalUrl;

-(NSString*)getShorebirdDonwloadUrl;

@end
