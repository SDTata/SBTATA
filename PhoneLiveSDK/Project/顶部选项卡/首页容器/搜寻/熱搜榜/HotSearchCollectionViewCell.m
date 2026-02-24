//
//  HotSearchCollectionViewCell.m
//  phonelive2
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HotSearchCollectionViewCell.h"

@implementation HotSearchCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.rankingLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.hotIcon];
        [self.contentView addSubview:self.popularityLabel];
        
        [self.rankingLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.rankingLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.titleLabel setContentCompressionResistancePriority: UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.popularityLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.popularityLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.rankingLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.centerY.mas_equalTo(self.contentView);
            make.height.mas_equalTo(18);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.rankingLabel);
            make.leading.mas_equalTo(self.rankingLabel.mas_trailing).offset(10);
        }];
        
        [self.hotIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(4);
            make.trailing.mas_lessThanOrEqualTo(self.popularityLabel.mas_leading).offset(10);
            make.size.mas_equalTo(14);
        }];
        
        [self.popularityLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.trailing.mas_equalTo(self.contentView).inset(10);
        }];
    }
    return self;
}

- (void)setupData:(NSDictionary *)data {
    NSString *ranking = data[@"ranking"];
    self.rankingLabel.text = ranking;
    NSArray *top3 = @[@"1",@"2",@"3"];
    if ([top3 containsObject:ranking]) {
        self.rankingLabel.textColor = vkColorHex(0xF251BB);
        [self.hotIcon setHidden:NO];
        if (data[@"icon"] && ((NSString *)data[@"icon"]).length > 0) {
            [self.hotIcon sd_setImageWithURL:[NSURL URLWithString:data[@"icon"]]];
        }
    }
    self.titleLabel.text = [NSString stringWithFormat:@"%@", data[@"key"]];
    NSNumber *number = data[@"value"];
    self.popularityLabel.text = [YBToolClass formatLikeNumber:[number stringValue]];
}

- (UILabel *)rankingLabel {
    if (!_rankingLabel) {
        _rankingLabel = [UILabel new];
        _rankingLabel.textColor = vkColorHex(0x4D4D4D);
        _rankingLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        _rankingLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rankingLabel;
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

- (UILabel *)popularityLabel {
    if (!_popularityLabel) {
        _popularityLabel = [UILabel new];
        _popularityLabel.textColor = vkColorHex(0x8C8C8C);
        _popularityLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _popularityLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _popularityLabel;
}

- (UIImageView *)hotIcon {
    if (!_hotIcon) {
        _hotIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _hotIcon.contentMode = UIViewContentModeScaleAspectFit;
        _hotIcon.image = [ImageBundle imagewithBundleName:@"HomeLongVideoFireIcon"];
        [_hotIcon setHidden:YES];
    }
    return _hotIcon;
}
@end
