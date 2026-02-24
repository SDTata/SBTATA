//
//  HSShare.m
//  HSShareSDK
//
//  Created by aa on 2020/10/13.
//

#import "HHTrace.h"
#import "HHTools.h"
#import <sys/utsname.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <CommonCrypto/CommonCrypto.h>
#import "AliyunLogProducer.h"
#import "DeviceUUID.h"
#import "StartGetHHTrace.h"
@interface HHTrace ()
@property(nonatomic,strong)LogProducerClient *clientLog;
@property(nonatomic,strong)Log* logAliyun;

@property(nonatomic,assign)BOOL isFirstStarApp;
@end
static HHTrace *_instance;

@implementation HHTrace

/**
 初始化
 */
+ (HHTrace *)shareInstance{
    
    @synchronized(self)
    {
        if (_instance == nil)
        {
            _instance = [[HHTrace alloc]init];
            _instance.isFirstStarApp = true;
            [_instance initLogs];
        }
        return _instance;
    }
}

-(void)initLogs
{
    NSString* endpoint = @"cn-shanghai.log.aliyuncs.com";
    NSString* project = @"a000-ios";
    NSString* logstore = @"op-logs";
   
    LogProducerConfig* configLog = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:aliaccesskeyid accessKeySecret:aliaccesskeysecret];
    // 设置主题
    [configLog SetTopic:@"iOS_OP日志"];
    // 设置tag信息，此tag会附加在每条日志上
    [configLog AddTag:@"plat_ID" value:[DomainManager sharedInstance].domainCode];
    [configLog AddTag:@"device_ID" value:[DeviceUUID uuidForPhoneDevice]];
    [configLog AddTag:@"system_version" value:[NSString stringWithFormat:@"%@ %@",APPVersionNumber,ios_buildVersion]];
    [configLog AddTag:@"user_ID" value:[Config getOwnID]?[Config getOwnID]:@""];

    self.clientLog = [[LogProducerClient alloc] initWithLogProducerConfig:configLog];
    self.logAliyun = [[Log alloc] init];
    
}

-(void)putContentLog:(NSString*)logs
{
    self.contentlogs = [NSString stringWithFormat:@"%@_%.3f\n",logs,[[NSDate date] timeIntervalSince1970]*1000];
}

-(void)uploadLog:(NSString*)title
{
    if (self.contentlogs!= nil && self.logAliyun) {
        [self.logAliyun PutContent:title value:self.contentlogs];
        // addLog第二个参数flush，是否立即发送，1代表立即发送，不设置时默认为0
        LogProducerResult res = [self.clientLog AddLog:self.logAliyun flush:0];
        if (res!= 0) {
            NSLog(@"日志发送失败");
        }
    }
    
}

//SDK当前版本
+ (NSString *)getSDKVersion{
    return @"1.3.2.1";
}

static int retryRegisterNumber;
+(void)registerPost:(NSString*)uid  callback:(void (^ _Nullable)(BOOL success))callback{
    NSDictionary *dic =[[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data];
    if ([HHTrace exist:[dic[@"data"] valueForKey:@"tid"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:uid forKey:@"HSShare_uid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *tid =[dic[@"data"] valueForKey:@"tid"];
        NSString *ch =@"";
        if ([HHTrace exist:[dic[@"data"] valueForKey:@"ch"]]) {
            ch =[dic[@"data"] valueForKey:@"ch"];
        }
        NSString *sign =[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",[HHTrace getAppKey],ch,[HHTrace iphoneType],@"Report.Index.IosReg",tid,uid,[HHTrace iphoneVersion],[StartGetHHTrace shareInstance].deviceID];
        NSDictionary *dic = @{
            @"tid":tid,
            @"ch":ch,
            @"ak":[HHTrace getAppKey],
            @"ver":[HHTrace iphoneVersion],
            @"md":[HHTrace iphoneType],
            @"sign":[HHTrace stringToMD5:sign],
            @"uid":uid,
            @"ymid":[StartGetHHTrace shareInstance].deviceID
        };
        [HHTools postWithUrlString:@"?s=Report.Index.IosReg" parameters:dic success:^(NSDictionary *data) {
            [[HHTrace shareInstance] putContentLog:[@"hhtrace加载注册完成msg" stringByAppendingFormat:@"%@",data[@"msg"]]];
            if ([HHTrace exist:data[@"msg"]]) {
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"HSShare_uid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"HSShare_SDK____%@",data[@"msg"]);
                [[HHTrace shareInstance] putContentLog:[@"hhtrace加载注册完成:" stringByAppendingFormat:@"%@",[data mj_JSONString]]];
                callback(true);
            }else{
                callback(false);
            }
        } failure:^(NSError *error) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                retryRegisterNumber++;
                if (retryRegisterNumber<5) {
                    [[HHTrace shareInstance] putContentLog:[@"hhtrace加载注册失败,次数" stringByAppendingFormat:@"%d,error:%@",retryRegisterNumber,error.localizedDescription]];
                    [HHTrace registerPost:uid callback:callback];
                }else{
                    [[HHTrace shareInstance] putContentLog:@"hhtrace加载注册失败,超过次数"];
                    callback(false);
                }
                
            });
            NSLog(@"%@",error);
        }];
    }else{
        [[HHTrace shareInstance] putContentLog:@"hhtrace注册失败,没有tid"];
        callback(false);
    }
}

//注册上报
+ (void)reportRegister:(NSString*)uid callback:(void (^ _Nullable)(BOOL success))callback
{
    if([HHTrace getAppKey]==nil||[HHTrace getAppKey].length<=0){
        NSLog(@"出错了，没有key");
        [[HHTrace shareInstance] putContentLog:@"hhtrace出错了，没有key"];
        callback(false);
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data]) {
        retryRegisterNumber = 0;
        [[HHTrace shareInstance] putContentLog:@"hhtrace从缓存注册上报"];
        [HHTrace registerPost:uid callback:callback];
    }else{
        [[HHTrace shareInstance] putContentLog:@"hhtrace从安装后注册上报"];
        [StartGetHHTrace getInstallTrace:^(HHTraceData * _Nullable traceData) {
            [HHTrace registerPost:uid callback:callback];
        } :^(NSString * _Nonnull failString) {
            
        }];
        
    }
}

static int numberTryOp3 = 0;
//获取渠道信息，安装参数
+ (void)reportInstallTrace:(void (^ _Nullable)(HHTraceData * _Nullable traceData))success :(void (^ _Nullable)(NSString * _Nonnull failString))fail{

    [[HHTools shareInstance] getPasteboardString:^(NSString *urlString) {
        if ([HHTrace getAppKey].length>0) {
            [StartGetHHTrace shareInstance].tidCopy = [[StartGetHHTrace shareInstance] getTraceIDStr];
            if ([StartGetHHTrace shareInstance].tidCopy == nil) {
                NSString *tid = @"";
                NSString *pastedBoardStr = [[HHTools shareInstance] getPasteboardString:nil];
                if ([HHTrace exist:pastedBoardStr]) {
                    NSString *str=pastedBoardStr;
                    if ([str rangeOfString:@"-ht-"].location!=NSNotFound) {
                        str = [str stringByReplacingOccurrencesOfString:@"-ht-" withString:@""];
                        tid =[HHTrace base64Decode:str];
                    }
                }

                [StartGetHHTrace shareInstance].tidCopy = tid;
                [[StartGetHHTrace shareInstance] setTraceIDStr:tid];
            }
            [HHTrace reportIosRetention];
            
            if ([[StartGetHHTrace shareInstance] getisAppInstalled]) {
                return;
            }
            
            NSDictionary *dic =[[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data];
            if (dic!= nil && [HHTrace exist:[dic[@"data"] valueForKey:@"tid"]]) {
                NSString *tid =[dic[@"data"] valueForKey:@"tid"];
                NSString *ch =@"";
                if ([HHTrace exist:[dic[@"data"] valueForKey:@"ch"]]) {
                    ch =[dic[@"data"] valueForKey:@"ch"];
                }
                
                NSDictionary *dic = @{
                    @"sw":[HHTrace s_width],
                    @"sh":[HHTrace s_height],
                    @"ss":[HHTrace s_scale],
                    @"glr":@"",
                    @"glv":@"",
                    @"li":[HHTrace localIPAddress],
                    @"md":[HHTrace iphoneType],
                    @"ak":[HHTrace getAppKey],
                    @"ver":[HHTrace iphoneVersion],
                    @"tid":tid?tid:@"",
                    @"bu":[HHTrace pkg],
                    @"ymid":[StartGetHHTrace shareInstance].deviceID
                };
                [HHTools postWithUrlString:@"?s=Report.Index.Ios" parameters:dic success:^(NSDictionary *data) {
                    if ([data allKeys]>0) {
                        [[NSUserDefaults standardUserDefaults] setValue:data forKey:HSShare_data];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        NSDictionary *dic =[[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data];
                        HHTraceData *hsdata = [[HHTraceData alloc]init];
                        if ([HHTrace exist:[dic[@"data"] valueForKey:@"ch"]]) {
                            hsdata.channel =[dic[@"data"] valueForKey:@"ch"];
                        }
                        if ([HHTrace exist:[dic[@"data"]  valueForKey:@"pr"]]) {
                            hsdata.parameters =[dic[@"data"]  valueForKey:@"pr"];
                        }
                        [[StartGetHHTrace shareInstance]setisAppInstalled:true];
                        [[HHTrace shareInstance] putContentLog:[@"hhtrace获取渠完成:" stringByAppendingFormat:@"%@",[hsdata mj_JSONString]]];
                        success(hsdata);
                        NSString *uidStr = [[NSUserDefaults standardUserDefaults]valueForKey:@"HSShare_uid"];
                        if ([HHTrace exist:uidStr]) {
                            [[HHTrace shareInstance] putContentLog:[@"hhtrace获取渠道信息，重新注册,UID:" stringByAppendingFormat:@"%@",uidStr]];
                            [HHTrace reportRegister:uidStr callback:^(BOOL success) {
                                
                            }];
                        }
                    }else{
                        [[HHTrace shareInstance] putContentLog:@"hhtrace获取渠道失败，返回空"];
                        HHTraceData *hsdata = [[HHTraceData alloc]init];
                        success(hsdata);
                    }
                    [[HHTrace shareInstance] putContentLog:[@"hhtrace获取渠道完成msg" stringByAppendingFormat:@"%@",data[@"msg"]]];
                    if ([HHTrace exist:data[@"msg"]]) {
                        NSLog(@"HSShare_SDK____%@",data[@"msg"]);
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                    if (numberTryOp3<5) {
                        numberTryOp3++;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[HHTrace shareInstance] putContentLog:[@"hhtrace获取渠道失败,次数" stringByAppendingFormat:@"%d,error:%@",numberTryOp3,error.localizedDescription]];
                            [HHTrace reportInstallTrace:success :fail];
                        });
                    }else{
                        fail(@"error");
                    }
                }];
            }
        }
        else{
            fail(@"APP_KEY配置错误");
        }
    }];
    
}

//留存
+ (void)reportIosRetention{
    if([HHTrace getAppKey]==nil||[HHTrace getAppKey].length==0 ||![HHTrace shareInstance].isFirstStarApp){
        return;
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data]) {
        NSDictionary *dic =[[NSUserDefaults standardUserDefaults] valueForKey:HSShare_data];
        if ([HHTrace exist:[dic[@"data"] valueForKey:@"tid"]]) {
            NSString *tid =[dic[@"data"] valueForKey:@"tid"];
            NSString *ch =@"";
            if ([HHTrace exist:[dic[@"data"] valueForKey:@"ch"]]) {
                ch =[dic[@"data"] valueForKey:@"ch"];
            }
            NSString *sign =[NSString stringWithFormat:@"%@%@%@%@%@%@%@",[HHTrace getAppKey],ch,[HHTrace iphoneType],@"Report.Index.IosRetention",tid,[HHTrace iphoneVersion],[StartGetHHTrace shareInstance].deviceID];
            NSDictionary *dic = @{
                @"tid":tid?tid:@"",
                @"ch":ch,
                @"ak":[HHTrace getAppKey],
                @"ver":[HHTrace iphoneVersion],
                @"md":[HHTrace iphoneType],
                @"sign":[HHTrace stringToMD5:sign],
                @"ymid":[StartGetHHTrace shareInstance].deviceID
            };
            NSLog(@"sign---%@",sign);
            [HHTools postWithUrlString:@"?s=Report.Index.IosRetention" parameters:dic success:^(NSDictionary *data) {
                if ([HHTrace exist:data[@"msg"]]) {
                    NSLog(@"HSShare_SDK____%@",data[@"msg"]);
                    [HHTrace shareInstance].isFirstStarApp = false;
                }
                [[HHTrace shareInstance] putContentLog:[@"hhtrace获取留存完成msg" stringByAppendingFormat:@"%@",data[@"msg"]]];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
                [[HHTrace shareInstance] putContentLog:[@"hhtrace获取留存失败msg" stringByAppendingFormat:@"%@",error.localizedDescription]];
            }];
        }
    }
}

+ (NSString *)pkg{
    if ([HHTrace exist:[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"]]) {
        return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
    }
    return @"";
}
+ (NSString *)getAppKey{
    if ([HHTrace exist:[[NSBundle mainBundle].infoDictionary objectForKey:@"com.HHTrace.APP_KEY"]]) {
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
    resultVC = [HHTrace _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [HHTrace _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [HHTrace _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [HHTrace _topViewController:[(UITabBarController *)vc selectedViewController]];
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
