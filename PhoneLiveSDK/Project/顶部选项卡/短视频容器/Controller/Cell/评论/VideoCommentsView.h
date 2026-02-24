//
//  VideoCommentsView.h
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol VideoCommentsViewDelegate <NSObject>
// 点击头像
- (void)tapAvatarImageView:(NSString *)uid;
// 点击用户名称
- (void)tapUserName:(NSString *)uid;
@end
@interface VideoCommentsView : UIView
@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *comments_count;
@property (strong, nonatomic)VKBaseTableView *tableView;
@property (nonatomic, assign) NSInteger page; //頁數、預設1
@property(nonatomic,assign) id<VideoCommentsViewDelegate> delelgate;
@property (nullable, nonatomic, copy) NSString *focus_comment_id; // 从互动消息打开评论直接跳转到该则讯息
@property (nullable, nonatomic, copy) NSString *message_id; // 从互动消息打开评论多带一个参数message_id
@property (nonatomic, copy, nullable) NSIndexPath *focus_comment_indexPath; // 从互动消息打开评论直接跳转到该则讯息
@property(nonatomic, assign) BOOL isVideoOwner; // 是否为该视频拥有者
- (void)loadlistData;
@end

NS_ASSUME_NONNULL_END
