//
//  LotteryCustomChipView.h
//  phonelive2
//
//  Created by vick on 2024/12/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotteryCustomChipView : UIView

@property (nonatomic, copy) void (^clickConfirmBlock)(double amount);

@end
