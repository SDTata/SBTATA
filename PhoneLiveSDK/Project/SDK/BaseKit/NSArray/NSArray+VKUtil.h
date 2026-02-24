//
//  NSArray+VKUtil.h
//
//  Created by vick on 2021/3/9.
//

#import <Foundation/Foundation.h>

@interface NSArray (VKUtil)

/// 筛选
- (NSArray *)vk_filter:(NSString *)format, ...;

/// 筛选
- (NSArray *)filterBlock:(BOOL (^)(id object))block;

/// 反转
- (NSArray *)reverse;

/// 去重
- (NSArray *)unique;

/// cout个分割一组
- (NSArray *)sliceBy:(NSInteger)count;

/// 平均分割count组
- (NSArray *)sliceTo:(NSInteger)count;

/// 交集
- (NSArray *)intersectSet:(NSArray *)array;

/// 差集
- (NSArray *)minusSet:(NSArray *)array;

/// 并集
- (NSArray *)unionSet:(NSArray *)array;

/// 降序
- (NSArray *)sortedDesByKey:(NSString *)key;

/// 升序
- (NSArray *)sortedAscByKey:(NSString *)key;

/// 安全取值
- (id)safeObjectWithIndex:(NSUInteger)index;

@end
