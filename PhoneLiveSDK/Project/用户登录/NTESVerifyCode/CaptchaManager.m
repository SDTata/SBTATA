//
//  CaptchaManager.m
//  phonelive2
//
//  Created by s5346 on 2025/10/1.
//  Copyright © 2025 toby. All rights reserved.
//

#import "CaptchaManager.h"
#import "CaptchaConfig.h"
#import <VerifyCode/NTESVerifyCodeManager.h>

@interface CaptchaManager () <NTESVerifyCodeManagerDelegate>

@property (nonatomic, strong) NTESVerifyCodeManager *verifyCodeManager;
@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, copy, nullable) NSString *initializedLang;
@property (nonatomic, copy, nullable) CaptchaSuccessBlock successBlock;
@property (nonatomic, copy, nullable) CaptchaErrorBlock errorBlock;
@property (nonatomic, copy, nullable) CaptchaCancelBlock cancelBlock;
@property (nonatomic, assign) BOOL successCalled;
@property (nonatomic, assign) BOOL errorCalled;

@end

@implementation CaptchaManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static CaptchaManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isInitialized = NO;
        _initializedLang = nil;
        _successCalled = NO;
        _errorCalled = NO;
    }
    return self;
}

#pragma mark - Private Methods

/// 初始化验证码插件
- (void)initCaptcha {
    NSString *lang = [CaptchaConfig getCurrentLanguage];

    // 如果已初始化且语言未变更，则直接返回
    if (self.isInitialized && [self.initializedLang isEqualToString:lang]) {
        return;
    }

    // 检查配置是否有效
    if (![CaptchaConfig isConfigValid]) {
        NSString *errorMsg = [CaptchaConfig getConfigErrorMessage];
        NSLog(@"billDebug 验证码配置无效: %@", errorMsg);
        @throw [NSException exceptionWithName:@"CaptchaConfigException"
                                       reason:errorMsg
                                     userInfo:nil];
    }

    NSLog(@"billDebug ========== 初始化验证码插件 ==========");
    NSLog(@"billDebug 验证码ID: %@", [CaptchaConfig captchaId]);
    NSLog(@"billDebug 产品编号: %@", [CaptchaConfig productId]);
    NSLog(@"billDebug Debug模式: %@", [CaptchaConfig isDebugMode] ? @"YES" : @"NO");
    NSLog(@"billDebug 超时时间: %ldms", (long)[CaptchaConfig captchaTimeout]);
    NSLog(@"billDebug 验证码语言: %@", lang);

    // 初始化验证码管理器
    self.verifyCodeManager = [NTESVerifyCodeManager getInstance];
    self.verifyCodeManager.delegate = self;

    // 设置语言（必须在配置之前设置）
    self.verifyCodeManager.lang = [self convertLanguageToNTESType:lang];

    // 配置验证码参数
    NSTimeInterval timeout = [CaptchaConfig captchaTimeout] / 1000.0; // 转换为秒
    [self.verifyCodeManager configureVerifyCode:[CaptchaConfig captchaId] timeout:timeout];

    // 设置其他属性
    self.verifyCodeManager.shouldCloseByTouchBackground = [CaptchaConfig touchOutsideDisappear];
    self.verifyCodeManager.alpha = 0.8;
    self.verifyCodeManager.extraData = [NSString stringWithFormat:@"Live_iOS_Login_%@", [CaptchaConfig productId]];

    // 设置降级开关
    self.verifyCodeManager.openFallBack = [CaptchaConfig enableFallbackMode];
    self.verifyCodeManager.fallBackCount = [CaptchaConfig maxRetryCount];

    // 开启日志（仅在Debug模式下）
    if ([CaptchaConfig isDebugMode]) {
        [self.verifyCodeManager enableLog:YES];
    }

    self.isInitialized = YES;
    self.initializedLang = lang;

    NSLog(@"billDebug 验证码插件初始化成功");
}

/// 转换语言代码为 NTESVerifyCode 的语言类型
- (NTESVerifyCodeLang)convertLanguageToNTESType:(NSString *)lang {
    if ([lang isEqualToString:@"zh-CN"]) {
        return NTESVerifyCodeLangCN;
    } else if ([lang isEqualToString:@"zh-TW"]) {
        return NTESVerifyCodeLangTW;
    } else if ([lang isEqualToString:@"en-US"] || [lang isEqualToString:@"en"]) {
        return NTESVerifyCodeLangENUS;
    } else if ([lang isEqualToString:@"ja-JP"] || [lang isEqualToString:@"ja"]) {
        return NTESVerifyCodeLangJP;
    } else if ([lang isEqualToString:@"vi-VN"] || [lang isEqualToString:@"vi"]) {
        return NTESVerifyCodeLangVT;
    } else if ([lang isEqualToString:@"id-ID"] || [lang isEqualToString:@"id"]) {
        return NTESVerifyCodeLangID;
    }
    return NTESVerifyCodeLangENUS; // 默认英文
}

#pragma mark - Public Methods

/// 显示验证码
+ (void)showCaptchaWithViewController:(UIViewController *)viewController
                            onSuccess:(CaptchaSuccessBlock)onSuccess
                              onError:(CaptchaErrorBlock)onError
                             onCancel:(nullable CaptchaCancelBlock)onCancel {
    CaptchaManager *manager = [CaptchaManager sharedInstance];

    // 重置回调标记
    manager.successCalled = NO;
    manager.errorCalled = NO;

    // 保存回调
    manager.successBlock = onSuccess;
    manager.errorBlock = onError;
    manager.cancelBlock = onCancel;

    @try {
        // 确保插件已初始化
        [manager initCaptcha];

        NSLog(@"billDebug ========== 开始显示验证码 ==========");
        // 显示验证码
        [manager.verifyCodeManager openVerifyCodeView];

    } @catch (NSException *exception) {
        NSLog(@"billDebug 显示验证码时发生错误: %@", exception.reason);

        // 检查是否启用降级模式
        if ([CaptchaConfig isDebugMode] && [CaptchaConfig enableFallbackMode]) {
            NSLog(@"billDebug 启用降级模式：跳过验证码验证");
            // 生成一个模拟的验证结果
            NSString *fallbackValidate = [NSString stringWithFormat:@"fallback_%ld",
                                         (long)([[NSDate date] timeIntervalSince1970] * 1000)];
            if (onSuccess) {
                onSuccess(fallbackValidate, YZMsg(@"降级模式验证成功"));
            }
        } else {
            if (onError) {
                onError([NSString stringWithFormat:@"%@: %@", YZMsg(@"验证码初始化失败，请稍后重试"), exception.reason]);
            }
        }
    }
}

/// 验证验证码结果
+ (BOOL)validateCaptchaResult:(NSString *)validate msg:(NSString *)msg {
    // 验证validate参数的有效性
    if (!validate || validate.length == 0) {
        NSLog(@"billDebug 验证码结果验证失败: validate为空");
        return NO;
    }

    // 验证validate长度（网易验证码的validate通常有一定长度）
    if (validate.length < 10) {
        NSLog(@"billDebug 验证码结果验证失败: validate长度异常");
        return NO;
    }

    NSLog(@"billDebug 验证码结果验证成功: validate=%@, msg=%@", validate, msg);
    return YES;
}

/// 检查验证码插件是否已初始化
+ (BOOL)isInitialized {
    return [CaptchaManager sharedInstance].isInitialized;
}

/// 重置验证码插件状态（用于调试或重新初始化）
+ (void)reset {
    CaptchaManager *manager = [CaptchaManager sharedInstance];
    manager.isInitialized = NO;
    manager.initializedLang = nil;
    NSLog(@"billDebug 验证码插件状态已重置");
}

/// 获取验��码错误信息的本地化文本
+ (NSString *)getLocalizedErrorMessage:(NSString *)errorMsg {
    if (!errorMsg) {
        return YZMsg(@"验证失败，请重试");
    }

    NSString *lowerError = [errorMsg lowercaseString];

    if ([lowerError containsString:@"timeout"] || [lowerError containsString:@"超时"]) {
        return YZMsg(@"验证码验证超时，请重试");
    } else if ([lowerError containsString:@"network"] || [lowerError containsString:@"网络"]) {
        return YZMsg(@"网络连接失败，请检查网络后重试");
    } else if ([lowerError containsString:@"cancel"] || [lowerError containsString:@"取消"]) {
        return YZMsg(@"验证已取消");
    } else if ([lowerError containsString:@"init"] || [lowerError containsString:@"初始化"]) {
        return YZMsg(@"验证码初始化失败，请稍后重试");
    } else if ([lowerError containsString:@"config"] || [lowerError containsString:@"配置"]) {
        return YZMsg(@"验证码配置错误，请联系客服");
    } else if ([lowerError containsString:@"invalid"] || [lowerError containsString:@"无效"]) {
        return YZMsg(@"验证结果无效，请重新验证");
    } else {
        return YZMsg(@"验证失败，请重试");
    }
}

#pragma mark - NTESVerifyCodeManagerDelegate

/// 验证码组件初始化完成
- (void)verifyCodeInitFinish {
    NSLog(@"billDebug 验证码组件初始化完成");
}

/// 验证码组件初始化出错
- (void)verifyCodeInitFailed:(NSArray *)error {
    NSLog(@"billDebug 验证码组件初始化失败: %@", error);

    self.errorCalled = YES;

    if (self.errorBlock) {
        NSString *errorMsg = error.firstObject ?: YZMsg(@"验证码初始化失败");
        self.errorBlock(errorMsg);
    }
}

/// 完成验证之后的回调
- (void)verifyCodeValidateFinish:(BOOL)result validate:(NSString *)validate message:(NSString *)message {
    NSLog(@"billDebug 验证码验证完成: result=%@, validate=%@, message=%@ lang=%ld",
          result ? @"YES" : @"NO", validate ?: @"", message ?: @"", self.verifyCodeManager.lang);

    if (result) {
        // 验证成功
        self.successCalled = YES;

        // 验证结果有效性检查
        if (validate && validate.length > 0) {
            if (self.successBlock) {
                self.successBlock(validate, message ?: @"");
            }
        } else {
            NSLog(@"billDebug 验证结果无效: validate为空");
            self.errorCalled = YES;
            if (self.errorBlock) {
                self.errorBlock(YZMsg(@"验证结果无效，请重新验证"));
            }
        }
    } else {
        // 验证失败
        // 某些机型/网络条件下，成功回调后仍可能触发失败，这里做幂等保护
        if (self.successCalled) {
            NSLog(@"billDebug 验证码已成功回调，忽略后续错误: %@", message);
            return;
        }

        self.errorCalled = YES;

        if (self.errorBlock) {
            NSString *errorMsg = message ?: YZMsg(@"验证失败");
            if ([errorMsg isEqualToString:@"验证失败"]) {
                errorMsg = YZMsg(@"验证失败");
            }
            self.errorBlock(errorMsg);
        }
    }
}

/// 关闭验证码窗口后的回调
- (void)verifyCodeCloseWindow:(NTESVerifyCodeClose)close {
    NSString *closeType = (close == NTESVerifyCodeCloseManual) ? @"手动关闭" : @"自动关闭";
    NSLog(@"billDebug 验证码关闭: %@", closeType);

    // 仅当未发生成功或失败回调时，才认为是用户主动取消
    if (!self.successCalled && !self.errorCalled) {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    } else {
        NSLog(@"billDebug 验证码已成功/失败回调，忽略关闭触发的取消提示");
    }
}

@end
