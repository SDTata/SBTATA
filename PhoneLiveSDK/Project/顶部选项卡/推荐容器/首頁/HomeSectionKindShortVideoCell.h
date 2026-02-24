//
//  HomeSectionKindShortVideoCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/26.
//

#import <UIKit/UIKit.h>
#import "HomeRecommendShortVideoModel.h"
#import "HomeSectionKindShortVideoContentViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HomeSectionKindShortVideoCellDelegate <NSObject>

- (void)homeSectionKindShortVideoCellDelegateForHotGotoShortVideo:(ShortVideoModel*)model;

@end

@interface HomeSectionKindShortVideoCell : UICollectionViewCell

@property (nonatomic, copy) void (^buttonActionBlock)(void);
@property (nonatomic, weak) id<HomeSectionKindShortVideoCellDelegate> delegate;

- (void)update:(HomeRecommendShortVideoModel*)model;
+(CGFloat)height;
+ (CGFloat)getCellWidth;

@end

NS_ASSUME_NONNULL_END
