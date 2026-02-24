//
//  RotationModel.m
//  phonelive2
//
//  Created by 400 on 2021/5/29.
//  Copyright © 2021 toby. All rights reserved.
//

#import "RotationModel.h"
@implementation RotationSubModel
+(NSDictionary*)mj_replacedKeyFromPropertyName
{
    return @{
                   @"ID" : @"id"
               };
}
@end

@implementation RotationModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"reward" : [RotationSubModel class]};
}

@end
