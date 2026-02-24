//
//  UIView+GYPop.m
//  GYbc
//
//  Created by wade on 03/08/2019.
//  Copyright © 2019 James. All rights reserved.
//

#import "UIView+GYPop.h"

@implementation UIView (GYPop)
UIView *contentView;
UIView *backgroundView;
CGFloat contentX;
CGFloat contentY;
CGFloat contentWidth;
CGFloat contentHeight;
CGFloat contentRadius;

- (void)gy_creatPopViewWithContentView:(UIView *)cView withContentViewFrame:(CGRect)cFrame andCornerRadius:(CGFloat)cRadius{
    if (contentView != nil) {
        return;
    }
    contentX = cFrame.origin.x;
    contentY = cFrame.origin.y;
    contentWidth = cFrame.size.width;
    contentHeight = cFrame.size.height;
    contentRadius = cRadius;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    backgroundView = [[UIView alloc] initWithFrame:window.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    [window addSubview:backgroundView];
    
    
    //点击手势
    UITapGestureRecognizer *tapDown = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gy_popViewdismiss)];
    tapDown.numberOfTapsRequired = 1;
    [backgroundView addGestureRecognizer:tapDown];
    
    contentView = cView;
    [window addSubview:contentView];
    contentView.frame = CGRectMake(contentX==0?(_window_width-contentWidth)/2:contentX, _window_height, contentWidth, contentHeight);
    if (cView.backgroundColor == nil) {
        contentView.backgroundColor = [UIColor whiteColor];
    } else {
        contentView.backgroundColor = cView.backgroundColor;
    }
    contentView.layer.cornerRadius = cRadius;
    contentView.clipsToBounds = YES;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        contentView.frame = CGRectMake(contentX==0?(_window_width-contentWidth)/2:contentX, contentY==0?(_window_height-contentHeight)/2- 8.f:contentY-8.f, contentWidth, contentHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            contentView.frame = CGRectMake(contentX==0?(_window_width-contentWidth)/2:contentX, contentY==0?(_window_height-contentHeight)/2:contentY, contentWidth, contentHeight);
        }];
    }];
    [UIView animateWithDuration:0.3 animations:^{
        backgroundView.backgroundColor = RGB_COLOR(@"#000000",0.6);
    } completion:^(BOOL finished) {
        
    }];    
    
}

- (void)gy_creatPopViewWithContentView:(UIView *)cView withContentViewFrame:(CGRect)cFrame {
    [self gy_creatPopViewWithContentView:cView withContentViewFrame:cFrame andCornerRadius:5.f];
}

- (void)gy_creatPopViewWithContentView:(UIView *)cView withContentViewSize:(CGSize)cSize {
    [self gy_creatPopViewWithContentView:cView withContentViewFrame:CGRectMake(0, 0, cSize.width, cSize.height) andCornerRadius:5.f];
}

//页面消失
-(void)gy_popViewdismiss {
    [UIView animateWithDuration:0.2 animations:^{
        backgroundView.backgroundColor = [UIColor clearColor];
        contentView.frame = CGRectMake(contentX==0?(_window_width-contentWidth)/2:contentX, _window_height, contentWidth, contentHeight);
    } completion:^(BOOL finished) {
        [contentView removeFromSuperview];
        [backgroundView removeFromSuperview];
        contentView = nil;
        backgroundView = nil;
    }];
}

@end
