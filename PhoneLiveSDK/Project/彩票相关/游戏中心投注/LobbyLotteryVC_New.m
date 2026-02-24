#import "LobbyLotteryVC_New.h"
#import "CommonTableViewController.h"
#import "BetViewInfoModel.h"
/* 动画倒计时 */
#import "HSFTimeDownView.h"
#import "HSFTimeDownConfig.h"
#import "OptionModel.h"
#import "LobbyBetConfirmViewController.h"
#import "BetConfirmViewController.h"
#import "PayViewController.h"
#import "UIImageView+WebCache.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "LobbyLotteryMenuBarView.h"
#import "LotteryChipView.h"
#import "CustomRoundedBlurView.h"
#import "LotteryBetModel.h"
#import "socketLivePlay.h"
#import "hotModel.h"

@interface LobbyLotteryVC_New ()<socketDelegate> {
    NSDate *openTime;
    NSArray *ways;   // 投注选项
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSString *curIssue; // 当前期号
    NSMutableArray *waysBtn;   // 投注分类按钮
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *last_open_result; // 上一期开奖结果

    // UI是否创建
    BOOL bCreatedUI;
    // 投注视图
    CommonTableViewController * betOptionsViewController;
    // 底部view显示类型 0 隐藏 1下注 2注单
    NSInteger bottomShowType;
    // 已选中的投注项
    NSArray *selectedOptions;
    // 注单列表界面
    LobbyBetConfirmViewController *betConfirmVC;
    // 倒计时
    HSFTimeDownView *timeLabel_hsf;
    
    SocketManager *LobbySocketManager;
    LotteryBetModel *lotteryBetModel;
    NSInteger timeReplyCount;
}
@property (nonatomic, strong) BetViewInfoModel *betViewModel;
@property (nonatomic, strong) CustomRoundedBlurView *customBlurView;
@property (nonatomic, strong) LobbyLotteryMenuBarView *menuBarView;
@property (nonatomic, strong) LotteryChipView *chipView;
@property (nonatomic, strong) socketMovieplay *socketDelegate;
@end

@implementation LobbyLotteryVC_New

- (LobbyLotteryMenuBarView *)menuBarView {
    if (!_menuBarView) {
        _menuBarView = [[LobbyLotteryMenuBarView alloc] initWithType:curLotteryType];
        _menuBarView.lotteryDelegate = self.lotteryDelegate;
        [_menuBarView setIconAndName:self.urlName withName:self.lotteryName];
        _weakify(self)
        _menuBarView.clickActionBlock = ^(NSInteger index) {
            _strongify(self)
            if (index == 0) {
                [self clickCloseAction];
            } else if (index == 1) {
                [self exchangeVersionToNew];
            }
        };
    }
    return _menuBarView;
}
- (CustomRoundedBlurView *)customBlurView {
    if (!_customBlurView) {
        _customBlurView = [[CustomRoundedBlurView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    }
    return _customBlurView;
}
- (LotteryChipView *)chipView {
    if (!_chipView) {
        _chipView = [LotteryChipView new];
        [_chipView.continueBtn setTitle:YZMsg(@"LobbyLotteryVC_Bet") forState: UIControlStateNormal];
        [_chipView.continueBtn addTarget:self action:@selector(doBet) forControlEvents: UIControlEventTouchUpInside];
        _weakify(self)
        _chipView.selectBlock = ^(id data) {
            [common saveChipNums:((ChipsModel*)data).chipNumber];
            _strongify(self)
        };
    }
    return _chipView;
}

- (void)setupView {
    UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    bg.image = [ImageBundle imagewithBundleName:@"sy_bj"];
    [self.view addSubview: bg];
    [self.view addSubview:self.customBlurView];
    [self.view addSubview:self.menuBarView];
    [self.view addSubview:self.chipView];
    [self.customBlurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    [self.menuBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
    [self.chipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(10);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}
- (void)clickCloseAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)exchangeVersionToNew {
    if (self.lotteryDelegate != nil) {
        [self.lotteryDelegate exchangeVersionToNew: curLotteryType];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter postNotificationName:@"KHomeSocketDeleteKey" object:nil];
    [self setupView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self cacheGameList];
    bottomShowType = 0; // 默认底部视图隐藏
    [common saveLotteryBetCart:@[]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self buildData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HomeLottery_didSelected" object:nil];
    [self deleteSocket];
    if (timeLabel_hsf) {
        [timeLabel_hsf invaliTimer];
    }
}

- (void)dealloc
{
    NSLog(@"dealloc");
    [NSNotificationCenter.defaultCenter postNotificationName:@"KHomeSocketCreateKey" object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpenNotice:) name:@"LotteryOpenAward" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HomeLottery_didSelected) name:@"HomeLottery_didSelected" object:nil];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
}

- (void)buildData {
    NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getHomeBetViewInfo"];
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES  andParameter:curLotteryType==10?@{@"lottery_type":[NSString stringWithFormat:@"%ld", curLotteryType],@"support_nn":@(1)}:@{@"lottery_type":[NSString stringWithFormat:@"%ld", curLotteryType]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            NSString *lastIssue = @"";
            if(strongSelf.betViewModel){
                lastIssue = strongSelf.betViewModel.issue;
            }
            strongSelf.betViewModel = [BetViewInfoModel mj_objectWithKeyValues:[info firstObject]];
            LotteryBetModel *model = [LotteryBetModel modelFromJSON:[info firstObject]];
            strongSelf->lotteryBetModel = model;
            
            strongSelf->openTime = [NSDate dateWithTimeInterval:strongSelf.betViewModel.time sinceDate:[NSDate date]];
            /// 更新余额
            [Config updateMoney: model.left_coin];
            [strongSelf.chipView refreshBalance];
            
            [self addNodeServer:model.lobbyServer];
            
            
            LiveUser *user = [Config myProfile];
            user.coin = minstr(strongSelf.betViewModel.left_coin);
            [Config updateProfile:user];
            
            
            
            strongSelf->last_open_result = strongSelf.betViewModel.lastResult.open_result;
            
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
            });
            
            if(strongSelf.betViewModel.issue != lastIssue && lastIssue.length > 0){
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@", YZMsg(@"LobbyLotteryVC_UpdateDate"),strongSelf.betViewModel.issue]];
            }
        }
        else {
            if (msg && msg.length > 0) {
                [MBProgressHUD showError:msg];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@(%d)", YZMsg(@"public_networkError"), code]];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)refreshUI {
    ways = self.betViewModel.ways;
    if (!bCreatedUI) {
        [self initUI];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeOpenAward_Changed" object:nil userInfo:nil];
    }
    [self.menuBarView setBetModel:lotteryBetModel];
    
    [self refreshBottomSpace];
    
    if (timeLabel_hsf) {
        timeLabel_hsf.visible = YES;
        [timeLabel_hsf refreshNumber:((self.betViewModel.time - [self.betViewModel.sealingTim integerValue]))];
    }
}

-(void)initUI {
    bCreatedUI = true;
    betOptionsViewController = [[CommonTableViewController alloc] initWithNibName:@"CommonTableViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [betOptionsViewController setLotteryType:curLotteryType];
    [betOptionsViewController setLotteryWays:ways];
    [self.view addSubview:betOptionsViewController.view];
    [self addChildViewController:betOptionsViewController];
    
    [self.view bringSubviewToFront:self.menuBarView];
    [self.view bringSubviewToFront:self.chipView];
    
    [self.customBlurView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    [self.menuBarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
    [self.chipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view).inset(10);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    [betOptionsViewController.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.menuBarView.mas_bottom).offset(10);
        make.leading.trailing.equalTo(self.view).inset(10);
        make.bottom.equalTo(self.chipView.mas_top).inset(10);
    }];
    self.menuBarView.betModel = lotteryBetModel;
    
    // 倒计时
    HSFTimeDownConfig *config = [[HSFTimeDownConfig alloc]init];
    config.timeType = HSFTimeType_HOUR_MINUTE_SECOND;
    config.bgColor = [UIColor whiteColor];
    config.fontColor = RGB_COLOR(@"#0600FF", 1);
    config.fontSize = 18.f;
    WeakSelf
    timeLabel_hsf = [[HSFTimeDownView alloc] initWityFrame:CGRectMake(0, 0, 0, 0) config:config timeChange:^(NSInteger time) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf lotteryInterval];
        NSLog(@"hsf===%ld",(long)time);
        strongSelf->betLeftTime = time;
        strongSelf.menuBarView.timeLabel.text = [YBToolClass timeFormatted:(time)];
        
        if(!strongSelf->timeLabel_hsf.visible) {
            strongSelf.menuBarView.timeLabel.text = [NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), time];
            if (strongSelf.LobbySocket.status != 3 && time == 0) {
                dispatch_main_async_safe(^{
                    [strongSelf refreshUI];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (strongSelf!= nil) {
                        [strongSelf buildData];
                    }
                });
            }
        }
    } timeEnd:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"hsf===倒计时结束");
        if(strongSelf->timeLabel_hsf.visible){
            strongSelf->timeLabel_hsf.visible = false;
            strongSelf->sealingTime = [strongSelf.betViewModel.sealingTim integerValue];
            [strongSelf->timeLabel_hsf refreshNumber:[strongSelf.betViewModel.sealingTim integerValue]];
            strongSelf.menuBarView.timeLabel.text = [NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), (long)5];
            
        }else{
            strongSelf.menuBarView.timeLabel.text = YZMsg(@"LobbyLotteryVC_betOpen");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf!= nil) {
                    [strongSelf buildData];
                }
            });
        }
    }];
    
    [timeLabel_hsf setcurentTime:(self.betViewModel.time - [self.betViewModel.sealingTim integerValue])];
}

- (void)doEmptySelcted {
    [betOptionsViewController clearSelectedStatus];
    NSArray *betCart = [common getLotteryBetCart];
    if(betCart.count > 0){
        [self switchLotteryCartView];
    }else{
        [self switchBottomView];
    }
}

-(void)doCharge {
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
}

-(void)doBet {
    __block LobbyLotteryVC_New *weakSelf = self;
    if (!timeLabel_hsf.visible) {
        // 封盘中
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_bet_endBet")];
        return;
    }
    
    if (selectedOptions.count == 0) {
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_betEmptySelecte")];
        return;
    }
    double chipValue = [common getChipNums];
    NSInteger minZhu = [betOptionsViewController getMinZhu];
    NSString *optionName = [betOptionsViewController getOptionName]?[betOptionsViewController getOptionName]:YZMsg(@"LobbyLotteryVC_titleBet");
    NSString *selectedNameSt = [betOptionsViewController getOptionNameSt]?[betOptionsViewController getOptionNameSt]:@"";
    if (minZhu > 1) {
        // 合并注单
        NSString *new_title;
        NSString *new_value;
        for (int i = 0; i < selectedOptions.count; i ++) {
            OptionModel *optionDict = selectedOptions[i];
            NSArray *splite = [optionDict.title componentsSeparatedByString:@"_"];
            if(!new_title){
                NSString *spliteValue = splite[1];
                if ([optionName isEqualToString:@"连尾"]) {
                    spliteValue = [spliteValue stringByReplacingOccurrencesOfString:@"尾" withString:@""];
                }
                NSString *titleValue = splite[0];
                new_title = [NSString stringWithFormat:@"%@_%@", titleValue, spliteValue];
            }else{
                NSString *spliteValue = splite[1];
                if ([optionName isEqualToString:@"连尾"]) {
                    spliteValue = [spliteValue stringByReplacingOccurrencesOfString:@"尾" withString:@""];
                }
                new_title = [NSString stringWithFormat:@"%@,%@", new_title, spliteValue];
            }
            new_value = optionDict.value;
        }
        OptionModel *model = [[OptionModel alloc]init];
        model.title = new_title;
        model.value = new_value;
        selectedOptions = @[model];
    }
    
    CGFloat totalMoney = (long)(chipValue * selectedOptions.count);
    if([self.betViewModel.left_coin integerValue] / 10.0 < totalMoney){
        UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"LobbyLotteryVC_NoBalanceDetailDes") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:suerA];
        
        UIAlertAction *suerB = [UIAlertAction actionWithTitle:YZMsg(@"PayReq_chargeNow") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf doCharge];
        }];
        [alertC addAction:suerB];
        if (currentVC.presentedViewController == nil) {
            [currentVC presentViewController:alertC animated:YES completion:nil];
        }
        
        return;
    }
    NSMutableArray * orders = [NSMutableArray array];
    NSString *way = @"[";
    NSString *money = @"[";
    for (int i = 0; i < selectedOptions.count; i ++) {
        NSMutableDictionary *order = [NSMutableDictionary dictionary];
        OptionModel *optionDict = selectedOptions[i];
        NSString *st = optionDict.st ? optionDict.st : @"";
        [order setObject:st forKey:@"st"];
        [order setObject:optionDict.title forKey:@"way"];
        [order setObject:[NSString stringWithFormat:@"%f", chipValue] forKey:@"money"];
        [orders addObject:order];
        NSString *title = optionDict.title;
        NSInteger _money = chipValue;
        if(i == 0){
            way = [NSString stringWithFormat:@"%@\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@%ld",money, (long)_money];
        }else{
            way = [NSString stringWithFormat:@"%@,\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@,%ld",money, (long)_money];
        }
    }
    way = [NSString stringWithFormat:@"%@%@",way,@"]"];
    money = [NSString stringWithFormat:@"%@%@",money,@"]"];
    
    NSString *lottery_type = minnum(curLotteryType);
    NSString *issue = self.betViewModel.issue;
    
    BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
        [betConfirmVC.view removeFromSuperview];
        [betConfirmVC removeFromParentViewController];
    }];
    
    NSDictionary *param = @{
        @"name":_betViewModel.name,
        @"lotteryType":lottery_type,
        @"money":money,
        @"way":way,
        @"serTime":minnum([[NSDate date] timeIntervalSince1970]),
        @"issue":issue,
        @"optionName":optionName,
        @"optionNameSt":selectedNameSt,
        @"betLeftTime":[NSString stringWithFormat:@"%ld",betLeftTime],
        @"sealingTime":[NSString stringWithFormat:@"%ld",sealingTime],
        @"orders": orders
    };
    
    [betConfirmVC setOrderInfo:param];
    //WeakSelf
    __weak BetConfirmViewController * weakbetConfirmVC = betConfirmVC;
    betConfirmVC.betBlock = ^(NSInteger idx, NSUInteger num){
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf doEmptySelcted];
        [shadowView removeFromSuperview];
        [weakbetConfirmVC.view removeFromSuperview];
        [weakbetConfirmVC removeFromParentViewController];
    };
    [self.view addSubview:betConfirmVC.view];
    betConfirmVC.view.bottom = self.view.bottom;
    [self addChildViewController:betConfirmVC];
    return;
}

- (void)HomeLottery_didSelected {
    NSArray * options = [betOptionsViewController getSelectedOptions];
    selectedOptions = options;
    if (options && options.count >= [betOptionsViewController getMinZhu]) {
        [self switchBetView];
    } else {
        NSArray *betCart = [common getLotteryBetCart];
        if (betCart.count > 0) {
            [self switchLotteryCartView];
        } else {
            [self switchBottomView];
        }
    }
}

- (void)switchBottomView {
    bottomShowType = 0;
    [self refreshBottomSpace];
}

- (void)switchBetView {
    bottomShowType = 1;
    [self refreshBottomSpace];
}

- (void)switchLotteryCartView {
    bottomShowType = 2;
    [self refreshBottomSpace];
}

- (void)refreshBottomSpace {
    if(bottomShowType == 0){
        [self.chipView.continueBtn setEnabled: NO];
    }else if(bottomShowType == 1){
        [self.chipView.continueBtn setEnabled: YES];
    }else if(bottomShowType == 2){
        [self.chipView.continueBtn setEnabled: NO];
    }
}

- (void)cacheGameList {
    NSArray *gameListAr = [common getlotteryc];
    if (gameListAr==nil || gameListAr.count<=1) {
        NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getLotteryList&uid=%@&token=%@&type=lobby",[Config getOwnID],[Config getOwnToken]];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if(code == 0)
            {
                NSDictionary *dict = [info firstObject];
                if (dict[@"lotteryList"]) {
                    [common savelotterycontroller:dict[@"lotteryList"]];
                }
            }
            
        } fail:^(NSError * _Nonnull error) {
        }];
    }
}

- (void)lotteryInterval {
    if(!_betViewModel) return;
    NSDate * nowDate = [NSDate date];
    NSInteger timeDistance = [openTime timeIntervalSinceDate:nowDate];
    
    _betViewModel.time = [[NSString stringWithFormat:@"%ld", timeDistance] integerValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lotterySecondNotify" object:nil userInfo:@{
        @"betLeftTime":[NSString stringWithFormat:@"%ld", _betViewModel.time],
        @"sealingTime":_betViewModel.sealingTim,
        @"issue":_betViewModel.issue,
        @"lotteryType":_betViewModel.lotteryType,
    }];
    timeReplyCount ++;
    if (timeReplyCount % 3 == 0) {
        if (self.socketDelegate) {
            NSString *lotteryType = [NSString stringWithFormat:@"%ld", curLotteryType];
            [self.socketDelegate sendSyncLotteryCMD:lotteryType];
        }
        return;
    }
}
- (void)releaseView {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HomeLottery_didSelected" object:nil];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self deleteSocket];
    if(timeLabel_hsf){
        [timeLabel_hsf invaliTimer];
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
        [self.socketDelegate addNodeListen:model isFirstConnect:YES serverUrl:serverUrl];
    }
}

- (void)deleteSocket {
    if (self.socketDelegate) {
        [self.socketDelegate socketStop];
    }
    self.socketDelegate.socketDelegate = nil;
    self.socketDelegate = nil;
}

/// 开奖通知
- (void)refreshLastOpenNotice:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    VKLOG(@"开奖通知 %@", dict);
    NSInteger lotteryType = [dict[@"lotteryType"] integerValue];
    if (lotteryType != curLotteryType) {
        return;
    }
    [self.menuBarView.chartView updateChartData:dict[@"result"]];
}

- (void)giveVideoTicketMessage:(GiveVideoTicket *)msg {
    NSString *text = msg.msg.ct;
    if (text.length) {
        [MBProgressHUD showBottomMessage:text];
    }
//    [VideoTicketFloatView refreshFloatData];
}

@end
