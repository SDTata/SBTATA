//
//  LongVideoChildVC.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoChildVC.h"
#import "LongVideoCell.h"
#import "VideoSectionCell.h"
#import "LongVideoDetailMainVC.h"
#import "LongVideoMoreVC.h"
#import <UMCommon/UMCommon.h>

@interface LongVideoChildVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation LongVideoChildVC

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
            NSString *type = ((MovieHomeModel *)self.tableView.dataItems[indexPath.section]).sub_cate.name;
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"type":type};
            [MobClick event:@"home_subnav_longvideo_detail_click" attributes:dict];
        };
        
        _tableView.clickSectionActionBlock = ^(NSIndexPath *indexPath, MovieHomeModel *item, NSInteger actionIndex) {
            _strongify(self)
            LongVideoMoreVC *vc = [LongVideoMoreVC new];
            vc.cateModel = self.cateModel;
            vc.subCateModel = item.sub_cate;
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            NSString *type = item.sub_cate.name;
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"type":type};
            [MobClick event:@"home_subnav2_longvideo_click" attributes:dict];
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
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getMovieList:self.cateModel.id_ sub:nil page:self.tableView.pageIndex block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        NSArray *array = [MovieHomeModel arrayFromJson:networkData.info];
        [strongSelf.tableView vk_refreshFinish:array];
    }];
}

@end
