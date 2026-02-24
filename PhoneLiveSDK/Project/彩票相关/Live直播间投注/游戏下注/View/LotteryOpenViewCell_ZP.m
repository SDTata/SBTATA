//
//  LotteryOpenViewCell_ZP.m
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryOpenViewCell_ZP.h"

@implementation LotteryOpenViewCell_ZP

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.rigthtLab.layer.cornerRadius = 11;
    self.rigthtLab.layer.masksToBounds = YES;
}
- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 70;
    self.rigthtLabTrailingConstraint.constant = 100;
}
@end
