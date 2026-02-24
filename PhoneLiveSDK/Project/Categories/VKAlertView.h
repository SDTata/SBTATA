//
//  VKAlertView.h
//  phonelive2
//
//  Created by vick on 2024/9/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKAlertView : UIView

@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIStackView *centerStackView;
@property (nonatomic, strong) UIStackView *buttonStackView;

@property (nonatomic, copy) void (^cancelActionBlock)(void);
@property (nonatomic, copy) void (^confirmActionBlock)(void);

+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)message
          cancelAction:(NSString *)cancelAction
         confirmAction:(NSString *)confirmAction
           cancelBlock:(void(^)(void))cancelBlock
          confirmBlock:(void(^)(void))confirmBlock;

@end
