//
//  HomeRecommendSkitModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"
#import "SkitVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeRecommendSkit : NSObject <CoverMetaProtocol>

@property (nonatomic, copy) NSString *skit_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *cate_id;
@property (nonatomic, assign) NSInteger total_episodes;
@property (nonatomic, assign) NSInteger current_episodes;
@property (nonatomic, copy) NSString *release_time;
@property (nonatomic, copy) NSString *end_time;
@property (nonatomic, assign) NSInteger is_hot;
@property (nonatomic, assign) NSInteger is_new;
@property (nonatomic, assign) NSInteger is_vip;
@property (nonatomic, assign) NSInteger coin_cost;
@property (nonatomic, assign) NSInteger ticket_cost;
@property (nonatomic, copy) NSString *featured_end_time;
@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *uptime;
@property (nonatomic, copy) NSString *plat;
@property (nonatomic, copy) NSString *cate_ids;
@property (nonatomic, copy) NSString *tag_ids;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, strong) VideoSizeModel *cover_meta;
@property (nonatomic, copy) NSString *cover_path;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *screen_orientation;
@property (nonatomic, copy) NSString *video_duration;
@property (nonatomic, copy) NSString *filesize;
@property (nonatomic, strong) VideoSizeModel *meta;
@property (nonatomic, assign) NSInteger is_encrypted;
@property (nonatomic, copy) NSString *encrypted_key;
@property (nonatomic, assign) BOOL can_play;
@property (nonatomic, assign) NSInteger is_favorite;
@property (nonatomic, copy) NSString *p_progress;
@property (nonatomic, copy) NSString *over;
@property (nonatomic, strong) NSArray <SkitVideoInfoModel *> *videoArray;
@property (nonatomic, assign) NSInteger total_browse;
@property (nonatomic,strong)NSString *video_type;

@end

@interface HomeRecommendSkitModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray<HomeRecommendSkit *> *data;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int layout_column;
@property (nonatomic, assign) int layout_row;
@property (nonatomic, assign) BOOL isScroll;

@end

NS_ASSUME_NONNULL_END
