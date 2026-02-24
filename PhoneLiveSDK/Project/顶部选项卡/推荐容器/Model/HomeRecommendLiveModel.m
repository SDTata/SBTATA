//
//  HomeRecommendLiveModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeRecommendLiveModel.h"



@implementation HomeRecommendLiveModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"className": @"class"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : [hotModel class]};
}

- (BOOL)isScroll {
    if (self.layout_column == 0) {
        return YES;
    }

    return NO;
}

@end
