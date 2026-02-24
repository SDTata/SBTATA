#import <UIKit/UIKit.h>

typedef void (^CancelBlock)(void);
typedef void (^ConfirmBlock)(void);
typedef void (^ConfirmBlockWithTextField)(NSString *textFieldContent);

@interface CustomAlertView : UIView<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;

+ (CustomAlertView *)showAlertInView:(UIView *)parentView withTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(CancelBlock)cancelBlock confirmBlock:(ConfirmBlock)confirmBlock;

+ (CustomAlertView *)showAlertWithTextFieldInView:(UIView *)parentView withTitle:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle cancelBlock:(CancelBlock)cancelBlock confirmBlock:(ConfirmBlockWithTextField)confirmBlock;

- (void)dismiss;

- (void)showWithAnimation:(UIView*)parentView;
@end
