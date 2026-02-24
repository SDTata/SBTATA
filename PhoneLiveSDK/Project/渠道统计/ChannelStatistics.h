//
//  ChannelStatistics.h
//  phonelive
//
//  Created by 400 on 2020/9/22.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelsModel : NSObject<NSCoding>

@property (nonatomic,strong)NSString *pasteString;
@property (nonatomic,strong) NSDictionary *datas;//动态参数
@property (nonatomic,copy) NSString *channelCode;//渠道编号
@property (nonatomic,copy) NSString *paramsDic;//分享编号
@property (nonatomic,copy) NSString *code;//分享编号
@property (nonatomic,copy) NSString *webUmidToken;//分享编号
@property (nonatomic,copy) NSString *uaToken;

@end

typedef void (^ChannelStatisticsBlock)(ChannelsModel *data);

@interface ChannelStatistics : NSObject
/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;

@property (nonatomic,strong)ChannelsModel *model;

-(void)channelsRequest:(ChannelStatisticsBlock)callback;

-(void)reportRegister:(NSString*)uid report:(BOOL)report;

@end
