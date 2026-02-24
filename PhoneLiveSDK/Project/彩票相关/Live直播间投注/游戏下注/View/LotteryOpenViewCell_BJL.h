//
//  LotteryOpenViewCell_BJL.h
//  phonelive2
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_BJL : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceTitle;

@property (weak, nonatomic) IBOutlet UILabel *issueLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;
@property (weak, nonatomic) IBOutlet UILabel *idleLab;
@property (weak, nonatomic) IBOutlet UIImageView *blue1;
@property (weak, nonatomic) IBOutlet UIImageView *blue2;
@property (weak, nonatomic) IBOutlet UIImageView *blue3;
@property (weak, nonatomic) IBOutlet UIImageView *red1;
@property (weak, nonatomic) IBOutlet UIImageView *red2;
@property (weak, nonatomic) IBOutlet UIImageView *red3;
@property (weak, nonatomic) IBOutlet UILabel *aLab;
@property (nonatomic, strong) lastResultModel * model;
@property (nonatomic, assign) BOOL isShowJustLast;
@property (nonatomic, assign) BOOL isFullscreen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1LeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1HorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rigthtLabTrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end

NS_ASSUME_NONNULL_END
