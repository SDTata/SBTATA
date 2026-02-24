//
//  SkitPreloadManager.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkitVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitPreloadManager : NSObject

- (void)addPreload:(SkitVideoInfoModel*)model;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
