//
//  TaskBackWaterModel.m
//  phonelive2
//
//  Created by vick on 2024/8/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskBackWaterModel.h"

@implementation TaskBackWaterRateModel

- (void)setKing_level:(NSString *)king_level {
    _king_level = king_level;
    
    NSArray *array = [king_level componentsSeparatedByString:@"-"];
    _king_name = [NSString stringWithFormat:@"%@V%@\n-\n%@V%@", YZMsg(@"VIPVC_King"), array.firstObject, YZMsg(@"VIPVC_King"), array.lastObject];
    _min_level = [array.firstObject integerValue];
    _max_level = [array.lastObject integerValue];
}

@end

@implementation TaskBackWaterModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"rates": [TaskBackWaterRateModel class],
    };
}

- (void)setRates:(NSArray<TaskBackWaterRateModel *> *)rates {
    
    /// 找出当前等级索引
    NSInteger level = [Config myProfile].king_level.integerValue;
    NSInteger index = [rates indexOfObjectPassingTest:^BOOL(TaskBackWaterRateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return level >= obj.min_level && level <= obj.max_level;
    }];
    if (index > rates.count) {
        index = 0;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    TaskBackWaterRateModel *previous = [rates safeObjectWithIndex:index - 1];
    if (previous) {
        [array addObject:previous];
    }
    TaskBackWaterRateModel *current = [rates safeObjectWithIndex:index];
    if (current) {
        [array addObject:current];
    }
    TaskBackWaterRateModel *next = [rates safeObjectWithIndex:index + 1];
    if (next) {
        [array removeObject:previous];
        [array addObject:next];
    }
    
    _rates = array;
}

@end
