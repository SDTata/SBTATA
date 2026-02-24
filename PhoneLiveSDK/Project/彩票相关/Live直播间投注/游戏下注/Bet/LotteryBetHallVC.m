//
//  LotteryBetHallVC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetHallVC.h"
#import "LotteryMenuBarView.h"
#import "LotteryChipView.h"
#import "LotteryHeaderView_BASE.h"
#import "LotteryBetHallView_BASE.h"
#import "LotteryNetworkUtil.h"
#import "LotteryBetModel.h"
#import "LotteryTimerView.h"
#import "LotteryVoiceUtil.h"

#import "socketLivePlay.h"
#import "hotModel.h"
#import "LotteryAwardVController.h"

@interface LotteryBetHallVC () <socketDelegate>

@property (nonatomic, strong) LotteryHeaderView_BASE *headerView;
@property (nonatomic, strong) LotteryBetHallView_BASE *contentView;
@property (nonatomic, strong) LotteryMenuBarView *menuBarView;
@property (nonatomic, strong) LotteryChipView *chipView;

@property (nonatomic, strong) socketMovieplay *socketDelegate;
@property (nonatomic, strong) NSTimer *lotteryTime;

@property (nonatomic, strong) NSMutableArray *lotteryShowArr;
@property (nonatomic, strong) LotteryAwardVController *lotteryAwardVC;

@end

@implementation LotteryBetHallVC

-(void)timeDelayUpdate:(long long)timeDelayNum
{
    
}

- (LotteryMenuBarView *)menuBarView {
    if (!_menuBarView) {
        _menuBarView = [[LotteryMenuBarView alloc] initWithType:self.lotteryType viewStyle:self.isFromVideo];
        _menuBarView.lotteryDelegate = self.lotteryDelegate;
        
        _weakify(self)
        _menuBarView.clickActionBlock = ^(NSInteger index) {
            _strongify(self)
            if (index == 0) {
                [self clickCloseAction];
            } else if (index == 1) {
                [self exchangeVersionToOld];
            }
        };
        
        _menuBarView.clickContinueBlock = ^(BetListDataModel *model) {
            _strongify(self)
            [self.contentView doContinue:model];
        };
    }
    return _menuBarView;
}

- (LotteryChipView *)chipView {
    if (!_chipView) {
        _chipView = [LotteryChipView new];
        
        _weakify(self)
        _chipView.selectBlock = ^(id data) {
            _strongify(self)
            self.contentView.chipModel = data;
        };
        
        _chipView.continueBlock = ^{
            _strongify(self)
            [self.contentView doContinue];
        };
    }
    return _chipView;
}

- (LotteryHeaderView_BASE *)headerView {
    if (!_headerView) {
        _headerView = [LotteryHeaderView_BASE createWithType:self.lotteryType];
    }
    return _headerView;
}

- (LotteryBetHallView_BASE *)contentView {
    if (!_contentView) {
        _contentView = [LotteryBetHallView_BASE createWithType:self.lotteryType];
        
        _weakify(self)
        _contentView.clickBetBlock = ^{
            _strongify(self)
            self.chipView.continueBtn.enabled = YES;
            [self.menuBarView refreshBetRecord];
        };
    }
    return _contentView;
}

- (void)dealloc {
    NSLog(@"LotteryBetHallVC - dealloc");
    [self releaseView];
    [NSNotificationCenter.defaultCenter postNotificationName:@"KHomeSocketCreateKey" object:nil];
    [NSNotificationCenter.defaultCenter postNotificationName:@"KLongVideoCloseGame" object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)backgroundCloseEnable {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [VideoTicketFloatView hideFloatView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter postNotificationName:@"KHomeSocketDeleteKey" object:nil];
    [self setupView];
    [self loadBetInfo];
    [self createNotice];
}

- (void)setupView {
    self.view.backgroundColor = UIColor.blackColor;
    self.view.layer.masksToBounds = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UIImageView *backImgView = [UIImageView new];
    backImgView.image = [ImageBundle imagewithBundleName:@"bj"];
    [self.view addSubview:backImgView];
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(VK_STATUS_H);
        make.height.mas_equalTo(150);
    }];
    
    [self.view insertSubview:self.menuBarView belowSubview:self.headerView];
    [self.menuBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(self.headerView.mas_bottom);
    }];
    
    UIImageView *bottomView = [UIImageView new];
    bottomView.userInteractionEnabled = YES;
    bottomView.image = [ImageBundle imagewithBundleName:@"yfks_bgview_bottom"];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(VK_BOTTOM_H+50);
    }];
    
    [bottomView addSubview:self.chipView];
    [self.chipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(40);
    }];
    
    [self.view insertSubview:self.contentView aboveSubview:backImgView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(self.menuBarView.mas_bottom);
        make.bottom.mas_equalTo(bottomView.mas_top);
    }];
    
    if (self.isFromVideo) {
        [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.height.mas_equalTo(140);
        }];
    }
}

- (void)loadBetInfo {
    _weakify(self)
    [LotteryNetworkUtil getHomeBetViewInfo:self.lotteryType block:^(NetworkData *networkData) {
        _strongify(self)
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [self clickCloseAction];
            return;
        }
        LotteryBetModel *model = [LotteryBetModel modelFromJSON:networkData.data];
        self.headerView.betModel = model;
        self.contentView.betModel = model;
        self.menuBarView.betModel = model;
        
        /// 更新余额
        [Config updateMoney:model.left_coin];
        [self.chipView refreshBalance];
        
        [LotteryVoiceUtil.shared startPlayBGM:model.music];
        [self addNodeServer:model.lobbyServer];
        
        /// 当前投注状态
        if (self.contentView.betModel.timeOffset > 0) {
            [self showBettingTimer];
            [self.headerView doStart];
            [self.contentView doStart];
        } else {
            [self createTimer];
            [self.headerView doStop];
            [self.contentView doStop];
        }
    }];
}

/// 关闭游戏
- (void)clickCloseAction {
    [self releaseView];
    if (self.isFromVideo) {
        [self.view.superview removeFromSuperview];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// 切换旧版
- (void)exchangeVersionToOld {
    if (self.lotteryDelegate != nil) {
        [self releaseView];
        [self.lotteryDelegate exchangeVersionToOld: self.lotteryType];
    }
}

/// 清空数据
- (void)releaseView {
    [LotteryVoiceUtil.shared stopPlayBGM];
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared stopPlayAward];
    [self deleteNotice];
    [self deleteTimer];
    [self deleteSocket];
}


#pragma mark - 倒计时
/// 投注倒计时
- (void)showBettingTimer {
    LotteryTimerView *timeView = [self.view viewWithTag:2002];
    if (timeView) return;
    
    timeView = [LotteryTimerView new];
    timeView.tag = 2002;
    [self.view addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(VK_STATUS_H + 10);
    }];
    timeView.title = YZMsg(@"game_begain");
    timeView.time = self.contentView.betModel.timeOffset;
    
    _weakify(self)
    timeView.timerFinishBlock = ^(LotteryTimerView *view) {
        _strongify(self)
        [view removeFromSuperview];
        [self createTimer];
        [self.headerView doStop];
        [self.contentView doStop];
        self.chipView.continueBtn.enabled = NO;
    };
    
    timeView.timerChangingBlock = ^(LotteryTimerView *view, NSUInteger time) {
        _strongify(self)
        if (time == 2) {
            [self.headerView doPreAnimate];
        }
    };
}

/// 封盘倒计时
- (void)showClosingTimer {
    LotteryTimerView *betTimeView = [self.view viewWithTag:2002];
    [betTimeView removeFromSuperview];
    
    LotteryTimerView *timeView = [self.view viewWithTag:2001];
    if (timeView) return;
    
    timeView = [LotteryTimerView new];
    timeView.tag = 2001;
    [self.view addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    timeView.title = YZMsg(@"game_will_begain");
    timeView.time = 5;
    
    _weakify(self)
    timeView.timerFinishBlock = ^(LotteryTimerView *view) {
        _strongify(self)
        [view removeFromSuperview];
        [self showBettingTimer];
        [self.headerView doStart];
        [self.contentView doStart];
    };
}


#pragma mark - 定时器
- (void)createTimer {
    [self deleteTimer];
    self.lotteryTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(lotteryInterval) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.lotteryTime forMode:NSRunLoopCommonModes];
}

- (void)deleteTimer {
    if (self.lotteryTime) {
        [self.lotteryTime invalidate];
    }
    self.lotteryTime = nil;
}

- (void)lotteryInterval {
    self.contentView.betModel.timeReplyCount ++;
    if (self.contentView.betModel.timeReplyCount % 2 == 0) {
        if (self.socketDelegate) {
            /// 定时查询期号
            NSString *lotteryType = [NSString stringWithFormat:@"%ld", self.lotteryType];
            [self.socketDelegate sendSyncLotteryCMD:lotteryType];
        }
        return;
    }
}


#pragma mark - Socket
- (void)addNodeServer:(NSString *)serverUrl {
    if (serverUrl.length) {
        hotModel * model = [[hotModel alloc] init];
        model.zhuboID = @"0";
        model.stream = @"";
        model.centerUrl = serverUrl;
        self.socketDelegate = [[socketMovieplay alloc]init];
        self.socketDelegate.socketDelegate = self;
        [self.socketDelegate addNodeListen:model isFirstConnect:YES  serverUrl:serverUrl];
    }
}

- (void)deleteSocket {
    if (self.socketDelegate) {
        [self.socketDelegate socketStop];
    }
    self.socketDelegate.socketDelegate = nil;
    self.socketDelegate = nil;
}

- (NSMutableArray *)lotteryShowArr {
    if (!_lotteryShowArr) {
        _lotteryShowArr = [NSMutableArray array];
    }
    return _lotteryShowArr;
}

#pragma mark - SocketDelegate
- (void)setLotteryAward:(LotteryAward *)msg {
    _weakify(self)
    vkGcdAfter(self.headerView.showAnimateTime, ^{
        _strongify(self)
        [self.lotteryShowArr addObject:msg];
        [self showNextLotteryAward];
    });
}

/// 队列展示中奖消息
- (void)showNextLotteryAward {
    if (self.lotteryAwardVC || self.lotteryShowArr.count <= 0) {
        return;
    }
    LotteryAward *msg = [self.lotteryShowArr firstObject];
    [self.lotteryShowArr removeObjectAtIndex:0];
    
    NSString *award_money = min2float(msg.msg.awardMoney);
    LotteryBarrageModel *model = [[LotteryBarrageModel alloc]init];
    model.content = award_money;
    model.showImgName = @"";
    model.liveuid = @"";
    model.isCurrentUser = true;
    model.lotteryType = @"";
    
    self.lotteryAwardVC = [[LotteryAwardVController alloc] initWithNibName:@"LotteryAwardVController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    self.lotteryAwardVC.model = model;
    self.lotteryAwardVC.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self addChildViewController:self.lotteryAwardVC];
    [self.view addSubview:self.lotteryAwardVC.view];
    
    _weakify(self)
    vkGcdAfter(4.0, ^{
        _strongify(self)
        self.lotteryAwardVC = nil;
        [self showNextLotteryAward];
    });
}

- (void)giveVideoTicketMessage:(GiveVideoTicket *)msg {
    NSString *text = msg.msg.ct;
    if (text.length) {
        [MBProgressHUD showBottomMessage:text];
    }
//    [VideoTicketFloatView refreshFloatData];
}

#pragma mark - 消息通知
- (void)createNotice {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataNotice:) name:@"moneyChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpenNotice:) name:@"LotteryOpenAward" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLotteryInfoNotice:) name:@"lotteryInfoNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWinInfoNotice:) name:KBetWinNotificationMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseView) name:KBetCloseNotificationMsg object:nil];
}

- (void)deleteNotice {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// 期号更新通知
- (void)refreshLotteryInfoNotice:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    VKLOG(@"期号更新通知 %@", dict);
    LotteryBetModel *model = [LotteryBetModel modelFromJSON:dict[@"lotteryInfo"]];
    if (model.lotteryType != self.lotteryType) {
        return;
    }
    /// 期号更新，停止定时器
    if (![self.contentView.betModel.issue isEqualToString:model.issue]) {
        self.contentView.betModel.timeReplyCount = 0;
        [self deleteTimer];
    }
    self.contentView.betModel.issue = model.issue;
    self.contentView.betModel.sealingTim = model.sealingTim;
    self.contentView.betModel.time = model.time;
    self.contentView.betModel.stopOrSell = model.stopOrSell;
}

/// 余额更新通知
- (void)refreshDataNotice:(NSNotification *)notification {
    NSString *left_coin = notification.userInfo[@"money"];
    [Config updateMoney:left_coin];
    [self.chipView refreshBalance];
}

/// 开奖通知
- (void)refreshLastOpenNotice:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSInteger lotteryType = [dict[@"lotteryType"] integerValue];
    if (lotteryType != self.lotteryType) {
        return;
    }
    VKLOG(@"开奖号码通知 %@", dict);
    [self.headerView doWin:dict];
    
    _weakify(self)
    vkGcdAfter(self.headerView.showAnimateTime, ^{
        _strongify(self)
        [self showClosingTimer];
        [self.contentView doWin:dict];
        [self.menuBarView.chartView updateChartData:self.headerView.chartValue];
        [self.menuBarView refreshBetRecord];
        [self.menuBarView refreshOpenHistory];
    });
}

/// 用户中奖通知
- (void)userWinInfoNotice:(NSNotification *)notification {
    
}

@end
