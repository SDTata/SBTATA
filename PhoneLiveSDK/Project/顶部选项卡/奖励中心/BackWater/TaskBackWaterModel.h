//
//  TaskBackWaterModel.h
//  phonelive2
//
//  Created by vick on 2024/8/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskBackWaterRateModel : NSObject

@property (nonatomic, copy) NSString *king_name;
@property (nonatomic, copy) NSString *king_level;
@property (nonatomic, copy) NSString *rebate_rate;
@property (nonatomic, assign) NSInteger min_level;
@property (nonatomic, assign) NSInteger max_level;

@end

@interface TaskBackWaterModel : NSObject

@property (nonatomic, copy) NSString *game;
@property (nonatomic, copy) NSString *max_rebate;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, strong) NSArray <TaskBackWaterRateModel *> *rates;

@end

NS_ASSUME_NONNULL_END
