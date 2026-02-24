//
//  HomeSearchResultNetworkUtil.m
//  phonelive2
//
//  Created by user on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSearchResultNetworkUtil.h"

@implementation HomeSearchResultNetworkUtil

// 短视频 tag 话题搜索
/** 2024.09.10 已弃用
 + (void)getShortVideoTopicVideos:(NSString *)topic page:(NSInteger)p block:(NetworkBlock)block {
     NSMutableDictionary *dict = [NSMutableDictionary dictionary];
     dict[@"topic"] = topic;
     dict[@"p"] = @(p);
     [self baseRequest:@"ShortVideo.getTopicVideos" params:dict block:block];
 }
 */

// 视频搜索结果 type: 0=全部, 1=短剧, 2=短视频, 3=长视屏
+ (void)getUserSearchMedia:(NSString *)key type:(NSInteger)type page:(NSInteger)p block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"key"] = key;
    dict[@"type"] = @(type);
    dict[@"p"] = @(p);
    [self baseRequest:@"User.searchMedia" params:dict block:block];
}

// 猜你喜欢
+ (void)getGuessUserLike:(NSInteger)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = @(type);
    [self baseRequest:@"User.guessUserLike" params:dict block:block];
}

// 热搜榜
+ (void)getHotSearchKey:(NSInteger)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = @(type);
    [self baseRequest:@"User.getHotSearchKey" params:dict block:block];
}

// 主播列表
+ (void)getAnchorList:(NSString *)key page:(NSInteger)p block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"key"] = key;
    dict[@"p"] = @(p);
    [self baseRequest:@"Home.search" params:dict block:block];
}

@end
