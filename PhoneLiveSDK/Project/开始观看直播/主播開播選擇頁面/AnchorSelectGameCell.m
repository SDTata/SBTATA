//
//  AnchorSelectGameCell.m
//  phonelive2
//
//  Created by vick on 2025/7/23.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorSelectGameCell.h"

@implementation AnchorSelectGameCell

+ (NSInteger)itemCount {
    return 6;
}

+ (CGFloat)itemHeight {
    return VKPX(60);
}

+ (CGFloat)itemWidth {
    return VKPX(50);
}

+ (CGFloat)itemLineSpacing {
    return 3;
}

- (void)updateView {
    UIImageView *gameImgView = [UIImageView new];
    gameImgView.contentMode = UIViewContentModeScaleAspectFill;
    [gameImgView vk_border:vkColorHex(0xFF63AC) cornerRadius:VKPX(18)];
    [self.contentView addSubview:gameImgView];
    self.gameImgView = gameImgView;
    [gameImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(VKPX(36));
    }];
    
    UILabel *gameNameLabel = [UIView vk_label:nil font:vkFont(10) color:UIColor.whiteColor];
    gameNameLabel.textAlignment = NSTextAlignmentCenter;
    gameNameLabel.adjustsFontSizeToFitWidth = YES;
    gameNameLabel.minimumScaleFactor = 0.1;
    [self.contentView addSubview:gameNameLabel];
    self.gameNameLabel = gameNameLabel;
    [gameNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(gameImgView.mas_bottom).offset(2);
    }];
}

- (void)updateData {
    VKActionModel *model = self.itemModel;
    [self.gameImgView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.gameNameLabel.text = model.title;
    if (model.selected) {
        self.gameImgView.layer.borderWidth = 1.0;
        self.gameNameLabel.textColor = vkColorHex(0xFF63AC);
    } else {
        self.gameImgView.layer.borderWidth = 0.0;
        self.gameNameLabel.textColor = vkColorHex(0xFFFFFF);
    }
}

@end
