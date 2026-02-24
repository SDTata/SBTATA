//
//  NSObject+Cache.h
//  FUDemo
//
//  Created on 2025/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Cache)

/**
 保存对象到缓存
 
 @param object 需要缓存的对象
 @param key 缓存的键值
 */
+ (void)saveCache:(id)object forKey:(NSString *)key;

/**
 从缓存中加载对象
 
 @param key 缓存的键值
 @return 缓存的对象
 */
+ (instancetype)loadCacheForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
