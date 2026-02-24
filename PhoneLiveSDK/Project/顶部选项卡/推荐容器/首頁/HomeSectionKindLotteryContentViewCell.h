//
//  HomeSectionKindLotteryContentViewCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendLotteriesModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindLotteryContentViewCell : UICollectionViewCell

- (void)update:(HomeRecommendLotteries*)model;
+(CGFloat)ratio;
+(CGFloat)minimumLineSpacing;

@end

NS_ASSUME_NONNULL_END
