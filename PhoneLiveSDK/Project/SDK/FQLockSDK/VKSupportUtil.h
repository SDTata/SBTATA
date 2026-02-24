//
//  VKSupportUtil.h
//  phonelive2
//
//  Created by vick on 2023/10/19.
//  Copyright © 2023 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    FQLockTypeSetting = 1,   // 设置手势密码（默认）
    FQLockTypeClose,         // 关闭手势密码
    FQLockTypeLogin,         // 登录手势密码
    FQLockTypeReset,         // 重置密码
} FQLockType;


@interface VKSupportUtil : NSObject

/// 手势密码
+ (void)showGesturePassword;

/// 设置手势密码
+ (void)showLockGesture:(NSString *)uid type:(FQLockType)type isPush:(BOOL)isPush;

/// 是否设置过
+ (BOOL)isLocalGestureEnableForUserId:(NSString *)uid;

/// 易盾初始化
+ (void)getNTESInit:(NSString *)channel pid:(NSString *)pid block:(void(^)(int code, NSString *msg, NSString * content))block;

/// 获取易盾token
+ (void)getNTESToken:(NSString *)token timeout:(NSInteger)timeout block:(void(^)(int code, NSString *token))block;

@end
