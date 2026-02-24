//
//  HomeSectionKindLiveStreamingContentViewCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "HomeSectionKindLiveStreamingContentViewCell.h"
#import "LiveGifImage.h"
@interface HomeSectionKindLiveStreamingContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *fireCountLabel;
@property(nonatomic, strong) UIStackView *tagsStackView;
@property(nonatomic, strong) UIView *normalTagView;
@property(nonatomic, strong) UIView *lockTagView;
@property(nonatomic, strong) UIView *timeTagView;
@property (nonatomic, strong) YYAnimatedImageView *liveGifImg;
@property (nonatomic, strong) UIView *gradientView;

@end

@implementation HomeSectionKindLiveStreamingContentViewCell

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

- (void)update:(hotModel*)model {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar_thumb]];
    self.titleLabel.text = model.title;
    self.nameLabel.text = [NSString stringWithFormat:@"@%@", model.zhuboName];
    self.fireCountLabel.text = [YBToolClass formatLikeNumber:model.nums];
    int type = model.type.intValue;
    switch (type) {
        case 1:
            self.lockTagView.hidden = NO;
            break;
        case 2:
        case 3:
            self.timeTagView.hidden = NO;
            break;
        default:
            self.normalTagView.hidden = NO;
            break;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
    self.titleLabel.text = @"";
    self.nameLabel.text = @"";
    self.fireCountLabel.text = @"";
    self.normalTagView.hidden = YES;
    self.lockTagView.hidden = YES;
    self.timeTagView.hidden = YES;
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
        make.height.equalTo(@(RatioBaseWidth390(48)));
    }];
    self.gradientView = gradientView;

    [self.fireCountLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.fireCountLabel];
    [self.fireCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-5);
        make.bottom.equalTo(self.contentView).offset(-6);
        make.height.equalTo(@13);
    }];

    UIImageView *fireIcon = [[UIImageView alloc] init];
    fireIcon.image = [ImageBundle imagewithBundleName:@"HomeFireIcon"];
    [self.contentView addSubview:fireIcon];
    [fireIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fireCountLabel.mas_left).offset(-2);
        make.centerY.equalTo(self.fireCountLabel).offset(-1);
        make.width.equalTo(@8);
        make.height.equalTo(@10);
    }];

    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(6);
        make.centerY.equalTo(self.fireCountLabel);
        make.right.equalTo(fireIcon.mas_left).offset(-4);
    }];

    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(6);
        make.height.equalTo(@17);
        make.bottom.equalTo(fireIcon.mas_top).offset(-2);
    }];

    [self.contentView addSubview:self.liveGifImg];
    [self.liveGifImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(7);
        make.left.equalTo(self.contentView).offset(8);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(18);
    }];

    [self.tagsStackView addArrangedSubview:self.normalTagView];
    [self.tagsStackView addArrangedSubview:self.lockTagView];
    [self.tagsStackView addArrangedSubview:self.timeTagView];
    [self.contentView addSubview:self.tagsStackView];
    [self.tagsStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.liveGifImg);
        make.left.equalTo(self.liveGifImg.mas_right).offset(8);
        make.height.equalTo(@14);
    }];
}

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

- (UILabel *)fireCountLabel {
    if (!_fireCountLabel) {
        _fireCountLabel = [[UILabel alloc] init];
        _fireCountLabel.textColor = [UIColor whiteColor];
        _fireCountLabel.font = [UIFont systemFontOfSize:9];
    }
    return _fireCountLabel;
}

- (UIStackView *)tagsStackView {
    if (!_tagsStackView) {
        _tagsStackView = [UIStackView new];
    }
    return _tagsStackView;
}

- (UIView *)normalTagView {
    if (!_normalTagView) {
        _normalTagView = [[UIView alloc] init];
        _normalTagView.layer.cornerRadius = 7;
        _normalTagView.layer.masksToBounds = YES;
        _normalTagView.backgroundColor = RGB_COLOR(@"#F251BB", 1);

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:8];
        label.textColor = [UIColor whiteColor];
        [_normalTagView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_normalTagView);
            make.bottom.equalTo(_normalTagView).offset(1);
            make.left.right.equalTo(_normalTagView).inset(4);
        }];

        _normalTagView.hidden = YES;
    }
    return _normalTagView;
}

- (UIView *)lockTagView {
    if (!_lockTagView) {
        _lockTagView = [[UIView alloc] init];
        _lockTagView.layer.cornerRadius = 7;
        _lockTagView.layer.masksToBounds = YES;
        _lockTagView.backgroundColor = RGB_COLOR(@"#4994EC", 1);

        UIImageView *lockImageView = [UIImageView new];
        lockImageView.image = [ImageBundle imagewithBundleName:@"ic_lockflag"];
        [_lockTagView addSubview:lockImageView];
        [lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@10);
            make.left.equalTo(_lockTagView).offset(4);
            make.centerY.equalTo(_lockTagView);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:8];
        label.textColor = [UIColor whiteColor];
        [_lockTagView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lockTagView);
            make.bottom.equalTo(_lockTagView).offset(1);
            make.right.equalTo(_lockTagView).inset(4);
            make.left.equalTo(lockImageView.mas_right).offset(2);
        }];

        _lockTagView.hidden = YES;
    }
    return _lockTagView;
}

- (UIView *)timeTagView {
    if (!_timeTagView) {
        _timeTagView = [[UIView alloc] init];
        _timeTagView.layer.cornerRadius = 7;
        _timeTagView.layer.masksToBounds = YES;
        _timeTagView.backgroundColor = RGB_COLOR(@"#B07FF2", 1);

        UIImageView *timeImageView = [UIImageView new];
        timeImageView.image = [ImageBundle imagewithBundleName:@"ic_liveroomtype_type"];
        [_timeTagView addSubview:timeImageView];
        [timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@10);
            make.left.equalTo(_timeTagView).offset(4);
            make.centerY.equalTo(_timeTagView);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:8];
        label.textColor = [UIColor whiteColor];
        [_timeTagView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_timeTagView);
            make.bottom.equalTo(_timeTagView).offset(1);
            make.right.equalTo(_timeTagView).inset(4);
            make.left.equalTo(timeImageView.mas_right).offset(2);
        }];

        _timeTagView.hidden = YES;
    }
    return _timeTagView;
}

- (YYAnimatedImageView *)liveGifImg {
    if (!_liveGifImg) {
        NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
        _liveGifImg = [[YYAnimatedImageView alloc]init];
        LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
        [imgAnima setAnimatedImageLoopCount:0];
        _liveGifImg.image = imgAnima;
        _liveGifImg.runloopMode = NSRunLoopCommonModes;
        _liveGifImg.animationRepeatCount = 0;
        [_liveGifImg startAnimating];
    }
    return _liveGifImg;
}

@end
