//
//  LotteryOpenViewCell_ZJH.h
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_ZJH : UICollectionViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceTitle;

@property (weak, nonatomic) IBOutlet UILabel *issuLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;
@property (weak, nonatomic) IBOutlet UILabel *resultLab;
@property (weak, nonatomic) IBOutlet UIImageView *imgV1;
@property (weak, nonatomic) IBOutlet UIImageView *imgV2;
@property (weak, nonatomic) IBOutlet UIImageView *imgV3;
@property (weak, nonatomic) IBOutlet UIImageView *labBg;
@property (nonatomic, strong) NSDictionary * model;
@property (nonatomic, assign) BOOL isShowJustLast;
@property (nonatomic, assign) BOOL isFullscreen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1LeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1HorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rigthtLabTrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end

NS_ASSUME_NONNULL_END
