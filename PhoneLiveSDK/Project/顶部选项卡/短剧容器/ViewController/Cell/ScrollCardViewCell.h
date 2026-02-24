//
//  ScrollCardViewCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/28.
//

#import <UIKit/UIKit.h>
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScrollCardViewCell : UICollectionViewCell
@property (nonatomic, copy) void (^tapIndex)(NSInteger);
- (void)update:(NSArray<HomeRecommendSkit*>*)models;
+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
