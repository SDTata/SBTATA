//
//  VKBaseCollectionSectionView.h
//
//  Created by vick on 2020/11/10.
//

#import <UIKit/UIKit.h>
#import "VKBaseCollectionView.h"

@interface VKBaseCollectionSectionView : UICollectionReusableView

/**Section位置*/
@property (nonatomic, strong) NSIndexPath *indexPath;

/**Section数据源*/
@property (nonatomic, strong) id itemModel;

/**Section委托，在 VKBaseCollectionView 中配置 extraDelegate*/
@property (nonatomic, weak) id delegate;

/** 配置Section其他事件*/
@property (nonatomic, copy) VKCollectionCellClickActionBlock clickSectionActionBlock;

/**Section高度*/
+ (CGFloat)itemHeight;

/**初始化界面*/
- (void)updateView;

/**更新数据*/
- (void)updateData;

@end
