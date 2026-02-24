//
//  HomeCommonListViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/7/18.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeCommonListViewController.h"
#import "CommonListViewCell.h"

@interface HomeCommonListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) NSString *hostString;
@property(nonatomic, strong) UIView *navigationView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<NSString*> *infoList;
@property(nonatomic, assign) int page;
@property(nonatomic, assign) bool isLoading;
@property(nonatomic, assign) bool isMore;
@property(nonatomic, strong) UILabel *noDataLabel;
@property(nonatomic, strong) UILabel *navigationTitleLabel;

@end

@implementation HomeCommonListViewController

- (instancetype)initWithTitle:(NSString*)title {
    self = [super init];
    if (self) {
        self.navigationTitleLabel.text = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self requestListForPage:1];
}

#pragma mark - UI
- (void)setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(backgroundImageView.mas_width).multipliedBy(360/1125.0);
    }];

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.right.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];

    [self.view addSubview:self.noDataLabel];
    [self.noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.right.equalTo(self.view).inset(15);
    }];
}

- (UICollectionView *)createCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[CommonListViewCell self] forCellWithReuseIdentifier:NSStringFromClass([CommonListViewCell class])];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsVerticalScrollIndicator = NO;

    WeakSelf
    collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf == nil) {
            return;
        }
        [strongSelf requestListForPage:1];
    }];


    return collectionView;
}

#pragma mark - API
- (void)requestListForPage:(int)page {
    if (page == 1) {
        self.infoList = [NSMutableArray array];
        self.isMore = YES;
    }
    if (self.isLoading == YES || self.isMore == NO) {
        return;
    }
    self.isLoading = YES;

    NSDictionary *dic = @{
        @"page":@(page)
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:self.hostString withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.collectionView.mj_header endRefreshing];

        if (code == 0) {
            strongSelf.page = page;

            if (![info isKindOfClass:[NSDictionary class]]) {
                strongSelf.noDataLabel.hidden = strongSelf.infoList.count != 0;
                strongSelf.isLoading = NO;
                strongSelf.isMore = NO;
                [strongSelf.collectionView reloadData];
                return;
            }

            NSArray *list = info[@"list"];
            if (![list isKindOfClass:[NSArray class]]) {
                return;
            }
            strongSelf.isMore = list.count > 0;

//            NSArray *models = [DramaInfoModel mj_objectArrayWithKeyValuesArray:list];
//            NSMutableArray *newArray = [NSMutableArray array];
//            for (DramaInfoModel *model in models) {
//                BOOL isNew = YES;
//                for (DramaInfoModel *oldModel in strongSelf.infoList) {
//                    if ([oldModel.skit_id isEqualToString:model.skit_id]) {
//                        isNew = NO;
//                        break;
//                    }
//                }
//                if (isNew) {
//                    [newArray addObject:model];
//                }
//            }
//            [strongSelf.infoList addObjectsFromArray:newArray];
            [strongSelf.collectionView reloadData];
            strongSelf.noDataLabel.hidden = strongSelf.infoList.count != 0;
        } else {
            [MBProgressHUD showError:msg];
        }
        strongSelf.isLoading = NO;
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        strongSelf.isLoading = NO;
        [strongSelf.collectionView.mj_header endRefreshing];
        if (strongSelf == nil) {
            return;
        }
    }];
}

#pragma mark - action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.infoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CommonListViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CommonListViewCell class]) forIndexPath:indexPath];
    if (self.infoList.count > indexPath.item) {
//        cell.model = self.infoList[indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.infoList.count - 3) {
        [self requestListForPage:self.page + 1];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.infoList.count) {
        return;
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [self createCollectionView];
    }
    return _collectionView;
}

- (UIView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[UIView alloc]init];
        _navigationView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_navigationView];
        [_navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@44);
        }];

        UIButton *backButton = [[UIButton alloc] init];
        [backButton setImage:[ImageBundle imagewithBundleName:@"fh-1"] forState:UIControlStateNormal];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:backButton];
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_navigationView);
            make.left.equalTo(_navigationView).offset(8);
            make.size.equalTo(@44);
        }];

        [_navigationView addSubview:self.navigationTitleLabel];
        [self.navigationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_navigationView);
            make.left.equalTo(backButton.mas_right);
            make.right.equalTo(@-44);
        }];
    }
    return _navigationView;
}

- (UILabel *)navigationTitleLabel {
    if (!_navigationTitleLabel) {
        _navigationTitleLabel = [[UILabel alloc] init];
        _navigationTitleLabel.font = [UIFont systemFontOfSize:18];
        _navigationTitleLabel.textColor = [UIColor blackColor];
        _navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _navigationTitleLabel;
}

- (UILabel *)noDataLabel {
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc] init];
        _noDataLabel.font = [UIFont systemFontOfSize:14];
        _noDataLabel.textColor = [UIColor blackColor];
        _noDataLabel.text = YZMsg(@"DramaFavoriteViewController_empty_favorite");
        _noDataLabel.hidden = YES;
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noDataLabel;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (CGRectGetWidth(collectionView.frame) - (14 * 2 + 8 + 1)) / 2;
    return CGSizeMake(width, width * 220 / 177);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 14, 0, 14);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

@end
