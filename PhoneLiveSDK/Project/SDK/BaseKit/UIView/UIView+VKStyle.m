//
//  UIView+VKStyle.m
//
//  Created by vick on 2023/10/20.
//

#import "UIView+VKStyle.h"
#import "VKInline.h"

@implementation UIView (VKStyle)
@dynamic verticalColors, horizontalColors;

#pragma mark - 设置渐变色
- (void)setVerticalColors:(NSArray *)verticalColors {
    [self layoutIfNeeded];
    self.backgroundColor = [UIView colors:verticalColors size:self.frame.size isHorizontal:NO];
}

- (void)setHorizontalColors:(NSArray *)horizontalColors {
    [self layoutIfNeeded];
    self.backgroundColor = [UIView colors:horizontalColors size:self.frame.size isHorizontal:YES];
}

/// 获取渐变色
+ (UIColor *)colors:(NSArray *)colors size:(CGSize)size isHorizontal:(BOOL)isHorizontal {
    if (colors.count < 2) {
        return colors.firstObject;
    }
    UIImage *backgroundColorImage = [UIView imageWithColors:colors size:size isHorizontal:isHorizontal];
    return [UIColor colorWithPatternImage:backgroundColorImage];
}

/// 获取渐变色图片
+ (UIImage *)imageWithColors:(NSArray *)colors size:(CGSize)size isHorizontal:(BOOL)isHorizontal {
    if (size.width <= 0) {
        size.width = 1;
        return nil;
    }
    if (size.height <=0) {
        size.height = 1;
        return nil;
    }
    
    CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
   
    backgroundGradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)[color CGColor]];
    }
    backgroundGradientLayer.colors = cgColors;
    
    if (isHorizontal) {
        [backgroundGradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
        [backgroundGradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
    } else {
        [backgroundGradientLayer setStartPoint:CGPointMake(0.5, 0.0)];
        [backgroundGradientLayer setEndPoint:CGPointMake(0.5, 1.0)];
    }
    
    UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size, NO, [UIScreen mainScreen].scale);
    [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return backgroundColorImage;
}

#pragma mark - 设置圆角
- (void)corner:(VKCornerMask)corner radius:(CGFloat)radius {
    self.layer.maskedCorners = (CACornerMask)corner;
    self.layer.cornerRadius = radius;
}

@end
