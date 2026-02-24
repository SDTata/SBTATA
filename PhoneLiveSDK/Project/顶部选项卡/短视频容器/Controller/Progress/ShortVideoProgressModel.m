//
//  ShortVideoProgressModel.m
//  phonelive2
//
//  Created by s5346 on 2024/8/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoProgressModel.h"

@implementation ShortVideoProgressModel

- (instancetype)initWithProgress:(NSString*)progress
{
    self = [super init];
    if (self) {
        NSArray *array = [progress componentsSeparatedByString:@"|"];
        if (array.count >= 2) {
            self.currentTime = [array[0] intValue];
            self.totalTime = [array[1] intValue];
        } else {
            self.currentTime = 0;
            self.totalTime = 0;
        }
    }
    return self;
}

@end
