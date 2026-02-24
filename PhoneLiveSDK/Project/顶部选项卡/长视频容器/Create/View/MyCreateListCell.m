//
//  MyCreateListCell.m
//  phonelive2
//
//  Created by vick on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateListCell.h"

@implementation MyCreateListCell

+ (NSInteger)itemCount {
    return 3;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return VKPX(140);
}

- (void)updateView {
    [self.contentView vk_border:nil cornerRadius:10];
    
    [self.contentView addSubview:self.videoImgView];
    [self.videoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.contentView addSubview:self.tagStackView];
    [self.tagStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];
    
    UIButton *tickButton = [UIView vk_buttonImage:@"create_tick_n" selected:@"create_tick_s"];
    [tickButton vk_addTapAction:self selector:@selector(clickTickAction)];
    [self.contentView addSubview:tickButton];
    self.tickButton = tickButton;
    [tickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(5);
        make.width.height.mas_equalTo(16);
    }];
    
    UIView *bottomMaskView = [UIView new];
    [self.contentView addSubview:bottomMaskView];
    self.bottomMaskView = bottomMaskView;
    [bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
//    [self.playCountButton setImage:[ImageBundle imagewithBundleName:@"create_menu_play"] forState:UIControlStateNormal];
    self.playCountButton.backgroundColor = UIColor.clearColor;
    [bottomMaskView addSubview:self.playCountButton];
    [self.playCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
    
    UIImageView *eyeImgView = [UIImageView new];
    eyeImgView.image = [ImageBundle imagewithBundleName:@"create_tag_eye"];
    eyeImgView.contentMode = UIViewContentModeScaleAspectFit;
    [bottomMaskView addSubview:eyeImgView];
    self.eyeImgView = eyeImgView;
    [eyeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-0);
        make.centerY.mas_equalTo(self.playCountButton);
        make.height.mas_equalTo(12);
    }];
    
    self.videoTitleLabel.textColor = UIColor.whiteColor;
    self.videoTitleLabel.font = vkFont(12);
    [bottomMaskView addSubview:self.videoTitleLabel];
    [self.videoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.bottom.mas_equalTo(self.playCountButton.mas_top).offset(-2);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bottomMaskView.verticalColors = @[vkColorHexA(0x000000, 0.0), vkColorHexA(0x000000, 0.2)];
}

- (void)updateData {
    [super updateData];
    
    self.tickButton.hidden = ![self.extraData boolValue];
    self.tickButton.selected = self.videoModel.isSelected;
    self.eyeImgView.hidden = !self.videoModel.user_hide_status;

    // 我的創作 例外處理
    [self.payTagButton setTitle:YZMsg(@"movie_pay") forState:UIControlStateNormal];
}

- (void)clickTickAction {
    if (self.clickCellActionBlock) {
        self.clickCellActionBlock(self.indexPath, self.itemModel, 0);
    }
}

@end
