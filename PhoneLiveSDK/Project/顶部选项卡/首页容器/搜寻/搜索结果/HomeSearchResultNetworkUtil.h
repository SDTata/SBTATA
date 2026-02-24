//
//  HomeSearchResultNetworkUtil.h
//  phonelive2
//
//  Created by user on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryNetworkUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSearchResultNetworkUtil : LotteryNetworkUtil
/** 2024.09.10 已弃用
 + (void)getShortVideoTopicVideos:(NSString *)topic page:(NSInteger)p block:(NetworkBlock)block;
 */
+ (void)getUserSearchMedia:(NSString *)key type:(NSInteger)type page:(NSInteger)p block:(NetworkBlock)block;
+ (void)getGuessUserLike:(NSInteger)type block:(NetworkBlock)block;
+ (void)getHotSearchKey:(NSInteger)type block:(NetworkBlock)block;
+ (void)getAnchorList:(NSString *)key page:(NSInteger)p block:(NetworkBlock)block;
@end

NS_ASSUME_NONNULL_END
