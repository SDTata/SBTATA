//
//  CaptchaConfig.h
//  c601PLAY
//
//  Created by s5346 on 2025/10/1.
//  Copyright © 2025 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 网易易盾验证码配置
@interface CaptchaConfig : NSObject

/// 验证码ID - 从网易易盾控制台获取
/// 产品编号: YD00508721626876
/// 申请地址：https://dun.163.com/
@property (class, nonatomic, readonly) NSString *captchaId;

/// 验证码模式
/// 1: 滑动拼图验证码
/// 2: 点击验证码
/// 3: 短信验证码
/// 4: 语音验证码
@property (class, nonatomic, readonly) NSInteger captchaMode;

/// 验证码语言（默认值，用于兜底）
/// 支持：zh-CN(简体)、zh-TW(繁体)、en、ja、vi、id 等
@property (class, nonatomic, readonly) NSString *defaultCaptchaLanguage;

/// 验证码超时时间（毫秒）
@property (class, nonatomic, readonly) NSInteger captchaTimeout;

/// 是否启用debug模式 (生产环境应设为false)
@property (class, nonatomic, readonly) BOOL isDebugMode;

/// 产品编号
@property (class, nonatomic, readonly) NSString *productId;

/// 验证码失败最大重试次数
@property (class, nonatomic, readonly) NSInteger maxRetryCount;

/// 是否允许点击外部关闭验证码
@property (class, nonatomic, readonly) BOOL touchOutsideDisappear;

/// 是否启用降级模式（当验证码插件出现问题时跳过验证）
/// 仅在调试模式下生效，生产环境请设为false
@property (class, nonatomic, readonly) BOOL enableFallbackMode;

/// 获取当前语言对应的验证码语言代码（适配项目中的多语言）
/// - 简体中文: zh-CN
/// - 繁体中文: zh-TW
/// - 英文: en
/// - 日文: ja
/// - 越南文: vi
/// - （可选）印尼文: id
+ (NSString *)getCurrentLanguage;

/// 检查验证码配置是否有效
+ (BOOL)isConfigValid;

/// 获取配置错误提示信息
+ (NSString *)getConfigErrorMessage;

@end

NS_ASSUME_NONNULL_END
