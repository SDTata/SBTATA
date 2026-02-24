//
//  MovieHomeModel.m
//  phonelive2
//
//  Created by vick on 2024/7/9.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MovieHomeModel.h"

@implementation MovieCateModel

@end

@implementation MovieHomeModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"movies": [ShortVideoModel class]
    };
}

@end
