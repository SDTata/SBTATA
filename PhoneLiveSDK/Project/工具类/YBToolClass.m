//
//  YBToolClass.m
//  yunbaolive
//
//  Created by Boom on 2018/9/19.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "YBToolClass.h"
#import<CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import "PhoneLoginVC.h"
#import "MXBADelegate.h"
#import "MYTapGestureRecognizer.h"


#import "UINavModalWebView.h"
#import "NavWeb.h"
#import "DeviceUUID.h"
#import <FFAES/FFAES.h>
#import <FFAES/GTMBase64.h>
#import "RandomRule.h"
//#import <openssl/rc2.h>
//#import <openssl/evp.h>
#import "LaunchInitManager.h"
#import <sys/utsname.h>//要导入头文件
#import "webH5.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#import "NavWeb.h"
#import "UINavModalWebView.h"
#import "OneBuyGirlViewController.h"
#import "PayViewController.h"
#import "EnterLivePlay.h"
#import "TaskVC.h"
#import "GameHomeMainVC.h"
#import "myWithdrawVC2.h"
#import "myPopularizeVC.h"
#import <UMCommon/UMCommon.h>

NSData * cipherOperation(NSData *contentData, NSData *keyData, NSData *ivData, CCOperation operation) {
    NSUInteger dataLength = contentData.length;
    void const *initVectorBytes = ivData.bytes;
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;
    
    size_t operationSize = dataLength + kCCBlockSizeAES128;
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  // 与其他平台的PKCS5Padding相等
                                          keyBytes,
                                          kCCKeySizeAES128,  // 秘钥长度选择AES128
                                          initVectorBytes,
                                          contentBytes,
                                          dataLength,
                                          operationBytes,
                                          operationSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    
    free(operationBytes);
    operationBytes = NULL;
    return nil;
}

NSString * aesEncryptString(NSString *content, NSString *key, NSString *iv) {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encrptedData = aesEncryptData(contentData, keyData, ivData);
    return [encrptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

NSString * aesDecryptString(NSString *content, NSString *key, NSString *iv) {
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *decryptedData = aesDecryptData(contentData, keyData, ivData);
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

NSData * aesEncryptData(NSData *contentData, NSData *keyData, NSData *ivData) {
    return cipherOperation(contentData, keyData, ivData, kCCEncrypt);
}

NSData * aesDecryptData(NSData *contentData, NSData *keyData, NSData *ivData) {
    return cipherOperation(contentData, keyData, ivData, kCCDecrypt);
}
@interface YBToolClass()<TaskJumpDelegate>
{
    uint32_t _iBytes;
    uint32_t _oBytes;
}

@end
@implementation YBToolClass
static YBToolClass* kSingleObject = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSingleObject = [[super allocWithZone:NULL] init];
        
        // 确保UI相关操作在主线程执行
        if ([NSThread isMainThread]) {
            // 在主线程直接设置
            kSingleObject.liveTableWidth = tableWidth;
        } else {
            // 在后台线程使用一个安全的默认值，避免访问UI
            kSingleObject.liveTableWidth = 300; // 使用一个默认值
            
            // 然后在主线程异步更新正确的值
            dispatch_async(dispatch_get_main_queue(), ^{
                kSingleObject.liveTableWidth = tableWidth;
            });
        }
        
        kSingleObject.playerDic = [NSMutableDictionary dictionary];
    });
    
    return kSingleObject;
}

// 重写创建对象空间的方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    // 直接调用单例的创建方法
    return [self sharedInstance];
}

// 根据请求获取sign
+ (NSString *)getRequestSign:(NSString *)url params:(NSMutableDictionary *)pDic{
    // 生成sign
    NSMutableArray *sign_params = [NSMutableArray array];
    // 解析url中的参数
    NSArray *url_splite = [url componentsSeparatedByString:@"?"];
    NSString *url_params_string = @"";
    if (url_splite.count>1) {
        url_params_string = url_splite[1];
    }
    if(url_params_string && url_params_string.length > 0){
        NSArray *url_params_string_splite = [url_params_string componentsSeparatedByString:@"&"];
        if(url_params_string_splite.count > 0){
            for (int i = 0; i < url_params_string_splite.count; i ++) {
                NSArray *params_splite = [url_params_string_splite[i] componentsSeparatedByString:@"="];
                NSString * v = @"";
                if (params_splite.count>1) {
                    v = params_splite[1];
                }
                if(v && v.length > 0 && ![pDic objectForKey:params_splite[0]]){
                    [sign_params addObject:@{@"key":params_splite[0], @"value":v}];
                }
            }
        }
    }
    if(![pDic objectForKey:@"plat"]){
        pDic[@"plat"] = @"ios";
    }
    if (![pDic objectForKey:@"device"]) {
        pDic[@"device"] =  [DeviceUUID uuidForPhoneDevice];
    }
    if (![pDic objectForKey:@"plat_id"]) {
        pDic[@"plat_id"] = [DomainManager sharedInstance].domainCode;
    }
    
    if (![pDic objectForKey:@"devicetype"]) {
        pDic[@"devicetype"] = [self getCurrentDeviceModel];
    }
    
    if(![pDic objectForKey:@"version"]){
        pDic[@"version"] = [NSString stringWithFormat:@"%@(tag%@)",APPVersionNumber,ios_buildVersion];
    }
    if(![pDic objectForKey:@"rtm"]){
     
        NSTimeInterval time = [YBToolClass LocalTime];
        pDic[@"rtm"] = [NSString stringWithFormat:@"%.0f",time];
    }
    for (NSString *key in pDic) {
        id v = pDic[key];
        if([v isKindOfClass:[NSString class]]){
            NSString *str = v;
            if(str && str.length > 0){
                [sign_params addObject:@{@"key":key, @"value":str}];
            }
        }else {
            [sign_params addObject:@{@"key":key, @"value":v}];
        }
    }
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSDictionary *dict1, NSDictionary *dict2){
        NSString *v1 = dict1[@"key"];
        NSString *v2 = dict2[@"key"];
        
        NSRange range = NSMakeRange(0,v1.length);
        return [v1 compare:v2 options:comparisonOptions range:range];
    };
    if (sign_params) {
        sign_params = [NSMutableArray arrayWithArray:[sign_params sortedArrayUsingComparator:sort]];
    }
    NSString *sign_str = @"";
    NSString *k = @"0011";
    for (int i = 0; i < sign_params.count; i++) {
        NSDictionary *d = sign_params[i];
        sign_str = [NSString stringWithFormat:@"%@%@%@", sign_str, d[@"key"], d[@"value"]];
    }
    sign_str = [NSString stringWithFormat:@"%@%@%@", k, sign_str, @" "];
    NSString *sign = [PublicObj stringToMD5:sign_str];
    return sign;
}

+(NSString*)getSignProxy{
    // 使用静态锁对象确保线程安全
    static dispatch_once_t onceToken;
    static NSObject *lock = nil;
    dispatch_once(&onceToken, ^{
        lock = [[NSObject alloc] init];
    });
    
    // 在锁内执行所有操作，防止多线程并发访问导致崩溃
    @synchronized(lock) {
        NSString *magicStr = @"FUCKYOU";
        NSString *publicKeyStr = @"5jZyks1r"; //公钥 = 随机8位大小写字母数字
        NSString *randomStr = [YBToolClass returnLetter:10]; //随机盐 = 随机10位大小写字母数字
        NSTimeInterval logTime = [YBToolClass LocalTime];
        NSString *timess = [NSString stringWithFormat:@"%.0f", logTime];
        NSString *rc2S = [NSString stringWithFormat:@"%@|%@|%@",magicStr,timess,randomStr];
        NSString *value = [NSString stringWithFormat:@"%@%@",publicKeyStr,[YBToolClass encodeRC2:rc2S]];
        return value;
    }
}


+(NSString *)encodeRC2:(NSString*)dataStr{
    NSData* result = nil;
    NSData *dataa = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *ivStr = @"5jZyks1r";
    NSString *keyStr = @"l65tvNcw";

    const char *keyPtr = [keyStr cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cIv = [ivStr cStringUsingEncoding:NSASCIIStringEncoding];

    NSUInteger dataLength = [dataa length];

    size_t bufferSize = dataLength + kCCBlockSizeRC2;
    void *buffer = malloc(bufferSize);
    //kCCBlockSizeAES128
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                             kCCAlgorithmRC2,
                                             kCCOptionPKCS7Padding,keyPtr,
                                             [keyStr length],
                                             cIv,
                                             [dataa bytes],
                                             dataLength,
                                             buffer,
                                             bufferSize,
                                             &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    } else {
        free(buffer);
        NSLog(@"[ERROR]解密失败| CCCryptoStatus: %d", cryptStatus);
    }

    NSString *base63ss = [GTMBase64 stringByEncodingData:result];
    return base63ss;
}

+ (NSData *)encryptWithAlgorithm:(CCAlgorithm)algorithm Key:(NSString *)key iv:(NSString *)iv value:(NSData*)data {
  
    const char *keyPtr = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cIv = [iv cStringUsingEncoding:NSASCIIStringEncoding];
    NSData* result = nil;
    NSUInteger dataLength = [data length];

    size_t bufferSize = dataLength + kCCBlockSizeRC2;
    void *buffer = malloc(bufferSize);
    //kCCBlockSizeAES128
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmRC2,
                                          kCCOptionPKCS7Padding,keyPtr,
                                          32,
                                          cIv,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    } else {
        free(buffer);
        NSLog(@"[ERROR]加密失败|CCCryptoStatus: %d", cryptStatus);
    }
    
    return result;
}
//返回16位大小写字母和数字
+(NSString *)returnLetter:(int)number
{
    //定义一个包含数字，大小写字母的字符串
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //定义一个结果
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:number];
    for (int i = 0; i < number; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        [result appendFormat:@"%c", tempStr];
    }
    
    return [result copy];
}
/**
 计算字符串宽度
 
 @param str 字符串
 @param font 字体
 @param height 高度
 @return 宽度
 */
- (CGFloat)widthOfString:(NSString *)str andFont:(UIFont *)font andHeight:(CGFloat)height{
    return [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width;
}

+ (CGFloat)widthOfString:(NSString *)str andFont:(UIFont *)font andHeight:(CGFloat)height{
    return [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.width;
}
/**
 计算字符串的高度
 
 @param str 字符串
 @param font 字体
 @param width 宽度
 @return 高度
 */
- (CGFloat)heightOfString:(NSString *)str andFont:(UIFont *)font andWidth:(CGFloat)width{
    return [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.height;
}

/**
 画一条线
 
 @param frame 线frame
 @param color 线的颜色
 @param view 父View
 */
- (void)lineViewWithFrame:(CGRect)frame andColor:(UIColor *)color andView:(UIView *)view{
    UIView *lineView = [[UIView alloc]initWithFrame:frame];
    lineView.backgroundColor = color;
    lineView.tag = 131411;
    [view addSubview:lineView];
}
/**
 MD5加密
 
 @param input 要加密的字符串
 @return 加密好的字符串
 */

- (NSString *) md5:(NSString *) input {
    
    const char *cStr = [input UTF8String];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr,(int32_t)strlen(cStr),digest); // This is the md5 call
    
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    
    [output appendFormat:@"%02x", digest[i]];
    
    
    return output;
    
}

-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    
    int ci;
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *dt1 = [[NSDate alloc]init];
    
    NSDate *dt2 = [[NSDate alloc]init];
    
    dt1 = [df dateFromString:date01];
    
    dt2 = [df dateFromString:date02];
    
    NSComparisonResult result = [dt1 compare:dt2];
    
    switch (result)
        
    {
            
            //date02比date01大
        case NSOrderedAscending:
            ci = 1;
            break;
            //date02比date01小
        case NSOrderedDescending:
            ci = -1;
            break;
            //date02=date01
        case NSOrderedSame:
            ci = 0;
            break;
        default:
            NSLog(@"erorr dates %@, %@", dt2, dt1);
            break;
    }
    
    return ci;
    
}

- (NSArray <NSTextCheckingResult *> *)machesWithPattern:(NSString *)pattern  andStr:(NSString *)str
{
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error)
    {
        NSLog(@"正则表达式创建失败");
        return nil;
    }
    return [expression matchesInString:str options:0 range:NSMakeRange(0, str.length)];
}
//退出登录函数
-(void)quitLogin:(BOOL)relogin
{
    [[NSNotificationCenter defaultCenter]postNotificationName:KLogOutNotification object:nil];
    if (relogin) {
        ///被挤下去
        
        [self logout];
    }
    ///主动退出
    [self logOutRequestIfAutologin:nil codeNum:nil];
}

-(void)logOutRequestIfAutologin:(nullable NSString*)phoneNum codeNum:(nullable NSString*)codeNum{
    WeakSelf
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:30];
    [MobClick profileSignOff];
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Login.logout" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if (code == 0) {
            [strongSelf logoutIfAutologin:phoneNum codeNum:codeNum];
        }else{
            //            [MBProgressHUD showError:msg];
            [strongSelf logoutIfAutologin:phoneNum codeNum:codeNum];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        [strongSelf logoutIfAutologin:phoneNum codeNum:codeNum];
    }];
}

-(void)logout{
    
    [self logoutIfAutologin:nil codeNum:nil];
}


-(void)logoutIfAutologin:(NSString*)phoneNum codeNum:(NSString*)codeNum
{
    if ([Config getOwnID] == nil) {
        return;
    }
//    [JMSGUser logout:^(id resultObject, NSError *error) {
//        if (!error) {
//            NSLog(@"极光IM退出登录成功");
//        } else {
//            NSLog(@"极光IM退出登录失败");
//        }
//    }];
//    NSString *aliasStr = [NSString stringWithFormat:@"youke"];
//    [JPUSHService setAlias:aliasStr callbackSelector:nil object:nil];
//    
//    [JMSGUser logout:^(id resultObject, NSError *error) {
//        if (!error) {
//            //退出登录成功
//        } else {
//            //退出登录失败
//        }
//    }];
    [VideoTicketFloatView hideFloatView];
    [Config clearProfile];
    PhoneLoginVC *login = [[PhoneLoginVC alloc] initWithNibName:@"PhoneLoginVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    [login autoLoginWithPhoneNum:phoneNum codeNum:codeNum];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:login];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.type = kCATransitionMoveIn;
    animation.removedOnCompletion = YES;
    animation.subtype = kCATransitionFromTop;
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    
}
+(UIView *)mengban:(UIView *)mainView clickCallback:(mengbanBlock)clickCallback{
    UIView *shadowView = [[UIView alloc] init];
    shadowView.frame = CGRectMake(0, 0, _window_width, _window_height);
    shadowView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    shadowView.userInteractionEnabled = YES;
    shadowView.multipleTouchEnabled = NO;
    
    MYTapGestureRecognizer *singleTap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    singleTap.delegate = (id)self;
    // [singleTap setNumberOfTapsRequired:1];
    singleTap.block = clickCallback;
    singleTap.shadowView = shadowView;
    
    [shadowView addGestureRecognizer:singleTap];
    if(mainView == NULL){
        UIWindow * window =  [UIApplication sharedApplication].keyWindow ;
        [window addSubview:shadowView];
    }else{
        [mainView addSubview:shadowView];
    }
    return shadowView;
}
+ (BOOL)gestureRecognizer:(MYTapGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer.shadowView != touch.view)
    {
        return NO;
    }
    return YES;
}
+(void)tapDetected:(UITapGestureRecognizer *)tapRecognizer {
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    tap.block();
    [tap.shadowView removeFromSuperview];
}

+ (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    if(hours > 0){
        return [NSString stringWithFormat:YZMsg(@"YBToolClass_timeFormat_Hour%02ld_Min%02ld_Second%02ld"),(long)hours, minutes, seconds];
    }else if(minutes > 0){
        return [NSString stringWithFormat:YZMsg(@"YBToolClass_timeFormat_Min%02ld_Second%02ld"), minutes, seconds];
    }else{
        return [NSString stringWithFormat:YZMsg(@"YBToolClass_timeFormat_Second%02ld"), seconds];
    }
}

+ (NSString *)timeFormattedAge:(NSInteger)totalSeconds
{
    NSDate* tm = [NSDate dateWithTimeIntervalSince1970:totalSeconds];
    NSInteger tdiff = [[NSDate date] timeIntervalSinceDate:tm];
    NSString *tmStr = @"";
    if(tdiff < 60){
        tmStr = [NSString stringWithFormat:@"%ld秒前", (long)tdiff];
    }else if(tdiff < 3600){
        tmStr = [NSString stringWithFormat:@"%ld分钟前", (long)floor(tdiff/60.0)];
    }else if(tdiff < 3600*24){
        tmStr = [NSString stringWithFormat:@"%ld小时前", (long)floor(tdiff/60.0/60.0)];
    }else if(tdiff < 3600*24*365){
        tmStr = [NSString stringWithFormat:@"%ld天前", (long)floor(tdiff/60.0/60.0/365.0)];
    }
    
    return tmStr;
}

// 拉起客服
+ (void)showService{
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
        webH5 *VC = [[webH5 alloc]init];
        VC.urls = serverUrl;
        VC.bAllJump = YES;
        VC.titles = YZMsg(@"activity_login_connectkefu");
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    }];
    
}

- (void)closeService:(id)sender{
    if ([LaunchInitManager sharedInstance].serviceWindow) {
        [LaunchInitManager sharedInstance].serviceWindow.hidden = YES;
        [LaunchInitManager sharedInstance].serviceWindow.rootViewController = nil;
        [LaunchInitManager sharedInstance].serviceWindow = nil;
    }
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}



+ (NSString *)replaceUrlParams:(NSString *)url{
    if ([Config getOwnID] == nil || [Config getOwnID].length<1) {
        if ([DeviceUUID uuidForPhoneDevice].length>8) {
            url = [url stringByReplacingOccurrencesOfString:@"{uid}" withString:[[DeviceUUID uuidForPhoneDevice] substringToIndex:8]];
        }else{
            url = [url stringByReplacingOccurrencesOfString:@"{uid}" withString:@"000000"];
        }
        
    }else{
        url = [url stringByReplacingOccurrencesOfString:@"{uid}" withString:[Config getOwnID]];
    }
    if ([Config getOwnNicename] == nil ||[Config getOwnNicename].length<1) {
        url = [url stringByReplacingOccurrencesOfString:@"{name}" withString:@"未登录用户iOS"];
    }else{
        url = [url stringByReplacingOccurrencesOfString:@"{name}" withString:[Config getOwnNicename]];
    }
    if ([Config getOwnToken] == nil || [Config getOwnToken].length<1) {
        if ([DeviceUUID uuidForPhoneDevice].length>8) {
            url = [url stringByReplacingOccurrencesOfString:@"{token}" withString:[[DeviceUUID uuidForPhoneDevice] substringToIndex:8]];
        }else{
            url = [url stringByReplacingOccurrencesOfString:@"{uid}" withString:@"000000"];
        }
    }else{
        url = [url stringByReplacingOccurrencesOfString:@"{token}" withString:[Config getOwnToken]];
    }
    NSURL *urls = [NSURL URLWithString:url];
    if(urls == nil){
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    return url;
}

+(NSString*)aes_Decode:(NSString*)decodeStr
{
    NSString *aaa = @"我操你妈，看你妈逼";
    NSString *randomS = [[[RandomRule randomWithColumn:4 Line:4 seeds:aaa.length others:@{@"key1":@"250250250250",@"key2":@"14",@"key3":@"360360360"}] stringByReplacingOccurrencesOfString:@"," withString:@""] substringWithRange:NSMakeRange(0, 16)];
    NSString *a = @"E+WiacOhxL+b5zx3OqNUVnkWhTWzrCHduKu5BLyM3h0=";
    NSString *dat = [FFAES decryptBase64andAESToStr:decodeStr key:[FFAES decryptBase64andAESToStr:a key:randomS]];
    return dat;
}

+(NSString*)signAESNL{
    NSString *ivStr =[self returnLetter:16];
    NSString *sla = [self returnLetter:16];
    NSTimeInterval logTime = [YBToolClass LocalTime];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", logTime];
    NSString *aes = aesEncryptString([NSString stringWithFormat:@"FUCKYOU|%@|%@",timeSp,sla], @"pKSgtybLRv4AwBnG", ivStr);
    NSString *resultStr = [NSString stringWithFormat:@"%@%@",ivStr,aes];
    return resultStr;
}

+ (short)getDecimalScale:(NSDecimalNumber*)selectDecimalNumber currency:(NSString*)currency {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];
    short decimalScale = 2;
    NSDecimalNumber *rmbRateNumber = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSComparisonResult result = [selectDecimalNumber compare:rmbRateNumber];
    if (result == NSOrderedAscending && currency.floatValue <= 1) {
        decimalScale = 5;
    }
    return decimalScale;
}

+ (short)getDecimalNoScale:(NSDecimalNumber*)selectDecimalNumber currency:(NSString*)currency {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];
    short decimalScale = 3;
    NSDecimalNumber *rmbRateNumber = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSComparisonResult result = [selectDecimalNumber compare:rmbRateNumber];
    if (result == NSOrderedAscending && currency.floatValue <= 1) {
        decimalScale = 5;
    }
    return decimalScale;
}

+ (NSString *)getRateCurrency:(NSString *)currency showUnit:(BOOL)showUnit {
    return [YBToolClass getRateCurrency:currency showUnit:showUnit showComma:NO];
}

+ (NSString *)getNoScaleRateCurrency:(NSString *)currency showUnit:(BOOL)showUnit {
    return [YBToolClass getRateNoScaleCurrency:currency showUnit:showUnit showComma:NO];
}

+ (NSString *)getRateNoScaleCurrency:(NSString *)currency showUnit:(BOOL)showUnit showComma:(BOOL)showComma {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];

    NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    short decimalScale = [YBToolClass getDecimalNoScale:rateNumber currency:currency];
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                         decimalNumberHandlerWithRoundingMode:NSRoundDown
                                         scale:decimalScale
                                         raiseOnExactness:NO
                                         raiseOnOverflow:NO
                                         raiseOnUnderflow:NO
                                         raiseOnDivideByZero:YES];
    if (!currency) {
        currency = @"0";
    }
    NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:currency];
    if (rateNumber.floatValue > 0) {
        coinNumber = [coinNumber decimalNumberByMultiplyingBy:rateNumber withBehavior:roundDown];
    }

    NSString *formattedResult;
    if (showComma) {
        // 使用 NSNumberFormatter 格式化帶逗號的字串
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle; // 設定為數字格式（自動加逗號）
        formatter.maximumFractionDigits = 5; // 保留5位小數
        formatter.minimumFractionDigits = 0; // 不強制顯示小數位數
        formattedResult = [formatter stringFromNumber:coinNumber];
    } else {
        // 不顯示逗號，直接返回數字字串
        formattedResult = [NSString stringWithFormat:@"%@", coinNumber.stringValue];
    }

    // 處理千單位格式化後的結果
    if (rateNumber.floatValue > 1 && fabs(coinNumber.floatValue) >= 1000) {
        NSDecimalNumber *number1000 = [NSDecimalNumber decimalNumberWithString:@"1000.0"];
        coinNumber = [coinNumber decimalNumberByDividingBy:number1000 withBehavior:roundDown];
        formattedResult = [NSString stringWithFormat:@"%@k", showComma ? [formattedResult stringByReplacingOccurrencesOfString:@"," withString:@""] : coinNumber.stringValue];
    }

    return [NSString stringWithFormat:@"%@%@", (showUnit && [Config getRegionCurrenyChar]) ? [Config getRegionCurrenyChar] : @"", formattedResult];
}


+ (NSString *)getRateCurrency:(NSString *)currency showUnit:(BOOL)showUnit showComma:(BOOL)showComma {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];

    NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    short decimalScale = [YBToolClass getDecimalScale:rateNumber currency:currency];
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                         decimalNumberHandlerWithRoundingMode:NSRoundDown
                                         scale:decimalScale
                                         raiseOnExactness:NO
                                         raiseOnOverflow:NO
                                         raiseOnUnderflow:NO
                                         raiseOnDivideByZero:YES];
    if (!currency) {
        currency = @"0";
    }
    NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:currency];
    if (rateNumber.floatValue > 0) {
        coinNumber = [coinNumber decimalNumberByMultiplyingBy:rateNumber withBehavior:roundDown];
    }

    NSString *formattedResult;
    if (showComma) {
        // 使用 NSNumberFormatter 格式化帶逗號的字串
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle; // 設定為數字格式（自動加逗號）
        formatter.maximumFractionDigits = 2; // 保留兩位小數
        formatter.minimumFractionDigits = 0; // 不強制顯示小數位數
        formattedResult = [formatter stringFromNumber:coinNumber];
    } else {
        // 不顯示逗號，直接返回數字字串
        formattedResult = [NSString stringWithFormat:@"%@", coinNumber.stringValue];
    }

    // 處理千單位格式化後的結果
    if (rateNumber.floatValue > 1 && fabs(coinNumber.floatValue) >= 1000) {
        NSDecimalNumber *number1000 = [NSDecimalNumber decimalNumberWithString:@"1000.0"];
        coinNumber = [coinNumber decimalNumberByDividingBy:number1000 withBehavior:roundDown];
        formattedResult = [NSString stringWithFormat:@"%@k", showComma ? [formattedResult stringByReplacingOccurrencesOfString:@"," withString:@""] : coinNumber.stringValue];
    }

    return [NSString stringWithFormat:@"%@%@", (showUnit && [Config getRegionCurrenyChar]) ? [Config getRegionCurrenyChar] : @"", formattedResult];
}

+ (NSString *)getRateBalance:(NSString *)currency showUnit:(BOOL)showUnit {
    if (!currency) {
        currency = @"0";
    }
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSDecimalNumber *coinNumber;
    @try {
        coinNumber = [NSDecimalNumber decimalNumberWithString:currency];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        coinNumber = [NSDecimalNumber zero]; // 使用默认值
    }

    // 除以10，若需要处理异常情况可以使用带Handler的方法

    NSDecimalNumber *number10 = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                            scale:2
                                                                                 raiseOnExactness:NO
                                                                                  raiseOnOverflow:NO
                                                                                 raiseOnUnderflow:NO
                                                                          raiseOnDivideByZero:NO];

    coinNumber = [coinNumber decimalNumberByDividingBy:number10 withBehavior:handler];
    return [self getRateCurrency:coinNumber.stringValue showUnit:showUnit];
}

+ (NSString *)getRateCurrencyWithoutK:(NSString *)currency {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    short decimalScale = [YBToolClass getDecimalScale:rateNumber currency:currency];
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                         decimalNumberHandlerWithRoundingMode:NSRoundDown
                                         scale:decimalScale
                                         raiseOnExactness:NO
                                         raiseOnOverflow:NO
                                         raiseOnUnderflow:NO
                                         raiseOnDivideByZero:YES];
    if (!currency) {
        currency = @"0";
    }
    NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:currency];
    if (rateNumber.floatValue > 0) {
        coinNumber = [coinNumber decimalNumberByMultiplyingBy:rateNumber withBehavior:roundDown];
    }
    NSString *numSt = [NSString stringWithFormat:@"%@", coinNumber.stringValue];
    return numSt;
}

+ (NSString *)getRmbCurrency:(NSString *)currency {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSDecimalNumber *rateNumber = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                         decimalNumberHandlerWithRoundingMode:NSRoundDown
                                         scale:2
                                         raiseOnExactness:NO
                                         raiseOnOverflow:NO
                                         raiseOnUnderflow:NO
                                         raiseOnDivideByZero:YES];
    if (!currency) {
        currency = @"0";
    }
    NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:currency];
    if (rateNumber.floatValue > 0) {
        coinNumber = [coinNumber decimalNumberByDividingBy:rateNumber withBehavior:roundDown];
    }
    return [NSString stringWithFormat:@"%@", coinNumber.stringValue];
}

+ (NSString *)currencyCoverToK:(NSString *)currency {
    currency = [currency stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSDecimalNumberHandler *roundDown = [NSDecimalNumberHandler
                                         decimalNumberHandlerWithRoundingMode:NSRoundDown
                                         scale:2
                                         raiseOnExactness:NO
                                         raiseOnOverflow:NO
                                         raiseOnUnderflow:NO
                                         raiseOnDivideByZero:YES];
    if (!currency) {
        currency = @"0";
    }
    NSDecimalNumber *coinNumber = [NSDecimalNumber decimalNumberWithString:currency];
    if (fabs(currency.floatValue) >= 1000) {
        NSDecimalNumber *number1000 = [NSDecimalNumber decimalNumberWithString:@"1000.0"];
        coinNumber = [coinNumber decimalNumberByDividingBy:number1000 withBehavior:roundDown];
        currency = [NSString stringWithFormat:@"%@k", coinNumber.stringValue];
    }
    return currency;
}

+ (NSString *)getCurrentDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];

    // iPhone models
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE 2";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
    if ([deviceModel isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
    if ([deviceModel isEqualToString:@"iPhone14,2"])   return @"iPhone 13 Pro";
    if ([deviceModel isEqualToString:@"iPhone14,3"])   return @"iPhone 13 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,6"])   return @"iPhone SE 3";
    if ([deviceModel isEqualToString:@"iPhone15,2"])   return @"iPhone 14";
    if ([deviceModel isEqualToString:@"iPhone15,3"])   return @"iPhone 14 Plus";
    if ([deviceModel isEqualToString:@"iPhone15,4"])   return @"iPhone 14 Pro";
    if ([deviceModel isEqualToString:@"iPhone15,5"])   return @"iPhone 14 Pro Max";

    // iPod models
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";

    // iPad models
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    // Apple TV models
    if ([deviceModel isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";

    // Simulator
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";

    return deviceModel;
}


-(NSString*)getCPUType
{
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);

    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);

    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86)
    {
            [cpu appendString:@"x86 "];
             // check for subtype ...

    } else if (type == CPU_TYPE_ARM)
    {
            [cpu appendString:@"ARM"];
            switch(subtype)
            {
                    case CPU_SUBTYPE_ARM_V7:
                    [cpu appendString:@"V7"];
                    break;
                    // ...
            }
    }
    return cpu;
}
-(BOOL)hasProximityMonitoring{ // 传感器的开启与关闭
    [UIDevice currentDevice].proximityMonitoringEnabled = true;
    // 可用性检测
    if (![UIDevice currentDevice].proximityMonitoringEnabled) {
        return false;;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIDevice currentDevice].proximityMonitoringEnabled = false;
    });
    return true;
}
-(NSString*)systemVersion
{
    return [UIDevice currentDevice].systemVersion;;
}
-(NSString*)iphoneName{
    return [UIDevice currentDevice].name;
}
-(BOOL)isInstallDouying
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"snssdk1128://"]])
    {
        return false;
    }else{
        return true;
    }
        
}
-(BOOL)isInstallAlipay
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]])
    {
        return false;
    }else{
        return true;
    }
        
}
-(BOOL)isInstallQQ
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]])
    {
        return false;
    }else{
        return true;
    }
        
}
-(BOOL)isInstallWeixin
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]] && ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]])
    {
        return false;
    }else{
        return true;
    }
        
}

-(NSDictionary*)checkUserPhoneDevice
{
    NSDictionary *dicDeviceInfo = @{@"cpu":[self getCPUType],@"bluetooth_name":[self iphoneName],@"have_light":@([self hasProximityMonitoring]),@"system_ver":[self systemVersion],@"have_app_dy":@([self isInstallDouying]),@"have_app_qq":@([self isInstallQQ]),@"have_app_wx":@([self isInstallWeixin]),@"have_app_alipay":@([self isInstallAlipay])};
    
    return dicDeviceInfo;
}

-(void)taskJumpWithTaskID:(NSInteger)taskID
{
    switch (taskID) {
        case 1:
        case 4:
        case 7:
        case 8:
            [YBToolClass pushRecharge];
            break;
        case 2:
        case 6:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 16:
        {
            GameHomeMainVC *VC = [[GameHomeMainVC alloc] init];
            [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
        }
            
            break;
        case 3:
        case 5:
        case 15:
        {
            myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
            withdraw.titleStr = YZMsg(@"public_WithDraw");
            [[MXBADelegate sharedAppDelegate] pushViewController:withdraw animated:YES];
        }
            
            break;
            
        default:
            break;
    }
}

+(NSDictionary *)getUrlParamWithUrl:(NSString*)urlst
{
    if (urlst==nil || urlst.length<1) {
        return nil;
    }
    // 解析 URL
//    urlst = [urlst stringByReplacingOccurrencesOfString:@"thirdgame://" withString:@"https://www.fuckyousss.com"];
    NSString *encodedString = [urlst stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSURL *url = [NSURL URLWithString:encodedString];
    if (url == nil) {
        return nil;
    }
    NSString *queryEncode = [url query];
    NSString *decodedQuery = [YBToolClass URLDecode:queryEncode];
    
    // 分割参数
    NSArray *queryComponents = [decodedQuery componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    // 构建字典
    for (NSString *pair in queryComponents) {
        NSArray *pairComponents = [pair componentsSeparatedByString:@"="];
        if ([pairComponents count] == 2) {
            NSString *key = pairComponents[0];
            NSString *value = pairComponents[1];
            [params setObject:value forKey:key];
        }
    }
    return params;
}
+ (NSString *)URLDecode:(NSString *)string {
    NSString *decodedString = [string stringByRemovingPercentEncoding];
    return decodedString;
}

+(void)pushRecharge{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [[MXBADelegate sharedAppDelegate].navigationViewController pushViewController:payView animated:1];
}

+ (NSString *)decrypt_sdk_key {
    if ([PublicObj checkNull:[YBToolClass sharedInstance].decrypt_sdk_key]) {
        [YBToolClass sharedInstance].decrypt_sdk_key = @"ZjJhNTIzODAtNGU0ZDUzMjEtY29tLmh0LmFiY2RlZg==-XoE58g9uf0UIrY4CHHwkDXWLaHPIHkkdhFYIgbqt4vGv3kctbfzaDpzBjTIdIVodmaEfzXRcWr5ZNXC+VlJtFbBO4U7ZlwByYdP9Qj30iR7UfLp59nc1Ar+NUAVjdLmpB4JMqRQEfL6r7aLMqSNNioRtlXdqenrrtdjDdgHxEzLO3ti1OkC0YAv+FptNJ2WHJx/IAJzSvo9St0otTl7RrP41X86MUiqY2wYDKX+VsZ4VQijOjPi/Qz42QWyro3DyWHen5IGTMywn3cVb/egC8Bt8LgpCt+FH3pOM9cg8fKRQ4m9kX53ceH7F9gc5SRxm1mT3SnCOTsGCG6bG5zJa6w==";
    }
    return [YBToolClass sharedInstance].decrypt_sdk_key;
}

-(void)checkNetworkflow
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return ;
    }
    
    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
//    struct timeval32 time;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
//            time = if_data->ifi_lastchange;
        }
        
        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }
        
        //3G and gprs flow
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    

    if (_iBytes != 0) {
        self.receivedNetworkSpeed = [self bytesToAvaiUnit:iBytes - _iBytes];
    }
    
    _iBytes = iBytes;
    
    if (_oBytes != 0) {
        self.sendNetworkSpeed = [self bytesToAvaiUnit:oBytes - _oBytes];
    }
    _oBytes = oBytes;
}

-(NSString *)bytesToAvaiUnit:(int)bytes
{
    if(bytes < 1024)     // B
    {
        return [NSString stringWithFormat:@"%db", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.1fkb", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)   // MB
    {
        return [NSString stringWithFormat:@"%.1fmb", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.1fgb", (double)bytes / (1024 * 1024 * 1024)];
    }
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary {
    if (dictionary==nil || dictionary.allKeys.count<1) {
        return @"";
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *encodedKey = [YBToolClass urlEncode:key];
        NSString *encodedValue = [YBToolClass urlEncode:[obj description]]; // 将值转换为字符串
        NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString:@"&"];
}

+ (NSString *)urlEncode:(NSString *)string {
    NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

+ (NSString *)customEncodeURLWithCharacterSet:(NSString *)urlString {
    // 创建一个可变的字符集，允许 URL 查询中的常见字符
    NSCharacterSet *customAllowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];

    NSMutableCharacterSet *mutaCus = [customAllowedCharacterSet mutableCopy];
    // 从字符集中移除 `-`，这样 `-` 将被视为不安全字符，强制编码
    [mutaCus removeCharactersInString:@"-"];

    // 使用自定义字符集进行编码
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:mutaCus];

    return encodedString;
}


+ (BOOL)isURLEncoded:(NSString *)string {
    // 如果包含非 URL 安全的字符，说明未编码
    NSCharacterSet *unsafeCharacters = [NSCharacterSet characterSetWithCharactersInString:@"!#$&'()*+,/:;=?@[] "];
    return [string rangeOfCharacterFromSet:unsafeCharacters].location == NSNotFound;
}

//所有h5需要拼接uid和token
+(NSString *)addurl:(NSString *)url{
    return [url stringByAppendingFormat:@"&uid=%@&token=%@&l=%@",[Config getOwnID],[Config getOwnToken],[YBNetworking currentLanguageServer]];
}


+(NSString*)decodeReplaceUrl:(NSString*)url{
    url = [YBToolClass replaceUrlParams:url];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    if (components.host == nil) {
        return url;
    }
    NSString *urlHost = components.host;
    if(urlHost && [url containsString:[urlHost stringByAppendingString:@":"]]){
        NSString *exStr = [[url stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        NSArray * arr = [exStr componentsSeparatedByString:@"/"];
        if(arr.count > 0){
            NSString *strDomain  = arr[0];
            if(strDomain!= nil && [strDomain containsString:urlHost]){
                urlHost = strDomain;
            }
        }
    }
    
    
    BOOL hasContent = NO;
 
    for (NSString *dd in [DomainManager sharedInstance].domainsALLSaved) {
        NSString *ddddsds;
        if ([urlHost containsString:@":"]) {
            ddddsds = [[urlHost componentsSeparatedByString:@":"] firstObject];
        } else {
            ddddsds = urlHost;
        }
        
        if ([dd containsString:ddddsds]) {
            hasContent = YES;
        }
    }
    if ([urlHost containsString:@"127.0.0."]||[urlHost containsString:[DomainManager sharedInstance].domainString]) {
        hasContent = true;
    }

    if (hasContent) {
        url = [[[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://%@",urlHost] withString:[DomainManager sharedInstance].domainGetString]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"https://%@",urlHost] withString:[DomainManager sharedInstance].domainGetString] stringByReplacingOccurrencesOfString:@"v1/v1/" withString:@"v1/"];
        
        
        url = [YBToolClass addurl:url];
    }
    
    return url;
}

// 喜欢，播放量，直播间人数。 还有 游戏在线人数
+ (NSString *)formatLikeNumber:(NSString *)number {
    NSNumberFormatter *returnFormatter = [[NSNumberFormatter alloc] init];
    returnFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    returnFormatter.maximumFractionDigits = 1;
    returnFormatter.roundingMode = NSNumberFormatterRoundDown;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *num = [formatter numberFromString:number];
    if (!num) {
        return @"0";
    }
    long long count = [num longLongValue];

    // 获取当前语言
    NSString *currentLanguage = [RookieTools currentLanguageServer];

    // 检查当前语言是否为简体中文或繁体中文
    if ([currentLanguage containsString:@"zh-cn"] || [currentLanguage containsString:@"zh-cht"]) {
        if (count >= 10000) { // 万以上显示“万”或“萬”，保留一位小数
            NSString *unit = [currentLanguage containsString:@"zh-cn"] ? @"万" : @"萬";
            double value = count / 10000.0;
            return [NSString stringWithFormat:@"%@%@", [returnFormatter stringFromNumber:@(value)], unit];
        } else {
            if (count < 0) {
                count = 0;
            }
            return [NSString stringWithFormat:@"%lld", count]; // 小于万显示整数
        }
    } else {
        // 英文或其他语言显示
        if (count >= 1000000000) { // 十亿以上显示 B
            double value = count / 1000000000.0;
            return [NSString stringWithFormat:@"%@B", [returnFormatter stringFromNumber:@(value)]];
        } else if (count >= 1000000) { // 百万以上显示 M
            double value = count / 1000000.0;
            return [NSString stringWithFormat:@"%@M", [returnFormatter stringFromNumber:@(value)]];
        } else if (count >= 1000) { // 千以上显示 K
            double value = count / 1000.0;
            if (count % 1000 == 0) {
                return [NSString stringWithFormat:@"%.0fk", value];
            } else {
                return [NSString stringWithFormat:@"%@k", [returnFormatter stringFromNumber:@(value)]];
            }
        } else {
            return [NSString stringWithFormat:@"%lld", count]; // 小于千显示整数
        }
    }
}

- (void)setNoticeSwitch:(BOOL)noticeSwitch {
    vkUserSet(@"kNoticeSwitchKey", @(noticeSwitch));
}

- (BOOL)noticeSwitch {
    id value = vkUserGet(@"kNoticeSwitchKey");
    if (!value) {
        return YES;
    }
    return [value boolValue];
}

+(NSTimeInterval)LocalTime {
    return [[NSDate date] timeIntervalSince1970]+[SkyShield shareInstance].getCaculateTime;
}
@end
