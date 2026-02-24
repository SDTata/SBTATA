//
//  SkitAllEpisodesGroupCell.m
//  phonelive2
//
//  Created by s5346 on 2025/3/16.
//  Copyright © 2025 toby. All rights reserved.
//

#import "SkitAllEpisodesGroupCell.h"

@interface SkitAllEpisodesGroupCell ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation SkitAllEpisodesGroupCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(NSString*)title {
    self.titleLabel.text = title;
}

#pragma mark - UI
- (void)setupViews {
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (selected) {
        self.containerView.backgroundColor = RGB_COLOR(@"#FF63AC", 0.15);
        self.titleLabel.textColor = RGB_COLOR(@"#FF63AC", 1.0);
    } else {
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = RGB_COLOR(@"#919191", 1);
    }
}

#pragma mark - Lazy
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.layer.cornerRadius = 15;
        _containerView.layer.masksToBounds = YES;
        _containerView.backgroundColor = [UIColor whiteColor];

        [_containerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.greaterThanOrEqualTo(_containerView).inset(8);
            make.left.right.equalTo(_containerView).inset(14);
        }];
    }
    return _containerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:500];
        _titleLabel.textColor = RGB_COLOR(@"#919191", 1);
    }
    return _titleLabel;
}

@end
