//
//  LovenseOrderHelper.h
//  DemoSdk
//
//  Created by Lovense on 2019/3/4.
//  Copyright © 2019 Hytto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lovense.h"
#import "LovenseToy.h"


NS_ASSUME_NONNULL_BEGIN

@interface LovenseHelper : NSObject

//设备uuid - 用于统计用户数量,规则LVS+生成的时间戳+六位随机数）如：LVS1552642801-123456
@property(nonatomic,strong)NSString * deviceUUID;

//是否已经验证了token
@property(nonatomic,assign)BOOL isHadVerifyTokened;
//是否验证成功
@property(nonatomic,assign)BOOL isVerifyPass;

//是否已经获取版本号
@property(nonatomic,assign)BOOL isGetVersion;
//玩具的版本号
@property(nonatomic,assign)int toyVersion;

///连接过的ToyID，用于日志上传判断
@property (nonatomic, strong) NSMutableSet<NSString *> * didConnectToyIDSet;

+ (LovenseHelper * _Nonnull)shared;

//验证token 同时 把appname和bundleid 发送到服务器
-(BOOL)isVerifyTokenPassWithToken:(NSString*)token;

/// 发送 --- 根据命令枚举 和 参数 生成字符串
-(NSArray*)getCommandArrayWithCommandType:(LovenseCommandType)commandType andToy:(LovenseToy*)nowToy andParamDict:(NSDictionary*)paramDict;

///验证是否有效的mac字符串
-(BOOL)isValidToyMac:(NSString*)macStr;

///验证是否全数字
-(BOOL)isAllInt:(NSString*)fullStr;

///通过字母获取玩具的类型
-(NSString*)getToyTypeWithWord:(NSString*)word;

/**
 十六进制转换为二进制
 @param hex 十六进制数
 @return 二进制数
 */
- (NSString *)getBinaryByHex:(NSString *)hex;

/**
 二进制转换为十进制
 @param binary 二进制数
 @return 十进制数
 */
- (NSInteger)getDecimalByBinary:(NSString *)binary;

//解析order
-(CGFloat)unwarpOrder:(NSString*)str;

///发送玩具连接日志
-(void)sendConnectToyLog:(LovenseToy *)toy symbol:(NSString *)symbol token:(NSString *)token;

@end

NS_ASSUME_NONNULL_END
