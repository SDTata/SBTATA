//
//  HomeSectionKindShortVideoContentViewCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/26.
//

#import "HomeSectionKindShortVideoContentViewCell.h"
#import "GKDYTools.h"

@interface HomeSectionKindShortVideoContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *videoTimeLabel;
@property(nonatomic, strong) UIButton *favoriteButton;
@property(nonatomic, strong) ShortVideoModel *model;
@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) SDAnimatedImageView *videoIcon;
@property(nonatomic, strong) UIView *likeNumberView;
@property(nonatomic, strong) UILabel *likeNumberLabel;

@end

@implementation HomeSectionKindShortVideoContentViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

+(CGFloat)ratio {
    return 164 / 128.0;
}

+(CGFloat)minimumLineSpacing {
    return 10.0;
}

- (void)update:(ShortVideoModel*)model {
    self.model = model;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.titleLabel.text = model.title;
    self.nameLabel.text = model.user_name;
    self.favoriteButton.selected = model.is_like == 1;

    self.videoTimeLabel.text = [GKDYTools convertTimeSecond:model.video_duration];
}

- (void)updateForOtherUserMsg:(ShortVideoModel*)model {
    self.model = model;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.titleLabel.text = model.description_;
    self.titleLabel.numberOfLines = 2;
    self.nameLabel.text = [YBToolClass formatLikeNumber:minnum(model.likes_count)];;
    self.favoriteButton.hidden = YES;

    self.videoTimeLabel.text = [GKDYTools convertTimeSecond:model.video_duration];
    self.videoIcon.image = model.is_like == 1 ? [ImageBundle imagewithBundleName:@"iconShortVidoFollowLike"] : [ImageBundle imagewithBundleName:@"iconShortVidoFollowUnlike"];
}

- (void)updateForLikeView:(ShortVideoModel*)model {
    self.model = model;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.titleLabel.text = model.title;
    self.nameLabel.text = model.user_name;
    self.favoriteButton.selected = model.is_like == 1;

    self.videoTimeLabel.text = [GKDYTools convertTimeSecond:model.video_duration];

    self.likeNumberLabel.text = [YBToolClass formatLikeNumber:minnum(model.likes_count)];
    self.videoIcon.layer.cornerRadius = 6.5;
    self.videoIcon.layer.masksToBounds = YES;
    [self.videoIcon sd_setImageWithURL:[NSURL URLWithString:model.user_avatar]];
}

- (void)updateData {
    ShortVideoModel *model = self.itemModel;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.titleLabel.text = model.title;
    self.nameLabel.text = model.user_name;
    self.favoriteButton.selected = model.is_like == 1;

    self.videoTimeLabel.text = [GKDYTools convertTimeSecond:model.video_duration];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
    self.titleLabel.text = @"";
    self.nameLabel.text = @"";
    self.favoriteButton.selected = NO;
    self.likeNumberLabel.text = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.gradientView.verticalColors = @[RGB_COLOR(@"#000000", 0.0), RGB_COLOR(@"#000000", 0.2)];
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;

    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    UIView *gradientView = [[UIView alloc] init];
    gradientView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:gradientView];
    [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(RatioBaseWidth390(65)));
    }];
    self.gradientView = gradientView;

    [self.contentView addSubview:self.videoIcon];
    [self.videoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).inset(8);
        make.bottom.equalTo(self.contentView).inset(6);
        make.size.equalTo(@13);
    }];

    [self.videoTimeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.videoTimeLabel];
    [self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-8);
        make.centerY.equalTo(self.videoIcon);
    }];

    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoIcon.mas_right).offset(2);
        make.centerY.equalTo(self.videoIcon);
        make.right.lessThanOrEqualTo(self.videoTimeLabel.mas_left).offset(-1);
    }];

    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(6);
        make.height.greaterThanOrEqualTo(@17);
        make.bottom.equalTo(self.videoIcon.mas_top).offset(-5);
    }];

    [self.contentView addSubview:self.tagStackView];
    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];

    [self addSubview:self.likeNumberView];
    [self.likeNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.height.equalTo(@32);
    }];

    [self addSubview:self.favoriteButton];
    [self.favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self.likeNumberView.mas_left);
        make.left.greaterThanOrEqualTo(self.tagStackView.mas_right).offset(-4);
        make.size.equalTo(@32);
    }];
}

#pragma mark - Lazy

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:9];
    }
    return _nameLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)videoTimeLabel {
    if (!_videoTimeLabel) {
        _videoTimeLabel = [[UILabel alloc] init];
        _videoTimeLabel.textColor = RGB_COLOR(@"#ffffff", 0.8);
        _videoTimeLabel.font = [UIFont systemFontOfSize:9];
    }
    return _videoTimeLabel;
}

- (UIButton *)favoriteButton {
    if (!_favoriteButton) {
        _favoriteButton = [UIButton new];
        [_favoriteButton setImage:[ImageBundle imagewithBundleName:@"iconShortVidoFollowUnlike"] forState:UIControlStateNormal];
        [_favoriteButton setImage:[ImageBundle imagewithBundleName:@"iconShortVidoFollowLike"] forState:UIControlStateSelected];
        _favoriteButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return _favoriteButton;
}

- (SDAnimatedImageView *)videoIcon {
    if (!_videoIcon) {
        _videoIcon = [[SDAnimatedImageView alloc] init];
        _videoIcon.image = [ImageBundle imagewithBundleName:@"iconShortVidoFollowPlay"];
    }
    return _videoIcon;
}

- (UIView *)likeNumberView {
    if (!_likeNumberView) {
        _likeNumberView = [UIView new];
        _likeNumberView.backgroundColor = UIColor.clearColor;
        [_likeNumberView addSubview:self.likeNumberLabel];
        [self.likeNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_likeNumberView).offset(-1);
            make.bottom.equalTo(_likeNumberView);
            make.left.equalTo(_likeNumberView).offset(-7);
            make.right.equalTo(_likeNumberView).offset(-7);
        }];
    }
    return _likeNumberView;
}

- (UILabel *)likeNumberLabel {
    if (!_likeNumberLabel) {
        _likeNumberLabel = [[UILabel alloc] init];
        _likeNumberLabel.textColor = [UIColor whiteColor];
        _likeNumberLabel.font = [UIFont systemFontOfSize:12];
        _likeNumberLabel.layer.shadowOpacity = 0.5;
        _likeNumberLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _likeNumberLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _likeNumberLabel;
}

@end
