//
//  ScrollUIPageViewController.h
//  phonelive2
//
//  Created by s5346 on 2024/9/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ScrollUIPageViewControllerDelegate <NSObject>

- (void)scrollUIPageViewControllerDelegateForScroll:(CGFloat)moveX scrollViewWidth:(CGFloat)scrollViewWidth scrollContentSizeWidth:(CGFloat)scrollContentSizeWidth;

@end
@interface ScrollUIPageViewController : UIPageViewController
@property(nonatomic, assign) id<ScrollUIPageViewControllerDelegate> scrollDelegate;

@end

NS_ASSUME_NONNULL_END
