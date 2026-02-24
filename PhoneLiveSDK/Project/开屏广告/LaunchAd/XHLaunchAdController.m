//
//  XHLaunchAdController.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2017/5/26.
//  Copyright © 2017年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd

#import "XHLaunchAdController.h"
#import "XHLaunchAdConst.h"

@interface XHLaunchAdController ()

@end

@implementation XHLaunchAdController

-(BOOL)shouldAutorotate{
    
    return NO;
}

-(BOOL)prefersHomeIndicatorAutoHidden{
    
    return XHLaunchAdPrefersHomeIndicatorAutoHidden;
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
    
}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//
//}
@end
