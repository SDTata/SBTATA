//
//  ChannelStatistics.m
//  phonelive
//
//  Created by 400 on 2020/9/22.
//  Copyright © 2020 toby. All rights reserved.
//

#import "ChannelStatistics.h"
#import "NSString+Extention.h"
#import "YBNetworking.h"
#import "DomainManager.h"
#import "DeviceUUID.h"
#import "HHTraceSDK.h"

#if !TARGET_IPHONE_SIMULATOR
#import <CorgiGameSDK.h>
#endif

#define APP_DOCUMENTS                [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define DocumentPaths(path)          [APP_DOCUMENTS stringByAppendingPathComponent:path]
#define ArchiveChannelStatisticsPath [NSString stringWithFormat:@"ChannelStatistics%@",[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] objectForInfoDictionaryKey:@"com.phonelive.plat"]]

@implementation ChannelsModel
MJExtensionCodingImplementation

@end

@interface ChannelStatistics()
{
    NSInteger timeOut;
    NSInteger timeOut1;
    BOOL isRequesting;

}
@end

@implementation ChannelStatistics



static ChannelStatistics* manager = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
            reportNumberForCode = 0;
        }
        
    });
    return manager;
}
-(void)channelsRequest:(ChannelStatisticsBlock)callbackValue
{
    NSString *defaulChannel = @"ios";//[NSString stringWithFormat:@"defaulChannel-%@",[DomainManager sharedInstance].domainCode];
    
    if (self.model.channelCode!= nil && self.model.channelCode.length>0) {
        
        if (![self.model.channelCode isEqualToString:[DomainManager sharedInstance].domainCode] && ![self.model.channelCode isEqualToString:@"ios"] && ![self.model.channelCode isEqualToString:defaulChannel]) {
            callbackValue(self.model);
            return;
        }
    }
    ChannelsModel *modelsChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:DocumentPaths(ArchiveChannelStatisticsPath)];
    
      //先获取剪切板的op参数
    self.model = [NSString pasteChannelDispose];
   
    if (modelsChannel) {
        self.model.pasteString = modelsChannel.pasteString;
        self.model.channelCode  = modelsChannel.channelCode;
        self.model.paramsDic = modelsChannel.paramsDic;
    }
    if (self.model.channelCode == nil||self.model.channelCode.length<1) {
        self.model.channelCode =  defaulChannel;
    }
    
    [self modelForString:self.model.paramsDic];
    __block BOOL isCallback = false;
    WeakSelf
#if !TARGET_IPHONE_SIMULATOR
 
    [[CorgiGameSDK defaultManager] getInstallParmsCompleted:^(CorgiGameData*_Nullable appData) {
        //在主线程中回调
        STRONGSELF
        if (appData.data) {//(动态安装参数)
           //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
            strongSelf.model.code = [appData.data objectForKey:@"code"];
            if (strongSelf.model.code!= nil && [self.model.code isEqualToString:@"false"]) {
                strongSelf.model.code = nil;
            }
            strongSelf.model.webUmidToken = [appData.data objectForKey:@"webUmidToken"];
            strongSelf.model.uaToken = [appData.data objectForKey:@"uaToken"];
        }
        if (appData.channelCode) {//(通过渠道链接或二维码安装会返回渠道编号)
            //e.g.可自己统计渠道相关数据等
            strongSelf.model.channelCode  = appData.channelCode;
        }
        if (appData.opCode==OPCode_timeout) {
            //获取参数超时，可在合适时机再去获取（可设置全局标识）
        }
        
        if (appData.opCode==OPCode_timeout||([PublicObj checkNull:strongSelf.model.channelCode] && [PublicObj checkNull:strongSelf.model.code])|| (![PublicObj checkNull:strongSelf.model.channelCode] && [strongSelf.model.channelCode isEqualToString:defaulChannel])) {
            
            [StartGetHHTrace getInstallTrace:^(HHTraceData * _Nullable traceData) {
                NSLog(@"渠道编码:%@,安装参数:%@",traceData.channel,traceData.parameters);
                STRONGSELF
                if(traceData.channel!= nil && traceData.channel.length>0){
                    strongSelf.model.channelCode  = traceData.channel;
                }
                if(traceData.parameters!= nil && traceData.parameters.length>0){
                    strongSelf.model.paramsDic = traceData.parameters;
                    [strongSelf modelForString:traceData.parameters];
                }
              
                if ([PublicObj checkNull:traceData.channel] && [PublicObj checkNull:traceData.parameters]) {
                    [[CorgiGameSDK defaultManager] getInstallParmsCompleted:^(CorgiGameData*_Nullable appData) {
                        //在主线程中回调
                        STRONGSELF
                        if (appData.data) {//(动态安装参数)
                           //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
                            strongSelf.model.code = [appData.data objectForKey:@"code"];
                            if (strongSelf.model.code!= nil && [self.model.code isEqualToString:@"false"]) {
                                strongSelf.model.code = nil;
                            }
                            strongSelf.model.webUmidToken = [appData.data objectForKey:@"webUmidToken"];
                            strongSelf.model.uaToken = [appData.data objectForKey:@"uaToken"];
                        }
                        if (appData.channelCode) {//(通过渠道链接或二维码安装会返回渠道编号)
                            //e.g.可自己统计渠道相关数据等
                            strongSelf.model.channelCode  = appData.channelCode;
                        }
                        if (appData.opCode==OPCode_timeout) {
                            //获取参数超时，可在合适时机再去获取（可设置全局标识）
                        }
                        dispatch_main_async_safe(^{
                            if (!isCallback) {
                                callbackValue(strongSelf.model);
                            }
                            isCallback = true;
                        });
                        
                    }];
                    return;
                }
                dispatch_main_async_safe(^{
                    if (!isCallback) {
                        callbackValue(strongSelf.model);
                    }
                    isCallback = true;
                });
            } :^(NSString * _Nonnull failString) {
                STRONGSELF
                
                if ([strongSelf.model.channelCode isEqualToString:[DomainManager sharedInstance].domainCode] || [strongSelf.model.channelCode isEqualToString:defaulChannel] || [strongSelf.model.channelCode isEqualToString:defaulChannel]) {
                    [[CorgiGameSDK defaultManager] getInstallParmsCompleted:^(CorgiGameData*_Nullable appData) {
                        //在主线程中回调
                        
                        if (appData.data) {//(动态安装参数)
                            //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
                            strongSelf.model.code = [appData.data objectForKey:@"code"];
                            if (strongSelf.model.code!= nil && [self.model.code isEqualToString:@"false"]) {
                                strongSelf.model.code = nil;
                            }
                            strongSelf.model.webUmidToken = [appData.data objectForKey:@"webUmidToken"];
                            strongSelf.model.uaToken = [appData.data objectForKey:@"uaToken"];
                        }
                        if (appData.channelCode) {//(通过渠道链接或二维码安装会返回渠道编号)
                            //e.g.可自己统计渠道相关数据等
                            strongSelf.model.channelCode  = appData.channelCode;
                        }
                        if (appData.opCode==OPCode_timeout) {
                            //获取参数超时，可在合适时机再去获取（可设置全局标识）
                        }
                        if (!isCallback) {
                            callbackValue(strongSelf.model);
                        }
                        isCallback = true;
                    }];
                }else{
                    if (!isCallback) {
                        callbackValue(strongSelf.model);
                    }
                    isCallback = true;
                }
            }];
            
            return;
        }
        
        
        dispatch_main_async_safe(^{
            if (!isCallback) {
                callbackValue(strongSelf.model);
            }
            isCallback = true;
        });
        
    }];
#endif
   
//    [StartGetHHTrace getInstallTrace:^(HHTraceData * _Nullable traceData) {
//        NSLog(@"渠道编码:%@,安装参数:%@",traceData.channel,traceData.parameters);
//        STRONGSELF
//        if(traceData.channel!= nil && traceData.channel.length>0){
//            strongSelf.model.channelCode  = traceData.channel;
//        }
//        if(traceData.parameters!= nil && traceData.parameters.length>0){
//            strongSelf.model.paramsDic = traceData.parameters;
//            [strongSelf modelForString:traceData.parameters];
//        }
//      
//        if ([PublicObj checkNull:traceData.channel] && [PublicObj checkNull:traceData.parameters]) {
//            [[OpenInstallSDK defaultManager] getInstallParmsCompleted:^(OpeninstallData*_Nullable appData) {
//                //在主线程中回调
//                STRONGSELF
//                if (appData.data) {//(动态安装参数)
//                   //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
//                    strongSelf.model.code = [appData.data objectForKey:@"code"];
//                    if (strongSelf.model.code!= nil && [self.model.code isEqualToString:@"false"]) {
//                        strongSelf.model.code = nil;
//                    }
//                    strongSelf.model.webUmidToken = [appData.data objectForKey:@"webUmidToken"];
//                    strongSelf.model.uaToken = [appData.data objectForKey:@"uaToken"];
//                }
//                if (appData.channelCode) {//(通过渠道链接或二维码安装会返回渠道编号)
//                    //e.g.可自己统计渠道相关数据等
//                    strongSelf.model.channelCode  = appData.channelCode;
//                }
//                if (appData.opCode==OPCode_timeout) {
//                    //获取参数超时，可在合适时机再去获取（可设置全局标识）
//                }
//                dispatch_main_async_safe(^{
//                    if (!isCallback) {
//                        callbackValue(strongSelf.model);
//                    }
//                    isCallback = true;
//                });
//                
//            }];
//            return;
//        }
//        dispatch_main_async_safe(^{
//            if (!isCallback) {
//                callbackValue(strongSelf.model);
//            }
//            isCallback = true;
//        });
//    } :^(NSString * _Nonnull failString) {
//        STRONGSELF
//        
//        if ([strongSelf.model.channelCode isEqualToString:[DomainManager sharedInstance].domainCode] || [strongSelf.model.channelCode isEqualToString:@"ios"] || [strongSelf.model.channelCode isEqualToString:defaulChannel]) {
//            [[OpenInstallSDK defaultManager] getInstallParmsCompleted:^(OpeninstallData*_Nullable appData) {
//                //在主线程中回调
//                
//                if (appData.data) {//(动态安装参数)
//                    //e.g.如免填邀请码建立邀请关系、自动加好友、自动进入某个群组或房间等
//                    strongSelf.model.code = [appData.data objectForKey:@"code"];
//                    if (strongSelf.model.code!= nil && [self.model.code isEqualToString:@"false"]) {
//                        strongSelf.model.code = nil;
//                    }
//                    strongSelf.model.webUmidToken = [appData.data objectForKey:@"webUmidToken"];
//                    strongSelf.model.uaToken = [appData.data objectForKey:@"uaToken"];
//                }
//                if (appData.channelCode) {//(通过渠道链接或二维码安装会返回渠道编号)
//                    //e.g.可自己统计渠道相关数据等
//                    strongSelf.model.channelCode  = appData.channelCode;
//                }
//                if (appData.opCode==OPCode_timeout) {
//                    //获取参数超时，可在合适时机再去获取（可设置全局标识）
//                }
//                if (!isCallback) {
//                    callbackValue(strongSelf.model);
//                }
//                isCallback = true;
//            }];
//        }else{
//            if (!isCallback) {
//                callbackValue(strongSelf.model);
//            }
//            isCallback = true;
//        }
//    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (!isCallback) {
            callbackValue(strongSelf.model);
        }
        isCallback = true;
    });
}

-(void)modelForString:(NSString*)paramStr
{
//    取自定义参数
//    ,分割数组成数组
//    :分割成key value
//
//    code是邀请码
//    webUmidToken 是设备指纹
//    uaToken 是人机token
//
//    webUmidToken、uaToken 在注册时 一并带给我
//
//    code用来绑定 上级 做推广分享用
//code:false,webUmidToken:T2gAj5b2fMCSAqhYXakgOGZvwbK8zqGdrz8uVOYBLIAx8ERTXZIfwC0trZPx1bHb4H4=,uaToken:140#ggQxkLaRzzWrBQo2+b7zKtN8s7aJIqg8D+tWjWa45p+OqDVAQjLEQA2a12PBqT6N4QiClp1zz/U8gUZAAzzx+oD496h/zzrb22U3lp1xzXTVV2EqlaOz2PD+VounUuI0MI2y7yDY5anrHRqjELrEkgNfA/QiOhM+WmdinbWBRuHQIKFof0VD+MxaTKNtyRO8Jl73zpMHIAadlawWQfx594psT03ZGPhPWVDFnvSgOQtPA8lFM1IobBmEIGe4iozvJFuzPOfImBKCa2SH7NItgc5s8lJaDXyoLstqLl1UNiJisTmG+1f/INcIWwaw3vZlJS4O3XWon4TBmBOpfG8dJXCtX8708z0efD8Yqdjb10lsDhaOQuJmcpjlH2i/CUgXyEKCneMSjGu2lV4j5itA9dY0QKA1S4hFIvWDs0G9oy8bmgUnMNNjBafiZagycvDJD/Y84yGHhhKhTA0nKnU3wJVPbRXmwBC9QY+FXxp98PpC4tcYLUQbOz+jG3DCj/9laAvnu37CjZy/LXuru032/dH1IfoE+1bT5dqWvPuiTsP2pSio45A0u9KK+rHNXeL1zT8yLb7AXor=
    NSMutableDictionary *dicModel = [NSMutableDictionary dictionary];
    if (paramStr!= nil && paramStr.length>0) {
        NSArray *paramArray = [paramStr componentsSeparatedByString:@","];
        if (paramArray.count>0) {
            for (NSString *subStr in paramArray) {
                NSArray *paramSubArray = [subStr componentsSeparatedByString:@":"];
                if (paramSubArray.count>1) {
                    NSString *key = paramSubArray[0];
                    NSString *value = paramSubArray[1];
                    if (key!= nil && value != nil && key.length>0&& value.length>0) {
                        [dicModel setObject:value forKey:key];
                    }
                    
                }
            }
        }
    }
    if (dicModel.count>0) {
        self.model.code = [dicModel objectForKey:@"code"];
        if (self.model.code!= nil && [self.model.code isEqualToString:@"false"]) {
            self.model.code = nil;
        }
        self.model.webUmidToken = [dicModel objectForKey:@"webUmidToken"];
        self.model.uaToken = [dicModel objectForKey:@"uaToken"];
    }
   

}

int numberRequestCode = 0;
//用户注册上报
-(void)reportRegister:(NSString*)uid report:(BOOL)report
{
    if (report) {
#if !TARGET_IPHONE_SIMULATOR
        [CorgiGameSDK reportRegister];
#endif
        [HHTrace reportRegister:uid callback:^(BOOL success) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KFirstRegister];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if(![ChannelStatistics sharedInstance].model || [PublicObj checkNull:[ChannelStatistics sharedInstance].model.code]){
                NSLog(@"验证码异常");
                [[HHTrace shareInstance] putContentLog:@"code为空"];
                [[HHTrace shareInstance] uploadLog:@"OP上报注册成功"];
                return;
            }
            [[HHTrace shareInstance] putContentLog:[NSString stringWithFormat:@"code:%@",[ChannelStatistics sharedInstance].model.code]];
            [[HHTrace shareInstance] uploadLog:@"OP上报注册"];
        }];
        reportNumberForCode = 0;
        [[ChannelStatistics sharedInstance] reportRequestCode];
    }else{
        reportNumberForCode = 0;
        [[ChannelStatistics sharedInstance] reportRequestCode];
        [[HHTrace shareInstance] uploadLog:@"OP上报后台丢量"];
    }
}
static int reportNumberForCode = 0;
-(void)reportRequestCode{
    if (reportNumberForCode>3) {
        return;
    }
    reportNumberForCode++;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if(self.model && self.model.code && self.model.code!= nil){
        [param setObject:self.model.code forKey:@"code"];
    }else{
        [param setObject:@"" forKey:@"code"];
    }
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setDistribut" withBaseDomian:YES andParameter:param data:nil success:^(int code, NSArray *info, NSString *msg) {
        if (code ==0) {
            
        }
    } fail:^(NSError *error) {
        numberRequestCode++;
        if (numberRequestCode<4) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [[ChannelStatistics sharedInstance] reportRequestCode];
            });
        }
        
    }];
}
@end

