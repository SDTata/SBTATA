//
//  UIScrollView+VKPage.m
//
//  Created by vick on 2021/3/2.
//

#import "UIScrollView+VKPage.h"
#import "UIScrollView+VKRefresh.h"
#import <objc/runtime.h>
#import "VKMacro.h"

@implementation UIScrollView (VKPage)

- (void)setPageIndex:(NSInteger)pageIndex {
    objc_setAssociatedObject(self, @selector(pageIndex), @(pageIndex), OBJC_ASSOCIATION_ASSIGN);
}
- (NSInteger)pageIndex {
    return [objc_getAssociatedObject(self, @selector(pageIndex)) integerValue];
}

- (void)setPageSize:(NSInteger)pageSize {
    objc_setAssociatedObject(self, @selector(pageSize), @(pageSize), OBJC_ASSOCIATION_ASSIGN);
}
- (NSInteger)pageSize {
    return [objc_getAssociatedObject(self, @selector(pageSize)) integerValue];
}

- (void)setPageStart:(NSInteger)pageStart {
    objc_setAssociatedObject(self, @selector(pageStart), @(pageStart), OBJC_ASSOCIATION_ASSIGN);
    self.pageIndex = pageStart;
}
- (NSInteger)pageStart {
    return [objc_getAssociatedObject(self, @selector(pageStart)) integerValue];
}

- (void)setIsHeaderRefreshing:(BOOL)isHeaderRefreshing {
    objc_setAssociatedObject(self, @selector(isHeaderRefreshing), @(isHeaderRefreshing), OBJC_ASSOCIATION_ASSIGN);

}
- (BOOL)isHeaderRefreshing {
    return [objc_getAssociatedObject(self, @selector(isHeaderRefreshing)) boolValue];
}

- (void)setLoadDataBlock:(void (^)(void))loadDataBlock {
    objc_setAssociatedObject(self, @selector(loadDataBlock), loadDataBlock, OBJC_ASSOCIATION_COPY);
}
- (void (^)(void))loadDataBlock {
    return objc_getAssociatedObject(self, @selector(loadDataBlock));
}

- (void)vk_headerRefreshSet {
    self.pageStart = 1;
    self.pageSize = 10;
    _weakify(self)
    [self vk_setHeaderRefreshBlock:^{
        _strongify(self)
        self.pageIndex = self.pageStart;
        self.isHeaderRefreshing = YES;
        !self.loadDataBlock ?: self.loadDataBlock();
    }];
}

- (void)vk_footerRefreshSet {
    self.pageStart = 1;
    self.pageSize = 10;
    _weakify(self)
    [self vk_setFooterRefreshBlock:^{
        _strongify(self)
        self.pageIndex ++ ;
        self.isHeaderRefreshing = NO;
        !self.loadDataBlock ?: self.loadDataBlock();
    }];
}

- (void)vk_endRefreshing:(NSArray *)array {
    if (self.isHeaderRefreshing) {
        
        if (array.count < self.pageSize) {
            [self vk_headerEndRefreshing];
            [self vk_noMoreData];
        } else {
            [self vk_headerEndRefreshing];
            [self vk_footerEndRefreshing];
        }
        
    } else {
        
        if (array.count < self.pageSize) {
            [self vk_noMoreData];
        } else {
            [self vk_footerEndRefreshing];
        }
    }
}

@end
