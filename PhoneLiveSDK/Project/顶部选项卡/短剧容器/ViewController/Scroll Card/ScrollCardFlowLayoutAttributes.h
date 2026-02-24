//
//  ScrollCardFlowLayoutAttributes.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollCardFlowLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGFloat startOffset;
@property (nonatomic, assign) CGFloat middleOffset;
@property (nonatomic, assign) CGFloat endOffset;

@end

NS_ASSUME_NONNULL_END
