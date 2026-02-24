//
//  UserBonusModel.m
//  phonelive2
//
//  Created by s5346 on 2024/8/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "UserBonusModel.h"

@implementation UserBonusItemModel

@end

@implementation UserBonusModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"bonus_list" : [UserBonusItemModel class]};
}

@end
