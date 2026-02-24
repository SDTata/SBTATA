//
//  VKPagerVC.m
//
//  Created by vick on 2021/2/23.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "VKPagerVC.h"

@implementation VKPagerVC

/// 返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}

/// 返回各个列表菜单下的实例，该实例需要遵守并实现 <JXCategoryListContentViewDelegate> 协议
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    VKPagerChildVC *vc = [self renderViewControllerWithIndex:index];
    vc.pageIndex = index;
    vc.superPagerVC = self;
    self.currentVC = vc;
    return vc;
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    return [VKPagerChildVC new];
}

- (Class)renderSegmentClass {
    return [VKPagerSegment class];
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
        _categoryView.listContainer = self.listContainerView;
    }
    return _categoryView;
}

/// 列表容器视图
- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
        _listContainerView.backgroundColor = UIColor.clearColor;
        _listContainerView.listCellBackgroundColor = UIColor.clearColor;
    }
    return _listContainerView;
}

/// 页面切换
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.currentVC = (VKPagerChildVC *)self.listContainerView.validListDict[@(index)];
    [self pageViewDidSelectedItemAtIndex:index];
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    
}

/// 页面切换
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
    [self pageViewDidClickItemAtIndex:index];
}

- (void)pageViewDidClickItemAtIndex:(NSInteger)index {
    
}
@end
