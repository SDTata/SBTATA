//
//  FQLockHelper.h
//  PhoneLiveSDK
//
//  Created by wuwuFQ on 2022/9/27.
//  Updated on 2025/04/07.
//

#import <Foundation/Foundation.h>

@interface FQLockHelper : NSObject

///是否设置了手势密码
+ (BOOL)isLocalGestureEnableForUserId:(NSString*)userId;
///设置手势密码
+ (void)setLocalGestureEnable:(BOOL)isEnable forUserId:(NSString*)userId;

@end
