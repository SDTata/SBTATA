//
//  GameHomeListCell.m
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeListCell.h"
#import "GameHomeModel.h"

@implementation GameHomeListCell

+ (NSInteger)itemCount {
    return 3;
}

+ (CGFloat)itemSpacing {
    return 0;
}

+ (CGFloat)itemLineSpacing {
    return 0;
}

+ (CGFloat)itemHeight {
    return VKPX(110);
}

- (void)updateView {
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"itemGamesImgCopy2"];
    [self.contentView addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(backImgView.mas_width);
    }];
    
    UIImageView *imgView = [UIImageView new];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.layer.cornerRadius = 12;
    imgView.layer.masksToBounds = YES;
    [self.contentView addSubview:imgView];
    self.imgView = imgView;
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(backImgView.mas_width).multipliedBy(0.89);
        make.height.mas_equalTo(imgView.mas_width);
        make.centerX.mas_equalTo(backImgView.mas_centerX).offset(-1);
        make.centerY.mas_equalTo(backImgView.mas_centerY).offset(-2);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(12) color:UIColor.blackColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(backImgView.mas_bottom);
    }];
}

- (void)updateData {
    GameListModel *model = self.itemModel;
    self.titleLabel.text = model.meunName;
    [self.imgView vk_setGridGameUrl:model.urlName];
    self.titleLabel.hidden = !model.show_name;
}

@end


@implementation GameHomeListFourCell

+ (NSInteger)itemCount {
    return 4;
}

+ (CGFloat)itemHeight {
    return VKPX(110);
}

@end


@implementation GameHomeListTwoCell

+ (NSInteger)itemCount {
    return 2;
}

+ (CGFloat)itemHeight {
    return VKPX(150);
}

- (void)updateView {
    [super updateView];
    self.backImgView.hidden = YES;
}

@end


@implementation GameHomeListOneCell

+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemSpacing {
    return 0;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)autoHeightForItem:(GameListModel *)itemModel {
    CGFloat width = VK_SCREEN_W - 108 - 15;
    CGFloat height = itemModel.imageScale > 0 ? width * itemModel.imageScale : VKPX(100);
    return itemModel.show_name ? height + 25 : height;
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
}

- (void)updateData {
    [super updateData];
    GameListModel *model = self.itemModel;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.backImgView.mas_bottom);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(model.show_name ? 25 : 0);
    }];
    
    WeakSelf
    [self.backImgView sd_setImageWithURL:[NSURL URLWithString:model.urlName] placeholderImage:[ImageBundle imagewithBundleName:@"game_center_big_placeholder"] options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
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
