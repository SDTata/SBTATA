//
//  WinningRecordTableViewCell.h
//  phonelive2
//
//  Created by user on 2024/8/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WinningRecordSectionCell : VKBaseTableSectionView
@property (nonatomic, strong) UILabel *titleLabel;
@end

@interface WinningRecordTableViewCell : VKBaseTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *rightTitleLabel;
@end

NS_ASSUME_NONNULL_END
