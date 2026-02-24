//
//  HomeSectionKindCarouselContentViewCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSectionKindCarouselContentViewCell.h"

@interface HomeSectionKindCarouselContentViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *adImageView;

@end

@implementation HomeSectionKindCarouselContentViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(HomeRecommendAds*)model {
    [self.adImageView sd_setImageWithURL:[NSURL URLWithString:model.image]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.adImageView sd_cancelCurrentImageLoad];
    self.adImageView.image = nil;
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;

    [self.contentView addSubview:self.adImageView];
    [self.adImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (SDAnimatedImageView *)adImageView {
    if (!_adImageView) {
        _adImageView = [[SDAnimatedImageView alloc] init];
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        _adImageView.clipsToBounds = YES;
    }
    return _adImageView;
}

@end
