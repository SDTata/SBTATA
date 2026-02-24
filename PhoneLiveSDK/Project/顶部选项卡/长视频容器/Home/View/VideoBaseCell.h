//
//  VideoBaseCell.h
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

@interface VideoBaseCell : VKBaseCollectionViewCell

@property (nonatomic, strong) SDAnimatedImageView *videoImgView;
@property (nonatomic, strong) UILabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *videoDetailLabel;

@property (nonatomic, strong) UIButton *playCountButton;
@property (nonatomic, strong) UIButton *playTimeButton;

@property (nonatomic, strong) UIStackView *tagStackView;
@property (nonatomic, strong) UIButton *vipTagButton;
@property (nonatomic, strong) UIButton *payTagButton;

@property (nonatomic, strong) ShortVideoModel *videoModel;

@end
