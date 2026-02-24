//
//  HANKCollectionViewCell.h
//  phonelive2
//
//  Created by user on 2023/11/13.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BetOptionCollectionViewCell_Fullscreen : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rate;
@property (weak, nonatomic) IBOutlet UIButton *tipBtn;
@property (nonatomic, weak) NSString *way;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage1;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage2;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImage3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rateTopToTitleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rateTopToImage3Constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rateCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img3CenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img1WidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img2WidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img3WidthConstraint;
- (void)setImage;
@end

NS_ASSUME_NONNULL_END
