//
//  FQLockConfig.h
//  PhoneLiveSDK
//
//  Created on 2025/04/07.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VKSupportUtil.h"

/**
 *  手势密码界面用途类型
 *  设置模式：会重置密码，设置两次
 *  验证模式：验证手势正确与否
 *  请结合业务组合使用
 */

/**
 *  单个圆的各种状态
 */
typedef enum{
    FQLockCircleStateNormal = 1,
    FQLockCircleStateSelected,
    FQLockCircleStateError,
    FQLockCircleStateLastSelected,
    FQLockCircleStateLastError
} FQLockCircleState;

NS_ASSUME_NONNULL_BEGIN

@interface FQLockConfig : NSObject

/// 解锁类型: 新设置密码  或  验证密码
@property (nonatomic, assign) FQLockType lockType;

/// 密码会以NSUserDefaults形式保存，可以自定义key（如果和userID有关，一定要自定义）
@property (nonatomic, copy) NSString *passwordKey;

/// 解锁背景色（解锁视图是正方形）
@property (nonatomic, strong) UIColor *lockViewBackgroundColor;

/// 整个解锁View居中，距离屏幕左边和右边的距离 （用来控制宽度，高度等于宽度）
@property (nonatomic, assign) CGFloat lockViewEdgeMargin;

/// 解锁View的顶部对齐坐标，用于小屏幕设备的精确定位
@property (nonatomic, assign) CGFloat lockViewTopY;

/// 连接的圆最少的个数，默认4个
@property (nonatomic, assign) CGFloat lockLeastCount;

/// 线条宽度，默认1.0
@property (nonatomic, assign) CGFloat lineWidth;

/// 圆点半径，默认15.0
@property (nonatomic, assign) CGFloat dotRadius;

/// 内圆半径，默认5.0
@property (nonatomic, assign) CGFloat dotInnerRadius;

/// 错误状态颜色，默认红色
@property (nonatomic, strong) UIColor *errorColor;

/// 主题颜色，用于线条和圆点
@property (nonatomic, strong) UIColor *themeColor;

@end

NS_ASSUME_NONNULL_END
