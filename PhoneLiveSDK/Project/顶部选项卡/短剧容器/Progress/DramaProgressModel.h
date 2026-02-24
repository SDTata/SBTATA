//
//  DramaProgressModel.h
//  phonelive2
//
//  Created by s5346 on 2024/5/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DramaProgressModel : NSObject

@property (nonatomic, assign) NSInteger episode_number;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, assign) NSInteger totalTime;

- (instancetype)initWithProgress:(NSString*)progress;

@end

NS_ASSUME_NONNULL_END
