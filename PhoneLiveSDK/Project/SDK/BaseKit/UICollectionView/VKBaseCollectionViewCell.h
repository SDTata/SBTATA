//
//  VKBaseCollectionViewCell.h
//
//  Created by vick on 2020/11/2.
//

#import <UIKit/UIKit.h>
#import "VKBaseCollectionView.h"

@interface VKBaseCollectionViewCell : UICollectionViewCell

/**Cell位置*/
@property (nonatomic, strong) NSIndexPath *indexPath;

/**Cell数据源，VKBaseCollectionView 中自动配置*/
@property (nonatomic, strong) id itemModel;

/**Cell委托，在 VKBaseCollectionView 中配置 extraDelegate*/
@property (nonatomic, weak) id delegate;

/**Cell额外数据，在 VKBaseCollectionView 中配置 extraData*/
@property (nonatomic, strong) id extraData;

/// 编辑状态
@property (nonatomic, assign) BOOL isEditType;

/** 配置Cell其他事件*/
@property (nonatomic, copy) VKCollectionCellClickActionBlock clickCellActionBlock;

/**Cell高度*/
+ (CGFloat)itemHeight;

/**Cell宽度，默认自适应*/
+ (CGFloat)itemWidth;

/**Cell间距*/
+ (CGFloat)itemSpacing;

/**Cell行间距*/
+ (CGFloat)itemLineSpacing;

/**Cell数量*/
+ (NSInteger)itemCount;

/**初始化界面*/
- (void)updateView;

/**更新数据*/
- (void)updateData;

/**动态高度*/
+ (CGFloat)autoHeightForItem:(id)itemModel;

/**获取当前tableView*/
- (VKBaseCollectionView *)baseTableView;

/**Cell刷新*/
- (void)reload;

/// 删除当前cell
- (void)deleteItem;

/// 最后一个cell
- (BOOL)isLastCell;

@end
