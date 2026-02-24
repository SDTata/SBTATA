//
//  MyCreateChildVC.h
//  phonelive2
//
//  Created by vick on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCreateInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MyCreateChildDelegate <NSObject>

/// 我的创作数据更新
- (void)myCreateChildDeletgateUpdate:(MyCreateInfoModel *)model;

/// 选择视频
- (void)myCreateChildDeletgateSelected;

@end

@interface MyCreateChildVC : VKPagerChildVC

@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak) id <MyCreateChildDelegate> delegate;
@property (nonatomic, assign) BOOL edit;

@property (nonatomic, strong, readonly) NSArray <ShortVideoModel *> *selectVideos;

/// 全选
- (void)selectAllList:(BOOL)isSelected;

- (void)refreshList;

@end

NS_ASSUME_NONNULL_END
