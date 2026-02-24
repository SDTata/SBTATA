//
//  UINavModalWebView.m
//  WebViewChatWindow
//
//  Created by Allon on 10/14/16.
//  Copyright © 2016 Allon. All rights reserved.
//

#import "UINavModalWebView.h"

@interface UINavModalWebView ()

@end

@implementation UINavModalWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    if(self.presentedViewController){
        WeakSelf
        [super dismissViewControllerAnimated:flag completion:^(void){
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSLog(@"%@", strongSelf.presentedViewController);
            completion();
            NSLog(@"%@", strongSelf.presentedViewController);
        }];
    }
}

-(void) presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    if (super.presentedViewController == nil) {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
