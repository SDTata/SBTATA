//
//  NSString+VKUtil.m
//  dev
//
//  Created by vick on 2021/5/15.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "NSString+VKUtil.h"
#import<CommonCrypto/CommonDigest.h>
#import<CommonCrypto/CommonCrypto.h>
#import "VKCodeKit.h"

@implementation NSString (VKUtil)

- (NSString *)toMD5 {
  const char *cStr = [self UTF8String];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5(cStr,(CC_LONG)strlen(cStr),digest);
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
  return output;
}

- (NSString *)toEncoding {
  return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)toTime {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.longLongValue/1000];
    return [vkDateFormatter(@"yyyy-MM-dd HH:mm:ss") stringFromDate:date];
}

- (NSString *)toDate {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.longLongValue/1000];
    return [vkDateFormatter(@"yyyy-MM-dd") stringFromDate:date];
}

- (NSString *)toDateFormatter:(NSString *)dateFormatter {
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.longLongValue/1000];
    return [vkDateFormatter(dateFormatter) stringFromDate:date];
}

- (NSString *)toBlank {
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return string;
}

- (NSURL *)toURL {
    return [NSURL URLWithString:self];
}

- (NSDictionary *)getURLParams {
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm;
}

- (NSString *)getURL:(NSDictionary *)dict {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self];
    NSMutableArray *array = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:obj];
        [array addObject:item];
    }];
    urlComponents.queryItems = array;
    return urlComponents.URL.absoluteString;
}
@end
