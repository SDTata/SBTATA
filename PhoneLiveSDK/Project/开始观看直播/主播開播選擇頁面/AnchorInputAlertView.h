//
//  AnchorInputAlertView.h
//  phonelive2
//
//  Created by vick on 2025/7/29.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnchorInputAlertView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, copy) void (^clickConfirmBlock)(NSString *text);

@end
