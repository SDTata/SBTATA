//
//  PhoneLiveSDK.m
//  PhoneLiveSDK
//
//  Created by 400 on 2022/1/19.
//  Copyright © 2022 toby. All rights reserved.
//

#import "PhoneLiveSDK.h"
#import "LaunchInitManager.h"
#import "MXBADelegate.h"

#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif

@implementation PhoneLiveSDK
+ (UIWindow*)runAndLaunchPublicApp{
   
    DummySwiftUILoader *ddd = [[DummySwiftUILoader alloc]init];
    [ddd preload];
    
    
    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
    [[MXBADelegate sharedAppDelegate]initSDK];
    return [[LaunchInitManager sharedInstance] showAndStartLaunchProcess];
}

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return [[MXBADelegate sharedAppDelegate] application:app openURL:url options:options];
}

+(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    return [[MXBADelegate sharedAppDelegate] application:application supportedInterfaceOrientationsForWindow:window];
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    return [[MXBADelegate sharedAppDelegate] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}


@end
