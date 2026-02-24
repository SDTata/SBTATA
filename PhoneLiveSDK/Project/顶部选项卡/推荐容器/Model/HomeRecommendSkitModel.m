//
//  HomeRecommendSkitModel.m
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeRecommendSkitModel.h"

@implementation HomeRecommendSkit

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"skit_id": @"id"};
}

-(void)setCover:(NSString *)cover
{
    _cover = cover;
    _cover_path = cover;
}

- (NSArray<SkitVideoInfoModel *> *)videoArray {
    if (!_videoArray) {
        SkitVideoInfoModel *model = [SkitVideoInfoModel new];
        _videoArray = @[model];
    }
    return _videoArray;
}

@end

@implementation HomeRecommendSkitModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"className": @"class"};
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : [HomeRecommendSkit class]};
}

- (BOOL)isScroll {
    if (self.layout_column == 0) {
        return YES;
    }

    return NO;
}

@end
