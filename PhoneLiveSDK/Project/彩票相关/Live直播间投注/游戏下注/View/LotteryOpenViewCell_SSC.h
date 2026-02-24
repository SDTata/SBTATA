//
//  LotteryOpenViewCell_SSC.h
//  c700LIVE
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"


@interface LotteryOpenViewCell_SSC : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *issuLab;
@property (weak, nonatomic) IBOutlet UILabel *lab1;
@property (weak, nonatomic) IBOutlet UILabel *lab2;
@property (weak, nonatomic) IBOutlet UILabel *lab3;
@property (weak, nonatomic) IBOutlet UILabel *lab4;
@property (weak, nonatomic) IBOutlet UILabel *lab5;
@property (weak, nonatomic) IBOutlet UILabel *danLab;
@property (weak, nonatomic) IBOutlet UILabel *xiaoLab;
@property (weak, nonatomic) IBOutlet UILabel *sumLab;
@property (weak, nonatomic) IBOutlet UILabel *longLab;


@property (nonatomic, strong) lastResultModel * model;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImg1TrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightImg2TrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end
