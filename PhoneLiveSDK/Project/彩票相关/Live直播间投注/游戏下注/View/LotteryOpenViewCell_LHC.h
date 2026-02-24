//
//  LotteryOpenViewCell_LHC.h
//  c700LIVE
//
//  Created by lucas on 10/17/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryNNModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LotteryOpenViewCell_LHC : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *issueLab;
@property (weak, nonatomic) IBOutlet UIButton *btnTe;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIButton *btn5;
@property (weak, nonatomic) IBOutlet UIButton *btn6;


@property (weak, nonatomic) IBOutlet UILabel *shulab;
@property (weak, nonatomic) IBOutlet UILabel *seLab;
@property (weak, nonatomic) IBOutlet UILabel *danLab;
@property (weak, nonatomic) IBOutlet UILabel *bigLab;
@property (weak, nonatomic) IBOutlet UILabel *blueLab;
@property (nonatomic, strong) lastResultModel * model;

@end

NS_ASSUME_NONNULL_END
