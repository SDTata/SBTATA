//
//  LotteryBetViewController.m
//
//

#import "LotteryBetViewController_LB.h"
#import "BetOptionCollectionViewCell.h"
#import "PayViewController.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "OpenHistoryViewController.h"
#import "IssueCollectionViewCell.h"
#import "popWebH5.h"

#import "LobbyHistoryAlertController.h"
#import "ChipChoiseCell.h"
#import "WMZDialog.h"
#import "S2C.pbobjc.h"
#import "UIView+Shake.h"
#import "LotteryBetResultePopView.h"
#import "SlotView.h"
#import "ChartView.h"
#import "LiveOpenListYFKSCell.h"
#import "LotteryNNModel.h"
#import "LiveBetListYFKSCell.h"
#import "BetListModel.h"
#import "LotteryCustomChipView.h"


#define kChipChoiseCell @"ChipChoiseCell"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"

#define perSection    M_PI*2/37
#define kLiveOpenListYFKSCell @"LiveOpenListYFKSCell"
#define kLiveBetListYFKSCell @"LiveBetListYFKSCell"
#define bottomConstant 0

#define heightView LotteryWindowNewHeigh

@interface LotteryBetViewController_LB ()<CAAnimationDelegate>{
    BOOL isShow;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSDictionary *allData;
    NSMutableArray *ways;   // 投注选项
    
    BOOL bUICreated; // UI是否创建
    
    
    NSInteger selectLineIndex;
    NSString *selectLineNum;  // 选择的line数
    NSInteger selectBetIndex;
    NSString *selectBetNum; // 选择的下注金额
    NSInteger winNum;
    BOOL isAuto;    //是否自动
    NSInteger freeTotalWinNum;  //免费win总数
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *poolStr;  //奖池
    NSMutableArray *allChipNumArray;
    NSMutableArray *allLineNumArray;
    BOOL isStart;
    
    AVAudioPlayer *voiceAwardMoney;
  
    BOOL isFinance;
    BOOL isOpenning;
    NSMutableDictionary *contiDic;
    NSString *issueContinueBet;
    BOOL isContinueBet;
    NSInteger _numberTimesecond;
    
    NSInteger betPage;
    
    NSInteger _currentState;
    NSTimeInterval _currentStartTime;
    NSTimeInterval _currentEndTime;
    BOOL _netFlag; //网络锁
    
    BOOL isShowTopList; //走势图等顶部视图是否显示
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) UIView * bigWinPopview;
@property (nonatomic, strong) UILabel * bigWinLab;
@property (nonatomic, strong) UIView * freeWinPopview;
@property (nonatomic, strong) UILabel * freeWinLab;
@property (nonatomic, strong) UIView * freeTimesPopview;
@property (nonatomic, strong) UIImageView * freeTimesImgV;
@property (nonatomic, strong) NSString * totalWin;
@property (nonatomic, assign) NSInteger freeTimes;
@property (nonatomic, strong) NSDictionary * curDict;  //当前开奖字典
@property (nonatomic, strong) NSMutableArray * freeArr;  //免费数组
@property (nonatomic, strong) SlotView * slotView;
@property(nonatomic,strong)NSTimer *timer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property(nonatomic,strong)NSMutableArray * toolBtnArr;
@property(nonatomic,strong)UIButton * selectedToolBtn;
@property(nonatomic,strong)NSMutableArray *allOpenResultData;
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@property(nonatomic,strong) CustomScrollView * toolScrollView;

@end

@implementation LotteryBetViewController_LB

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@0];
}
- (void)viewDidAppear:(BOOL)animated{
    if (!isShow) {
        isShow = YES;
        self.slotView = [SlotView instanceSlotViewWithFrame:self.v_slotContainer.bounds];
        [self.v_slotContainer addSubview:self.slotView];
        betPage = 1;
        _netFlag = YES;
        isShowTopList = NO;
        [self createToolScorllview];
        self.topHeight.constant = 0;
        
        [self getBetInfo];
        [self getInfo:YES];
        //        self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
        self.contentView.hidden = NO;
        if(_isExit){
            self.bottomConstraint.constant = 0;
        }else{
            [self.view layoutIfNeeded];
            self.bottomConstraint.constant = 0;
            WeakSelf
            [UIView animateWithDuration:0.25 animations:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:strongSelf action:@selector(exitView)];
                [strongSelf.shadowView addGestureRecognizer:myTap];
            }];
        }
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [YBToolClass sharedInstance].lotteryLiveGameHeight = heightView+ShowDiff;
    self.bottomConstraint.constant =  (heightView+ShowDiff+[self LobbyWindowHeight]);
    // 菊花
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // testActivityIndicator.center = self.view.center;
    [self.contentView addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor whiteColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    [testActivityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    
    //0-0[self.betHistoryButton setTitle:YZMsg(@"LobbyLotteryVC_BetRecord") forState:UIControlStateNormal];
    
    allChipNumArray = [NSMutableArray arrayWithArray:@[
        @"2",
        @"5",
        @"10",
        @"20",
        @"100",
        @"1000"
    ]];
    allLineNumArray = [NSMutableArray arrayWithArray:@[
        @"1",
        @"2",
        @"3",
        @"4",
        @"5"
    ]];
    self.freeArr = [NSMutableArray array];
    selectLineNum = @"5";
    selectLineIndex = 4;
    selectBetNum = @"2";
    selectBetIndex = 0;
    freeTotalWinNum = 0;
    self.lb_lineCount.text = selectLineNum;
    self.lb_betCount.text = selectBetNum;
    isAuto = NO;
    self.lb_totalCount.text = [NSString stringWithFormat:@"%d",[selectLineNum intValue] * [selectBetNum intValue]];
    
    contiDic = [NSMutableDictionary dictionary];
    //0-0self.continueBtn.enabled = false;
    [self.KeyBTN setBackgroundImage:[[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(120, 30)] sd_imageByRoundCornerRadius:15] forState:UIControlStateNormal];
    [self.KeyBTN setTitle:YZMsg(@"Livebroadcast_SaySomething") forState:UIControlStateNormal];
    //    [self stopWobble];
    ////   摇摆
    //    [self startWobble];
    if(!self.timer){
        self.timer=[NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(getPoolDataInfo) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    self.leftCoinLabel.adjustsFontSizeToFitWidth = YES;
    self.leftCoinLabel.minimumScaleFactor = 0.5;
    self.lb_winCount.adjustsFontSizeToFitWidth = YES;
    self.lb_winCount.minimumScaleFactor = 0.5;
    
    self.betHistoryList.hidden = YES;
    self.topHeight.constant = 0;
    self.view.height = heightView+ShowDiff;
    [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
    NSDate *now = [NSDate date];
    NSDate *zero = [self getZeroTimeWithDate:now];
    NSDate *end = [self getEndTimeWithDate:now];
    _currentStartTime = [zero timeIntervalSince1970];
    _currentEndTime = [end timeIntervalSince1970];
    
    _currentState = -1;
    
    
    
    [self.view layoutIfNeeded];
    
    
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
   
}

-(void)createToolScorllview{
    
    if (self.toolScrollView) {
        [self.toolScrollView removeFromSuperview];
        self.toolScrollView = nil;
    }
    
    self.toolScrollView = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, 0, self.toolBg.size.width, self.toolBg.size.height)];
    self.toolScrollView.delegate = self;
    self.toolScrollView.alwaysBounceHorizontal = YES;
    self.toolScrollView.backgroundColor = [UIColor clearColor];
    self.toolScrollView.userInteractionEnabled = YES;
    self.toolScrollView.delaysContentTouches = NO;
    self.toolScrollView.canCancelContentTouches = YES;
    
    NSArray * imgArr = @[@"yfks_icon_wfsm",@"yfks_icon_xxkq",@"yfks_icon_lstz",@"yfks_icon_lw",@"yfks_icon_game",@"live_redpack"];
    CGFloat contentLength = 0;
    CGFloat buttonWidth = 30.0;
    CGFloat spacing = 5;
    
    self.toolBtnArr = [NSMutableArray array];
    for (int i = 0; i< imgArr.count; i ++) {
        if (self.isFromLiveBroadcast && i >= 3) {
            continue;
        }
        UIButton *livechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        livechatBtn.frame = CGRectMake(5+i*(buttonWidth+spacing),5,buttonWidth,buttonWidth);
        livechatBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [livechatBtn setImage:[ImageBundle imagewithBundleName:imgArr[i]] forState:UIControlStateNormal];
        livechatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        livechatBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        livechatBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        livechatBtn.titleLabel.minimumScaleFactor = 0.3;
        [livechatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        livechatBtn.tag = 1000+i;
        [livechatBtn setBackgroundImage:[[UIImage sd_imageWithColor:RGB_COLOR(@"#000000", 0.5) size:CGSizeMake(100, 30)] sd_imageByRoundCornerRadius:0] forState:UIControlStateNormal];
        //        livechatBtn.backgroundColor = RGB_COLOR(@"#000000", 0.5);
        livechatBtn.layer.masksToBounds = YES;
        livechatBtn.layer.cornerRadius = buttonWidth/2;
        [livechatBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolScrollView addSubview:livechatBtn];
        [self.toolBtnArr addObject:livechatBtn];
        if(i == imgArr.count -1){
            contentLength = livechatBtn.right + 5;
        }
        if(i == 1){
            [livechatBtn setImage:[ImageBundle imagewithBundleName:@"yfks_icon_xxgb"] forState:UIControlStateSelected];
            self.musicBtn = livechatBtn;
        }
        
    }
    self.toolScrollView.contentSize = CGSizeMake(contentLength, 0);
    [self.toolBg addSubview:self.toolScrollView];
}

- (NSDate *)getZeroTimeWithDate:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
    NSDateComponents*zerocompents = [cal components:unitFlags fromDate:date];
    NSLog(@"%@",zerocompents);
    // 转化成0晨0点时间
    zerocompents.hour=0;
    zerocompents.minute=0;
    zerocompents.second=0;
    NSLog(@"%@",zerocompents);
    // NSdatecomponents转NSdate类型
    NSDate*newdate= [cal dateFromComponents:zerocompents];
    return newdate;
}
- (NSDate *)getEndTimeWithDate:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
    NSDateComponents*zerocompents = [cal components:unitFlags fromDate:date];
    NSLog(@"%@",zerocompents);
    // 转化成当天23点59分时间
    zerocompents.hour=23;
    zerocompents.minute=59;
    zerocompents.second=59;
    NSLog(@"%@",zerocompents);
    // NSdatecomponents转NSdate类型
    NSDate*newdate= [cal dateFromComponents:zerocompents];
    return newdate;
}


// 投注记录
- (void)getBetInfo{
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Lottery.betList3" withBaseDomian:YES andParameter:@{@"page":@(betPage),@"lottery_type":@(curLotteryType),@"status":@(_currentState),@"start_time":@(_currentStartTime),@"end_time":@(_currentEndTime)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            NSLog(@"%@",info);
            strongSelf.dataModel = [BetListModel mj_objectWithKeyValues:info];
            if (strongSelf->betPage == 1) {
                strongSelf.listModel = strongSelf.dataModel.list;
                [strongSelf.betHistoryList scrollsToTop];
            }else{
                NSMutableArray *new_list = strongSelf.listModel.mutableCopy;
                [new_list addObjectsFromArray:strongSelf.dataModel.list];
                strongSelf.listModel = new_list.copy;
            }
            if (strongSelf.dataModel.list.count == 10 && strongSelf.dataModel.page.current.integerValue < strongSelf.dataModel.page.max.integerValue) {
                strongSelf->betPage = strongSelf.dataModel.page.current.integerValue + 1;
                strongSelf->_netFlag = YES;
            }else{
                strongSelf->_netFlag = NO;
            }
            [strongSelf.betHistoryList reloadData];
        }else{
            
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        NSLog(@"%@",error);
    }];
}



-(void)getPoolDataInfo{
    [self getInfo:NO];
}

//获取彩种信息
- (void)getInfo:(BOOL)isFirst{
    
    if (!isFirst) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSInteger timeSecond = interval;
        if (timeSecond-_numberTimesecond<10) {
            return;
        }
        _numberTimesecond = timeSecond;
    }
    
    NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getBetViewInfo&uid=%@&token=%@&lottery_type=%@&live_id=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", (long)curLotteryType],minnum([GlobalDate getLiveUID])];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"xxxxxxxxx%@",info);
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        if (strongSelf.isExit) {
            return;
        }
        if(code == 0)
        {
            NSLog(@"%@",info);
            NSDictionary * dict = [info firstObject];
            strongSelf->poolStr = minstr([dict valueForKey:@"pool"]);
            strongSelf.poolLab.attributedText = [strongSelf numwithStr:strongSelf->poolStr imageStr:@"lb_jackpot_"];
            if (isFirst) {
                LiveUser *user = [Config myProfile];
                user.coin = minstr([dict valueForKey:@"left_coin"]);
                [Config updateProfile:user];
                self.leftCoinLabel.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
            }
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
            });
        }
        else{
            [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
            [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            if(msg){
                [MBProgressHUD showError:msg];
            }else{
                [MBProgressHUD showError:YZMsg(@"public_networkError")];
            }
            [strongSelf exitView];
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@",YZMsg(@"public_networkError"),error.description]];
        [strongSelf exitView];
        return;
    }];
}
//刷新UI
-(void)refreshUI{
    if(!ways){
        ways = [NSMutableArray array];
    }
    if(!bUICreated){
        [self initUI];
    }
    // 更新余额
    //    [self refreshLeftCoinLabel];
}

-(void)initUI{
    bUICreated = true;
    // 刷新筹码和往期记录
    [self initCollection];
    // 监听按钮事件[历史期号]
    self.chargeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapCharge = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doCharge:)];
    [self.chargeView addGestureRecognizer:tapCharge];
    // 监听按钮事件[历史投注]
    //    [self.betHistoryButton addTarget:self action:@selector(doShowBetHistory) forControlEvents:UIControlEventTouchUpInside];
    //    [self.musicBtn addTarget:self action:@selector(musicSwitch:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"lb_sound_dark"] forState:UIControlStateSelected];
    
}
-(void)musicSwitch:(UIButton*)button
{
    button.selected = !button.selected;
    if (self.musicBtn.selected) {
        [voiceAwardMoney setVolume:0];
    }else{
        [voiceAwardMoney setVolume:1];
    }
    
}

//点击开始滚动
- (IBAction)startAction:(id)sender {
    NSLog(@"开始");
    if (isStart) {
        return;
    }
    isStart = YES;
    self.startBtn.userInteractionEnabled = NO;
    [self.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_dark"] forState:UIControlStateNormal];
    self.betHistoryButton.userInteractionEnabled = NO;
    [self doBetType:@"" BetDetailType:@"" ];
    
}

// 下注
-(void)doBetType:(NSString*)betType BetDetailType:(NSString*)detailType {
    // 生成确认界面需要的信息
    NSString * bet_info = [NSString stringWithFormat:@"0,%d",[selectBetNum intValue] *10];
    if (selectLineIndex > 0) {
        for (int i = 1; i <= selectLineIndex; i ++) {
            bet_info = [[NSString alloc] initWithFormat:@"%@|%d,%d",bet_info,i,[selectBetNum intValue] *10];
        }
    }
    
    WeakSelf
    NSString *betUrl = [NSString stringWithFormat:@"User.playSlotDraw&uid=%@&token=%@&bet_info=%@",[Config getOwnID],[Config getOwnToken],bet_info];
    __block BOOL showHUDBOOL = true;
    [[YBNetworking sharedManager] postNetworkWithUrl:betUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"开始1");
        [MBProgressHUD hideHUD];
        showHUDBOOL = false;
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            NSDictionary *dict = [info firstObject];
            LiveUser *user = [Config myProfile];
            user.coin = [NSString stringWithFormat:@"%0.2f",[dict[@"cur_money"] floatValue]];
            [Config updateProfile:user];
            [strongSelf openResulte:dict];
            if(strongSelf.selectedToolBtn.tag == 1001){
                strongSelf->betPage = 1;
                [strongSelf getBetInfo];
            }
            
            
        }
        else{
            if (strongSelf->isAuto) {
                strongSelf->isAuto = NO;
                [strongSelf.autoBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_auto"] forState:UIControlStateNormal];
            }
            strongSelf.startBtn.userInteractionEnabled = YES;
            [strongSelf.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_light"] forState:UIControlStateNormal];
            strongSelf.betHistoryButton.userInteractionEnabled = YES;
            strongSelf->isStart = false;
            [MBProgressHUD showError:msg];
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"开始2");
        strongSelf->isStart = false;
        showHUDBOOL = false;
        [MBProgressHUD hideHUD];
        // 请求失败
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        strongSelf->isAuto = NO;
        [strongSelf.autoBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_auto"] forState:UIControlStateNormal];
        strongSelf.startBtn.userInteractionEnabled = YES;
        [strongSelf.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_light"] forState:UIControlStateNormal];
        strongSelf.betHistoryButton.userInteractionEnabled = YES;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (showHUDBOOL) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
        }
        
    });
    
}

// 开奖结果展示
-(void)openResulte:(NSDictionary *)info {
    self.freeTimes = [info[@"free_times"] intValue];
    freeTotalWinNum = [info[@"total_win"] integerValue];
    NSArray * data = info[@"win_res"];
    if (data.count == 0) {
        return;
    }else if (self.freeTimes && data.count -1 == self.freeTimes) {
        self.curDict = data[0];
        for (int i = 1; i < data.count; i ++) {
            [self.freeArr addObject:data[i]];
        }
        [self showReslutView:self.curDict isFree:NO];
    }else if(data.count == 1){
        self.curDict = data[0];
        [self showReslutView:self.curDict isFree:NO];
    }
}

// 免费开奖展示
-(void)freeOpenShow{
    self.startBtn.userInteractionEnabled = NO;
    self.autoBtn.userInteractionEnabled = NO;
    self.btn_lineDes.userInteractionEnabled = NO;
    self.btn_lineAdd.userInteractionEnabled = NO;
    self.btn_betDes.userInteractionEnabled = NO;
    self.btn_betAdd.userInteractionEnabled = NO;
    [self.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_dark"] forState:UIControlStateNormal];
    self.betHistoryButton.userInteractionEnabled = NO;
    isStart = YES;
    
    self.freeTimesLab.attributedText = [self getFreeTimesStr:[NSString stringWithFormat:@"%ld",self.freeTimes]];
    self.freeTimesLab.hidden = NO;
    self.freeBgView.hidden = NO;
    if (self.freeArr.count && self.freeTimes) {
        self.curDict = self.freeArr[0];
        self.freeTimes --;
        [self.freeArr removeObject:self.curDict];
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf showReslutView:strongSelf.curDict isFree:YES];
        });
    }
}

// 开奖试图
-(void)showReslutView:(NSDictionary *)dict isFree:(BOOL)isFree{
    if (_isExit) {
        return;
    }
    WeakSelf;
    if (!voiceAwardMoney||(voiceAwardMoney &&  [voiceAwardMoney.url.path rangeOfString:@"lb_start.mp3"].location == NSNotFound)) {
        NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]URLForResource:@"lb_start.mp3" withExtension:Nil];
        voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
        if (self.musicBtn.selected) {
            [voiceAwardMoney setVolume:0];
        }else{
            [voiceAwardMoney setVolume:1];
        }
    }
    [voiceAwardMoney prepareToPlay];
    [voiceAwardMoney play];
    
    [self.slotView startSlotWithResult:dict[@"icon_id_list"] animationCompleteHandler:^{
        STRONGSELF
        if (strongSelf == nil||strongSelf.isExit) {
            return;
        }
        NSArray * win_pos_list = dict[@"win_pos_list"];
        if(!isFree && strongSelf.freeArr.count){
            //            中奖免费次数弹框
            [strongSelf showFreeTimesPopview];
        }else if(isFree && strongSelf.freeArr.count == 0 && strongSelf.freeTimes ==0 ) {
            //            中奖免费次数总金额弹框
            if (strongSelf->freeTotalWinNum >0) {
                [strongSelf showFreeWinNumPopview];
            }
            strongSelf.autoBtn.userInteractionEnabled = YES;
            strongSelf.btn_lineDes.userInteractionEnabled = YES;
            strongSelf.btn_lineAdd.userInteractionEnabled = YES;
            strongSelf.btn_betDes.userInteractionEnabled = YES;
            strongSelf.btn_betAdd.userInteractionEnabled = YES;
            strongSelf.betHistoryButton.userInteractionEnabled = YES;
            if (!strongSelf->isAuto) {
                strongSelf.startBtn.userInteractionEnabled = YES;
                [strongSelf.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_light"] forState:UIControlStateNormal];
                strongSelf->isStart = false;
            }
        }else if ([strongSelf.curDict[@"big_win"] boolValue]) {
            //            中大奖弹框
            [strongSelf showBigWinPopview];
        }
        //        动画完刷新余额
        if (strongSelf.freeArr.count == 0 && strongSelf.freeTimes ==0) {
            [strongSelf refreshLeftCoinLabel];
        }
        if (win_pos_list.count) {
            //            刷新赢钱数
            [strongSelf refreshWinNumLabel];
            if ([strongSelf.curDict[@"big_win"] boolValue]) {
                //                中大奖声音
                if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"lb_bigwin.mp3"].location == NSNotFound)) {
                    NSURL *url=[[XBundle currentXibBundleWithResourceName:@""] URLForResource:@"lb_bigwin.mp3" withExtension:Nil];
                    strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
                    if (strongSelf.musicBtn.selected) {
                        [strongSelf->voiceAwardMoney setVolume:0];
                    }else{
                        [strongSelf->voiceAwardMoney setVolume:1];
                    }
                }
                [strongSelf->voiceAwardMoney prepareToPlay];
                [strongSelf->voiceAwardMoney play];
            }else{
                //                中奖声音
                if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"lb_win.mp3"].location == NSNotFound)) {
                    NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"lb_win.mp3" withExtension:Nil];
                    strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
                    if (strongSelf.musicBtn.selected) {
                        [strongSelf->voiceAwardMoney setVolume:0];
                    }else{
                        [strongSelf->voiceAwardMoney setVolume:1];
                    }
                }
                [strongSelf->voiceAwardMoney prepareToPlay];
                [strongSelf->voiceAwardMoney play];
            }
            //            中奖画线
            [strongSelf.slotView startLine:dict[@"win_pos_list"] withLineCompleteHander:^{
                if (strongSelf.freeArr.count && strongSelf.freeTimes) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf freeOpenShow];
                    });
                }else if(strongSelf->isAuto){
                    strongSelf.freeTimesLab.hidden = YES;
                    strongSelf.freeBgView.hidden = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [strongSelf doBetType:@"" BetDetailType:@""];
                    });
                }else{
                    strongSelf.freeTimesLab.hidden = YES;
                    strongSelf.freeBgView.hidden = YES;
                    strongSelf.startBtn.userInteractionEnabled = YES;
                    [strongSelf.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_light"] forState:UIControlStateNormal];
                    strongSelf.betHistoryButton.userInteractionEnabled = YES;
                    strongSelf->isStart = false;
                }
            }];
        }else{
            if (strongSelf.freeArr.count && strongSelf.freeTimes) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf freeOpenShow];
                });
            }else if(strongSelf->isAuto){
                strongSelf.freeTimesLab.hidden = YES;
                strongSelf.freeBgView.hidden = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf doBetType:@"" BetDetailType:@""];
                });
            }else{
                strongSelf.freeTimesLab.hidden = YES;
                strongSelf.freeBgView.hidden = YES;
                strongSelf.startBtn.userInteractionEnabled = YES;
                [strongSelf.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_light"] forState:UIControlStateNormal];
                strongSelf.betHistoryButton.userInteractionEnabled = YES;
                strongSelf->isStart = false;
            }
        }
    }];
}


-(void)refreshLeftCoinLabel{
    LiveUser *user = [Config myProfile];
    self.leftCoinLabel.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
    winNum = [self.curDict[@"win_money"] integerValue]/10;
    self.lb_winCount.text = [NSString stringWithFormat:@"%ld", winNum];
    
    
}

-(void)refreshWinNumLabel{
    winNum = [self.curDict[@"win_money"] integerValue]/10;
    self.lb_winCount.text = [NSString stringWithFormat:@"%ld", winNum];
}

-(void)doShowBetHistory{
    LobbyHistoryAlertController *history = [[LobbyHistoryAlertController alloc]initWithNibName:@"LobbyHistoryAlertController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    WeakSelf
    history.closeCallback = ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-heightView-ShowDiff-[strongSelf LobbyWindowHeight], SCREEN_WIDTH, heightView+ShowDiff+[strongSelf LobbyWindowHeight]);
    };
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    history.view.frame = CGRectMake(0, _window_height, _window_width, _window_height);
    [self.view addSubview:history.view];
    [self addChildViewController:history];
    history.view.frame = CGRectMake(0, 0, _window_width, _window_height);
    [history.view didMoveToSuperview];
    [history didMoveToParentViewController:self];
}


- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

-(void)doCharge:(UIButton *)sender{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
}

-(void)doCustomChip{
    LotteryCustomChipView *view = [LotteryCustomChipView new];
    [view showFromCenter];
    
    WeakSelf
    view.clickConfirmBlock = ^(double amount) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        for (ChipsModel *model in strongSelf->chipsArraysAll) {
//            if (model.isEdit) {
//                model.chipNumber = amount;
//                model.chipStr = [NSString stringWithFormat:@"?\n%@", [YBToolClass currencyCoverToK:[YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", amount]showUnit: NO]]];
//                model.customChipNumber = model.chipNumber;
//            }
//        }
//        [strongSelf.betChipCollectionView reloadData];
    };
}

-(void)exitView{
    if (self.contentView.alpha<=0) {
        return;
    }
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    voiceAwardMoney = nil;
    isAuto = NO;
    //    [self stopWobble];
    
    if(_isExit) return;
    _isExit = true;
    //    [self.view layoutIfNeeded];
    self.bottomConstraint.constant =  (heightView+ShowDiff+[self LobbyWindowHeight]);
    if (self.lotteryDelegate!= nil && isShowTopList) {
        isShowTopList = NO;
        [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
        [self.lotteryDelegate refreshTableHeight:NO];
    }
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
        [GameToolClass setCurOpenedLotteryType:0];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:@"lotterySecondNotify" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:@"LotteryOpenAward" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:KBetDoNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:KBetWinAllUserNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@1];
        if (strongSelf.lotteryDelegate!= nil) {
            [strongSelf.lotteryDelegate lotteryCancless];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)doKey:(id)sender {
   
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 0;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.view.frame = CGRectZero;
    }];
    if (self.lotteryDelegate!= nil) {
        [self.lotteryDelegate showkeyboard:sender];
    }
}

- (void)appearToolBar{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 1;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.view.frame = CGRectMake(0, SCREEN_HEIGHT-heightView-ShowDiff-[self LobbyWindowHeight], SCREEN_WIDTH, heightView+ShowDiff+[self LobbyWindowHeight]);
    }];
}

- (IBAction)returnLive:(id)sender {
    [self exitView];
    //    if (self.lotteryDelegate!= nil) {
    //        [self.lotteryDelegate returnCancless];
    //    }
}

// lin 减
- (IBAction)lineDesAction:(id)sender {
    if (selectLineIndex == 0) {
        selectLineIndex = 4;
    }else{
        selectLineIndex--;
    }
    selectLineNum = allLineNumArray[selectLineIndex];
    self.lb_lineCount.text = selectLineNum;
    self.lb_totalCount.text = [NSString stringWithFormat:@"%d",[selectLineNum intValue] * [selectBetNum intValue]];
}
//line 加
- (IBAction)lineAddAction:(id)sender {
    if (selectLineIndex == 4) {
        selectLineIndex = 0;
    }else{
        selectLineIndex++;
    }
    selectLineNum = allLineNumArray[selectLineIndex];
    self.lb_lineCount.text = selectLineNum;
    self.lb_totalCount.text = [NSString stringWithFormat:@"%d",[selectLineNum intValue] * [selectBetNum intValue]];
}
// bet减
- (IBAction)betDesAction:(id)sender {
    if (selectBetIndex == 0) {
        selectBetIndex = 5;
    }else{
        selectBetIndex--;
    }
    selectBetNum = allChipNumArray[selectBetIndex];
    self.lb_betCount.text = selectBetNum;
    self.lb_totalCount.text = [NSString stringWithFormat:@"%d",[selectLineNum intValue] * [selectBetNum intValue]];
}
// bet加
- (IBAction)betAddAction:(id)sender {
    if (selectBetIndex == 5) {
        selectBetIndex = 0;
    }else{
        selectBetIndex++;
    }
    selectBetNum = allChipNumArray[selectBetIndex];
    self.lb_betCount.text = selectBetNum;
    self.lb_totalCount.text = [NSString stringWithFormat:@"%d",[selectLineNum intValue] * [selectBetNum intValue]];
}
- (IBAction)autoAction:(id)sender {
    if (isAuto) {
        isAuto = NO;
        [self.autoBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_auto"] forState:UIControlStateNormal];
        self.startBtn.userInteractionEnabled = YES;
        [self.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_light"] forState:UIControlStateNormal];
    }else{
        isAuto = YES;
        if (!isStart) {
            [self doBetType:@"1" BetDetailType:@"1"];
        }
        isStart = YES;
        [self.autoBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_stop"] forState:UIControlStateNormal];
        self.startBtn.userInteractionEnabled  = NO;
        [self.startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"lb_start_dark"] forState:UIControlStateNormal];
        self.betHistoryButton.userInteractionEnabled = NO;
    }
}

-(void)showBigWinPopview{
    if (!self.bigWinPopview) {
        self.bigWinPopview = [[UIView alloc] initWithFrame:CGRectMake(kWidth/2 - 120, -190, 240, 190)];
        self.bigWinPopview.backgroundColor = [UIColor clearColor];
        [self.popBgView addSubview:self.bigWinPopview];
        
        UIImageView * bigWinImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 180)];
        bigWinImgV.image = [ImageBundle imagewithBundleName:@"lb_bigwin_bg"];
        [self.bigWinPopview addSubview:bigWinImgV];
        
        UIImageView * bigWinNumImgV = [[UIImageView alloc] initWithFrame:CGRectMake(40,130, 140, 36)];
        bigWinNumImgV.image = [ImageBundle imagewithBundleName:@"lb_bigwin_input"];
        [self.bigWinPopview addSubview:bigWinNumImgV];
        
        self.bigWinLab = [[UILabel alloc] initWithFrame:CGRectMake(45,130, 130, 36)];
        self.bigWinLab.font = [UIFont systemFontOfSize:15];
        self.bigWinLab.textColor = [UIColor blueColor];
        self.bigWinLab.textAlignment = NSTextAlignmentCenter;
        [self.bigWinPopview addSubview:self.bigWinLab];
    }
    self.popBgView.backgroundColor = RGB_COLOR(@"#000000", 0.5);
    int winMoney =  [self.curDict[@"win_money"] intValue]/10;
    //    self.bigWinLab.text =  [NSString stringWithFormat:@"%d",winMoney];
    self.bigWinLab.attributedText = [self numwithStr:[NSString stringWithFormat:@"%d",winMoney] imageStr:@"lb_bigwin_"];
    
    [UIView animateWithDuration:1 animations:^{
        self.bigWinPopview.y = 40;
        self.popBgView.hidden = NO;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.bigWinPopview.y = 320;
                [self.contentView layoutIfNeeded];
            }completion:^(BOOL finished) {
                self.popBgView.hidden = YES;
                self.bigWinPopview.y = -190;
            }];
        });
    }];
}

-(void)showFreeWinNumPopview{
    if (!self.freeWinPopview) {
        self.freeWinPopview = [[UIView alloc] initWithFrame:CGRectMake(kWidth/2 - 120, -190, 240, 190)];
        self.freeWinPopview.backgroundColor = [UIColor clearColor];
        [self.popBgView addSubview:self.freeWinPopview];
        
        UIImageView * freeWinImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 180)];
        freeWinImgV.image = [ImageBundle imagewithBundleName:@"lb_freewin_bg"];
        [self.freeWinPopview addSubview:freeWinImgV];
        
        UIImageView * freeWinNumImgV = [[UIImageView alloc] initWithFrame:CGRectMake(40,115,160, 36)];
        freeWinNumImgV.image = [ImageBundle imagewithBundleName:@"lb_bigwin_input"];
        [self.freeWinPopview addSubview:freeWinNumImgV];
        
        self.freeWinLab = [[UILabel alloc] initWithFrame:CGRectMake(45,115, 150, 36)];
        //        self.freeWinLab.font = [UIFont systemFontOfSize:15];
        //        self.freeWinLab.textColor = [UIColor blueColor];
        self.freeWinLab.textAlignment = NSTextAlignmentCenter;
        [self.freeWinPopview addSubview:self.freeWinLab];
    }
    self.popBgView.backgroundColor = RGB_COLOR(@"#000000", 0.5);
    self.freeWinLab.attributedText = [self numwithStr:[NSString stringWithFormat:@"%ld",freeTotalWinNum/10] imageStr:@"lb_freewin_"];
    //    self.freeWinLab.text = [NSString stringWithFormat:@"%ld",freeTotalWinNum/10];
    
    [UIView animateWithDuration:0.7 animations:^{
        self.freeWinPopview.y = 40;
        self.popBgView.hidden = NO;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.freeWinPopview.y = 320;
                [self.contentView layoutIfNeeded];
            }completion:^(BOOL finished) {
                self.popBgView.hidden = YES;
                self.freeWinPopview.y = -190;
            }];
        });
    }];
}
//免费次数弹框
-(void)showFreeTimesPopview{
    if (!self.freeTimesPopview) {
        self.freeTimesPopview = [[UIView alloc] initWithFrame:CGRectMake(kWidth/2 - 120, -190, 240, 190)];
        self.freeTimesPopview.backgroundColor = [UIColor clearColor];
        [self.popBgView addSubview:self.freeTimesPopview];
        
        UIImageView * freeWinImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 180)];
        freeWinImgV.image = [ImageBundle imagewithBundleName:@"lb_freespin_bg"];
        [self.freeTimesPopview addSubview:freeWinImgV];
        
        self.freeTimesImgV = [[UIImageView alloc] initWithFrame:CGRectMake(50,95, 16, 25)];
        [self.freeTimesPopview addSubview:self.freeTimesImgV];
        
        UIImageView * freeImgV = [[UIImageView alloc] initWithFrame:CGRectMake(70,95,45,25)];
        freeImgV.image = [ImageBundle imagewithBundleName:@"lb_freespin_free"];
        [self.freeTimesPopview addSubview:freeImgV];
        
        UIImageView * spinsImgV = [[UIImageView alloc] initWithFrame:CGRectMake(120,95,58,25)];
        spinsImgV.image = [ImageBundle imagewithBundleName:@"lb_freespin_spins"];
        [self.freeTimesPopview addSubview:spinsImgV];
        
    }
    self.popBgView.backgroundColor = RGB_COLOR(@"#000000", 0.5);
    self.freeTimesImgV.image = [ImageBundle imagewithBundleName: [NSString stringWithFormat:@"lb_freespin_%ld",self.freeTimes]];
    
    [UIView animateWithDuration:0.7 animations:^{
        self.freeTimesPopview.y = 40;
        self.popBgView.hidden = NO;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.freeTimesPopview.y = 320;
                [self.contentView layoutIfNeeded];
            }completion:^(BOOL finished) {
                self.popBgView.hidden = YES;
                self.freeTimesPopview.y = -190;
            }];
        });
    }];
}

-(NSMutableAttributedString *)numwithStr:(NSString *)winNumStr imageStr:(NSString *)imgName{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < winNumStr.length; i++) {
        char c = [winNumStr characterAtIndex:i];
        [arr addObject:[NSString stringWithFormat:@"%c", c]];
    }
    NSMutableAttributedString *  noteStr = [[NSMutableAttributedString alloc]initWithString:@""];
    for (NSInteger i = (arr.count-1); i >=0; i--) {
        NSTextAttachment *numAttchment = [[NSTextAttachment alloc]init];
        if ([imgName isEqualToString:@"lb_freewin_"]) {
            numAttchment.bounds = CGRectMake(0, -2, 16, 22);
        }else{
            numAttchment.bounds = CGRectMake(0, -2, 13, 26);
        }
        numAttchment.image =[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"%@%@",imgName,arr[i]]];
        NSAttributedString *numString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(numAttchment)];
        [noteStr insertAttributedString:numString atIndex:0];
    }
    return noteStr;
}


-(NSMutableAttributedString *)getFreeTimesStr:(NSString *)freeNumStr{
    NSMutableAttributedString *  noteStr = [[NSMutableAttributedString alloc]initWithString:@""];
    NSTextAttachment *numAttchment = [[NSTextAttachment alloc]init];
    numAttchment.bounds = CGRectMake(0, -2, 14, 22);
    numAttchment.image =[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lb_freespin_%@",freeNumStr]];
    NSAttributedString *numString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(numAttchment)];
    [noteStr insertAttributedString:numString atIndex:0];
    
    NSTextAttachment *freeAttchment = [[NSTextAttachment alloc]init];
    freeAttchment.bounds = CGRectMake(0, -2, 45, 22);
    freeAttchment.image =[ImageBundle imagewithBundleName:@"lb_freespin_free"];
    NSAttributedString *freeString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(freeAttchment)];
    [noteStr insertAttributedString:freeString atIndex:0];
    return noteStr;
}

-(void)invaliTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

-(void)dealloc{
    if (self.timer) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

#pragma mark ============摇摆=============
#define RADIANS(degrees) (((degrees) * M_PI) / 180.0)
//- (void)startWobble {
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    transform = CGAffineTransformRotate(transform, RADIANS(-10));
//    _gameBTN.transform = transform;
//    WeakSelf
//    [UIView animateWithDuration:0.25
//                          delay:0.0
//                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
//                     animations:^ {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        strongSelf.gameBTN.transform = CGAffineTransformMakeRotation(RADIANS(10));
//    }
//                     completion:^(BOOL finished) {
//        //                         if(finished){
//        //                             NSLog(@"Wobble finished");
//        //                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //                                 [__weakSelf startWobble];
//        //                             });
//        //                         }
//    }
//     ];
//}
//
//- (void)stopWobble {
//    WeakSelf
//    [UIView animateWithDuration:0.0
//                          delay:0.0
//                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
//                     animations:^ {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        strongSelf.gameBTN.transform = CGAffineTransformIdentity;
//    }
//                     completion:NULL
//     ];
//}


- (void)initCollection {
    
    UICollectionViewFlowLayout *betlayout = [[UICollectionViewFlowLayout alloc] init];
    betlayout.minimumLineSpacing = 0;
    betlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    betlayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    betlayout.itemSize =  CGSizeMake(_window_width,32);
    self.betHistoryList.collectionViewLayout = betlayout;
    
    UINib *betnib=[UINib nibWithNibName:kLiveBetListYFKSCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.betHistoryList registerNib: betnib forCellWithReuseIdentifier:kLiveBetListYFKSCell];
    self.betHistoryList.backgroundColor= RGB_COLOR(@"#000000", 0.6);
    self.betHistoryList.delegate = self;
    self.betHistoryList.dataSource = self;
    self.betHistoryList.allowsMultipleSelection = YES;
    
    //    self.betHistoryList.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
    //       STRONGSELF
    //        if (strongSelf == nil) {
    //            return;
    //        }
    //        strongSelf->betPage = 0;
    //        [strongSelf getBetInfo];
    //
    //    }];
    //    self.betHistoryList.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    //        STRONGSELF
    //        if (strongSelf == nil) {
    //            return;
    //        }
    //        strongSelf->betPage ++;
    //        [strongSelf getBetInfo];
    //    }];
    
    [self.betHistoryList reloadData];
    
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.listModel.count;
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LiveBetListYFKSCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLiveBetListYFKSCell forIndexPath:indexPath];
    cell.model = self.listModel[indexPath.row];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    
    return CGSizeMake(_window_width, 32);
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(_window_width, 32);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


// 工具栏点击事件
-(void)titleBtnClick:(UIButton *)btn{
    
    
    if(btn.tag == 1001){
        [self musicSwitch:btn];
        return;
    }
    
    
    if (btn.tag == 1000){
        //  玩法说明
        popWebH5 *VC = [[popWebH5 alloc]init];
        VC.titles = YZMsg(@"LobbyLotteryVC_betExplain");
        //            VC.hightRate = 0.5;
        VC.isBetExplain = YES;
        
        NSString *url = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"index.php?g=Appapi&m=LotteryArticle&a=index&lotteryType=%@&uid=%@&token=%@",minnum(curLotteryType), [Config getOwnID],[Config getOwnToken]];
        url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
        VC.urls = url;
        WeakSelf
        UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [VC doCloseWeb];
            strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-heightView-ShowDiff-[strongSelf LobbyWindowHeight], SCREEN_WIDTH, heightView+ShowDiff+[strongSelf LobbyWindowHeight]);
        }];
        __weak popWebH5 *weakVC = VC;
        VC.closeCallback = ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [shadowView removeFromSuperview];
            [weakVC.view removeFromSuperview];
            [weakVC removeFromParentViewController];
            strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-heightView-ShowDiff-[strongSelf LobbyWindowHeight], SCREEN_WIDTH, heightView+ShowDiff+[strongSelf LobbyWindowHeight]);
        };
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.view addSubview:VC.view];
        [self addChildViewController:VC];
        
    }else if (btn.tag == 1002){
        //  投注历史
        [self doShowBetHistory];
    }else if (btn.tag == 1003){
        //  礼物
        //            [self exitView];
        if (self.lotteryDelegate!= nil) {
            [self.lotteryDelegate doLiwu];
        }
    }else if (btn.tag == 1004){
        //  游戏切换
        [self.lotteryDelegate cancelLuwu];
        [self exitView];
        if (self.lotteryDelegate!= nil) {
            [self.lotteryDelegate doGame];
        }
    }else if (btn.tag == 1005){
        //  红包
        if (self.lotteryDelegate!= nil) {
            [self.lotteryDelegate showRedView];
        }
    }
    //    }
    
    
}

-(void)rebackScrollView{
    if (self.lotteryDelegate!= nil && isShowTopList) {
        isShowTopList = NO;
        [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
        [self.lotteryDelegate refreshTableHeight:NO];
    }
    self.toolScrollView.contentSize = CGSizeMake(35*self.toolBtnArr.count + 10, 0);
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 0; i< self.toolBtnArr.count; i ++) {
            UIButton *livechatBtn = self.toolBtnArr[i];
            livechatBtn.frame = CGRectMake(5+i*(30+5),5,30,30);
        }
        self.topHeight.constant = 0;
        [self updateViewFrame];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.betHistoryList.hidden = YES;
        self.betHistoryList.hidden = YES;
    }];
}

-(float)LobbyWindowHeight{
    if(isShowTopList){
        return 100;
    }else{
        return 0;
    }
}
-(void)updateViewFrame{
    self.view.frame = CGRectMake(0, SCREEN_HEIGHT-heightView-ShowDiff-[self LobbyWindowHeight], SCREEN_WIDTH, heightView+ShowDiff+[self LobbyWindowHeight]);
}
@end
