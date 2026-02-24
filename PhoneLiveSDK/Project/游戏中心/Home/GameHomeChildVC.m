//
//  GameHomeChildVC.m
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeChildVC.h"
#import "GameHomeModel.h"
#import "GameHomeListCell.h"
#import "GameHomeMenuCell.h"
#import "WMZPageProtocol.h"
#import "WMZPageController.h"
#import "GameMoreListVC.h"
#import "LobbyLotteryVC.h"
#import "LobbyLotteryVC_New.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "LotteryBetHallVC.h"
#import <UMCommon/UMCommon.h>

@interface GameHomeChildVC () <WMZPageProtocol, lotteryBetViewDelegate>

@property (nonatomic, strong) VKBaseCollectionView *menuTableView;
@property (nonatomic, strong) VKBaseCollectionView *gameTableView;

@end

@implementation GameHomeChildVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.menuTableView.dataItems.count) {
        [self startHeaderRefresh];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.menuTableView];
    [self.menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(108);
    }];
    
    [self.view addSubview:self.gameTableView];
    [self.gameTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.menuTableView.mas_right);
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-15);
    }];
}

- (void)startHeaderRefresh {
    _weakify(self)
    [LotteryNetworkUtil getPlatsBlock:^(NetworkData *networkData) {
        _strongify(self)
        if (networkData.status) {
            [common savegamecontroller:networkData.info];
            [self refreshLisData:networkData.info];
        } else {
            NSArray *info = [common getgamec];
            [self refreshLisData:info];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(gameHomeChildVCDelegateRefreshFinish)]) {
            [self.delegate gameHomeChildVCDelegateRefreshFinish];
        }
    }];
}

- (void)refreshLisData:(NSArray *)info {
    NSArray <GameHomeModel *> *array = [GameHomeModel arrayFromJson:info];
    NSMutableArray *results = [NSMutableArray array];
    NSInteger section = 0;
    for (NSInteger i= 0; i< array.count; i++) {
        GameHomeModel *model = array[i];
        model.section = section;
        /// 配置对应索引位置
        [model.sub setValue:@(i) forKeyPath:@"section"];
        section = section + model.sub.count;
        [results addObjectsFromArray:model.sub];
    }
    array.firstObject.selected = YES;
    self.menuTableView.dataItems = array.mutableCopy;
    [self.menuTableView reloadData];
    
    self.gameTableView.dataItems = results;
    [self.gameTableView reloadData];
}

/// 选择游戏
- (void)selectGameItem:(GameListModel *)item {
    if (item.plat.length <= 0) {
        [MBProgressHUD showError:YZMsg(@"GameListVC_UnknowGamePlat")];
        return;
    }
    if ([item.type containsString:@"more"] || [item.type containsString:@"group"]) {
        GameMoreListVC *vc = [GameMoreListVC new];
        vc.cateModel = item;
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        return;
    }
    [GameToolClass enterGame:item.plat menueName:item.meunName kindID:item.kindID iconUrlName:item.urlName parentViewController:self autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        
    } fail:^{
        
    }];
}

#pragma mark - lazy
- (VKBaseCollectionView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [VKBaseCollectionView new];
        _menuTableView.registerCellClass = [GameHomeMenuCell class];
        
        _weakify(self)
        _menuTableView.didSelectCellBlock = ^(NSIndexPath *indexPath, GameHomeModel *item) {
            _strongify(self)
            [self.menuTableView selectIndexPath:indexPath key:@"selected"];
            
            /// 先置顶视图，再联动
            WMZPageController *parentVC = (WMZPageController*)self.parentViewController;
            [parentVC downScrollViewSetOffset:CGPointZero animated:NO];
            
            [self.gameTableView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:item.section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"type_name": item.meunName};
            [MobClick event:@"game_menue_left_click" attributes:dict];
        };
    }
    return _menuTableView;
}

- (VKBaseCollectionView *)gameTableView {
    if (!_gameTableView) {
        _gameTableView = [VKBaseCollectionView new];
        _gameTableView.viewStyle = VKCollectionViewStyleGrouped;
        _gameTableView.registerCellClass = [GameHomeListCell class];
        _gameTableView.registerCellClass = [GameHomeListTwoCell class];
        _gameTableView.registerCellClass = [GameHomeListOneCell class];
        _gameTableView.registerSectionHeaderClass = [GameHomeSectionCell class];
        _gameTableView.registerSectionHeaderClass = [VKBaseCollectionSectionView class];
        _gameTableView.automaticDimension = YES;
        
        _weakify(self)
        _gameTableView.rowsParseBlock = ^NSArray *(GameTypeModel *section) {
            return section.sub;
        };
        
        _gameTableView.registerCellClassBlock = ^Class(NSIndexPath *indexPath, GameListModel *item) {
            if (item.gridCount == 3) {
                return [GameHomeListCell class];
            } else if (item.gridCount == 2) {
                return [GameHomeListTwoCell class];
            } else {
                return [GameHomeListOneCell class];
            }
        };
        
        _gameTableView.heightForHeaderInSectionBlock = ^CGFloat(NSInteger section, GameTypeModel *item) {
            return item.show_name ? [GameHomeSectionCell itemHeight] : 0;
        };
        
        _gameTableView.classForHeaderInSectionBlock = ^Class(NSInteger section, GameTypeModel *item) {
            return item.show_name ? [GameHomeSectionCell class] : [VKBaseCollectionSectionView class];
        };
        
        _gameTableView.scrollViewDidScrollBlock = ^(UIScrollView *scrollView) {
            _strongify(self)
            if (!scrollView.isTracking && !scrollView.isDecelerating) {
                return;
            }
            /// 联动左侧菜单
            NSArray *visibleIndexPaths = [self.gameTableView indexPathsForVisibleItems];
            if (visibleIndexPaths.count > 0) {
                NSIndexPath *firstVisibleIndexPath = visibleIndexPaths[0];
                GameTypeModel *mode = self.gameTableView.dataItems[firstVisibleIndexPath.section];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:mode.section inSection:0];
                [self.menuTableView selectIndexPath:indexPath key:@"selected"];
            }
        };
        
        _gameTableView.didSelectCellBlock = ^(NSIndexPath *indexPath, GameListModel *item) {
            _strongify(self)
            [self selectGameItem:item];
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"game_name": item.meunName,
                                    @"game_type": item.plat};
            [MobClick event:@"game_detail_game_click" attributes:dict];
        };
    }
    return _gameTableView;
}

#pragma mark - WMZPageProtocol
- (NSArray<UIScrollView *> *)getMyScrollViews{
    return @[self.menuTableView, self.gameTableView];
}

#pragma mark - lotteryBetViewDelegate
- (void)setCurlotteryVC:(LotteryBetViewController *)vc {

}
-(BOOL)cancelLuwu {
    return false;
}

-(void)lotteryCancless {
    return;
}

- (void)refreshTableHeight:(BOOL)isShowTopView {
    return;
}
-(void)doGame {
    return;
}
-(void)exchangeVersionToNew:(NSInteger)curLotteryType {
    if (curLotteryType == 6 || curLotteryType == 11) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSSC_view"];
        [YBToolClass sharedInstance].default_oldSSC_view = false;
    } else if (curLotteryType == 10) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldNN_view"];
        [YBToolClass sharedInstance].default_oldNN_view = false;
    } else if (curLotteryType == 14) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSC_view"];
        [YBToolClass sharedInstance].default_oldSC_view = false;
    } else if (curLotteryType == 26  || curLotteryType == 27 ) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_old_view"];
        [YBToolClass sharedInstance].default_old_view = false;
    } else if (curLotteryType == 28) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = false;
    } else if(curLotteryType == 29) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = false;
    } else if (curLotteryType == 30) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = false;
    } else if (curLotteryType == 31) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLH_view"];
        [YBToolClass sharedInstance].default_oldLH_view = false;
    } else if (curLotteryType == 32 || curLotteryType == 7 || curLotteryType == 8) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLHC_view"];
        [YBToolClass sharedInstance].default_oldLHC_view = false;
    }
    LotteryBetHallVC *VC = [LotteryBetHallVC new];
    VC.lotteryDelegate = self;
    VC.lotteryType = curLotteryType;
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    NSArray* vcArr = [[[MXBADelegate sharedAppDelegate] navigationViewController] viewControllers];
    for (UIViewController *vc in vcArr) {
        if([vc isKindOfClass:[LotteryBetViewController_Fullscreen class]] || [vc isKindOfClass:[LobbyLotteryVC_New class]]) {
            [vc removeFromParentViewController];
        }
    }
}
- (void)exchangeVersionToOld:(NSInteger)curLotteryType {
    NSArray* vcArr = [[[MXBADelegate sharedAppDelegate] navigationViewController] viewControllers];
    if (curLotteryType == 6 || curLotteryType == 8 || curLotteryType == 11) {
        LobbyLotteryVC_New *VC = [[LobbyLotteryVC_New alloc]initWithNibName:@"LobbyLotteryVC_New" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        VC.lotteryDelegate = self;
        [VC setLotteryType:curLotteryType];
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    } else {
        LotteryBetViewController_Fullscreen *VC = [[LotteryBetViewController_Fullscreen alloc]initWithNibName:@"LotteryBetViewController_Fullscreen" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        VC.lotteryDelegate = self;
        [VC setLotteryType:curLotteryType];
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    }
    if (curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27) {
        [YBToolClass sharedInstance].default_old_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_old_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if (curLotteryType == 28) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = true;
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 30) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = true;
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 29) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = true;
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 31) {
        [YBToolClass sharedInstance].default_oldLH_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldLH_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 14) {
        [YBToolClass sharedInstance].default_oldSC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldSC_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 8) {
        [YBToolClass sharedInstance].default_oldLHC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldLHC_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 6 || curLotteryType == 11) {
        [YBToolClass sharedInstance].default_oldSSC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldSSC_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    } else if(curLotteryType == 10) {
        [YBToolClass sharedInstance].default_oldNN_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldNN_view"];
        for (UIViewController *vc in vcArr) {
            if([vc isKindOfClass:[LotteryBetHallVC class]]) {
                [vc removeFromParentViewController];
            }
        }
    }
}

@end
