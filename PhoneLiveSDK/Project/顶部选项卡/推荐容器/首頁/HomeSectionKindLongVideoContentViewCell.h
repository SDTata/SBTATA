//
//  HomeSectionKindLongVideoContentViewCell.h
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import <UIKit/UIKit.h>
#import "HomePayBaseViewCell.h"
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeSectionKindLongVideoContentViewCell : HomePayBaseViewCell

- (void)update:(ShortVideoModel*)model;

@end

NS_ASSUME_NONNULL_END
