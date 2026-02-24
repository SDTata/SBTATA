//
//  HomeSectionKindLongVideoCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendLongVideoModel.h"
#import "LongVideoCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindLongVideoCell : UICollectionViewCell

- (void)update:(HomeRecommendLongVideoModel*)model;
+(CGFloat)height;
+ (CGFloat)getCellWidth;
@end

NS_ASSUME_NONNULL_END
