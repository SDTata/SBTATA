//
//  PlayletContainer.m
//  phonelive2
//
//  Created by user on 2024/6/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import "PlayletContainer.h"
#import "SkitListViewController.h"

@interface PlayletContainer ()

@property(nonatomic, strong) SkitListViewController *hotViewController;
@property(nonatomic, strong) SkitListViewController *latestViewController;
@property(nonatomic, strong) SkitListViewController *favoriteViewController;
@property(nonatomic, strong) SkitListViewController *recordViewController;

@end

@implementation PlayletContainer


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.categoryView.titles = @[YZMsg(@"Hotpage_Hot"),
                                 YZMsg(@"DramaHomeHeaderView_latest"),
                                 YZMsg(@"Favorite"),
                                 YZMsg(@"Watch History")];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleColor = vkColorHexA(0x000000, 0.5);
    self.categoryView.titleLabelZoomEnabled = YES;
    self.categoryView.titleFont = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.categoryView.segmentStyle = SegmentStyleLine;
    self.categoryView.averageCellSpacingEnabled = YES;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view).multipliedBy(0.7);
        //make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.categoryView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeHideHomeMenu" object:nil];
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    if (index == 0) {
        // 熱門
        if (self.hotViewController==nil) {
            self.hotViewController = [[SkitListViewController alloc] initWithType:SkitListViewControllerTypeCategory];
        }

        return (id)self.hotViewController;
    } else if (index == 1) {
        // 最新
        if (self.latestViewController == nil) {
            self.latestViewController = [[SkitListViewController alloc] initWithType:SkitListViewControllerTypeLatest];
        }
        return (id)self.latestViewController;
    } else if (index == 2) {
        // 收藏
        if (self.favoriteViewController == nil) {
            self.favoriteViewController = [[SkitListViewController alloc] initWithType:SkitListViewControllerTypeFavorite];
        }

        return (id)self.favoriteViewController;
    } else if (index == 3) {
        // 觀看紀錄
        if (self.recordViewController == nil) {
            self.recordViewController = [[SkitListViewController alloc] initWithType:SkitListViewControllerTypeHistory];
        }

        return (id)self.recordViewController;
    }
    return nil;
}

@end
