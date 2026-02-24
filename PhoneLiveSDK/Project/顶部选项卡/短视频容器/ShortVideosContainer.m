//
//  ShortVideosContainer.m
//  phonelive2
//
//  Created by user on 2024/6/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideosContainer.h"
#import "ShortVideoListViewController.h"
#import "JXCategoryTitleCell.h"
#import "ShortVideoLiikeViewController.h"
#import "ShortVideosFollowContainer.h"
#import "h5game.h"
#import "webH5.h"
#import "ZYTabBarController.h"
#import "HomeSearchVC.h"
#import <UMCommon/UMCommon.h>

@interface ShortVideosContainer ()<ShortVideoListViewControllerDelegate, JXCategoryListContentViewDelegate> {
    h5game *_h5gameVC;
    webH5 *_webH5VC;
    NSString *gameURLPath;
    NSString *lastOperate; //纪录最后一次是转出或是转入状态
    UIButton *searchButton;
}

@property(nonatomic, strong) ShortVideoListViewController *hotVoewController;
@property(nonatomic, strong) ShortVideosFollowContainer *focusVoewController;
@property(nonatomic, strong) ShortVideoLiikeViewController *favoriteVoewController;
@property(nonatomic, strong) NSArray *tags;

@end

@implementation ShortVideosContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;  // 允許視圖延伸到tabBar區域
    self.extendedLayoutIncludesOpaqueBars = YES;  // 延伸包括不透明的bars
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(convertCoinOut:) name:@"KNoticeConvertCoinOut" object:nil];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:NO]}];
    searchButton.hidden = NO;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (!strongSelf) return;
        strongSelf->searchButton.alpha = 1.0;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [VideoTicketFloatView showPostVideoButton];
    [VideoTicketFloatView showTicketButton];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [VideoTicketFloatView hidePostVideoButton];
    [VideoTicketFloatView hideTicketButton];
    searchButton.hidden = YES;
    searchButton.alpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.tabBarController.selectedIndex != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
    }
}

- (void)hideCommentView {
    [self.hotVoewController hideCommentView];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView {
    self.navigationController.navigationBarHidden = YES;

    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame: self.view.frame];
    backgroundImage.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    [self.view addSubview:backgroundImage];
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(backgroundImage.mas_width).multipliedBy(360/1125.0);
    }];

    NSMutableArray *arrayTitles = [NSMutableArray array];
    self.tags = [self getShortVideoConfigTags];
    if (self.tags.count > 0) {
        for (int i = 0; i< self.tags.count; i++) {
            [arrayTitles addObject:self.tags[i][@"tag_name"]];
        }
    } else {
        [arrayTitles addObject:YZMsg(@"Hotpage_Hot")];
    }

    self.categoryView.titles = arrayTitles;
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleColor = vkColorHexA(0x000000, 0.5);
    self.categoryView.titleLabelZoomEnabled = YES;
    self.categoryView.titleFont = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.categoryView.segmentStyle = SegmentStyleLineWithWhite;
    self.categoryView.averageCellSpacingEnabled = YES;
    NSInteger hotIndex = [self getHotIndex];
    self.categoryView.defaultSelectedIndex = hotIndex == -1 ? 0 : hotIndex;
    [self renderViewControllerWithIndex:hotIndex];

    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(0);
    }];

    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view).multipliedBy(0.55);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(40);
    }];
    
    UIImage *search_image = [ImageBundle imagewithBundleName:@"home_search_button"];
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    [searchButton setImage:search_image forState:UIControlStateNormal];
    searchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchButton];
    
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.size.mas_equalTo(40);
        make.top.mas_equalTo(VK_STATUS_H);
    }];
}

- (void)searchAction:(id)sender {
    HomeSearchVC *searchVC = [HomeSearchVC new];
    searchVC.type = 2;
    [[MXBADelegate sharedAppDelegate] pushViewController:searchVC animated:YES];
    searchButton.hidden = YES;
    searchButton.alpha = 0;
    
    NSString *tab_name = [NSString stringWithFormat:@"短视频-%@%@", self.categoryView.titles[self.currentVC.pageIndex], @"tab"];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"page_current": tab_name};
    [MobClick event:@"home_search_click" attributes:dict];
}

- (void)selectIndex:(int)index {
    [UIView performWithoutAnimation:^{
        [self.categoryView selectItemAtIndex:index];
        [self listWillDisappear];
    }];
}

- (NSInteger)getHotIndex {
    for (int i = 0; i<self.tags.count; i++) {
        NSDictionary *dic = self.tags[i];
        if ([minstr(dic[@"tag_type"]) isEqualToString:@"shortVideo_hot"]) {
            return i;
        }
    }
    return -1;
}

- (NSInteger)getLikeIndex {
    for (int i = 0; i<self.tags.count; i++) {
        NSDictionary *dic = self.tags[i];
        if ([minstr(dic[@"tag_type"]) isEqualToString:@"shortVideo_like"]) {
            return i;
        }
    }
    return -1;
}

- (void)handleRefresh {
    if (self.navigationController.viewControllers.count >= 2) {
        return;
    }
    NSInteger index = self.categoryView.selectedIndex;
    NSString *type = self.tags[index][@"tag_type"];
    if ([type isEqualToString:@"shortVideo_follow"]) {
        // 關注
        [self.focusVoewController handleRefresh];
    } else if ([type isEqualToString:@"shortVideo_hot"]) {
        // 熱門
        [self.hotVoewController handleRefresh];
    } else if ([type isEqualToString:@"shortVideo_like"]) {
        // 喜歡
        [self.favoriteVoewController handleRefresh];
    }
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    if (self.tags.count > 0 && self.tags.count>index) {
        NSString *type = self.tags[index][@"tag_type"];
        if ([type isEqualToString:@"shortVideo_follow"]) {
            // 關注
            if (self.focusVoewController == nil) {
                self.focusVoewController = [[ShortVideosFollowContainer alloc] init];
                self.focusVoewController.delegate = self;
            }
            return (id)self.focusVoewController;
        } else if ([type isEqualToString:@"shortVideo_hot"]) {
            // 熱門
            if (self.hotVoewController==nil) {
                self.hotVoewController = [[ShortVideoListViewController alloc] initWithHost:HotHost];
                self.hotVoewController.delegate = self;
                [self.hotVoewController loadViewIfNeeded];
                [self.hotVoewController viewWillDisappear:NO];
                CGFloat tabBarHeight = self.tabBarController.tabBar.height;
                CGFloat safeAreaHeight = tabBarHeight + [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
//                if (@available(iOS 26.0, *)) {
                    safeAreaHeight = tabBarHeight;
//                }
                [self.hotVoewController updateTableViewLayout:safeAreaHeight];
            }
            return (id)self.hotVoewController;
        } else if ([type isEqualToString:@"shortVideo_like"]) {
            // 喜歡
            if (self.favoriteVoewController == nil) {
                self.favoriteVoewController = [[ShortVideoLiikeViewController alloc] init];
                self.favoriteVoewController.delegate = self;
            }

            return (id)self.favoriteVoewController;
        } else if ([type isEqualToString:@"game"]) {
            gameURLPath = self.tags[index][@"tag_url"];
            if (_h5gameVC == nil) {
                _h5gameVC = [h5game new];
            }
            _h5gameVC.isFromHomeUrls = gameURLPath;
            _h5gameVC.titles = @"";
            _h5gameVC.bHiddenReturnBtn = true;
            return _h5gameVC;
        } else if ([type isEqualToString:@"web"]) {
            NSString *urlString = self.tags[index][@"tag_url"];;
            NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
            NSError *error = nil;
            NSAttributedString *decodedAttributedString = [[NSAttributedString alloc] initWithData:data
                                                                                           options:options
                                                                                documentAttributes:nil
                                                                                             error:&error];
            if (error) {
                NSLog(@"Error parsing HTML: %@", error.localizedDescription);
                return [VKPagerChildVC new];
            }
            NSString *url = decodedAttributedString.string;

            if (url.length > 9) {
                if (_webH5VC == nil) {
                    _webH5VC = [webH5 new];
                }
                _webH5VC.isFromHome = YES;
                _webH5VC.titles = @"";
                url = [YBToolClass decodeReplaceUrl:url];
                _webH5VC.urls = url;
                return _webH5VC;
            } else {
                return [VKPagerChildVC new];
            }

        } else {
            return [VKPagerChildVC new];
        }
    } else {
        // 熱門
        if (self.hotVoewController==nil) {
            self.hotVoewController = [[ShortVideoListViewController alloc] initWithHost:HotHost];
            self.hotVoewController.delegate = self;
        }

        return (id)self.hotVoewController;
    }
}

- (void)insertModelToHotShortVideo:(ShortVideoModel*)model {
    [self.categoryView selectItemAtIndex:[self getHotIndex]];
    if (self.hotVoewController == nil) {
        _weakify(self)
        vkGcdAfter(0.5, ^{
            _strongify(self)
            [self.hotVoewController insertModelAndOrderToIndex:model];
        });
    } else {
        [self.hotVoewController insertModelAndOrderToIndex:model];
    }
}

- (NSArray *)getShortVideoConfigTags {
    NSDictionary *cachedConfig = [[MXBADelegate sharedAppDelegate] getAppConfig:nil];
    if (cachedConfig) {
        NSArray *items = cachedConfig[@"MainPage"][@"tabbar"][@"tabbar_buttons"];
        if (![items isKindOfClass:[NSArray class]]) {
            return nil;
        }

        for (NSDictionary *dic in items) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;;
            }
            if ([minstr(dic[@"nav"]) isEqualToString:@"nav://shortVideo"]) {
                NSArray *tags = dic[@"tags"];
                if (![tags isKindOfClass:[NSArray class]]) {
                    return nil;
                }
                return tags;
            }
        }
    }
    return nil;
}

#pragma mark - ShortVideoListViewControllerDelegate
- (void)changeSegmentStyle:(SegmentStyle)style {
    UIColor *color = style == SegmentStyleLineWithWhite ? [UIColor whiteColor] : [UIColor blackColor];
    UIColor *shadowColor = style == SegmentStyleLineWithWhite ? [UIColor blackColor] : [UIColor whiteColor];

    for (JXCategoryBaseCellModel *model in self.categoryView.dataSource) {
        if ([model isKindOfClass:[JXCategoryTitleCellModel class]]) {
            JXCategoryTitleCellModel *tempModel = (JXCategoryTitleCellModel*)model;
            tempModel.titleNormalColor = color;
            tempModel.titleSelectedColor = color;
            [self.categoryView refreshSelectedCellModel:tempModel unselectedCellModel:tempModel];
        }
    }

    for (UIView *view in self.categoryView.subviews) {
        if ([view isKindOfClass:[JXCategoryCollectionView class]]) {
            for (int i = 0; i<view.subviews.count; i++) {
                JXCategoryTitleCell *cell = view.subviews[i];
                if ([cell isKindOfClass:[JXCategoryTitleCell class]]) {
                    cell.titleLabel.textColor = color;
                    cell.titleLabel.layer.shadowOpacity = 0.5;
                    cell.titleLabel.layer.shadowColor = shadowColor.CGColor;
                    cell.titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
                    cell.maskTitleLabel.textColor = color;
                }
            }
        }
    }
}
- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    if (index == [self getLikeIndex]) {
        [self.favoriteVoewController refreshAndScrollToTop];
    }

    [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeHideHomeMenu" object:nil];
    [self convertCoinOut:nil];
    NSString *tab_name = self.categoryView.titles[index];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"page": tab_name};
    [MobClick event:@"shortvideo_page_click" attributes:dict];
}

#pragma mark - JXCategoryListContentViewDelegate
- (void)listWillDisappear {
    if (self.focusVoewController) {
        [self.focusVoewController viewWillDisappear:NO];
    }
    if (self.hotVoewController) {
        [self.hotVoewController viewWillDisappear:NO];
    }
    if (self.favoriteVoewController) {
        [self.favoriteVoewController viewWillDisappear:NO];
    }
}

#pragma mark - H5

- (void)requestData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *getBalanceNewUrl = [NSString stringWithFormat:@"User.getPlatGameBalance&uid=%@&token=%@&game_plat=user",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getBalanceNewUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        //当旋转结束时隐藏
        [MBProgressHUD hideHUD];
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = info;
            LiveUser *user = [Config myProfile];
            user.coin = minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];

        [MBProgressHUD hideHUD];
    }];
}
- (void)convertCoinOut:(nullable NSNotification*)notification {
    NSString *subplat = @"";
    NSString *kindid = @"";
    NSDictionary *params = [YBToolClass getUrlParamWithUrl:gameURLPath];
    if (params) {
        NSString *game = params[@"game"];
        NSString *plat = params[@"plat"];
        kindid = params[@"kindid"];
        subplat = plat ? plat : game; //这里切换到游戏的时候，转入转出的api  User.convertCoin的参数subplat，优先从这里新加的协议 plat取值，如果没有就取game。
    }
    NSString *operate = (self.currentVC == _h5gameVC) ? @"in" : @"out";
    if (notification && notification.object[@"operate"]) {
        operate = notification.object[@"operate"];
    }
    NSInteger operateValue = -1;
    if ([common getAutoExchange] && ![subplat isEqualToString:@""] && ![lastOperate isEqualToString:operate]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *convertCoinUrl = [NSString stringWithFormat:@"User.convertCoin&uid=%@&token=%@&subplat=%@&operate=%@&value=%ld",[Config getOwnID],[Config getOwnToken],subplat,operate,operateValue];
            if (![PublicObj checkNull:kindid]) {
                convertCoinUrl = [convertCoinUrl stringByAppendingFormat:@"&kind_id=%@",kindid];
            }
            WeakSelf
            [[YBNetworking sharedManager] postNetworkWithUrl:convertCoinUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf->lastOperate = operate; //纪录 in 或是 out, 避免切换画面一直重复转出或转入
                [MBProgressHUD hideHUD];
                if (code == 0 && info && ![info isEqual:[NSNull null]]) {
                    [strongSelf requestData];
                } else {
//                    [MBProgressHUD showError:msg];
                }
            } fail:^(NSError * _Nonnull error) {
                [MBProgressHUD hideHUD];
            }];
        });
    }
}
- (void)resetOperate {
    lastOperate = @"";
}


@end
