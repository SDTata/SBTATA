//
//  LotteryHallBaseCell.m
//  phonelive2
//
//  Created by vick on 2024/1/16.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHallBaseCell.h"

@implementation LotteryHallBaseCell

- (instancetype)initWithKey:(NSString *)key superKey:(NSString *)superKey
{
    self = [super init];
    if (self) {
        self.key = key;
        self.superKey = superKey;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    UIButton *backImgView = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImage = [ImageBundle imagewithBundleName:@"bjl_betbg"];
    [backImgView setBackgroundImage:normalImage forState:UIControlStateNormal];
    UIImage *selectImage = [[ImageBundle imagewithBundleName:@"win_bolder_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    [backImgView setBackgroundImage:selectImage forState:UIControlStateSelected];
    backImgView.userInteractionEnabled = NO;
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontBold(15) color:vkColorHex(0xFFFFFF)];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-10);
    }];
    
    UILabel *valueLabel = [UIView vk_label:nil font:vkFontMedium(11) color:vkColorHex(0xFFFFFF)];
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(5);
    }];
}

- (void)setOptionModel:(LotteryOptionModel *)optionModel {
    _optionModel = optionModel;
    self.titleLabel.text = optionModel.st;
    self.valueLabel.text = [NSString stringWithFormat:@"x%@", optionModel.value];
}

/// 开始闪烁动画
- (void)showWinAnimation {
    self.backImgView.selected = !self.backImgView.selected;
    self.titleLabel.textColor = self.backImgView.selected ? UIColor.blackColor : UIColor.whiteColor;
    self.valueLabel.textColor = self.backImgView.selected ? UIColor.blackColor : UIColor.whiteColor;
    [self performSelector:@selector(showWinAnimation) withObject:nil  afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
}

/// 停止动画
- (void)hideWinAnimation {
    self.backImgView.selected = NO;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.valueLabel.textColor = UIColor.whiteColor;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
