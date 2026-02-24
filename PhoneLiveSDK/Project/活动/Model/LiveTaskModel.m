//
//  LiveTaskModel.m
//  phonelive2
//
//  Created by lucas on 2021/11/5.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LiveTaskModel.h"

@implementation LiveTaskModel
+(NSDictionary*)mj_replacedKeyFromPropertyName
{
    return @{
                   @"ID" : @"id"
               };
}

@end
