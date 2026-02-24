//
//  KingSalaryCell.h
//  phonelive2
//
//  Created by s5346 on 2024/8/23.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KingSalaryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KingSalaryCell : UICollectionViewCell

- (void)update:(SalaryLevelItem*)model;

@end

NS_ASSUME_NONNULL_END
