//
//  InteractiveMessagesCell.m
//  phonelive2
//
//  Created by user on 2024/8/7.
//  Copyright © 2024 toby. All rights reserved.
//

#import "InteractiveMessagesCell.h"

@interface InteractiveMessagesCell ()
@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UILabel *createTimeLabel;
@property(nonatomic, strong) SDAnimatedImageView *rightCoverImageView;
@property(nonatomic, strong) UIView *unreadView;
@property(nonatomic, strong) SDAnimatedImageView *replyAvatarImageView;
@property(nonatomic, strong) UILabel *replyTitleLabel;
@property(nonatomic, strong) SDAnimatedImageView *likeIconImageView;
@property(nonatomic, strong) UILabel *likeLabel;
@property(nonatomic, strong) UIView *replyBg;
@property(nonatomic, strong) UIView *likeBg;
@end
@implementation InteractiveMessagesCell
+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 0;
}

+ (CGFloat)itemHeight {
    // Default height, will be overridden by calculateHeightForContent
    return 92.0;
}

// Class method to calculate height based on content
+ (CGFloat)heightForContent:(NSString *)content {
    if (!content || content.length == 0) {
        return [self itemHeight]; // Return default height if no content
    }
    
    // 计算最大可用宽度，不考虑右侧图片
    // 考虑头像(50) + 左边距(14) + 头像右边距(13) + 右边距(14)
    CGFloat availableWidth = [UIScreen mainScreen].bounds.size.width - 14 - 50 - 13 - 14;
    
    // Calculate the height needed for the content with the available width
    CGSize constraintSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    
    CGRect textRect = [content boundingRectWithSize:constraintSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    
    // Calculate the height needed for the content
    CGFloat contentHeight = ceil(textRect.size.height);
    CGFloat defaultLabelHeight = 17; // Original fixed height
    
    // Calculate additional height if content is larger than default
    CGFloat additionalHeight = MAX(0, contentHeight - defaultLabelHeight);
    
    // 获取消息类型，用于判断是否显示底部按钮
    NSString *messageType = nil;
    
    // 判断内容是否包含回复消息的特定文本
    if ([content containsString:YZMsg(@"short_video_comment_reply")]) {
        messageType = @"2"; // 回复类型
    }
    
    // 底部按钮的高度，如果不显示则减去这个高度
    CGFloat bottomButtonsHeight = 20;
    CGFloat bottomPadding = 10;
    CGFloat totalBottomHeight = bottomButtonsHeight + bottomPadding;
    
    // 如果是回复类型，显示底部按钮，否则不显示
    BOOL showBottomButtons = [messageType isEqualToString:@"2"];
    
    // 基础高度(92) + 内容需要的额外高度 - 如果不显示底部按钮则减去底部高度
    return [self itemHeight] + additionalHeight - (showBottomButtons ? 0 : totalBottomHeight);
}

- (void)updateData {
    InteractionMessagesModel *model = (InteractionMessagesModel *)self.itemModel;
    if ([model.messageType isEqualToString:@"system"] && [model.from_user_avatar isEqualToString:@""]) {
        self.avatarImageView.image = [PublicObj getAppIcon];
    } else {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.from_user_avatar] placeholderImage: [PublicObj getAppIcon]];
    }
    self.titleLabel.text = model.from_user_name;
    NSString *contentText = nil;
    if ([model.type isEqualToString:@"1"]) {
        contentText = YZMsg(@"comment_replay_like_des");
    } else if ([model.type isEqualToString:@"2"]) {
        contentText = [NSString stringWithFormat:@"%@:%@", YZMsg(@"short_video_comment_reply"), model.content];
    } else if ([model.type isEqualToString:@"3"]) {
        contentText = YZMsg(@"comment_replay_like_video_des");
    } else if ([model.type isEqualToString:@"4"]) {
        if (model.content && model.content.length > 0) {
            contentText = [NSString stringWithFormat:@"%@:%@", YZMsg(@"comment_post_new_video"), model.content];
        } else {
            contentText = YZMsg(@"comment_post_new_video");
        }
    } else {
        contentText = model.content;
    }
    self.subTitleLabel.text = contentText;
    
    // Calculate and update cell height based on content
    [self calculateHeightForContent:contentText];
    self.createTimeLabel.text = model.create_time;
    [self.unreadView setHidden: [model.is_read boolValue]];
    WeakSelf
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:model.short_video_cover] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
    {} completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
    {
        STRONGSELF
        if (!strongSelf) return;
        if (image) {
            UIImage *roundedImage = [strongSelf imageWithRoundedCorners:image cornerRadius:36];
            strongSelf.rightCoverImageView.image = roundedImage;
        }
        
    }];
    [self.replyAvatarImageView sd_setImageWithURL:[NSURL URLWithString:model.from_user_avatar] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    self.replyTitleLabel.text = YZMsg(@"message_list_reply_comment");
    NSString *iconName = model.is_like ? @"ShortVideoLoveOnIcon" : @"ShortVideoLoveIcon";
    UIImage *iconImage = [ImageBundle imagewithBundleName:iconName];
    if (!model.is_like) {
        iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.likeIconImageView.image = iconImage;
    self.likeIconImageView.tintColor = vkColorRGB(195, 195, 195);
    self.likeLabel.text = YZMsg(@"message_list_like");
    if ([model.type isEqualToString:@"2"]) {
        self.replyBg.hidden = NO;
        self.likeBg.hidden = YES; // 互动消息列表的点赞消息，下面不要显示💗赞的快捷点赞按钮 因为不可以点赞，没法用
    } else {
        self.replyBg.hidden = YES;
        self.likeBg.hidden = YES;
    }
}

- (void)updateView {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.unreadView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.rightCoverImageView];
    UIView *replyBg = [UIView new];
    replyBg.tag = 2;
    [replyBg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    replyBg.backgroundColor = vkColorRGBA(216, 215, 218, 0.8);
    replyBg.layer.cornerRadius = 10;
    replyBg.layer.masksToBounds = YES;
    [self.contentView addSubview: replyBg];
    [replyBg addSubview:self.replyAvatarImageView];
    [replyBg addSubview:self.replyTitleLabel];
    self.replyBg = replyBg;
    
    UIView *likeBg = [UIView new];
    likeBg.tag = 3;
    [likeBg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    likeBg.backgroundColor = vkColorRGBA(216, 215, 218, 0.8);
    likeBg.layer.cornerRadius = 10;
    likeBg.layer.masksToBounds = YES;
    [self.contentView addSubview: likeBg];
    [likeBg addSubview:self.likeIconImageView];
    [likeBg addSubview:self.likeLabel];
    self.likeBg = likeBg;
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(14);
        make.top.mas_equalTo(self.contentView).inset(10);
        make.size.mas_equalTo(50);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(13);
        make.height.mas_equalTo(23);
        make.top.mas_equalTo(self.avatarImageView.mas_top);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(13);
        // 不设置固定高度，允许根据内容自适应
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        // 如果有右侧图片，则使用右侧图片作为参考点，否则使用内容视图的右边缘
        InteractionMessagesModel *model = (InteractionMessagesModel *)self.itemModel;
        if (model.short_video_cover && model.short_video_cover.length > 0) {
            make.trailing.mas_equalTo(self.rightCoverImageView.mas_leading).inset(10);
        } else {
            make.trailing.mas_equalTo(self.contentView).inset(14); // 直接使用内容视图的右边缘，只留出14点的边距
        }
    }];
    
    [self.createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(13);
        make.height.mas_equalTo(14);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom);
        make.trailing.mas_equalTo(self.contentView).inset(10);
    }];
    
    [self.unreadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(8);
        make.centerX.mas_equalTo(self.avatarImageView).offset(20);
        make.centerY.mas_equalTo(self.avatarImageView.mas_top).offset(5);
    }];
    
    [self.rightCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(72);
        make.top.mas_equalTo(self.avatarImageView);
        make.trailing.mas_equalTo(self.contentView).inset(14);
    }];
    
    [replyBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.createTimeLabel);
        make.top.mas_equalTo(self.createTimeLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.contentView).inset(10);
    }];
    
    [self.replyAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.centerY.mas_equalTo(replyBg);
        make.size.mas_equalTo(18);
    }];
    
    [self.replyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.replyAvatarImageView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(self.replyAvatarImageView);
        make.trailing.mas_equalTo(replyBg).inset(5);
        make.height.mas_equalTo(18);
    }];
    
    [likeBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(replyBg.mas_trailing).offset(24);
        make.top.mas_equalTo(self.createTimeLabel.mas_bottom).offset(1);
        make.height.mas_equalTo(20);
    }];
    
    [self.likeIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(likeBg).offset(5);
        make.centerY.mas_equalTo(likeBg);
        make.size.mas_equalTo(14);
    }];
    
    [self.likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.likeIconImageView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(self.likeIconImageView);
        make.trailing.mas_equalTo(likeBg).inset(5);
        make.height.mas_equalTo(18);
    }];
    
    UIView *lineSeparators = [UIView new];
    lineSeparators.backgroundColor = vkColorRGB(199, 199, 199);
    [self.contentView addSubview:lineSeparators];
    [lineSeparators mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.contentView);
        make.leading.trailing.mas_equalTo(self.contentView).inset(14);
    }];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:YZMsg(@"BetCell_remove") forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:vkFont(14)];
    deleteButton.hidden = YES;
    deleteButton.backgroundColor = UIColor.redColor;
    [deleteButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(75);
        make.leading.mas_equalTo(self.contentView.mas_trailing);
    }];
    self.deleteButton = deleteButton;
}

- (void)deleteButtonTapped:(UIButton *)sender {
    ///TODO:
}

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 25;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.userInteractionEnabled = YES;
        _avatarImageView.tag = 1;
        [_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _avatarImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = vkColorRGB(26, 26, 26);
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.userInteractionEnabled = YES;
        _titleLabel.tag = 1;
        [_titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = vkColorRGB(26, 26, 26);
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.numberOfLines = 0; // Allow multiple lines
        _subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _subTitleLabel;
}

- (UILabel *)createTimeLabel {
    if (!_createTimeLabel) {
        _createTimeLabel = [[UILabel alloc] init];
        _createTimeLabel.textColor = vkColorRGB(77, 77, 77);
        _createTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _createTimeLabel;
}

- (SDAnimatedImageView *)rightCoverImageView {
    if (!_rightCoverImageView) {
        _rightCoverImageView = [[SDAnimatedImageView alloc] init];
        _rightCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightCoverImageView.clipsToBounds = YES;
    }
    return _rightCoverImageView;
}

- (UIView *)unreadView {
    if (!_unreadView) {
        _unreadView = [[UIView alloc] init];
        _unreadView.layer.cornerRadius = 4;
        _unreadView.layer.masksToBounds = YES;
        _unreadView.backgroundColor = UIColor.redColor;
    }
    return _unreadView;
}

- (SDAnimatedImageView *)replyAvatarImageView {
    if (!_replyAvatarImageView) {
        _replyAvatarImageView = [[SDAnimatedImageView alloc] init];
        _replyAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _replyAvatarImageView.layer.cornerRadius = 9;
        _replyAvatarImageView.layer.masksToBounds = YES;
        _replyAvatarImageView.clipsToBounds = YES;
        _replyAvatarImageView.userInteractionEnabled = YES;
        _replyAvatarImageView.tag = 2;
        [_replyAvatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _replyAvatarImageView;
}

- (UILabel *)replyTitleLabel {
    if (!_replyTitleLabel) {
        _replyTitleLabel = [[UILabel alloc] init];
        _replyTitleLabel.textColor = vkColorRGB(77, 77, 77);
        _replyTitleLabel.font = [UIFont systemFontOfSize:12];
        _replyTitleLabel.userInteractionEnabled = YES;
        _replyTitleLabel.tag = 2;
        [_replyTitleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _replyTitleLabel;
}

- (SDAnimatedImageView *)likeIconImageView {
    if (!_likeIconImageView) {
        _likeIconImageView = [[SDAnimatedImageView alloc] init];
        _likeIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _likeIconImageView.userInteractionEnabled = YES;
        _likeIconImageView.tag = 3;
        [_likeIconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _likeIconImageView;
}

- (UILabel *)likeLabel {
    if (!_likeLabel) {
        _likeLabel = [[UILabel alloc] init];
        _likeLabel.textColor = vkColorRGB(77, 77, 77);
        _likeLabel.font = [UIFont systemFontOfSize:12];
        _likeLabel.userInteractionEnabled = YES;
        _likeLabel.tag = 3;
        [_likeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _likeLabel;
}

- (void)handleGesture:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 1:
            if ([self.delegate respondsToSelector:@selector(tapAvatarImageView:)]) {
                if ([self.itemModel isKindOfClass:[InteractionMessagesModel class]]) {
                    InteractionMessagesModel *model = (InteractionMessagesModel *)self.itemModel;
                    [self.delegate tapAvatarImageView:model.from_uid];
                }
            }
            break;
        case 2:
            if ([self.delegate respondsToSelector:@selector(reply:indexPath:)]) {
                if ([self.itemModel isKindOfClass:[InteractionMessagesModel class]]) {
                    InteractionMessagesModel *model = (InteractionMessagesModel *)self.itemModel;
                    [self.delegate reply: model indexPath:self.indexPath];
                }
            }
            break;
        case 3:
            if ([self.delegate respondsToSelector:@selector(likeComment:isLike:indexPath:)]) {
                if ([self.itemModel isKindOfClass:[InteractionMessagesModel class]]) {
                    InteractionMessagesModel *model = (InteractionMessagesModel *)self.itemModel;
                    [self.delegate likeComment: model.comment_id isLike:!model.is_like indexPath:self.indexPath];
                }
            }
            break;
    }
}
- (UIImage *)imageWithRoundedCorners:(UIImage *)image cornerRadius:(CGFloat)cornerRadius {
    // 创建一个新的图形上下文，大小与图片相同
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    // 创建圆角路径
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    
    // 绘制图片到圆角路径中
    [image drawInRect:rect];
    
    // 获取新的图片
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

// 计算并更新单元格高度基于内容文本
- (void)calculateHeightForContent:(NSString *)content {
    if (!content || content.length == 0) {
        return;
    }
    
    // 获取子标题标签的可用宽度
    CGFloat availableWidth = 0;
    InteractionMessagesModel *model = (InteractionMessagesModel *)self.itemModel;
    
    if (model.short_video_cover && model.short_video_cover.length > 0) {
        // 有右侧图片时的计算
        // 考虑头像(50) + 左边距(14) + 头像右边距(13) + 右侧图片(72) + 右边距(14) + 内边距(10)
        availableWidth = [UIScreen mainScreen].bounds.size.width - 14 - 50 - 13 - 72 - 14 - 10;
    } else {
        // 没有右侧图片时的计算
        // 考虑头像(50) + 左边距(14) + 头像右边距(13) + 右边距(14)
        availableWidth = [UIScreen mainScreen].bounds.size.width - 14 - 50 - 13 - 14;
    }
    
    // 根据可用宽度计算内容所需的高度
    CGSize constraintSize = CGSizeMake(availableWidth, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    
    CGRect textRect = [content boundingRectWithSize:constraintSize
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    
    // 计算内容所需的高度
    CGFloat contentHeight = ceil(textRect.size.height);
    CGFloat defaultLabelHeight = 17; // 原始固定高度
    
    // 检查底部按钮是否显示
    BOOL showBottomButtons = NO;
    if ([model.type isEqualToString:@"2"]) {
        // 如果是回复类型，显示回复按钮
        showBottomButtons = YES;
    }
    
    // 只有当内容高度大于默认高度时才更新
    if (contentHeight > defaultLabelHeight) {
        // 更新subTitleLabel的高度约束
        [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(13);
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.height.mas_equalTo(contentHeight);
            
            // 根据是否有右侧图片设置不同的右侧约束
            if (model.short_video_cover && model.short_video_cover.length > 0) {
                make.trailing.mas_equalTo(self.rightCoverImageView.mas_leading).inset(10);
            } else {
                make.trailing.mas_equalTo(self.contentView).inset(14);
            }
        }];
        
        // 确保所有其他元素相对于子标题标签正确定位
        [self.createTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.subTitleLabel.mas_bottom);
        }];
        
        // 如果有回复/点赞按钮，也更新它们的位置
        if (self.replyBg) {
            [self.replyBg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.createTimeLabel.mas_bottom).offset(1);
                // 如果不显示底部按钮，设置高度为0
                make.height.mas_equalTo(showBottomButtons ? 20 : 0);
            }];
        }
        
        if (self.likeBg) {
            [self.likeBg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.createTimeLabel.mas_bottom).offset(1);
                // 如果不显示底部按钮，设置高度为0
                make.height.mas_equalTo(showBottomButtons ? 20 : 0);
            }];
        }
        
        // 强制刷新布局
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}
@end
