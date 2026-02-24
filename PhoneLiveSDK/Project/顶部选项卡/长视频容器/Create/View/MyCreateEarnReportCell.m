//
//  MyCreateEarnReportCell.m
//  phonelive2
//
//  Created by vick on 2024/7/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateEarnReportCell.h"
#import "MyEarnReportModel.h"

@implementation MyCreateEarnReportCell

+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return 92;
}

- (void)updateView {
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.contentView vk_border:nil cornerRadius:10];
    
    UILabel *firstLabel = [UILabel new];
    [self.contentView addSubview:firstLabel];
    
    UILabel *timeLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UILabel *amountLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:amountLabel];
    self.amountLabel = amountLabel;
    
    NSArray *views = @[firstLabel, timeLabel, amountLabel];
    [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:1.0 leadSpacing:0 tailSpacing:0];
    [views mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView *videoImgView = [UIImageView new];
    [videoImgView vk_border:nil cornerRadius:10];
    videoImgView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    videoImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:videoImgView];
    self.videoImgView = videoImgView;
    [videoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(firstLabel.mas_centerX);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(88);
    }];
}

- (void)updateData {
    ShortVideoModel *model = self.itemModel;
    [self.videoImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
    self.timeLabel.text = [model.consume_time stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    self.amountLabel.text = [YBToolClass getRateCurrency:model.consume_amount showUnit:YES];
}

@end
