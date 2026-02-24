//
//  ScrollCardAttributesAnimator.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "ScrollCardAttributesAnimator.h"

@implementation ScrollCardAttributesAnimator {
    CGFloat _itemSpacingRate;
    CGFloat _scaleRate;
}

- (instancetype)initWithScaleRate:(CGFloat)scaleRate itemSpacingRate:(CGFloat)itemSpacingRate {
    self = [super init];
    if (self) {
        _scaleRate = scaleRate;
        _itemSpacingRate = itemSpacingRate;
    }
    return self;
}

- (void)animateWithCollectionView:(UICollectionView *)collectionView attributes:(ScrollCardFlowLayoutAttributes *)attributes {
    CGFloat position = attributes.middleOffset;
    CGFloat scaleFactor = 1 - _scaleRate * fabs(position);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);

    CGFloat width = collectionView.frame.size.width;
    CGFloat translationX = width * _itemSpacingRate * position;
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(translationX, 0);

    attributes.transform = CGAffineTransformConcat(translationTransform, scaleTransform);
}

@end
