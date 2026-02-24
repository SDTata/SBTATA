//
//  UIView+VKCreate.m
//
//  Created by vick on 2023/10/20.
//

#import "UIView+VKCreate.h"
#import "VKInline.h"

@implementation UIView (VKCreate)

+ (UILabel *)vk_label:(NSString *)title font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = font;
    label.textColor = color;
    return label;
}

+ (UIImageView *)vk_imageView:(NSString *)imageName {
    UIImageView *imgView = [UIImageView new];
    imgView.image = [ImageBundle imagewithBundleName:imageName];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    return imgView;
}

+ (UIButton *)vk_buttonImage:(NSString *)imageNormal selected:(NSString *)imageSelected {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (imageNormal) {
        [button setImage:[ImageBundle imagewithBundleName:imageNormal] forState:UIControlStateNormal];
    }
    if (imageSelected) {
        [button setImage:[ImageBundle imagewithBundleName:imageSelected] forState:UIControlStateSelected];
        [button setImage:[ImageBundle imagewithBundleName:imageSelected] forState:UIControlStateSelected|UIControlStateHighlighted];
    }
    return button;
}

+ (UIButton *)vk_button:(NSString *)title image:(NSString *)imageName font:(UIFont *)font color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    if (imageName) {
        [button setImage:[ImageBundle imagewithBundleName:imageName] forState:UIControlStateNormal];
    }
    return button;
}

- (void)vk_button:(NSString *)title image:(NSString *)imageName font:(UIFont *)font color:(UIColor *)color {
    self.backgroundColor = UIColor.clearColor;
    if ([self isKindOfClass:UIButton.class]) {
        if (title) {
            [(UIButton *)self setTitle:title forState:UIControlStateNormal];
        }
        if (imageName) {
            [(UIButton *)self setImage:[ImageBundle imagewithBundleName:imageName] forState:UIControlStateNormal];
        }
        if (color) {
            [(UIButton *)self setTitleColor:color forState:UIControlStateNormal];
        }
        if (font) {
            [[(UIButton *)self titleLabel] setFont:font];
        }
    }
}

- (void)vk_buttonSelected:(NSString *)title image:(NSString *)imageName color:(UIColor *)color {
    if ([self isKindOfClass:UIButton.class]) {
        if (title) {
            [(UIButton *)self setTitle:title forState:UIControlStateSelected];
            [(UIButton *)self setTitle:title forState:UIControlStateSelected|UIControlStateHighlighted];
        }
        if (color) {
            [(UIButton *)self setTitleColor:color forState:UIControlStateSelected];
            [(UIButton *)self setTitleColor:color forState:UIControlStateSelected|UIControlStateHighlighted];
        }
        if (imageName) {
            [(UIButton *)self setImage:[ImageBundle imagewithBundleName:imageName] forState:UIControlStateSelected];
            [(UIButton *)self setImage:[ImageBundle imagewithBundleName:imageName] forState:UIControlStateSelected|UIControlStateHighlighted];
        }
    }
}

- (void)vk_border:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    if (color) {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = color.CGColor;
    }
}

- (void)vk_addTapAction:(id)target selector:(SEL)selector {
    if ([self isKindOfClass:UIButton.class]) {
        [(UIButton *)self setUserInteractionEnabled:YES];
        [(UIButton *)self removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [(UIButton *)self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    } else if ([self isKindOfClass:UIView.class]) {
        [(UIView *)self setUserInteractionEnabled:YES];
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            [self removeGestureRecognizer:gesture];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
        [(UIView *)self addGestureRecognizer:tap];
    }
}

+ (void)setNavColor:(UIColor *)color titleColor:(UIColor *)titleColor font:(UIFont *)font {
    NSDictionary *navTextAttributes = @{
        NSForegroundColorAttributeName : titleColor,
        NSFontAttributeName : font
    };
    
    if (@available(iOS 13.0, *)) {
        
        UINavigationBarAppearance *navBar = UINavigationBarAppearance.new;
        [navBar configureWithOpaqueBackground];
        navBar.backgroundColor = color;
        navBar.titleTextAttributes = navTextAttributes;
        navBar.shadowColor = UIColor.clearColor;
        navBar.shadowImage = UIImage.new;
        
        UINavigationBar.appearance.scrollEdgeAppearance = navBar;
        UINavigationBar.appearance.standardAppearance = navBar;
        UINavigationBar.appearance.translucent = NO;
        
    } else {
        
        UINavigationBar.appearance.barTintColor = color;
        UINavigationBar.appearance.titleTextAttributes = navTextAttributes;
        UINavigationBar.appearance.translucent = NO;
        UINavigationBar.appearance.shadowImage = UIImage.new;
    }
}

+ (void)setTabColor:(UIColor *)color titleColor:(UIColor *)titleColor titleSelectColor:(UIColor *)titleSelectColor font:(UIFont *)font {
    
    NSDictionary *textNormalAtts = @{
        NSForegroundColorAttributeName: titleColor,
        NSFontAttributeName: font
    };
    NSDictionary *textSelectedAtts = @{
        NSForegroundColorAttributeName: titleSelectColor,
        NSFontAttributeName: font
    };
    
    if (@available(iOS 13.0, *)) {
        
        UITabBarAppearance * appearance = UITabBarAppearance.new;
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = color;
        appearance.shadowColor = UIColor.clearColor;
        appearance.shadowImage = UIImage.new;
        
        UITabBarItemAppearance *itemAppearance = UITabBarItemAppearance.new;
        itemAppearance.normal.titleTextAttributes = textNormalAtts;
        itemAppearance.selected.titleTextAttributes = textSelectedAtts;
        appearance.stackedLayoutAppearance = itemAppearance;
        
        UITabBar.appearance.standardAppearance = appearance;
        UITabBar.appearance.translucent = NO;
        
        if (@available(iOS 15.0, *)) {
            UITabBar.appearance.scrollEdgeAppearance = appearance;
        }
        
    } else {
        
        [UITabBarItem.appearance setTitleTextAttributes:textNormalAtts forState:UIControlStateNormal];
        [UITabBarItem.appearance setTitleTextAttributes:textSelectedAtts forState:UIControlStateSelected];
        
        UITabBar.appearance.tintColor = titleColor;
        UITabBar.appearance.barTintColor = color;
        UITabBar.appearance.shadowImage = UIImage.new;
        UITabBar.appearance.backgroundImage = UIImage.new;
        UITabBar.appearance.translucent = NO;
    }
}

+ (void)pushVC:(UIViewController *)vc {
    vc.hidesBottomBarWhenPushed = YES;
    [vkTopVC().navigationController pushViewController:vc animated:YES];
}

+ (void)presentVC:(UIViewController *)vc {
    UINavigationController *nav = [UINavigationController.alloc initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [vkTopVC() presentViewController:nav animated:YES completion:nil];
}

+ (void)doCopy:(NSString *)text {
    UIPasteboard.generalPasteboard.string = text;
}

@end
