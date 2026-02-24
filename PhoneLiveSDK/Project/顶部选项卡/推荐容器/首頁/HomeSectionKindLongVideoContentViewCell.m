//
//  HomeSectionKindLongVideoContentViewCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "HomeSectionKindLongVideoContentViewCell.h"

@interface HomeSectionKindLongVideoContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *videoImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) UILabel *viewCountLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *hotImgView;

@end

@implementation HomeSectionKindLongVideoContentViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(ShortVideoModel*)model {
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.titleLabel.text = model.title;
    self.subtitleLabel.text = model.description_;
    self.viewCountLabel.text = minnum(model.browse_count);
    self.timeLabel.text = model.playTimeShow;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.videoImageView sd_cancelCurrentImageLoad];
    self.videoImageView.image = nil;
    self.titleLabel.text = @"";
    self.viewCountLabel.text = @"";
    self.timeLabel.text = @"";
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;

    UIView *infoContainer = [[UIView alloc] init];
    [self.contentView addSubview:infoContainer];
    [infoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@38);
    }];

    [infoContainer addSubview:self.hotImgView];
    [self.hotImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(infoContainer).offset(-8);
        make.centerY.equalTo(infoContainer);
        make.size.equalTo(@24);
    }];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.subtitleLabel]];
    stackView.axis = UILayoutConstraintAxisVertical;
    [infoContainer addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(infoContainer);
        make.left.equalTo(infoContainer).offset(8);
        make.right.equalTo(self.hotImgView.mas_left).offset(-4);
    }];

    [self.contentView addSubview:self.videoImageView];
    [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.bottom.equalTo(infoContainer.mas_top);
    }];

    UIView *eyeView = [[UIView alloc] init];
    eyeView.layer.cornerRadius = 5;
    eyeView.layer.masksToBounds = YES;
    eyeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.contentView addSubview:eyeView];
    [eyeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(9);
        make.bottom.equalTo(infoContainer.mas_top).offset(-3);
        make.height.equalTo(@14);
    }];

    UIImageView *viewIcon = [[UIImageView alloc] init];
    viewIcon.image = [ImageBundle imagewithBundleName:@"HomeSkitViewIcon"];
    [eyeView addSubview:viewIcon];
    [viewIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(eyeView).offset(3);
        make.centerY.equalTo(eyeView);
        make.width.equalTo(@12);
        make.height.equalTo(@6);
    }];

    [eyeView addSubview:self.viewCountLabel];
    [self.viewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewIcon.mas_right).offset(2);
        make.right.equalTo(eyeView).offset(-2);
        make.top.bottom.equalTo(eyeView);
    }];

    UIView *timeView = [[UIView alloc] init];
    timeView.layer.cornerRadius = 5;
    timeView.layer.masksToBounds = YES;
    timeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.contentView addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-8);
        make.bottom.equalTo(infoContainer.mas_top).offset(-3);
        make.height.equalTo(@14);
    }];

    [timeView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(timeView).inset(4);
        make.top.bottom.equalTo(timeView);
    }];

    [self.contentView addSubview:self.tagStackView];
    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];
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
        _titleLabel.textColor = RGB_COLOR(@"#1A1A1A", 1);
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = RGB_COLOR(@"#8C8C8C", 1);
        _subtitleLabel.font = [UIFont systemFontOfSize:9];
    }
    return _subtitleLabel;
}

- (SDAnimatedImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[SDAnimatedImageView alloc] init];
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoImageView.clipsToBounds = YES;
    }
    return _videoImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:9];
    }
    return _timeLabel;
}

- (UIImageView *)hotImgView {
    if (!_hotImgView) {
        _hotImgView = [UIImageView new];
        _hotImgView.image = [ImageBundle imagewithBundleName:@"HomeLongVideoFireIcon"];
    }
    return _hotImgView;
}
@end
