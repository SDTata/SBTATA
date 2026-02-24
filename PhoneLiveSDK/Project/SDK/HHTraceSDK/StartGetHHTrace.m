//
//  HSShare.m
//  HSShareSDK
//
//  Created by aa on 2020/10/13.
//

#import "StartGetHHTrace.h"
#import "HHTools.h"
#import <sys/utsname.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <CommonCrypto/CommonCrypto.h>
#import "HHTrace.h"
#import "DeviceUUID.h"

static NSString *KEY_HHTRACE_ID = @"key_hhtrace_id";

static NSString *KEY_HHTRACE_ReportInstall = @"key_hhtrace_ReportInstal";


@interface StartGetHHTrace ()

@end
static StartGetHHTrace *_instance;

@implementation StartGetHHTrace

/**
 初始化
 */
+ (StartGetHHTrace *)shareInstance{
    
    @synchronized(self)
    {
        if (_instance == nil)
        {
            _instance = [[StartGetHHTrace alloc]init];
        }
        return _instance;
    }
}


-(NSString*)getTraceIDStr
{
    NSString *traceIDStr = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_HHTRACE_ID];
    if ([PublicObj checkNull:traceIDStr]) {
        return nil;
    }else{
        return traceIDStr;
    }
}

-(void)setTraceIDStr:(NSString*)traceIDStr
{
    if ([PublicObj checkNull:traceIDStr]) {
        [[NSUserDefaults standardUserDefaults] setObject:traceIDStr forKey:KEY_HHTRACE_ID];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

//看是否首次安装
-(BOOL)getisAppInstalled
{
    BOOL isInstall = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_HHTRACE_ReportInstall];
    return isInstall;
}
-(void)setisAppInstalled:(BOOL)isInstalled
{
    [[NSUserDefaults standardUserDefaults] setBool:isInstalled forKey:KEY_HHTRACE_ReportInstall];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


//SDK当前版本
+ (NSString *)getSDKVersion{
    return @"1.3.2.1";
}

static int numberTryOp2 = 0;
//获取渠道信息，安装参数
+ (void)getInstallTrace:(void (^ _Nullable)(HHTraceData * _Nullable traceData))success :(void (^ _Nullable)(NSString * _Nonnull failString))fail{
    [StartGetHHTrace shareInstance].deviceID  = [DeviceUUID uuidForPhoneDevice];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data]!=nil){
        NSDictionary *dic =[[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data];
        HHTraceData *hsdata = [[HHTraceData alloc]init];
        if ([StartGetHHTrace exist:[dic[@"data"] valueForKey:@"ch"]]) {
            hsdata.channel =[dic[@"data"] valueForKey:@"ch"];
        }
        if ([StartGetHHTrace exist:[dic[@"data"]  valueForKey:@"pr"]]) {
            hsdata.parameters =[dic[@"data"]  valueForKey:@"pr"];
        }
        [[HHTrace shareInstance] putContentLog:[@"加载缓存渠道" stringByAppendingFormat:@"%@|%@",hsdata.channel,hsdata.parameters]];
        success(hsdata);
        
    }else{
        if ([StartGetHHTrace getAppKey].length>0) {
           
            [[HHTools shareInstance] getPasteboardString:^(NSString *pastedBoardStr) {
                NSString *tid = @"";
                if ([StartGetHHTrace exist:pastedBoardStr]) {
                    NSString *str=pastedBoardStr;
                    if ([str rangeOfString:@"-ht-"].location!=NSNotFound) {
                        str = [str stringByReplacingOccurrencesOfString:@"-ht-" withString:@""];
                        tid =[StartGetHHTrace base64Decode:str];
                    }
                }
                NSDictionary *dic = @{
                    @"sw":[StartGetHHTrace s_width],
                    @"sh":[StartGetHHTrace s_height],
                    @"ss":[StartGetHHTrace s_scale],
                    @"glr":@"",
                    @"glv":@"",
                    @"li":[StartGetHHTrace localIPAddress],
                    @"md":[StartGetHHTrace iphoneType],
                    @"ak":[StartGetHHTrace getAppKey],
                    @"ver":[StartGetHHTrace iphoneVersion],
                    @"tid":tid?tid:@"",
                    @"bu":[StartGetHHTrace pkg],
                    @"ymid":[StartGetHHTrace shareInstance].deviceID
                };
                [HHTools postWithUrlString:@"?s=Report.Index.Igch" parameters:dic success:^(NSDictionary *data) {
                    if ([data allKeys]>0) {
                        [[NSUserDefaults standardUserDefaults] setValue:data forKey:HSShare_data];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        NSDictionary *dic =[[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data];
                        HHTraceData *hsdata = [[HHTraceData alloc]init];
                        if ([StartGetHHTrace exist:[dic[@"data"] valueForKey:@"ch"]]) {
                            hsdata.channel =[dic[@"data"] valueForKey:@"ch"];
                        }
                        if ([StartGetHHTrace exist:[dic[@"data"]  valueForKey:@"pr"]]) {
                            hsdata.parameters =[dic[@"data"]  valueForKey:@"pr"];
                        }
                        NSString *tidStr = [dic[@"data"] valueForKey:@"tid"];
                        [[StartGetHHTrace shareInstance]setTidCopy:tidStr];
                        [[StartGetHHTrace shareInstance]setTraceIDStr:tidStr];
                        success(hsdata);
                    }else{
                        HHTraceData *hsdata = [[HHTraceData alloc]init];
                        success(hsdata);
                    }
                    if ([StartGetHHTrace exist:data[@"msg"]]) {
                        NSLog(@"HSShare_SDK____%@",data[@"msg"]);
                      
                    }
                    [[HHTrace shareInstance] putContentLog:[@"加载返回消息msg" stringByAppendingFormat:@"%@",data[@"msg"]]];
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                    if (numberTryOp2<5) {
                        numberTryOp2++;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[HHTrace shareInstance] putContentLog:[@"加载失败重试 次数 " stringByAppendingFormat:@"%d,错误信息:%@",numberTryOp2,error.localizedDescription]];
                            [StartGetHHTrace getInstallTrace:success :fail];
                        });
                    }else{
                        fail(@"error");
                    }
                }];
            }];
            
        }
        else{
            fail(@"APP_KEY配置错误");
        }
    }
}


+ (NSString *)pkg{
    if ([StartGetHHTrace exist:[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"]]) {
        return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    }
    return @"";
}
+ (NSString *)getAppKey{
    if ([StartGetHHTrace exist:[[NSBundle mainBundle].infoDictionary objectForKey:@"com.HHTrace.APP_KEY"]]) {
        return [[NSBundle mainBundle].infoDictionary objectForKey:@"com.HHTrace.APP_KEY"];
    }
    return @"";
}


//屏幕宽度
+(NSString *)s_width{
    return [NSString stringWithFormat:@"%.0f",[UIScreen mainScreen].bounds.size.width];
}
//屏幕高度
+(NSString *)s_height{
    return [NSString stringWithFormat:@"%.0f",[UIScreen mainScreen].bounds.size.height];
}
//scale
+(NSString *)s_scale{
    return [NSString stringWithFormat:@"%.0f",[UIScreen mainScreen].scale];
}
//手机系统版本
+ (NSString *)iphoneVersion {
    NSString * iphoneVersion = [[UIDevice currentDevice] systemVersion];
    return  iphoneVersion;
}
//手机内网IP地址
+ (NSString *)localIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    if ([address isEqualToString:@"error"]) {
        NSString *localIP = @"";
        struct ifaddrs *addrs;
        if (getifaddrs(&addrs)==0) {
            const struct ifaddrs *cursor = addrs;
            while (cursor != NULL) {
                if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
                {
                    //NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                    //if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                    {
                        localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                        break;
                    }
                }
                cursor = cursor->ifa_next;
            }
            freeifaddrs(addrs);
        }
        return localIP;
    }
    return address;
}
//手机型号
+ (NSString *)iphoneType{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

/**
 是否存在
 */
+ (BOOL)exist:(id __nullable)object{
    if ([object isKindOfClass:[NSNull class]]||object == nil
        ||([object isKindOfClass:[NSString class]]&&
           ([object isEqualToString:@""]||
            [object isEqualToString:@" "]||
            [object isEqualToString:@"  "]||
            [object isEqual:@"(null)"]||
            [object isEqualToString:@"<Null>"]))) {
        return NO;
    }
    return YES;
}

/**
 获取最上层控制器
 */
+ (UIViewController *)topViewController{
    UIViewController *resultVC;
    resultVC = [StartGetHHTrace _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [StartGetHHTrace _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [StartGetHHTrace _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [StartGetHHTrace _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

// base64解码
+ (NSString*)base64Decode:(NSString*)str {
    // 1.先把base64编码后的字符串转成二进制数据
    NSData* data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    // 2.把data转成字符串
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - MD5
+(NSString *)stringToMD5:(NSString *)str {
    //1.首先将字符串转换成UTF-8编码, 因为MD5加密是基于C语言的,所以要先把字符串转化成C语言的字符串
    const char *fooData = [str UTF8String];
    //2.然后创建一个字符串数组,接收MD5的值
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //3.计算MD5的值, 这是官方封装好的加密方法:把我们输入的字符串转换成16进制的32位数,然后存储到result中
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    /**
     第一个参数:要加密的字符串
     第二个参数: 获取要加密字符串的长度
     第三个参数: 接收结果的数组
     */
    //4.创建一个字符串保存加密结果
    NSMutableString *saveResult = [NSMutableString string];
    //5.从result 数组中获取加密结果并放到 saveResult中
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
    return saveResult;
}
@end
