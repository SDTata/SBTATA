//
//  MessageListNetworkUtil.m
//  phonelive2
//
//  Created by user on 2024/8/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MessageListNetworkUtil.h"

@implementation MessageListNetworkUtil

// 获取互动消息未读条数
/*
+ (void)getUnreadMessagesCount:(NetworkBlock)block {
    [self baseRequest:@"User.getUnreadMessagesCount" params:nil block:block];
}

// 获取未读消息列表
+ (void)getInteractionMessages:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"page"] = @(page);
    [self baseRequest:@"User.getInteractionMessages" params:dict block:block];
}
*/

// 获取消息列表
+ (void)getMessageHome:(NetworkBlock)block {
    [self baseRequest:@"Message.getMessageHome" params:nil block:block];
}

// 获取消息列表
+ (void)getMessageListByType:(NSString *)type page:(NSInteger)p block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
    dict[@"p"] = @(p);
    [self baseRequest:@"Message.getMessageListByType" params:dict block:block];
}

// 设置未读消息为已读。全部已读 message_id = 0
+ (void)setMarkMessageAsRead:(NSString *)message_id type:(NSString *)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
    dict[@"message_id"] = message_id;
    [self baseRequest:@"Message.makeMessageAsRead" params:dict block:block];
}

// 删除互动消息 id: 0表示删除全部
+ (void)deleteInteractionMessages:(NSString *)message_id type:(NSString *)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
    dict[@"message_id"] = message_id;
    [self baseRequest:@"Message.deleteMessage" params:dict block:block];
}
@end

// 消息列表 - 互動消息 Data Model
@implementation InteractionMessagesModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"identifier": @"id", @"messageType": @"class"};
}
@end

@implementation NewMessageListModel
@end

// 消息列表 -  FirstMessage Model
@implementation NewMessageListFirstMessageModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"identifier": @"id", @"messageType": @"class"};
}
@end
