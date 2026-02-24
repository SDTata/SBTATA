//
//  VKBaseTableView.h
//
//  Created by vick on 2020/11/2.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VKTableViewStyle) {
    VKTableViewStyleSingle,
    VKTableViewStyleGrouped
};

typedef void (^VKTableCellConfigureBlock)(UITableViewCell *cell, id item, NSIndexPath *indexPath);
typedef void (^VKTableCellDidSelectBlock)(NSIndexPath *indexPath, id item);
typedef void (^VKTableCellClickActionBlock)(NSIndexPath *indexPath, id item, NSInteger actionIndex);
typedef void (^VKTableCommitEditingBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef NSString *(^VKTableDeleteTitleBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef BOOL (^VKTableCanEditRowBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef void (^VKTableWillDisplayCellBlock)(UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath);

@interface VKBaseTableView : UITableView

/** 配置Cell自定义内容，不配置默认使用 VKBaseTableViewCell */
@property (nonatomic, copy) VKTableCellConfigureBlock configureCellBlock;
/** 配置Cell点击事件*/
@property (nonatomic, copy) VKTableCellDidSelectBlock didSelectCellBlock;
/** 配置Cell其他事件*/
@property (nonatomic, copy) VKTableCellClickActionBlock clickCellActionBlock;
/** 配置Section其他事件*/
@property (nonatomic, copy) VKTableCellClickActionBlock clickSectionActionBlock;
/** 配置Cell刪除事件*/
@property (nonatomic, copy) VKTableCommitEditingBlock commitEditingBlock;
/** 配置Cell自定義刪除按鈕標題*/
@property (nonatomic, copy) VKTableDeleteTitleBlock deleteTitleBlock;
/** 用於控制是否允許編輯（刪除操作）的 Block**/
@property (nonatomic, copy) VKTableCanEditRowBlock canEditRowBlock;

@property (nonatomic, copy) VKTableWillDisplayCellBlock willDisplayCellBlock;
/** 样式，单列和分组*/
@property (nonatomic, assign) VKTableViewStyle viewStyle;
/** 配置数据源*/
@property (nonatomic, strong) NSMutableArray *dataItems;

/** 注册Cell类，VKBaseTableViewCell子类*/
@property (nonatomic, assign) Class registerCellClass;
/** 注册SectionHeader类，VKBaseTableSectionView子类*/
@property (nonatomic, assign) Class registerSectionHeaderClass;
/** 注册SectionFooter类，VKBaseTableSectionView子类*/
@property (nonatomic, assign) Class registerSectionFooterClass;

/** 注册Cell委托，在 VKBaseTableViewCell 中使用*/
@property (nonatomic, weak) id extraDelegate;
/** 配置Cell额外数据，在 VKBaseTableViewCell 中使用*/
@property (nonatomic, strong) id extraData;
/** 自适应高度*/
@property (nonatomic, assign) BOOL automaticDimension;
/** 固定高度*/
@property (nonatomic, assign) CGFloat itemHeight;

/** 分组模式下，解析后返回头部数据*/
@property (nonatomic, copy) id (^sectionHeaderParseBlock)(id section);
/** 分组模式下，解析后返回底部数据*/
@property (nonatomic, copy) id (^sectionFooterParseBlock)(id section);
/** 分组模式下，解析后返回row数组数据*/
@property (nonatomic, copy) NSArray *(^rowsParseBlock)(id section);

/** 分组模式下，设置每组Cell为不同类型*/
@property (nonatomic, strong) NSArray <Class> *registerCellClassItems;

/// 默认选择项
@property (nonatomic, strong) NSIndexPath *defalutIndexPath;

/** 配置不同的Cell*/
@property (nonatomic, copy) Class (^registerCellClassBlock)(NSIndexPath *indexPath, id item);

@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDeceleratingBlock)(UIScrollView *scrollView);
@property (nonatomic, copy) void (^scrollViewDidEndDraggingBlock)(UIScrollView *scrollView, BOOL willDecelerate);

/// 自定义组数
@property (nonatomic, assign) NSInteger sectionNumbers;

/// 自定义不同的组数
@property (nonatomic, copy) NSArray *(^numberOfRowsInSectionBlock)(NSInteger section, NSArray *datas);

/// SectionHeader高度
@property (nonatomic, copy) CGFloat (^heightForHeaderInSectionBlock)(NSInteger section);

/// SectionFooter高度
@property (nonatomic, copy) CGFloat (^heightForFooterInSectionBlock)(NSInteger section);

- (NSArray *)rowItemsForSectionIndex:(NSInteger)section;

/// 滚动到指定位置，-1为底部
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

/// 单选
- (void)selectIndexPath:(NSIndexPath *)indexPath key:(NSString *)key;

@end
