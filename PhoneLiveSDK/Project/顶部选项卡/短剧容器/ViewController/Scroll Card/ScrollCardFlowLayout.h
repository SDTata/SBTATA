//
//  ScrollCardFlowLayout.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <Foundation/Foundation.h>
#import "ScrollCardFlowLayoutAttributes.h"
#import "ScrollCardAttributesAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScrollCardFlowLayout : UICollectionViewFlowLayout

- (instancetype)initWithAnimator:(ScrollCardAttributesAnimator *)animator scrollDirection:(UICollectionViewScrollDirection)scrollDirection;

@end
NS_ASSUME_NONNULL_END
