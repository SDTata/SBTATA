//
//  FMBackModeManager.h
//  BackModeDemo
//
//  Created by LIUSONG on 2019/4/2.
//  Copyright © 2019 Rayor. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FMBackModeManager : NSObject
/** 是否启用声音 */
@property (nonatomic, assign) BOOL soundActive;

/** 当前后台模式是否开启 */
@property (nonatomic, assign, readonly) BOOL isActive;

/** 单例 */
+ (instancetype)shared;

/** 启动后台运行模式 */
- (void)activeBackMode;

/** 取消后台运行模式 */
- (void)invalidBackModel;

@end

/*
 使用范例：
 
 准备条件：配置 Capabilities  设置Background Modes 选择Audio, AirPlay, and Picture in Picture
 
 1. 在需要进行后台线程常驻的时候，需要开启
 [[FMBackModeManager shared] activeBackMode];
 
 2. 在不需要后台常驻的时候关闭即可
 [[FMBackModeManager shared] invalidBackModel];
 
 3. 音乐配置,开启背景提示音乐，关闭背景提示音乐
 [FMBackModeManager shared].soundActive = YES;
 
 */
