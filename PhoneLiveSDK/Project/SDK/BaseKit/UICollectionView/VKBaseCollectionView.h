//
//  VKBaseCollectionView.h
//
//  Created by vick on 2020/11/2.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VKCollectionViewStyle) {
    VKCollectionViewStyleSingle,
    VKCollectionViewStyleGrouped,
    VKCollectionViewStyleHorizontal
};

typedef void (^VKCollectionCellConfigureBlock)(UICollectionViewCell *cell, id item, NSIndexPath *indexPath);
typedef void (^VKCollectionCellDidSelectBlock)(NSIndexPath *indexPath, id item);
typedef void (^VKCollectionCellClickActionBlock)(NSIndexPath *indexPath, id item, NSInteger actionIndex);

@interface VKBaseCollectionView : UICollectionView

/** 配置Cell内容，需要自定义可实现该方法*/
@property (nonatomic, copy) VKCollectionCellConfigureBlock configureCellBlock;
/** 配置Cell点击事件*/
@property (nonatomic, copy) VKCollectionCellDidSelectBlock didSelectCellBlock;
/** 配置Cell其他事件*/
@property (nonatomic, copy) VKCollectionCellClickActionBlock clickCellActionBlock;
/** 配置Section其他事件*/
@property (nonatomic, copy) VKCollectionCellClickActionBlock clickSectionActionBlock;

/** 样式，单列和分组*/
@property (nonatomic, assign) VKCollectionViewStyle viewStyle;
/** 自定义布局*/
@property (nonatomic, strong) UICollectionViewLayout *customCollectionViewLayout;
/** 数据源*/
@property (nonatomic, strong) NSMutableArray *dataItems;
/** 配置头部视图*/
@property (nonatomic, strong) UIView *headerView;

/** 注册cell类，VKBaseCollectionViewCell子类*/
@property (nonatomic, assign) Class registerCellClass;
/** 注册SectionHeader类，VKBaseCollectionSectionView子类*/
@property (nonatomic, assign) Class registerSectionHeaderClass;
/** 注册SectionFooter类，VKBaseCollectionSectionView子类*/
@property (nonatomic, assign) Class registerSectionFooterClass;

/** SectionHeader高度*/
@property (nonatomic, assign) CGFloat sectionHeaderHeight;
/** SectionFooter高度*/
@property (nonatomic, assign) CGFloat sectionFooterHeight;

/** 注册Cell委托，VKBaseCollectionViewCell 的 delegate*/
@property (nonatomic, weak) id extraDelegate;
/** 配置Cell额外数据，VKBaseCollectionViewCell 的 extraData*/
@property (nonatomic, strong) id extraData;

/** 分组模式下，解析后返回头部数据*/
@property (nonatomic, copy) id (^sectionHeaderParseBlock)(id section);
/** 分组模式下，解析后返回底部数据*/
@property (nonatomic, copy) id (^sectionFooterParseBlock)(id section);
/** 分组模式下，解析后返回row数组数据*/
@property (nonatomic, copy) NSArray *(^rowsParseBlock)(id section);

/** 分组模式下，设置每组Cell为不同类型*/
@property (nonatomic, strong) NSArray <Class> *registerCellClassItems;

/**设置间隔*/
@property (nonatomic, assign) CGFloat itemSpacing;
/**设置行间距*/
@property (nonatomic, assign) CGFloat itemLineSpacing;
/**设置每行个数*/
@property (nonatomic, assign) NSInteger itemCount;
/**设置高度*/
@property (nonatomic, assign) CGFloat itemHeight;
/**设置宽度*/
@property (nonatomic, assign) CGFloat itemWidth;

/** 自适应高度*/
@property (nonatomic, assign) BOOL automaticDimension;

/// 编辑状态
@property (nonatomic, assign) BOOL isEditType;

/// 默认选择项
@property (nonatomic, strong) NSIndexPath *defalutIndexPath;

/// 自定义组数
@property (nonatomic, assign) NSInteger sectionNumbers;

/// 内容高度
@property (nonatomic, assign) CGFloat contentHeight;

/** 配置不同的Cell*/
@property (nonatomic, copy) Class (^registerCellClassBlock)(NSIndexPath *indexPath, id item);

/// 自定义不同的组数
@property (nonatomic, copy) NSArray *(^numberOfRowsInSectionBlock)(NSInteger section, NSArray *datas);

/// SectionHeader高度
@property (nonatomic, copy) CGFloat (^heightForHeaderInSectionBlock)(NSInteger section, id item);

/// SectionFooter高度
@property (nonatomic, copy) CGFloat (^heightForFooterInSectionBlock)(NSInteger section, id item);

/// SectionHeader类型
@property (nonatomic, copy) Class (^classForHeaderInSectionBlock)(NSInteger section, id item);

/// SectionFooter类型
@property (nonatomic, copy) Class (^classForFooterInSectionBlock)(NSInteger section,  id item);

@property (nonatomic, copy) void (^scrollViewDidScrollBlock)(UIScrollView *scrollView);

- (NSArray *)rowItemsForSectionIndex:(NSInteger)index;

/// 滚动到指定位置，-1为底部
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

/// 单选
- (void)selectIndexPath:(NSIndexPath *)indexPath key:(NSString *)key;

@end
