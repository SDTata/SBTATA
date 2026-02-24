//
//  BTagCollectionViewCell.m
//  phonelive2
//
//  Created by user on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BTagCollectionViewCell.h"

@implementation BTagCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 10;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.borderColor = vkColorHex(0xE5E5E5).CGColor;
        self.contentView.layer.borderWidth = 1;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.tagLabel];
        [self.contentView addSubview:self.moreIcon];
    }
    return self;
}

- (void)setupData:(NSString *)text {
    if ([text isEqualToString:@"_<_"] || [text isEqualToString:@"_>_"]) {
        self.moreIcon.image = [text isEqualToString:@"_<_"] ? [ImageBundle imagewithBundleName:@"home_search_more_down"] : [ImageBundle imagewithBundleName:@"home_search_more_up"];
        [self.moreIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(10);
            make.center.mas_equalTo(self.contentView);
        }];
        [self.moreIcon setHidden: NO];
        [self.tagLabel setHidden: YES];
    } else {
        [self.moreIcon setHidden: YES];
        [self.tagLabel setHidden: NO];
        self.tagLabel.text = text;
        [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
}

+ (CGSize)getItemSizeWothText:(NSString *)text {
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 25) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    return CGSizeMake(MIN(rect.size.width + 10, SCREEN_WIDTH - 50), rect.size.height + 10);
}

//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    CGRect rect = [self.tagLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 25) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
//    rect.size.width +=10;
//    rect.size.height+=10;
//    attributes.frame = rect;
//    return attributes;
//
//}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.textColor = vkColorHex(0x4D4D4D);
        _tagLabel.font = [UIFont systemFontOfSize:14];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

- (UIImageView *)moreIcon {
    if (!_moreIcon) {
        _moreIcon = [UIImageView new];
        _moreIcon.image = [ImageBundle imagewithBundleName:@"home_search_more_down"];
        _moreIcon.contentMode = UIViewContentModeScaleAspectFit;
        [_moreIcon setHidden:YES];
    }
    return _moreIcon;
}
@end
