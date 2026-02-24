//
//  HomeSectionKindSkitContentViewCell.h
//  NewDrama
//
//  Created by s5346 on 2024/7/2.
//

#import <UIKit/UIKit.h>
#import "HomePayBaseViewCell.h"
#import "HomeRecommendSkitModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindSkitContentViewCell : HomePayBaseViewCell

- (void)update:(HomeRecommendSkit*)model;
+(CGFloat)ratio;
+(CGFloat)minimumLineSpacing;

@end

NS_ASSUME_NONNULL_END
