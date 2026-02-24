//
//  DailyCheckInCell.h
//  phonelive2
//
//  Created by s5346 on 2024/8/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBonusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DailyCheckInCell : UICollectionViewCell

- (void)update:(UserBonusItemModel*)model countDay:(int)countDay;

@end

NS_ASSUME_NONNULL_END
