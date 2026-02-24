//
//  TaskDailyTaskVC.m
//  phonelive2
//
//  Created by vick on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "TaskDailyTaskVC.h"
#import "TaskDailyTaskCell.h"
#import "TaskSignInAlertView.h"

@interface TaskDailyTaskVC ()<ZJJTimeCountDownDelegate>

@property (nonatomic, strong) VKBaseTableView *tableView;

@property (nonatomic, strong) ZJJTimeCountDown *countDown;

@end

@implementation TaskDailyTaskVC

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.registerCellClass = [TaskDailyTaskCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _tableView.automaticDimension = YES;
        
        [_tableView vk_headerRefreshSet];
        
        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };
        
        _tableView.clickCellActionBlock = ^(NSIndexPath *indexPath, RewardHomeModel *item, NSInteger actionIndex) {
            _strongify(self)
            [self getTaskRewardData:item];
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.tableView vk_headerBeginRefresh];
}

- (void)setupView {
    self.view.backgroundColor = vkColorHex(0xf2f2f6);
    self.view.frame = CGRectMake(0, 0, VK_SCREEN_W, SCREEN_HEIGHT*0.8+VK_BOTTOM_H);
    self.view.layer.cornerRadius = 20;
    self.view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"task_alert_top"];
    [self.view addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(68);
    }];
    
    UILabel *titleLabel = [UIView vk_label:self.rewardModel.name?self.rewardModel.name:@"" font:vkFontBold(16) color:UIColor.whiteColor];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(16);
    }];
    
    UIButton *closeButton = [UIView vk_buttonImage:@"demo_icon_close" selected:nil];
    [closeButton vk_addTapAction:self selector:@selector(hideAlert)];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(44);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.right.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(56);
    }];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getTaskListByGroup:self.rewardModel.groupId block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        NSArray *array = [RewardHomeModel arrayFromJson:networkData.data[@"rewards"]];
        strongSelf.tableView.extraData = strongSelf.countDown;
        [strongSelf.tableView vk_refreshFinish:array];
    }];
}

/// 领取每日奖励
- (void)getTaskRewardData:(RewardHomeModel *)model {
    if (!model.completed) {
        if (model.btn_jump.length <= 0) {
            return;
        }
        [self hideAlert];
        NSDictionary *data = @{@"scheme": model.btn_jump};
        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
        return;
    }
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getTaskRewardById:model.id_ groupId:model.groupId block:^(NetworkData *networkData) {
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


- (void)showRewardAlertView:(RewardHomeModel *)model {
    TaskSignInAlertView *view = [TaskSignInAlertView new];
    view.rewardModel = model;
    [view showFromCenter];
}

#pragma mark - ZJJTimeCountDownDelegate
- (NSAttributedString *)customTextWithTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    if (timeLabel.hours <= 0 && timeLabel.minutes <= 0 && timeLabel.seconds <= 0) {
        [self.tableView vk_headerBeginRefresh];
    }
    return [NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", timeLabel.hours, timeLabel.minutes, timeLabel.seconds]];
}


@end
