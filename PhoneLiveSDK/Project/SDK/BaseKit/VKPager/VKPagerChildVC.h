//
//  VKPagerChildVC.h
//
//  Created by vick on 2021/2/23.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXCategoryListContainerView.h>
#import <JXPagerView.h>
@class VKPagerVC;

@interface VKPagerChildVC : UIViewController <JXCategoryListContentViewDelegate, JXPagerViewListViewDelegate>

/// 子类需要实现该回调
@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

/// 当前页码
@property (nonatomic, assign) NSInteger pageIndex;

/// 上级控制器
@property (nonatomic, weak) VKPagerVC *superPagerVC;

@end
