//
//  UIScrollView+VKRefresh.m
//
//  Created by vick on 2021/3/2.
//

#import "UIScrollView+VKRefresh.h"
#import "UIScrollView+VKPage.h"
#import "MJRefresh.h"
#import "AnimRefreshHeader.h"

@implementation UIScrollView (VKRefresh)

- (void)vk_setHeaderRefreshBlock:(void (^)(void))block {
    AnimRefreshHeader *header = [AnimRefreshHeader headerWithRefreshingBlock:block];
    header.isCollectionViewAnimationBug = YES;
    header.ignoredScrollViewContentInsetTop =  self.contentInset.top;
    self.mj_header = header;
}

- (void)vk_setFooterRefreshBlock:(void (^)(void))block {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:block];
//    footer.automaticallyChangeAlpha = true;
    footer.triggerAutomaticallyRefreshPercent = -10;
    self.mj_footer = footer;
}

- (void)vk_headerBeginRefreshing {
    [self setContentOffset:CGPointZero animated:NO];
    [self.mj_header beginRefreshing];
}

- (void)vk_headerBeginRefresh {
    self.pageIndex = self.pageStart;
    self.isHeaderRefreshing = YES;
    !self.loadDataBlock ?: self.loadDataBlock();
}

- (void)vk_headerEndRefreshing {
    [self.mj_header endRefreshing];
}

- (void)vk_footerBeginRefreshing {
    [self.mj_footer beginRefreshing];
}

- (void)vk_footerEndRefreshing {
    [self.mj_footer endRefreshing];
}

- (void)vk_noMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)vk_scrollToTopAnimated:(BOOL)animated {
    CGPoint point = CGPointMake(-self.contentInset.left, -self.contentInset.top);
    [self setContentOffset:point animated:animated];
}

@end
