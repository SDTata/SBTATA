//
//  UIView+VKImage.h
//
//  Created by vick on 2023/10/20.
//

#import <UIKit/UIKit.h>

@interface UIView (VKImage)

/// 加载网络图片
- (void)vk_setImageUrl:(NSString *)url;

/// 加载方形游戏
- (void)vk_setGridGameUrl:(NSString *)url;

/// 加载长形游戏
- (void)vk_setLongGameUrl:(NSString *)url;

/// 加载网络图和占位图
- (void)vk_setImageUrl:(NSString *)url defalutImage:(UIImage *)image;

/// 加载图片
+ (void)vk_loadImageUrl:(NSString *)url completed:(void(^)(UIImage *image, NSError *error))completed;

/// 加载Gif
+ (UIImage *)vk_animatedGIFNamed:(NSString *)name;

/// 缓存大小
+ (NSUInteger)vk_imageCachaSize;

/// 清空缓存
+ (void)vk_clearImageCacha;

@end
