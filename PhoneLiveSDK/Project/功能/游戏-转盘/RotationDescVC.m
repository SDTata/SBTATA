//
//  RotationDescVC.m
//  phonelive2
//
//  Created by 400 on 2021/5/26.
//  Copyright © 2021 toby. All rights reserved.
//

#import "RotationDescVC.h"

@interface RotationDescVC ()
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantY;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgV;

@end

@implementation RotationDescVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *imgBg = [ImageBundle imagewithBundleName:YZMsg(@"RotationDescVC_ImgBg")];
    imgBg = [imgBg resizableImageWithCapInsets:UIEdgeInsetsMake(100, 30, 40, 30)];
    self.bgImgV.image = imgBg;
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;
    self.view.backgroundColor = [UIColor clearColor];
    NSAttributedString * attStr = [[NSAttributedString alloc] initWithData:[self.ruleStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    self.contentTextView.attributedText = attStr;
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
    [UIView animateWithDuration:0.3 animations:^{
        self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.703636/2;;
        self.view.backgroundColor = [UIColor clearColor];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

//
//    self.textview.attributedText = attStr;
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
