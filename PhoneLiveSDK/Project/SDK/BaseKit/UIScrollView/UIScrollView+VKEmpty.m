//
//  UIScrollView+VKEmpty.m
//
//  Created by vick on 2021/3/2.
//

#import "UIScrollView+VKEmpty.h"
#import <objc/runtime.h>

@implementation UIScrollView (VKEmpty)

- (void)setEmptyImage:(UIImage *)emptyImage {
    objc_setAssociatedObject(self, @selector(emptyImage), emptyImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIImage *)emptyImage {
    return objc_getAssociatedObject(self, @selector(emptyImage));
}

- (void)setEmptyOffset:(CGFloat)emptyOffset {
    objc_setAssociatedObject(self, @selector(emptyOffset), @(emptyOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)emptyOffset {
    return [objc_getAssociatedObject(self, @selector(emptyOffset)) floatValue];
}

- (void)setEmptyTitle:(NSAttributedString *)emptyTitle {
    objc_setAssociatedObject(self, @selector(emptyTitle), emptyTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSAttributedString *)emptyTitle {
    return objc_getAssociatedObject(self, @selector(emptyTitle));
}

- (void)setEmptyView:(UIView *)emptyView {
    objc_setAssociatedObject(self, @selector(emptyView), emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)emptyView {
    return objc_getAssociatedObject(self, @selector(emptyView));
}

- (void)vk_showEmptyView {
    self.emptyDataSetSource = self;
    self.emptyDataSetDelegate = self;
}

- (void)vk_hideEmptyView {
    self.emptyDataSetSource = nil;
    self.emptyDataSetDelegate = nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.emptyTitle) {
        return self.emptyTitle;
    }
    NSString *text = kDefaultEmptyText;
    NSDictionary *attributes = @{
        NSFontAttributeName: vkFont(14),
        NSForegroundColorAttributeName: vkColorHexA(0x000000, 0.5)
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.emptyImage) {
        return self.emptyImage;
    }
//    return [ImageBundle imagewithBundleName:kDefaultEmptyImage];
    return nil;
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.emptyView) {
        return self.emptyView;
    }
    return nil;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return self.emptyOffset;
}

@end
