//
//  UIScrollView+VKPage.h
//
//  Created by vick on 2021/3/2.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VKPage)

/// 初始页码
@property (nonatomic, assign) NSInteger pageStart;

/// 页码大小
@property (nonatomic, assign) NSInteger pageSize;

/// 当前页码
@property (nonatomic, assign) NSInteger pageIndex;

/// 刷新状态
@property (nonatomic, assign) BOOL isHeaderRefreshing;

/// 数据加载回调
@property (nonatomic, copy) void (^loadDataBlock)(void);

/// 添加下拉刷新
- (void)vk_headerRefreshSet;

/// 添加上拉加载
- (void)vk_footerRefreshSet;

/// 刷新结束
- (void)vk_endRefreshing:(NSArray *)array;

@end
