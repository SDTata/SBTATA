//
//  HomeRecommendModel.m
//  c700LIVE
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeRecommendModel.h"

@implementation HomeRecommendModel

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (NSDictionary*)mj_replacedKeyFromPropertyName {
    return @{@"adsModel": @"ads",
             @"gameModel": @"games",
             @"liveModel": @"live",
             @"longVideoModel": @"long_video",
             @"lotteryModel": @"lotteries",
             @"shortVideoModel": @"short_videos",
             @"skitModel": @"skits"};
}

@end
