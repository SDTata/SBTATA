//
//  MyCreateListCell.h
//  phonelive2
//
//  Created by vick on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCreateListCell : VideoBaseCell

@property (nonatomic, strong) UIButton *tickButton;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) UIImageView *eyeImgView;

@end

NS_ASSUME_NONNULL_END
