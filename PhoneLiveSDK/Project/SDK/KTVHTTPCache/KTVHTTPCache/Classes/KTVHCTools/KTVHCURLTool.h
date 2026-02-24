//
//  KTVHCURLTool.h
//  KTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTVHCURLTool : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)tool;

@property (nonatomic, copy) NSURL * (^URLConverter)(NSURL *URL);

@property (nonatomic, strong)NSMutableDictionary *urlDic;

- (NSString *)keyWithURL:(NSURL *)URL;
- (NSString *)URLEncode:(NSString *)URLString;
- (NSString *)URLDecode:(NSString *)URLString;


- (NSString *)cacheUrlKeyMd5Path:(NSString *)uri;

//获取m3u8地址
- (NSURL *)getCacheUrlKeyFromMd5Path:(NSString *)path;
//获取ts地址
-(NSString*)findTsURLFromTsPath:(NSString*)tsPath;

@end
