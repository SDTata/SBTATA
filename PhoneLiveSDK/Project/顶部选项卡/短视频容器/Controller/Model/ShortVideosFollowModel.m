//
//  ShortVideosFollowModel.m
//  phonelive2
//
//  Created by s5346 on 2024/9/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideosFollowModel.h"

@implementation ShortVideosFollowUserModel

@end

@implementation ShortVideosFollowModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"videos": @"ShortVideoModel"
    };
}

@end
