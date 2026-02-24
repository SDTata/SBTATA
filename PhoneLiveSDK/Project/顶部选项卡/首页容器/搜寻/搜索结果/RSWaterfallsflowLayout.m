//
//  RSWaterfallsflowLayout.m
//  RSWaterfallsDemo
//
//  Created by WhatsXie on 2017/8/17.
//  Copyright © 2017年 StevenXie. All rights reserved.
//

#import "RSWaterfallsflowLayout.h"

/** 默认列数 */
static const NSInteger RSDefaultColumnCount = 2;
/** 默认每一列间的间距 */
static const CGFloat RSDefaultColumnMargin = 10;
/** 默认每一行间的间距 */
static const CGFloat RSDefaultRowMargin = 10;
/** 默认边缘间距 */
static const UIEdgeInsets RSDefaultEdgeInsets = {10, 10, 10, 10};

@interface RSWaterfallsflowLayout ()

/** 存放所有cell的布局属性 */
@property (nonatomic, strong) NSMutableArray *attrsArray;
/** 存放所有列的当前高度 */
@property (nonatomic, strong) NSMutableArray *columnHeights;
/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;

/** 传值处理（优先使用外部传进数值）*/
- (NSInteger)columnCount;
- (CGFloat)columnMargin;
- (CGFloat)rowMargin;
- (UIEdgeInsets)edgeInsets;

@end

@implementation RSWaterfallsflowLayout
/** 默认的列数 */
- (NSInteger)columnCount {
    if ([self.delegate respondsToSelector:@selector(columnCountInWaterflowLayout:)]) {
        return [self.delegate columnCountInWaterflowLayout:self];
    } else {
        return RSDefaultColumnCount;
    }
}

/** 每一列之间的间距 */
- (CGFloat)columnMargin {
    if ([self.delegate respondsToSelector:@selector(columnMarginInWaterflowLayout:)]) {
        return [self.delegate columnMarginInWaterflowLayout:self];
    } else {
        return RSDefaultColumnMargin;
    }
}

/** 每一行之间的间距 */
- (CGFloat)rowMargin {
    if ([self.delegate respondsToSelector:@selector(rowMarginInWaterflowLayout:)]) {
        return [self.delegate rowMarginInWaterflowLayout:self];
    } else {
        return RSDefaultRowMargin;
    }
}

/** 边缘间距 */
- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInWaterflowLayout:)]) {
        return [self.delegate edgeInsetsInWaterflowLayout:self];
    } else {
        return RSDefaultEdgeInsets;
    }
}

#pragma mark - <lazy>
/** 存放所有cell的布局属性 */
- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}
/** 存放所有列的当前高度 */
- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

/**
 * 初始化
 */
- (void)prepareLayout {
    [super prepareLayout];
    
    // 内容高度清0
    self.contentHeight = 0;
    
    // 清除以前计算的所有高度
    [self.columnHeights removeAllObjects];
    
    for (NSInteger i = 0; i < self.columnCount; i++) {
        [self.columnHeights addObject:@(self.edgeInsets.top)];
    }
    
    // 清除之前所有的布局属性
    [self.attrsArray removeAllObjects];
    //开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

/**
 * cell的排布
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

/**
 * 返回indexPath位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 创建布局属性
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // collectionView的宽度
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    
    // 设置布局属性的frame
    CGFloat width = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right - (self.columnCount - 1) * self.columnMargin) / self.columnCount;
    CGFloat cover_meta_height = [self.delegate waterflowLayout:self heightForItemAtIndex:indexPath.item itemWidth:width];
    CGFloat videoTextheight = [self.delegate waterflowLayout:self heightForShortVideoItemAtIndex:indexPath.item itemWidth:width];
    // 設置比例，橫屏和豎屏的長寬比
    CGFloat aspectRatio;
    if (cover_meta_height > width) {
        aspectRatio = 9.0 / 12.0;  // 豎屏比例
    } else if (cover_meta_height < width) {
        aspectRatio = 16.0 / 7.0;  // 橫屏比例
    } else {
        aspectRatio = 1;
    }
    
    // 使用比例計算高度
    CGFloat height = (width / aspectRatio) + videoTextheight;
    
    // 找出高度最短的那一列
    NSInteger destColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.columnCount; i++) {
        // 取得第i列的高度
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    CGFloat x = self.edgeInsets.left + destColumn * (width + self.columnMargin);
    CGFloat y = minColumnHeight;
    if (y != self.edgeInsets.top) {
        y += self.rowMargin;
    }
    if (!isnan(width) && !isnan(height)) {
        attrs.frame = CGRectMake(x, y, width, (cover_meta_height == 62 ? 62 : height)); // 用户昵称cell 高度写死 62
    } else {
        NSLog(@"Invalid width or height for item at indexPath: %@", indexPath);
    }
    
    // 更新最短那列的高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
    
    // 记录内容的高度
    CGFloat columnHeight = [self.columnHeights[destColumn] doubleValue];
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    return attrs;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(0, self.contentHeight + self.edgeInsets.bottom);
}

@end
