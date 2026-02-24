//
//  VKPagerVC.h
//
//  Created by vick on 2021/2/23.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXCategoryListContainerView.h>
#import "VKPagerSegment.h"
#import "VKPagerSegment+Style.h"
#import "VKPagerChildVC.h"

@interface VKPagerVC : UIViewController <JXCategoryListContainerViewDelegate, JXCategoryViewDelegate, JXCategoryListContentViewDelegate>

/// 标题视图
@property (nonatomic, strong) VKPagerSegment *categoryView;

/// 内容视图
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

/// 当前控制器
@property (nonatomic, weak) VKPagerChildVC *currentVC;

/// 当前页码
@property (nonatomic, assign) NSInteger pageIndex;

/// 上级控制器
@property (nonatomic, weak) VKPagerVC *superPagerVC;

/// 返回指定控制器
- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index;

/// 返回标题类型
- (Class)renderSegmentClass;

/// 页面切换回调
- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index;

@end
