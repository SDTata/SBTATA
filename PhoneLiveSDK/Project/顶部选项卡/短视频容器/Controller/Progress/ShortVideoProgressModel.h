//
//  ShortVideoProgressModel.h
//  phonelive2
//
//  Created by s5346 on 2024/8/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideoProgressModel : NSObject

@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, assign) NSInteger totalTime;

- (instancetype)initWithProgress:(NSString*)progress;

@end

NS_ASSUME_NONNULL_END
