//
//  PhoneLiveSDK.h
//  PhoneLiveSDK
//
//  Created by  on 2022/1/19.
//  Copyright © 2022 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
//! Project version number for PLSDK.
FOUNDATION_EXPORT double PLSDKVersionNumber;

//! Project version string for PLSDK.
FOUNDATION_EXPORT const unsigned char PLSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PLSDK/PublicHeader.h>



@interface PhoneLiveSDK : NSObject
+ (UIWindow*)runAndLaunchPublicApp;

+ (BOOL)application:(UIApplication *_Nullable)app openURL:(NSURL *_Nullable)url options:(NSDictionary<NSString*, id> *_Nullable)options;

+(UIInterfaceOrientationMask)application:(UIApplication *_Nullable)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

+ (BOOL)application:(UIApplication *_Nullable)application continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;

@end
