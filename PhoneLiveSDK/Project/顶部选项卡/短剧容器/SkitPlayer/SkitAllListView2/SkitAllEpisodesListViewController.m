//
//  SkitAllEpisodesListViewController.m
//  phonelive2
//
//  Created by s5346 on 2025/3/18.
//  Copyright © 2025 toby. All rights reserved.
//

#import "SkitAllEpisodesListViewController.h"
#import "SkitAllEpisodesGroupCell.h"
#import "SkitAllEpisodesCell.h"

@interface SkitAllEpisodesListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *floatingView;
@property(nonatomic, strong) UIView *headerContainer;
@property(nonatomic, strong) UIImageView *coverImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UILabel *episodesUpdateLabel;
@property(nonatomic, strong) UIView *totalEpisodesContainer;
@property(nonatomic, strong) UILabel *totalEpisodesLabel;
@property(nonatomic, strong) NSArray<SkitVideoInfoModel*> *videoInfoModels;
@property(nonatomic, strong) NSString *selectVideoId;
@property(nonatomic, strong) HomeRecommendSkit *infoModel;
@property(nonatomic, strong) UICollectionView *groupCollectionView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *groupArray;
@property(nonatomic, strong) NSArray<NSArray*> *selectGroupArray;
@property(nonatomic, assign) int currentGroup;

@end

#define GroupCount 30
#define GroupRows 6
#define GroupColumns GroupCount/GroupRows
#define MinimumLineSpacing RatioBaseWidth390(14) // 行間距
#define MinimumInteritemSpacing RatioBaseWidth390(9) // 列間距
#define SectionInset RatioBaseWidth390(15)

@interface PagedCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGSize pageSize;
@end

@implementation PagedCollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = MinimumLineSpacing;
    self.minimumInteritemSpacing = MinimumInteritemSpacing;

    CGFloat width = (self.pageSize.width - (MinimumInteritemSpacing*(GroupRows - 1) + SectionInset*2))/GroupRows;
    CGFloat height = width;
    self.itemSize = CGSizeMake(width, height);

    CGFloat leftInset = SectionInset;
    CGFloat rightInset = SectionInset;
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    self.sectionInset = UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 使用新的计算方法
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }
    }
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;

    NSInteger itemsPerRow = GroupRows;
    NSInteger row = item / itemsPerRow;
    NSInteger column = item % itemsPerRow;

    CGFloat x = section * self.pageSize.width + self.sectionInset.left + column * (self.itemSize.width + self.minimumInteritemSpacing);
    CGFloat y = self.sectionInset.top + row * (self.itemSize.height + self.minimumLineSpacing);
    attributes.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
    
    return attributes;
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    CGFloat width = numberOfSections * self.pageSize.width;
    CGFloat height = self.pageSize.height;
    
    return CGSizeMake(width, height);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat pageWidth = self.pageSize.width;
    NSInteger page = round(proposedContentOffset.x / pageWidth);
    return CGPointMake(page * pageWidth, proposedContentOffset.y);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end

@implementation SkitAllEpisodesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnFloatingView:)];
    self.floatingView.userInteractionEnabled = YES;
    [self.floatingView addGestureRecognizer:pan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showAnimation];
}

- (void)showAnimation {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.floatingView.transform = CGAffineTransformIdentity;
    } completion:^(UIViewAnimatingPosition finalPosition) {
    }];
}

- (void)updateData:(HomeRecommendSkit*)infoModel videoInfoModel:(NSArray<SkitVideoInfoModel*>*)videoInfoModels selectVideoId:(NSString*)videoId {
    self.selectVideoId = videoId;
    self.videoInfoModels = videoInfoModels;
    self.infoModel = infoModel;

    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:minstr(infoModel.cover)]];
    self.titleLabel.text = infoModel.name;

    int payCount = 0;
    BOOL isContainVip = NO;
    for (SkitVideoInfoModel *model in videoInfoModels) {
        if (model.isNeedPay) {
            payCount += 1;
            if (model.is_vip > 0) {
                isContainVip = YES;
            }
        }
    }

    self.totalEpisodesLabel.text = @"";
    if (payCount > 0) {
        self.totalEpisodesLabel.text = isContainVip ? [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_pay_info_vip"), payCount] : [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_pay_info"), payCount];
    } else {
        self.totalEpisodesLabel.text = [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_paid_info"), videoInfoModels.count];
    }

    NSString *browse = [YBToolClass formatLikeNumber:minnum(infoModel.total_browse)];
    NSString *allString = [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_all_episodes"), infoModel.total_episodes];
    self.infoLabel.text = [NSString stringWithFormat:@"%@%@・%@", browse, YZMsg(@"play"), allString];

    NSString *episodesUpdateLabelTitle = infoModel.total_episodes == infoModel.current_episodes ? YZMsg(@"Episodes finished") : YZMsg(@"Episodes update to");
    NSInteger updateCount = infoModel.total_episodes == infoModel.current_episodes ? infoModel.total_episodes : infoModel.current_episodes;
    NSString *episodesUpdateLabelCount = [NSString stringWithFormat:YZMsg(@"No Prefix Episode %ld"), updateCount];
    self.episodesUpdateLabel.text = [NSString stringWithFormat:@"%@%@",
                           episodesUpdateLabelTitle,
                           episodesUpdateLabelCount];


    // 分類
    NSMutableArray *selectGroupArray = [NSMutableArray array];
    NSMutableArray *groupArray = [NSMutableArray array];
    NSInteger totalCount = videoInfoModels.count;
    NSInteger groupNum = (totalCount + GroupCount - 1) / GroupCount;

    for (NSInteger i = 0; i < groupNum; i++) {
        NSInteger startIndex = i * GroupCount;
        NSInteger endIndex = MIN(startIndex + GroupCount, totalCount);
        NSArray *subArray = [videoInfoModels subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
        [selectGroupArray addObject:subArray];

        NSString *groupTitle = [NSString stringWithFormat:@"%ld-%ld", startIndex + 1, endIndex];
        [groupArray addObject:groupTitle];
    }
    self.groupArray = [groupArray copy];
    self.selectGroupArray = [selectGroupArray copy];

    self.currentGroup = 0;
    if (videoId.length > 0) {
        for (NSInteger i = 0; i < videoInfoModels.count; i++) {
            SkitVideoInfoModel *model = videoInfoModels[i];
            if ([model.video_id isEqualToString:videoId]) {
                NSInteger groupIndex = i / GroupCount;
                self.currentGroup = (int)groupIndex;
                break;
            }
        }
    }

    [self.collectionView reloadData];
    [self.groupCollectionView reloadData];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentGroup inSection:0];
    [self.groupCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self.groupCollectionView.delegate collectionView:self.groupCollectionView didSelectItemAtIndexPath:indexPath];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.totalEpisodesContainer.horizontalColors = @[RGB_COLOR(@"#FF838E", 1.0), RGB_COLOR(@"#FF63AC", 1.0)];

    PagedCollectionViewLayout *layout = (PagedCollectionViewLayout *)self.collectionView.collectionViewLayout;
    layout.pageSize = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    [layout invalidateLayout];
}

#pragma mark - UI
- (void)setupViews {
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    closeTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:closeTap];

    [self.view addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];

    [self.floatingView addSubview:self.headerContainer];
    [self.headerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.floatingView).offset(24);
        make.left.right.equalTo(self.floatingView);
        make.height.equalTo(@58);
    }];

    UIView *selectInfoView = [self createSelectTitleView];
    [self.floatingView addSubview:selectInfoView];
    [selectInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerContainer.mas_bottom).offset(24);
        make.left.equalTo(self.floatingView).offset(14);
    }];

    [self.floatingView addSubview:self.groupCollectionView];
    [self.groupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(selectInfoView.mas_bottom).offset(14);
        make.left.equalTo(self.floatingView).offset(14);
        make.right.equalTo(self.floatingView);
        make.height.equalTo(@30);
    }];

    CGFloat width = (VK_SCREEN_W - (MinimumInteritemSpacing*(GroupRows - 1) + SectionInset*2))/GroupRows;
    CGFloat collectionHeight = MinimumLineSpacing*4 + width*GroupColumns + 15;
    [self.floatingView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupCollectionView.mas_bottom).offset(14);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.equalTo(@(collectionHeight));
    }];

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    self.floatingView.transform = CGAffineTransformMakeTranslation(0, self.floatingView.bounds.size.height);
}

#pragma mark - Lazy
- (UIView *)floatingView {
    if (!_floatingView) {
        _floatingView = [UIView new];
        _floatingView.backgroundColor = [UIColor whiteColor];
        _floatingView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _floatingView.layer.cornerRadius = 25;
        _floatingView.layer.masksToBounds = YES;
    }
    return _floatingView;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [UIImageView new];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.cornerRadius = 4;
        _coverImageView.layer.masksToBounds = YES;
    }
    return _coverImageView;
}

- (UIView *)headerContainer {
    if (!_headerContainer) {
        _headerContainer = [UIView new];

        [_headerContainer addSubview:self.coverImageView];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@44);
            make.height.equalTo(@58);
            make.left.equalTo(_headerContainer).offset(12);
            make.centerY.equalTo(_headerContainer);
        }];

        [_headerContainer addSubview:self.totalEpisodesContainer];
        [self.totalEpisodesContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerContainer);
            make.right.equalTo(_headerContainer).offset(-14);
        }];

        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.infoLabel]];
        stackView.spacing = 6;
        stackView.axis = UILayoutConstraintAxisVertical;
        [_headerContainer addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverImageView.mas_right).offset(14);
            make.right.equalTo(self.totalEpisodesContainer.mas_left).offset(-4);
            make.centerY.equalTo(self.coverImageView);
        }];
    }
    return _headerContainer;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:500];
        _titleLabel.textColor = RGB_COLOR(@"#111118", 1.0);
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
        _infoLabel.font = [UIFont systemFontOfSize:12 weight:400];
        _infoLabel.textColor = RGB_COLOR(@"#919191", 1.0);
    }
    return _infoLabel;
}

- (UILabel *)episodesUpdateLabel {
    if (!_episodesUpdateLabel) {
        _episodesUpdateLabel = [UILabel new];
        _episodesUpdateLabel.font = [UIFont systemFontOfSize:10 weight:400];
        _episodesUpdateLabel.textColor = RGB_COLOR(@"#919191", 1.0);
    }
    return _episodesUpdateLabel;
}

- (UICollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        layout.sectionInset = UIEdgeInsetsZero;
        _groupCollectionView.contentInset = UIEdgeInsetsZero;
        _groupCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _groupCollectionView.backgroundColor = [UIColor clearColor];
        _groupCollectionView.dataSource = self;
        _groupCollectionView.delegate = self;
        [_groupCollectionView registerClass:[SkitAllEpisodesGroupCell class] forCellWithReuseIdentifier:@"SkitAllEpisodesGroupCell"];
    }
    return _groupCollectionView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        PagedCollectionViewLayout *layout = [[PagedCollectionViewLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SkitAllEpisodesCell class] forCellWithReuseIdentifier:@"SkitAllEpisodesCell"];
    }
    return _collectionView;
}

- (UILabel *)totalEpisodesLabel {
    if (!_totalEpisodesLabel) {
        _totalEpisodesLabel = [UILabel new];
        _totalEpisodesLabel.font = [UIFont systemFontOfSize:10 weight:500];
        _totalEpisodesLabel.textColor = [UIColor whiteColor];
    }
    return _totalEpisodesLabel;
}

- (UIView *)totalEpisodesContainer {
    if (!_totalEpisodesContainer) {
        _totalEpisodesContainer = [UIView new];
        _totalEpisodesContainer.layer.cornerRadius = 17;
        _totalEpisodesContainer.layer.masksToBounds = YES;

        [self.totalEpisodesLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_totalEpisodesContainer addSubview:self.totalEpisodesLabel];
        [self.totalEpisodesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_totalEpisodesContainer).inset(10);
            make.left.right.equalTo(_totalEpisodesContainer).inset(12);
        }];
    }
    return _totalEpisodesContainer;
}

- (UIView*)createSelectTitleView {
    UIView *container = [UIView new];

    UILabel *selectLabel = [UILabel new];
    selectLabel.font = [UIFont systemFontOfSize:14 weight:500];
    selectLabel.textColor = RGB_COLOR(@"#111118", 1.0);
    selectLabel.text = YZMsg(@"Select episode");
    [container addSubview:selectLabel];
    [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(container);
    }];

    [container addSubview:self.episodesUpdateLabel];
    [self.episodesUpdateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(selectLabel.mas_right).offset(2);
        make.bottom.equalTo(selectLabel.mas_bottom).offset(-2);
    }];

    return container;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.collectionView) {
        return self.selectGroupArray.count;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.groupCollectionView) {
        return self.groupArray.count;
    }

    if (collectionView == self.collectionView) {
        if (section < self.selectGroupArray.count) {
            return self.selectGroupArray[section].count;
        }
    }
    
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.groupCollectionView) {
        SkitAllEpisodesGroupCell *cell = (SkitAllEpisodesGroupCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SkitAllEpisodesGroupCell" forIndexPath:indexPath];
        if (self.groupArray.count > indexPath.item) {
            [cell update:self.groupArray[indexPath.item]];
        }
        return cell;
    }
    
    SkitAllEpisodesCell *cell = (SkitAllEpisodesCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SkitAllEpisodesCell" forIndexPath:indexPath];

    if (indexPath.section < self.selectGroupArray.count) {
        NSArray *models = self.selectGroupArray[indexPath.section];
        if (models.count > indexPath.item) {
            SkitVideoInfoModel *model = models[indexPath.item];
            BOOL isCurrent = [model.video_id isEqualToString:self.selectVideoId];
            int index = (int)indexPath.item + 1 + GroupCount * (int)indexPath.section;
            [cell update:model index:index isCurrent:isCurrent];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.groupCollectionView) {
        self.currentGroup = (int)indexPath.item;
        [self scrollToCurrentGroup];
    } else {
        if (indexPath.section < self.selectGroupArray.count) {
            NSArray *models = self.selectGroupArray[indexPath.section];
            if (models.count > indexPath.item) {
                SkitVideoInfoModel *model = models[indexPath.item];
                if ([self.delegate respondsToSelector:@selector(SkitAllEpisodesListViewControllerDelegateForSelect:)]) {
                    [self.delegate SkitAllEpisodesListViewControllerDelegateForSelect:model.video_id];
                }
                [self closeAnimation];
            }
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.groupCollectionView) {
        return CGSizeMake(59, 30);
    }

    CGFloat width = (collectionView.bounds.size.width - (MinimumInteritemSpacing*(GroupRows - 1) + SectionInset*2))/GroupRows;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.groupCollectionView) {
        return 6;
    }
    return MinimumInteritemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.groupCollectionView) {
        return 6;
    }
    return MinimumLineSpacing;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSInteger currentPage = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
        self.currentGroup = (int)currentPage;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentGroup inSection:0];
        [self.groupCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark - Floating
- (void)panOnFloatingView:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseOut animations:^{
                CGFloat translationY = self.floatingView.bounds.size.height;
                self.floatingView.transform = CGAffineTransformMakeTranslation(0, translationY);
                self.view.backgroundColor = [UIColor clearColor];
            }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self.floatingView];
            CGFloat fractionComplete = translation.y / self.floatingView.bounds.size.height;
            self.animator.fractionComplete = fractionComplete;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.animator.fractionComplete <= 0.22) {
                self.animator.reversed = YES;
            } else {
                __weak typeof(self) weakSelf = self;
                [weakSelf close];
                [self.animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                }];
            }
            [self.animator continueAnimationWithTimingParameters:nil durationFactor:0];
            break;
        }
        default:
            break;
    }
}

- (void)closeAnimation {
    [self close];
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2
                                                          delay:0
                                                        options:UIViewAnimationOptionCurveEaseOut
                                                     animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        CGFloat transformY = self.floatingView.bounds.size.height;
        self.floatingView.transform = CGAffineTransformMakeTranslation(0, transformY);
    } completion:^(UIViewAnimatingPosition finalPosition) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)closeView:(UIGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.view];
    UIView *touchView = [self.view hitTest:touchPoint withEvent:nil];

    if (touchView != self.view) {
        return;
    }

    [self closeAnimation];
}

#pragma mark - Action
- (void)close {
    if ([self.delegate respondsToSelector:@selector(SkitAllEpisodesListViewControllerDelegateForClose)]) {
        [self.delegate SkitAllEpisodesListViewControllerDelegateForClose];
    }
}

- (void)scrollToCurrentGroup {
    if (self.currentGroup < self.selectGroupArray.count) {
        CGFloat pageWidth = self.collectionView.bounds.size.width;
        CGPoint offset = CGPointMake(self.currentGroup * pageWidth, 0);
        [self.collectionView setContentOffset:offset animated:YES];

        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

@end
