//
//  SkitHotModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/8.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitHotModel.h"

@implementation CateInfoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"cate_id": @"id"};
}

@end

//@implementation CateSkitListModel
//
//+ (NSDictionary *)mj_replacedKeyFromPropertyName {
//    return @{@"video_id": @"id"};
//}
//
//@end

@implementation SkitHotModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"cate_info" : [CateInfoModel class],
        @"cate_skit_list" : [HomeRecommendSkit class],
        @"list" : [HomeRecommendSkit class]
    };
}

@end

