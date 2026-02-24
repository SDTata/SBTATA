//
//  LotteryHallBaseCell.h
//  phonelive2
//
//  Created by vick on 2024/1/16.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryBetModel.h"

@interface LotteryHallBaseCell : UIView

@property (nonatomic, strong) UIButton *backImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, copy) NSString *superKey;
@property (nonatomic, copy) NSString *key;

@property (nonatomic, strong) LotteryOptionModel *optionModel;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithKey:(NSString *)key superKey:(NSString *)superKey;

- (void)setupView;

- (void)showWinAnimation;

- (void)hideWinAnimation;

@end
