//
//  VideoCommentsNetworkUtil.m
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoCommentsNetworkUtil.h"

@implementation VideoCommentsNetworkUtil

// 获取评论
+ (void)getShortVideoComment:(NSString *)videoId messageId:(NSString *)messageId page:(NSInteger)p block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_id"] = videoId;
    if (messageId) {
        dict[@"message_id"] = messageId;
    }
    dict[@"p"] = @(p);
    [self baseRequest:@"ShortVideo.getComment" params:dict block:block];
}

// 添加评论
+ (void)addShortVideoComment:(NSString *)videoId comment_pid:(NSString *)comment_pid comment:(NSString *)comment block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_id"] = videoId;
    dict[@"comment_pid"] = comment_pid;
    dict[@"comment"] = comment;
    [self baseRequest:@"ShortVideo.addComment" params:dict block:block];
}

// 评论点赞
+ (void)getLikeComment:(NSString *)commentId isLike:(NSInteger)isLike block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"comment_id"] = commentId;
    dict[@"is_like"] = @(isLike);
    [self baseRequest:@"ShortVideo.likeComment" params:dict block:block];
}

// 删除评论
+ (void)deleteComment:(NSString *)commentId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"comment_id"] = commentId;
    [self baseRequest:@"ShortVideo.deleteComment" params:dict block:block];
}
@end
