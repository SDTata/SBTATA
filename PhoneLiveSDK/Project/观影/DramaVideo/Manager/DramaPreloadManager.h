//
//  DramaPreloadManager.h
//  phonelive2
//
//  Created by s5346 on 2024/6/13.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DramaPreloadManager : NSObject

- (void)addPreload:(DramaVideoInfoModel*)model;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
