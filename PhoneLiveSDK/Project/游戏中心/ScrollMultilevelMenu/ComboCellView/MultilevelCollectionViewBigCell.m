//
//  MultilevelCollectionViewBigCell.m
//  c700LIVE
//
//  Created by lucas on 2022/10/14.
//  Copyright © 2022 toby. All rights reserved.
//

#import "MultilevelCollectionViewBigCell.h"

@implementation MultilevelCollectionViewBigCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = UIColor.clearColor;
    self.imageView.layer.cornerRadius = 12;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *backMaskView = [UIView new];
    backMaskView.layer.cornerRadius = 12;
    backMaskView.backgroundColor = UIColor.whiteColor;
    backMaskView.layer.shadowOpacity = 0.3;
    backMaskView.layer.shadowColor = RGB_COLOR(@"#664CCB", 1).CGColor;
    backMaskView.layer.shadowOffset = CGSizeMake(0, 2);
    [self.contentView addSubview:backMaskView];
    [self.contentView sendSubviewToBack:backMaskView];
    [backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageView);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.verticalColors = @[vkColorRGB(225, 208, 253), vkColorRGB(235, 221, 255)];
}

@end
