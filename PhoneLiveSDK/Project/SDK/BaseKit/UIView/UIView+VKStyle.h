//
//  UIView+VKStyle.h
//
//  Created by vick on 2023/10/20.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSUInteger, VKCornerMask) {
    VKCornerMaskLeft = kCALayerMinXMinYCorner|kCALayerMinXMaxYCorner,
    VKCornerMaskRight = kCALayerMaxXMinYCorner|kCALayerMaxXMaxYCorner,
    VKCornerMaskTop = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner,
    VKCornerMaskBottom = kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner,
    VKCornerMaskAll = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner|kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner,
};

@interface UIView (VKStyle)

/// 上下渐变
@property (nonatomic, strong) NSArray *verticalColors;

/// 左右渐变
@property (nonatomic, strong) NSArray *horizontalColors;

/// 获取渐变色
+ (UIColor *)colors:(NSArray *)colors size:(CGSize)size isHorizontal:(BOOL)isHorizontal;

/// 获取渐变图片
+ (UIImage *)imageWithColors:(NSArray *)colors size:(CGSize)size isHorizontal:(BOOL)isHorizontal;

/// 设置部分圆角
- (void)corner:(VKCornerMask)corner radius:(CGFloat)radius;

@end
