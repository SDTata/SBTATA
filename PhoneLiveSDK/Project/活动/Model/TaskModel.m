//
//  TaskModel.m
//  phonelive
//
//  Created by 400 on 2020/9/22.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TaskModel.h"
#import "PublicObj.h"
@implementation ConditionInfoModel

+(NSDictionary*)mj_replacedKeyFromPropertyName
{
    return @{
                   @"ID" : @"id"
               };
}

-(void)setCur_num:(NSString *)cur_num
{
    if ([PublicObj checkNull:cur_num]) {
        _cur_num = @"0";
    }else{
        _cur_num = cur_num;
    }
}
@end

@implementation TaskModel
+(NSDictionary*)mj_replacedKeyFromPropertyName
{
    return @{
                   @"ID" : @"id"
               };
}
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"condition_info" : [ConditionInfoModel class]};
}

@end
