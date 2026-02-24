//
//  VideoCommentsTableViewCell.h
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKBaseTableViewCell.h"
#import "VideoCommentsModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VideoCommentsCellDelegate <NSObject>
// 评论回复
- (void)reply:(id)model indexPath:(NSIndexPath *)indexPath;

// 评论点赞
- (void)likeComment:(NSString *)videoId isLike:(BOOL)isLike;

// 评论展开收合
- (void)commentCellDidTapExpandMore:(VKBaseTableViewCell *)cell;

// 点击头像
- (void)tapAvatarImageView:(NSString *)uid;

// 点击用户名称
- (void)tapUserName:(NSString *)uid;
@end

@interface VideoCommentsTableViewCell : VKBaseTableViewCell
@property (nonatomic, strong) UILabel *expandMoreLabel;
- (instancetype)initWithData:(id)data style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property(nonatomic,assign) id<VideoCommentsCellDelegate> delelgate;
@end

NS_ASSUME_NONNULL_END
