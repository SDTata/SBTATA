//
//  ShortVideoProgressManager.h
//  phonelive2
//
//  Created by s5346 on 2024/8/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoProgressModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideoProgressManager : NSObject

+(void)saveUserProgress:(NSString*)progress videoId:(NSString*)videoId title:(NSString*)title;
+(ShortVideoProgressModel*)loadProgress:(NSString*)videoId title:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
