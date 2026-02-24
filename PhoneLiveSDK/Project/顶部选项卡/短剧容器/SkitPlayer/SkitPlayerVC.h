//
//  SkitPlayerVC.h
//  phonelive2
//
//  Created by vick on 2024/9/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendSkitModel.h"
#import "SkitVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitPlayerVC : UIViewController

@property (nonatomic, strong) NSArray <HomeRecommendSkit *> *skitArray;
@property (nonatomic, assign) NSInteger skitIndex;
@property(nonatomic, copy) void (^currentIndexBlock)(NSInteger);
@property(nonatomic, copy) UIView* (^getViewCurrentIndexBlock)(NSInteger);
@property (nonatomic, assign) BOOL hasTabbar;

@end

NS_ASSUME_NONNULL_END
