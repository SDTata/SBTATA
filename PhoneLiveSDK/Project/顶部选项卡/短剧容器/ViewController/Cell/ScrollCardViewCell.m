//
//  ScrollCardViewCell.m
//  NewDrama
//
//  Created by s5346 on 2024/6/28.
//

#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "ScrollCardViewCell.h"
#import "ScrollCardFlowLayout.h"
#import "ScrollCardItemCell.h"

#define DefaultPageControlSpace 4
#define DefaultPageControlWidth 20
@interface ScrollCardViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, strong) JXPageControlJump *pageControl;
@property(nonatomic, strong) NSMutableArray<HomeRecommendSkit*> *dataSources;

@end

@implementation ScrollCardViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * 0.7;
        [self setupViews];
    }
    return self;
}

- (void)calculatePageIndex {
    CGFloat index = round(self.collectionView.contentOffset.x / self.itemWidth);
    CGFloat movePositionX = self.itemWidth * index;
    [self.collectionView setContentOffset:CGPointMake(movePositionX, 0) animated:YES];
    self.pageControl.progress = index;
}

- (void)update:(NSArray<HomeRecommendSkit*>*)models {
    if (![self isNeedUpdate:models]) {
        [self changePageControlSize];
        return;
    }

    self.dataSources = [NSMutableArray arrayWithArray:models];
    self.pageControl.numberOfPages = models.count;

    [self changePageControlSize];

    [self.collectionView reloadData];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int index = (int)floor(models.count / 2.0);
        CGFloat movePositionX = self.itemWidth * index;
        [self.collectionView setContentOffset:CGPointMake(movePositionX, 0) animated:NO];
        [self calculatePageIndex];
    });
}

- (BOOL)isNeedUpdate:(NSArray<HomeRecommendSkit*>*)models {
    BOOL isNeed = NO;
    for (int i = 0; i<models.count; i++) {
        if (self.dataSources.count <= i) {
            isNeed = YES;
            break;
        }
        HomeRecommendSkit *model = self.dataSources[i];
        HomeRecommendSkit *newModel = models[i];
        if (newModel.skit_id != model.skit_id) {
            isNeed = YES;
            break;
        }
    }
    return isNeed;
}

- (void)changePageControlSize {
    CGFloat number = self.pageControl.numberOfPages;
    if (number <= 0) {
        return;
    }

    CGFloat viewWidth = _window_width - 20;
    CGFloat totalPageControlWidth = number * DefaultPageControlWidth;
    CGFloat totalPageControlSpace = MAX(number - 1, 0) * DefaultPageControlSpace;
    CGFloat totalWidth = totalPageControlWidth + totalPageControlSpace;

    if (totalWidth <= viewWidth) {
        return;
    }

    CGFloat adjustWidth = DefaultPageControlWidth;
    CGFloat adjustSpace = 2;
    CGFloat newTotalWidth = adjustWidth * number + adjustSpace * number;
    if (newTotalWidth > viewWidth) {
        adjustWidth = MAX((newTotalWidth - adjustSpace * number) / number, 5);
    }

    newTotalWidth = adjustWidth * number + adjustSpace * number;
    if (newTotalWidth > viewWidth) {
        adjustWidth = MAX((viewWidth - adjustSpace * number) / number, 5);
    }

    self.pageControl.indicatorSize = CGSizeMake(adjustWidth, 5);
    self.pageControl.columnSpacing = adjustSpace;
}

+ (CGFloat)height {
    return RatioBaseWidth390(305);
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(-10);
        make.left.right.bottom.equalTo(self.contentView);
    }];

    [self.contentView addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(self.contentView.mas_width);
        make.bottom.equalTo(self.collectionView).offset(-3);
    }];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat itemHeight = ScrollCardViewCell.height;
        CGFloat padding = (CGRectGetWidth([[UIScreen mainScreen] bounds]) - self.itemWidth) / 2;
        ScrollCardAttributesAnimator *animator = [[ScrollCardAttributesAnimator alloc] initWithScaleRate:0.2 itemSpacingRate:-0.05];
        ScrollCardFlowLayout *layout = [[ScrollCardFlowLayout alloc] initWithAnimator:animator scrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 0;
        layout.itemSize = CGSizeMake(self.itemWidth, itemHeight);
        layout.sectionInset = UIEdgeInsetsMake(0, padding, 0, padding);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;

        [_collectionView registerClass:[ScrollCardItemCell class] forCellWithReuseIdentifier:@"ScrollCardItemCell"];
    }
    return _collectionView;
}

- (JXPageControlJump *)pageControl {
    if (!_pageControl) {
        _pageControl = [[JXPageControlJump alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.isInactiveHollow = YES;
        _pageControl.activeColor = RGB_COLOR(@"#9F57DF", 1);
        _pageControl.inactiveColor = RGB_COLOR(@"#9F57DF", 1);
        _pageControl.indicatorSize = CGSizeMake(DefaultPageControlWidth, 5);
        _pageControl.columnSpacing = DefaultPageControlSpace;
        _pageControl.progress = 0;
    }
    return _pageControl;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ScrollCardItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScrollCardItemCell" forIndexPath:indexPath];

    if (self.dataSources.count > indexPath.item) {
        [cell update:self.dataSources[indexPath.item]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tapIndex) {
        self.tapIndex(indexPath.item);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self calculatePageIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self calculatePageIndex];
}
@end
