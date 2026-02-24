//
//  SkitPreload.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkitVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitPreload : NSObject

- (void)addModel:(SkitVideoInfoModel*)model;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
