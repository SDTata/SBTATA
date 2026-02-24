//
//  YBNetworking.h
//  iphoneLive
//
//  Created by YunBao on 2018/6/6.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImage.h"

typedef void (^networkSuccessBlock)(int code,NSArray *info,NSString *msg);
typedef void (^networkFailBlock)(NSError *error);



@interface DataForUpload : NSObject
@property(nonatomic,strong)NSData *datas;

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *filename;
@property(nonatomic,strong)NSString *mimeType;

@end

@interface YBNetworking : NSObject<NSCoding>

+ (YBNetworking *)sharedManager;




-(AFHTTPSessionManager*)manager;


@property(nonatomic,strong)AFHTTPSessionManager *manager;

+(NSString*)encodePath:(NSString *)path withForm:(NSDictionary*)form  withDic:(NSDictionary*)subDic;

+(id)decodeResponseString:(NSString*)content;




-(void)postNetworkWithUrl:(NSString *)url withBaseDomian:(BOOL)baseDomain andParameter:(NSDictionary *)dic data:(DataForUpload*)dataModel success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack;


-(void)postNetworkWithUrl:(NSString *)url withBaseDomian:(BOOL)baseDomain andParameter:(NSDictionary *)dic data:(DataForUpload*)dataModel progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack;
/**
 网络封装
 @param url 接口名称
 @param dic 接口参数dic
 @param sucBack 成功回调
 @param failBack 失败回调
 */
+(void)getNetWorkWithUrl:(NSString *)url andParameter:(NSDictionary *)dic success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack;


///
+(NSString*)currentLanguageServer;
@end


