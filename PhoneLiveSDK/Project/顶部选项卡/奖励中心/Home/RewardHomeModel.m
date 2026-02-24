//
//  RewardHomeModel.m
//  phonelive2
//
//  Created by vick on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "RewardHomeModel.h"

@implementation RewardItemsModel

@end

@implementation RewardProgressModel

@end

@implementation RewardDetailsModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"items": [RewardItemsModel class]
    };
}

@end

@implementation RewardHomeModel

- (void)setAction_url:(NSString *)action_url {
    _action_url = action_url;
    
    if ([action_url isEqualToString:@"getBonus"]) {
        _rewardType = RewardTypeDaySign;
    } else if ([action_url isEqualToString:@"getRebateReward"]) {
        _rewardType = RewardTypeBackWater;
    } else if ([action_url isEqualToString:@"chargeInto"]) {
        _rewardType = RewardTypeShareAward;
    } else if ([action_url isEqualToString:@"doLuckydraw"]) {
        _rewardType = RewardTypeLuckyDraw;
    } else if ([action_url isEqualToString:@"Kingreward.getreward"]) {
        _rewardType = RewardTypeKingSalary;
    } else if ([action_url isEqualToString:@"goWeb"]) {
        _rewardType = RewardTypeGoWEB;
    } else {
        _rewardType = RewardTypeDayTask;
    }
}

- (void)setReward_details:(RewardDetailsModel *)reward_details {
    _reward_details = reward_details;
    
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    if (reward_details.coin.floatValue > 0) {
        [string vk_appendString:[NSString stringWithFormat:@"%@：", YZMsg(@"task_reward_alert_title")]];
        [string vk_appendString:[YBToolClass getRateCurrency:reward_details.coin showUnit:YES] color:vkColorHex(0xc87dfa)];
        [string vk_appendSpace:5];
    }
    for (RewardItemsModel *item in reward_details.items) {
        if ([item.type isEqualToString:@"car"]) {
            [string vk_appendString:[NSString stringWithFormat:@"%@：", YZMsg(@"market_mount")]];
            [string vk_appendString:item.name color:vkColorHex(0xd0104c)];
            [string vk_appendString:[NSString stringWithFormat:@" +%@%@", item.duration, YZMsg(@"public_Day")] color:vkColorHex(0xd0104c)];
            [string vk_appendSpace:5];
        } else if ([item.type isEqualToString:@"vip"]) {
            [string vk_appendString:@"VIP："];
            [string vk_appendString:[NSString stringWithFormat:@"+%@%@", item.duration, YZMsg(@"public_Day")] color:vkColorHex(0xd0104c)];
            [string vk_appendSpace:5];
        } else if ([item.type isEqualToString:@"flow"]) {
            [string vk_appendString:[NSString stringWithFormat:@"%@：", YZMsg(@"task_reward_bet")]];
            [string vk_appendString:[NSString stringWithFormat:@"+%@", [YBToolClass getRateCurrency:item.amount showUnit:YES]] color:vkColorHex(0x65b3f3)];
            [string vk_appendSpace:5];
        } else if ([item.type isEqualToString:@"flow_kp"]) {
            [string vk_appendString:[NSString stringWithFormat:@"%@：", YZMsg(@"task_reward_bet")]];
            [string vk_appendString:[NSString stringWithFormat:@"x%@",[YBToolClass getRateCurrency:item.amount showUnit:YES]] color:vkColorHex(0x65b3f3)];
            [string vk_appendSpace:5];
        }
    }
    _itemText = string;
}

- (BOOL)completed {
    return [self.status isEqualToString:@"completed"];
}

- (BOOL)canClick {
    return (self.completed || ([self.status isEqualToString:@"in_progress"] && (self.rewardType == RewardTypeDayTask || self.rewardType == RewardTypeDaySign)) || (self.action_url &&[self.action_url containsString:@"goWeb"])) && ([PublicObj checkNull:self.timer] || [self.timer isEqualToString:@"0"]);
}

- (NSString *)groupId {
    return [self.cell_jump componentsSeparatedByString:@"="].lastObject;
}

@end
