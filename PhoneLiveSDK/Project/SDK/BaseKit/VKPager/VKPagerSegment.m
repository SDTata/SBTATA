//
//  VKPagerSegment.m
//
//  Created by vick on 2021/2/23.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "VKPagerSegment.h"

#pragma mark -
#pragma mark - 自定义Model
@interface VKCategoryBorderCellModel : JXCategoryTitleImageCellModel

@property (nonatomic, strong) UIColor *cellBorderNormalColor;
@property (nonatomic, strong) UIColor *cellBorderSelectedColor;
@property (nonatomic, assign) CGFloat cellBorderLineWidth;
@property (nonatomic, assign) CGFloat cellBorderCornerRadius;

@end

@implementation VKCategoryBorderCellModel

@end


#pragma mark -
#pragma mark - 自定义Cell
@interface VKCategoryBorderCell : JXCategoryTitleImageCell

@end

@implementation VKCategoryBorderCell

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];
    VKCategoryBorderCellModel *myCellModel = (VKCategoryBorderCellModel *)cellModel;
    self.contentView.layer.borderWidth = myCellModel.cellBorderLineWidth;
    self.contentView.layer.cornerRadius = myCellModel.cellBorderCornerRadius;
    self.contentView.layer.borderColor = myCellModel.isSelected ? myCellModel.cellBorderSelectedColor.CGColor : myCellModel.cellBorderNormalColor.CGColor;
}

@end


#pragma mark -
#pragma mark - 自定义View
@implementation VKPagerSegment

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.delegate = self;
    self.selectedAnimationEnabled = YES;
    
    [self addSubview:self.bottomSeparatorView];
    self.bottomSeparatorView.backgroundColor = UIColor.lightGrayColor;
    self.bottomSeparatorView.hidden = YES;
    
    self.imageSize = CGSizeZero;
    self.titleImageSpacing = 0;
}

- (UIView *)bottomSeparatorView {
    if (!_bottomSeparatorView) {
        _bottomSeparatorView = [UIView new];
        _bottomSeparatorView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1);
        _bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _bottomSeparatorView;
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (self.clickIndexBlock) {
        self.clickIndexBlock(index);
    }
}

- (NSString *)selectedTitle {
    if (self.selectedIndex < self.titles.count) {
        return self.titles[self.selectedIndex];
    }
    return nil;
}

- (id)selectedValue {
    if (self.selectedIndex < self.values.count) {
        return self.values[self.selectedIndex];
    }
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bottomSeparatorView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1);
    
    if (self.equalWidth) {
        CGFloat width = CGRectGetWidth(self.frame);
        CGFloat space = self.cellSpacing * (self.titles.count - 1);
        self.cellWidth = (width - space) / self.titles.count;
        [self reloadDataWithoutListContainer];
    }
}

#pragma mark - 重写数据处理
- (Class)preferredCellClass {
    return [VKCategoryBorderCell class];
}

- (void)refreshDataSource {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < self.titles.count; i++) {
        VKCategoryBorderCellModel *cellModel = [[VKCategoryBorderCellModel alloc] init];
        [tempArray addObject:cellModel];
    }
    self.dataSource = tempArray;
    
    NSMutableArray *types = [NSMutableArray array];
    for (int i = 0; i < self.titles.count; i++) {
        if (!self.imageTypes || self.imageTypes.count == 0) {
            [types addObject:@(JXCategoryTitleImageType_LeftImage)];
        } else if (i < self.imageTypes.count) {
            [types addObject:self.imageTypes[i]];
        } else {
            [types addObject:self.imageTypes.lastObject];
        }
    }
    self.imageTypes = types;
}

- (void)refreshCellModel:(JXCategoryBaseCellModel *)cellModel index:(NSInteger)index {
    [super refreshCellModel:cellModel index:index];
    VKCategoryBorderCellModel *myModel = (VKCategoryBorderCellModel *)cellModel;
    myModel.cellBorderNormalColor = self.cellBorderNormalColor;
    myModel.cellBorderSelectedColor = self.cellBorderSelectedColor;
    myModel.cellBorderLineWidth = self.cellBorderLineWidth;
    myModel.cellBorderCornerRadius = self.cellBorderCornerRadius;
}

@end
