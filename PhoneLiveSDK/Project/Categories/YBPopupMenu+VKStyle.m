//
//  YBPopupMenu+VKStyle.m
//  phonelive2
//
//  Created by vick on 2024/7/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YBPopupMenu+VKStyle.h"

@implementation YBPopupMenu (VKStyle)
@dynamic menuStyle;


#pragma mark -
#pragma mark - 新增属性
- (void)setSelectedIndexBlock:(void (^)(NSInteger))selectedIndexBlock {
    objc_setAssociatedObject(self, @selector(selectedIndexBlock), selectedIndexBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSInteger))selectedIndexBlock {
    return objc_getAssociatedObject(self, @selector(selectedIndexBlock));
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    objc_setAssociatedObject(self, @selector(textAlignment), @(textAlignment), OBJC_ASSOCIATION_ASSIGN);
}

- (NSTextAlignment)textAlignment {
    return [objc_getAssociatedObject(self, @selector(textAlignment)) integerValue];
}


#pragma mark -
#pragma mark - 修改方法
+ (void)load {
    vkGcdOnce(^{
        VK_METHOD_SWIZZLING_CLASS(self, @selector(tableView:cellForRowAtIndexPath:), @selector(vk_tableView:cellForRowAtIndexPath:));
    });
}

- (UITableViewCell *)vk_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self vk_tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textAlignment = self.textAlignment;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark -
#pragma mark - 显示弹窗
+ (void)showMenu:(UIView *)view style:(VKPopupMenuStyle)style width:(CGFloat)width titles:(NSArray *)titles icons:(NSArray *)icons block:(void (^)(NSInteger))block {
    [YBPopupMenu showRelyOnView:view titles:titles icons:icons menuWidth:width otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.delegate = (id<YBPopupMenuDelegate>) self;
        popupMenu.selectedIndexBlock = block;
        popupMenu.menuStyle = style;
        popupMenu.dismissOnSelected = NO;
        popupMenu.animationManager.style = YBPopupMenuAnimationStyleFade;
    }];
}

+ (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index {
    if (ybPopupMenu.selectedIndexBlock) {
        ybPopupMenu.selectedIndexBlock(index);
    }
    [ybPopupMenu dismiss];
}


#pragma mark -
#pragma mark - 设置样式
- (void)setMenuStyle:(VKPopupMenuStyle)menuStyle {
    switch (menuStyle) {
        case VKPopupMenuNormal:
        {
            self.backColor = UIColor.whiteColor;
            self.textColor = UIColor.blackColor;
        }
            break;
        case VKPopupMenuDate:
        {
            self.backColor = vkColorHex(0x8F70B3);
            self.textColor = UIColor.whiteColor;
            self.textAlignment = NSTextAlignmentCenter;
            
            self.arrowWidth = 0;
            self.arrowHeight = 0;
            self.itemHeight = 28;
            
            self.tableView.separatorColor = vkColorHex(0xFFFFFF);
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//            self.tableView.separatorInset = UIEdgeInsetsMake(0, 30, 0, 30);
        }
            break;
        default:
            break;
    }
}

@end
