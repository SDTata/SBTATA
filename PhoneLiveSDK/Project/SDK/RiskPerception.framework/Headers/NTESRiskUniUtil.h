//
//  NTESRiskUniUtil.h
//  RiskPerception
//
//  Created by Netease on 2022/4/27.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESRiskUniUtil : NSObject

/**
 *  数据签名
 *
 *  @param dataString               需要签名的数据 data不能为空，若为空，返回nil
 *
 *  @return                 数据的签名值
 */
+ (NSString *)getDataSign:(NSString *)dataString;

/**
 *  数据签名
 *
 *  @param data                             需要签名的数据 data不能为空，若为空，返回nil
 *
 *  @return                 数据的签名值
 */
+ (NSString *)getDataSignWithData:(NSData *)data;

/**
 *  白盒加密 V2 版本
 *
 *  @param alg                              加密算法
 *  @param data                             需要加密的原文
 *  @param error                            错误信息
 *  @return                                 加密成功后的数据（base64编码后的字符串）
 */
+ (NSString *)safeCommToServer:(int)alg
                      withData:(NSData *)data
                         error:(NSError **)error;

/**
 *  白盒加密 V2 版本
 *
 *  @param alg                              加密算法
 *  @param data                             需要加密的原文
 *  @param error                            错误信息
 *  @return                                 加密成功后的数据（二进制）
 */
+ (NSData *)safeCommToServerByte:(int)alg
                        withData:(NSData *)data
                           error:(NSError **)error;

/**
 *  白盒解密（原接口）
 *
 *  @param alg                               加密算法
 *  @param timeout                           超时时间（秒）
 *  @param data                              配合查询需要的数据（base64编码后字符串的二进制），不需要时传空，详见接入文档。
 *  @param error                             错误信息
 *  @return                                  返回解密结果
 */
+ (NSData *)safeCommFromServer:(int)alg
                       timeout:(int)timeout
                      withData:(NSData *)data
                         error:(NSError **)error;

/**
 *  白盒解密 V2 版本
 *
 *  @param alg                               加密算法
 *  @param timeout                           超时时间（秒）
 *  @param string                            配合查询需要的数据（base64编码后的字符串），不需要时传空，详见接入文档。
 *  @param error                             错误信息
 *  @return                                  返回解密结果
 */
+ (NSData *)safeCommFromServer:(int)alg
                       timeout:(int)timeout
                    withString:(NSString *)string
                         error:(NSError **)error;
/**
 *  白盒解密 V2 版本
 *
 *  @param alg                               加密算法
 *  @param timeout                           超时时间（秒）
 *  @param data                              配合查询需要的数据（二进制），不需要时传空，详见接入文档。
 *  @param error                             错误信息
 *  @return                                  返回解密结果
 */
+ (NSData *)safeCommFromServerByte:(int)alg
                           timeout:(int)timeout
                          withData:(NSData *)data
                             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
