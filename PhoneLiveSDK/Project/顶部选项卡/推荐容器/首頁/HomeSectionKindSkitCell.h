//
//  HomeSectionKindSkitCell.h
//  NewDrama
//
//  Created by s5346 on 2024/7/2.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendSkitModel.h"
#import "HomeSectionKindSkitContentViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindSkitCell : UICollectionViewCell

- (void)update:(HomeRecommendSkitModel*)model;
+(CGFloat)height;
+ (CGFloat)getCellWidth;

@end

NS_ASSUME_NONNULL_END
