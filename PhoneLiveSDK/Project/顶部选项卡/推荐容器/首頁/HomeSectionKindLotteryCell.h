//
//  HomeSectionKindLotteryCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendLotteriesModel.h"
#import "HomeSectionKindLotteryContentViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindLotteryCell : UICollectionViewCell

- (void)update:(HomeRecommendLotteriesModel*)model;
+(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
