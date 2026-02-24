//
//  DramaVideoInfoModel.m
//  phonelive2
//
//  Created by s5346 on 2024/5/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaVideoInfoModel.h"

@implementation DramaVideoInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.play_url = @"";
    }
    return self;
}
+ (NSDictionary*)mj_replacedKeyFromPropertyName {
    return @{@"video_id"  : @"id"};
}

- (BOOL)isNeedPay {
    return self.need_ticket_count > 0 && self.is_buy == NO;
}

@end
