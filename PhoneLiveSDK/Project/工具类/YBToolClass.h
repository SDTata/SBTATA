//
//  YBToolClass.h
//  yunbaolive
//
//  Created by Boom on 2018/9/19.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NodeMediaClient/NodeMediaClient.h>



NSString *_Nullable aesEncryptString(NSString * _Nullable content, NSString *_Nullable key, NSString *_Nullable iv);
NSString *_Nullable aesDecryptString(NSString * _Nullable content, NSString * _Nullable key, NSString *_Nullable iv);
NSData   *_Nullable aesEncryptData(NSData *_Nullable contentData, NSData *_Nullable keyData, NSData *_Nullable ivData);
NSData   *_Nullable aesDecryptData(NSData *_Nullable contentData, NSData *_Nullable keyData, NSData *_Nullable ivData);

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ELEncryptMode) {
    ELEncryptAES128      = 0,
    ELEncryptAES192,
    ELEncryptAES256,
    ELEncryptDES,
    ELEncrypt3DES,
};


typedef void (^mengbanBlock)(void);
@interface YBToolClass : NSObject
/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;


@property(nonatomic,strong) NSString * decrypt_sdk_key;
@property(nonatomic,assign) BOOL  default_old_view;
@property(nonatomic,assign) BOOL  default_oldLH_view;
@property(nonatomic,assign) BOOL  default_oldZJH_view;
@property(nonatomic,assign) BOOL  default_oldBJL_view;
@property(nonatomic,assign) BOOL  default_oldZP_view;

@property(nonatomic,assign) BOOL  default_oldSC_view;
@property(nonatomic,assign) BOOL  default_oldLHC_view;
@property(nonatomic,assign) BOOL  default_oldSSC_view;
@property(nonatomic,assign) BOOL  default_oldNN_view;


@property(nonatomic,assign) float  liveTableWidth;

@property(nonatomic,assign) float  lotteryLiveWindowHeight;

@property(nonatomic,assign) float  lotteryLiveGameHeight;

@property(nonatomic,assign) BOOL shouldUseHookedMethodForTimer;

@property(nonatomic,strong) NSMutableDictionary *dicForKeyPlay;

@property(nonatomic,strong) NodePlayer *nplayer;

@property(nonatomic,strong) NSMutableDictionary *playerDic;

@property (nonatomic, copy) NSString * receivedNetworkSpeed;

@property (nonatomic, copy) NSString * sendNetworkSpeed;

@property (nonatomic, assign) BOOL noticeSwitch;

/**
 计算字符串宽度

 @param str 字符串
 @param font 字体
 @param height 高度
 @return 宽度
 */
- (CGFloat)widthOfString:(NSString *)str andFont:(UIFont *)font andHeight:(CGFloat)height;
+ (CGFloat)widthOfString:(NSString *)str andFont:(UIFont *)font andHeight:(CGFloat)height;

/**
 计算字符串的高度

 @param str 字符串
 @param font 字体
 @param width 宽度
 @return 高度
 */
- (CGFloat)heightOfString:(NSString *)str andFont:(UIFont *)font andWidth:(CGFloat)width;
/**
 画一条线
 
 @param frame 线frame
 @param color 线的颜色
 @param view 父View
 */
- (void)lineViewWithFrame:(CGRect)frame andColor:(UIColor *)color andView:(UIView *)view;

/**
 MD5加密

 @param input 要加密的字符串
 @return 加密好的字符串
 */
- (NSString *) md5:(NSString *) input;

/**
 比较两个时间的大小

 @param date01 老的时间
 @param date02 新的时间
 @return 返回 1 -1 0
 */
-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02;

/**
 创建emoji正则表达式

 @param pattern 正则规则
 @param str 字符串
 @return 数组
 */
- (NSArray <NSTextCheckingResult *> *)machesWithPattern:(NSString *)pattern  andStr:(NSString *)str;

-(void)quitLogin:(BOOL)relogin;

+(UIView *)mengban:(UIView *)mainView clickCallback:(mengbanBlock)clickCallback;
+ (NSString *)timeFormatted:(NSInteger)totalSeconds;
+ (NSString *)timeFormattedAge:(NSInteger)totalSeconds;
+ (void)showService;
+ (NSString *)replaceUrlParams:(NSString *)url;
//+ (NSComparisonResult)customStringSort:(NSDictionary *)dict1 dict2:(NSDictionary *)dict2;
+ (NSString *)getRequestSign:(NSString *)url params:(NSMutableDictionary *)pDic;

- (void)closeService:(id)sender;

+(NSString*)aes_Decode:(NSString*)decodeStr;

//请求头
+(NSString*)getSignProxy;

+(NSString*)signAESNL;

/// 汇率转换，超过1000显示k
+ (NSString *)getRateCurrency:(NSString *)currency showUnit:(BOOL)showUnit;

/// 汇率转换,小数点不省略，超过1000显示k
+ (NSString *)getNoScaleRateCurrency:(NSString *)currency showUnit:(BOOL)showUnit;

/// 汇率转换，超过1000显示k, 可选择是否显示千分为逗号
+ (NSString *)getRateCurrency:(NSString *)currency showUnit:(BOOL)showUnit showComma:(BOOL)showComma;

/// 汇率转换，内部除以10
+ (NSString *)getRateBalance:(NSString *)currency showUnit:(BOOL)showUnit;

/// 汇率转换，不显示k
+ (NSString *)getRateCurrencyWithoutK:(NSString *)currency;

/// 反向汇率转换
+ (NSString *)getRmbCurrency:(NSString *)currency;

/// 自定义输入，超过1000显示k
+ (NSString *)currencyCoverToK:(NSString *)currency;
////
///获取cpu信息
-(NSString*)getCPUType;
///是否有距离传感器
-(BOOL)hasProximityMonitoring;
//系统版本
-(NSString*)systemVersion;
//手机名称
-(NSString*)iphoneName;
-(BOOL)isInstallDouying;
-(BOOL)isInstallAlipay;
-(BOOL)isInstallQQ;
-(BOOL)isInstallWeixin;
-(NSDictionary*)checkUserPhoneDevice;
+(NSString *)returnLetter:(int)number;

-(void)logOutRequestIfAutologin:(nullable NSString*)phoneNum codeNum:(nullable NSString*)codeNum;

+ (NSString *)decrypt_sdk_key;

-(void)checkNetworkflow;

+(NSString *)encodeRC2:(NSString*)dataStr;

+(NSDictionary *)getUrlParamWithUrl:(NSString*)urlst;

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary;

+(NSString*)decodeReplaceUrl:(NSString*)url;

//所有h5需要拼接uid和token
+(NSString *)addurl:(NSString *)url;

// 喜欢，播放量，直播间人数。 还有 游戏在线人数
+ (NSString *)formatLikeNumber:(NSString *)number;


+ (NSString *)customEncodeURLWithCharacterSet:(NSString *)urlString;

+ (BOOL)isURLEncoded:(NSString *)string;

+(NSTimeInterval)LocalTime;

@end

NS_ASSUME_NONNULL_END
