//
//  VKMacro.h
//  VKCodeKit
//
//  Created by vick on 2020/10/26.
//

#pragma mark - 日志打印
#ifdef DEBUG
#define VKLOG(FORMAT, ...) fprintf(stderr, "[DEBUG] [%s %s] [%s] [Line %d]\n%s\n\n", __DATE__ , __TIME__, [NSString stringWithUTF8String:__FILE__].lastPathComponent.UTF8String, __LINE__, [[NSString alloc] initWithCString:[[[NSString alloc] initWithCString:[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] cStringUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"].UTF8String encoding:NSNonLossyASCIIStringEncoding].UTF8String ?: [NSString stringWithFormat:FORMAT, ##__VA_ARGS__].UTF8String)
#else
#define VKLOG(...)
#endif

#pragma mark - 交换方法
#define VK_METHOD_SWIZZLING_CLASS(class, originalFunction, swizzledFunction)\
({\
SEL originalSelector = originalFunction;\
SEL swizzledSelector = swizzledFunction;\
Method originalMethod = class_getInstanceMethod(class, originalSelector);\
Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);\
BOOL didAddMethod = class_addMethod(class,originalSelector,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod));\
if (didAddMethod) {\
    class_replaceMethod(class,swizzledSelector,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));\
} else {\
    method_exchangeImplementations(originalMethod, swizzledMethod);\
}\
})

#pragma mark - 分类属性
#define VK_PROPERTY_OBJECT(object) objc_setAssociatedObject(self, @selector(object), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#define VK_PROPERTY_ASSIGN(object) objc_setAssociatedObject(self, @selector(object), @(object), OBJC_ASSOCIATION_ASSIGN)
#define VK_PROPERTY_GET(object) objc_getAssociatedObject(self, @selector(object))

#pragma mark - 创建单例
#define VK_SINGLETON_H \
+ (instancetype)shared;
#define VK_SINGLETON_M \
static id _instance;\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    return _instance;\
}\
+ (instancetype)shared{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    return _instance;\
}\
- (id)copyWithZone:(NSZone *)zone{\
    return _instance;\
}

#pragma mark - weak引用
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#pragma mark - strong引用
#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define _weakify(x) __weak typeof(x) x##_##weak = x;
#define _strongify(x) __strong typeof(x) x = x##_##weak; if (!x) return;
#define _strongifyReturn(x) __strong typeof(x) x = x##_##weak; if (!x) return nil;

#pragma mark - 屏幕尺寸
/** 屏幕高度*/
#define VK_SCREEN_H ([UIScreen mainScreen].bounds.size.height)
/** 屏幕宽度*/
#define VK_SCREEN_W ([UIScreen mainScreen].bounds.size.width)
/** 状态栏高度*/
#define VK_STATUS_H ([[UIApplication sharedApplication] statusBarFrame].size.height)
/** 导航栏高度*/
#define VK_NAV_H (VK_STATUS_H + 44.0)
/** 底部安全区高度*/
#define VK_BOTTOM_H (VK_STATUS_H > 20.0f ? 34.0f : 0.f)
/** 标签栏高度*/
#define VK_TAB_H (VK_BOTTOM_H + 49.0f)
/** 内容高度*/
#define VK_CONTENT_H (VK_SCREEN_H - VK_BOTTOM_H - VK_NAV_H)
/** 屏幕缩放比例*/
#define VKPX(v) ((v) * (VK_SCREEN_W / 375.0f))
/** 1像素*/
#define VKPX1 (1/[UIScreen mainScreen].scale)
/** 判断刘海屏*/
#define IPHONE_X \
({\
    BOOL isPhoneX = NO;\
    if (@available(iOS 11.0, *)) {\
        isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
    }\
    (isPhoneX);\
})
/** Block调用*/
#define VKBLOCK(block, ...) ({ !block ? nil : block(__VA_ARGS__); })
