//
//  LiveOpenListYFKSCell.h
//  phonelive2
//
//  Created by lucas on 10/7/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveOpenListYFKSCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *issuLab;
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UILabel *lab1;
@property (weak, nonatomic) IBOutlet UILabel *lab2;
@property (weak, nonatomic) IBOutlet UILabel *lab3;
@property (weak, nonatomic) IBOutlet UILabel *lab4;

@property (nonatomic, strong) lastResultModel * model;

@property (nonatomic, assign) BOOL isFullscreen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issuLabLeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1LeadiingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgV1HorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rigthtLabTrailingConstraint;
- (void)updateConstraintsForFullscreen;
@end

NS_ASSUME_NONNULL_END
