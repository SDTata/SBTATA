//
//  HomeSectionKindLotteryContentViewCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "HomeSectionKindLotteryContentViewCell.h"

@interface HomeSectionKindLotteryContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *iconImageView;
@property(nonatomic, strong) UIView *onlineView;
@property(nonatomic, strong) UILabel *onlineLabel;

@end

@implementation HomeSectionKindLotteryContentViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

+(CGFloat)ratio {
    return 78 / 78.0;
}

+(CGFloat)minimumLineSpacing {
    return 10.0;
}

- (void)update:(HomeRecommendLotteries*)model {
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:GamePlaceholdImage];
    self.onlineLabel.text = [NSString stringWithFormat:YZMsg(@"%@ people online"), [YBToolClass formatLikeNumber:model.people_count]];
}

#pragma mark - UI
- (void)setupViews {
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];

    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    self.onlineView.layer.cornerRadius = 15 / 2.0;
    self.onlineView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.onlineView];
    [self.onlineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.greaterThanOrEqualTo(@70);
//        make.width.lessThanOrEqualTo(self.contentView).multipliedBy(0.9);
        make.top.right.equalTo(self.contentView).inset(4);
        make.height.equalTo(@15);
      
    }];
}

#pragma mark - Lazy
- (SDAnimatedImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SDAnimatedImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_iconImageView setImage:GamePlaceholdImage];
        _iconImageView.clipsToBounds = YES;
    }
    return _iconImageView;
}

- (UIView *)onlineView {
    if (!_onlineView) {
        _onlineView = [UIView new];
        _onlineView.backgroundColor = RGB_COLOR(@"#ffffff", 0.6);
        _onlineView.layer.borderWidth = 0.5;
        _onlineView.layer.borderColor = [UIColor whiteColor].CGColor;

        [_onlineView addSubview:self.onlineLabel];
        [self.onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_onlineView).inset(3);
            make.centerY.equalTo(_onlineView);
        }];
    }
    return _onlineView;
}

- (UILabel *)onlineLabel {
    if (!_onlineLabel) {
        _onlineLabel = [UILabel new];
        _onlineLabel.font = [UIFont systemFontOfSize:8];
        _onlineLabel.textAlignment = NSTextAlignmentCenter;
        _onlineLabel.textColor = RGB_COLOR(@"#000000", 0.7);
    }
    return _onlineLabel;
}
@end
