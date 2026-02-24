//
//  ShortVideoModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoTagsModel : NSObject

@property (nonatomic, copy) NSString *tag_id;
@property (nonatomic, copy) NSString *tag_name;

@end

@interface VideoSizeModel : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL isProtrait;
@property (nonatomic, assign) CGFloat ratio;
@end

@protocol CoverMetaProtocol <NSObject>
@property (nonatomic, strong) VideoSizeModel *cover_meta;
@end

typedef NS_ENUM(NSInteger, ShortVideoModelPayType) {
    ShortVideoModelPayTypeFree,// 不需付費
    ShortVideoModelPayTypeVIP,// VIP
    ShortVideoModelPayTypeTicket,// ticket
    ShortVideoModelPayTypeCoin,// coin
};

@interface ShortVideoModel : NSObject <CoverMetaProtocol>

@property (nonatomic, assign) NSInteger browse_count;
@property (nonatomic, assign) NSInteger can_play;
@property (nonatomic, assign) NSInteger coin_cost;
@property (nonatomic, assign) NSInteger comments_count;
@property (nonatomic, copy) NSString *cover_path;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, strong) NSString *encrypted_key;
@property (nonatomic, assign) NSInteger filesize;
@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, assign) NSInteger is_encrypted;
@property (nonatomic, assign) NSInteger is_follow;
@property (nonatomic, assign) NSInteger is_like;
@property (nonatomic, assign) NSInteger is_vip;
@property (nonatomic, assign) NSInteger likes_count;
@property (nonatomic, strong) VideoSizeModel *meta;
@property (nonatomic, strong) VideoSizeModel *cover_meta;
@property (nonatomic, assign) NSInteger screen_orientation;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger ticket_cost;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *topics;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *user_avatar;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, assign) NSInteger video_duration;
@property (nonatomic, assign) NSInteger preview_duration;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *video_type;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, strong) NSArray<VideoTagsModel *>*tags;
@property (nonatomic, assign) ShortVideoModelPayType isNeedPay;
//@property (nonatomic, copy) VideoSizeModel *videoSize;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *playTimeShow;
@property (nonatomic, assign) BOOL user_hide_status;/// 0是公开 1是隐藏
@property (nonatomic, copy) NSString *consume_time;
@property (nonatomic, copy) NSString *consume_amount;
@property (nonatomic, assign) BOOL isSearchResultMovies;
- (void)changeEncrypted_key:(NSString*)key;
+ (BOOL)showPayTagIfNeed:(NSInteger)coin_cost ticket_cost:(NSInteger)ticket_cost;
@end

NS_ASSUME_NONNULL_END
