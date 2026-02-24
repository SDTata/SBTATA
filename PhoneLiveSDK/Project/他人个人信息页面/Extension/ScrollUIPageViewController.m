//
//  ScrollUIPageViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/9/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ScrollUIPageViewController.h"

@interface ScrollUIPageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *pageScrollView;

@end

@implementation ScrollUIPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
            break;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollUIPageViewControllerDelegateForScroll:scrollViewWidth:scrollContentSizeWidth:)]) {
        [self.scrollDelegate scrollUIPageViewControllerDelegateForScroll:scrollView.contentOffset.x - scrollView.mj_w scrollViewWidth:scrollView.mj_w scrollContentSizeWidth:scrollView.contentSize.width];
    }
}

@end
