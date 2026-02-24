//
//  HomeRecommendShortVideoModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

//@interface HomeRecommendShortVideo : NSObject
//
//@property (nonatomic, assign) NSInteger browse_count;
//@property (nonatomic, assign) NSInteger can_play;
//@property (nonatomic, assign) NSInteger coin_cost;
//@property (nonatomic, assign) NSInteger comments_count;
//@property (nonatomic, copy) NSString *cover_path;
//@property (nonatomic, copy) NSString *created_at;
//@property (nonatomic, copy) NSString *description_;
//@property (nonatomic, strong) NSString *encrypted_key;
//@property (nonatomic, assign) NSInteger filesize;
//@property (nonatomic, copy) NSString *video_id;
//@property (nonatomic, assign) NSInteger is_encrypted;
//@property (nonatomic, assign) NSInteger is_follow;
//@property (nonatomic, assign) NSInteger is_like;
//@property (nonatomic, assign) NSInteger is_vip;
//@property (nonatomic, assign) NSInteger likes_count;
//@property (nonatomic, strong) VideoSizeModel *meta;
//@property (nonatomic, strong) VideoSizeModel *cover_meta;
//@property (nonatomic, assign) NSInteger screen_orientation;
//@property (nonatomic, assign) NSInteger status;
//@property (nonatomic, assign) NSInteger ticket_cost;
//@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSArray *topics;
//@property (nonatomic, copy) NSString *uid;
//@property (nonatomic, copy) NSString *updated_at;
//@property (nonatomic, copy) NSString *user_avatar;
//@property (nonatomic, copy) NSString *user_name;
//@property (nonatomic, assign) NSInteger video_duration;
//@property (nonatomic, copy) NSString *video_url;
//@property (nonatomic, strong) NSArray<VideoTagsModel *>*tags;
//@property (nonatomic, assign) ShortVideoModelPayType isNeedPay;
//
//@end

@interface HomeRecommendShortVideoModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray<ShortVideoModel *> *data;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int layout_column;
@property (nonatomic, assign) int layout_row;
@property (nonatomic, assign) BOOL isScroll;

@end

NS_ASSUME_NONNULL_END
