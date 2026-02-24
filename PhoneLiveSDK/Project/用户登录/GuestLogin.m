//
//  GuestLogin.m
//  phonelive2
//
//  Created by 400 on 2021/4/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import "GuestLogin.h"
#import "ChannelStatistics.h"
#import "YBNetworking.h"
#import "DeviceUUID.h"
#import <FFAES/FFAES.h>
#import <FFAES/GTMBase64.h>
#import "RandomRule.h"
#import <Security/Security.h>
#import "XYDeviceInfoUUID.h"
#import "LaunchInitManager.h"
#import <UMCommon/UMCommon.h>

static NSString * const kKeychainService = @"MyAppService";
static NSString * const kKeychainAccessGroup = nil;
@implementation GuestLogin
static GuestLogin* manager = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
        }
        
    });
    return manager;
}

//加密
+(NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
      
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
      
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return [GTMBase64 stringByEncodingData:resultData];
//        return [self hexStringFromData:resultData];
  
    }
    free(buffer);
    return nil;
}
//// 普通字符串转换为十六进
//+ (NSString *)hexStringFromData:(NSData *)data {
//    Byte *bytes = (Byte *)[data bytes];
//    // 下面是Byte 转换为16进制。
//    NSString *hexStr = @"";
//    for(int i=0; i<[data length]; i++) {
//        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff]; //16进制数
//        newHexStr = [newHexStr uppercaseString];
//
//        if([newHexStr length] == 1) {
//            newHexStr = [NSString stringWithFormat:@"0%@",newHexStr];
//        }
//
//        hexStr = [hexStr stringByAppendingString:newHexStr];
//
//    }
//    return hexStr;
//}
+(NSString*)getEncodefp{
    NSDictionary *subDic = [[YBToolClass sharedInstance] checkUserPhoneDevice];
    NSString *jsonStr = [GuestLogin convertToJsonData:subDic];
    NSString *aaa = @"我操你妈，看你妈逼";
    NSString *randomS = [[[RandomRule randomWithColumn:4 Line:4 seeds:aaa.length others:@{@"key1":@"250250250250",@"key2":@"14",@"key3":@"360360360"}] stringByReplacingOccurrencesOfString:@"," withString:@""] substringWithRange:NSMakeRange(0, 16)];
    NSString *a = @"E+WiacOhxL+b5zx3OqNUVnkWhTWzrCHduKu5BLyM3h0=";
    NSString *encodeStr = [GuestLogin AES128Encrypt:jsonStr key:[FFAES decryptBase64andAESToStr:a key:randomS]]; //@"0123456789abcdef"
    return encodeStr;
}
+ (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}
static float delaynumC = 0.0;
-(void)loginWithGuest:(GuestLoginBlock)callback{
    
    if(([LaunchInitManager sharedInstance].wangyiToken == nil || [LaunchInitManager sharedInstance].wangyiToken.length<1) && !([DeviceUUID uuidFromWangyiDevice]!= nil && [DeviceUUID uuidFromWangyiDevice].length>0)){
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            delaynumC = delaynumC+ 0.1;
            if(([LaunchInitManager sharedInstance].wangyiToken == nil || [LaunchInitManager sharedInstance].wangyiToken.length<1) && !([DeviceUUID uuidFromWangyiDevice]!= nil && [DeviceUUID uuidFromWangyiDevice].length>0)){
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if(delaynumC>5){
                    [[LaunchInitManager sharedInstance] initWangyiToken:^(BOOL success) {
                        if (strongSelf == nil) {
                            return;
                        }
                        [strongSelf loginNetAction:callback];
                    }];
                }else{
                    if(strongSelf != nil){
                        [strongSelf loginWithGuest:callback];
                    }
                }
                
            }else{
                STRONGSELF
                if(strongSelf != nil){
                    [strongSelf loginNetAction:callback];
                }
            }
        });
    }else{
        [self loginNetAction:callback];
    }
    
   
}
-(void)loginNetAction:(GuestLoginBlock)callback{
    delaynumC = 0.0;
    NSString *password = [DeviceUUID uuidForPhoneDevice];
    __block BOOL isloginAction = false;
    WeakSelf
    [[ChannelStatistics sharedInstance] channelsRequest:^(ChannelsModel * _Nonnull appData) {
        //在主线程中回调
        
        [XYDeviceInfoUUID getWANIPAddress:^(NSString * _Nullable ipaddress) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            
            NSDictionary *Login = @{
                @"guest_pass":password?password:@"",
                @"pushid":[DeviceUUID uuidForPhoneDevice]?[DeviceUUID uuidForPhoneDevice]:@"",
                @"sub_plat":[DomainManager sharedInstance].domainCode,
                @"source":appData.channelCode?appData.channelCode:@"",
                @"fp":[GuestLogin getEncodefp]?[GuestLogin getEncodefp]:@"",
                @"device_mac":@"",
                @"net_ip":ipaddress?ipaddress:@"",
                @"webUmidToken":appData.webUmidToken?appData.webUmidToken:@"",
                @"acd_token":[LaunchInitManager sharedInstance].wangyiToken?[LaunchInitManager sharedInstance].wangyiToken:@"",
                @"acd_device":[DeviceUUID uuidFromWangyiDevice]?[DeviceUUID uuidFromWangyiDevice]:@"",
                @"ali_device":@"",
                @"uaToken":appData.uaToken?appData.uaToken:@"",
                @"deviceToken":[LaunchInitManager sharedInstance].aliToken?[LaunchInitManager sharedInstance].aliToken:@"",
            };
            [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 15;
            WeakSelf
            [[YBNetworking sharedManager] postNetworkWithUrl:@"Login.guestLogin" withBaseDomian:YES andParameter:Login data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 15;
                if (code == 0) {
                    if(![info isKindOfClass:[NSArray class]]|| [(NSArray*)info count]<=0){
                        [MBProgressHUD showError:msg];
                        return;
                    }
                    NSDictionary *infos = [info objectAtIndex:0];
                    LiveUser *userInfo = [[LiveUser alloc] initWithDic:infos];
                    [Config saveProfile:userInfo];
                    NSString *acd_device = infos[@"acd_device"];
                    if (acd_device && acd_device.length>0) {
                        [DeviceUUID setWangyiDevice:acd_device];
                    }
//                    NSString *ali_device = infos[@"ali_device"];
//                    if (ali_device && ali_device.length>0) {
//                        [DeviceUUID setAliDevice:ali_device];
//                    }
                    BOOL dfk = [infos[@"dfk"] boolValue];
                    BOOL dsm = [infos[@"dsm"] boolValue];
                    
                    //判断第一次登陆
                    NSString *isreg = minstr([infos valueForKey:@"isreg"]);
                    [[NSUserDefaults standardUserDefaults] setObject:minstr([infos valueForKey:@"isagent"]) forKey:@"isagent"];
                    if([isreg isEqualToString:@"1"] && !isloginAction){
                        [[ChannelStatistics sharedInstance] reportRegister:userInfo.ID report:!(dfk || dsm)];
                       
                    }
                    isloginAction = true;
                    [[MXBADelegate sharedAppDelegate] getAppConfig:^(NSString *errormsg, NSDictionary *json) {
                        STRONGSELF
                        if (!strongSelf) return;
                        callback(true,msg);
                    }];
                    [MobClick profileSignInWithPUID:[DomainManager sharedInstance].domainCode provider:[Config getOwnID]];
                    //login
                }else{
                    [MBProgressHUD showError:msg];
                    callback(false,msg);
                }
                
            }fail:^(NSError * _Nonnull error) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [YBNetworking sharedManager].manager.requestSerializer.timeoutInterval = 15;
                if ([error isKindOfClass:[NSError class]]) {
                    [MBProgressHUD showError:[NSString stringWithFormat:@"code:%ld_msg:%@",error.code,error.localizedDescription]];
                    callback(false,error.localizedDescription);
                }else if([error isKindOfClass:[NSString class]] || [error isKindOfClass:[NSMutableString class]]){
                    NSString *errorMsg = (NSString *)error;
                    [MBProgressHUD showError:errorMsg];
                    callback(false,errorMsg);
                }else{
                    callback(false,@"");
                }
            }];
            
        }];
        
    }];
}
@end
