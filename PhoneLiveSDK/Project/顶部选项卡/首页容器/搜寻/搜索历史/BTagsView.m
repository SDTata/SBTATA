//
//  BTagsView.m
//  phonelive2
//
//  Created by user on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BTagsView.h"
#import "BTagCollectionViewCell.h"
#import "HomeSearchRecordCell.h"

@implementation BTagsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTagCollectionViewCell" forIndexPath:indexPath];
    [cell setupData:self.datas[indexPath.row]];
    [cell.contentView sizeToFit];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.datas[indexPath.row];
    return [BTagCollectionViewCell getItemSizeWothText:text];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.datas[indexPath.row];
    if ([text isEqualToString:@"_<_"] || [text isEqualToString:@"_>_"]) {
        [common saveSearchRedcordExpand:[text isEqualToString:@"_<_"]];
        [self setDatas:[common getSearchRedcord]];
        [self.delelgate didSelecedTag: @""];
    } else {
        [self.delelgate didSelecedTag: text];
    }
}

#pragma mark - Get

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        // 设置列表信息居左显示
        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        layout.minimumInteritemSpacing = 6.0;
        layout.minimumLineSpacing = 6.0;
        // ⚠️ 测试下来 estimatedItemSize + preferredLayoutAttributesFittingAttributes 存在各种机型和版本兼容问题，而且对子视图的布局约束很严格，稍有失误可能会出现各种异常
        // 暂用 sizeForItemAtIndexPath + systemLayoutSizeFittingSize
//        layout.estimatedItemSize = CGSizeMake(40.0, 30.0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.userInteractionEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[BTagCollectionViewCell class] forCellWithReuseIdentifier:@"BTagCollectionViewCell"];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    if (datas.count >= 6) {
        if ([common getSearchRedcordExpand]) {
            NSMutableArray *hasMoreArr = [NSMutableArray arrayWithArray:[common getSearchRedcord]];
            [hasMoreArr addObject:@"_>_"]; //上
            _datas = hasMoreArr;
        } else {
            NSMutableArray *hasMoreArr = [NSMutableArray new];
            for (int i = 0; i < 5; i++) {
                [hasMoreArr addObject:datas[i]];
            }
            [hasMoreArr addObject:@"_<_"]; //下
            _datas = hasMoreArr;
        }
    } else {
        _datas = datas;
    }
    [self.collectionView reloadData];
}
@end
