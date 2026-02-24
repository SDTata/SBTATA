//
//  RotationResultVC.m
//  phonelive2
//
//  Created by 400 on 2021/5/29.
//  Copyright © 2021 toby. All rights reserved.
//

#import "RotationResultVC.h"
#import "SDWebImage.h"
@interface RotationResultVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantY;

@property (weak, nonatomic) IBOutlet UIImageView *bgImgV;

@property (weak, nonatomic) IBOutlet UIImageView *contentImgV;

@property (weak, nonatomic) IBOutlet UILabel *contentlabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBth;

@end

@implementation RotationResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *imgBg = [ImageBundle imagewithBundleName:YZMsg(@"RotationResultVC_bgImgV")];
//    UIEdgeInsets insets = UIEdgeInsetsMake(imgBg.size.height/2.0,
//                                           0,
//                                           imgBg.size.height/2.0,
//                                           0);
//    imgBg = [imgBg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
//    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(120, 100, 40, 100)];
    self.bgImgV.image = imgBg;
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;
    self.view.backgroundColor = [UIColor clearColor];
    [self.contentImgV sd_setImageWithURL:[NSURL URLWithString:self.model.item_icon] placeholderImage:[ImageBundle imagewithBundleName:@"zjIcon"]];
    self.contentlabel.text = [NSString stringWithFormat:@"%@%@",YZMsg(@"RotationResultVC_ResultContent"),self.model.item_name];
    [self.confirmBth setImage:[ImageBundle imagewithBundleName:YZMsg(@"RotationNothingVC_Confirm")] forState:UIControlStateNormal];

    self.numLabel.hidden = true;
    if ([self.model.item_type isEqualToString:@"money"]) {
        NSString *coin = minstr(self.model.item_num);
        NSString *removeCommaCoin = [coin stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *currencyCoin = [YBToolClass getRateCurrency:removeCommaCoin showUnit:YES];
        self.numLabel.text = [NSString stringWithFormat:@"+%@", currencyCoin];
        self.numLabel.hidden = false;
    }

//    [self.contentImgV sd_setImageWithURL: placeholderImage:[ImageBundle imagewithBundleName:@"zjIcon"]];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.constant = 0;
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelDismiss];
}
-(void)cancelDismiss{
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;;
        self.view.backgroundColor = [UIColor clearColor];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
- (IBAction)cancelAction:(UIButton *)sender {
    [self cancelDismiss];
}
- (IBAction)sureAction:(id)sender {
    [self cancelDismiss];
}
@end
