//
//  HomeSectionKindShortVideoContentViewCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/26.
//

#import <UIKit/UIKit.h>
#import "HomePayBaseViewCell.h"
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindShortVideoContentViewCell : HomePayBaseViewCell

- (void)update:(ShortVideoModel*)model;
- (void)updateForOtherUserMsg:(ShortVideoModel*)model;
- (void)updateForLikeView:(ShortVideoModel*)model;
+(CGFloat)ratio;
+(CGFloat)minimumLineSpacing;

@end

NS_ASSUME_NONNULL_END
