//
//  PayPwdAlertView.h
//  phonelive2
//
//  Created by vick on 2024/8/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayPwdAlertView : UIView

@property (nonatomic, copy) void (^clickConfirmBlock)(NSString *text);

@end
