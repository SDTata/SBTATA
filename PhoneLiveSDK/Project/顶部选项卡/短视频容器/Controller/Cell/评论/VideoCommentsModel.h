//
//  VideoCommentsModel.h
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCommentsToUser : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *username;
@end

@interface VideoCommentsReply : NSObject
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *uid;
@property (nonatomic, copy)   NSString *avatar;
@property (nonatomic, copy)   NSString *username;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, copy)   NSString *video_id;
@property (nonatomic, copy)   NSString *parent_id;
@property (nonatomic, copy)   NSString *comment;
@property (nonatomic, copy)   NSString *like_count;
@property (nonatomic, copy)   NSString *create_time;
@property (nonatomic, copy)   NSString *deleted;
@property (nonatomic, strong) VideoCommentsToUser *to_user;
@property (nonatomic, assign) BOOL isExpandedLast; // 展开后的最后一笔
@end

@interface VideoCommentsModel : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *top_parent_id;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *deleted;
@property (nonatomic, copy) NSMutableArray<VideoCommentsReply *> *replies;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, assign) BOOL isExpanded; // 用于记录评论是否展开

@end
NS_ASSUME_NONNULL_END
