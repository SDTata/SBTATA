//
//  NSString+Extention.h
//  phonelive
//
//  Created by 400 on 2020/8/27.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelStatistics.h"

@interface NSString (Extention)
+(ChannelsModel *)pasteChannelDispose;
- (BOOL)isPureInt;
- (NSString*)reverseString;

/// 初始化
+ (NSString *)toAmount:(NSString *)amount;

/// 除以10
- (NSString *)toDivide10;

/// 汇率
- (NSString *)toRate;

/// 显示K
- (NSString *)toK;

/// 显示单位
- (NSString *)toUnit;

/// 减去
- (NSString *)toSub:(NSString *)value;

@end
