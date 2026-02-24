//
//  UIScrollView+VKRefresh.h
//
//  Created by vick on 2021/3/2.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VKRefresh)

/// 下拉刷新
- (void)vk_setHeaderRefreshBlock:(void (^)(void))block;

/// 上拉加载
- (void)vk_setFooterRefreshBlock:(void (^)(void))block;

/// 开始刷新
- (void)vk_headerBeginRefreshing;

/// 开始刷新，无动画
- (void)vk_headerBeginRefresh;

/// 结束刷新
- (void)vk_headerEndRefreshing;

/// 开始加载
- (void)vk_footerBeginRefreshing;

/// 结束加载
- (void)vk_footerEndRefreshing;

/// 无更多数据
- (void)vk_noMoreData;

/// 返回顶部
- (void)vk_scrollToTopAnimated:(BOOL)animated;

@end
