//
//  LongVideoHomeChildVC.h
//  phonelive2
//
//  Created by vick on 2024/7/9.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LongVideoHomeChildVC : VKPagerChildVC

@property (nonatomic, strong) NSArray <MovieHomeModel *> *homeList;
@property (nonatomic, strong) MovieCateModel *cateModel;

@end

NS_ASSUME_NONNULL_END
