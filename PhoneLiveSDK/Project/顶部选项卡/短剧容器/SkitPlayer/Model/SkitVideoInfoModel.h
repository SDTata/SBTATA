//
//  SkitVideoInfoModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitVideoInfoModel : NSObject

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *skit_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *plat;
@property (nonatomic, copy) NSString *cate_id;
@property (nonatomic, copy) NSString *tags_id;
@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *uptime;
@property (nonatomic, assign) NSInteger episode_number;
@property (nonatomic, assign) NSInteger is_vip;
@property (nonatomic, assign) NSInteger ticket_cost;
@property (nonatomic, assign) NSInteger coin_cost;
@property (nonatomic, copy) NSString *cate_ids;
@property (nonatomic, copy) NSString *tag_ids;
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, copy) NSString *cover_path;
@property (nonatomic, copy) NSString *screen_orientation;
@property (nonatomic, copy) NSString *video_duration;
@property (nonatomic, copy) NSString *filesize;
@property (nonatomic, strong) VideoSizeModel *meta;
@property (nonatomic, copy) NSString *is_encrypted;
@property (nonatomic, copy) NSString *encrypted_key;
@property (nonatomic, assign) BOOL can_play;

@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, assign) ShortVideoModelPayType isNeedPay;
@property (nonatomic, assign) int preview_duration;

- (void)changeEncrypted_key:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
