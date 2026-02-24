//
//  VideoProgressManager.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DramaProgressModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoProgressManager : NSObject

+(NSDictionary*)loadUserProgress:(NSString*)skitId;
+(void)saveUserProgress:(NSString*)progress skitId:(NSString*)skitId episodeNumber:(NSInteger)episodeNumber;
+(DramaProgressModel*)loadProgress:(NSString*)skitId episodeNumber:(NSInteger)episodeNumber;

@end

NS_ASSUME_NONNULL_END
