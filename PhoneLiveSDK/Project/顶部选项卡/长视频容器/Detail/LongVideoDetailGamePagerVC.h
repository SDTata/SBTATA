//
//  LongVideoDetailGamePagerVC.h
//  phonelive2
//
//  Created by vick on 2024/7/8.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendGameModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LongVideoDetailGamePagerVC : VKPagerChildVC

@property (nonatomic, strong) NSArray <HomeRecommendGame *> *gameList;

@end

NS_ASSUME_NONNULL_END
