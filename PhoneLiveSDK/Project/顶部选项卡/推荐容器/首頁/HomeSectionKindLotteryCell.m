//
//  HomeSectionKindLotteryCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "HomeSectionKindLotteryCell.h"
#import <UMCommon/UMCommon.h>

@interface HomeSectionKindLotteryCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) HomeRecommendLotteriesModel *dataModel;
@end

@implementation HomeSectionKindLotteryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(HomeRecommendLotteriesModel*)model {
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
    return 78;
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
        layout.itemSize = CGSizeMake(HomeSectionKindLotteryCell.height, HomeSectionKindLotteryCell.height);
        [layout invalidateLayout];
        return;
    }
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat width = (_window_width - ((self.dataModel.layout_column - 1) * HomeSectionKindLotteryContentViewCell.minimumLineSpacing) - 30)/self.dataModel.layout_column;
    layout.itemSize = CGSizeMake(width, width * HomeSectionKindLotteryContentViewCell.ratio);
    [layout invalidateLayout];
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor clearColor];

    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.contentView layoutIfNeeded];
}

- (UICollectionView *)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(HomeSectionKindLotteryCell.height, HomeSectionKindLotteryCell.height);
    layout.sectionInset = UIEdgeInsetsMake(0, 14, 0, 14);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = HomeSectionKindLotteryContentViewCell.minimumLineSpacing;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;

    [collectionView registerClass:[HomeSectionKindLotteryContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindLotteryContentViewCell"];

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
    HomeSectionKindLotteryContentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindLotteryContentViewCell" forIndexPath:indexPath];
    if (self.dataModel.data.count > indexPath.item) {
        [cell update:self.dataModel.data[indexPath.item]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataModel.data.count <= indexPath.item) {
        return;
    }
    
    NSString *type_name = [self.dataModel.className isEqualToString:@"game"] ? @"区块链" : @"彩票";
    NSString *type_name1 = [NSString stringWithFormat:@"%@%@",type_name, self.dataModel.isScroll ? @"" : @"1"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type_name":type_name1};
    [MobClick event:@"home_recommend_coupons_click" attributes:dict];

    HomeRecommendLotteries *model = self.dataModel.data[indexPath.item];
    // 自动转换额度
    if(model.plat && model.plat.length > 0){
        UIViewController *nav = [MXBADelegate sharedAppDelegate].topViewController;
        [GameToolClass enterGame:model.plat menueName:@"" kindID:model.kindID iconUrlName:model.icon parentViewController:nav autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

        } fail:^{

        }];
    }else{
        [MBProgressHUD showError:YZMsg(@"GameListVC_UnknowGamePlat")];
    }
}

@end

