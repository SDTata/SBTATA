//
//  InteractiveMessagesCell.h
//  phonelive2
//
//  Created by user on 2024/8/7.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKBaseTableViewCell.h"
#import "MessageListNetworkUtil.h"

NS_ASSUME_NONNULL_BEGIN

@protocol InteractiveMessagesCellDelegate <NSObject>
// 点击头像
- (void)tapAvatarImageView:(NSString *)uid;
// 评论回复
- (void)reply:(InteractionMessagesModel *)model indexPath:(NSIndexPath *)indexPath;
// 评论点赞
- (void)likeComment:(NSString *)comment_id isLike:(BOOL)isLike indexPath:(NSIndexPath *)indexPath;
@end

@interface InteractiveMessagesCell : VKBaseTableViewCell
@property(nonatomic, strong) UIButton *deleteButton;

// 实例方法：根据内容计算并更新单元格高度
- (void)calculateHeightForContent:(NSString *)content;

// 类方法：根据内容计算单元格高度
+ (CGFloat)heightForContent:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
