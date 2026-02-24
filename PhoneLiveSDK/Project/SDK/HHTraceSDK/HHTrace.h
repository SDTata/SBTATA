//
//  HSShare.h
//  HSShareSDK
//
//  Created by aa on 2020/10/13.
//

#import <Foundation/Foundation.h>
#import "HHTraceData.h"
static NSString * _Nullable HSShare_data = @"HSShare_datas";
NS_ASSUME_NONNULL_BEGIN

@interface HHTrace : NSObject
+ (HHTrace *)shareInstance;

@property(nonatomic,strong)NSString *contentlogs;




//上报注册
+ (void)reportRegister:(NSString*)uid callback:(void (^ _Nullable)(BOOL success))callback;

//上报安装量 上报留存
+ (void)reportInstallTrace:(void (^ _Nullable)(HHTraceData * _Nullable traceData))success :(void (^ _Nullable)(NSString * _Nonnull failString))fail;


+ (NSString *)getSDKVersion;

//日志
-(void)putContentLog:(NSString*)logs;
-(void)uploadLog:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
