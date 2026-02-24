//
//  YBUserInfoContentCell.h
//  phonelive2
//
//  Created by user on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBUserInfoContentCell : UICollectionViewCell
@property (nonatomic, strong) SDAnimatedImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
- (void)setupData:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
