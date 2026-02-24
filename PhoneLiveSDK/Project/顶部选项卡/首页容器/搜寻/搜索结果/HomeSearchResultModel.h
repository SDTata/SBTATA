//
//  HomeSearchResultModel.h
//  phonelive2
//
//  Created by user on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

// 搜索结果 - 主播列表
@interface HomeSearchResultAnchorList : NSObject <CoverMetaProtocol>
@property (nonatomic, copy)           NSString *identifier;
@property (nonatomic, copy)           NSString *user_nicename;
@property (nonatomic, copy)           NSString *avatar;
@property (nonatomic, nullable, copy)        id avatar_aid;
@property (nonatomic, copy)           NSString *sex;
@property (nonatomic, copy)           NSString *signature;
@property (nonatomic, copy)           NSString *votestotal;
@property (nonatomic, copy)           NSString *isattention;
@property (nonatomic, copy)           NSString *level;
@property (nonatomic, copy)           NSString *level_anchor;
@property (nonatomic, strong)   VideoSizeModel *cover_meta;
@property (nonatomic, copy)           NSString *fans;
@property (nonatomic, assign)         BOOL isLive;


@end
NS_ASSUME_NONNULL_END
