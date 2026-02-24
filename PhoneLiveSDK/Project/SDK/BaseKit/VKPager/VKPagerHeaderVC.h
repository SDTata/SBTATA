//
//  VKPagerHeaderVC.h
//
//  Created by vick on 2022/2/19.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXPagerListRefreshView.h>
#import "VKPagerSegment.h"
#import "VKPagerSegment+Style.h"
#import "VKPagerChildVC.h"

@interface VKPagerHeaderVC : UIViewController <JXCategoryViewDelegate, JXPagerViewDelegate, JXPagerMainTableViewGestureDelegate>

/// 头部视图
@property (nonatomic, strong) UIView *headerBackView;

/// 悬浮视图
@property (nonatomic, strong) UIView *sectionBackView;

/// 头部高度
@property (nonatomic, assign) CGFloat headerViewHeight;

/// 悬浮高度
@property (nonatomic, assign) CGFloat sectionViewHeight;

/// 标题视图
@property (nonatomic, strong) VKPagerSegment *categoryView;

/// 内容视图
@property (nonatomic, strong) JXPagerView *pagerView;

/// 当前控制器
@property (nonatomic, strong) VKPagerChildVC *currentVC;

/// 上级控制器
@property (nonatomic, weak) VKPagerVC *superPagerVC;

/// 当前页码
@property (nonatomic, assign) NSInteger pageIndex;

/// 返回指定控制器
- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index;

/// 返回类型
- (Class)renderSegmentClass;

/// 返回分页类型
- (Class)renderPagerClass;

/// 页面切换回调
- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index;

@end
