//
//  BonusRulesTableViewCell.h
//  phonelive2
//
//  Created by user on 2024/8/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@interface BonusRulesSectionCell : VKBaseTableSectionView
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@interface BonusRulesTableViewCell : VKBaseTableViewCell
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
