//
//  NTESRiskUniConfiguration.h
//  RiskPerception
//
//  Created by Netease on 2022/4/27.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESRiskUniConfiguration : NSObject

/**
 * 设置透传ip和端口，透传2.0需要使用
 *
 * @param ip                  透传ip地址
 * @param port              透传端口号
 *
 * @return          是否设置成功
 */
+ (BOOL)setTransIPandPort:(NSString *)ip transPort:(int32_t)port;

+ (BOOL)setTransIP:(NSString *)ip transPort:(int32_t)port DEPRECATED_MSG_ATTRIBUTE("Please use [NTESRiskUniConfiguration setTransIPandPort:transPort:].");

/**
 * 设置服务器所属地区
 *
 * @param type              服务器类型(1:中国大陆;2:中国台湾3:其他区域。4：欧盟区域 默认大陆,不需要设置，如需接入台湾服务需要单独开通，请与商务联系。)
 */
+ (void)setServerType:(NSInteger)type;

/**
 * 设置渠道信息，供用户传入该app的渠道信息（App Store）
 *
 * @param channel              渠道信息
 */
+ (void)setChannel:(NSString *)channel;

/**
 * 设置额外信息，用户希望我们在数据上报中包含的额外信息，使用该接口设置，可多次调用
 *
 * @param value              设置额外信息的值
 * @param key                   设置额外信息的key
 */
+ (void)setExtraDataValue:(NSString *)value forKey:(NSString *)key DEPRECATED_MSG_ATTRIBUTE("Please use [NTESRiskUniConfiguration setExtraData:forValue:].");
/**
 * 设置额外信息，用户希望我们在数据上报中包含的额外信息，使用该接口设置，可多次调用
 *
 * @param key              设置额外信息的key
 * @param value          设置额外信息的值
 */
+ (void)setExtraData:(NSString *)key forValue:(NSString *)value;

/**
 * 设置代理闪退模式。（闪退仅发生在数据上报失败的情况下）
 *
 *  @param type             类型(0、不拦截代理 1、高危代理闪退 2、全部代理闪退（高危、低危））
 *
 */
+ (void)setVPNCrashType:(NSInteger)type;

/**
 * 设置通用访问的域名，即BASE_URL
 *
 *  @param host             域名
 *
 */
+ (void)setHost:(NSString *)host;


@end

NS_ASSUME_NONNULL_END
