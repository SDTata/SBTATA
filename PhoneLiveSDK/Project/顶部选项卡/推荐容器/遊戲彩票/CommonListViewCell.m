//
//  CommonListViewCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "CommonListViewCell.h"

@interface CommonListViewCell ()

@property(nonatomic, strong) SDAnimatedImageView *bgImageView;

@end

@implementation CommonListViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)update {
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
}

#pragma mark - Lazy
- (SDAnimatedImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[SDAnimatedImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;

    }
    return _bgImageView;
}

@end
