//
//  ScrollCardItemCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/8.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ScrollCardItemCell.h"
#import "HomeSectionKindSkitContentViewCell.h"

@interface ScrollCardItemCell ()

@property(nonatomic, strong) HomeSectionKindSkitContentViewCell *infoCell;

@end

@implementation ScrollCardItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(HomeRecommendSkit*)model {
    [self.infoCell update:model];
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor clearColor];

    CGFloat radius = RatioBaseWidth390(16);
    UIView *containerView = [[UIView alloc] init];
    containerView.userInteractionEnabled = NO;
    containerView.backgroundColor = [UIColor clearColor];
    containerView.layer.shadowOffset = CGSizeMake(0, 3);
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOpacity = 0.4;
    containerView.layer.shadowRadius = 3;

    [self.contentView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(radius);
        make.height.mas_equalTo(self.contentView.height - (radius * 2));
    }];

    self.infoCell.layer.cornerRadius = 16;
    self.infoCell.layer.masksToBounds = YES;
    [containerView addSubview:self.infoCell];
    [self.infoCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
}

- (HomeSectionKindSkitContentViewCell *)infoCell {
    if (!_infoCell) {
        _infoCell = [[HomeSectionKindSkitContentViewCell alloc] init];
    }
    return _infoCell;
}

@end
