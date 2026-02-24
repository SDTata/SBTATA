//
//  GameMoreListVC.m
//  phonelive2
//
//  Created by vick on 2024/10/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameMoreListVC.h"
#import "BaseNavBarView.h"
#import "GameHomeListCell.h"

@interface GameMoreListVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) BaseNavBarView *navBarView;

@end

@implementation GameMoreListVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [GameHomeListFourCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_footerRefreshSet];
        [_tableView vk_showEmptyView];
        
        _tableView.pageSize = 30;
        
        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, GameListModel *item) {
            _strongify(self)
            [GameToolClass enterGame:item.plat menueName:item.meunName kindID:item.kindID iconUrlName:item.urlName parentViewController:self autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                
            } fail:^{
                
            }];
        };
    }
    return _tableView;
}

- (BaseNavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [BaseNavBarView new];
        _navBarView.titleLabel.text = self.cateModel.meunName;
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
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(VK_NAV_H + 80);
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
    if ([self.cateModel.type isEqualToString:@"group"]) {
        WeakSelf
        [LotteryNetworkUtil getGroupGames:self.cateModel.kindID page:self.tableView.pageIndex block:^(NetworkData *networkData) {
            STRONGSELF
            if (!strongSelf) return;
            if (!networkData.status) {
                [MBProgressHUD showError:networkData.msg];
                [strongSelf.tableView vk_refreshFinish:nil];
                return;
            }
            NSArray *array = [GameListModel arrayFromJson:networkData.info];
            [array setValue:@(1) forKeyPath:@"show_name"];
            [strongSelf.tableView vk_refreshFinish:array];
        }];
    } else {
        WeakSelf
        [LotteryNetworkUtil getPlatGames:self.cateModel.plat subPlat:self.cateModel.kindID page:self.tableView.pageIndex block:^(NetworkData *networkData) {
            STRONGSELF
            if (!strongSelf) return;
            if (!networkData.status) {
                [MBProgressHUD showError:networkData.msg];
                [strongSelf.tableView vk_refreshFinish:nil];
                return;
            }
            NSArray *array = [GameListModel arrayFromJson:networkData.info];
            [array setValue:@(1) forKeyPath:@"show_name"];
            [strongSelf.tableView vk_refreshFinish:array];
        }];
    }
}

@end
