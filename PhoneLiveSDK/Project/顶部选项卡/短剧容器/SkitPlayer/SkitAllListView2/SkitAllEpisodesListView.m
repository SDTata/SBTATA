//
//  SkitAllEpisodesListView.m
//  phonelive2
//
//  Created by s5346 on 2025/3/16.
//  Copyright © 2025 toby. All rights reserved.
//

#import "SkitAllEpisodesListView.h"
#import "SkitAllEpisodesGroupCell.h"
#import "SkitAllEpisodesCell.h"

@interface SkitAllEpisodesListView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIView *floatingView;
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

@implementation SkitAllEpisodesListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
        [self showAnimation];
        self.selectVideoId = @"";
    }
    return self;
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

    [self.groupCollectionView reloadData];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentGroup inSection:0];
    [self.groupCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self.groupCollectionView.delegate collectionView:self.groupCollectionView didSelectItemAtIndexPath:indexPath];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (touch.view != self) {
        return;
    }
    [self closeAnimation];
}

- (void)layoutSubviews {
    [super layoutIfNeeded];
    self.totalEpisodesContainer.horizontalColors = @[RGB_COLOR(@"#FF838E", 1.0), RGB_COLOR(@"#FF63AC", 1.0)];
}

#pragma mark - UI
- (void)setupViews {
    [self addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@RatioBaseHeight720(510));
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

    [self.floatingView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.groupCollectionView.mas_bottom).offset(14);
        make.left.right.equalTo(self).inset(15);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];

    [self layoutIfNeeded];

    self.floatingView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.floatingView.bounds));
}

- (void)showAnimation {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.backgroundColor = RGB_COLOR(@"#111118", 0.5);
        self.floatingView.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished) {
    }];
}

- (void)closeAnimation {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.floatingView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.floatingView.bounds));
    }
                     completion:^(BOOL finished) {
        [self close];
    }];
}

#pragma mark - Action
- (void)close {
    if ([self.delegate respondsToSelector:@selector(skitAllEpisodesListViewDelegateForClose)]) {
        [self.delegate skitAllEpisodesListViewDelegateForClose];
    }
    [self removeFromSuperview];
}

#pragma mark - Lazy
- (UIView *)floatingView {
    if (!_floatingView) {
        _floatingView = [[UIView alloc] init];
        _floatingView.backgroundColor = [UIColor whiteColor];
        _floatingView.layer.cornerRadius = 15;
        _floatingView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _floatingView.layer.masksToBounds = YES;
    }
    return _floatingView;
}

- (UIView *)headerContainer {
    if (!_headerContainer) {
        _headerContainer = [UIView new];

        self.coverImageView = [UIImageView new];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.layer.cornerRadius = 4;
        self.coverImageView.layer.masksToBounds = YES;
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

//        [_headerContainer addSubview:self.titleLabel];
//        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.coverImageView.mas_right).offset(14);
//            make.right.equalTo(self.totalEpisodesContainer.mas_left).offset(-4);
//            make.centerY.equalTo(self.coverImageView).offset(-12);
//        }];
//
//        [_headerContainer addSubview:self.infoLabel];
//        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.coverImageView.mas_right).offset(14);
//            make.right.equalTo(self.totalEpisodesContainer.mas_left).offset(-4);
//            make.centerY.equalTo(self.coverImageView).offset(12);
//        }];

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
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        layout.sectionInset = UIEdgeInsetsZero;
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[SkitAllEpisodesCell class] forCellWithReuseIdentifier:@"SkitAllEpisodesCell"];
//        [_collectionView registerNib:[UINib nibWithNibName:@"personLiveCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"personLiveCELL"];
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.groupCollectionView) {
        return self.groupArray.count;
    }

    if (self.currentGroup >= self.selectGroupArray.count) {
        return 0;
    }
    return self.selectGroupArray[self.currentGroup].count;
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

    if (self.currentGroup < self.selectGroupArray.count) {
        NSArray *models = self.selectGroupArray[self.currentGroup];
        if (models.count > indexPath.item) {
            SkitVideoInfoModel *model = models[indexPath.item];
            BOOL isCurrent = [model.video_id isEqualToString:self.selectVideoId];
            int index = (int)indexPath.item + 1 + GroupCount * self.currentGroup;
            [cell update:model index:index isCurrent:isCurrent];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.groupCollectionView) {
        self.currentGroup = (int)indexPath.item;
        [self.collectionView reloadData];
    } else {
        if (self.currentGroup < self.selectGroupArray.count) {
            NSArray *models = self.selectGroupArray[self.currentGroup];
            if (models.count > indexPath.item) {
                SkitVideoInfoModel *model = models[indexPath.item];
                if ([self.delegate respondsToSelector:@selector(skitAllEpisodesListViewDelegateForSelect:)]) {
                    [self.delegate skitAllEpisodesListViewDelegateForSelect:model.video_id];
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
    CGFloat width = (collectionView.width - RatioBaseWidth390(9)*5 - RatioBaseWidth390(15)*2 - 1)/6;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.groupCollectionView) {
        return 6;
    }
    return RatioBaseWidth390(9);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.groupCollectionView) {
        return 6;
    }
    return RatioBaseWidth390(14);
}

@end
