//
//  TaskContentCell.h
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWProgressView.h"
#import "TaskModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^TaskActionBlock)(NSInteger taskID);

@interface TaskContentCell : UITableViewCell
@property(nonatomic,strong)TaskModel *model;

@property(nonatomic,copy)TaskActionBlock taskCallback;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *rewardLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet HWProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *chargeLabel;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

NS_ASSUME_NONNULL_END
