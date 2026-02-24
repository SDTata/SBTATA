//
//  RewardHomeModel.h
//  phonelive2
//
//  Created by vick on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RewardType) {
    RewardTypeDaySign,
    RewardTypeBackWater,
    RewardTypeShareAward,
    RewardTypeLuckyDraw,
    RewardTypeKingSalary,
    RewardTypeDayTask,
    RewardTypeGoWEB
};

@interface RewardItemsModel : NSObject
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *type;
@end

@interface RewardProgressModel : NSObject
@property (nonatomic, assign) CGFloat current;
@property (nonatomic, assign) CGFloat total;
@end

@interface RewardDetailsModel : NSObject
@property (nonatomic, copy) NSString *coin;
@property (nonatomic, strong) NSArray <RewardItemsModel *> *items;
@end

@interface RewardHomeModel : NSObject
@property (nonatomic, copy) NSString *action_text;
@property (nonatomic, copy) NSString *action_url;
@property (nonatomic, copy) NSString *btn_jump;
@property (nonatomic, copy) NSString *cell_jump;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, copy) NSString *icon_url;
@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) RewardProgressModel *progress;
@property (nonatomic, strong) RewardDetailsModel *reward_details;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *timer;
@property (nonatomic, assign) RewardType rewardType;
@property (nonatomic, copy) NSAttributedString *itemText;
@property (nonatomic, assign) BOOL canClick;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *rebate_rule_desc;
@end
