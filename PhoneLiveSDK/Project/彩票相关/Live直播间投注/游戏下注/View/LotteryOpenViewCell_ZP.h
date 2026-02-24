//
//  LotteryOpenViewCell_ZP.h
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_ZP : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *rigthtLab;
@property (weak, nonatomic) IBOutlet UILabel *issuLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rigthtLabTrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end

NS_ASSUME_NONNULL_END
