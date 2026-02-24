//
//  LotteryTimerView.h
//  phonelive2
//
//  Created by vick on 2023/12/12.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotteryTimerView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger time;

@property (nonatomic, copy) void (^timerChangingBlock)(LotteryTimerView *view, NSUInteger time);
@property (nonatomic, copy) void (^timerFinishBlock)(LotteryTimerView *view);

@end
