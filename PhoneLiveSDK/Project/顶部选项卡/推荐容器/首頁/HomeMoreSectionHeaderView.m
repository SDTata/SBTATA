//
//  HomeMoreSectionHeaderView.m
//  NewDrama
//
//  Created by s5346 on 2024/6/26.
//

#import "HomeMoreSectionHeaderView.h"

@interface HomeMoreSectionHeaderView()

@property(nonatomic, strong) SDAnimatedImageView *iconImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *moreView;
@property (nonatomic, copy) void (^buttonActionBlock)(void);

@end

@implementation HomeMoreSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)updateForIcon:(NSString*)icon title:(NSString*)title placeholder:(NSString *)placeholder block:(void (^)(void))buttonActionBlock {
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:minstr(icon)] placeholderImage:[ImageBundle imagewithBundleName:placeholder]];
    self.titleLabel.text = title;
    self.buttonActionBlock = buttonActionBlock;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.iconImageView.image = nil;
    self.titleLabel.text = @"";
    self.buttonActionBlock = nil;
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.iconImageView, self.titleLabel, self.moreView]];
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = 6;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(14);
        make.top.bottom.equalTo(self);
    }];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@16);
    }];
}

- (SDAnimatedImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SDAnimatedImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = RGB_COLOR(@"#1A1A1A", 1);
    }
    return _titleLabel;
}

- (UIView *)moreView {
    if (!_moreView) {
        _moreView = [[UIView alloc] init];
//        _moreView.backgroundColor = RGB_COLOR(@"#F6F0FE", 1);
        _moreView.backgroundColor = UIColor.clearColor;
        _moreView.layer.cornerRadius = 11;
        _moreView.layer.masksToBounds = YES;
        [_moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@22);
        }];

        UIImageView *arrowImageView = [[UIImageView alloc] init];
        arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        arrowImageView.image = [[ImageBundle imagewithBundleName:@"HotHeaderRightArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        arrowImageView.tintColor = RGB_COLOR(@"#d6a9ff", 1);
        [_moreView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_moreView).offset(-9);
            make.centerY.equalTo(_moreView);
            make.size.equalTo(@12);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        titleLabel.text = YZMsg(@"More_title");
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = RGB_COLOR(@"#d6a9ff", 1);
        [_moreView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_moreView).offset(15);
            make.top.bottom.equalTo(_moreView);
            make.right.equalTo(arrowImageView.mas_left);
        }];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMore)];
        [_moreView addGestureRecognizer:tap];
    }
    return _moreView;
}

#pragma mark - Action
- (void)tapMore {
    if (self.buttonActionBlock) {
        self.buttonActionBlock();
    }
}
@end
