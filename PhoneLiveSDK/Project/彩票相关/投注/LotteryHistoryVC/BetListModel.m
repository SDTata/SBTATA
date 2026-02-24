//
//  BetListModel.m
//  phonelive2
//
//  Created by test on 2021/9/20.
//  Copyright © 2021 toby. All rights reserved.
//

#import "BetListModel.h"
@implementation BetListTotalModel

@end

@implementation BetStatusInfoModel

@end

@implementation BetListPageModel

@end

@implementation BetLotterysInfoModel

@end

@implementation BetListDetailModel

@end

@implementation BetListDataModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"detail":@"BetListDetailModel"
    };
}
@end


@implementation BetListModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"list":@"BetListDataModel",
        @"lotterysInfo":@"BetLotterysInfoModel",
        @"statusInfo":@"BetStatusInfoModel"
    };
}

@end
