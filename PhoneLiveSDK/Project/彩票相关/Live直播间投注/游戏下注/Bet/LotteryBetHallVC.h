//
//  LotteryBetHallVC.h
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotteryBetHallVC : UIViewController

@property (nonatomic, assign) NSInteger lotteryType;
@property (nonatomic, weak) id <lotteryBetViewDelegate> lotteryDelegate;
@property (nonatomic, assign) BOOL isFromVideo;

- (void)releaseView;

-(void)timeDelayUpdate:(long long)timeDelayNum;

@end
