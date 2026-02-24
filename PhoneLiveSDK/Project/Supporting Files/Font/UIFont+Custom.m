//
//  UIFont+Custom.m
//  phonelive2
//
//  Created by vick on 2024/9/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "UIFont+Custom.h"
#import <CoreText/CoreText.h>

@implementation UIFont (Custom)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        [self registerFont:@"SanJiYuanTiJian.ttf"];
//        [self registerFont:@"SanJiYuanTiJian-Xi.ttf"];
//        [self registerFont:@"SanJiYuanTiJian-Zhong.ttf"];
//        [self registerFont:@"SanJiYuanTiJian-Cu.ttf"];
//        [self registerFont:@"SanJiYuanTiJian-Cu.ttf"];
        [self registerFont:@"HYZhengYuan-45W.ttf"];
        [self registerFont:@"HYZhengYuan-65W.ttf"];
        [self registerFont:@"HYZhengYuan-85W.ttf"];
        
        method_exchangeImplementations(class_getClassMethod([self class], @selector(systemFontOfSize:)), class_getClassMethod([self class], @selector(vk_systemFontOfSize:)));
        
        method_exchangeImplementations(class_getClassMethod([self class], @selector(boldSystemFontOfSize:)), class_getClassMethod([self class], @selector(vk_boldSystemFontOfSize:)));
        
        method_exchangeImplementations(class_getClassMethod([self class], @selector(systemFontOfSize:weight:)), class_getClassMethod([self class], @selector(vk_systemFontOfSize:weight:)));
        
        method_exchangeImplementations(class_getClassMethod([self class], @selector(fontWithName:size:)), class_getClassMethod([self class], @selector(vk_fontWithName:size:)));
    });
}

+ (void)registerFont:(NSString *)fontName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ImgBundle" ofType:@"bundle"];
    NSString *fontPath = [NSString stringWithFormat:@"%@/%@", bundlePath, fontName];
    NSData *dynamicFontData = [NSData dataWithContentsOfFile:fontPath];
    if (!dynamicFontData) {
        return;
    }
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(providerRef);
}

+ (UIFont *)vk_systemFontOfSize:(CGFloat)fontSize {
    UIFont *font = [UIFont fontWithName:@"HYZhengYuan-DEW" size:fontSize];
    if (font) return font;
    return [self vk_systemFontOfSize:fontSize];
}

+ (UIFont *)vk_boldSystemFontOfSize:(CGFloat)fontSize {
    UIFont *font = [UIFont fontWithName:@"HYZhengYuan-FEW" size:fontSize];
    if (font) return font;
    return [self vk_boldSystemFontOfSize:fontSize];
}

+ (UIFont *)vk_systemFontOfSize:(CGFloat)fontSize weight:(UIFontWeight)weight {
    UIFont *font = [UIFont fontWithName:@"HYZhengYuan-FEW" size:fontSize];
    if (font) return font;
    return [self vk_systemFontOfSize:fontSize weight:weight];
}

+ (UIFont *)vk_fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont *font = [self vk_fontWithName:@"HYZhengYuan-FEW" size:fontSize];
    if (font) return font;
    return [self vk_fontWithName:fontName size:fontSize];
}

@end
