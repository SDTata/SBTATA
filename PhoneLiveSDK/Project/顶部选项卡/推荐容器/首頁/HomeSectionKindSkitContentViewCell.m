//
//  HomeSectionKindSkitContentViewCell.m
//  NewDrama
//
//  Created by s5346 on 2024/7/2.
//

#import "HomeSectionKindSkitContentViewCell.h"
#import "DramaProgressModel.h"
#import "VideoProgressManager.h"

@interface HomeSectionKindSkitContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *viewCountLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *hotImgView;
@property (nonatomic, strong) UIView *gradientView;
@property(nonatomic, strong) UIButton *favoriteButton;
@property(nonatomic, strong) HomeRecommendSkit *model;
//@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation HomeSectionKindSkitContentViewCell

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

- (void)update:(HomeRecommendSkit*)model {
    self.model = model;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.hotImgView.hidden = model.is_hot == 1;
    self.titleLabel.text = model.name;
    self.favoriteButton.selected = model.is_favorite == 1;
    
    if (model.total_episodes == 0) {
        self.viewCountLabel.text = [NSString stringWithFormat:@"%@ %ld/%ld",
                                    YZMsg(@"Serialization"),
                                    model.current_episodes, model.current_episodes];
    } else {
        NSDictionary *dict = [VideoProgressManager loadUserProgress:model.skit_id];
        NSInteger currentEpisode = [dict[@"currentEpisode"] integerValue];
//        currentEpisode = currentEpisode > 0 ? currentEpisode : model.current_episodes;
        NSString *title = model.total_episodes == model.current_episodes ? YZMsg(@"Episodes finished") : YZMsg(@"Episodes updating");
        self.viewCountLabel.text = [NSString stringWithFormat:@"%@ %ld/%ld",
                                    title,
                                    currentEpisode,
                                    model.total_episodes];
    }

    DramaProgressModel *progressModel = [[DramaProgressModel alloc] initWithProgress:model.p_progress];
    CGFloat percent = progressModel.totalTime == 0 ? 0 : (CGFloat)(progressModel.currentTime * 100 / progressModel.totalTime);

    if (model.p_progress.length <= 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@  ", YZMsg(@"Not watched")];
    } else {
        NSString *numberTitle = [NSString stringWithFormat:YZMsg(@"Episode %ld"), progressModel.episode_number];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %d%%  ", numberTitle, (int)percent];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
    self.titleLabel.text = @"";
    self.viewCountLabel.text = @"";
    self.timeLabel.text = @"";
    self.hotImgView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.gradientView.verticalColors = @[RGB_COLOR(@"#000000", 0.0), RGB_COLOR(@"#000000", 0.2)];
//    self.gradientLayer.colors = @[(__bridge id)[RGB_COLOR(@"#5E3780", 0) CGColor],
//                             (__bridge id)[RGB_COLOR(@"#330044", 1) CGColor]];
//    self.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.gradientView.frame), CGRectGetHeight(self.gradientView.frame));
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 16;
    self.contentView.layer.masksToBounds = YES;

    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    self.gradientView = [[UIView alloc] init];
    self.gradientView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.gradientView];
    [self.gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(RatioBaseWidth390(48)));
    }];

    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.viewCountLabel];
    [self.viewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(6);
        make.bottom.equalTo(self.contentView).offset(-9);
        make.right.equalTo(self.timeLabel.mas_left).offset(-4);
        make.height.equalTo(@12);
    }];

    [self.timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-5);
        make.centerY.equalTo(self.viewCountLabel);
        make.height.mas_equalTo(16);
    }];

    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(6);
        make.height.equalTo(@17);
        make.bottom.equalTo(self.viewCountLabel.mas_top).offset(-2);
    }];

    [self.contentView addSubview:self.tagStackView];
    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];

//    [self.contentView addSubview:self.hotImgView];
//    [self.hotImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-10);
//        make.top.right.mas_equalTo(self.contentView).inset(7);
//        make.width.height.mas_equalTo(28);
//    }];
    
    [self.contentView addSubview:self.favoriteButton];
    [self.favoriteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self).inset(-3);
        make.size.equalTo(@36);
    }];

//    self.gradientLayer = [[CAGradientLayer alloc] init];
//    self.gradientLayer.startPoint = CGPointMake(0, 0);
//    self.gradientLayer.endPoint = CGPointMake(0, 1);
//    [self.gradientView.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (UILabel *)viewCountLabel {
    if (!_viewCountLabel) {
        _viewCountLabel = [[UILabel alloc] init];
        _viewCountLabel.textColor = [UIColor whiteColor];
        _viewCountLabel.font = [UIFont systemFontOfSize:10];
    }
    return _viewCountLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
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

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.font = [UIFont systemFontOfSize:9];
        _timeLabel.backgroundColor = vkColorHexA(0xffffff, 0.7);
        _timeLabel.layer.cornerRadius = 8;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

- (UIImageView *)hotImgView {
    if (!_hotImgView) {
        _hotImgView = [UIImageView new];
        _hotImgView.image = [ImageBundle imagewithBundleName:@"HomeLongVideoFireIcon"];
        _hotImgView.hidden = YES;
    }
    return _hotImgView;
}

- (UIButton *)favoriteButton {
    if (!_favoriteButton) {
        _favoriteButton = [UIButton new];
        [_favoriteButton setImage:[ImageBundle imagewithBundleName:@"skitLikeIconOff"] forState:UIControlStateNormal];
        [_favoriteButton setImage:[ImageBundle imagewithBundleName:@"skitLikeIconOn"] forState:UIControlStateSelected];
        _favoriteButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return _favoriteButton;
}

@end
