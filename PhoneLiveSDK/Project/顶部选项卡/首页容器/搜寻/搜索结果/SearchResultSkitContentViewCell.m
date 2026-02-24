//
//  SearchResultSkitContentViewCell.m
//  phonelive2
//
//  Created by user on 2024/8/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SearchResultSkitContentViewCell.h"
#import "HomePayBaseViewCell.h"
#import "DramaProgressModel.h"

@interface SearchResultSkitContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *viewCountLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *hotImgView;
@property (nonatomic, strong) UIView *gradientView;

@end

@implementation SearchResultSkitContentViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)updateData {
    HomeRecommendSkit *model = self.itemModel;
    [self updateDataForVip:model.is_vip pay:model.coin_cost ticket:model.ticket_cost canPlay:model.can_play];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.hotImgView.hidden = model.is_hot == 1;
    self.titleLabel.text = model.name;
    self.viewCountLabel.text = [NSString stringWithFormat:YZMsg(@"All %ld episodes, completed"), model.total_episodes];

    if (model.total_episodes == 0) {
        self.viewCountLabel.text = [NSString stringWithFormat:@"%@ %ld/%ld",
                                    YZMsg(@"Serialization"),
                                    model.current_episodes, model.current_episodes];
    } else {
        NSString *title = model.total_episodes == model.current_episodes ? YZMsg(@"Episodes finished") : YZMsg(@"Episodes updating");
        self.viewCountLabel.text = [NSString stringWithFormat:@"%@ %ld/%ld",
                                    title,
                                    model.current_episodes,
                                    model.total_episodes];
    }

    DramaProgressModel *progressModel = [[DramaProgressModel alloc] initWithProgress:model.p_progress];
    CGFloat percent = progressModel.totalTime == 0 ? 0 : (CGFloat)(progressModel.currentTime * 100 / progressModel.totalTime);

    if (model.p_progress.length <= 0) {
        self.timeLabel.text = YZMsg(@"Not watched");
    } else {
        NSString *numberTitle = [NSString stringWithFormat:YZMsg(@"Episode %ld"), progressModel.episode_number];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %d%%", numberTitle, (int)percent];
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

    UIView *gradientView = [[UIView alloc] init];
    gradientView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:gradientView];
    [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(RatioBaseWidth390(48)));
    }];
    self.gradientView = gradientView;

    UIImageView *viewIcon = [[UIImageView alloc] init];
    viewIcon.image = [ImageBundle imagewithBundleName:@"HomeSkitViewIcon"];
    [viewIcon setHidden:YES]; // 短剧的排版，把那个观看量图标去掉
    [self.contentView addSubview:viewIcon];


    [self.timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.viewCountLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(6);
        make.bottom.mas_equalTo(self.contentView).inset(10);
    }];

    [self.contentView addSubview:self.viewCountLabel];
    [self.viewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).inset(6);
        make.centerY.equalTo(self.timeLabel);
    }];
    
    [viewIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.viewCountLabel.mas_left).inset(2);
        make.centerY.equalTo(self.timeLabel);
        make.width.mas_equalTo(@12);
        make.height.mas_equalTo(@6);
    }];

    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(6);
        make.height.equalTo(@17);
        make.bottom.equalTo(self.timeLabel.mas_top).offset(-2);
    }];

    [self.contentView addSubview:self.tagStackView];
    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];

    [self.contentView addSubview:self.hotImgView];
    [self.hotImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.right.mas_equalTo(self.contentView).inset(7);
        make.width.height.mas_equalTo(28);
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
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:10];
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
@end

