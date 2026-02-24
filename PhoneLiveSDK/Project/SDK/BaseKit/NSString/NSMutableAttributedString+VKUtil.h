//
//  NSMutableAttributedString+VKUtil.h
//  dev
//
//  Created by vick on 2021/7/12.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (VKUtil)

/// 字体
@property (nonatomic, strong) UIFont *vk_font;

/// 添加文字
- (void)vk_appendString:(id)string;

/// 添加文字，颜色
- (void)vk_appendString:(id)string color:(UIColor *)color;

/// 添加文字，颜色，字体
- (void)vk_appendString:(id)string color:(UIColor *)color font:(UIFont *)font;

/// 添加图片
- (void)vk_appendImage:(id)image;

/// 添加图片，设置尺寸
- (void)vk_appendImage:(id)image size:(CGSize)size;

/// 添加间隙
- (void)vk_appendSpace:(CGFloat)width;

/// 设置样式
- (void)vk_setStrings:(NSArray *)strings color:(UIColor *)color font:(UIFont *)font;

/// 设置行高
- (void)vk_setLineSpacing:(CGFloat)lineSpacing alignment:(NSTextAlignment)alignment;

@end
