//
//  MyCreateMainVC.m
//  phonelive2
//
//  Created by vick on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateMainVC.h"
#import "MyCreateHeaderView.h"
#import "MyCreateChildVC.h"
#import "BaseNavBarView.h"
#import "MyCreateInfoModel.h"
#import "MyCreateFooterView.h"
#import "PostVideoViewController.h"

@interface MyCreateMainVC () <MyCreateChildDelegate, MyCreateFooterViewDelegate>

@property (nonatomic, strong) MyCreateHeaderView *headerView;
@property (nonatomic, strong) BaseNavBarView *navBarView;
@property (nonatomic, strong) MyCreateFooterView *footerView;

@end

@implementation MyCreateMainVC

- (MyCreateHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [MyCreateHeaderView new];
    }
    return _headerView;
}

- (BaseNavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [BaseNavBarView new];
        _navBarView.titleLabel.text = YZMsg(@"create_nav_title");
        
        UIButton *editButton = [UIView vk_button:YZMsg(@"public_manage") image:nil font:vkFont(14) color:UIColor.blackColor];
        [editButton vk_buttonSelected:YZMsg(@"public_cancel") image:nil color:UIColor.blackColor];
        [editButton vk_addTapAction:self selector:@selector(clickEditAction:)];
        [_navBarView addSubview:editButton];
        [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(44);
            make.right.mas_equalTo(-10);
        }];
    }
    return _navBarView;
}

- (MyCreateFooterView *)footerView {
    if (!_footerView) {
        _footerView = [MyCreateFooterView new];
        _footerView.delegate = self;
    }
    return _footerView;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //禁用屏幕左滑返回手势
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self loadListData];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveUploadVideoNotice:) name:UploadVideoAndInfoFinished object:nil];
}

- (void)receiveUploadVideoNotice:(NSNotification *)notice {
    self.categoryView.defaultSelectedIndex = 1;
    [self.categoryView reloadData];
}

- (void)setupView {
    self.view.backgroundColor = vkColorRGB(231, 227, 235);
    
    [self.view addSubview:self.navBarView];
    [self.navBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(self.navBarView.mas_bottom);
        make.height.mas_equalTo(180);
    }];
    
    self.categoryView.segmentStyle = SegmentStyleLine;
    self.categoryView.averageCellSpacingEnabled = YES;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(0);
    }];
    
    self.footerView.hidden = YES;
    [self.view addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.footerView.mas_top);
        make.top.mas_equalTo(self.categoryView.mas_bottom).offset(10);
    }];
}

- (void)clickEditAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    self.footerView.hidden = !btn.selected;
    CGFloat height = btn.selected ? 46+VK_BOTTOM_H : 0;
    [self.footerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    ((MyCreateChildVC *)self.currentVC).edit = !self.footerView.hidden;
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    MyCreateChildVC *vc = [MyCreateChildVC new];
    vc.type = self.categoryView.values[index];
    vc.delegate = self;
    return vc;
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    self.footerView.type = self.categoryView.values[index];
    self.footerView.selectVideos = [(MyCreateChildVC *)self.currentVC selectVideos];
    ((MyCreateChildVC *)self.currentVC).edit = !self.footerView.hidden;
}

- (void)loadListData {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getMyCreateVideos:@"0" page:1 block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        MyCreateInfoModel *model = [MyCreateInfoModel modelFromJSON:networkData.data];
        strongSelf.headerView.infoModel = model;
        [strongSelf updateCategoryData];
        if (strongSelf.isFromPost) {
            strongSelf.categoryView.defaultSelectedIndex = 1;
        }
        [strongSelf.categoryView reloadData];
    }];
}

#pragma mark - MyCreateChildDelegate
- (void)myCreateChildDeletgateUpdate:(MyCreateInfoModel *)model {
    self.headerView.infoModel = model;
    [self updateCategoryData];
    [self.categoryView reloadCellAtIndex:self.categoryView.selectedIndex];
}

- (void)myCreateChildDeletgateSelected {
    self.footerView.selectVideos = [(MyCreateChildVC *)self.currentVC selectVideos];
}

- (void)updateCategoryData {
    NSString *title1 = [NSString stringWithFormat:@"%@ %@", YZMsg(@"create_state_approved"), self.headerView.infoModel.review_status_counts.approved];
    NSString *title2 = [NSString stringWithFormat:@"%@ %@", YZMsg(@"create_state_pending"), self.headerView.infoModel.review_status_counts.pending];
    NSString *title3 = [NSString stringWithFormat:@"%@ %@", YZMsg(@"create_state_rejected"), self.headerView.infoModel.review_status_counts.rejected];
    self.categoryView.titles = @[title1, title2, title3];
    self.categoryView.values = @[@"1", @"0", @"2"];
}

#pragma mark - MyCreateFooterViewDelegate
- (void)myCreateFooterViewDeletgateSelectAll:(BOOL)isSelected {
    [(MyCreateChildVC *)self.currentVC selectAllList:isSelected];
}

- (void)myCreateFooterViewDeletgateRefreshList {
    [(MyCreateChildVC *)self.currentVC refreshList];
}

@end
