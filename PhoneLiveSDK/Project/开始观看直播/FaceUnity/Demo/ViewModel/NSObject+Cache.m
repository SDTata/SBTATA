//
//  NSObject+Cache.m
//  FUDemo
//
//  Created on 2025/6/15.
//

#import "NSObject+Cache.h"

@implementation NSObject (Cache)

+ (void)saveCache:(id)object forKey:(NSString *)key {
    if (!object || !key) {
        return;
    }
    
    // 确保对象可以被归档
    if (![object conformsToProtocol:@protocol(NSCoding)]) {
        NSLog(@"保存缓存失败：对象不支持NSCoding协议");
        return;
    }
    
    NSString *cachePath = [self cachePathForKey:key];
    
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:nil];
        [data writeToFile:cachePath atomically:YES];
    } @catch (NSException *exception) {
        NSLog(@"保存缓存异常：%@", exception);
    }
}

+ (instancetype)loadCacheForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    
    NSString *cachePath = [self cachePathForKey:key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        return nil;
    }
    
    @try {
        NSData *data = [NSData dataWithContentsOfFile:cachePath];
        if (!data) {
            return nil;
        }
        
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return object;
    } @catch (NSException *exception) {
        NSLog(@"读取缓存异常：%@", exception);
        return nil;
    }
}

+ (NSString *)cachePathForKey:(NSString *)key {
    NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cacheDirectory = [cachesDirectory stringByAppendingPathComponent:@"FUBeautyCache"];
    
    // 确保缓存目录存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cache", key]];
}

@end
