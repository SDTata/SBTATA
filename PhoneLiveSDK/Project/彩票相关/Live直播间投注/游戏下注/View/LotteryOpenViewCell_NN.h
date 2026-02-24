//
//  LotteryBetViewCell_NN.h
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_NN : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *issuLab;
@property (weak, nonatomic) IBOutlet UIImageView *blue1;
@property (weak, nonatomic) IBOutlet UIImageView *blue2;
@property (weak, nonatomic) IBOutlet UIImageView *blue3;
@property (weak, nonatomic) IBOutlet UIImageView *blue4;
@property (weak, nonatomic) IBOutlet UIImageView *blue5;
@property (weak, nonatomic) IBOutlet UIImageView *red1;
@property (weak, nonatomic) IBOutlet UIImageView *red2;
@property (weak, nonatomic) IBOutlet UIImageView *red3;
@property (weak, nonatomic) IBOutlet UIImageView *red4;
@property (weak, nonatomic) IBOutlet UIImageView *red5;
@property (weak, nonatomic) IBOutlet UIButton *leftWinMask;
@property (weak, nonatomic) IBOutlet UIButton *rightWinMask;
@property (weak, nonatomic) IBOutlet UILabel *leftNLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNNLabel;
@property (nonatomic, strong) lastResultModel * model;

@property (weak, nonatomic) IBOutlet UIImageView *blueOpenBg;
@property (weak, nonatomic) IBOutlet UIImageView *redOpenBg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWinWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWinTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWinLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWinWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWinTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWinTrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end

NS_ASSUME_NONNULL_END
