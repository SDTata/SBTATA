//
//  LotteryWayTableViewCell.h
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotteryWayTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titile;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

-(void)setZero;
@end
