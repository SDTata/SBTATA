//
//  LotteryOpenViewCell_LH.h
//  phonelive2
//
//  Created by lucas on 10/16/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_LH : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceTitle;

@property (weak, nonatomic) IBOutlet UILabel *issuLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;
@property (weak, nonatomic) IBOutlet UIImageView *leftImgV;
@property (weak, nonatomic) IBOutlet UIImageView *rigthImgV;
@property (nonatomic, strong) NSDictionary * model;
@property (weak, nonatomic) IBOutlet UILabel *leftPointLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightPointLabel;
@property (nonatomic, assign) BOOL isShowJustLast;
@property (nonatomic, assign) BOOL isFullscreen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1LeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1HorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rigthtLabTrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end

NS_ASSUME_NONNULL_END
