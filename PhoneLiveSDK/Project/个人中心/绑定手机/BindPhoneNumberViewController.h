//
//  BindPhoneNumberViewController.h
//  phonelive2
//
//  Created by lucas on 2021/4/19.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowDropDownTextField.h"
#import <IQKeyboardManager.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, BindingType) {
    BindingTypeForPhone,
    BindingTypeForEmail,
};

@interface BindPhoneNumberViewController : UIViewController
@property (weak, nonatomic) IBOutlet ShowDropDownTextField *phoneT;
@property (weak, nonatomic) IBOutlet UITextField *passWordT;
@property (weak, nonatomic) IBOutlet UIButton *yanzhengmaBtn;
@property (weak, nonatomic) IBOutlet UIButton *RechargeBtn;
@property (assign, nonatomic) BindingType bindingType;

@end

NS_ASSUME_NONNULL_END
