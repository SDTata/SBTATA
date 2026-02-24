//
//  HomeSectionKindCarouselContentViewCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendAdsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindCarouselContentViewCell : UICollectionViewCell

- (void)update:(HomeRecommendAds*)model;

@end

NS_ASSUME_NONNULL_END
