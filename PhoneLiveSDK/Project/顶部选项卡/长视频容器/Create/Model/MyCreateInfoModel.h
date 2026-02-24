//
//  MyCreateInfoModel.h
//  phonelive2
//
//  Created by vick on 2024/7/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCreateCountModel : NSObject

@property (nonatomic, copy) NSString *approved;
@property (nonatomic, copy) NSString *pending;
@property (nonatomic, copy) NSString *rejected;

@end


@interface MyCreateInfoModel : NSObject

@property (nonatomic, copy) NSString *income;
@property (nonatomic, strong) MyCreateCountModel *review_status_counts;
@property (nonatomic, strong) NSArray <ShortVideoModel *> *video_list;

@end

NS_ASSUME_NONNULL_END
