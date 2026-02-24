//
//  HomeSectionKindLiveStreamingCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendLiveModel.h"
#import "HotCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindLiveStreamingCell : UICollectionViewCell

- (void)update:(HomeRecommendLiveModel*)model;
+(CGFloat)height;
+ (CGFloat)getCellWidth;

@end

NS_ASSUME_NONNULL_END
