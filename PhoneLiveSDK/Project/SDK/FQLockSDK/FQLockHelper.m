//
//  FQLockHelper.m
//  PhoneLiveSDK
//
//  Created by wuwuFQ on 2022/9/27.
//  Updated on 2025/04/07.
//

#import "FQLockHelper.h"

#define kLocalAuthPasswordKey @"FQ_LOCAL_AUTH_PASSWORD_KEY"
#define kLocalGesturePasswordKey @"FQ_LOCAL_GESTURE_PASSWORD_KEY"

@implementation FQLockHelper


///手势密码
+ (BOOL)isLocalGestureEnableForUserId:(NSString*)userId {
    if (!userId) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_%@", kLocalGesturePasswordKey, userId]];
}

+ (void)setLocalGestureEnable:(BOOL)isEnable forUserId:(NSString*)userId {
    if (!userId) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:isEnable forKey:[NSString stringWithFormat:@"%@_%@", kLocalGesturePasswordKey, userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
