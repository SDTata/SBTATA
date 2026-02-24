//
//  VideoCommentsNetworkUtil.h
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryNetworkUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCommentsNetworkUtil : LotteryNetworkUtil
+ (void)getShortVideoComment:(NSString *)videoId messageId:(NSString *)messageId page:(NSInteger)p block:(NetworkBlock)block;
+ (void)addShortVideoComment:(NSString *)videoId comment_pid:(NSString *)comment_pid comment:(NSString *)comment block:(NetworkBlock)block;
+ (void)getLikeComment:(NSString *)commentId isLike:(NSInteger)isLike block:(NetworkBlock)block;
+ (void)deleteComment:(NSString *)commentId block:(NetworkBlock)block;
@end

NS_ASSUME_NONNULL_END
