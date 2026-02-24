//
//  TaskModel.h
//  phonelive
//
//  Created by 400 on 2020/9/22.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ConditionInfoModel : NSObject

@property(nonatomic,assign)NSInteger condition_num;
@property(nonatomic,assign)NSInteger condition_type;
@property(nonatomic,strong)NSString *cur_num;
@property(nonatomic,strong)NSString *desc;
@property(nonatomic,assign)NSInteger ID;

@end

@interface TaskModel : NSObject

@property(nonatomic,strong)NSString *condition_id;
@property(nonatomic,strong)NSArray *condition_info;
@property(nonatomic,strong)NSString *desc;
@property(nonatomic,assign)NSInteger end_time;
@property(nonatomic,strong)NSString *group;
@property(nonatomic,assign)NSInteger hide_time;
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic,assign)NSInteger pre_task_id;
@property(nonatomic,strong)NSString *reward_id;
@property(nonatomic,strong)NSString *task_reward_desc;
@property(nonatomic,strong)NSString *reward_num;
@property(nonatomic,assign)NSInteger show_time;
@property(nonatomic,assign)NSInteger start_time;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *user_group;
@property(nonatomic,assign)NSInteger completed;
@property(nonatomic,strong)NSString *title_group_id;

@end

NS_ASSUME_NONNULL_END
