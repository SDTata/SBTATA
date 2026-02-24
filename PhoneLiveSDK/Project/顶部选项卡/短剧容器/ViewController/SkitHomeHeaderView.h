//
//  SkitHomeHeaderView.h
//  phonelive2
//
//  Created by vick on 2024/9/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitHomeHeaderView : UIStackView

@property (nonatomic, strong) NSArray <HomeRecommendSkit *> *collectArray;
@property (nonatomic, strong) NSArray <HomeRecommendSkit *> *historyArray;
@property (nonatomic, assign) CGFloat viewHeight;

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
