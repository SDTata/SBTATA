//
//  LongVideoCell.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoCell.h"

@implementation LongVideoCell

+(CGFloat)ratio {
    return 146 / 180.0;
}

+(CGFloat)minimumLineSpacing {
    return 10.0;
}

+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemSpacing {
    return 0;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return VKPX(180);
}

- (void)updateView {
    [super updateView];
    [self.contentView vk_border:nil cornerRadius:10];
    self.contentView.backgroundColor = UIColor.whiteColor;
    self.videoDetailLabel.hidden = YES;
    
    [self.videoImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-VKPX(30));
    }];
    
    [self.videoTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(self.videoImgView.mas_bottom).offset(5);
    }];
    
    [self.videoDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(self.playCountButton.mas_left).offset(-5);
        make.top.mas_equalTo(self.videoTitleLabel.mas_bottom).offset(5);
    }];
    
    [self.tagStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
    }];
    
    [self.playCountButton setImage:[ImageBundle imagewithBundleName:@"video_play_count"] forState:UIControlStateNormal];
    [self.playCountButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.playCountButton.backgroundColor = UIColor.clearColor;
    self.playCountButton.tintColor = UIColor.whiteColor;
    self.playCountButton.layer.backgroundColor = vkColorHexA(0x000000, 0.3).CGColor;
    self.playCountButton.layer.cornerRadius = 5;
    [self.playCountButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.videoImgView.mas_left).offset(8);
        make.bottom.mas_equalTo(self.videoImgView.mas_bottom).offset(-4);
        make.height.mas_equalTo(16);
    }];
    
    [self.playTimeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.videoImgView.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.videoImgView.mas_bottom).offset(-4);
        make.height.mas_equalTo(16);
    }];
}

@end


@implementation LongVideoTwoCell

+ (NSInteger)itemCount {
    return 2;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return VKPX(130);
}

@end


@implementation LongVideoSearchResultCell

- (void)updateView {
    [super updateView];
    self.videoTitleLabel.font = vkFont(12);
    self.videoDetailLabel.font = vkFont(11);
}

@end
