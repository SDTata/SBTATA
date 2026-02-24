//
//  UIView+UIScreenDisplaying.h
//  phonelive
//
//  Created by 400 on 2021/1/15.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (UIScreenDisplaying)
// 判断View是否显示在屏幕上
- (BOOL)isDisplayedInScreen;
@end

NS_ASSUME_NONNULL_END
