//
//  TaskCenterMainVC.m
//  phonelive2
//
//  Created by vick on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskCenterMainVC.h"
#import "BaseNavBarView.h"
#import "TaskCenterMainCell.h"
#import "TaskBackWaterVC.h"
#import "TaskDailyTaskVC.h"
#import "KingSalaryViewController.h"
#import "LuckyDrawViewController.h"
#import "DailyCheckInViewController.h"
#import "RewardHomeModel.h"
#import "myPopularizeVC.h"
#import "BindPhoneNumberViewController.h"
#import "ZJJTimeCountDown.h"
#import "TaskSignInAlertView.h"

@interface TaskCenterMainVC () <ZJJTimeCountDownDelegate>

@property (nonatomic, strong) VKBaseTableView *tableView;
@property (nonatomic, strong) BaseNavBarView *navBarView;
@property (nonatomic, strong) ZJJTimeCountDown *countDown;
@property (nonatomic, strong) MASConstraint *backgroundImageHeightConstraint;
@property (nonatomic, assign) CGFloat backgroundImageHeight;
@end

@implementation TaskCenterMainVC

- (BaseNavBarView *)navBarView {
    if (!_navBarView) {
        _navBarView = [BaseNavBarView new];
        _navBarView.titleLabel.text = (self.titleStr && self.titleStr.length > 0) ? self.titleStr : YZMsg(@"task_reward_title");
    }
    return _navBarView;
}

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.registerCellClass = [TaskCenterMainCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _tableView.automaticDimension = YES;
        
        [_tableView vk_headerRefreshSet];
        
        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, RewardHomeModel *item) {
            _strongify(self)
            
            
            switch (item.rewardType) {
                case RewardTypeDayTask:
                    if ([item.status containsString:@"in_progress"] && ![PublicObj checkNull:item.btn_jump]) {
                        NSDictionary *data = @{@"scheme": item.cell_jump,@"name":item.name};
                        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
                    }else{
                        [self clickDayTaskAction:item];
                    }
                 
                    break;
                case RewardTypeGoWEB:{
                    NSDictionary *data = @{@"scheme": item.cell_jump};
                    [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
                }
                    break;
                default:
                {
                    NSDictionary *data = @{@"scheme": item.cell_jump};
                    [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
                }
                    break;
            }
        };
        
        _tableView.clickCellActionBlock = ^(NSIndexPath *indexPath, RewardHomeModel *item, NSInteger actionIndex) {
            _strongify(self)
            switch (item.rewardType) {
                case RewardTypeDaySign:
                    [self getSignRewardData:item];
                    break;
                case RewardTypeBackWater:
                    [self getBackWaterRewardData:item];
                    break;
                case RewardTypeShareAward:
                case RewardTypeLuckyDraw:
                {
                    NSDictionary *data = @{@"scheme": item.btn_jump};
                    [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
                }
                    break;
                case RewardTypeKingSalary:
                    [self getKingRewardData:item];
                    break;
                default:
                    [self getTaskRewardData:item];
                    break;
            }
        };

        _tableView.scrollViewDidScrollBlock = ^(UIScrollView *scrollView) {
            _strongify(self)
            if (scrollView.contentOffset.y <= 0) {
                CGFloat height = self.backgroundImageHeight + fabs(scrollView.contentOffset.y);
                [self.backgroundImageHeightConstraint setOffset:height];
                [self.view layoutIfNeeded];
            }
        };
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];

    [self.tableView vk_headerBeginRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.view.backgroundColor = vkColorHex(0xf2f2f6);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    UIImageView *backgroundImage = [UIImageView new];
    backgroundImage.image = [ImageBundle imagewithBundleName:@"task_center_top"];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImage];
    [backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        self.backgroundImageHeight = VKPX(285);
        self.backgroundImageHeightConstraint = make.height.mas_equalTo(self.backgroundImageHeight);
    }];
    
    [self.view addSubview:self.navBarView];
    [self.navBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(self.navBarView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getRewardCenterInfoBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        
        NSArray *array = [RewardHomeModel arrayFromJson:networkData.data[@"rewards"]];
        strongSelf.tableView.extraData = strongSelf.countDown;
        [strongSelf.tableView vk_refreshFinish:array];
    }];
}


/// 每日闯关
- (void)clickDayTaskAction:(RewardHomeModel *)model {
    if (model.cell_jump.length <= 0) {
        return;
    }
    TaskDailyTaskVC *vc = [TaskDailyTaskVC new];
    vc.rewardModel = model;
    [vc showFromBottom];
}

/// 领取王者俸禄奖励
- (void)getKingRewardData:(RewardHomeModel *)model {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getKingReward:nil block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf.tableView vk_headerBeginRefresh];
        [strongSelf showRewardAlertView:model];
    }];
}

/// 领取签到奖励
- (void)getSignRewardData:(RewardHomeModel *)model {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getSignRewardBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (networkData.code == 1002) {
            [MBProgressHUD hideHUD];
            BindPhoneNumberViewController * vc = [[BindPhoneNumberViewController alloc]initWithNibName:@"BindPhoneNumberViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            return;
        }
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf.tableView vk_headerBeginRefresh];
        RewardDetailsModel *reward = [RewardDetailsModel modelFromJSON:networkData.data];
        model.reward_details = reward;
        [strongSelf showRewardAlertView:model];
    }];
}

/// 领取每日奖励
- (void)getTaskRewardData:(RewardHomeModel *)model {
    if (!model.completed) {
//        [self clickDayTaskAction:model];
        if (model.btn_jump.length <= 0) {
            return;
        }
        NSDictionary *data = @{@"scheme": model.btn_jump};
        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
        return;
    }
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getTaskRewardById:@"" groupId:model.groupId block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf.tableView vk_headerBeginRefresh];
        RewardDetailsModel *reward = [RewardDetailsModel modelFromJSON:networkData.data];
        model.reward_details = reward;
        [strongSelf showRewardAlertView:model];
    }];
}

/// 领取返水奖励
- (void)getBackWaterRewardData:(RewardHomeModel *)model {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getBackWaterRewardBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf.tableView vk_headerBeginRefresh];
        [strongSelf showRewardAlertView:model];
    }];
}

/// 领取幸运抽奖
- (void)getLuckyDrawData:(RewardHomeModel *)model {
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getDrawLuckyRewardBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf.tableView vk_headerBeginRefresh];
        [strongSelf showRewardAlertView:model];
    }];
}

- (void)showRewardAlertView:(RewardHomeModel *)model {
    TaskSignInAlertView *view = [TaskSignInAlertView new];
    view.rewardModel = model;
    [view showFromCenter];
}

#pragma mark - Timer
- (ZJJTimeCountDown *)countDown {
    if (!_countDown) {
        _countDown = [[ZJJTimeCountDown alloc] initWithScrollView:self.tableView dataList:self.tableView.dataItems];
        _countDown.timeStyle = ZJJCountDownTimeStyleTamp;
        _countDown.delegate = self;
    }
    return _countDown;
}

- (void)dealloc {
    [_countDown destoryTimer];
    _countDown = nil;
}

#pragma mark - ZJJTimeCountDownDelegate
- (NSAttributedString *)customTextWithTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    if (timeLabel.hours <= 0 && timeLabel.minutes <= 0 && timeLabel.seconds <= 0) {
        [self.tableView vk_headerBeginRefresh];
    }
    return [NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", timeLabel.hours, timeLabel.minutes, timeLabel.seconds]];
}

@end
