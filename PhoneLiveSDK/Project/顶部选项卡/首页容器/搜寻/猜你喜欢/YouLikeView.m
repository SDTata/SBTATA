//
//  YouLikeView.m
//  phonelive2
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YouLikeView.h"
#import "YouLikeCollectionViewCell.h"

@implementation YouLikeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YouLikeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YouLikeCollectionViewCell" forIndexPath:indexPath];
    [cell.contentView sizeToFit];
    [cell setupData:self.datas[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.datas[indexPath.row];
    [self.delelgate didSelecedTag: text];
}

#pragma mark - Get

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0; // 設置行間距
        layout.minimumLineSpacing = 0; // 設置列間距
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.userInteractionEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[YouLikeCollectionViewCell class] forCellWithReuseIdentifier:@"YouLikeCollectionViewCell"];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

    }
    return _collectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width / 2, 25);
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    [self.collectionView reloadData];
}
@end
