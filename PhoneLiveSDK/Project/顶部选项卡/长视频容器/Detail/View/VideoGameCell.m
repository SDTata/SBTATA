//
//  VideoGameCell.m
//  phonelive2
//
//  Created by vick on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoGameCell.h"
#import "HomeRecommendGameModel.h"

@implementation VideoGameCell

+ (NSInteger)itemCount {
    return 3;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)autoHeightForItem:(HomeRecommendGame *)itemModel {
    CGFloat width = (VK_SCREEN_W - 40) / 3;
    CGFloat height = itemModel.imageScale > 0 ? width * itemModel.imageScale : VKPX(120);
    return height + 25;
}

- (void)updateView {
    [super updateView];
    self.imgView.hidden = YES;
    
    self.backImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.backImgView.layer.masksToBounds = YES;
    self.backImgView.layer.cornerRadius = 12;
    [self.backImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.backImgView.mas_bottom);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(25);
    }];
}

- (void)updateData {
    HomeRecommendGame *model = self.itemModel;
    self.titleLabel.text = model.name;
    
    WeakSelf
    [self.backImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[ImageBundle imagewithBundleName:@"game_center_small_placeholder"] options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (image != nil && model.imageScale <= 0){
            model.imageScale = image.size.height / image.size.width;
            [strongSelf reload];
        }
    }];
}

@end
