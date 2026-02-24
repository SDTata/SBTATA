//
//  ShowDropDownTextField.h
//  phonelive2
//
//  Created by s5346 on 2024/2/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ShowDropDownTextFieldDelegate <NSObject>

- (void)showDropDownTextFieldForSelected;

@end

@interface ShowDropDownTextField : UITextField
@property (nonatomic, strong) UILabel *errorLabel;
@property(nonatomic, assign) id<ShowDropDownTextFieldDelegate> dropDownDelegate;
@property(nonatomic, assign) BOOL isNeedShowDropDown;
@end

NS_ASSUME_NONNULL_END
