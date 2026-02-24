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
#import "LiveTaskModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^TaskActionBlock)(NSInteger taskID);

@interface LiveTaskContentCell : UITableViewCell
@property(nonatomic,strong)LiveTaskModel *model;

@property(nonatomic,copy)TaskActionBlock taskCallback;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *downButton;

@end

NS_ASSUME_NONNULL_END
