//
//  TaskTableVC.h
//  phonelive
//
//  Created by 400 on 2020/9/22.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol TaskJumpDelegate <NSObject>

- (void)taskJumpWithTaskID:(NSInteger)taskID;

@end

@interface TaskTableVC : UITableViewController
@property(nonatomic,strong)NSMutableArray *models;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,assign)id<TaskJumpDelegate> delelgate;
@end

NS_ASSUME_NONNULL_END
