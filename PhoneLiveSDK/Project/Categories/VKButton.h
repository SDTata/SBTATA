//
//  VKButton.h
//  phonelive2
//
//  Created by vick on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VKButtonImagePosition) {
    VKButtonImagePositionLeft,
    VKButtonImagePositionRight,
    VKButtonImagePositionTop,
    VKButtonImagePositionBottom,
};

extern const CGFloat VKButtonCornerRadiusAdjustsBounds;

@interface VKButton : UIButton

/// 控制图片在UIButton里的位置
@property(nonatomic, assign) VKButtonImagePosition imagePosition;

/// 图片和文字的间距，默认值5
@property(nonatomic, assign) CGFloat spacingBetweenImage;

/// 指定图片size
@property (nonatomic, assign) CGSize imageSize;

/// 当 `cornerRadius` 为 `VKButtonCornerRadiusAdjustsBounds` 时，`VKButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
@property(nonatomic, assign) CGFloat cornerRadius;

/// 设置按钮额外热区
@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

@end
