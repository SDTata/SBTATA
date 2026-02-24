//
//  LuckyDrawTableViewCell.h
//  phonelive2
//
//  Created by user on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LuckyDrawTableViewCell : VKBaseTableViewCell
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIView *rightnumberBgView;
@property (nonatomic, strong) UILabel *rightnumberLabel;
@end

NS_ASSUME_NONNULL_END
