//
//  MyCreateChildVC.m
//  phonelive2
//
//  Created by vick on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateChildVC.h"
#import "MyCreateListCell.h"
#import "MyCreateInfoModel.h"
#import "ShortVideoListViewController.h"

@interface MyCreateChildVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation MyCreateChildVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [MyCreateListCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_footerRefreshSet];
        [_tableView vk_showEmptyView];
        
        WeakSelf
        _tableView.loadDataBlock = ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf loadListData];
        };
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, ShortVideoModel *item) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            ShortVideoListViewController *vc = [[ShortVideoListViewController alloc] initWithHost:@""];
            vc.showCreateTime = YES;
            [vc updateData:strongSelf.tableView.dataItems selectIndex:indexPath.row fetchMore:NO];
            [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:[strongSelf.tableView cellForItemAtIndexPath:indexPath]];
            vc.currentIndexBlock = ^(NSString *videoId) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
            
                NSInteger currentIndex = -1;
                for (int i = 0; i < strongSelf.tableView.dataItems.count; i++) {
                    ShortVideoModel *model = strongSelf.tableView.dataItems[i];
                    if (![model isKindOfClass:[ShortVideoModel class]]) {
                        continue;
                    }
                    if ([model.video_id isEqualToString:videoId]) {
                        currentIndex = i;
                        break;
                    }
                }

                if (currentIndex < 0) {
                    return;
                }

                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
                if ([strongSelf.tableView numberOfItemsInSection:0] > currentIndex) {
                    [strongSelf.tableView scrollToItemAtIndexPath:indexPath
                                           atScrollPosition:UICollectionViewScrollPositionNone
                                                   animated:NO];
                }
            };
            
            vc.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSString *videoId) {
                STRONGSELF
                if (strongSelf == nil) {
                    return nil;
                }

                NSInteger currentIndex = -1;
                for (int i = 0; i < strongSelf.tableView.dataItems.count; i++) {
                    ShortVideoModel *model = strongSelf.tableView.dataItems[i];
                    if (![model isKindOfClass:[ShortVideoModel class]]) {
                        continue;
                    }
                    if ([model.video_id isEqualToString:videoId]) {
                        currentIndex = i;
                        break;
                    }
                }

                if (currentIndex < 0) {
                    return nil;
                }

                return [strongSelf.tableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:indexPath.section]].contentView;;
            };
        };
        
        _tableView.clickCellActionBlock = ^(NSIndexPath *indexPath, ShortVideoModel *item, NSInteger actionIndex) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            item.isSelected = !item.isSelected;
            [strongSelf.tableView reloadData];
            [strongSelf refreshNotify];
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.tableView vk_headerBeginRefresh];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

/// 更新编辑状态
- (void)setEdit:(BOOL)edit {
    _edit = edit;
    self.tableView.extraData = @(edit);
    [self.tableView reloadData];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getMyCreateVideos:self.type page:self.tableView.pageIndex block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        MyCreateInfoModel *model = [MyCreateInfoModel modelFromJSON:networkData.data];
        [strongSelf.tableView vk_refreshFinish:model.video_list];
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(myCreateChildDeletgateUpdate:)]) {
            [strongSelf.delegate myCreateChildDeletgateUpdate:model];
        }
        [strongSelf refreshNotify];
    }];
}

- (void)selectAllList:(BOOL)isSelected {
    [self.tableView.dataItems setValue:@(isSelected) forKeyPath:@"isSelected"];
    [self.tableView reloadData];
    [self refreshNotify];
}

- (void)refreshList {
    [self.tableView vk_headerBeginRefresh];
}

- (void)refreshNotify {
    if (self.delegate && [self.delegate respondsToSelector:@selector(myCreateChildDeletgateSelected)]) {
        [self.delegate myCreateChildDeletgateSelected];
    }
}

- (NSArray<ShortVideoModel *> *)selectVideos {
    NSArray *selectItems = [self.tableView.dataItems filterBlock:^BOOL(ShortVideoModel *object) {
        return object.isSelected;
    }];
    return selectItems;
}

@end
