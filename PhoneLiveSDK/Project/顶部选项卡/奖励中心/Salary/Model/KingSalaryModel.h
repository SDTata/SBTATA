//
//  KingSalaryModel.h
//  phonelive2
//
//  Created by s5346 on 2024/8/23.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SalaryLevelItem : NSObject

@property (nonatomic, strong) NSString *c_charge;
@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSString *level_icon;
@property (nonatomic, strong) NSString *level_icon_aid;
@property (nonatomic, strong) NSString *levelup_reward;
@property (nonatomic, strong) NSString *week_reward;
@property (nonatomic, strong) NSString *month_reward;

@end

@interface SararyRewardItem : NSObject

@property (nonatomic, strong) NSString *reward_can_get;
@property (nonatomic, strong) NSString *reward_got_money;
@property (nonatomic, strong) NSString *reward_money;
@property (nonatomic, strong) NSString *reward_next_time;
@property (nonatomic, strong) NSString *reward_process;
@property (nonatomic, strong) NSString *reward_title;
@property (nonatomic, strong) NSString *reward_total_count;
@property (nonatomic, strong) NSString *reward_type;

@end

@interface KingSalaryModel : NSObject

@property (nonatomic, strong) NSString *leve_c_cur;
@property (nonatomic, strong) NSString *leve_c_end;
@property (nonatomic, strong) NSString *leve_c_start;
@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSArray<SalaryLevelItem *> *list;
@property (nonatomic, strong) NSArray<SararyRewardItem *> *reward_list;
@property (nonatomic, strong) NSString *rule;

@end

NS_ASSUME_NONNULL_END
