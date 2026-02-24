//
//  DramaProgressModel.m
//  phonelive2
//
//  Created by s5346 on 2024/5/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaProgressModel.h"

@implementation DramaProgressModel

- (instancetype)initWithProgress:(NSString*)progress
{
    self = [super init];
    if (self) {
        NSArray *array = [progress componentsSeparatedByString:@"|"];
        if (array.count >= 3) {
            self.episode_number = [array[0] intValue];
            self.currentTime = [array[1] intValue];
            self.totalTime = [array[2] intValue];
        } else {
            self.episode_number = 1;
            self.currentTime = 0;
            self.totalTime = 0;
        }
    }
    return self;
}

@end
