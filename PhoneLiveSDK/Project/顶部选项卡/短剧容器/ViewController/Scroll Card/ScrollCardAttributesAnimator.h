//
//  ScrollCardAttributesAnimator.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <Foundation/Foundation.h>
#import "ScrollCardFlowLayoutAttributes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScrollCardAttributesAnimator : NSObject

- (instancetype)initWithScaleRate:(CGFloat)scaleRate itemSpacingRate:(CGFloat)itemSpacingRate;
- (void)animateWithCollectionView:(UICollectionView *)collectionView attributes:(ScrollCardFlowLayoutAttributes *)attributes;


@end

NS_ASSUME_NONNULL_END
