//
//  TopTodayCell.h
//  phonelive
//
//  Created by 400 on 2020/7/28.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopTodayView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TopTodayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leveLabel;
@property (weak, nonatomic) IBOutlet SDAnimatedImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftNumLabel;

@property(nonatomic,strong)TopTodayModel *model;

- (void)updateIsFirst:(BOOL)isFirst;
@end

NS_ASSUME_NONNULL_END
