//
//  HotCollectionViewCell.h
//  yunbaolive
//
//  Created by Boom on 2018/9/21.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HotCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *liveTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *numsLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lotteryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lotteryImageView;
@property (nonatomic,assign) BOOL isNear;
@property (weak, nonatomic) IBOutlet UIImageView *numImgView;
@property (weak, nonatomic) IBOutlet UIButton *btn_redBag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jianju1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jianju2;
@property (weak, nonatomic) IBOutlet UIImageView *regionImgV;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;

@property (nonatomic,strong)hotModel *model;
//@property (nonatomic,strong)NearbyVideoModel *videoModel;

+(CGFloat)ratio;
+(CGFloat)minimumLineSpacing;

@end

NS_ASSUME_NONNULL_END
