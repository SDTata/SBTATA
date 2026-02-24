//
//  ScrollCardItemCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/8.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScrollCardItemCell : UICollectionViewCell

- (void)update:(HomeRecommendSkit*)model;
@end

NS_ASSUME_NONNULL_END
