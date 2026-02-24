//
//  NSString+VKUtil.h
//  dev
//
//  Created by vick on 2021/5/15.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VKUtil)

/// MD5加密
- (NSString *)toMD5;

/// 字符串编码
- (NSString *)toEncoding;

/// 转时间
- (NSString *)toTime;

/// 转日期
- (NSString *)toDate;

/// 时间转换
- (NSString *)toDateFormatter:(NSString *)dateFormatter;

/// 去空格
- (NSString *)toBlank;

/// 转URL
- (NSURL *)toURL;

/// 解析请求参数
- (NSDictionary *)getURLParams;

/// 创建请求地址
- (NSString *)getURL:(NSDictionary *)dict;

@end
