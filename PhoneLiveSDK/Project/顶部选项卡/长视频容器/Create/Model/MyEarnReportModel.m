//
//  MyEarnReportModel.m
//  phonelive2
//
//  Created by vick on 2024/7/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyEarnReportModel.h"

@implementation MyEarnReportModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"profit_list": [ShortVideoModel class]
    };
}

@end
