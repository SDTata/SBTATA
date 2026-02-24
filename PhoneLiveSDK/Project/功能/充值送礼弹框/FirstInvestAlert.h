//
//  FirstInvestAlert.h
//  phonelive2
//
//  Created by test on 2021/6/11.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LivePlayNOScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FirstInvestAlert : LivePlayNOScrollView
+ (instancetype)instanceNotificationAlertWithMessages;
- (void)alertShowAnimationWithSuperView:(UIView *)superView;
-(void)dismissView;
@end

NS_ASSUME_NONNULL_END
