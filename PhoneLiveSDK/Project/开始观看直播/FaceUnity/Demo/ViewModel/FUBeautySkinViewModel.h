//
//  FUBeautySkinViewModel.h
//  FUDemo
//
//  Created by 项林平 on 2021/6/11.
//  美肤功能模块
//

#import <Foundation/Foundation.h>
#import "FUBeautySkinModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautySkinViewModel : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSArray<FUBeautySkinModel *> *beautySkins;
/// 是否所有值都是默认
@property (nonatomic, assign, readonly) BOOL isDefaultValue;
/// 当前选中索引，默认为-1
@property (nonatomic, assign) NSInteger selectedIndex;

/// 设置单项美肤值
/// @param value 当前选中单项的值
- (void)setSkinValue:(double)value;

/// 恢复所有美肤值为默认
- (void)recoverAllSkinValuesToDefault;

/// 设置所有美肤参数值
- (void)setAllSkinValues;

/// 从缓存加载视图模型
+ (instancetype)loadCacheForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
