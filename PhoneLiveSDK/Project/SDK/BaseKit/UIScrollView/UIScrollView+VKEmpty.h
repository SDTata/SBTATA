//
//  UIScrollView+VKEmpty.h
//
//  Created by vick on 2021/3/2.
//

#import <UIKit/UIKit.h>
#import <UIScrollView+EmptyDataSet.h>

#define kDefaultEmptyText  YZMsg(@"public_noEmpty")
#define kDefaultEmptyImage @"no_betList"

@interface UIScrollView (VKEmpty)
<DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

/// 空图片
@property (nonatomic, strong) UIImage *emptyImage;

/// 空文字
@property (nonatomic, copy) NSAttributedString *emptyTitle;

/// 空视图
@property (nonatomic, strong) UIView *emptyView;

/// 偏移
@property (nonatomic, assign) CGFloat emptyOffset;

/// 显示空视图
- (void)vk_showEmptyView;

/// 隐藏空视图
- (void)vk_hideEmptyView;

@end
