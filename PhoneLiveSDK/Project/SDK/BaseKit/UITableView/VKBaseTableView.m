//
//  VKBaseTableView.m
//
//  Created by vick on 2020/11/2.
//

#import "VKBaseTableView.h"
#import "VKBaseTableViewCell.h"
#import "VKBaseTableSectionView.h"

@interface VKBaseTableView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSString *sectionHeaderIdentifier;
@property (nonatomic, copy) NSString *sectionFooterIdentifier;
@end

@implementation VKBaseTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    self.backgroundColor = UIColor.clearColor;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.sectionFooterHeight = 0;
    self.sectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.separatorColor = [UIColor groupTableViewBackgroundColor];
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.dataSource = self;
    self.delegate = self;
    self.viewStyle = VKTableViewStyleSingle;
    
    if (@available(iOS 15.0, *)) {
        self.sectionHeaderTopPadding = 0;
    }
}

-(NSMutableArray *)dataItems{
    if (!_dataItems) {
        _dataItems = [NSMutableArray array];
    }
    return _dataItems;
}

#pragma mark - 注册cell
- (void)getCellClassConfig:(Class)registerCellClass item:(id)item {
    if ([registerCellClass respondsToSelector:@selector(autoHeightForItem:)]) {
        CGFloat height = [registerCellClass autoHeightForItem:item];
        self.itemHeight = height;
        self.estimatedRowHeight = item ? 0 : height;
    }
}

- (void)registerCellWithClass:(Class)registerCellClass {
    self.cellIdentifier = NSStringFromClass(registerCellClass);
    NSString *nibPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:self.cellIdentifier ofType:@"nib"];
    if (nibPath) {
        [self registerNib:[UINib nibWithNibName:self.cellIdentifier bundle:[XBundle currentXibBundleWithResourceName:@""]] forCellReuseIdentifier:self.cellIdentifier];
    } else {
        [self registerClass:registerCellClass forCellReuseIdentifier:self.cellIdentifier];
    }
}

- (void)setRegisterCellClass:(Class)registerCellClass {
    _registerCellClass = registerCellClass;
    [self getCellClassConfig:registerCellClass item:nil];
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
    if ([registerSectionHeaderClass respondsToSelector:@selector(itemHeight)]) {
        self.sectionHeaderHeight = [registerSectionHeaderClass itemHeight];
    }
    NSString *nibPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:self.sectionHeaderIdentifier ofType:@"nib"];
    if (nibPath) {
        [self registerNib:[UINib nibWithNibName:self.sectionHeaderIdentifier bundle:[XBundle currentXibBundleWithResourceName:@""]] forHeaderFooterViewReuseIdentifier:self.sectionHeaderIdentifier];
    } else {
        [self registerClass:registerSectionHeaderClass forHeaderFooterViewReuseIdentifier:self.sectionHeaderIdentifier];
    }
}

- (void)setRegisterSectionFooterClass:(Class)registerSectionFooterClass {
    _registerSectionFooterClass = registerSectionFooterClass;
    self.sectionFooterIdentifier = NSStringFromClass(registerSectionFooterClass);
    if ([registerSectionFooterClass respondsToSelector:@selector(itemHeight)]) {
        self.sectionFooterHeight = [registerSectionFooterClass itemHeight];
    }
    NSString *nibPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:self.sectionFooterIdentifier ofType:@"nib"];
    if (nibPath) {
        [self registerNib:[UINib nibWithNibName:self.sectionFooterIdentifier bundle:[XBundle currentXibBundleWithResourceName:@""]] forHeaderFooterViewReuseIdentifier:self.sectionFooterIdentifier];
    } else {
        [self registerClass:registerSectionFooterClass forHeaderFooterViewReuseIdentifier:self.sectionFooterIdentifier];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.sectionNumbers > 0) {
        return self.sectionNumbers;
    }
    return (self.viewStyle == VKTableViewStyleSingle) ? 1 : self.dataItems.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self rowItemsForSectionIndex:section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    VKBaseTableSectionView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.sectionHeaderIdentifier];
    if (!sectionView){
        sectionView = [[VKBaseTableSectionView alloc] initWithReuseIdentifier:self.sectionHeaderIdentifier];
    }
    id sectionItem = nil;
    if (section < self.dataItems.count) {
        sectionItem = self.dataItems[section];
    }
    if (self.sectionHeaderParseBlock) {
        sectionItem = self.sectionHeaderParseBlock(sectionItem);
    }
    sectionView.clickSectionActionBlock = self.clickSectionActionBlock;
    sectionView.delegate = self.extraDelegate;
    sectionView.extraData = self.extraData;
    sectionView.section = section;
    sectionView.itemModel = sectionItem;
    [sectionView updateData];
    return sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    VKBaseTableSectionView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.sectionFooterIdentifier];
    if (!sectionView){
        sectionView = [[VKBaseTableSectionView alloc] initWithReuseIdentifier:self.sectionFooterIdentifier];
    }
    id sectionItem = nil;
    if (section < self.dataItems.count) {
        sectionItem = self.dataItems[section];
    }
    if (self.sectionFooterParseBlock) {
        sectionItem = self.sectionFooterParseBlock(sectionItem);
    }
    sectionView.clickSectionActionBlock = self.clickSectionActionBlock;
    sectionView.delegate = self.extraDelegate;
    sectionView.extraData = self.extraData;
    sectionView.section = section;
    sectionView.itemModel = sectionItem;
    [sectionView updateData];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.heightForHeaderInSectionBlock) {
        return self.heightForHeaderInSectionBlock(section);
    }
    return self.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.heightForFooterInSectionBlock) {
        return self.heightForFooterInSectionBlock(section);
    }
    return self.sectionFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.automaticDimension) {
        return UITableViewAutomaticDimension;
    }
    id item = [self rowItemsForSectionIndex:indexPath.section][indexPath.row];
    if (self.registerCellClassItems && indexPath.section < self.registerCellClassItems.count) {
        Class registerCellClass = self.registerCellClassItems[indexPath.section];
        [self getCellClassConfig:registerCellClass item:item];
    }
    if (self.registerCellClassBlock) {
        Class registerCellClass = self.registerCellClassBlock(indexPath, item);
        [self getCellClassConfig:registerCellClass item:item];
    }
    return self.itemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self rowItemsForSectionIndex:indexPath.section][indexPath.row];
    if (self.registerCellClassItems && indexPath.section < self.registerCellClassItems.count) {
        Class registerCellClass = self.registerCellClassItems[indexPath.section];
        self.cellIdentifier = NSStringFromClass(registerCellClass);
    }
    if (self.registerCellClassBlock) {
        Class registerCellClass = self.registerCellClassBlock(indexPath, item);
        self.cellIdentifier = NSStringFromClass(registerCellClass);
    }
    if (self.configureCellBlock) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
        self.configureCellBlock(cell, item, indexPath);
        return cell;
    } else {
        VKBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
        cell.delegate = self.extraDelegate;
        cell.extraData = self.extraData;
        cell.clickCellActionBlock = self.clickCellActionBlock;
        cell.indexPath = indexPath;
        cell.itemModel = item;
        [cell updateData];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.commitEditingBlock) {
            self.commitEditingBlock(tableView, indexPath);
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.deleteTitleBlock) {
        return self.deleteTitleBlock(tableView, indexPath);
    }
    return @"Delete";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.canEditRowBlock) {
        return self.canEditRowBlock(tableView, indexPath);
    }
    return NO;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *rows = [self rowItemsForSectionIndex:indexPath.section];
    if (!rows || rows.count <= indexPath.row) {
        return;
    }
    id item = rows[indexPath.row];
    if (self.didSelectCellBlock) {
        self.didSelectCellBlock(indexPath, item);
    }
}

- (NSArray *)rowItemsForSectionIndex:(NSInteger)index {
    if (self.numberOfRowsInSectionBlock) {
        return self.numberOfRowsInSectionBlock(index, self.dataItems);
    }
    if (self.viewStyle == VKTableViewStyleSingle) {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.willDisplayCellBlock) {
        self.willDisplayCellBlock(tableView, cell, indexPath);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)setDefalutIndexPath:(NSIndexPath *)defalutIndexPath {
    _defalutIndexPath = defalutIndexPath;
    [self tableView:self didSelectRowAtIndexPath:defalutIndexPath];
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
            [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)selectIndexPath:(NSIndexPath *)indexPath key:(NSString *)key {
    [self.dataItems setValue:@(NO) forKeyPath:key];
    id item = [self rowItemsForSectionIndex:indexPath.section][indexPath.row];
    [item setValue:@(YES) forKey:key];
    [self reloadData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollViewDidEndDeceleratingBlock) {
        self.scrollViewDidEndDeceleratingBlock(scrollView);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollViewDidEndDraggingBlock) {
        self.scrollViewDidEndDraggingBlock(scrollView, decelerate);
    }
}

@end
