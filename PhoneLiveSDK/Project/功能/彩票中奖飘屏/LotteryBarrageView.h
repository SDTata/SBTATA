//
//  LotteryBarrageView.h
//  phonelive
//
//  Created by 400 on 2020/7/31.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LotteryBarrageModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^Callback)(void);
@protocol LotteryBarrageDelegate <NSObject>
-(void)lotteryBarrageClick:(LotteryBarrageModel*)model;

@end


@interface LotteryBarrageView : UIView

+(LotteryBarrageView*)showInView:(UIView *)superView Model:(LotteryBarrageModel*)model complete:(Callback)callback delegate:(id)delegate;


@end

NS_ASSUME_NONNULL_END
