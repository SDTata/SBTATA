//
//  VideoCommentsModel.m
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoCommentsModel.h"

@implementation VideoCommentsToUser
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"user_name": @"username"};
}
@end

@implementation VideoCommentsReply
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"identifier": @"id"};
}
@end

@implementation VideoCommentsModel

+ (void)initialize {
    [self mj_setupObjectClassInArray:^NSDictionary *{
        return @{@"replies" : @"VideoCommentsReply"};
    }];
    
    [self mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
            @"identifier" : @"id"
        };
    }];
}

- (NSMutableArray<VideoCommentsReply *> *)replies {
    if (!_replies) {
        _replies = [NSMutableArray array];
    } else if ([_replies isKindOfClass:[NSArray class]]) {
        _replies = [NSMutableArray arrayWithArray:_replies];
    }
    return _replies;
}

@end
