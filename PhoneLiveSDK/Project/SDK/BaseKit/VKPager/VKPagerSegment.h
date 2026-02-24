//
//  VKPagerSegment.h
//
//  Created by vick on 2021/2/23.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import <JXCategoryView.h>

@interface VKPagerSegment : JXCategoryTitleImageView <JXCategoryViewDelegate>

/// 指示器
@property (nonatomic, strong) JXCategoryIndicatorComponentView *indicatorsView;

/// 底部分割线
@property (nonatomic, strong) UIView *bottomSeparatorView;

/// 边框普通颜色
@property (nonatomic, strong) UIColor *cellBorderNormalColor;

/// 边框选中颜色
@property (nonatomic, strong) UIColor *cellBorderSelectedColor;

/// 边框宽度
@property (nonatomic, assign) CGFloat cellBorderLineWidth;

/// 边框弧度
@property (nonatomic, assign) CGFloat cellBorderCornerRadius;

/// 点击回调
@property (nonatomic, copy) void (^clickIndexBlock)(NSInteger index);

/// 附加值
@property (nonatomic, strong) NSArray *values;

/// 当前选择的标题
@property (nonatomic, copy) NSString *selectedTitle;

/// 当前选择的附加值
@property (nonatomic, strong) id selectedValue;

/// 等宽
@property (nonatomic, assign) BOOL equalWidth;

@end
