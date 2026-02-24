//
//  RotationNothingVC.m
//  phonelive2
//
//  Created by 400 on 2021/5/29.
//  Copyright © 2021 toby. All rights reserved.
//

#import "RotationNothingVC.h"

@interface RotationNothingVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantY;
@property (weak, nonatomic) IBOutlet UIImageView *resultNothingImgV;
@end

@implementation RotationNothingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.43471/2;
    self.view.backgroundColor = [UIColor clearColor];
    self.resultNothingImgV.image = [ImageBundle imagewithBundleName:YZMsg(@"RotationNothingVC_Nothing")];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.constantY.constant = SCREEN_HEIGHT/2  + SCREEN_HEIGHT*0.43471/2;
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

@end
