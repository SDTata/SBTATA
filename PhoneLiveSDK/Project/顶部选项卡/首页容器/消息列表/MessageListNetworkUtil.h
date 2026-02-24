//
//  MessageListNetworkUtil.h
//  phonelive2
//
//  Created by user on 2024/8/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryNetworkUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageListNetworkUtil : LotteryNetworkUtil
//+ (void)getUnreadMessagesCount:(NetworkBlock)block;
//+ (void)getInteractionMessages:(NSInteger)page block:(NetworkBlock)block;
+ (void)getMessageHome:(NetworkBlock)block;
+ (void)getMessageListByType:(NSString *)type page:(NSInteger)p block:(NetworkBlock)block;
+ (void)setMarkMessageAsRead:(NSString *)message_id type:(NSString *)type block:(NetworkBlock)block;
+ (void)deleteInteractionMessages:(NSString *)message_id type:(NSString *)type block:(NetworkBlock)block;
@end

@interface NewMessageListFirstMessageModel : NSObject
@property (nonatomic, nullable, copy) NSString *identifier;
@property (nonatomic, nullable, copy) NSString *messageType;
@property (nonatomic, nullable, copy) NSString *content;
@property (nonatomic, nullable, copy) NSString *from_uid;
@property (nonatomic, nullable, copy) NSString *video_id;
@property (nonatomic, nullable, copy) NSString *comment_id;
@property (nonatomic, nullable, copy) NSString *type;
@property (nonatomic, assign) BOOL is_read;
@property (nonatomic, assign) BOOL is_like;
@property (nonatomic, nullable, copy) NSString *create_time;
@property (nonatomic, nullable, copy) NSString *from_user_name;
@property (nonatomic, nullable, copy) NSString *from_user_avatar;
@property (nonatomic, nullable, copy) NSString *short_video_cover;
@end

@interface NewMessageListModel: NSObject
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *type;
@property (nonatomic, copy)   NSString *display_type;
@property (nonatomic, copy)   NSString *icon;
@property (nonatomic, assign) NSInteger unread_count;
@property (nonatomic, strong) NewMessageListFirstMessageModel *first_message;
@end

// 消息列表 - 互動消息
@interface InteractionMessagesModel: NSObject
@property (nonatomic, nullable, copy) NSString *identifier;
@property (nonatomic, nullable, copy) NSString *from_uid;
@property (nonatomic, nullable, copy) NSString *video_id;
@property (nonatomic, nullable, copy) NSString *comment_id;
@property (nonatomic, nullable, copy) NSString *type;
@property (nonatomic, nullable, copy) NSString *content;
@property (nonatomic, nullable, copy) NSString *is_read;
@property (nonatomic, nullable, copy) NSString *create_time;
@property (nonatomic, nullable, copy) NSString *from_user_name;
@property (nonatomic, nullable, copy) NSString *from_user_avatar;
@property (nonatomic, nullable, copy) NSString *short_video_cover;
@property (nonatomic, nullable, copy) NSString *messageType;
@property (nonatomic, assign) BOOL is_like;
@end

NS_ASSUME_NONNULL_END
