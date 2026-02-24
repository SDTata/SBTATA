//
//  VKSupportUtil.m
//  phonelive2
//
//  Created by vick on 2023/10/18.
//  Copyright © 2023 toby. All rights reserved.
//

#import "VKSupportUtil.h"



#import "FQLockGestureViewController.h"
#import "FQLockHelper.h"
#import "Config.h"
#if !TARGET_IPHONE_SIMULATOR

#import <RiskPerception/NTESRiskUniPerception.h>
#import <RiskPerception/NTESRiskUniConfiguration.h>

#endif
@implementation VKSupportUtil

+ (void)showGesturePassword {
  
    FQLockGestureViewController *vc = [[FQLockGestureViewController alloc] init];
    vc.lockType = [VKSupportUtil isLocalGestureEnableForUserId:[Config getOwnID]]?FQLockTypeReset:FQLockTypeSetting;
    vc.userID = [Config getOwnID];
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

+ (void)showLockGesture:(NSString *)uid type:(FQLockType)type isPush:(BOOL)isPush {
    UIWindow *mainwindows = [UIApplication sharedApplication].keyWindow;
    if (![mainwindows.rootViewController isKindOfClass:[FQLockGestureViewController class]] && ![mainwindows.rootViewController.presentedViewController isKindOfClass:[FQLockGestureViewController class]]) {
        
        if ([mainwindows.rootViewController isKindOfClass:[ZYTabBarController class]]) {
            FQLockGestureViewController *lockVC = [[FQLockGestureViewController alloc] init];
            lockVC.lockType = type;
            lockVC.userID = uid;
            lockVC.localLockBlock = ^(BOOL complete) {
                if (complete) {
                    [mainwindows.rootViewController dismissViewControllerAnimated:NO completion:^{
                        
                    }];
                }
            };
            lockVC.modalPresentationStyle = UIModalPresentationFullScreen;

            [mainwindows.rootViewController presentViewController:lockVC animated:NO completion:^{
                
            }];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [VKSupportUtil showLockGesture:uid type:type isPush:isPush];
            });
        }
                
                
    }
}

+ (BOOL)isLocalGestureEnableForUserId:(NSString *)uid {
    return [FQLockHelper isLocalGestureEnableForUserId:[Config getOwnID]];
}

+ (void)getNTESInit:(NSString *)channel pid:(NSString *)pid block:(void (^)(int, NSString *, NSString *))block {
#if !TARGET_IPHONE_SIMULATOR
    [NTESRiskUniConfiguration setChannel:channel];
    [[NTESRiskUniPerception fomentBevelDeadengo] init:pid callback:block];
#else
    if (block) {
        block(-1,@"",@"");
    }
#endif
    
}

+ (void)getNTESToken:(NSString *)token timeout:(NSInteger)timeout block:(void (^)(int, NSString *))block {
#if !TARGET_IPHONE_SIMULATOR
    [[NTESRiskUniPerception fomentBevelDeadengo] getTokenAsync:yidunToken withTimeout:3000 completeHandler:^(AntiCheatResult * _Nonnull result) {
        !block ?: block(result.code, result.token);
    }];
#else
    if (block) {
        block(-1,@"");
    }
#endif
    
    
}


@end


