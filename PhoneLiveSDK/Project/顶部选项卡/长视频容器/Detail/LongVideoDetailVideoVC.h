//
//  LongVideoDetailVideoVC.h
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LongVideoDetailVideoVC : VKPagerChildVC

@property (nonatomic, strong) NSArray <ShortVideoModel *> *videoList;

@end

NS_ASSUME_NONNULL_END
