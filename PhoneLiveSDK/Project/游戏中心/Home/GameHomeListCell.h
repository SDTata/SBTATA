//
//  GameHomeListCell.h
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameHomeListCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@interface GameHomeListFourCell : GameHomeListCell

@end


@interface GameHomeListTwoCell : GameHomeListCell

@end


@interface GameHomeListOneCell : GameHomeListCell

@end
