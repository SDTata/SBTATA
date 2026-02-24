//
//  VKBaseTableViewCell.h
//
//  Created by vick on 2020/11/2.
//

#import <UIKit/UIKit.h>
#import "VKBaseTableView.h"

@interface VKBaseTableViewCell : UITableViewCell

/**Cell位置*/
@property (nonatomic, strong) NSIndexPath *indexPath;

/**Cell数据源，VKBaseTableView 中自动配置*/
@property (nonatomic, strong) id itemModel;

/**Cell委托，在 VKBaseTableView 中配置 extraDelegate*/
@property (nonatomic, weak) id delegate;

/**Cell额外数据，在 VKBaseTableView 中配置 extraData*/
@property (nonatomic, strong) id extraData;

/** 配置Cell事件*/
@property (nonatomic, copy) VKTableCellClickActionBlock clickCellActionBlock;

/**Cell高度*/
+ (CGFloat)itemHeight;

/**动态高度*/
+ (CGFloat)autoHeightForItem:(id)itemModel;

/**初始化界面*/
- (void)updateView;

/**更新数据*/
- (void)updateData;

/**获取当前tableView*/
- (VKBaseTableView *)baseTableView;

/**Cell刷新*/
- (void)reload;

/// 删除当前cell
- (void)deleteItem;

/// 最后一个cell
- (BOOL)isLastCell;

@end
