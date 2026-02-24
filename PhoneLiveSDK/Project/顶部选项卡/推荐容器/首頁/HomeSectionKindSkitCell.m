//
//  HomeSectionKindSkitCell.m
//  NewDrama
//
//  Created by s5346 on 2024/7/2.
//

#import "HomeSectionKindSkitCell.h"
#import "SkitPlayerVC.h"
#import <UMCommon/UMCommon.h>

@interface HomeSectionKindSkitCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) HomeRecommendSkitModel *dataModel;

@end

@implementation HomeSectionKindSkitCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(HomeRecommendSkitModel*)model {
    if (model.isScroll == NO) {
        NSArray *limitedArray = model.data;
        int maxCount = model.layout_row * model.layout_column;
        if (model.data.count > maxCount) {
            limitedArray = [model.data subarrayWithRange:NSMakeRange(0, maxCount)];
        } else {
            limitedArray = model.data;
        }
        model.data = limitedArray;
    }

    self.dataModel = model;
    [self updateCollectionLayout];
    [self.collectionView reloadData];
}

+(CGFloat)height {
    return HomeSectionKindSkitCell.getCellWidth * HomeSectionKindSkitContentViewCell.ratio;
}

+ (CGFloat)getCellWidth {
    return _window_width / 3.8;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.dataModel = nil;
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [self.collectionView reloadData];
}

- (void)updateCollectionLayout {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (self.dataModel.isScroll) {
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(HomeSectionKindSkitCell.getCellWidth, HomeSectionKindSkitCell.height);
        [layout invalidateLayout];
        return;
    }
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat width = (_window_width - ((self.dataModel.layout_column - 1) * HomeSectionKindSkitContentViewCell.minimumLineSpacing) - 30)/self.dataModel.layout_column;
    layout.itemSize = CGSizeMake(width, width * HomeSectionKindSkitContentViewCell.ratio);
    [layout invalidateLayout];
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor clearColor];

    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UICollectionView *)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(HomeSectionKindSkitCell.getCellWidth, HomeSectionKindSkitCell.height);
    layout.sectionInset = UIEdgeInsetsMake(0, 14, 0, 14);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = HomeSectionKindSkitContentViewCell.minimumLineSpacing;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;

    [collectionView registerClass:[HomeSectionKindSkitContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindSkitContentViewCell"];

    collectionView.dataSource = self;
    collectionView.delegate = self;

    return collectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataModel.data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeSectionKindSkitContentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindSkitContentViewCell" forIndexPath:indexPath];
    if (self.dataModel.data.count > indexPath.item) {
        [cell update:self.dataModel.data[indexPath.item]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SkitPlayerVC *viewController = [SkitPlayerVC new];
    viewController.skitArray = self.dataModel.data;
    viewController.skitIndex = indexPath.row;
    viewController.hasTabbar = YES;
    [[MXBADelegate sharedAppDelegate] pushViewController:viewController cell:[collectionView cellForItemAtIndexPath:indexPath] hidesBottomBarWhenPushed:NO];

    _weakify(self)
    viewController.currentIndexBlock = ^(NSInteger currentIndex) {
        _strongify(self)
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:indexPath.section];
        if ([self.collectionView numberOfItemsInSection:indexPath.section] > currentIndex) {
            [self.collectionView scrollToItemAtIndexPath:newIndexPath
                                   atScrollPosition:UICollectionViewScrollPositionNone
                                           animated:YES];
        }
    };

    viewController.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSInteger index) {
        _strongifyReturn(self)
        return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:indexPath.section]].contentView;;
    };
    
    NSString *type_name = [NSString stringWithFormat:@"短剧%@",self.dataModel.isScroll ? @"" : @"1"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type_name":type_name};
    [MobClick event:@"home_recommend_coupons_click" attributes:dict];
}

@end
