//
//  ScrollCardFlowLayout.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "ScrollCardFlowLayout.h"

@implementation ScrollCardFlowLayout {
    ScrollCardAttributesAnimator *_animator;
}

- (instancetype)initWithAnimator:(ScrollCardAttributesAnimator *)animator scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    self = [super init];
    if (self) {
        _animator = animator;
        self.scrollDirection = scrollDirection;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    [NSException raise:@"initWithCoder not implemented" format:@""];
    return nil;
}

+ (Class)layoutAttributesClass {
    return [ScrollCardFlowLayoutAttributes class];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray<UICollectionViewLayoutAttributes *> *transformedAttributes = [NSMutableArray array];

    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        ScrollCardFlowLayoutAttributes *copyAttribute = [attribute copy];
        [transformedAttributes addObject:[self transformLayoutAttributes:copyAttribute]];
    }

    return transformedAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (ScrollCardFlowLayoutAttributes *)transformLayoutAttributes:(ScrollCardFlowLayoutAttributes *)attributes {
    UICollectionView *collectionView = self.collectionView;
    if (!collectionView) {
        return attributes;
    }

    CGFloat distance;
    CGFloat itemOffset;

    distance = collectionView.frame.size.width;
    itemOffset = attributes.center.x - collectionView.contentOffset.x;
    attributes.startOffset = (attributes.frame.origin.x - collectionView.contentOffset.x) / attributes.frame.size.width;
    attributes.endOffset = (attributes.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.size.width) / attributes.frame.size.width;
    attributes.middleOffset = itemOffset / distance - 0.5;

    if (!attributes.contentView) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:attributes.indexPath];
        if (cell) {
            attributes.contentView = cell.contentView;
        }
    }

    [_animator animateWithCollectionView:collectionView attributes:attributes];

    return attributes;
}

@end
