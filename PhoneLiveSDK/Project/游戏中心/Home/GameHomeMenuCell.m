//
//  GameHomeMenuCell.m
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeMenuCell.h"
#import "GameHomeModel.h"

@implementation GameHomeMenuCell

+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return 44;
}

- (void)updateView {
    UIImageView *backImgView = [UIImageView new];
    backImgView.layer.cornerRadius = 12;
    backImgView.backgroundColor = UIColor.whiteColor;
    backImgView.layer.shadowOpacity = 0.3;
    backImgView.layer.shadowColor = RGB_COLOR(@"#664CCB", 1).CGColor;
    backImgView.layer.shadowOffset = CGSizeMake(0, 2);
    [self.contentView addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.spacing = 5;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    [backImgView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-2);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *imgView = [UIImageView new];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [stackView addArrangedSubview:imgView];
    self.imgView = imgView;
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(30);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.1;
    [stackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)updateData {
    GameHomeModel *model = self.itemModel;
    self.titleLabel.text = model.meunName;
    self.titleLabel.hidden = !model.show_name;
    
    if (model.selected) {
        [self.imgView vk_setImageUrl:model.meunIconSelected defalutImage:[ImageBundle imagewithBundleName:@"itemGamesLeftActiveCopy2"]];
        self.backImgView.backgroundColor = vkColorHex(0x7341ff);
        self.titleLabel.textColor = UIColor.whiteColor;
    } else {
        [self.imgView vk_setImageUrl:model.meunIcon defalutImage:SmallIconPlaceHoldImage];
        self.backImgView.backgroundColor = UIColor.whiteColor;
        self.titleLabel.textColor = vkColorHex(0x97a4b0);
    }
}

@end


@implementation GameHomeSectionCell

+ (CGFloat)itemHeight {
    return 36;
}

- (void)updateView {
    UIImageView *leftImgView = [UIImageView new];
    leftImgView.contentMode = UIViewContentModeScaleAspectFit;
    leftImgView.image = [ImageBundle imagewithBundleName:@"game_bt1"];
    [self addSubview:leftImgView];
    [leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(20);
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftImgView.mas_right).offset(5);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *rightImgView = [UIImageView new];
    rightImgView.contentMode = UIViewContentModeScaleAspectFit;
    rightImgView.image = [ImageBundle imagewithBundleName:@"game_bt2"];
    [self addSubview:rightImgView];
    [rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(20);
        make.left.mas_equalTo(titleLabel.mas_right).offset(5);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)updateData {
    GameTypeModel *model = self.itemModel;
    self.titleLabel.text = model.meunName;
}

@end
