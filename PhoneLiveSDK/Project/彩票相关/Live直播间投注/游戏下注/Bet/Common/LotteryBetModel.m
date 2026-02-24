//
//  LotteryBetModel.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetModel.h"

@implementation LotteryResultModel

@end

@implementation LotteryOptionModel

- (void)setData:(id)data {
    if ([data isKindOfClass:NSArray.class]) {
        _data = [LotteryOptionModel arrayFromJson:data];
    } else {
        NSMutableArray *results = [NSMutableArray array];
        [results addObjectsFromArray:data[@"text"]];
        [results addObjectsFromArray:data[@"num"]];
        _data = [LotteryOptionModel arrayFromJson:results];
    }
}

@end

@implementation LotteryWayModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"options": [LotteryOptionModel class]
    };
}

@end

@implementation LotteryBetModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"ways": [LotteryWayModel class]
    };
}

- (void)setTime:(NSInteger)time {
    _time = time;
    _timeDate = [NSDate dateWithTimeInterval:time sinceDate:NSDate.date];
}

- (NSInteger)timeOffset {
    NSInteger time = [_timeDate timeIntervalSinceDate:NSDate.date];
    return time - self.sealingTim;
}

@end
