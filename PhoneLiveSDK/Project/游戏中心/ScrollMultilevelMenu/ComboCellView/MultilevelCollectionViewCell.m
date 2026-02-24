//
//  MultilevelCollectionViewCell.m
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import "MultilevelCollectionViewCell.h"
#import "MultilevelMenu.h"

@implementation MultilevelCollectionViewCell

+ (NSInteger)itemCount {
    return 4;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return VKPX(100);
}

- (void)updateData {
    rightMeun *meun = self.itemModel;
    self.titile.text = meun.meunName;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[ImageBundle imagewithBundleName:@"tempShop2"]];
}

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
