//
//  LotteryCodeResultCell.h
//  phonelive2
//
//  Created by vick on 2023/12/7.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryCodeView_Base.h"
#import "LotteryBetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LotteryCodeResultCell : VKBaseTableViewCell

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) LotteryCodeView_Base *codeView;
@property (nonatomic, strong) LotteryResultModel *resultModel;

@end

NS_ASSUME_NONNULL_END
