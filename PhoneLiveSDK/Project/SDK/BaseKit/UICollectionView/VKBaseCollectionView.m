//
//  VKBaseCollectionView.m
//
//  Created by vick on 2020/11/2.
//

#import "VKBaseCollectionView.h"
#import "VKBaseCollectionViewCell.h"
#import "VKBaseCollectionSectionView.h"
#import "VKInline.h"

@interface VKBaseCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *sectionHeaderIdentifier;
@property (nonatomic, copy) NSString *sectionFooterIdentifier;
@end

@implementation VKBaseCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (!layout) {
        layout = [[UICollectionViewFlowLayout alloc] init];
    }
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionViewLayout = layout;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = UIColor.clearColor;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.contentOffset = CGPointMake(0, 0);
    self.dataSource = self;
    self.delegate = self;
    self.alwaysBounceVertical = YES;
    self.delaysContentTouches = false;
    self.viewStyle = VKCollectionViewStyleSingle;
    
    // 添加手势识别器
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollectionViewTap:)];
        [self addGestureRecognizer:tapGesture];
        
    
//    if (@available(iOS 11.0, *)) {
//        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
    
    SEL sel = NSSelectorFromString(@"_setRowAlignmentsOptions:");
    if ([self.collectionViewLayout respondsToSelector:sel]) {
        ((void(*)(id,SEL,NSDictionary*)) objc_msgSend)(self.collectionViewLayout,sel, @{@"UIFlowLayoutCommonRowHorizontalAlignmentKey":@(NSTextAlignmentLeft),@"UIFlowLayoutLastRowHorizontalAlignmentKey" : @(NSTextAlignmentLeft),@"UIFlowLayoutRowVerticalAlignmentKey" : @(NSTextAlignmentCenter)});
    }
}

- (void)setViewStyle:(VKCollectionViewStyle)viewStyle {
    _viewStyle = viewStyle;
    if (viewStyle == VKCollectionViewStyleHorizontal) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionViewLayout = layout;
        self.alwaysBounceVertical = NO;
    }
}

- (void)setCustomCollectionViewLayout:(UICollectionViewLayout *)layout {
    _customCollectionViewLayout = layout;
    self.collectionViewLayout = layout;
}

- (void)getCellClassConfig:(Class)registerCellClass {
    if ([registerCellClass respondsToSelector:@selector(itemHeight)]) {
        self.itemHeight = [registerCellClass itemHeight];
    }
    if ([registerCellClass respondsToSelector:@selector(itemLineSpacing)]) {
        self.itemLineSpacing = [registerCellClass itemLineSpacing];
    }
    if ([registerCellClass respondsToSelector:@selector(itemCount)]) {
        self.itemCount = [registerCellClass itemCount];
    }
    if ([registerCellClass respondsToSelector:@selector(itemSpacing)]) {
        self.itemSpacing = [registerCellClass itemSpacing];
    }
    if ([registerCellClass respondsToSelector:@selector(itemWidth)]) {
        self.itemWidth = [registerCellClass itemWidth];
    }
}

- (void)registerCellWithClass:(Class)registerCellClass {
    self.cellIdentifier = NSStringFromClass(registerCellClass);
    NSString *nibPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:self.cellIdentifier ofType:@"nib"];
    if (nibPath) {
        [self registerNib:[UINib nibWithNibName:self.cellIdentifier bundle:[XBundle currentXibBundleWithResourceName:@""]] forCellWithReuseIdentifier:self.cellIdentifier];
    } else {
        [self registerClass:registerCellClass forCellWithReuseIdentifier:self.cellIdentifier];
    }
}

- (void)setRegisterCellClass:(Class)registerCellClass {
    _registerCellClass = registerCellClass;
    [self getCellClassConfig:registerCellClass];
    [self registerCellWithClass:registerCellClass];
}

- (void)setRegisterCellClassItems:(NSArray<Class> *)registerCellClassItems {
    _registerCellClassItems = registerCellClassItems;
    for (Class registerCellClass in registerCellClassItems) {
        [self registerCellWithClass:registerCellClass];
    }
}

- (void)setRegisterSectionHeaderClass:(Class)registerSectionHeaderClass {
    _registerSectionHeaderClass = registerSectionHeaderClass;
    self.sectionHeaderIdentifier = NSStringFromClass(registerSectionHeaderClass);
    if (!self.sectionHeaderHeight && [registerSectionHeaderClass respondsToSelector:@selector(itemHeight)]) {
        self.sectionHeaderHeight = [registerSectionHeaderClass itemHeight];
    }
    NSString *nibPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:self.sectionHeaderIdentifier ofType:@"nib"];
    if (nibPath) {
        [self registerNib:[UINib nibWithNibName:self.sectionHeaderIdentifier bundle:[XBundle currentXibBundleWithResourceName:@""]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.sectionHeaderIdentifier];
    } else {
        [self registerClass:registerSectionHeaderClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.sectionHeaderIdentifier];
    }
}

- (void)setRegisterSectionFooterClass:(Class)registerSectionFooterClass {
    _registerSectionFooterClass = registerSectionFooterClass;
    self.sectionFooterIdentifier = NSStringFromClass(registerSectionFooterClass);
    if (!self.sectionFooterHeight && [registerSectionFooterClass respondsToSelector:@selector(itemHeight)]) {
        self.sectionFooterHeight = [registerSectionFooterClass itemHeight];
    }
    NSString *nibPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:self.sectionFooterIdentifier ofType:@"nib"];
    if (nibPath) {
        [self registerNib:[UINib nibWithNibName:self.sectionFooterIdentifier bundle:[XBundle currentXibBundleWithResourceName:@""]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:self.sectionFooterIdentifier];
    } else {
        [self registerClass:registerSectionFooterClass forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:self.sectionFooterIdentifier];
    }
}

- (void)setSectionHeaderHeight:(CGFloat)sectionHeaderHeight {
    if (!self.sectionHeaderIdentifier) {
        [self setRegisterSectionHeaderClass:[VKBaseCollectionSectionView class]];
    }
    _sectionHeaderHeight = sectionHeaderHeight;
}

- (void)setSectionFooterHeight:(CGFloat)sectionFooterHeight {
    if (!self.sectionFooterIdentifier) {
        [self setRegisterSectionFooterClass:[VKBaseCollectionSectionView class]];
    }
    _sectionFooterHeight = sectionFooterHeight;
}

- (void)setHeaderView:(UIView *)headerView {
    CGFloat height = CGRectGetHeight(headerView.frame);
    UIEdgeInsets contentInset = self.contentInset;
    CGFloat lastHeight = height + contentInset.top;
    contentInset.top = lastHeight;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(lastHeight, 0, 0, 0);
    self.contentInset = contentInset;
    
    headerView.frame = CGRectMake(-contentInset.left, -height, 0, height);
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:headerView];
}

-(NSMutableArray *)dataItems{
    if (!_dataItems) {
        _dataItems = [NSMutableArray array];
    }
    return _dataItems;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.sectionNumbers > 0) {
        return self.sectionNumbers;
    }
    return (self.viewStyle == VKCollectionViewStyleGrouped) ? self.dataItems.count : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self rowItemsForSectionIndex:section].count;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemLineSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.viewStyle == VKCollectionViewStyleHorizontal) {
        return CGSizeZero;
    }
    if (self.heightForHeaderInSectionBlock) {
        id data = [self.dataItems safeObjectWithIndex:section];
        return CGSizeMake(CGRectGetWidth(self.frame), self.heightForHeaderInSectionBlock(section, data));
    }
    return CGSizeMake(CGRectGetWidth(self.frame), self.sectionHeaderHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.viewStyle == VKCollectionViewStyleHorizontal) {
        return CGSizeZero;
    }
    if (self.heightForFooterInSectionBlock) {
        id data = [self.dataItems safeObjectWithIndex:section];
        return CGSizeMake(CGRectGetWidth(self.frame), self.heightForFooterInSectionBlock(section, data));
    }
    return CGSizeMake(CGRectGetWidth(self.frame), self.sectionFooterHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (self.viewStyle != VKCollectionViewStyleGrouped) {
        return nil;
    }
    if (kind == UICollectionElementKindSectionHeader) {
        if (!self.sectionHeaderIdentifier) return nil;
        
        id data = [self.dataItems safeObjectWithIndex:indexPath.section];
        
        if (self.classForHeaderInSectionBlock) {
            Class registerCellClass = self.classForHeaderInSectionBlock(indexPath.section, data);
            self.sectionHeaderIdentifier = NSStringFromClass(registerCellClass);
        }
        
        VKBaseCollectionSectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.sectionHeaderIdentifier forIndexPath:indexPath];
        headerView.clickSectionActionBlock = self.clickSectionActionBlock;
        headerView.indexPath = indexPath;
        headerView.delegate = self.extraDelegate;
        headerView.itemModel = data;
        [headerView updateData];
        return headerView;
        
    } else if (kind == UICollectionElementKindSectionFooter) {
        if (!self.sectionFooterIdentifier) return nil;
        
        id data = [self.dataItems safeObjectWithIndex:indexPath.section];
        
        if (self.classForFooterInSectionBlock) {
            Class registerCellClass = self.classForFooterInSectionBlock(indexPath.section, data);
            self.sectionFooterIdentifier = NSStringFromClass(registerCellClass);
        }
        
        VKBaseCollectionSectionView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:self.sectionFooterIdentifier forIndexPath:indexPath];
        footerView.clickSectionActionBlock = self.clickSectionActionBlock;
        footerView.indexPath = indexPath;
        footerView.delegate = self.extraDelegate;
        footerView.itemModel = data;
        [footerView updateData];
        return footerView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self rowItemsForSectionIndex:indexPath.section][indexPath.row];
    if (self.registerCellClassItems && indexPath.section < self.registerCellClassItems.count) {
        Class registerCellClass = self.registerCellClassItems[indexPath.section];
        self.cellIdentifier = NSStringFromClass(registerCellClass);
    }
    if (self.registerCellClassBlock) {
        Class registerCellClass = self.registerCellClassBlock(indexPath, item);
        self.cellIdentifier = NSStringFromClass(registerCellClass);
    }
    VKBaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    cell.delegate = self.extraDelegate;
    cell.extraData = self.extraData;
    cell.isEditType = self.isEditType;
    cell.clickCellActionBlock = self.clickCellActionBlock;
    cell.indexPath = indexPath;
    cell.itemModel = item;
    [cell updateData];
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item, indexPath);
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.registerCellClassItems && indexPath.section < self.registerCellClassItems.count) {
        Class registerCellClass = self.registerCellClassItems[indexPath.section];
        [self getCellClassConfig:registerCellClass];
    }
    if (self.automaticDimension) {
        id item = [self rowItemsForSectionIndex:indexPath.section][indexPath.row];
        if (self.registerCellClassBlock) {
            self.registerCellClass = self.registerCellClassBlock(indexPath, item);
        }
        [self getCellClassConfig:self.registerCellClass];
        self.itemHeight = [self.registerCellClass autoHeightForItem:item];
    }
    if (self.itemWidth > 0) {
        return CGSizeMake(self.itemWidth, self.itemHeight);
    }
    CGFloat widthSpacing = (self.itemCount - 1) * self.itemSpacing;
    CGFloat width = CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right - widthSpacing;
    CGFloat itemWidth = floor(width / self.itemCount);
    return CGSizeMake(itemWidth, self.itemHeight);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rows = [self rowItemsForSectionIndex:indexPath.section];
    if (!rows || rows.count <= indexPath.row) {
        return;
    }
    id item = rows[indexPath.row];
    if (self.didSelectCellBlock) {
        self.didSelectCellBlock(indexPath, item);
    }
}

- (void)handleCollectionViewTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:location];

    if (indexPath) {
        // 调用 UICollectionView 的 didSelectItemAtIndexPath 方法
        [self collectionView:self didSelectItemAtIndexPath:indexPath];
    }
}


- (NSArray *)rowItemsForSectionIndex:(NSInteger)index {
    if (self.numberOfRowsInSectionBlock) {
        return self.numberOfRowsInSectionBlock(index, self.dataItems);
    }
    if (self.viewStyle != VKCollectionViewStyleGrouped) {
        return self.dataItems;
    } else {
        if (self.dataItems.count <= index) {
            return nil;
        }
        id section = self.dataItems[index];
        if (!self.rowsParseBlock) {
            return section;
        } else {
            return self.rowsParseBlock(section);
        }
    }
}

- (CGFloat)contentHeight {
    NSInteger count = vkLineCount(self.dataItems.count, self.itemCount);
    return count * self.itemHeight + (count - 1) * self.itemLineSpacing;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)setDefalutIndexPath:(NSIndexPath *)defalutIndexPath {
    _defalutIndexPath = defalutIndexPath;
    [self collectionView:self didSelectItemAtIndexPath:defalutIndexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollViewDidScrollBlock) {
        self.scrollViewDidScrollBlock(scrollView);
    }
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    @synchronized(self.dataItems) {
        index = index < 0 ? self.dataItems.count - 1 : index;
        if (self.dataItems.count > index) {
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)selectIndexPath:(NSIndexPath *)indexPath key:(NSString *)key {
    [self.dataItems setValue:@(NO) forKeyPath:key];
    id item = [self rowItemsForSectionIndex:indexPath.section][indexPath.row];
    [item setValue:@(YES) forKey:key];
    [self reloadData];
}

@end
