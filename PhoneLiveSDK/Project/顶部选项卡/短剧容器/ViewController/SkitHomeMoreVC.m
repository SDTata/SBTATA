//
//  SkitHomeMoreVC.m
//  phonelive2
//
//  Created by vick on 2024/10/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitHomeMoreVC.h"
#import "SkitVideoCell.h"
#import "SkitPlayerVC.h"
#import "BaseNavBarView.h"

@interface SkitHomeMoreVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) BaseNavBarView *navBarView;

@end

@implementation SkitHomeMoreVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [SkitVideoCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_footerRefreshSet];
        [_tableView vk_showEmptyView];
        
        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            _strongify(self)
            SkitPlayerVC *viewController = [SkitPlayerVC new];
            viewController.skitArray = self.tableView.dataItems;
            viewController.skitIndex = indexPath.row;
            viewController.hasTabbar = YES;
            [[MXBADelegate sharedAppDelegate] pushViewController:viewController cell:[self.tableView cellForItemAtIndexPath:indexPath] hidesBottomBarWhenPushed:NO];

            viewController.currentIndexBlock = ^(NSInteger currentIndex) {
                _strongify(self)
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
                if ([self.tableView numberOfItemsInSection:0] > currentIndex) {
                    [self.tableView scrollToItemAtIndexPath:indexPath
                                           atScrollPosition:UICollectionViewScrollPositionNone
                                                   animated:YES];
                }
            };

            viewController.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSInteger index) {
                _strongifyReturn(self)
                return [self.tableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]].contentView;;
            };
        };
    }
    return _tableView;
}

- (BaseNavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [BaseNavBarView new];
        _navBarView.titleLabel.text = self.titleText;
    }
    return _navBarView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSkitFavorite:) name:@"updateSkitFavorite" object:nil];

    [self setupView];
    [self.tableView vk_headerBeginRefresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateSkitFavorite:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *skitId = minstr(dic[@"skit_id"]);
    int is_favorite = [dic[@"is_favorite"] intValue];
    for (HomeRecommendSkit *model in self.tableView.dataItems) {
        if (![model isKindOfClass:[HomeRecommendSkit class]]) {
            continue;
        }
        if ([model.skit_id isEqualToString:skitId]) {
            model.is_favorite = is_favorite;
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)setupView {
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIImageView *backgroundImage = [UIImageView new];
    backgroundImage.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    [self.view addSubview:backgroundImage];
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(backgroundImage.mas_width).multipliedBy(360/1125.0);
    }];

    [self.view addSubview:self.navBarView];
    [self.navBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(self.navBarView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getSkitHomeList:self.type cate:nil page:self.tableView.pageIndex block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        NSArray *array = [HomeRecommendSkit arrayFromJson:networkData.data[@"list"]];
        [strongSelf.tableView vk_refreshFinish:array];
    }];
}

@end
