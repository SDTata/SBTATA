//
//  HomeRecommendLiveModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hotModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface HomeRecommendLiveModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray<hotModel *> *data;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int layout_column;
@property (nonatomic, assign) int layout_row;
@property (nonatomic, assign) BOOL isScroll;

@end

NS_ASSUME_NONNULL_END
