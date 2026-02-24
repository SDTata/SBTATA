#import "CustomAlertView.h"
#import "Masonry.h"
#import <objc/runtime.h>

@implementation CustomAlertView

+ (CustomAlertView *)showAlertInView:(UIView *)parentView withTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(CancelBlock)cancelBlock confirmBlock:(ConfirmBlock)confirmBlock {
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    alertView.layer.cornerRadius = 13;
    alertView.layer.masksToBounds = YES;
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelButton addTarget:alertView action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [confirmButton addTarget:alertView action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [alertView addSubview:titleLabel];
    [alertView addSubview:messageLabel];
    [alertView addSubview:cancelButton];
    [alertView addSubview:confirmButton];
    
    CGSize constraintSize = CGSizeMake(parentView.width*0.75, MAXFLOAT);
    CGRect textRect = [messageLabel.text boundingRectWithSize:constraintSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: messageLabel.font}
                                            context:nil];
    float heightCell = ceil(textRect.size.height);
    
    alertView.frame = CGRectMake((parentView.width - parentView.width*0.75)/2.0, (parentView.height-(144+heightCell))/2.0, parentView.width*0.75,(144+heightCell));
    
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(alertView).offset(20);
        make.left.equalTo(alertView).offset(20);
        make.right.equalTo(alertView).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    
    // 检查是否需要显示取消按钮
    BOOL shouldShowCancelButton = cancelTitle != nil && cancelTitle.length > 0;
    // 检查是否需要显示确认按钮
    BOOL shouldShowConfirmButton = confirmTitle != nil && confirmTitle.length > 0;
    
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        if (shouldShowConfirmButton) {
            make.left.equalTo(alertView).offset((alertView.width/4.0)-20);
        }else{
            make.left.equalTo(alertView).offset((alertView.width/2.0)-20);
        }
        
        make.top.equalTo(messageLabel.mas_bottom).offset(20);
    }];
    
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (shouldShowCancelButton) {
            make.right.equalTo(alertView).offset(-((alertView.width/4.0)-20));
        }else{
            make.right.equalTo(alertView).offset(-((alertView.width/2.0)-20));
        }
       
        make.top.equalTo(cancelButton);
        make.bottom.equalTo(alertView).offset(-20);  // This will set the height of the alertView
    }];
    

    objc_setAssociatedObject(alertView, "cancelBlock", cancelBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alertView, "confirmBlock", confirmBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [parentView addSubview:alertView];
    
    [alertView showWithAnimation:parentView];
    return alertView;
}

+ (CustomAlertView *)showAlertWithTextFieldInView:(UIView *)parentView withTitle:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(CancelBlock)cancelBlock confirmBlock:(ConfirmBlockWithTextField)confirmBlock {
    
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 13;
    alertView.layer.masksToBounds = YES;
    alertView.userInteractionEnabled = YES;
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.numberOfLines = 5;
//    titleLabel.adjustsFontSizeToFitWidth = YES;
//    titleLabel.minimumScaleFactor = 0.2;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont systemFontOfSize:15];
    textField.tag = 1000111l;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = placeholder;
    textField.delegate = alertView;
    alertView.textField = textField;

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton addTarget:alertView action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [confirmButton addTarget:alertView action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [alertView addSubview:titleLabel];
    [alertView addSubview:messageLabel];
    [alertView addSubview:textField];
    [alertView addSubview:cancelButton];
    [alertView addSubview:confirmButton];
    
    CGSize constraintSize = CGSizeMake(parentView.width*0.75, MAXFLOAT);
    CGRect textRect = [messageLabel.text boundingRectWithSize:constraintSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: messageLabel.font}
                                            context:nil];
    float heightCell = ceil(textRect.size.height);
    
    alertView.frame = CGRectMake((parentView.width - parentView.width*0.75)/2.0, (parentView.height-(144+heightCell))/2.0, parentView.width*0.75,(144+heightCell));
    
    // titleLabel的约束
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(alertView).offset(20);
        make.left.equalTo(alertView).offset(20);
        make.right.equalTo(alertView).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
    // messageLabel的约束
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    // textField的约束
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(10);
        make.left.right.equalTo(messageLabel);
        make.height.mas_equalTo(44);
    }];
    
    
    // cancelButton的约束
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.left.equalTo(alertView).offset(20);
        make.width.mas_equalTo((alertView.width - 60) / 2);  // 减去两边的margin和中间的间隔
        make.bottom.equalTo(alertView).offset(-20);  // 这将设置alertView的高度
    }];
    
    // confirmButton的约束
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).offset(20);
        make.right.equalTo(alertView).offset(-20);
        make.width.equalTo(cancelButton);
        make.bottom.equalTo(alertView).offset(-20);  // 这将设置alertView的高度
    }];
    
    objc_setAssociatedObject(alertView, "cancelBlock", cancelBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alertView, "confirmFieldBlock", confirmBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
  
    
    
    [alertView showWithAnimation:parentView];
    return alertView;
}

- (void)cancelAction:(UIButton *)sender {
    CancelBlock cancelBlock = objc_getAssociatedObject(self, "cancelBlock");
    if (cancelBlock) cancelBlock();
//    [self dismiss];
}

- (void)confirmAction:(UIButton *)sender {
    ConfirmBlock confirmBlock = objc_getAssociatedObject(self, "confirmBlock");
    ConfirmBlockWithTextField confirmBlockWithTextField = objc_getAssociatedObject(self, "confirmFieldBlock");
    UITextField *textF = [self viewWithTag:1000111l];
    if (confirmBlock) {
        confirmBlock();
    } else if (confirmBlockWithTextField && textF) {
        confirmBlockWithTextField(textF.text);
    }
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showWithAnimation:(UIView*)parentView{
    [parentView addSubview:self];
    self.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
        }];
    }

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;;
}

@end
