//
//  VKPagerChildVC.m
//
//  Created by vick on 2021/2/23.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "VKPagerChildVC.h"

@interface VKPagerChildVC ()

@end

@implementation VKPagerChildVC

#pragma mark - JXCategoryListContentViewDelegate
/**
 实现 <JXCategoryListContentViewDelegate> 协议方法，返回该视图控制器所拥有的「视图」
 */
- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)view;
        }
    }
    return nil;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

@end
