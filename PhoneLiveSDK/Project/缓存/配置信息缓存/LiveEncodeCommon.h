//
//  LiveEncodeCommon.h
//  phonelive2
//
//  Created by 400 on 2021/5/8.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface LiveEncodeCommon : NSObject
+ (instancetype)sharedInstance;
@property(nonatomic,assign)BOOL isOpenEncode;
@property(nonatomic,assign)BOOL isOpenEncodeSDK;
//加密分辨率
@property(nonatomic,strong)ResolutionModel *live_resolution;

@property(nonatomic,assign)BOOL enableEn;
@property(nonatomic,assign)BOOL flip;
@property(nonatomic,assign)BOOL bitwise_not;
@property(nonatomic,assign)int column;
@property(nonatomic,assign)int line;
@property(nonatomic,assign)int bitrate;

@property(nonatomic,assign)BOOL show_lottery_profit_rank;
//            int bitrate = [minnum([ep objectForKey:@"bitrate"]) intValue];
//

@end

NS_ASSUME_NONNULL_END
