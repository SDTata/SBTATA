//
//  VKBaseTableSectionView.h
//
//  Created by vick on 2020/12/15.
//

#import <UIKit/UIKit.h>
#import "VKBaseTableView.h"

@interface VKBaseTableSectionView : UITableViewHeaderFooterView

/**Section位置*/
@property (nonatomic, assign) NSInteger section;

/**Section数据源*/
@property (nonatomic, strong) id itemModel;

/**Section委托，在 VKBaseTableView 中配置 extraDelegate*/
@property (nonatomic, weak) id delegate;

/**Section额外数据，在 VKBaseTableView 中配置 extraData*/
@property (nonatomic, strong) id extraData;

/** 配置Section其他事件*/
@property (nonatomic, copy) VKTableCellClickActionBlock clickSectionActionBlock;

/**Section高度*/
+ (CGFloat)itemHeight;

/**初始化界面*/
- (void)updateView;

/**更新数据*/
- (void)updateData;

@end
