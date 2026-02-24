//
//  DramaInfoModel.m
//  phonelive2
//
//  Created by s5346 on 2024/5/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaInfoModel.h"

@implementation DramaInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.is_favorite = NO;
        self.skit_ticket_count = 0;
    }
    return self;
}

+ (NSDictionary*)mj_replacedKeyFromPropertyName {
    return @{@"skit_id"  : @"id"};
}

@end
