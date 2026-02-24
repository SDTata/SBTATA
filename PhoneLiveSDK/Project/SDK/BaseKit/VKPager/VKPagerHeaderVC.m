//
//  VKPagerHeaderVC.m
//
//  Created by vick on 2022/2/19.
//  Copyright © 2022 Facebook. All rights reserved.
//

#import "VKPagerHeaderVC.h"

@implementation VKPagerHeaderVC

#pragma mark - JXPagerViewDelegate

- (UIView *)tableHeaderViewInPagerView:(JXPagerView *)pagerView {
    return self.headerBackView;
}

- (NSUInteger)tableHeaderViewHeightInPagerView:(JXPagerView *)pagerView {
    return self.headerViewHeight;
}

- (UIView *)viewForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return self.sectionBackView;
}

- (NSUInteger)heightForPinSectionHeaderInPagerView:(JXPagerView *)pagerView {
    return self.sectionViewHeight;
}

- (NSInteger)numberOfListsInPagerView:(JXPagerView *)pagerView {
    return self.categoryView.titles.count;
}

- (id<JXPagerViewListViewDelegate>)pagerView:(JXPagerView *)pagerView initListAtIndex:(NSInteger)index {
    VKPagerChildVC *vc = [self renderViewControllerWithIndex:index];
    vc.pageIndex = index;
    self.currentVC = vc;
    return vc;
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    return [VKPagerChildVC new];
}

- (Class)renderSegmentClass {
    return [VKPagerSegment class];
}

- (Class)renderPagerClass {
    return [JXPagerView class];
}

#pragma mark - JXCategoryListContentViewDelegate
/**
 实现 <JXCategoryListContentViewDelegate> 协议方法，返回该视图控制器所拥有的「视图」
 */
- (UIView *)listView {
    return self.view;
}

/// 分页菜单视图
- (VKPagerSegment *)categoryView {
    if (!_categoryView) {
        _categoryView = [[[self renderSegmentClass] alloc] init];
        _categoryView.delegate = self;
        _categoryView.listContainer = (id<JXCategoryViewListContainer>)self.pagerView.listContainerView;
    }
    return _categoryView;
}

/// 列表容器视图
- (JXPagerView *)pagerView {
    if (!_pagerView) {
        _pagerView = [[[self renderPagerClass] alloc] initWithDelegate:self];
        _pagerView.mainTableView.gestureDelegate = self;
        _pagerView.backgroundColor = UIColor.clearColor;
        _pagerView.mainTableView.backgroundColor = UIColor.clearColor;
        _pagerView.listContainerView.backgroundColor = UIColor.clearColor;
        _pagerView.listContainerView.listCellBackgroundColor = UIColor.clearColor;
        _pagerView.automaticallyDisplayListVerticalScrollIndicator = NO;
        _pagerView.listContainerView.categoryNestPagingEnabled = YES;
    }
    return _pagerView;
}

- (UIView *)headerBackView {
    if (!_headerBackView) {
        _headerBackView = [UIView new];
    }
    return _headerBackView;
}

- (UIView *)sectionBackView {
    if (!_sectionBackView) {
        _sectionBackView = [UIView new];
    }
    return _sectionBackView;
}

/// 页面切换
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.currentVC = (VKPagerChildVC *)self.pagerView.validListDict[@(index)];
    [self pageViewDidSelectedItemAtIndex:index];
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    
}

#pragma mark - JXPagerMainTableViewGestureDelegate

- (BOOL)mainTableViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (!YBToolClass.sharedInstance.gameTopCanScroll) {
//        return NO;
//    }
    /// 禁止categoryView左右滑动的时候，上下和左右都可以滚动
    if (otherGestureRecognizer == self.categoryView.collectionView.panGestureRecognizer) {
        return NO;
    }
    if ([self.superPagerVC isKindOfClass:[VKPagerVC class]]) {
        if (otherGestureRecognizer.view == ((VKPagerVC *)self.superPagerVC).listContainerView.scrollView) {
            return NO;
        }
    }
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

@end
