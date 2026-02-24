//
//  HomeSearchResultModel.m
//  phonelive2
//
//  Created by user on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSearchResultModel.h"

// 搜索结果 - 主播列表
@implementation HomeSearchResultAnchorList
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"identifier": @"id"};
}
@end
