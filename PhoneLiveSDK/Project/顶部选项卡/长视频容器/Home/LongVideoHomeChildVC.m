//
//  LongVideoHomeChildVC.m
//  phonelive2
//
//  Created by vick on 2024/7/9.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoHomeChildVC.h"
#import "LongVideoCell.h"
#import "VideoSectionCell.h"
#import "LongVideoDetailMainVC.h"
#import "LongVideoChildVC.h"
#import "LongVideoMoreVC.h"

@interface LongVideoHomeChildVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation LongVideoHomeChildVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.viewStyle = VKCollectionViewStyleGrouped;
        _tableView.registerCellClass = [LongVideoCell class];
        _tableView.registerCellClass = [LongVideoTwoCell class];
        _tableView.registerSectionHeaderClass = [VideoSectionCell class];
        _tableView.automaticDimension = YES;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_footerRefreshSet];
        [_tableView vk_showEmptyView];
        
        /// 设置没有更多
        _tableView.pageSize = 1000;
        
        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };
        
        _tableView.rowsParseBlock = ^NSArray *(MovieHomeModel *section) {
            return section.movies;
        };
        
        _tableView.registerCellClassBlock = ^Class(NSIndexPath *indexPath, id item) {
            return !indexPath.row ? [LongVideoCell class] : [LongVideoTwoCell class];
        };
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, ShortVideoModel *item) {
            _strongify(self)
            VideoBaseCell *cell = [self.tableView cellForItemAtIndexPath:indexPath];
            LongVideoDetailMainVC *vc = [LongVideoDetailMainVC new];
            vc.videoId = item.video_id;
            vc.originalModel = item;
            [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:cell.videoImgView];
        };
        
        _tableView.clickSectionActionBlock = ^(NSIndexPath *indexPath, MovieHomeModel *item, NSInteger actionIndex) {
            _strongify(self)
            LongVideoMoreVC *vc = [LongVideoMoreVC new];
            vc.cateModel = self.cateModel;
            vc.subCateModel = item.sub_cate;
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.tableView vk_refreshFinish:self.homeList];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getMovieHomeListBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        NSArray *movies = [MovieHomeModel arrayFromJson:networkData.data[@"sub_cate_movies"]];
        [strongSelf.tableView vk_refreshFinish:movies];
    }];
}

@end
