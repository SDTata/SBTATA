//
//  FMKeepVCManager.h
//  BackModeDemo
//
//  Created by LIUSONG on 2019/4/5.
//  Copyright © 2019 Rayor. All rights reserved.
//
/** 保活控制器 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMKeepVCManager : NSObject

/** 单例 */
+ (instancetype)shared;

/** 通过类获取保活的控制器 */
- (UIViewController *)liveVCFromManager:(Class)class;

/** 需要保活的控制器 */
@property (nonatomic, strong) NSMutableArray <UIViewController *> *keepVCs;


@end
/**
 * 主要针对为那些需要常驻的页面，即使退出页面也不能让某些事件停掉，可以将其放到单例中进行保活
 */
