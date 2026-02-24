//
//  SkitHomeMainVC.m
//  phonelive2
//
//  Created by vick on 2024/9/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitHomeMainVC.h"
#import "SkitHomeChildVC.h"
#import "SkitHomeHeaderView.h"
#import "SkitHotModel.h"
#import <UMCommon/UMCommon.h>

@interface SkitHomeMainVC () <SkitHomeChildDelegate>

@property (nonatomic, strong) SkitHomeHeaderView *headerView;

@end

@implementation SkitHomeMainVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshHeaderData];
    if (!self.categoryView.titles.count) {
        [self loadListData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.sectionViewHeight = 44;
    
    [self.headerBackView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.categoryView.segmentStyle = SegmentStyleRound;
    [self.sectionBackView addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(24);
    }];
    
    [self.view addSubview:self.pagerView];
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    WeakSelf
    [self.pagerView.mainTableView vk_headerRefreshSet];
    self.pagerView.mainTableView.loadDataBlock = ^{
        STRONGSELF
        if (!strongSelf) return;
        [strongSelf refreshHeaderData];
        [strongSelf.pagerView.mainTableView reloadData];
        [(SkitHomeChildVC *)strongSelf.currentVC startHeaderRefresh];
    };
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getSkitHomeList:@"2" cate:nil page:1 block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        NSArray *cateArray = [CateInfoModel arrayFromJson:networkData.data[@"cate_info"]];
        strongSelf.categoryView.titles = [cateArray valueForKeyPath:@"name"];
        strongSelf.categoryView.values = cateArray;
        [strongSelf.categoryView reloadData];
    }];
}

- (void)refreshHeaderData {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    /// 我的收藏
    WeakSelf
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [LotteryNetworkUtil getSkitHomeList:@"3" cate:nil page:1 block:^(NetworkData *networkData) {
            STRONGSELF
            if (!strongSelf) return;
            NSArray *array = [HomeRecommendSkit arrayFromJson:networkData.data[@"list"]];
            strongSelf.headerView.collectArray = array;
            dispatch_group_leave(group);
        }];
    });
    
    /// 观看历史
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [LotteryNetworkUtil getSkitHomeList:@"0" cate:nil page:1 block:^(NetworkData *networkData) {
            STRONGSELF
            if (!strongSelf) return;
            NSArray *array = [HomeRecommendSkit arrayFromJson:networkData.data[@"list"]];
            strongSelf.headerView.historyArray = array;
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        STRONGSELF
        if (!strongSelf) return;
        [strongSelf.headerView refreshData];
        strongSelf.headerViewHeight = strongSelf.headerView.viewHeight;
        [strongSelf.pagerView resizeTableHeaderViewHeightWithAnimatable:NO duration:0 curve:UIViewAnimationCurveLinear];
    });
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    NSString *type = ((CateInfoModel *)self.categoryView.values[index]).name;
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type":type};
    [MobClick event:@"home_subnav_skit_click" attributes:dict];
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    SkitHomeChildVC *vc = [SkitHomeChildVC new];
    vc.cateModel = self.categoryView.values[index];
    vc.delegate = self;
    return vc;
}

#pragma mark - SkitHomeChildDelegate
- (void)skitHomeChildDeletgateRefreshFinish {
    [self.pagerView.mainTableView vk_headerEndRefreshing];
}

#pragma mark - lazy
- (SkitHomeHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [SkitHomeHeaderView new];
    }
    return _headerView;
}

@end
