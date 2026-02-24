//
//  GameHomeMainVC.m
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeMainVC.h"
#import "GameHomeHeaderView.h"
#import "GameHomeSectionView.h"
#import "GameHomeChildVC.h"
#import <UMCommon/UMCommon.h>

@interface GameHomeMainVC () <GameHomeChildVCDelegate>

@property (nonatomic, strong) GameHomeHeaderView *headerView;
@property (nonatomic, strong) GameHomeSectionView *sectionView;
@property (nonatomic, strong) GameHomeChildVC *childVC;

@end

@implementation GameHomeMainVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.sectionView setTextBalance];
    [self loadListData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    UIButton *customerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [customerBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"game_kf")] forState:UIControlStateNormal];
    [customerBtn addTarget:self action:@selector(livechatBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customerBtn];
    [customerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.width.mas_equalTo(44);
    }];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"GameListVC_GameCenter_title") font:vkFontBold(16) color:UIColor.blackColor];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(44);
    }];
    
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        [leftButton setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftButton];
        [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(VK_STATUS_H);
            make.height.width.mas_equalTo(44);
        }];
    }
    
    __weak __typeof(self)weakSelf = self;
    NSArray *data = @[@""];
    WMZPageParam *param = PageParam()
    .wTopSuspensionSet(YES)
    .wBouncesSet(YES)
    .wBgColorSet(UIColor.clearColor)
    .wMenuBgColorSet(UIColor.clearColor)
    .wCustomNaviBarYSet(^CGFloat (CGFloat y) {
        return VK_NAV_H;
    })
    .wMenuHeightSet(0)
    .wTitleArrSet(data)
    .wViewControllerSet(^UIViewController *(NSInteger index) {
        return weakSelf.childVC;
    })
    .wMenuAddSubViewSet(^UIView * _Nullable{
        return weakSelf.sectionView;
    })
    .wMenuHeadViewSet(^UIView *{
        return weakSelf.headerView;
    });
    self.param = param;
    
    [self.downSc vk_headerRefreshSet];
    self.downSc.loadDataBlock = ^{
        [weakSelf.childVC startHeaderRefresh];
    };
    
    [self performSelector:@selector(createNavBarView) withObject:nil afterDelay:CGFLOAT_MIN];
}

- (void)createNavBarView {
    self.view.backgroundColor = UIColor.whiteColor;
    self.pageView.backgroundColor = UIColor.clearColor;
    self.downSc.backgroundColor = UIColor.clearColor;
    
    UIImageView *bj = [UIImageView new];
    bj.image = [ImageBundle imagewithBundleName:@"game_nav_bg"];
    bj.userInteractionEnabled = YES;
    [self.view addSubview:bj];
    [self.view sendSubviewToBack:bj];
    [bj mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.equalTo(bj.mas_width).multipliedBy(360/1125.0);
    }];
}

- (void)loadListData {
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetBaseInfo" withBaseDomian:YES andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if([info isKindOfClass:[NSArray class]]&& [(NSArray*)info count]>0){
            NSDictionary *infoDic = [info objectAtIndex:0];
            
            LiveUser *user = [Config myProfile];
            user.user_nicename = minstr([infoDic valueForKey:@"user_nicename"]);
            user.contact_info = minstr([infoDic valueForKey:@"contact_info"]);
            NSArray *app_list = [infoDic valueForKey:@"app_list"];
            NSMutableArray *apps = [NSMutableArray array];
            for (NSDictionary *item in app_list) {
                LiveAppItem *app = [[LiveAppItem alloc] init];
                app.info = minstr(item[@"info"]);
                app.id = minstr(item[@"id"]);
                app.app_name = item[@"app_name"];
                app.app_logo = item[@"app_logo"];
                [apps addObject:app];
            }
            user.app_list = apps.copy;
            user.sex = minstr([infoDic valueForKey:@"sex"]);
            user.level =minstr([infoDic valueForKey:@"level"]);
            user.king_level =minstr([infoDic valueForKey:@"king_level"]);
            user.avatar = minstr([infoDic valueForKey:@"avatar"]);
            user.city = minstr([infoDic valueForKey:@"city"]);
            user.level_anchor = minstr([infoDic valueForKey:@"level_anchor"]);
            user.change_name_cost = minstr([infoDic valueForKey:@"change_name_cost"]);
            user.chat_level = minstr([infoDic valueForKey:@"chat_level"]);
            user.show_level = minstr([infoDic valueForKey:@"show_level"]);
            user.chess_url = minstr([infoDic valueForKey:@"chess_url"]);
            user.game_url = minstr([infoDic valueForKey:@"game_url"]);
            user.live_ad_text = minstr([infoDic valueForKey:@"live_ad_text"]);
            user.live_ad_url = minstr([infoDic valueForKey:@"live_ad_url"]);
            user.isBindMobile = [[infoDic valueForKey:@"isBindMobile"] boolValue];
            user.isZeroCharge =[[infoDic valueForKey:@"isZeroCharge"] boolValue];
            user.liveShowChargeTime = [[infoDic valueForKey:@"liveShowChargeTime"] intValue];
            user.signature = minstr([infoDic valueForKey:@"signature"]);
            user.coin = minstr(infoDic[@"coin"]);
            user.withdrawInfo = infoDic[@"withdrawInfo"];
            [Config updateProfile:user];
            
            [common saveLivePopChargeInfo:[infoDic valueForKey:@"livePopChargeInfo"]];
            
            // TODO 保存系统公告 infoDic[@"system_msg"]
            NSArray *system_msg = [infoDic objectForKey:@"system_msg"];
            [common saveSystemMsg:system_msg];
            
            NSArray *contactPrice = [infoDic objectForKey:@"live_contact_cost"];
            [common saveContactPrice:contactPrice];
            
//            if ([infoDic isKindOfClass:[NSDictionary class]]) {
//                NSString *chat_service_url = [infoDic objectForKey:@"chat_service_url"];
//                [common saveServiceUrl:chat_service_url];
//            }
            NSArray *list = [infoDic valueForKey:@"list"];
            [common savepersoncontroller:list];//保存在本地，防止没网的时候不显示
            [[NSNotificationCenter defaultCenter]postNotificationName:KUpdateSkitEntrance object:nil];
            for (NSArray *subArray in list) {
                if (subArray.count>0) {
                    for (NSDictionary *subDic in subArray) {
                        
                        NSString *href = [subDic objectForKey:@"href"];
                        NSString *scheme = [subDic objectForKey:@"scheme"];
                        if (href && [scheme containsString:@"game-report://"]) {
                            strongSelf.sectionView.gameReportDic = subDic;
                        }
                    }
                }
            }
            NSArray *adListArr = [infoDic objectForKey:@"adlist"];
            adListArr = [adListArr filterBlock:^BOOL(id object) {
                return [[object objectForKey:@"pos"] intValue] == 4;
            }];
            strongSelf.headerView.dataArray = adListArr;
        }else{
            [MBProgressHUD showError:msg];
        }
        
    } fail:^(NSError * _Nonnull error) {
        
    }];
}

- (void)livechatBtnClick {
    [YBToolClass showService];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"客服"};
    [MobClick event:@"game_page_menue_click" attributes:dict];
}

- (void)closeVC{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
    [[[MXBADelegate sharedAppDelegate] topViewController].navigationController popViewControllerAnimated:YES];
}

#pragma mark - GameHomeChildVCDelegate
- (void)gameHomeChildVCDelegateRefreshFinish {
    [self.downSc vk_headerEndRefreshing];
}

#pragma mark - lazy
- (GameHomeHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [GameHomeHeaderView new];
        _headerView.frame = CGRectMake(0, 0, VK_SCREEN_W, VKPX(145));
    }
    return _headerView;
}

- (GameHomeSectionView *)sectionView {
    if (!_sectionView) {
        _sectionView = [GameHomeSectionView new];
        _sectionView.frame = CGRectMake(0, 0, VK_SCREEN_W, 100);
    }
    return _sectionView;
}

- (GameHomeChildVC *)childVC {
    if (!_childVC) {
        _childVC = [GameHomeChildVC new];
        _childVC.delegate = self;
    }
    return _childVC;
}

@end
