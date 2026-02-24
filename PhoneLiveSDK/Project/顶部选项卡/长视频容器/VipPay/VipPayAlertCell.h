//
//  VipPayAlertCell.h
//  phonelive2
//
//  Created by vick on 2025/2/10.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VipPayAlertCell : VKBaseCollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *unitLabel;
@property (nonatomic, strong) UILabel *amountLabel;

@end

NS_ASSUME_NONNULL_END
