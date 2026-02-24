//
//  LobbyHistoryTimeView.h
//  phonelive2
//
//  Created by test on 2021/7/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LobbyHistoryTimeView : UIView
@property(nonatomic,strong)void(^completeHandler)(NSDate *startDate,NSString *startValue,NSDate *endDate,NSString *endValue);
@property(nonatomic,strong)void(^cancelHandler)(void);
+ (instancetype)instanceStateAlertWithStartTime:(NSDate *)start andEndTime:(NSDate *)end;
- (void)alertShowAnimationWithSuperView:(UIView *)superView;
@end

NS_ASSUME_NONNULL_END
