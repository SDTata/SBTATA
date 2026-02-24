//
//  FQLockGestureView.h
//  PhoneLiveSDK
//
//  Created on 2025/04/07.
//

#import <UIKit/UIKit.h>
#import "FQLockConfig.h"
#import "VKSupportUtil.h"

NS_ASSUME_NONNULL_BEGIN

@class FQLockGestureView;

@protocol FQGestureLockViewDelegate <NSObject>

@optional
/// 连线个数少于最少连接数，通知代理
/// @param view LockView
/// @param type 锁类型
/// @param gesture 手势密码
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type connectNumberLessThanNeedWithGesture:(NSString *)gesture;

/// 第一次设置手势密码
/// @param view LockView
/// @param type 锁类型
/// @param gesture 第一次手势密码
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type didCompleteSetFirstGesture:(NSString *)gesture;

/// 第二次设置手势密码
/// @param view LockView
/// @param type 锁类型
/// @param gesture 第二次手势密码
/// @param equal 第二次和第一次的手势密码匹配结果
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal;

/// 验证手势密码
/// - Parameters:
///   - view: LockView
///   - type: 锁类型
///   - gesture: 验证的手势密码
///   - equal: 验证是否通过
- (void)fq_gestureLockView:(FQLockGestureView *)view type:(FQLockType)type didCompleteVerifyGesture:(NSString *)gesture result:(BOOL)equal;

@end

@interface FQLockGestureView : UIView

// 代理
@property (nonatomic, weak) id<FQGestureLockViewDelegate> delegate;

/// 初始化方法
/// - Parameter config: 配置信息
- (instancetype)initWithConfig:(FQLockConfig *)config;

/// 更新配置
/// - Parameter config: 新的配置信息
- (void)updateConfig:(FQLockConfig *)config;

@end

NS_ASSUME_NONNULL_END
