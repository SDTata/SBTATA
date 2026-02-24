//
//  DramaHomeHistoryCell.m
//  DramaTest
//
//  Created by s5346 on 2024/5/3.
//

#import "DramaHomeHistoryCell.h"
#import "DramaHomeVideoCell.h"

@interface DramaHomeHistoryCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIView *moreView;

@end

@implementation DramaHomeHistoryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setDramaHistoryInfoList:(NSMutableArray<DramaInfoModel *> *)dramaHistoryInfoList {
    self.moreView.hidden = dramaHistoryInfoList.count < 6;
    _dramaHistoryInfoList = dramaHistoryInfoList;
    [self.collectionView reloadData];
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.contentView.layer.cornerRadius = 10;

    UIView *leftLineView = [[UIView alloc] init];
    leftLineView.backgroundColor = RGB_COLOR(@"#9C00BE", 1);
    [self.contentView addSubview:leftLineView];
    [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(17);
        make.top.equalTo(self.contentView).offset(12);
        make.width.equalTo(@2);
        make.height.equalTo(@12);
    }];

    [self.contentView addSubview:self.moreView];
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-17);
        make.centerY.equalTo(leftLineView);
        make.height.equalTo(@34);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = YZMsg(@"DramaHomeHistoryCell_history_title");
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftLineView).offset(5);
        make.centerY.equalTo(leftLineView);
        make.right.lessThanOrEqualTo(self.moreView.mas_left).offset(-5);
    }];



    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftLineView.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (UICollectionView *)createCollectionView {
//    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
//        __typeof(self) strongSelf = self;
//        if (!strongSelf) { return nil; }
//
//        return [strongSelf historyLayoutSection];
//    }];


    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[DramaHomeVideoCell self] forCellWithReuseIdentifier:NSStringFromClass([DramaHomeVideoCell class])];

    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;

    return collectionView;
}

- (NSCollectionLayoutSection *)historyLayoutSection {
    NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:RatioBaseWidth360(103)] heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]];
    NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
    NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:RatioBaseWidth360(103)] heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]];
    NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitems:@[item]];
    __block NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
    section.interGroupSpacing = 5;
    section.contentInsets = NSDirectionalEdgeInsetsMake(0, 10, 0, 10);
    section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;

    NSCollectionLayoutSize *footerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:44] heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]];
    NSCollectionLayoutBoundarySupplementaryItem *footer = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:footerSize elementKind:UICollectionElementKindSectionFooter alignment:NSRectAlignmentTrailing];
    footer.zIndex = 0;
    section.boundarySupplementaryItems = @[footer];

    return section;
}

#pragma mark - Action
- (void)tapMore {
    if ([self.delegate respondsToSelector:@selector(dramaHomeHistoryCellForTapMore)]) {
        [self.delegate dramaHomeHistoryCellForTapMore];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dramaHistoryInfoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DramaHomeVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DramaHomeVideoCell class]) forIndexPath:indexPath];
    if (self.dramaHistoryInfoList.count > indexPath.item) {
        cell.model = self.dramaHistoryInfoList[indexPath.item];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.dramaHistoryInfoList.count) {
        return;
    }
    DramaInfoModel *model = self.dramaHistoryInfoList[indexPath.item];
    if ([self.delegate respondsToSelector:@selector(dramaHomeHistoryCellForTapDrama:)]) {
        [self.delegate dramaHomeHistoryCellForTapDrama:model];
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

- (UIView *)moreView {
    if (!_moreView) {
        _moreView = [[UIView alloc] init];

        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [ImageBundle imagewithBundleName:@"wd_tx_jt"];
        [_moreView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@7);
            make.height.equalTo(@12);
            make.right.equalTo(_moreView);
            make.centerY.equalTo(_moreView);
        }];

        UILabel *moreLabel = [[UILabel alloc] init];
        moreLabel.font = [UIFont systemFontOfSize:15];
        moreLabel.text = @"More";
        moreLabel.textColor = [UIColor blackColor];
        [_moreView addSubview:moreLabel];
        [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_moreView);
            make.centerY.equalTo(_moreView);
            make.right.equalTo(arrow.mas_left).offset(-4);
        }];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMore)];
        [_moreView addGestureRecognizer:tap];
    }
    return _moreView;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(RatioBaseWidth360(103), collectionView.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(44, collectionView.height);
}
@end
