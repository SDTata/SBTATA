//
//  UIView+GYPop.h
//  GYbc
//
//  Created by wade on 03/08/2019.
//  Copyright © 2019 James. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GYPop)

/**
 弹窗包裹视图 可添加到任意view上

 @param cView 内容View
 @param cFrame 内容View的frame
 @param cRadius 内容View的边框圆角
 */
- (void)gy_creatPopViewWithContentView:(UIView *)cView withContentViewFrame:(CGRect)cFrame andCornerRadius:(CGFloat)cRadius;

/**
 弹窗包裹视图 可添加到任意view上,圆角默认krealvalue(10.f)

 @param cView 内容View
 @param cFrame 内容View的frame
 */
- (void)gy_creatPopViewWithContentView:(UIView *)cView withContentViewFrame:(CGRect)cFrame;


/**
 弹窗包裹视图 可添加到任意view上 内容View居中显示,圆角默认krealvalue(10.f)

 @param cView 内容View
 @param cSize 内容View的Size
 */
- (void)gy_creatPopViewWithContentView:(UIView *)cView withContentViewSize:(CGSize)cSize;


/**
 消失弹窗
 */
- (void)gy_popViewdismiss;

@end

NS_ASSUME_NONNULL_END
