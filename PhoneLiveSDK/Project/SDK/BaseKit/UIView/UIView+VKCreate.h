//
//  UIView+VKCreate.h
//
//  Created by vick on 2023/10/20.
//

#import <UIKit/UIKit.h>

@interface UIView (VKCreate)

/// 创建文字
+ (UILabel *)vk_label:(NSString *)title font:(UIFont *)font color:(UIColor *)color;

/// 创建图片
+ (UIImageView *)vk_imageView:(NSString *)imageName;

/// 创建图片按钮
+ (UIButton *)vk_buttonImage:(NSString *)imageNormal selected:(NSString *)imageSelected;

/// 创建按钮
+ (UIButton *)vk_button:(NSString *)title image:(NSString *)imageName font:(UIFont *)font color:(UIColor *)color;

/// 设置按钮普通状态
- (void)vk_button:(NSString *)title image:(NSString *)imageName font:(UIFont *)font color:(UIColor *)color;

/// 设置按钮点击状态
- (void)vk_buttonSelected:(NSString *)title image:(NSString *)imageName color:(UIColor *)color;

/// 设置边框和圆角
- (void)vk_border:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;

/// 设置点击事件
- (void)vk_addTapAction:(id)target selector:(SEL)selector;

/// 设置导航栏样式
+ (void)setNavColor:(UIColor *)color titleColor:(UIColor *)titleColor font:(UIFont *)font;

/// 设置标签栏样式
+ (void)setTabColor:(UIColor *)color titleColor:(UIColor *)titleColor titleSelectColor:(UIColor *)titleSelectColor font:(UIFont *)font;

/// 导航下一页
+ (void)pushVC:(UIViewController *)vc;

/// 弹出下一页
+ (void)presentVC:(UIViewController *)vc;

/// 复制
+ (void)doCopy:(NSString *)text;

@end
