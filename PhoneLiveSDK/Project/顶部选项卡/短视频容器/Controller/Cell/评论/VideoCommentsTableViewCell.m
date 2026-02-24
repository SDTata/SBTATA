//
//  VideoCommentsTableViewCell.m
//  phonelive2
//
//  Created by user on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoCommentsTableViewCell.h"

@interface VideoCommentsTableViewCell()
@property (nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property (nonatomic, strong) UILabel *writerUserLabel;
@property (nonatomic, strong) UILabel *toUserLabel;
@property (nonatomic, strong) UILabel *commnetLabel;
@property (nonatomic, strong) UILabel *createTimeLabel;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) SDAnimatedImageView *likeImageView;
@property (nonatomic, strong) SDAnimatedImageView *expandMoreImageView;
@property (nonatomic, strong) MASConstraint *createTimeLabelBottomConstraint;
@property (nonatomic, strong) MASConstraint *expandMoreLabelBottomConstraint;
@end

@implementation VideoCommentsTableViewCell

- (instancetype)initWithData:(id)data style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        self.itemModel = data;
        [self updateView];
    }
    return self;
}


- (void)updateView {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.writerUserLabel];
    [self.contentView addSubview:self.toUserLabel];
    [self.contentView addSubview:self.commnetLabel];
    [self.contentView addSubview:self.createTimeLabel];
    [self.contentView addSubview:self.replyButton];
    [self.contentView addSubview:self.likeCountLabel];
    [self.contentView addSubview:self.likeImageView];
    [self.contentView addSubview:self.expandMoreLabel];
    [self.contentView addSubview:self.expandMoreImageView];
    
    [self.writerUserLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.writerUserLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.toUserLabel setContentCompressionResistancePriority: UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.toUserLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.commnetLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.commnetLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.createTimeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.createTimeLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.expandMoreLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    VideoCommentsModel *model = (VideoCommentsModel *)self.itemModel;
    BOOL isSub = ![model.parent_id isEqualToString:@"0"];
    
    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(40);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.leading.mas_equalTo(self.contentView).offset(isSub ? 50 : 10);
    }];
    
    [self.writerUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.avatarImageView);
        make.height.mas_equalTo(22);
    }];
    
    [self.toUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.writerUserLabel.mas_trailing);
        make.trailing.mas_equalTo(self.contentView).inset(10);
        make.top.mas_equalTo(self.avatarImageView);
        make.height.mas_equalTo(22);
    }];
    
    [self.commnetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
        make.trailing.mas_lessThanOrEqualTo(self.likeImageView.mas_leading).inset(2);
        make.top.mas_equalTo(self.writerUserLabel.mas_bottom);
    }];
    
    [self.createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.commnetLabel.mas_bottom);
        make.height.mas_equalTo(22);
        make.bottom.mas_equalTo(self.contentView).priorityLow();
    }];
    
    [self.replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.createTimeLabel.mas_trailing).offset(20);
        make.centerY.mas_equalTo(self.createTimeLabel);
        make.height.mas_equalTo(22);
    }];
    
    [self.likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(10);
        make.centerY.mas_equalTo(self.replyButton);
        make.height.mas_equalTo(22);
    }];
    
    [self.likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.likeCountLabel.mas_leading).inset(4);
        make.centerY.mas_equalTo(self.replyButton);
        make.size.mas_equalTo(13);
    }];
    
    [self.expandMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.replyButton.mas_bottom).offset(4);
        make.height.mas_equalTo(22);
        make.bottom.mas_equalTo(self.contentView).priorityLow();
    }];
    
    [self.expandMoreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.expandMoreLabel.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.expandMoreLabel);
        make.size.mas_equalTo(12);
    }];
}

- (void)updateData {
    
    if ([self.itemModel isKindOfClass:[VideoCommentsModel class]]) {
        VideoCommentsModel *model = (VideoCommentsModel *)self.itemModel;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[ImageBundle imagewithBundleName:@"headDefalt"]];
        self.writerUserLabel.text = model.username;
        self.commnetLabel.text = model.comment;
        self.commnetLabel.textColor = [model.deleted boolValue] ? UIColor.grayColor : RGB_COLOR(@"#1A1A1A", 1);
        self.createTimeLabel.text = [self timeAgoFromDate: model.create_time];
        self.likeCountLabel.text = model.like_count;
        if (model.is_like) {
            self.likeCountLabel.textColor = vkColorRGB(224.0f, 93.0f, 183.0f);
            UIImage *image = [ImageBundle imagewithBundleName:@"comment_like_selected"];
            self.likeImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.likeImageView setTintColor:vkColorRGB(224.0f, 93.0f, 183.0f)];
        } else {
            self.likeCountLabel.textColor = [UIColor blackColor];
            self.likeImageView.image = [ImageBundle imagewithBundleName:@"comment_like_normal"];
        }
        if (model.replies.count == 0 ) {
            [self remakeConstraints:NO isLast:NO];
            [self.expandMoreLabel setHidden:YES];
            [self.expandMoreImageView setHidden:YES];
        } else {
            if (!model.isExpanded) {
                self.expandMoreImageView.image = [ImageBundle imagewithBundleName:@"down_arrow"];
                self.expandMoreLabel.text = [NSString stringWithFormat:@"——— %@%ld%@",
                                             YZMsg(@"short_video_comment_expand"),
                                             model.replies.count,
                                             YZMsg(@"short_video_comment_howManyComments")];
                [self remakeConstraints:YES isLast:NO];
                [self.expandMoreLabel setHidden:NO];
                [self.expandMoreImageView setHidden:NO];
            } else {
                [self remakeConstraints:NO isLast:NO];
                [self.expandMoreLabel setHidden:YES];
                [self.expandMoreImageView setHidden:YES];
            }
        }
    } else if ([self.itemModel isKindOfClass:[VideoCommentsReply class]]) {
        VideoCommentsReply *reply = (VideoCommentsReply *)self.itemModel;;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:reply.avatar] placeholderImage:[ImageBundle imagewithBundleName:@"headDefalt"]];
        self.writerUserLabel.text = reply.username;
        self.toUserLabel.text = reply.to_user.username;
        self.commnetLabel.text = reply.comment;
        self.commnetLabel.textColor = [reply.deleted boolValue] ? UIColor.grayColor : RGB_COLOR(@"#1A1A1A", 1);
        self.createTimeLabel.text = [self timeAgoFromDate: reply.create_time];
        self.likeCountLabel.text = reply.like_count;
        if (reply.isExpandedLast) {
            self.expandMoreImageView.image = [ImageBundle imagewithBundleName:@"up_arrow"];
            self.expandMoreLabel.text = [NSString stringWithFormat:@"——— %@", YZMsg(@"short_video_comment_close")];
            [self remakeConstraints:YES isLast:YES];
            [self.expandMoreLabel setHidden:NO];
            [self.expandMoreImageView setHidden:NO];
        } else {
            [self remakeConstraints:NO isLast:NO];
            [self.expandMoreLabel setHidden:YES];
            [self.expandMoreImageView setHidden:YES];
        }
        if (reply.is_like) {
            self.likeCountLabel.textColor = vkColorRGB(224.0f, 93.0f, 183.0f);
            UIImage *image = [ImageBundle imagewithBundleName:@"comment_like_selected"];
            self.likeImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.likeImageView setTintColor:vkColorRGB(224.0f, 93.0f, 183.0f)];
        } else {
            self.likeCountLabel.textColor = [UIColor blackColor];
            self.likeImageView.image = [ImageBundle imagewithBundleName:@"comment_like_normal"];
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    [self.likeImageView sd_cancelCurrentImageLoad];
    [self.expandMoreImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
    self.likeImageView.image = nil;
    self.expandMoreImageView.image = nil;
    self.writerUserLabel.text = @"";
    self.toUserLabel.text = @"";
    self.commnetLabel.text = @"";
    self.createTimeLabel.text = @"";
    self.likeCountLabel.text = @"";
    self.expandMoreLabel.text = @"";
}

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = 20;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.userInteractionEnabled = YES;
        _avatarImageView.tag = 3;
        [_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _avatarImageView;
}

- (UILabel *)writerUserLabel {
    if (!_writerUserLabel) {
        _writerUserLabel = [[UILabel alloc] init];
        _writerUserLabel.font = [UIFont systemFontOfSize:13];
        _writerUserLabel.textColor = vkColorHex(0x8C8C8C);
        _writerUserLabel.userInteractionEnabled = YES;
        _writerUserLabel.tag = 4;
        [_writerUserLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _writerUserLabel;
}

- (UILabel *)toUserLabel {
    if (!_toUserLabel) {
        _toUserLabel = [[UILabel alloc] init];
        _toUserLabel.font = [UIFont systemFontOfSize:13];
        _toUserLabel.textColor = vkColorHex(0x8C8C8C);
        _toUserLabel.userInteractionEnabled = YES;
        _toUserLabel.tag = 5;
        [_toUserLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _toUserLabel;
}

- (UILabel *)commnetLabel {
    if (!_commnetLabel) {
        _commnetLabel = [[UILabel alloc] init];
        _commnetLabel.font = [UIFont systemFontOfSize:13];
        _commnetLabel.numberOfLines = 0;
        _commnetLabel.textColor = RGB_COLOR(@"#1A1A1A", 1);
    }
    return _commnetLabel;
}

- (UILabel *)createTimeLabel {
    if (!_createTimeLabel) {
        _createTimeLabel = [[UILabel alloc] init];
        _createTimeLabel.font = [UIFont systemFontOfSize:13];
        _createTimeLabel.textColor = vkColorHex(0x8C8C8C);
    }
    return _createTimeLabel;
}

- (UIButton *)replyButton {
    if (!_replyButton) {
        _replyButton = [[UIButton alloc] init];
        _replyButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_replyButton setTitleColor:vkColorHex(0x8C8C8C) forState:UIControlStateNormal];
        [_replyButton setTitle:YZMsg(@"short_video_comment_reply") forState: UIControlStateNormal];
        [_replyButton addTarget:self action:@selector(replyAciton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replyButton;
}

- (UILabel *)likeCountLabel {
    if (!_likeCountLabel) {
        _likeCountLabel = [[UILabel alloc] init];
        _likeCountLabel.font = [UIFont systemFontOfSize:13];
        _likeCountLabel.textColor = [UIColor blackColor];
        _likeCountLabel.userInteractionEnabled = YES;
        _likeCountLabel.tag = 1;
        [_likeCountLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _likeCountLabel;
}

- (SDAnimatedImageView *)likeImageView {
    if (!_likeImageView) {
        _likeImageView = [[SDAnimatedImageView alloc] init];
        _likeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _likeImageView.image = [ImageBundle imagewithBundleName:@"comment_like_normal"];
        _likeImageView.userInteractionEnabled = YES;
        _likeImageView.tag = 1;
        [_likeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _likeImageView;
}

- (UILabel *)expandMoreLabel {
    if (!_expandMoreLabel) {
        _expandMoreLabel = [[UILabel alloc] init];
        _expandMoreLabel.font = [UIFont systemFontOfSize:13];
        _expandMoreLabel.textColor = vkColorHex(0x8C8C8C);
        _expandMoreLabel.userInteractionEnabled = YES;
        _expandMoreLabel.tag = 2;
        [_expandMoreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _expandMoreLabel;
}

- (SDAnimatedImageView *)expandMoreImageView {
    if (!_expandMoreImageView) {
        _expandMoreImageView = [[SDAnimatedImageView alloc] init];
        _expandMoreImageView.contentMode = UIViewContentModeScaleAspectFit;
        _expandMoreImageView.image = [ImageBundle imagewithBundleName:@"down_arrow"];
        _expandMoreImageView.userInteractionEnabled = YES;
        _expandMoreImageView.tag = 2;
        [_expandMoreImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    }
    return _expandMoreImageView;
}

- (void)replyComment {
    if ([self.delegate respondsToSelector:@selector(reply:indexPath:)] && self.indexPath) {
        if ([self.itemModel isKindOfClass:[VideoCommentsModel class]]) {
            VideoCommentsModel *model = (VideoCommentsModel *)self.itemModel;
            [self.delegate reply: model indexPath:self.indexPath];
        } else {
            VideoCommentsReply *reply = (VideoCommentsReply *)self.itemModel;
            [self.delegate reply: reply indexPath:self.indexPath];
        }
    }
}

// 重写 setSelected:animated: 方法。
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self replyComment];
    }
}

- (void)replyAciton:(UIButton *)sender {
    [self replyComment];
}

- (void)handleGesture:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 1: { // 點贊
            if ([self.delegate respondsToSelector:@selector(commentCellDidTapExpandMore:)]) {
                VideoCommentsModel *model = (VideoCommentsModel *)self.itemModel;
                model.is_like = !model.is_like;
                model.like_count = [NSString stringWithFormat:@"%i", model.is_like ? [model.like_count intValue]+1 : abs([model.like_count intValue]-1)];
                self.likeCountLabel.text = model.like_count;
                if (model.is_like) {
                    self.likeCountLabel.textColor = vkColorRGB(224.0f, 93.0f, 183.0f);
                    UIImage *image = [ImageBundle imagewithBundleName:@"comment_like_selected"];
                    self.likeImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [self.likeImageView setTintColor:vkColorRGB(224.0f, 93.0f, 183.0f)];
                } else {
                    self.likeCountLabel.textColor = [UIColor blackColor];
                    self.likeImageView.image = [ImageBundle imagewithBundleName:@"comment_like_normal"];
                }
                [self.delegate likeComment:model.identifier isLike:model.is_like];
            }
            break;
        }
        case 2: { // 展開
            if ([self.delegate respondsToSelector:@selector(commentCellDidTapExpandMore:)]) {
                [self.delegate commentCellDidTapExpandMore:self];
            }
            break;
        }
        case 3: { // 点击头像
            if ([self.delegate respondsToSelector:@selector(tapAvatarImageView:)]) {
                if ([self.itemModel isKindOfClass:[VideoCommentsModel class]]) {
                    VideoCommentsModel *model = (VideoCommentsModel *)self.itemModel;
                    [self.delegate tapAvatarImageView:model.uid];
                } else {
                    VideoCommentsReply *reply = (VideoCommentsReply *)self.itemModel;
                    [self.delegate tapAvatarImageView:reply.uid];
                }
            }
            break;;
        }
        case 4: { // 点击评论者名称
            if ([self.delegate respondsToSelector:@selector(tapUserName:)]) {
                if ([self.itemModel isKindOfClass:[VideoCommentsModel class]]) {
                    VideoCommentsModel *model = (VideoCommentsModel *)self.itemModel;
                    [self.delegate tapUserName:model.uid];
                } else {
                    VideoCommentsReply *reply = (VideoCommentsReply *)self.itemModel;
                    [self.delegate tapUserName:reply.uid];
                }
            }
            break;
        }
        case 5: { // 点击被回复者名称
            if ([self.delegate respondsToSelector:@selector(tapUserName:)]) {
                if ([self.itemModel isKindOfClass:[VideoCommentsReply class]]) {
                    VideoCommentsReply *reply = (VideoCommentsReply *)self.itemModel;
                    [self.delegate tapUserName:reply.to_user.uid];
                }
            }
            break;
        }
    }
}

- (void)remakeConstraints:(BOOL)isExpanded isLast:(BOOL)isLast {
    if (isExpanded) {
        [self.createTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
            make.top.mas_equalTo(self.commnetLabel.mas_bottom);
            make.height.mas_equalTo(22);
        }];
        [self.expandMoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (isLast) {
                make.leading.mas_equalTo(self.avatarImageView);
            } else {
                make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
            }
            make.top.mas_equalTo(self.replyButton.mas_bottom).offset(4);
            make.height.mas_equalTo(22);
            make.bottom.mas_equalTo(self.contentView).priorityLow();
        }];
    } else {
        [self.createTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
            make.top.mas_equalTo(self.commnetLabel.mas_bottom);
            make.height.mas_equalTo(22);
            make.bottom.mas_equalTo(self.contentView).priorityLow();
        }];
        [self.expandMoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (isLast) {
                make.leading.mas_equalTo(self.avatarImageView);
            } else {
                make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(10);
            }
            make.top.mas_equalTo(self.replyButton.mas_bottom).offset(4);
            make.height.mas_equalTo(22);
        }];
    }
}

- (NSString *)timeAgoFromDate:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    if (!date) {
        return @"";
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear
                                               fromDate:date
                                                 toDate:[NSDate date]
                                                options:0];
    
    if (components.year >= 1) {
        return [NSString stringWithFormat:@"%ld%@", (long)components.year, YZMsg(@"short_video_comment_year")];
    } else if (components.month >= 1) {
        return [NSString stringWithFormat:@"%ld%@", (long)components.month, YZMsg(@"short_video_comment_month")];
    } else if (components.weekOfYear >= 1) {
        return [NSString stringWithFormat:@"%ld%@", (long)components.weekOfYear, YZMsg(@"short_video_comment_weekOfYear")];
    } else if (components.day >= 1) {
        return [NSString stringWithFormat:@"%ld%@", (long)components.day, YZMsg(@"short_video_comment_day")];
    } else if (components.hour >= 1) {
        return [NSString stringWithFormat:@"%ld%@", (long)components.hour, YZMsg(@"short_video_comment_hour")];
    } else if (components.minute >= 1) {
        return [NSString stringWithFormat:@"%ld%@", (long)components.minute, YZMsg(@"short_video_comment_minute")];
    } else {
        return YZMsg(@"short_video_comment_justNow");
    }
}
@end
