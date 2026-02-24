//
//  ChipSwitchViewController.h
//

#import <UIKit/UIKit.h>
typedef void (^ChipType)(NSInteger idx, NSUInteger num);

@interface ChipSwitchViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *chip1Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip1Label;
@property (weak, nonatomic) IBOutlet UIButton *chip2Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip2Label;
@property (weak, nonatomic) IBOutlet UIButton *chip3Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip3Label;
@property (weak, nonatomic) IBOutlet UIButton *chip4Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip4Label;
@property (weak, nonatomic) IBOutlet UIButton *chip5Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip5Label;
@property (weak, nonatomic) IBOutlet UIButton *chip6Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip6Label;
@property (weak, nonatomic) IBOutlet UIButton *chip7Btn;
@property (weak, nonatomic) IBOutlet UILabel *chip7Label;
@property (weak, nonatomic) IBOutlet UILabel *chip8Label;
@property (weak, nonatomic) IBOutlet UIButton *chipCustomBtn;
@property (weak, nonatomic) IBOutlet UIButton *chipConfirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *curSelectLabel;



@property (nonatomic,copy) ChipType block;
@end

