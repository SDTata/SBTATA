//
//  CaptchaManager.h
//  phonelive2
//
//  Created by s5346 on 2025/10/1.
//  Copyright © 2025 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 验证码验证成功回调
/// @param validate 验证码验证结果
/// @param msg 验证消息
typedef void(^CaptchaSuccessBlock)(NSString *validate, NSString *msg);

/// 验证码验证失败回调
/// @param errorMsg 错误信息
typedef void(^CaptchaErrorBlock)(NSString *errorMsg);

/// 验证码取消回调
typedef void(^CaptchaCancelBlock)(void);

/// 验证码管理器
/// 封装网易易盾验证码插件的使用
@interface CaptchaManager : NSObject

/// 单例对象
+ (instancetype)sharedInstance;

/// 显示验证码
/// @param viewController 当前视图控制器
/// @param onSuccess 验证成功回调
/// @param onError 验证失败回调
/// @param onCancel 用户取消回调（可选）
+ (void)showCaptchaWithViewController:(UIViewController *)viewController
                            onSuccess:(CaptchaSuccessBlock)onSuccess
                              onError:(CaptchaErrorBlock)onError
                             onCancel:(nullable CaptchaCancelBlock)onCancel;

/// 验证验证码结果
/// @param validate 验证码验证结果
/// @param msg 验证消息
/// @return 是否验证成功
+ (BOOL)validateCaptchaResult:(NSString *)validate msg:(NSString *)msg;

/// 检查验证码插件是否已初始化
+ (BOOL)isInitialized;

/// 重置验证码插件状态（用于调试或重新初始化）
+ (void)reset;

/// 获取验证码错误信息的本地化文本
/// @param errorMsg 错误信息
/// @return 本地化的错误提示
+ (NSString *)getLocalizedErrorMessage:(NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END
