//
//  NSObject+VKModel.h
//
//  Created by vick on 2020/12/14.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface NSObject (VKModel)

/// JSON转模型
+ (id)modelFromJSON:(id)json;

/// JSON转模型数组
+ (NSArray *)arrayFromJson:(id)json;

/// 模型转字典
- (NSDictionary *)toDict;

/// 模型转JSON
- (NSString *)toJson;

/// 模型数组转JSON
+ (NSString *)arrayToJson:(NSArray *)array;

/// 转二进制
- (NSData *)toData;

/// 二进制转模型
+ (id)fromData:(NSData *)data;

/// 数据缓存
+ (void)saveCache:(id)data forKey:(NSString *)key;

/// 读取缓存
+ (id)loadCacheForKey:(NSString *)key;

@end
