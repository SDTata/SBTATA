//
//  MyCreateInfoModel.m
//  phonelive2
//
//  Created by vick on 2024/7/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateInfoModel.h"

@implementation MyCreateCountModel

@end


@implementation MyCreateInfoModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"video_list": [ShortVideoModel class]
    };
}

@end
