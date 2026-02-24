//
//  ShortVideosFollowContainer.h
//  phonelive2
//
//  Created by s5346 on 2024/9/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortVideoListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideosFollowContainer : VKPagerChildVC

@property(nonatomic, weak) id<ShortVideoListViewControllerDelegate> delegate;
- (void)handleRefresh;
@end

NS_ASSUME_NONNULL_END
