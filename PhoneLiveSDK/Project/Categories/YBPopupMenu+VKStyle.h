//
//  YBPopupMenu+VKStyle.h
//  phonelive2
//
//  Created by vick on 2024/7/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YBPopupMenu.h"

typedef NS_ENUM(NSInteger, VKPopupMenuStyle) {
    VKPopupMenuNormal,  /// 默认样式
    VKPopupMenuDate,    /// 时间选择样式
};

@interface YBPopupMenu (VKStyle)

@property (nonatomic, assign) VKPopupMenuStyle menuStyle;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, copy) void (^selectedIndexBlock)(NSInteger index);

/// 菜单选择弹窗
+ (void)showMenu:(UIView *)view
           style:(VKPopupMenuStyle)style
           width:(CGFloat)width
          titles:(NSArray *)titles
           icons:(NSArray *)icons
           block:(void(^)(NSInteger index))block;

@end
