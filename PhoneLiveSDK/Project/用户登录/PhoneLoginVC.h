#import "VideoViewController.h"
#import "ShowDropDownTextField.h"
#import <IQKeyboardManager.h>

@interface PhoneLoginVC : VideoViewController

@property (weak, nonatomic) IBOutlet ShowDropDownTextField *phoneT;
@property (weak, nonatomic) IBOutlet UITextField *passWordT;
@property (weak, nonatomic) IBOutlet UIButton *doLoginBtn;
//@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UIButton *yanzhengmaBtn;

- (IBAction)mobileLogin:(id)sender;
//- (IBAction)regist:(id)sender;
//- (IBAction)forgetPass:(id)sender;
//- (IBAction)clickBackBtn:(UIButton *)sender;

-(void)autoLoginWithPhoneNum:(nullable NSString*)phoneNum codeNum:(nullable NSString*)codeNum;

@end
