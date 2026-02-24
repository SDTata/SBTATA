//
//  LongVideoMoreVC.m
//  phonelive2
//
//  Created by vick on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoMoreVC.h"
#import "LongVideoCell.h"
#import "LongVideoDetailMainVC.h"
#import "BaseNavBarView.h"

@interface LongVideoMoreVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) BaseNavBarView *navBarView;

@end

@implementation LongVideoMoreVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [LongVideoCell class];
        _tableView.registerCellClass = [LongVideoTwoCell class];
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
    }
    return _tableView;
}

- (BaseNavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [BaseNavBarView new];
        _navBarView.titleLabel.text = self.subCateModel.name;
    }
    return _navBarView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.tableView vk_headerBeginRefresh];
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
    [LotteryNetworkUtil getMovieList:self.cateModel.id_ sub:self.subCateModel.id_ page:self.tableView.pageIndex block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        NSArray *array = [ShortVideoModel arrayFromJson:networkData.data[@"movies"]];
        [strongSelf.tableView vk_refreshFinish:array withKey:@"video_id"];
    }];
}

@end
