//
//  HomeSectionKindLiveStreamingContentViewCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindLiveStreamingContentViewCell : UICollectionViewCell

- (void)update:(hotModel*)model;
+(CGFloat)ratio;
+(CGFloat)minimumLineSpacing;

@end

NS_ASSUME_NONNULL_END
