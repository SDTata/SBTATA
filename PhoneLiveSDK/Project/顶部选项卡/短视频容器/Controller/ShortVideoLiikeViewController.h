//
//  ShortVideoLiikeViewController.h
//  phonelive2
//
//  Created by s5346 on 2024/8/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortVideoListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideoLiikeViewController : VKPagerChildVC

@property(nonatomic, weak) id<ShortVideoListViewControllerDelegate> delegate;
- (void)handleRefresh;
- (void)refreshAndScrollToTop;
@end

NS_ASSUME_NONNULL_END
