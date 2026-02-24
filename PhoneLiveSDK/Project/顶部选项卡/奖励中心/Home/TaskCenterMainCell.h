//
//  TaskCenterMainCell.h
//  phonelive2
//
//  Created by vick on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardHomeModel.h"
#import "ZJJTimeCountDown.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskCenterMainCell : VKBaseTableViewCell

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) SDAnimatedImageView *iconImgView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) ZJJTimeCountDownLabel *timeLabel;

@property (nonatomic, strong) RewardHomeModel *rewardModel;

@end

NS_ASSUME_NONNULL_END
