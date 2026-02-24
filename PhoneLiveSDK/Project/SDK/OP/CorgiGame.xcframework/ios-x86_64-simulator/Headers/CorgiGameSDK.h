
#import <Foundation/Foundation.h>
#import "CorgiGameData.h"

@protocol CorgiGameDelegate<NSObject>

@optional

/**
 * 唤醒时获取h5页面动态参数（如果是渠道链接，渠道编号会一起返回）
 * @param appData 动态参数对象
 */
- (void)getWakeUpParams:(nullable CorgiGameData *)appData;

@end

@interface CorgiGameSDK : NSObject

/**
 * 获取sdk当前版本号
 */
+ (NSString *_Nullable)sdkVersion;


/**
 * SDK单例
 */
+(instancetype _Nullable)defaultManager;


///-------------
/// @name 初始化
///-------------

/**
 * 初始化 SDK
 * ***调用该方法前，需在Info.plist文件中配置键值对***
 
 <key>com.corgigame.APP_KEY</key>
 <string>你的appKey</string>
 
 * @param delegate 委托方法所在的类的对象
 */
+(void)initWithDelegate:(id<CorgiGameDelegate> _Nonnull)delegate;


/**
 * 初始化sdk并传入广告标识符id（可选）
 *
 * @param adid 广告标识符，需用户自己获取并传入，默认为空，传入nil则与初始化方法 initwithDelegate: 一致
 * @param delegate 委托方法所在的类的对象
 * @discussion 1、只有需要使用“广告平台渠道”进行广告效果监测的用户才需调用，2、需开启后台开关，位置："iOS集成"->"iOS应用配置"->"广告平台对接"
 */
+ (void)initWithDelegate:(nullable id<CorgiGameDelegate>)delegate advertisingId:(NSString *_Nullable)adid;



/**
 * 初始化sdk，并传入广告相关参数
 *
 * @param delegate 委托方法所在的类的对象
 * @param attribution 广告相关参数，如ASA token，idfa等，@{app_ASA_Token:@"your ASA Token"}
 */
+ (void)initWithDelegate:(nullable id<CorgiGameDelegate>)delegate adsAttribution:(NSDictionary *_Nullable)attribution;


#pragma mark - Deprecated in v2.2.0（已废弃）

/**
 * 初始化 SDK (已废弃,请参考方法 initwithDelegate: 已使用该初始化方法的用户也可继续使用)
 *
 * @param appKey 控制中心创建应用获取appKey
 * @param delegate 委托方法(getWakeUpParams)所在的类的对象
 * @discussion 老版本sdk升级过来可延用该api
 */
+(void)setAppKey:(nonnull NSString *)appKey withDelegate:(nullable id<CorgiGameDelegate>)delegate __deprecated_msg("Deprecated in v2.2.0，请参考方法<code>initwithDelegate</code>");

///----------------------
/// @name 获取安装的动态参数
///----------------------

/**
 * 开发者在需要获取用户安装app后由web网页传递过来的”动态参数“（如邀请码、游戏房间号，渠道编号，ASA渠道编号等）时调用该方法
 *
 *
 * @param completedBlock 回调block，在主线程（UI线程）回调
 *
 */
-(void)getInstallParmsCompleted:(void (^_Nullable)(CorgiGameData*_Nullable appData))completedBlock;


/**
 * 开发者在需要获取用户安装app后由web网页传递过来的”动态参数“（如邀请码、游戏房间号，渠道编号，ASA渠道编号等）时调用该方法,可第一时间返回数据，可在任意位置调用
 *
 * @param timeoutInterval 可设置回调超时时长，单位秒(s)
 * @param completedBlock 回调block，在主线程（UI线程）回调
 *
 */
-(void)getInstallParmsWithTimeoutInterval:(NSTimeInterval)timeoutInterval
                                completed:(void (^_Nullable)(CorgiGameData*_Nullable appData))completedBlock;



///---------------------
/// @name 一键拉起回调处理
///---------------------

/**
 * 处理 URI schemes
 * @param URL 系统回调传回的URL
 * @return bool URL是否被识别
 */
+(BOOL)handLinkURL:(NSURL *_Nullable)URL;


/**
 * 处理 通用链接
 * @param userActivity 存储了页面信息，包括url
 * @return bool URL是否被识别
 */
+(BOOL)continueUserActivity:(NSUserActivity *_Nullable)userActivity;



///--------------
/// @name 统计相关
///--------------


/**
 * 注册量统计
 *
 * 使用 控制中心提供的渠道统计时，在App用户注册完成后调用，可以统计渠道注册量。
 * 必须在注册成功的时再调用该方法，避免重复调用，否则可能导致注册统计不准
 */
+(void)reportRegister;

/**
 * 渠道效果统计
 *
 * 目前SDK采用定时上报策略，时间间隔由服务器控制
 * e.g.可统计用户支付消费情况,点击次数等
 *
 * @param effectID 效果点ID
 * @param effectValue 效果点值（如果是人民币金额，请以分为计量单位）
 */
-(void)reportEffectPoint:(NSString *_Nonnull)effectID effectValue:(long)effectValue;

#pragma mark - added in v2.6.0
/**
   * 渠道效果统计，效果明细上报
   *
   * 目前SDK采用定时上报策略，时间间隔由服务器控制
   * e.g.可统计用户支付消费情况，点击次数，以及效果明细等
   *
   * @param effectID 效果点ID
   * @param effectValue 效果点值（如果是人民币金额，请以分为计量单位）
   * @param effectDictionary 效果点明细，key和value都要传入字符串格式
*/
-(void)reportEffectPoint:(NSString *_Nonnull)effectID effectValue:(long)effectValue effectDictionary:(NSDictionary*_Nonnull)effectDictionary;


#pragma mark - added in v2.7.0
/**
  * 分享上报
 *
 * @param shareCode 分享用户ID；String 必填
 * @param sharePlatform 分享平台：String 建议填入 根据已创建好的“OP_SharePlatform”字符串类型填
 入
  * @param completedBlock 上报成功code=0，飞行模式/网络差/连接异常code=-1可重试，其它情况代表发
 生异常错误不需要重试，返回主线程
 */
-(void)reportShareParametersWithShareCode:(NSString *_Nonnull)shareCode
                            sharePlatform:(CorgiGame_SharePlatform _Nullable)sharePlatform
                                completed:(void (^_Nullable)(NSInteger code,NSString *_Nullable msg))completedBlock;

/**
 *  Gets opid.
 *  Call after initialization, non-asynchronous, must tests on the phone.
 *  you can call this method in `getInstallParmsCompleted` method.
 *  @return string.
 */
- (NSString *_Nullable)getOpId;
@end

