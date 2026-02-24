//
//  HomeSectionKindCarouselCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "HomeSectionKindCarouselCell.h"
#import "HomeSectionKindCarouselContentViewCell.h"
#import <UMCommon/UMCommon.h>

@interface HomeSectionKindCarouselCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) HomeRecommendAdsModel *dataModel;
@property (nonatomic, strong) JXPageControlJump *pageControl;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemSpace;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, strong) NSTimer *autoScrollTimer;

@end

@implementation HomeSectionKindCarouselCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemWidth = RatioBaseWidth390(335);
        self.itemHeight = RatioBaseWidth390(120); // 修改为120，确保不超过CollectionView高度
        self.itemSpace = RatioBaseWidth390(8);
        [self setupViews];
    }
    return self;
}

- (void)update:(HomeRecommendAdsModel*)model {
    self.collectionView.scrollEnabled = NO;
    self.dataModel = [model copy];
    if (model.data.count > 1) {
        self.collectionView.scrollEnabled = YES;
        NSMutableArray<HomeRecommendAds*> *tempArray = [NSMutableArray arrayWithArray:model.data];
        [tempArray insertObject:model.data.lastObject atIndex:0];
        [tempArray addObject:model.data.firstObject];
        self.dataModel.data = tempArray;
    }

    NSInteger count = self.dataModel.data.count;
    self.pageControl.numberOfPages = MAX(count - 2, 0);
    [self.collectionView reloadData];

    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (strongSelf.dataModel.data.count >= 2) {
            [strongSelf scrollToItemAtIndex:1 animated:NO];
            [strongSelf startAutoScroll];
        }
    });
}

+(CGFloat)height {
    return RatioBaseWidth390(140); // 增加高度，确保有足够空间容纳CollectionView和pageControl
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stopAutoScroll];
}

#pragma mark - Private
- (void)calculatePageIndex {
    CGFloat index = round(self.collectionView.contentOffset.x / (self.itemWidth + self.itemSpace));
    if (index > self.dataModel.data.count - 2) {
        index = 1;
    } else if (index <= 0) {
        index = self.dataModel.data.count - 2;
    }
    self.pageControl.progress = index - 1;
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    CGFloat pageWidth = self.itemWidth + self.itemSpace;
    CGFloat targetX = index * pageWidth;

    [self.collectionView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}

- (void)judgementInfinite {
    CGFloat index = round(self.collectionView.contentOffset.x / (self.itemWidth + self.itemSpace));
    if (index == 0) {
        [self scrollToItemAtIndex:self.dataModel.data.count - 2 animated:NO];
    } else if (index == self.dataModel.data.count - 1) {
        [self scrollToItemAtIndex:1 animated:NO];
    }
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor clearColor];

    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.itemHeight));
        make.left.right.equalTo(self.contentView);
    }];

    [self.contentView addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(RatioBaseWidth390(10));
        make.left.right.equalTo(self.contentView).inset(RatioBaseWidth390(10));
    }];
}

- (UICollectionView *)createCollectionView {
    CustomFlowLayout *layout = [[CustomFlowLayout alloc] init];
    layout.minimumLineSpacing = self.itemSpace;
    layout.itemSize = CGSizeMake(self.itemWidth, self.itemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [layout setSectionInset:UIEdgeInsetsMake(0, RatioBaseWidth390(30), 0, RatioBaseWidth390(30))];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectionView.clipsToBounds = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = NO;

    [collectionView registerClass:[HomeSectionKindCarouselContentViewCell class] forCellWithReuseIdentifier:@"HomeSectionKindCarouselContentViewCell"];

    return collectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

- (JXPageControlJump *)pageControl {
    if (!_pageControl) {
        _pageControl = [[JXPageControlJump alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.isInactiveHollow = YES;
        _pageControl.activeColor = [UIColor blackColor];
        _pageControl.inactiveColor = [UIColor grayColor];
        _pageControl.indicatorSize = CGSizeMake(20, 5);
        _pageControl.progress = 0;
    }
    return _pageControl;
}

#pragma mark - Auto scroll
- (void)startAutoScroll {
    if (self.dataModel.data.count <= 1) {
        return;
    }
    [self stopAutoScroll];
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
}

- (void)stopAutoScroll {
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
}

- (void)scrollToNextPage {
    NSInteger currentIndex = round(self.collectionView.contentOffset.x / (self.itemWidth + self.itemSpace));
    NSInteger nextIndex = currentIndex + 1;
    [self scrollToItemAtIndex:nextIndex animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataModel.data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeSectionKindCarouselContentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeSectionKindCarouselContentViewCell" forIndexPath:indexPath];
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
    HomeRecommendAds *model = self.dataModel.data[indexPath.item];
    if (model.url.length <= 0) {
        return;
    }
    NSDictionary *data = @{@"scheme": model.url, @"showType": minnum(model.show_type)};
    [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
    NSString *type_name = [NSString stringWithFormat:@"轮播图%li",(long)indexPath.item+1];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type_name":type_name};
    [MobClick event:@"home_recommend_coupons_click" attributes:dict];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self calculatePageIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startAutoScroll];
    if (!decelerate) {
        [self calculatePageIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self judgementInfinite];
    [self calculatePageIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoScroll];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self judgementInfinite];
    [self calculatePageIndex];
}

@end

@implementation CustomFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat pageWidth = self.itemSize.width + self.minimumLineSpacing;
    CGFloat proposedPage = proposedContentOffset.x / pageWidth;

    CGFloat targetPage;
    if (velocity.x == 0) {
        targetPage = round(proposedPage);
    } else {
        targetPage = velocity.x > 0 ? ceil(proposedPage) : floor(proposedPage);
    }

    CGFloat targetX = targetPage * pageWidth;
    return CGPointMake(targetX, proposedContentOffset.y);
}

@end
