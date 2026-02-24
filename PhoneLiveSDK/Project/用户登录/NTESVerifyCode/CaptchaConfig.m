//
//  CaptchaConfig.m
//  c601PLAY
//
//  Created by s5346 on 2025/10/1.
//  Copyright © 2025 toby. All rights reserved.
//

#import "CaptchaConfig.h"
#import "RookieTools.h"

@implementation CaptchaConfig

#pragma mark - Class Properties

+ (NSString *)captchaId {
    return @"9d1b50e6941740c7a346acb3a6ba1600";
}

+ (NSInteger)captchaMode {
    return 1;
}

+ (NSString *)defaultCaptchaLanguage {
    return @"zh-CN";
}

+ (NSInteger)captchaTimeout {
    return 15000; // 增加到15秒，提供更好的用户体验
}

+ (BOOL)isDebugMode {
    return NO;
}

+ (NSString *)productId {
    return @"YD00643302348070";
}

+ (NSInteger)maxRetryCount {
    return 3;
}

+ (BOOL)touchOutsideDisappear {
    return YES;
}

+ (BOOL)enableFallbackMode {
    return YES;
}

#pragma mark - Public Methods

+ (NSString *)getCurrentLanguage {
    // 优先使用服务端/请求使用的语言参数（与业务接口保持一致）
    NSString *serverLang = [[RookieTools currentLanguageServer] lowercaseString];

    if ([serverLang isEqualToString:@"zh-cn"]) {
        return @"zh-CN";
    } else if ([serverLang isEqualToString:@"zh-cht"]) {
        return @"zh-TW";
    } else if ([serverLang isEqualToString:@"en"]) {
        return @"en-US";
    } else if ([serverLang isEqualToString:@"jp"]) {
        return @"ja";
    } else if ([serverLang isEqualToString:@"vn"]) {
        return @"vi";
    } else if ([serverLang isEqualToString:@"id"]) {
        return @"id";
    }

    // 其次回退到系统语言
    NSString *preferredLang = [[NSLocale preferredLanguages] firstObject];
    if ([preferredLang hasPrefix:@"zh-Hans"]) {
        return @"zh-CN";
    } else if ([preferredLang hasPrefix:@"zh-Hant"] ||
               [preferredLang hasPrefix:@"zh-TW"] ||
               [preferredLang hasPrefix:@"zh-HK"] ||
               [preferredLang hasPrefix:@"zh-MO"]) {
        return @"zh-TW";
    } else if ([preferredLang hasPrefix:@"en"]) {
        return @"en";
    } else if ([preferredLang hasPrefix:@"ja"]) {
        return @"ja";
    } else if ([preferredLang hasPrefix:@"vi"]) {
        return @"vi";
    } else if ([preferredLang hasPrefix:@"id"]) {
        return @"id";
    }

    // 兜底
    return [self defaultCaptchaLanguage];
}

+ (BOOL)isConfigValid {
    NSString *captchaId = [self captchaId];
    return ![captchaId isEqualToString:@"YOUR_CAPTCHA_ID_HERE"] && captchaId.length > 0;
}

+ (NSString *)getConfigErrorMessage {
    NSString *captchaId = [self captchaId];

    if ([captchaId isEqualToString:@"YOUR_CAPTCHA_ID_HERE"]) {
        return @"请在 CaptchaConfig 中配置真实的验证码ID";
    } else if (captchaId.length == 0) {
        return @"验证码ID不能为空";
    }

    return @"验证码配置无效";
}

@end
