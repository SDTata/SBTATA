//
//  LotteryOpenViewCell_NN_Fullscreen.h
//  
//
//  Created by user on 2023/12/6.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_NN_Fullscreen : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *issueLab;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWinTrailingConstraint;
@property (nonatomic, strong) lastResultModel * model;
- (void)updateConstraintsForLastResultCollection;
@end

NS_ASSUME_NONNULL_END
