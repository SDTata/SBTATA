//
//  NSObject+VKModel.m
//
//  Created by vick on 2020/12/14.
//

#import "NSObject+VKModel.h"
#import "VKCodeKit.h"

@implementation NSObject (VKModel)

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"id_": @"id",
        @"ID": @"id",
        @"default_": @"default",
        @"description_": @"description"
    };
}

#pragma mark - 数据转模型
+ (id)modelFromJSON:(id)json {
    return [self mj_objectWithKeyValues:json];
}

+ (NSArray *)arrayFromJson:(id)json {
    return [self mj_objectArrayWithKeyValuesArray:json];
}

- (NSDictionary *)toDict {
    return [self mj_keyValues];
}

- (NSString *)toJson {
    return [self mj_JSONString];
}

+ (NSString *)arrayToJson:(NSArray *)array {
  NSArray *results = [self mj_keyValuesArrayWithObjectArray:array];
  return vkToJson(results);
}

- (NSData *)toData {
    NSDictionary *dict = [self toDict];
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

+ (id)fromData:(NSData *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self modelFromJSON:dict];
}

+ (void)saveCache:(id)data forKey:(NSString *)key {
  if ([data isKindOfClass:[NSArray class]]) {
    NSString *json = [self arrayToJson:data];
    vkArchiveSet(key, json);
  } else {
    NSString *json = [data toJson];
    vkArchiveSet(key, json);
  }
}

+ (id)loadCacheForKey:(NSString *)key {
  NSString *json = vkArchiveGet(key);
  id data = vkFromJson(json);
  if ([data isKindOfClass:[NSArray class]]) {
    return [self arrayFromJson:data];
  } else {
    return [self modelFromJSON:data];
  }
}

@end
