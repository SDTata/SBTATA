//
//  ExchangeRateModel.m
//  phonelive2
//
//  Created by lucas on 2021/9/24.
//  Copyright © 2021 toby. All rights reserved.
//

#import "ExchangeRateModel.h"

@implementation ExchangeRateModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
     return @{
               @"ID" : @"id"
              };
}
@end
