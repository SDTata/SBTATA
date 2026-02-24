//
//  GameHomeMenuCell.h
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameHomeMenuCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@interface GameHomeSectionCell : VKBaseCollectionSectionView

@property (nonatomic, strong) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
