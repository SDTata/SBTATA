//
//  MessageListViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MessageListViewCell.h"
#import "MessageListNetworkUtil.h"

@interface MessageListViewCell ()
@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) SDAnimatedImageView *rightArrowImageView;
@property(nonatomic, strong) UILabel *messageCountLabel;
@end

@implementation MessageListViewCell
+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return 54.0;
}

- (void)updateData {
    NewMessageListModel *model = (NewMessageListModel *)self.itemModel;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.titleLabel.text = model.title;
    self.messageCountLabel.text = [NSString stringWithFormat:@"%li", (long)model.unread_count];
    self.rightArrowImageView.hidden = model.unread_count != 0;
    self.messageCountLabel.hidden = model.unread_count == 0;
    if (model.first_message && [model.first_message.messageType isEqualToString:@"interaction"]) {
        NSString *content;
        if ([model.first_message.type isEqualToString:@"1"]) {
            content = [NSString stringWithFormat:@"%@:%@",YZMsg(@"comment_replay_like_des"), model.first_message.content];
        } else if ([model.first_message.type isEqualToString:@"2"]) {
            content = [NSString stringWithFormat:@"%@:%@", YZMsg(@"short_video_comment_reply"), model.first_message.content];
        } else if ([model.first_message.type isEqualToString:@"3"]) {
            content = [NSString stringWithFormat:@"%@:%@", YZMsg(@"comment_replay_like_video_des"), model.first_message.content];
        } else if ([model.first_message.type isEqualToString:@"4"]) {
            content = [NSString stringWithFormat:@"%@:%@", YZMsg(@"comment_post_new_video"), model.first_message.content];
        }
        self.subTitleLabel.text = (model.first_message.content && model.first_message.content.length > 0) ? [NSString stringWithFormat:@"%@ %@",model.first_message.from_user_name, content] : YZMsg(@"public_noEmpty");
    } else {
        self.subTitleLabel.text = (model.first_message.content && model.first_message.content.length > 0) ? model.first_message.content : YZMsg(@"public_noEmpty");
    }
}

- (void)updateView {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.rightArrowImageView];
    [self.contentView addSubview:self.messageCountLabel];
    [self.messageCountLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(14);
        //make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).inset(10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(13);
        make.height.mas_equalTo(23);
        make.top.mas_equalTo(self.avatarImageView.mas_top).offset(5);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(13);
        make.height.mas_equalTo(17);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.trailing.mas_equalTo(self.rightArrowImageView.mas_leading).inset(10);
    }];
    
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(27);
        make.width.mas_equalTo(6);
        make.height.mas_equalTo(12);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.messageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).inset(27);
        make.height.mas_equalTo(14);
        make.width.mas_greaterThanOrEqualTo(14);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 25;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = vkColorRGB(77, 77, 77);
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _subTitleLabel;
}

- (SDAnimatedImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [[SDAnimatedImageView alloc] init];
        _rightArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightArrowImageView.image = [ImageBundle imagewithBundleName:@"arrows_43"];
    }
    return _rightArrowImageView;
}

- (UILabel *)messageCountLabel {
    if (!_messageCountLabel) {
        _messageCountLabel = [[UILabel alloc] init];
        _messageCountLabel.backgroundColor = vkColorRGB(242, 81, 187);
        _messageCountLabel.textColor = [UIColor whiteColor];
        _messageCountLabel.textAlignment = NSTextAlignmentCenter;
        _messageCountLabel.layer.cornerRadius = 7;
        _messageCountLabel.layer.masksToBounds = YES;
        _messageCountLabel.numberOfLines = 1;
        _messageCountLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightRegular];
    }
    return _messageCountLabel;
}
@end
