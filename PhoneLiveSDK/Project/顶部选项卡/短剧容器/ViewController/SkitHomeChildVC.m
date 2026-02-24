//
//  SkitHomeChildVC.m
//  phonelive2
//
//  Created by vick on 2024/9/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitHomeChildVC.h"
#import "SkitVideoCell.h"
#import "SkitPlayerVC.h"
#import <UMCommon/UMCommon.h>

@interface SkitHomeChildVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation SkitHomeChildVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [SkitVideoCell class];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
        _tableView.scrollViewDidScrollBlock = self.scrollCallback;

        [_tableView vk_footerRefreshSet];
        [_tableView vk_showEmptyView];

        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };

        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            _strongify(self)
            NSString *type = self.cateModel.name;
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"type":type};
            [MobClick event:@"home_subnav_skit_detail_click" attributes:dict];

            SkitPlayerVC *viewController = [SkitPlayerVC new];
            viewController.skitArray = self.tableView.dataItems;
            viewController.skitIndex = indexPath.row;
            viewController.hasTabbar = YES;
            [[MXBADelegate sharedAppDelegate] pushViewController:viewController cell:[self.tableView cellForItemAtIndexPath:indexPath] hidesBottomBarWhenPushed:NO];

            viewController.currentIndexBlock = ^(NSInteger currentIndex) {
                _strongify(self)
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:indexPath.section];
                if ([self.tableView numberOfItemsInSection:indexPath.section] > currentIndex) {
                    [self.tableView scrollToItemAtIndexPath:newIndexPath
                                           atScrollPosition:UICollectionViewScrollPositionNone
                                                   animated:NO];
                }
            };

            viewController.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSInteger index) {
                _strongifyReturn(self)
                return [self.tableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:indexPath.section]].contentView;;
            };
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSkitFavorite:) name:@"updateSkitFavorite" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skitListUpdate:) name:@"SkitListUpdate" object:nil];

    [self setupView];
    [self startHeaderRefresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)startHeaderRefresh {
    self.tableView.pageIndex = 1;
    self.tableView.isHeaderRefreshing = YES;
    [self loadListData];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getSkitHomeList:@"4" cate:self.cateModel.cate_id page:self.tableView.pageIndex block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
        }
        STRONGSELF
        if (!strongSelf) return;
        NSArray *array = [HomeRecommendSkit arrayFromJson:networkData.data[@"list"]];
        [strongSelf.tableView vk_refreshFinish:array];
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(skitHomeChildDeletgateRefreshFinish)]) {
            [strongSelf.delegate skitHomeChildDeletgateRefreshFinish];
        }
    }];
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

- (void)skitListUpdate:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *skitId = minstr(dic[@"skitId"]);
    NSString *progress = minstr(dic[@"progress"]);

    for (HomeRecommendSkit *model in self.tableView.dataItems) {
        if ([model.skit_id isEqualToString:skitId]) {
            model.p_progress = progress;
            [self.tableView reloadData];
            break;
        }
    }
}

@end
