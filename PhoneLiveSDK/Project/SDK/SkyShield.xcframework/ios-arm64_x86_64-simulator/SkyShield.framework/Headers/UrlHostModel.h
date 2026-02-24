//
//  UrlHostModel.h
//  SkyShieldDemo
//
//  Created by Co co on 2024/11/26.
//

/**
 * URL主机模型头文件
 * 用于配置和管理URL主机的相关属性
 */

#import <Foundation/Foundation.h>

/**
 * 时间类型枚举
 * 用于定义URL主机模型的时间单位
 */
typedef NS_ENUM(NSInteger, TypeForTime) {
    TypeForTimeDay,  ///< 表示天为单位
    TypeForTimeHour  ///< 表示小时为单位
};

/**
 * URL主机模型类
 * 用于配置和管理URL主机的相关属性
 */
@interface UrlHostModel : NSObject

/** 主机名称 */
@property (nonatomic,strong) NSString *name;

/** 时间类型，可选天或小时 */
@property (nonatomic,assign) TypeForTime type;

/** 是否使用HTTPS协议 */
@property (nonatomic,assign) BOOL isHttps;

/** 是否启用加密 */
@property (nonatomic,assign) BOOL isEncryption;

/**
 * 获取协议方案字符串
 * @return NSString 返回"http"或"https"
 */
-(NSString*)getSchemeString;

/**
 * 创建URL主机模型实例
 * @param name 主机名称
 * @param type 时间类型
 * @param isHttps 是否使用HTTPS
 * @param isEncryption 是否启用加密
 * @return UrlHostModel实例
 */
+ (instancetype)modelWithName:(NSString *)name type:(TypeForTime)type isHttps:(BOOL)isHttps isEncryption:(BOOL)isEncryption;

@end
