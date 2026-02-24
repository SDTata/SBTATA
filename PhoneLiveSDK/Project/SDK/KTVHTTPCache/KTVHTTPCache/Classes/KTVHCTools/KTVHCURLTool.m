//
//  KTVHCURLTool.m
//  KTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "KTVHCURLTool.h"
#import <CommonCrypto/CommonCrypto.h>

@interface KTVHCURLTool ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *md5s;

@property (nonatomic, strong)NSMutableDictionary *urlDomainDic;

@end

@implementation KTVHCURLTool

+ (instancetype)tool
{
    static KTVHCURLTool *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
        obj.urlDic = [NSMutableDictionary dictionary];
        obj.urlDomainDic = [NSMutableDictionary dictionary];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.lock = [[NSLock alloc] init];
        self.md5s = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)keyWithURL:(NSURL *)URL
{
    if (self.URLConverter && URL && URL.absoluteString.length > 0) {
        NSURL *newURL = self.URLConverter(URL);
        if (newURL.absoluteString.length > 0) {
            URL = newURL;
        }
    }
//    NSString *md5 = [self md5:URL.absoluteString];
//    NSLog(@"convertKey md5: %@", md5);
//    return md5;
    NSString *convertKey = [self cacheUrlKeyMd5Path:URL.absoluteString];
    NSLog(@"convertKey: %@", convertKey);
    NSString *md5 = [self md5:convertKey];
    NSLog(@"convertKey md5: %@", md5);
    return md5;
}


/**
 * 处理 URI，去掉协议、域名和查询参数
 *
 * @param uri1 原始 URI
 * @return 处理后的 URI 作为缓存键
 */
- (NSString *)cacheUrlKeyMd5Path:(NSString *)uri1 {
   
    NSString *fullUrl = uri1;
    
    // 去掉查询参数
    NSRange queryRange = [fullUrl rangeOfString:@"?"];
    if (queryRange.location != NSNotFound) {
        fullUrl = [fullUrl substringToIndex:queryRange.location];
    }

    // 去掉协议部分
    NSRange protocolRange = [fullUrl rangeOfString:@"://"];
    NSRange protocolRange1 = [fullUrl rangeOfString:@":/"];
    NSUInteger pathStartIndex = 0;
    
    if (protocolRange.location != NSNotFound) {
        // 协议部分的结束位置
        pathStartIndex = protocolRange.location + protocolRange.length;
    } else {
        // 没有协议部分的情况
        if (protocolRange1.location != NSNotFound) {
            // 协议部分的结束位置
            pathStartIndex = protocolRange1.location + protocolRange1.length;
        } else {
            // 没有协议部分的情况
            pathStartIndex = 0;
        }
    }
    
    // 查找路径部分的开始位置
    NSRange pathRange = [fullUrl rangeOfString:@"/" options:0 range:NSMakeRange(pathStartIndex, fullUrl.length - pathStartIndex)];
    if (pathRange.location != NSNotFound) {
        fullUrl = [fullUrl substringFromIndex:pathRange.location];
    } else {
        // 如果没有路径部分，则返回空字符串
        fullUrl = @"";
    }
    fullUrl = [fullUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    [self.urlDic setObject:uri1 forKey:fullUrl];
    
    NSString *fileNameP = [self extractPathFromURL:fullUrl];
    if ([uri1 containsString:@".m3u8"]) {
        [self.urlDomainDic setObject:uri1 forKey:fileNameP];
    }
    return fullUrl;
}

///获取到文件名
- (NSString *)getUrlFileName:(NSString *)uri1
{
    NSString *fullUrl = uri1;
    
    // 去掉查询参数
    NSRange queryRange = [fullUrl rangeOfString:@"?"];
    if (queryRange.location != NSNotFound) {
        fullUrl = [fullUrl substringToIndex:queryRange.location];
    }

    // 去掉协议部分
    NSRange protocolRange = [fullUrl rangeOfString:@"://"];
//    NSRange protocolRange1 = [fullUrl rangeOfString:@":/"];
    NSUInteger pathStartIndex = 0;
    
    if (protocolRange.location != NSNotFound) {
        // 协议部分的结束位置
        pathStartIndex = protocolRange.location + protocolRange.length;
    } else {
        // 没有协议部分的情况
//        if (protocolRange1.location != NSNotFound) {
//            // 协议部分的结束位置
//            pathStartIndex = protocolRange1.location + protocolRange1.length;
//        } else {
            // 没有协议部分的情况
            pathStartIndex = 0;
//        }
    }
    
    // 查找路径部分的开始位置
    NSRange pathRange = [fullUrl rangeOfString:@"/" options:0 range:NSMakeRange(pathStartIndex, fullUrl.length - pathStartIndex)];
    if (pathRange.location != NSNotFound) {
        fullUrl = [fullUrl substringFromIndex:pathRange.location];
    } else {
        // 如果没有路径部分，则返回空字符串
        fullUrl = @"";
    }
    fullUrl = [self extractPathFromURL:fullUrl];
    
    return fullUrl;
}
-(NSString*)findTsURLFromTsPath:(NSString*)tsPath
{
    NSString *fileName = [self getUrlFileName:tsPath];
    NSString *m3u8Url = [self.urlDomainDic objectForKey:fileName];
    if (m3u8Url) {
        NSURL *urlM3u8 = [NSURL URLWithString:m3u8Url];
        if ([urlM3u8 isKindOfClass:[NSURL class]]) {
            NSString *hostUrl = urlM3u8.host;
            tsPath = [tsPath stringByReplacingOccurrencesOfString:@"http:" withString:[NSString stringWithFormat:@"http:/%@",hostUrl]];
        }
    }
    
    return tsPath;
    
}

- (NSString *)extractPathFromURL:(NSString *)urlString {
    // 创建 NSURL 对象
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 获取 path 并去掉最后一个路径组件
    NSString *path = [url.path stringByDeletingLastPathComponent];
    
    // 添加尾部的斜杠，确保路径格式一致
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    
    return path;
}


- (NSURL *)getCacheUrlKeyFromMd5Path:(NSString *)path
{
    NSString *urlStr = @"";
    if (self.urlDic) {
        urlStr = [self.urlDic objectForKey:[path stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    }
    return [NSURL URLWithString:urlStr];
}


- (NSString *)md5:(NSString *)URLString
{
    [self.lock lock];
    NSString *result = [self.md5s objectForKey:URLString];
    if (!result || result.length == 0) {
        const char *value = [URLString UTF8String];
        unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
        CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
        NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH *2];
        for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
            [outputString appendFormat:@"%02x", outputBuffer[count]];
        }
        result = outputString;
        [self.md5s setObject:result forKey:URLString];
    }
    [self.lock unlock];
    return result;
}

- (NSString *)URLEncode:(NSString *)URLString
{
    static NSString *characters =  @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:characters];
    return [URLString stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

- (NSString *)URLDecode:(NSString *)URLString
{
    return [URLString stringByRemovingPercentEncoding];
}

- (NSDictionary<NSString *,NSString *> *)parseQuery:(NSString *)query
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    [scanner setCharactersToBeSkipped:nil];
    while (1) {
        NSString *key = nil;
        if (![scanner scanUpToString:@"=" intoString:&key] || [scanner isAtEnd]) {
            break;
        }
        [scanner setScanLocation:([scanner scanLocation] + 1)];
        NSString *value = nil;
        [scanner scanUpToString:@"&" intoString:&value];
        if (value == nil) {
            value = @"";
        }
        key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSString *unescapedKey = key ? [self URLDecode:key] : nil;
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSString *unescapedValue = value ? [self URLDecode:value] : nil;
        if (unescapedKey && unescapedValue) {
            [parameters setObject:unescapedValue forKey:unescapedKey];
        }
        if ([scanner isAtEnd]) {
            break;
        }
        [scanner setScanLocation:([scanner scanLocation] + 1)];
    }
    return parameters;
}

@end
