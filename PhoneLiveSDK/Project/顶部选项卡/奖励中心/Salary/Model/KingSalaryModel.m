//
//  KingSalaryModel.m
//  phonelive2
//
//  Created by s5346 on 2024/8/23.
//  Copyright © 2024 toby. All rights reserved.
//

#import "KingSalaryModel.h"

@implementation SalaryLevelItem

@end

@implementation SararyRewardItem

@end

@implementation KingSalaryModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"list": [SalaryLevelItem class],
        @"reward_list": [SararyRewardItem class]
    };
}

@end
