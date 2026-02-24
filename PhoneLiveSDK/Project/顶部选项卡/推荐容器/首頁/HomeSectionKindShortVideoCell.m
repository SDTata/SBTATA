//
//  HomeSectionKindShortVideoCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/26.
//

#import "HomeSectionKindShortVideoCell.h"
#import "ShortVideoListViewController.h"
#import <UMCommon/UMCommon.h>

@interface HomeSectionKindShortVideoCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) HomeRecommendShortVideoModel *dataModel;

@end

@implementation HomeSectionKindShortVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(HomeRecommendShortVideoModel*)model {
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
    return HomeSectionKindShortVideoCell.getCellWidth * HomeSectionKindShortVideoContentViewCell.ratio;
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
        layout.itemSize = CGSizeMake(HomeSectionKindShortVideoCell.getCellWidth, HomeSectionKindShortVideoCell.height);
        [layout invalidateLayout];
        return;
    }
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat width = (_window_width - ((self.dataModel.layout_column - 1) * HomeSectionKindShortVideoContentViewCell.minimumLineSpacing) - 30)/self.dataModel.layout_column;
    layout.itemSize = CGSizeMake(width, width * HomeSectionKindShortVideoContentViewCell.ratio);
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
    layout.itemSize = CGSizeMake(HomeSectionKindShortVideoCell.getCellWidth, HomeSectionKindShortVideoCell.height);
    layout.sectionInset = UIEdgeInsetsMake(0, 14, 0, 14);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = HomeSectionKindShortVideoContentViewCell.minimumLineSpacing;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;

    [collectionView registerClass:[HomeSectionKindShortVideoContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell"];

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
    HomeSectionKindShortVideoContentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindShortVideoContentViewCell" forIndexPath:indexPath];
    if (self.dataModel.data.count > indexPath.item) {
        [cell update:self.dataModel.data[indexPath.item]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(homeSectionKindShortVideoCellDelegateForHotGotoShortVideo:)]) {
        if (self.dataModel.data.count <= indexPath.item) {
            return;
        }
        ShortVideoModel *model = self.dataModel.data[indexPath.item];
        [self.delegate homeSectionKindShortVideoCellDelegateForHotGotoShortVideo:model];
        NSString *type_name = [NSString stringWithFormat:@"短视频%@",self.dataModel.isScroll ? @"" : @"1"];
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"type_name":type_name};
        [MobClick event:@"home_recommend_coupons_click" attributes:dict];
    }
}

@end
