//
//  VideoTicketCardView.m
//  phonelive2
//
//  Created by vick on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoTicketCardView.h"

@interface VideoTicketCardView ()

@end

@implementation VideoTicketCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIImageView *backImgView = [UIImageView new];
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"movie_ticket_name") font:vkFontBold(16) color:UIColor.whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backImgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-VKPX(50));
        make.bottom.mas_equalTo(backImgView.mas_centerY);
    }];
    
    UILabel *detailLabel = [UIView vk_label:nil font:vkFont(12) color:UIColor.whiteColor];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    [detailLabel vk_border:nil cornerRadius:8];
    [backImgView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(titleLabel.mas_centerX);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(VKPX(80));
    }];
    
    UILabel *priceLabel = [UIView vk_label:nil font:vkFont(18) color:UIColor.blackColor];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.adjustsFontSizeToFitWidth = YES;
    priceLabel.minimumScaleFactor = 0.1;
    [backImgView addSubview:priceLabel];
    self.priceLabel = priceLabel;
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(VKPX(60));
    }];
}

@end
