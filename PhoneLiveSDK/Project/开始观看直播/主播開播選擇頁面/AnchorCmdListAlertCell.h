//
//  AnchorCmdListAlertCell.h
//  phonelive2
//
//  Created by vick on 2025/7/25.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnchorCmdIconView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnchorCmdListAlertCell : VKBaseCollectionViewCell

@property (nonatomic, strong) AnchorCmdIconView *iconImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIImageView *tickImgView;
@property (nonatomic, strong) UIImageView *editImgView;

@end

NS_ASSUME_NONNULL_END
