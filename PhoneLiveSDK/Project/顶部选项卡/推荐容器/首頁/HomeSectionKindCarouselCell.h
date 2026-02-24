//
//  HomeSectionKindCarouselCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendAdsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindCarouselCell : UICollectionViewCell

- (void)update:(HomeRecommendAdsModel*)model;
+(CGFloat)height;
- (void)stopAutoScroll;
- (void)startAutoScroll;
@end

@interface CustomFlowLayout : UICollectionViewFlowLayout
@end

NS_ASSUME_NONNULL_END
