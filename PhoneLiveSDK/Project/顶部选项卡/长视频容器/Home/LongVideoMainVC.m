//
//  LongVideoMainVC.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoMainVC.h"
#import "LongVideoChildVC.h"
#import "VideoMenuAlertView.h"
#import "MovieHomeModel.h"
#import "LongVideoHomeChildVC.h"
#import <UMCommon/UMCommon.h>

@interface LongVideoMainVC ()

@end

@implementation LongVideoMainVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.categoryView.titles.count) {
        [self loadListData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.categoryView.segmentStyle = SegmentStyleRound;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(24);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.categoryView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(0);
    }];
    
//    UIButton *arrowButton = [UIView vk_buttonImage:@"down_arrow" selected:nil];
//    [arrowButton vk_addTapAction:self selector:@selector(clickArrowAction)];
//    [self.view addSubview:arrowButton];
//    [arrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.categoryView.mas_centerY);
//        make.left.mas_equalTo(self.categoryView.mas_right).offset(0);
//        make.width.height.mas_equalTo(40);
//    }];
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeHideHomeMenu" object:nil];
    NSString *type = ((MovieCateModel *)self.categoryView.values[index]).name;
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type":type};
    [MobClick event:@"home_subnav1_longvideo_click" attributes:dict];
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
//    if (index == 0) {
//        LongVideoHomeChildVC *vc = [LongVideoHomeChildVC new];
//        vc.homeList = self.categoryView.extraData;
//        vc.cateModel = self.categoryView.values[index];
//        return vc;
//    }
    LongVideoChildVC *vc = [LongVideoChildVC new];
    vc.cateModel = self.categoryView.values[index];
    return vc;
}

- (void)clickArrowAction {
    VideoMenuAlertView *view = [VideoMenuAlertView new];
    view.dataArray = self.categoryView.values;
    [view showFromTop];
    
    _weakify(self)
    view.clickIndexBlock = ^(NSInteger index) {
        _strongify(self)
        [self.categoryView selectItemAtIndex:index];
    };
}

- (void)loadListData {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getMovieHomeListBlock:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        [MBProgressHUD hideHUD];
        NSArray *cates = [MovieCateModel arrayFromJson:networkData.data[@"cate_list"]];
        NSArray *movies = [MovieHomeModel arrayFromJson:networkData.data[@"sub_cate_movies"]];
        strongSelf.categoryView.values = cates;
        strongSelf.categoryView.extraData = movies;
        strongSelf.categoryView.titles = [cates valueForKeyPath:@"name"];
        [strongSelf.categoryView reloadData];
    }];
}

@end
