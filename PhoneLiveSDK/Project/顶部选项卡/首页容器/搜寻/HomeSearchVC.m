//
//  HomeSearchVC.m
//  phonelive2
//
//  Created by user on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSearchVC.h"
#import "HXSearchBar.h"
#import "HomeSearchRecordCell.h"
#import "HomeSearchYouLikeCell.h"
#import "HomeHotSearchCell.h"
#import "BTagsView.h"
#import "HomeSearchResultChildVC.h"
#import "HomeSearchResultNetworkUtil.h"
#import "ZYTabBarController.h"
#import <UMCommon/UMCommon.h>

@interface HomeSearchVC () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate, TagViewDelegate, JXCategoryViewDelegate> {
    UIButton *closeBtn;
    HXSearchBar *searchBars;
    NSMutableArray *searchRecord;
    NSString *tempSearchText;
    NSArray *userLikes;
    NSArray *hotSearchKey;
}
@property (strong, nonatomic)VKBaseTableView *tableView;
@end

@implementation HomeSearchVC

- (void)dealloc {
    //[common saveSearchRedcord:@[]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    searchRecord = [NSMutableArray arrayWithArray:[common getSearchRedcord]];
    tempSearchText = self.key;

    [self setupViews];
    [self getGuessUserLike];
    [self getHotSearchKey];
}

- (void)getGuessUserLike {
    //[MBProgressHUD showMessage:nil];
    WeakSelf
    [HomeSearchResultNetworkUtil getGuessUserLike:self.type block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        //[MBProgressHUD hideHUD];
        [strongSelf.tableView.mj_header endRefreshing];
        strongSelf->userLikes = networkData.info;
        [strongSelf.tableView reloadData];
    }];
}

- (void)getHotSearchKey {
    WeakSelf
    //[MBProgressHUD showMessage:nil];
    [HomeSearchResultNetworkUtil getHotSearchKey:self.type block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        //[MBProgressHUD hideHUD];
        [strongSelf.tableView.mj_header endRefreshing];
        NSMutableArray *hotSearchKeys = [NSMutableArray new];
        [networkData.info enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *mutiDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            mutiDic[@"ranking"] = [NSString stringWithFormat:@"%lu", (unsigned long)idx+1];
            [hotSearchKeys addObject:mutiDic];
        }];
        strongSelf->hotSearchKey = [hotSearchKeys copy];
        [strongSelf.tableView reloadData];
    }];
}

- (void)setupViews {
    [self hideTabBar];
    self.view.backgroundColor = vkColorHex(0xEAE7EE);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBar.hidden = YES;
    
    UIImageView *topIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];
    topIndicator.image = [ImageBundle imagewithBundleName:@"home_search_indicator"];
    [self.view addSubview:topIndicator];
    
    _tableView = [[VKBaseTableView alloc]initWithFrame: CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 110.0f;
    _tableView.sectionHeaderHeight = 30.0f;
    _tableView.registerCellClass = [HomeSearchRecordCell class];
    _tableView.registerCellClass = [HomeSearchYouLikeCell class];
    _tableView.registerCellClass = [HomeHotSearchCell class];
    
    [self.view addSubview:_tableView];
    WeakSelf
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf getGuessUserLike];
        [strongSelf getHotSearchKey];
    }];
    _tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
    
    closeBtn = [UIButton new];
    [closeBtn setImage:[ImageBundle imagewithBundleName:@"person_back_black"] forState:UIControlStateNormal];
    closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn addTarget:self action:@selector(doBackVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(self.isFromHashTag ? 10 : 37);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        make.leading.mas_equalTo(self.view).offset(8);
        make.size.mas_equalTo(40);
    }];
    
    searchBars = [[HXSearchBar alloc] initWithFrame: CGRectZero];
    searchBars.backgroundColor = [UIColor clearColor];
    searchBars.leftIcomImageName = @"home_serachBar_icon";
    searchBars.delegate = self;
    //输入框提示
    searchBars.placeholder = YZMsg(@"home_search_searchVideos");
    //光标颜色
    searchBars.cursorColor = vkColorHex(0x8C8C8C);
    //TextField
    searchBars.searchBarTextField.layer.cornerRadius = 16;
    searchBars.searchBarTextField.layer.masksToBounds = YES;
    searchBars.searchBarTextField.backgroundColor = [UIColor whiteColor];
    //清除按钮图标
    //searchBar.clearButtonImage = [ImageBundle imagewithBundleName:@"demand_delete"];
    //去掉取消按钮灰色背景
    searchBars.hideSearchBarBackgroundImage = YES;
    searchBars.searchBarTextField.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:searchBars];
    
    [topIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.centerX.mas_equalTo(self.view);
        //make.height.mas_equalTo(self.isFromHashTag ? 0 : 4);
        make.height.mas_equalTo(0);
    }];
    
    [searchBars mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(self.isFromHashTag ? 10 : 37);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        make.leading.mas_equalTo(closeBtn.mas_trailing);
        make.trailing.mas_equalTo(self.view).inset(14);
        make.height.mas_equalTo(40);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(searchBars.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(self.view).inset(14);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
   
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    
    self.categoryView.titles = @[YZMsg(@"home_search_all"), YZMsg(@"home_search_shortVideo"), YZMsg(@"home_search_skit"), YZMsg(@"home_search_longVideo"), /*@"游戏",*/YZMsg(@"homepageController_live"), YZMsg(@"home_search_userNickName")];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleColor = vkColorHexA(0x000000, 0.5);
    self.categoryView.titleLabelZoomEnabled = YES;
    self.categoryView.titleFont = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    self.categoryView.segmentStyle = SegmentStyleLine;
    self.categoryView.averageCellSpacingEnabled = YES;
    
    NSInteger selectedIndex = 0;
    if (self.isFromHashTag) {
        selectedIndex = 1;
    } else if (self.type == 1) {
        selectedIndex = 2;
    } else if (self.type == 2) {
        selectedIndex = 1;
    } else {
        selectedIndex = self.type;
    }
    self.categoryView.defaultSelectedIndex = selectedIndex;
    
    
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.leading.trailing.mas_equalTo(self.view).inset(14);
        make.top.mas_equalTo(searchBars.mas_bottom).offset(10);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        /*
        if (self.isFromHashTag) {
            make.top.mas_equalTo(searchBars.mas_bottom).offset(10);
        } else {
            make.top.mas_equalTo(self.categoryView.mas_bottom).offset(10);
        }
        */
        make.top.mas_equalTo(self.categoryView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(0);
    }];
    
    if (self.isFromHashTag) {
        [_tableView setHidden:YES];
        [self.listContainerView setHidden:NO];
        [self.categoryView setHidden:NO];
    } else {
        [self.categoryView setHidden:YES];
        [self.listContainerView setHidden:YES];
    }

    
}

// 开始编辑
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    HXSearchBar *sear = (HXSearchBar *)searchBar;
    //取消按钮当搜索按钮
    sear.cancleButton.backgroundColor = [UIColor clearColor];
    [sear.cancleButton setTitle:YZMsg(@"home_search_search") forState:UIControlStateNormal];
    [sear.cancleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    sear.cancleButton.titleLabel.font = [UIFont systemFontOfSize:14];
}
// 搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    HXSearchBar *sear = (HXSearchBar *)searchBar;
    if ([tempSearchText isEqualToString:sear.searchBarTextField.text] || [sear.searchBarTextField.text isEqualToString:@""]) {
        return;
    }
    tempSearchText = sear.searchBarTextField.text;
    if (![searchRecord containsObject: tempSearchText]) {
        [searchRecord insertObject:sear.searchBarTextField.text atIndex:0];
        if (searchRecord.count == 11) {
            [searchRecord removeLastObject];
        }
    } else {
        [searchRecord removeObject:tempSearchText];
        [searchRecord insertObject:tempSearchText atIndex:0];
    }
    NSArray *arr = [NSArray arrayWithArray: searchRecord];
    [common saveSearchRedcord: arr];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    [self.tableView setHidden:YES];
    HomeSearchResultChildVC *vc = (HomeSearchResultChildVC *)self.currentVC;
    vc.hasMore = YES; //换新的关键字查询要重置hasMore状态
    vc.key = tempSearchText;
    vc.isFromHashTag = self.isFromHashTag;
    [vc claerAllData];
    [vc loadListData];
    [self.categoryView setHidden:self.isFromHashTag];
    [self.listContainerView setHidden:NO];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
        tempSearchText = @"";
        /*
        if (self.isFromHashTag) { // 删除后是常规搜索 页面布局api都要是和搜索一样。只有点的那一次是topic
            self.isFromHashTag = NO;
            [self.listContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                if (self.isFromHashTag) {
                    make.top.mas_equalTo(searchBars.mas_bottom).offset(10);
                } else {
                    make.top.mas_equalTo(self.categoryView.mas_bottom).offset(10);
                }
                
                make.bottom.mas_equalTo(0);
            }];
        }
         */
        [self.tableView setHidden:NO];
        [self.categoryView setHidden:YES];
        [self.listContainerView setHidden:YES];
        [self.tableView reloadData];
    }
}
// 取消按钮点击的回调当搜索按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    HXSearchBar *sear = (HXSearchBar *)searchBar;
    if ([tempSearchText isEqualToString:sear.searchBarTextField.text] || [sear.searchBarTextField.text isEqualToString:@""]) {
        return;
    }
    tempSearchText = sear.searchBarTextField.text;
    if (![searchRecord containsObject: tempSearchText]) {
        [searchRecord insertObject:sear.searchBarTextField.text atIndex:0];
        if (searchRecord.count == 11) {
            [searchRecord removeLastObject];
        }
    } else {
        [searchRecord removeObject:tempSearchText];
        [searchRecord insertObject:tempSearchText atIndex:0];
    }
    NSArray *arr = [NSArray arrayWithArray: searchRecord];
    [common saveSearchRedcord: arr];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    [self.tableView setHidden:YES];
    HomeSearchResultChildVC *vc = (HomeSearchResultChildVC *)self.currentVC;
    vc.hasMore = YES; //换新的关键字查询要重置hasMore状态
    vc.key = tempSearchText;
    vc.isFromHashTag = self.isFromHashTag;
    [vc claerAllData];
    [vc loadListData];
    [self.categoryView setHidden:NO];
    [self.listContainerView setHidden:NO];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"search_tag": tempSearchText};
    [MobClick event:@"search_text_input_click" attributes:dict];
}

- (void)doBackVC {
    searchBars.showsCancelButton = NO;
    searchBars.text = nil;
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self showTabBar];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [common getSearchRedcord].count > 0 ? 3 : 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([common getSearchRedcord].count > 0) {
        if (indexPath.row == 0) {
            HomeSearchRecordCell *cell = [[HomeSearchRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.datas = searchRecord;
            return cell;
        } else if (indexPath.row == 1) {
            HomeSearchYouLikeCell *cell = [[HomeSearchYouLikeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.datas = userLikes;
            WeakSelf
            cell.didSelectCellBlock = ^{
                STRONGSELF
                if (strongSelf == nil) return;
                [strongSelf getGuessUserLike];
            };
            return cell;
        } else {
            HomeHotSearchCell *cell = [[HomeHotSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.datas = hotSearchKey;
            return cell;
        }
    } else {
        [searchRecord removeAllObjects];
        if (indexPath.row == 0) {
            HomeSearchYouLikeCell *cell = [[HomeSearchYouLikeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.datas = userLikes;
            WeakSelf
            cell.didSelectCellBlock = ^{
                STRONGSELF
                if (strongSelf == nil) return;
                [strongSelf getGuessUserLike];
            };
            return cell;
        } else {
            HomeHotSearchCell *cell = [[HomeHotSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%ldIndexcell",(long)indexPath.row]];
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.datas = hotSearchKey;
            return cell;
        }
    }
}

- (void)didSelecedTag:(NSString *)text {
    searchBars.searchBarTextField.text = text;
    tempSearchText = text;
    if (![searchRecord containsObject: tempSearchText]) {
        [searchRecord insertObject:searchBars.searchBarTextField.text atIndex:0];
        if (searchRecord.count == 11) {
            [searchRecord removeLastObject];
        }
    } else {
        [searchRecord removeObject:tempSearchText];
        [searchRecord insertObject:tempSearchText atIndex:0];
    }
    NSArray *arr = [NSArray arrayWithArray: searchRecord];
    [common saveSearchRedcord: arr];
    [self.tableView reloadData];
    [searchBars resignFirstResponder];
    [self.tableView setHidden:YES];
    HomeSearchResultChildVC *vc = (HomeSearchResultChildVC *)self.currentVC;
    vc.hasMore = YES; //换新的关键字查询要重置hasMore状态
    vc.key = tempSearchText;
    vc.isFromHashTag = self.isFromHashTag;
    [vc claerAllData];
    [vc loadListData];
    [self.categoryView setHidden:NO];
    [self.listContainerView setHidden:NO];
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    HomeSearchResultChildVC* vc = [HomeSearchResultChildVC new];
    if (index == 1) {
        vc.type = 2;
    } else if (index == 2) {
        vc.type = 1;
    } else {
        vc.type = index;
    }
    if (self.isFromHashTag) {
        vc.isFromHashTag = YES;
        searchBars.searchBarTextField.text = tempSearchText;
    }
    // vc.onceDelay = index == 3;
    vc.key = tempSearchText;
    /*
    vc.isFromHashTag = self.isFromHashTag;
    if (self.isFromHashTag) {
        searchBars.searchBarTextField.text = tempSearchText;
        vc.type = self.type;
        vc.key = tempSearchText;
    } else {
        if (index == 1) {
            vc.type = 2;
        } else if (index == 2) {
            vc.type = 1;
        } else {
            vc.type = index;
        }
        vc.key = tempSearchText;
    }
    */
    return vc;
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    HomeSearchResultChildVC* vc = (HomeSearchResultChildVC *)self.currentVC;
    if (![tempSearchText isEqualToString:@""] && ![vc.key isEqualToString:tempSearchText]) {
        vc.hasMore = YES; //换新的关键字查询要重置hasMore状态
        vc.key = tempSearchText;
        [vc claerAllData];
        [vc loadListData];
    }
}

#pragma mark ================ 隐藏和显示tabbar ===============
- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController setTabbarHiden: YES];
}

- (void)showTabBar {
    if (self.tabBarController.tabBar.hidden == NO) {
        return;
    }
    ZYTabBarController *tabbarController = (ZYTabBarController *)self.tabBarController;
    [tabbarController setTabbarHiden: NO];
}

@end
