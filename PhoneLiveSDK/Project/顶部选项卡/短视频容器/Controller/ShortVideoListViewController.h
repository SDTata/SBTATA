//
//  ShortVideoListViewController.h
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortVideoModel.h"
NS_ASSUME_NONNULL_BEGIN

#define HotHost @"ShortVideo.getHotVideos"
#define FollowedHost @"ShortVideo.getFollowedVideos"
#define LikeHost @"ShortVideo.getLikedVideos"


@protocol ShortVideoListViewControllerDelegate <NSObject>
@optional
- (void)changeSegmentStyle:(SegmentStyle)style;
@end

@interface ShortVideoListViewController : VKPagerChildVC
@property(nonatomic, weak) id<ShortVideoListViewControllerDelegate> delegate;
@property(nonatomic, copy) void (^fetchMoreBlock)(void);
@property(nonatomic, copy) void (^currentIndexBlock)(NSString*);
@property(nonatomic, copy) UIView* (^getViewCurrentIndexBlock)(NSString*);
@property (nonatomic, assign) BOOL showCreateTime;
@property (nonatomic, strong) NSString *toUid;

- (instancetype)initWithHost:(NSString*)host;
// 外部新開模塊 可指定index
- (void)updateData:(NSArray<ShortVideoModel*>*)models selectIndex:(NSInteger)index fetchMore:(BOOL)fetchMore;
- (void)showVideoCommentWithID:(NSString *)comment_id messageId:(NSString *)message_id;
+ (void)requestVideo:(NSString*)videoId autoDeduct:(BOOL)autoDeduct refresh_url:(BOOL)refresh_url completion:(nullable void (^)(ShortVideoModel *newModel, BOOL success, NSString *errorMsg))completion;
// 插入
- (void)insertModelAndOrderToIndex:(ShortVideoModel*)model;
// 設定 tableView 高度
- (void)updateTableViewLayout:(CGFloat)height;
- (void)handleRefresh;
- (void)hideCommentView;

@end

NS_ASSUME_NONNULL_END
