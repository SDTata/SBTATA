//
//  VipPayModel.m
//  phonelive2
//
//  Created by vick on 2025/2/10.
//  Copyright © 2025 toby. All rights reserved.
//

#import "VipPayModel.h"

@implementation VipPayListModel

@end

@implementation VipPayUserModel

@end

@implementation VipPayModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"vip_list": [VipPayListModel class]
    };
}

@end
