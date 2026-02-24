//
//  LotteryBetView.m
//  phonelive2
//
//  Created by vick on 2023/11/8.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetView.h"
#import "BetBubbleView.h"

@interface LotteryBetView ()

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) BetBubbleView *bubbleView;

@end

@implementation LotteryBetView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.selected = NO;
    }
    return self;
}

- (void)setupView {
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.tag = 300;
    backImgView.layer.borderWidth = 2.0;
    backImgView.layer.cornerRadius = 12;
    backImgView.layer.masksToBounds = YES;
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIView *bottomView = ({
        
        UIView *view = [UIView new];
        view.backgroundColor = vkColorHexA(0x000000, 0.3);
        
        UIImageView *goldImgView = [UIImageView new];
        goldImgView.image = [ImageBundle imagewithBundleName:@"JB"];
        [view addSubview:goldImgView];
        [goldImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(-1);
            make.right.mas_equalTo(view.mas_centerX);
            make.height.width.mas_equalTo(10);
        }];
        
        UILabel *goldLabel = [UIView vk_label:@"0" font:vkFont(10) color:vkColorHex(0xFFFFFF)];
        goldLabel.tag = 101;
        [view addSubview:goldLabel];
        [goldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(goldImgView.mas_right).offset(2);
            make.centerY.mas_equalTo(goldImgView.mas_centerY);
        }];
        
        view;
    });
    
    [backImgView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(14);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontMedium(15) color:vkColorHex(0x05542F)];
    titleLabel.tag = 200;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-12);
    }];
    
    UILabel *valueLabel = [UIView vk_label:nil font:vkFontMedium(11) color:vkColorHex(0x05542F)];
    valueLabel.tag = 201;
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(-2);
    }];
    
    BetBubbleView *bubbleView = [BetBubbleView new];
    bubbleView.tag = 1010;
    [self addSubview:bubbleView];
    self.bubbleView = bubbleView;
    [bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-10);
        make.top.mas_equalTo(-5);
    }];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.backImgView.layer.borderColor = selected ? vkColorRGB(253, 237, 94).CGColor : vkColorRGB(115, 215, 145).CGColor;
}

@end
