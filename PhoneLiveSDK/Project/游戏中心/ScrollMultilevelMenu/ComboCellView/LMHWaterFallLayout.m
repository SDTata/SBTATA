//
//  LMHWaterFallLayout.m
//  c700LIVE
//
//  Created by lucas on 2022/10/13.
//  Copyright © 2022 toby. All rights reserved.
//

#import "LMHWaterFallLayout.h"


@interface LMHWaterFallLayout()
/** 存放所有的布局属性 */
@property (nonatomic, strong) NSMutableArray * attrsArr;
/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;


@end

@implementation LMHWaterFallLayout



#pragma mark 懒加载
- (NSMutableArray *)attrsArr{
    if (!_attrsArr) {
        _attrsArr = [NSMutableArray array];
    }
    
    return _attrsArr;
}


/**
 * 初始化
 */
- (void)prepareLayout{
    
    [super prepareLayout];
    
    self.contentHeight = 0;
    
    // 清楚之前所有的布局属性
    [self.attrsArr removeAllObjects];

    NSInteger itemCount = [self.collectionView numberOfSections];
    
    for (int index = 0; index < itemCount; index ++) {
        NSInteger pSec = [self.collectionView numberOfItemsInSection:index];
        //头部视图
        UICollectionViewLayoutAttributes * layoutHeader = [UICollectionViewLayoutAttributes   layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathWithIndex:index]];
        layoutHeader.frame =CGRectMake(0,self.contentHeight, self.collectionView.size.width, 44);
        [self.attrsArr addObject:layoutHeader];
        for (int i = 0; i < pSec; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:index];
            // 获取indexPath位置上cell对应的布局属性
            UICollectionViewLayoutAttributes * attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
            
            [self.attrsArr addObject:attrs];
        }
    }
}

/**
 * 返回indexPath位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 创建布局属性
    UICollectionViewLayoutAttributes * attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    // 设置布局属性的frame
    CGRect itemframe = [self.delegate waterFallLayout:self sizeForItemAtIndexPath:indexPath contentHeight:self.contentHeight];
    if (itemframe.size.height <=0 ||isnan(itemframe.size.height)) {
        NSLog(@"value is NaN");
    }
    self.contentHeight = CGRectGetMaxY(itemframe);
    attrs.frame = itemframe;
    return attrs;
}

/**
 * 决定cell的布局属性
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    return self.attrsArr;
}

/**
 * 内容的高度
 */
- (CGSize)collectionViewContentSize{
    return CGSizeMake(0, self.contentHeight);
}



@end
