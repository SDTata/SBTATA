//
//  HomeRecommendAdsModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeRecommendAdsModel.h"

@implementation HomeRecommendAds

@end

@implementation HomeRecommendAdsModel

+ (NSDictionary*)mj_replacedKeyFromPropertyName {
    return @{@"className": @"class"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : [HomeRecommendAds class]};
}

- (id)copyWithZone:(NSZone *)zone {
    HomeRecommendAdsModel *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.className = [self.className copy];
        copy.data = [NSArray arrayWithArray:self.data];
        copy.title = [self.title copy];
    }
    return copy;
}

@end
