//
//  SearchResultShortVideosContentViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SearchResultShortVideosContentViewCell.h"
#import "DramaProgressModel.h"

@interface SearchResultShortVideosContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *coverImageView;
@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *loveCountLabel;
@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) UIImageView *loveIconImageView;

@end

@implementation SearchResultShortVideosContentViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)updateData {
    ShortVideoModel *model = self.itemModel;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.titleLabel.text = model.title;
    self.userNameLabel.text = model.user_name;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.user_avatar] placeholderImage: [ImageBundle imagewithBundleName:@"profile_accountImg"]];
    self.loveCountLabel.text = [YBToolClass formatLikeNumber:[@(model.likes_count) stringValue]];
    if (model.is_like) {
        self.loveIconImageView.image = [ImageBundle imagewithBundleName:@"iconShortVidoFollowLike"];
    } else {
        UIImage *image = [[ImageBundle imagewithBundleName:@"HotShortVideoLoveIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.loveIconImageView.image = image;
        self.loveIconImageView.tintColor = [UIColor blackColor];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
    self.titleLabel.text = @"";
    self.loveCountLabel.text = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];

    //self.gradientView.verticalColors = @[RGB_COLOR(@"#000000", 0.0), RGB_COLOR(@"#000000", 0.2)];
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;

    UIImageView *loveIcon = [[UIImageView alloc] init];
    UIImage *image = [[ImageBundle imagewithBundleName:@"HotShortVideoLoveIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    loveIcon.image = image;
    loveIcon.tintColor = [UIColor blackColor];
    self.loveIconImageView = loveIcon;
    
    
    UIView *gradientView = [[UIView alloc] init];
    gradientView.backgroundColor = [UIColor whiteColor];
    self.gradientView = gradientView;

    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:gradientView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.loveCountLabel];
    [self.contentView addSubview:self.loveIconImageView];
    [self.contentView addSubview:self.tagStackView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.avatarImageView];
    
    [self.loveCountLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.loveCountLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(gradientView.top);
    }];

    [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.titleLabel.mas_top).inset(-5);//make.height.equalTo(@(RatioBaseWidth390(48)));
    }];

    [self.loveCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).inset(6);
        make.bottom.mas_equalTo(self.contentView).inset(8);
    }];
    
    [loveIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.loveCountLabel.mas_left).inset(4);
        make.centerY.mas_equalTo(self.loveCountLabel);
        make.size.mas_equalTo(@12);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(6);
        make.bottom.equalTo(loveIcon.mas_top).inset(5);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.size.mas_equalTo(@16);
        make.centerY.mas_equalTo(self.loveCountLabel);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarImageView.mas_right).offset(4);
        make.right.mas_equalTo(loveIcon.mas_left).inset(2);
        make.centerY.mas_equalTo(self.loveCountLabel);
    }];
    
    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];
}

- (UILabel *)loveCountLabel {
    if (!_loveCountLabel) {
        _loveCountLabel = [[UILabel alloc] init];
        _loveCountLabel.textColor = [UIColor blackColor];
        _loveCountLabel.font = [UIFont systemFontOfSize:10];
    }
    return _loveCountLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor blackColor];
        _userNameLabel.font = [UIFont systemFontOfSize:11];
    }
    return _userNameLabel;
}

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 8;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (SDAnimatedImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[SDAnimatedImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (UIImageView *)loveIconImageView {
    if (!_loveIconImageView) {
        _loveIconImageView = [[UIImageView alloc] init];
        _loveIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _loveIconImageView.clipsToBounds = YES;
    }
    return _loveIconImageView;
}
@end
