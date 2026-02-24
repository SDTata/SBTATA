//
//  UIScrollView+VKData.h
//
//  Created by vick on 2021/4/17.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (VKData)

/// 保存key，去重处理
@property (nonatomic, strong) NSMutableArray *keys;

/// 刷新结束数据处理
- (void)vk_refreshFinish:(NSArray *)array;

/// 刷新结束数据处理，根据key去重
- (void)vk_refreshFinish:(NSArray *)array withKey:(NSString *)key;

@end
