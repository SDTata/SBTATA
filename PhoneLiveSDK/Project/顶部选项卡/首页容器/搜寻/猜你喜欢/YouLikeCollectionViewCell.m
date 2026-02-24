//
//  YouLikeCollectionViewCell.m
//  phonelive2
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YouLikeCollectionViewCell.h"

@implementation YouLikeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)setupData:(NSString *)text {
    self.titleLabel.text = text;
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = vkColorHex(0x4D4D4D);
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

@end
