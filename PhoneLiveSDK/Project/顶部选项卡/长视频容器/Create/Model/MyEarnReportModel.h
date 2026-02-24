//
//  MyEarnReportModel.h
//  phonelive2
//
//  Created by vick on 2024/7/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyEarnReportModel : NSObject

@property (nonatomic, copy) NSString *period_profit;
@property (nonatomic, copy) NSString *total_profit;
@property (nonatomic, strong) NSArray <ShortVideoModel *> *profit_list;

@end

NS_ASSUME_NONNULL_END
