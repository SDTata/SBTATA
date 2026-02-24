//
//  YBUserInfoContentView.m
//  phonelive2
//
//  Created by user on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YBUserInfoContentView.h"
#import "YBUserInfoContentCell.h"

@implementation YBUserInfoContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 30;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowColor = RGB_COLOR(@"#828991", 0.15).CGColor;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 3;

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
    YBUserInfoContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YBUserInfoContentCell" forIndexPath:indexPath];
    [cell.contentView sizeToFit];
    [cell setupData:self.datas[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.datas[indexPath.row];
    [self.delegate didSelected: data];
}

#pragma mark - Get

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemSpacing = 0.0; // 每个 item 之间的间距
        layout.minimumInteritemSpacing = itemSpacing; // 横向最小间距
        layout.minimumLineSpacing = itemSpacing; // 纵向最小间距
//        layout.sectionInset = UIEdgeInsetsMake(itemSpacing, itemSpacing, itemSpacing + 4, itemSpacing); // 设置 section 的边距
        layout.sectionInset = UIEdgeInsetsMake(10, 18, 10, 18);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.userInteractionEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[YBUserInfoContentCell class] forCellWithReuseIdentifier:@"YBUserInfoContentCell"];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

    }
    return _collectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat itemSpacing = 10.0; // 每个 item 之间的间距
//    CGFloat itemsInRow = 4; // 每行的 item 数量
//    CGFloat width = (self.collectionView.frame.size.width - (itemsInRow + 1) * itemSpacing) / itemsInRow;
//    CGFloat height = 47;
//    if (width < 0) width = 0;
//    if (height < 0) height = 0;
//    return CGSizeMake(width, height);
    CGFloat width = ((self.collectionView.width - 18*2) / 4.0) - 1;
    CGFloat height = width * 75.0 / 85.0;
    return CGSizeMake(width, height);
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    [self.collectionView reloadData];
}
@end
