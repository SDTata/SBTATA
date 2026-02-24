//
//  LotteryBetViewController.m
//
//

#import "LotteryCenterBetViewController_ZP.h"
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
#import "ChipsModel.h"
#import "LotteryBetSubView1.h"
#import "NSString+Extention.h"
#import "BetViewInfoModel.h"
#import "socketLivePlay.h"
#import "LotteryAwardVController.h"
#import "SwitchLotteryViewController.h"
#import "ChartView.h"
#import "LotteryCenterMsgView.h"
#import "VIMediaCache.h"

#import "LotteryNNModel.h"
#import "BetListModel.h"
#import "LiveBetListYFKSCell.h"
#import "LotteryOpenViewCell_ZP.h"



#define kChipChoiseCell @"ChipChoiseCell"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"

#define perSection    M_PI*2/37


@interface LotteryCenterBetViewController_ZP ()<CAAnimationDelegate,socketDelegate>{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    lastResultModel * lastOpenResult;
    
    BOOL isShow;

    NSDictionary *allData;
    NSMutableArray *ways;   // 投注选项
    
    BOOL bUICreated; // UI是否创建
    BOOL isExit;
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSString *curIssue; // 当前期号
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *last_open_result;
    
    
    //自定义筹码
    WMZDialog *myAlert;//Dialog
    UITextField *alertTextField;
    
    NSInteger openPage;
    NSInteger betPage;
    NSInteger _currentState;
    NSTimeInterval _currentStartTime;
    NSTimeInterval _currentEndTime;
    BOOL _netFlag; //网络锁

    AVAudioPlayer *voiceAwardMoney;
  
    BOOL isFinance;
    BOOL isOpenning;
    NSMutableDictionary *contiDic;
    NSString *issueContinueBet;
    BOOL isContinueBet;
    
    
    int numberOfChips1;
    int numberOfChips2;
    int numberOfChips3;
    int numberOfChips4;
    int numberOfChips5;
    int numberOfChips6;
    int numberOfChips7;
    int numberOfChips8;
    int numberOfChips9;
    int numberOfChips10;
    int numberOfChips11;
    int numberOfChips12;
    int numberOfChips13;
    int numberOfChips14;
    int numberOfChips15;
    int numberOfChips16;
    int numberOfChips17;
    int numberOfChips18;
    int numberOfChips19;
    int numberOfChips20;
    int numberOfChips21;
    int numberOfChips22;
    int numberOfChips23;
    int numberOfChips24;
    int numberOfChips25;
    int numberOfChips26;
    int numberOfChips27;
    int numberOfChips28;
    int numberOfChips29;
    int numberOfChips30;
    int numberOfChips31;
    int numberOfChips32;
    int numberOfChips33;
    int numberOfChips34;
    int numberOfChips35;
    int numberOfChips36;
    int numberOfChips37;
    int numberOfChips38;
    int numberOfChips39;
    int numberOfChips40;
    int numberOfChips41;
    int numberOfChips42;
    int numberOfChips43;
    int numberOfChips44;
    
    NSMutableArray<ChipsModel*> *chipsArraysAll;
    ChipsModel *selectedChipModel;
    NSArray <NSDictionary *> *_titleSts;
    
    socketMovieplay *socketDelegate;//socket监听
    // 彩票定时器
    NSTimer *lotteryTime;
    NSInteger standTickCount;
    NSInteger openedTickCount;

    // 彩票信息
    NSMutableDictionary *lotteryInfo;
    LotteryAwardVController *lotteryAwardVC;
    BOOL showAwardVC;
    ChartView *chartSubV;
    BOOL closeAnimationShaigu;
    BOOL isStop; //停止闪烁
    NSMutableArray * messageList;
    
    BOOL isShowTopList; //走势图等顶部视图是否显示
}
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@property(nonatomic,strong)NSMutableArray *allOpenResultData;

@property (nonatomic, strong) VIResourceLoaderManager *resourceLoaderManager;
@property (nonatomic, strong) BetViewInfoModel *betViewModel;
@property(nonatomic,strong)SocketIOClient *ChatSocket;
@property (nonatomic, strong)NSMutableArray * lotteryShowArr;
@property (nonatomic, strong)LotteryCenterMsgView * msgView;

@property(nonatomic,strong)AVPlayer *avplayer;

@property(nonatomic,strong) CustomScrollView * toolScrollView;
@property(nonatomic,strong)UIButton * selectedToolBtn;
@property(nonatomic,strong)NSMutableArray * toolBtnArr;

@end

@implementation LotteryCenterBetViewController_ZP

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSArray *las = self.navigationController.viewControllers;
    if (las==nil) {
        [self releaseView];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (!isShow) {
        isShow = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpen:) name:@"LotteryOpenAward" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(betNotification:) name:KBetDoNotificationMsg object:nil];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLotteryInfo:) name:@"lotteryInfoNotify" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWinInfo:) name:KBetWinNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildData) name:@"errorDisConnect" object:nil];
        [self buildData];
    }
}
-(void)updateGameResult
{
    if (isFinance) {
        [self buildData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.lotteryShowArr = [NSMutableArray array];
    chartSubV = [ChartView instanceChatViewWithType:30];
    [self.chartView addSubview:chartSubV];
    chartSubV.width = SCREEN_WIDTH;
    NSArray<UIView*> *betViews = @[self.bet_bg1_view,self.bet_bg2_view,self.bet_bg3_view,self.bet_bg4_view,self.bet_bg5_view,self.bet_bg6_view,self.bet_bg7_view,self.bet_bg8_view,self.bet_bg9_view,self.bet_bg10_view,self.bet_bg11_view,self.bet_bg12_view,self.bet_bg13_view,self.bet_bg14_view,self.bet_bg15_view,self.bet_bg16_view,self.bet_bg17_view,self.bet_bg18_view,self.bet_bg19_view,self.bet_bg20_view,self.bet_bg21_view,self.bet_bg22_view,self.bet_bg23_view,self.bet_bg24_view,self.bet_bg25_view,self.bet_bg26_view,self.bet_bg27_view,self.bet_bg28_view,self.bet_bg29_view,self.bet_bg30_view,self.bet_bg31_view,self.bet_bg32_view,self.bet_bg33_view,self.bet_bg34_view,self.bet_bg35_view,self.bet_bg36_view,self.bet_bg37_view,self.bet_bg38_view,self.bet_bg39_view,self.bet_bg40_view,self.bet_bg41_view,self.bet_bg42_view,self.bet_bg43_view,self.bet_bg44_view];

    for (int i = 0; i<betViews.count; i++) {
        betViews[i].tag = i+810;
        UITapGestureRecognizer *tapBet = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(betAction:)];
        [betViews[i] addGestureRecognizer:tapBet];
    }

    begainAnimationShaigu = false;
    closeAnimationShaigu = false;

    if (@available(iOS 11.0, *)) {
        self.openResultCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.openResultCollection.contentInset = UIEdgeInsetsMake(0, -7, 0, 0);
   
    [self.betHistoryButton setTitle:YZMsg(@"LobbyLotteryVC_BetRecord") forState:UIControlStateNormal];

    // 菊花
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // testActivityIndicator.center = self.view.center;
    [self.contentView addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor whiteColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    [testActivityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];

    chipsArraysAll = [[ChipsListModel sharedInstance] chipListArrays];
    selectedChipModel = chipsArraysAll[0];

    contiDic = [NSMutableDictionary dictionary];
    messageList = [NSMutableArray array];
    _titleSts = [NSArray <NSDictionary *> array];
    self.continueBtn.enabled = false;
  
    [self.betChipCollectionView reloadData];
    //创建手势 使用initWithTarget:action:的方法创建
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doShowHistory)];

    //别忘了添加到testView上
    [self.openResutLab addGestureRecognizer:tap];
    
    standTickCount= 0;

    //彩票计时器
    if (lotteryTime) {
        [lotteryTime invalidate];
        lotteryTime = nil;
    }
    if (!lotteryTime) {
        lotteryTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(lotteryInterval) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:lotteryTime forMode:NSRunLoopCommonModes];
    }
    lotteryInfo = [NSMutableDictionary dictionary];
    
    self.chartView.hidden = NO;
    self.betHistoryList.hidden = YES;
    self.openResultList.hidden = YES;
    
    NSDate *now = [NSDate date];
    NSDate *zero = [self getZeroTimeWithDate:now];
    NSDate *end = [self getEndTimeWithDate:now];
    _currentStartTime = [zero timeIntervalSince1970];
    _currentEndTime = [end timeIntervalSince1970];
    _currentState = -1;
    self.noLab.text = YZMsg(@"LiveGame_NoBetList");
    
    openPage = 0;
    betPage = 1;
    _netFlag = YES;
    isShowTopList = YES;
    [self createToolScorllview];
    [self getOpenResultInfo];
}

- (void)lotteryInterval{
    if(!lotteryInfo) return;
    for (NSString * lotteryType in lotteryInfo.allKeys) {
        if ([lotteryType integerValue] == curLotteryType) {
            NSMutableDictionary *dict = lotteryInfo[lotteryType];
            //NSInteger time = [dict[@"time"] integerValue];
            NSDate * nowDate = [NSDate date];
            NSInteger timeDistance = [lotteryInfo[lotteryType][@"openTime"] timeIntervalSinceDate:nowDate];
            
            dict[@"time"] = [NSString stringWithFormat:@"%ld", timeDistance];
            BOOL bCurLottery = lotteryType == [NSString stringWithFormat:@"%ld",curLotteryType];
            if (timeDistance >[dict[@"sealingTim"] integerValue]) {
                if(bCurLottery){
                    standTickCount = 0;
                }else{
                    NSInteger openedLotteryType = labs([GameToolClass getCurOpenedLotteryType]);
                    if([lotteryType integerValue] == openedLotteryType && openedLotteryType > 0 && (openedLotteryType != curLotteryType)){
                        openedTickCount = 0;
                    }
                }
            }else {
                if(timeDistance > 0){
                }else if([dict[@"stopOrSell"] integerValue] == 2){

                }else{
                    if(bCurLottery){
                      
                        if(standTickCount == 2 || (standTickCount > 0 && standTickCount % 6 == 0)){
                            // 一直没等来开奖消息 递增等待时间主动拉取
                            // NSLog(@"standTickCount=[%ld] 请求同步彩票2-1", standTickCount);
                            if (socketDelegate) {
                                [socketDelegate sendSyncLotteryCMD:lotteryType];
                            }
//                            [self buildData];
                            //[socketDelegate sendSyncOpenAwardCMD:lotteryType];
                        }
                        standTickCount ++;
                    }else{
                        NSInteger openedLotteryType = labs([GameToolClass getCurOpenedLotteryType]);
                        if([lotteryType integerValue] == openedLotteryType && openedLotteryType > 0 && (openedLotteryType != curLotteryType)){
                            if(openedTickCount == 2 || (openedTickCount > 0 && openedTickCount % 6 == 0)){
                                // 一直没等来开奖消息 递增等待时间主动拉取
                                // NSLog(@"standTickCount=[%ld] 请求同步彩票2-2", standTickCount);
                                if (socketDelegate) {
                                    [socketDelegate sendSyncLotteryCMD:[NSString stringWithFormat:@"%ld", openedLotteryType]];
                                    [socketDelegate sendSyncOpenAwardCMD:[NSString stringWithFormat:@"%ld", openedLotteryType]];
                                }
//                                [self buildData];
                                
                            }
                            openedTickCount ++;
                        }
                    }
                }
            }
            NSDictionary * dic = @{
                @"betLeftTime":dict[@"time"],
                @"sealingTime":dict[@"sealingTim"],
                @"issue":dict[@"issue"],
                @"lotteryType":lotteryType,
            };
            [self refreshTime:dic];
            
        }
    }
}
// 从nodejs来的LotterySync数据
-(void)refreshLotteryInfo:(NSNotification *)notification{
    NSDictionary * msg = notification.userInfo;
    NSString *lotteryType = msg[@"lotteryType"];
    if(curLotteryType>0 && ![lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        return;
    }
    if(!lotteryInfo){
        lotteryInfo = [NSMutableDictionary dictionary];
    }
    if(!lotteryInfo[lotteryType]){
        lotteryInfo[lotteryType] = [NSMutableDictionary dictionary];
    }
    for (NSString * key1 in [msg[@"lotteryInfo"] mj_keyValues].allKeys) {
        lotteryInfo[lotteryType][key1] = msg[@"lotteryInfo"][key1];
        if([minstr(key1) isEqualToString:@"time"]){
            lotteryInfo[lotteryType][@"openTime"] = [NSDate dateWithTimeInterval:[lotteryInfo[lotteryType][key1] integerValue] sinceDate:[NSDate date]];
        }
        // NSLog(@"同步:[%@]%@->%@",lotteryType,key1,msg[@"lotteryInfo"][key1]);
    }
}

//用户中奖通知
-(void)userWinInfo:(NSNotification *)notification
{
    NSDictionary * notifiDic = notification.userInfo;
    LotteryBarrage  *msg = (LotteryBarrage*)[notifiDic objectForKey:@"model"];
    NSArray *barrage_arr = msg.msg.barrageArrArray;
    if (barrage_arr && barrage_arr.count >0) {
        for (LotteryBarrage_Barrage *subDic in barrage_arr) {
            NSString *ctStr  = [NSString stringWithFormat:YZMsg(@"LotteryCenterBarrageView_name%@_type%@_money%@%@"),subDic.ct.nickname,subDic.ct.lotteryName,[NSString stringWithFormat:@"%.2f",[subDic.ct.totalmoney doubleValue]],[common name_coin]];
            NSString * titleColor = @"lotteryProfit";
            NSString *ct = ctStr;
            NSString *uname = YZMsg(@"");
            NSString *ID = @"";
            NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:
                                  uname,@"userName",
                                  ct,@"contentChat",
                                  ID,@"id",
                                  titleColor,@"titleColor",
                                  nil];

            @synchronized (self) {
                if (messageList.count>100) {
                    [messageList removeObjectsInRange:NSMakeRange(0,1)];
                }
                if(messageList.count<1){
                    [messageList addObject:chat];
                    [self dealWithMsgArr];
                }else{
                    [messageList addObject:chat];
                }
            }
        }
    }
}

-(void)dealWithMsgArr{
    if (messageList.count == 0 || !messageList) {
        return;
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSDictionary *dicSub = strongSelf->messageList[0];
        if (dicSub!= nil && [dicSub isKindOfClass:[NSDictionary class]] && [[dicSub objectForKey:@"contentChat"] isKindOfClass:[NSString class]]) {
            chatCenterModel *model = [chatCenterModel modelWithDic:dicSub];
            [model setChatFrame];
            [self.msgView addMsgList:model];
        }
        
        [strongSelf->messageList removeObjectAtIndex:0];
        if (strongSelf->messageList.count) {
            [strongSelf dealWithMsgArr];
        }
    });
}

-(void)setLotteryAward:(LotteryAward *)msg
{
    float timeDelay = 2;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.lotteryShowArr addObject:msg];
        if (!strongSelf->showAwardVC) {
            [strongSelf showNextLotteryAward];
        }
    });
    
   
}

// 队列展示中奖消息
-(void)showNextLotteryAward{
    if (self.lotteryShowArr.count == 0 || self.lotteryShowArr == nil) {//判断队列中有item且不是满屏
        return;
    }
    LotteryAward *msg = [self.lotteryShowArr firstObject];
    [self.lotteryShowArr removeObjectAtIndex:0];
    [self setShowLotteryAward:msg];
}


-(void)setShowLotteryAward:(LotteryAward *)msg{
    WeakSelf
    dispatch_main_async_safe(^{
        STRONGSELF
        //        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->showAwardVC) {
            return;
        }
        NSString *award_money = min2float(msg.msg.awardMoney);
        LotteryBarrageModel *model = [[LotteryBarrageModel alloc]init];
        model.content = award_money;
        model.showImgName = @"";
        model.liveuid = @"";
        model.isCurrentUser = true;
        model.lotteryType = @"";
        
        strongSelf->lotteryAwardVC = [[LotteryAwardVController alloc]initWithNibName:@"LotteryAwardVController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        strongSelf->lotteryAwardVC.model = model;
        strongSelf->lotteryAwardVC.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [strongSelf addChildViewController:strongSelf->lotteryAwardVC];
        [strongSelf.view addSubview:strongSelf->lotteryAwardVC.view];
        strongSelf->showAwardVC = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf->showAwardVC = false;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf showNextLotteryAward];
            });
        });
    });
    
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
//    [GameToolClass setCurOpenedLotteryType:lotteryType];
}
//获取彩种信息
- (void)buildData {
    NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getHomeBetViewInfo"];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES  andParameter:curLotteryType==10?@{@"lottery_type":[NSString stringWithFormat:@"%ld", curLotteryType],@"support_nn":@(1)}:@{@"lottery_type":[NSString stringWithFormat:@"%ld", curLotteryType]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->isExit) {
            return;
        }
        if(code == 0)
        {
            if (strongSelf->allData) {
                [strongSelf closeShaiguBoxAnimation];
            }
            strongSelf->allData = [info firstObject];
            strongSelf.titleLabel.text = strongSelf->allData[@"name"];
            [strongSelf addNodeServer:minstr(strongSelf->allData[@"lobbyServer"])];
            NSDictionary *dict = strongSelf->allData[@"lastResult"];
            strongSelf->curIssue = strongSelf->allData[@"issue"];
            strongSelf->betLeftTime = [strongSelf->allData[@"time"] integerValue];
            strongSelf->sealingTime = [strongSelf->allData[@"sealingTim"] integerValue];
            NSString *musicUrl = strongSelf->allData[@"music"];
            if (musicUrl!= nil && musicUrl.length>1) {
                [strongSelf playerBgMusic:musicUrl];
            }
            if(dict){
                strongSelf.openResutLab.hidden = NO;
                strongSelf->last_open_result = dict[@"open_result"];
                strongSelf.openResutLab.text = minstr(dict[@"open_result"]);
                [strongSelf resultColor:dict[@"open_result"]];
                [strongSelf animationWithBegainSelectonIndex:[strongSelf resultPosition:dict[@"open_result"]]];
            }else{
                strongSelf->last_open_result = @"";
                strongSelf.openResutLab.hidden = YES;
            }

            strongSelf->ways = strongSelf->allData[@"ways"];

            if([strongSelf->allData[@"issue"] integerValue] == 0 || [strongSelf->allData[@"stopOrSell"] integerValue] == 2){
                [MBProgressHUD showError:strongSelf->allData[@"stopMsg"]];
                [strongSelf exitView];
                return;
            }

            LiveUser *user = [Config myProfile];
            user.coin = minstr([strongSelf->allData valueForKey:@"left_coin"]);
            [Config updateProfile:user];

            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
            });
        }
        else{
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
        
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf exitView];
        return;
    }];
}
-(void)playerBgMusic:(NSString*)musicUrl{
    if (self.avplayer==nil) {
        NSURL *originUrl = nil;
        if (musicUrl!= nil && musicUrl.length>4) {
            originUrl = [NSURL URLWithString:musicUrl];
//            VIResourceLoaderManager *resourceLoaderManager = [VIResourceLoaderManager new];
//            self.resourceLoaderManager = resourceLoaderManager;
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:originUrl];
            VICacheConfiguration *configuration = [VICacheManager cacheConfigurationForURL:originUrl];
            if (configuration.progress >= 1.0) {
                NSLog(@"cache completed");
            }
            self.avplayer = [AVPlayer playerWithPlayerItem:playerItem];
            self.avplayer.automaticallyWaitsToMinimizeStalling = NO;
            [self.avplayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avplayer.currentItem];
            if ([common soundControlValue] != 0) {
                [self.avplayer pause];
            }else{
                [self.avplayer play];
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCacheDidChanged:) name:VICacheManagerDidUpdateCacheNotification object:nil];
        }
        
    }
   
}
#pragma mark - notification

- (void)mediaCacheDidChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    VICacheConfiguration *configuration = userInfo[VICacheConfigurationKey];
    NSArray<NSValue *> *cachedFragments = configuration.cacheFragments;
    long long contentLength = configuration.contentInfo.contentLength;
    
    NSInteger number = 100;
    NSMutableString *progressStr = [NSMutableString string];
    
    WeakSelf
    [cachedFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONGSELF
        if(strongSelf == nil){
            return;
        }
        NSRange range = obj.rangeValue;
        
        NSInteger location = roundf((range.location / (double)contentLength) * number);
        
        NSInteger progressCount = progressStr.length;
        [strongSelf string:progressStr appendString:@"0" muti:location - progressCount];
        
        NSInteger length = roundf((range.length / (double)contentLength) * number);
        [strongSelf string:progressStr appendString:@"1" muti:length];
        
        
        if (idx == cachedFragments.count - 1 && (location + length) <= number + 1) {
            [strongSelf string:progressStr appendString:@"0" muti:number - (length + location)];
        }
    }];
    
    NSLog(@"-------%@", progressStr);
}

- (void)string:(NSMutableString *)string appendString:(NSString *)appendString muti:(NSInteger)muti {
    for (NSInteger i = 0; i < muti; i++) {
        [string appendString:appendString];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }
}
- (void)playbackFinished:(NSNotification *)notification {
    if (self.avplayer) {
        [self.avplayer seekToTime:kCMTimeZero];
        [self.avplayer play];
    }
    
}


-(void)addNodeServer:(NSString *)serverUrl{
    if (serverUrl.length) {
        hotModel * model = [[hotModel alloc] init];
        model.zhuboID = @"0";
        model.stream = @"";
        model.centerUrl = serverUrl;
        socketDelegate = [[socketMovieplay alloc]init];
        socketDelegate.socketDelegate = self;
        [socketDelegate addNodeListen:model isFirstConnect:YES  serverUrl:serverUrl];
    }
}

//刷新UI
-(void)refreshUI{
    if(!ways){
        ways = [NSMutableArray array];
    }
    // 更新倒计时时间
    [self refreshTimeUI];
    if(!bUICreated){
        [self initUI];
    }
    self.openResultCollection.hidden = YES;
    // 更新余额
    [self refreshLeftCoinLabel];
}
#pragma mark---Notification通知----
//时间刷新通知
- (void)refreshTime:(NSDictionary *)dict {
    if(!bUICreated){
        return;
    }
    NSString * lotteryType = minstr(dict[@"lotteryType"]);
    if(curLotteryType>0 && [lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        betLeftTime = [dict[@"betLeftTime"] integerValue];
        sealingTime = [dict[@"sealingTime"] integerValue];
        curIssue = minstr(dict[@"issue"]);
        [self refreshTimeUI];
    }
}

///开奖
- (void)refreshLastOpen:(NSNotification *)notification {
    if(!bUICreated || isOpenning == true){
        return;
    }
    NSString * result = notification.userInfo[@"result"];
    NSString * lotteryType = minstr(notification.userInfo[@"lotteryType"]);
    if(curLotteryType>0 && [lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        if (socketDelegate) {
            [socketDelegate sendSyncLotteryCMD:[NSString stringWithFormat:@"%ld",curLotteryType]];
        }
        self.continueBtn.enabled = false;
        UIView *willReadyView = [self.contentView viewWithTag:2200];
        if (willReadyView) {
            [willReadyView removeFromSuperview];
        }
        UIView *ResultShowView = [self.contentView viewWithTag:2500];
        if (ResultShowView) {
            [ResultShowView removeFromSuperview];
        }

        isFinance = YES;
        isOpenning = YES;
        isStop = YES;
        last_open_result = result;
       
//        [self.openResultCollection reloadData];
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.openResutLab.text = minstr(result);
            strongSelf.openResutLab.hidden = NO;
            [strongSelf resultColor:result];
            if (strongSelf->chartSubV) {
                [strongSelf->chartSubV updateChartData:result];
            }
        });
        NSArray *winways = notification.userInfo[@"winWays"];
        //关闭骰子动画显示结果
        [self closeAnimationAndShowResult:result winways:winways];
        [self animationWithSelectonIndex:[self resultPosition:result]];

        //桌子点亮及砝码动效
        [self performSelector:@selector(tableAndChipsChangedWithWinways:) withObject:winways afterDelay:2];
        ///
        [self closeAndReadyToBegain];
        [self clearChipsNumber];

    }
}
-(void)clearChipsNumber{
    numberOfChips1 = 0;
    numberOfChips2 = 0;
    numberOfChips3 = 0;
    numberOfChips4 = 0;
    numberOfChips5 = 0;
    numberOfChips6 = 0;
    numberOfChips7 = 0;
    numberOfChips8 = 0;
    numberOfChips9 = 0;
    numberOfChips10 = 0;
    numberOfChips11 = 0;
    numberOfChips12 = 0;
    numberOfChips13 = 0;
    numberOfChips14 = 0;
    numberOfChips15 = 0;
    numberOfChips16 = 0;
    numberOfChips17 = 0;
    numberOfChips18 = 0;
    numberOfChips19 = 0;
    numberOfChips20 = 0;
    numberOfChips21 = 0;
    numberOfChips22 = 0;
    numberOfChips23 = 0;
    numberOfChips24 = 0;
    numberOfChips25 = 0;
    numberOfChips26 = 0;
    numberOfChips27 = 0;
    numberOfChips28 = 0;
    numberOfChips29 = 0;
    numberOfChips30 = 0;
    numberOfChips31 = 0;
    numberOfChips32 = 0;
    numberOfChips33 = 0;
    numberOfChips34 = 0;
    numberOfChips35 = 0;
    numberOfChips36 = 0;
    numberOfChips37 = 0;
    numberOfChips38 = 0;
    numberOfChips39 = 0;
    numberOfChips40 = 0;
    numberOfChips41 = 0;
    numberOfChips42 = 0;
    numberOfChips43 = 0;
    numberOfChips44 = 0;
}
- (void)tableAndChipsChangedWithWinways:(NSArray *)winways{
    ///下面是桌面赢方背景改变
    NSMutableArray *winViews = [NSMutableArray array];
    NSMutableArray *winChipsTags = [NSMutableArray array];
    for (NSString *winName in winways) {
        UIImageView *imgV;
        if ([winName isEqualToString:@"点数_大"]) {
            imgV = [self.bet_bg1_view viewWithTag:300];
            [winChipsTags addObject:@"20000"];
            [winViews addObject:self.bet_bg1_view];
        }else if ([winName isEqualToString:@"点数_小"]){
            imgV = [self.bet_bg2_view viewWithTag:300];
            [winViews addObject:self.bet_bg2_view];
            [winChipsTags addObject:@"20001"];
        }else if ([winName isEqualToString:@"颜色_红色"]){
            imgV = [self.bet_bg3_view viewWithTag:300];
            [winViews addObject:self.bet_bg3_view];
            [winChipsTags addObject:@"20002"];
        }else if ([winName isEqualToString:@"颜色_黑色"]){
            imgV = [self.bet_bg4_view viewWithTag:300];
            [winViews addObject:self.bet_bg4_view];
            [winChipsTags addObject:@"20003"];
        }else if ([winName isEqualToString:@"点数_1-12"]){
            imgV = [self.bet_bg5_view viewWithTag:300];
            [winViews addObject:self.bet_bg5_view];
            [winChipsTags addObject:@"20004"];
        }else if ([winName isEqualToString:@"点数_13-24"]){
            imgV = [self.bet_bg6_view viewWithTag:300];
            [winViews addObject:self.bet_bg6_view];
            [winChipsTags addObject:@"20005"];
        }else if ([winName isEqualToString:@"点数_25-36"]){
            imgV = [self.bet_bg7_view viewWithTag:300];
            [winViews addObject:self.bet_bg7_view];
            [winChipsTags addObject:@"20006"];
        }else if ([winName isEqualToString:@"点数_0"]){
            imgV = [self.bet_bg8_view viewWithTag:300];
            [winViews addObject:self.bet_bg8_view];
            [winChipsTags addObject:@"20007"];
        }
        if ([winName isEqualToString:@"点数_1"]) {
            imgV = [self.bet_bg9_view viewWithTag:300];
            [winChipsTags addObject:@"20008"];
            [winViews addObject:self.bet_bg9_view];
        }else if ([winName isEqualToString:@"点数_2"]){
            imgV = [self.bet_bg10_view viewWithTag:300];
            [winViews addObject:self.bet_bg10_view];
            [winChipsTags addObject:@"20009"];
        }else if ([winName isEqualToString:@"点数_3"]){
            imgV = [self.bet_bg11_view viewWithTag:300];
            [winViews addObject:self.bet_bg11_view];
            [winChipsTags addObject:@"20010"];
        }else if ([winName isEqualToString:@"点数_4"]){
            imgV = [self.bet_bg12_view viewWithTag:300];
            [winViews addObject:self.bet_bg12_view];
            [winChipsTags addObject:@"20011"];
        }else if ([winName isEqualToString:@"点数_5"]){
            imgV = [self.bet_bg13_view viewWithTag:300];
            [winViews addObject:self.bet_bg13_view];
            [winChipsTags addObject:@"20012"];
        }else if ([winName isEqualToString:@"点数_6"]){
            imgV = [self.bet_bg14_view viewWithTag:300];
            [winViews addObject:self.bet_bg14_view];
            [winChipsTags addObject:@"20013"];
        }else if ([winName isEqualToString:@"点数_7"]){
            imgV = [self.bet_bg15_view viewWithTag:300];
            [winViews addObject:self.bet_bg15_view];
            [winChipsTags addObject:@"20014"];
        }else if ([winName isEqualToString:@"点数_8"]){
            imgV = [self.bet_bg16_view viewWithTag:300];
            [winViews addObject:self.bet_bg16_view];
            [winChipsTags addObject:@"20015"];
        }else if ([winName isEqualToString:@"点数_9"]){
            imgV = [self.bet_bg17_view viewWithTag:300];
            [winViews addObject:self.bet_bg17_view];
            [winChipsTags addObject:@"20016"];
        }else if ([winName isEqualToString:@"点数_10"]){
            imgV = [self.bet_bg18_view viewWithTag:300];
            [winViews addObject:self.bet_bg18_view];
            [winChipsTags addObject:@"20017"];
        }else if ([winName isEqualToString:@"点数_11"]){
            imgV = [self.bet_bg19_view viewWithTag:300];
            [winViews addObject:self.bet_bg19_view];
            [winChipsTags addObject:@"20018"];
        }else if ([winName isEqualToString:@"点数_12"]){
            imgV = [self.bet_bg20_view viewWithTag:300];
            [winViews addObject:self.bet_bg20_view];
            [winChipsTags addObject:@"20019"];
        }else if ([winName isEqualToString:@"点数_13"]){
            imgV = [self.bet_bg21_view viewWithTag:300];
            [winViews addObject:self.bet_bg21_view];
            [winChipsTags addObject:@"20020"];
        }else if ([winName isEqualToString:@"点数_14"]){
            imgV = [self.bet_bg22_view viewWithTag:300];
            [winViews addObject:self.bet_bg22_view];
            [winChipsTags addObject:@"20021"];
        }else if ([winName isEqualToString:@"点数_15"]){
            imgV = [self.bet_bg23_view viewWithTag:300];
            [winViews addObject:self.bet_bg23_view];
            [winChipsTags addObject:@"20022"];
        }else if ([winName isEqualToString:@"点数_16"]){
            imgV = [self.bet_bg24_view viewWithTag:300];
            [winViews addObject:self.bet_bg24_view];
            [winChipsTags addObject:@"20023"];
        }else if ([winName isEqualToString:@"点数_17"]){
            imgV = [self.bet_bg25_view viewWithTag:300];
            [winViews addObject:self.bet_bg25_view];
            [winChipsTags addObject:@"20024"];
        }else if ([winName isEqualToString:@"点数_18"]){
            imgV = [self.bet_bg26_view viewWithTag:300];
            [winViews addObject:self.bet_bg26_view];
            [winChipsTags addObject:@"20025"];
        }else if ([winName isEqualToString:@"点数_19"]){
            imgV = [self.bet_bg27_view viewWithTag:300];
            [winViews addObject:self.bet_bg27_view];
            [winChipsTags addObject:@"20026"];
        }else if ([winName isEqualToString:@"点数_20"]){
            imgV = [self.bet_bg28_view viewWithTag:300];
            [winViews addObject:self.bet_bg28_view];
            [winChipsTags addObject:@"20027"];
        }else if ([winName isEqualToString:@"点数_21"]){
            imgV = [self.bet_bg29_view viewWithTag:300];
            [winViews addObject:self.bet_bg29_view];
            [winChipsTags addObject:@"20028"];
        }else if ([winName isEqualToString:@"点数_22"]){
            imgV = [self.bet_bg30_view viewWithTag:300];
            [winViews addObject:self.bet_bg30_view];
            [winChipsTags addObject:@"20029"];
        }else if ([winName isEqualToString:@"点数_23"]){
            imgV = [self.bet_bg31_view viewWithTag:300];
            [winViews addObject:self.bet_bg31_view];
            [winChipsTags addObject:@"20030"];
        }else if ([winName isEqualToString:@"点数_24"]){
            imgV = [self.bet_bg32_view viewWithTag:300];
            [winViews addObject:self.bet_bg32_view];
            [winChipsTags addObject:@"20031"];
        }else if ([winName isEqualToString:@"点数_25"]){
            imgV = [self.bet_bg33_view viewWithTag:300];
            [winViews addObject:self.bet_bg33_view];
            [winChipsTags addObject:@"20032"];
        }else if ([winName isEqualToString:@"点数_26"]){
            imgV = [self.bet_bg34_view viewWithTag:300];
            [winViews addObject:self.bet_bg34_view];
            [winChipsTags addObject:@"20033"];
        }else if ([winName isEqualToString:@"点数_27"]){
            imgV = [self.bet_bg35_view viewWithTag:300];
            [winViews addObject:self.bet_bg35_view];
            [winChipsTags addObject:@"20034"];
        }else if ([winName isEqualToString:@"点数_28"]){
            imgV = [self.bet_bg36_view viewWithTag:300];
            [winViews addObject:self.bet_bg36_view];
            [winChipsTags addObject:@"20035"];
        }else if ([winName isEqualToString:@"点数_29"]){
            imgV = [self.bet_bg37_view viewWithTag:300];
            [winViews addObject:self.bet_bg37_view];
            [winChipsTags addObject:@"20036"];
        }else if ([winName isEqualToString:@"点数_30"]){
            imgV = [self.bet_bg38_view viewWithTag:300];
            [winViews addObject:self.bet_bg38_view];
            [winChipsTags addObject:@"20037"];
        }else if ([winName isEqualToString:@"点数_31"]){
            imgV = [self.bet_bg39_view viewWithTag:300];
            [winViews addObject:self.bet_bg39_view];
            [winChipsTags addObject:@"20038"];
        }else if ([winName isEqualToString:@"点数_32"]){
            imgV = [self.bet_bg40_view viewWithTag:300];
            [winViews addObject:self.bet_bg40_view];
            [winChipsTags addObject:@"20039"];
        }else if ([winName isEqualToString:@"点数_33"]){
            imgV = [self.bet_bg41_view viewWithTag:300];
            [winViews addObject:self.bet_bg41_view];
            [winChipsTags addObject:@"20040"];
        }else if ([winName isEqualToString:@"点数_34"]){
            imgV = [self.bet_bg42_view viewWithTag:300];
            [winViews addObject:self.bet_bg42_view];
            [winChipsTags addObject:@"20041"];
        }else if ([winName isEqualToString:@"点数_35"]){
            imgV = [self.bet_bg43_view viewWithTag:300];
            [winViews addObject:self.bet_bg43_view];
            [winChipsTags addObject:@"20042"];
        }else if ([winName isEqualToString:@"点数_36"]){
            imgV = [self.bet_bg44_view viewWithTag:300];
            [winViews addObject:self.bet_bg44_view];
            [winChipsTags addObject:@"20043"];
        }
        if (imgV) {
            UIImage *imageNew = [[ImageBundle imagewithBundleName:@"win_bolder_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
            NSArray * arr = @[imgV.image,imageNew,imgV];
            [self animationDeskOld:arr];
        }
    }
    BOOL isChecked = false;
    CGPoint resultPoint = CGPointMake(self.betBgView.right+20, self.betBgView.y+self.betBgView.height);

    ///下面是飞筹码动画
    NSArray *subViews = [NSArray arrayWithArray:self.betBgView.subviews];
    NSMutableArray *chipLose = [NSMutableArray array];
    for (int i = 0; i<subViews.count; i++) {
        UIView *sub = subViews[i];
        if (sub.tag >=20000 && sub.tag<=888888) {
            if ([winChipsTags containsObject:[NSString stringWithFormat:@"%ld",(long)sub.tag]] && !isChecked) {
                resultPoint=  CGPointMake(self.betBgView.left+20, self.betBgView.y+self.betBgView.height);
                isChecked = true;
            }

            for (UIView *subV in winViews) {
                if (![subV.layer containsPoint:sub.frame.origin]) {
                    [chipLose addObject:sub];
                }else{

                }
            }
        }
    }
    ///结算动画，先收掉输方筹码
    WeakSelf
    [UIView animateWithDuration:0.8 animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        for (UIView *sub in chipLose) {
            sub.center = CGPointMake(SCREEN_WIDTH/2, strongSelf.betBgView.top-100);
        }
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf==nil||strongSelf->isExit) {
            return;
        }
        if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"shoufamaaudio.mp3"].location == NSNotFound)) {
            NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"shoufamaaudio.mp3" withExtension:Nil];
            strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
            if ([common soundControlValue] == 2) {
                [strongSelf->voiceAwardMoney setVolume:0];
            }else{
                [strongSelf->voiceAwardMoney setVolume:1];
            }
        }
        [strongSelf->voiceAwardMoney prepareToPlay];
        [strongSelf->voiceAwardMoney play];
    }];
    ///结算动画，输方筹码飞到赢方
    [UIView animateWithDuration:0.8 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if (winViews.count>1) {
            for (int i = 0;i<chipLose.count;i++) {
                UIView *sub = chipLose[i];
                sub.alpha=1;
                if (i<chipLose.count/2) {
                    CGPoint toRectPoint = [strongSelf toRandomRectPointtoView:winViews[0]];
                    sub.frame = CGRectMake(toRectPoint.x, toRectPoint.y, sub.width, sub.height);
                    sub.tag = [winChipsTags[0] integerValue];
                }else{
                    CGPoint toRectPoint = [strongSelf toRandomRectPointtoView:winViews[1]];
                    sub.frame = CGRectMake(toRectPoint.x, toRectPoint.y, sub.width, sub.height);
                    sub.tag = [winChipsTags[1] integerValue];
                }
            }
        }else{
            for (UIView *sub in chipLose) {
                CGPoint toRectPoint = [strongSelf toRandomRectPointtoView:winViews[0]];
                sub.frame = CGRectMake(toRectPoint.x, toRectPoint.y, sub.width, sub.height);
                sub.tag = [winChipsTags[0] integerValue];
            }
        }
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf==nil||strongSelf->isExit) {
            return;
        }
        if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"shoufamaaudio.mp3"].location == NSNotFound)) {
            NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"shoufamaaudio.mp3" withExtension:Nil];
            strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
            if ([common soundControlValue] == 2) {
                [strongSelf->voiceAwardMoney setVolume:0];
            }else{
                [strongSelf->voiceAwardMoney setVolume:1];
            }
        }
        [strongSelf->voiceAwardMoney prepareToPlay];
        [strongSelf->voiceAwardMoney play];

        NSLog(@"XXxxXXxxXXxxXXxxXXxxXXxxXXxxXXxxXXxxXXxxXXxxXXxx");
    }];

    ///结算动画，输方筹码飞到赢方或者玩家
    [UIView animateWithDuration:0.8 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        for (int i = 0; i<subViews.count; i++) {
            UIView *sub = subViews[i];
            if (sub.tag >=20000 && sub.tag<=888888) {
                sub.center =  resultPoint;
            }
        }
    
    }completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        for (int i = 0; i<subViews.count; i++) {
            UIView *sub = subViews[i];
            if (sub.tag >=20000 && sub.tag<=888888) {
                [sub removeAllSubviews];
                [sub removeFromSuperview];
            }
        }

    }];
}
-(void)closeAndReadyToBegain
{
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->closeAnimationShaigu = NO;
        [strongSelf closeShaiguBoxAnimation];
        NSArray<UIView*> *betViews = @[strongSelf.bet_bg1_view,strongSelf.bet_bg2_view,strongSelf.bet_bg3_view,strongSelf.bet_bg4_view,strongSelf.bet_bg5_view,strongSelf.bet_bg6_view,strongSelf.bet_bg7_view,strongSelf.bet_bg8_view,strongSelf.bet_bg9_view,strongSelf.bet_bg10_view,strongSelf.bet_bg11_view,strongSelf.bet_bg12_view,strongSelf.bet_bg13_view,strongSelf.bet_bg14_view,strongSelf.bet_bg15_view,strongSelf.bet_bg16_view,strongSelf.bet_bg17_view,strongSelf.bet_bg18_view,strongSelf.bet_bg19_view,strongSelf.bet_bg20_view,strongSelf.bet_bg21_view,strongSelf.bet_bg22_view,strongSelf.bet_bg23_view,strongSelf.bet_bg24_view,strongSelf.bet_bg25_view,strongSelf.bet_bg26_view,strongSelf.bet_bg27_view,strongSelf.bet_bg28_view,strongSelf.bet_bg29_view,strongSelf.bet_bg30_view,strongSelf.bet_bg31_view,strongSelf.bet_bg32_view,strongSelf.bet_bg33_view,strongSelf.bet_bg34_view,strongSelf.bet_bg35_view,strongSelf.bet_bg36_view,strongSelf.bet_bg37_view,strongSelf.bet_bg38_view,strongSelf.bet_bg39_view,strongSelf.bet_bg40_view,strongSelf.bet_bg41_view,strongSelf.bet_bg42_view,strongSelf.bet_bg43_view,strongSelf.bet_bg44_view];
        for (UIView *viewSub in betViews) {
            UIImageView *imgV = [viewSub viewWithTag:300];
            if ([viewSub isEqual:strongSelf.bet_bg1_view]||[viewSub isEqual:strongSelf.bet_bg2_view]||[viewSub isEqual:strongSelf.bet_bg5_view]||[viewSub isEqual:strongSelf.bet_bg6_view]||[viewSub isEqual:strongSelf.bet_bg7_view]) {
                imgV.image = [ImageBundle imagewithBundleName:@"normal_bolder_bg"];
            }else if ([viewSub isEqual:strongSelf.bet_bg8_view]){
                imgV.image = [ImageBundle imagewithBundleName:@"lp_green_bg"];
            }else if ([viewSub isEqual:strongSelf.bet_bg3_view]||[viewSub isEqual:strongSelf.bet_bg9_view]||[viewSub isEqual:strongSelf.bet_bg11_view]||[viewSub isEqual:strongSelf.bet_bg12_view]||[viewSub isEqual:strongSelf.bet_bg13_view]||[viewSub isEqual:strongSelf.bet_bg15_view]||[viewSub isEqual:strongSelf.bet_bg17_view]||[viewSub isEqual:strongSelf.bet_bg20_view]||[viewSub isEqual:strongSelf.bet_bg22_view]||[viewSub isEqual:strongSelf.bet_bg24_view]||[viewSub isEqual:strongSelf.bet_bg26_view]||[viewSub isEqual:strongSelf.bet_bg29_view]||[viewSub isEqual:strongSelf.bet_bg31_view]||[viewSub isEqual:strongSelf.bet_bg33_view]||[viewSub isEqual:strongSelf.bet_bg35_view]||[viewSub isEqual:strongSelf.bet_bg38_view]||[viewSub isEqual:strongSelf.bet_bg40_view]||[viewSub isEqual:strongSelf.bet_bg42_view]||[viewSub  isEqual:strongSelf.bet_bg44_view]){
                imgV.image = [ImageBundle imagewithBundleName:@"lp_red_bg"];
            }else if ([viewSub isEqual:strongSelf.bet_bg4_view]||[viewSub isEqual:strongSelf.bet_bg10_view]||[viewSub  isEqual:strongSelf.bet_bg14_view]||[viewSub isEqual:strongSelf.bet_bg16_view]||[viewSub isEqual:strongSelf.bet_bg18_view]||[viewSub isEqual:strongSelf.bet_bg19_view]||[viewSub isEqual:strongSelf.bet_bg21_view]||[viewSub isEqual:strongSelf.bet_bg23_view]||[viewSub isEqual:strongSelf.bet_bg25_view]||[viewSub isEqual:strongSelf.bet_bg27_view]||[viewSub isEqual:strongSelf.bet_bg28_view]||[viewSub isEqual:strongSelf.bet_bg30_view]||[viewSub isEqual:strongSelf.bet_bg32_view]||[viewSub isEqual:strongSelf.bet_bg34_view]||[viewSub isEqual:strongSelf.bet_bg36_view]||[viewSub isEqual:strongSelf.bet_bg37_view]||[viewSub isEqual:strongSelf.bet_bg39_view]||[viewSub isEqual:strongSelf.bet_bg41_view]||[viewSub isEqual:strongSelf.bet_bg43_view]){
                imgV.image = [ImageBundle imagewithBundleName:@"lp_black_bg"];
            }

        }
        strongSelf->isStop = NO;

        ///显示即将开始
        UIView *willReadyView = [[UIView alloc]initWithFrame:CGRectMake(40, 0,SCREEN_WIDTH-80, 73)];
        willReadyView.tag = 2100;
        willReadyView.layer.zPosition = 21;
        [strongSelf.contentView addSubview:willReadyView];
        willReadyView.center = CGPointMake(SCREEN_WIDTH/2, (396+ShowDiff)/2.0);

        UIImageView *imgVReadybg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-80, 73)];
        imgVReadybg.image = [ImageBundle imagewithBundleName:@"gamecenter_will_begain"];
        [willReadyView addSubview:imgVReadybg];

        UILabel *labelTip = [[UILabel alloc]initWithFrame: CGRectMake((SCREEN_WIDTH/2)-220, 10, 200, 53)];
        labelTip.textColor = RGB(248, 210, 147);
        labelTip.textAlignment = NSTextAlignmentRight;
        labelTip.text = YZMsg(@"game_will_begain");
        labelTip.font = [UIFont boldSystemFontOfSize:20];
        [willReadyView addSubview:labelTip];

        __block UIButton *buttonick = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonick.frame =  CGRectMake(labelTip.right+10, 19, 33, 37);
        [buttonick setBackgroundImage:[ImageBundle imagewithBundleName:@"gamecenter_secondimg"] forState:UIControlStateNormal];
        [buttonick setTitleColor:RGB(248, 210, 147) forState:UIControlStateNormal];
        buttonick.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [buttonick setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
        [willReadyView addSubview:buttonick];
        [buttonick setTitle:@"4" forState:UIControlStateNormal];

        __block NSInteger seconds = 4;
        dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

        dispatch_source_set_event_handler(timer, ^{
            if (strongSelf == nil) {
                dispatch_source_cancel(timer);
                return;
            }
            seconds--;
            if (seconds<=0) {
                dispatch_source_cancel(timer);
                dispatch_main_async_safe(^{
                    if (strongSelf == nil) {
                        return;
                    }
                    ///关闭即将开始
                    strongSelf->isFinance = false;
                    strongSelf->isOpenning = false;
                    if (strongSelf->contiDic.count>0) {
                        strongSelf.continueBtn.enabled = true;
                    }
                    [strongSelf canBetHidenLastBetSubView:YES isClearAll:true toView:nil];

                    [buttonick setTitle:minnum(seconds) forState:UIControlStateNormal];
                    [buttonick shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
                        UIView *viewWillReadyView = [strongSelf.contentView viewWithTag:2100];
                        if (strongSelf == nil) {
                            return;
                        }
                        if (viewWillReadyView) {
                            [willReadyView removeFromSuperview];
                        }
                    }];

                });
            }else{
                dispatch_main_async_safe(^{
                  ///即将开始
                    if (buttonick!= nil) {
                        [buttonick setTitle:minnum(seconds) forState:UIControlStateNormal];
                        [buttonick shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{

                        }];
                    }
                });
            }
        });
        dispatch_resume(timer);
    });

}
-(void)animationDeskOld:(NSArray *)arr
{
    UIImage * oldImg = arr[0];
    UIImage * img = arr[1];
    UIImageView * imgV = arr[2];
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if ([imgV.image isEqual:oldImg]) {
            imgV.image= img;
        }else{
            imgV.image= oldImg;
        }
//    } completion:^(BOOL finished) {
        if (self == nil||isExit ||isStop == false) {
            imgV.image= oldImg;
        }else{
            [self performSelector:@selector(animationDeskOld:) withObject:arr  afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
        }
//    }];
}

///玩家赢
-(void)betWintification:(NSNotification*)notification
{
    
}

///玩家下注
-(void)betNotification:(NSNotification*)notification
{
    if (isOpenning) {
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf betNotification:notification];
        });
        return;
    }
    
    NSDictionary * notifiDic = notification.userInfo;
    LotteryBet *betModel = (LotteryBet*)[notifiDic objectForKey:@"model"];
    NSString *moneyStrs = betModel.msg.money;
    NSString *waysStrs = betModel.msg.way;
    waysStrs = [waysStrs stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    waysStrs = [waysStrs stringByReplacingOccurrencesOfString:@"[" withString:@""];
    waysStrs = [waysStrs stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray * arrWays = [waysStrs componentsSeparatedByString:@","];


    moneyStrs = [moneyStrs stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    moneyStrs = [moneyStrs stringByReplacingOccurrencesOfString:@"[" withString:@""];
    moneyStrs = [moneyStrs stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray * arrMoney = [moneyStrs componentsSeparatedByString:@","];

    if (betModel.msg.issue == [curIssue longLongValue] && curLotteryType == betModel.msg.lotteryType) {
        for (int i = 0; i<arrWays.count; i++) {
            NSString *keyContinue = @"";
            NSString *subWay = arrWays[i];
            NSString *subMoney = arrMoney[i];

            if ([subWay isEqualToString:@"点数_大"]) {
                keyContinue = @"1";
                [self animationFrom:nil toView:self.bet_bg1_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20000 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_小"]){
                keyContinue = @"2";
                [self animationFrom:nil toView:self.bet_bg2_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20001 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"颜色_红色"]){
                keyContinue = @"3";
                [self animationFrom:nil toView:self.bet_bg3_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20002 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"颜色_黑色"]){
                keyContinue = @"4";
                [self animationFrom:nil toView:self.bet_bg4_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20003 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_1-12"]){
                keyContinue = @"5";
                [self animationFrom:nil toView:self.bet_bg5_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20004 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_13-24"]){
                keyContinue = @"6";
                [self animationFrom:nil toView:self.bet_bg6_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20005 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_25-36"]){
                keyContinue = @"7";
                [self animationFrom:nil toView:self.bet_bg7_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20006 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_0"]){
                keyContinue = @"8";
                [self animationFrom:nil toView:self.bet_bg8_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20007 moneyNum:subMoney] uid:betModel.msg.uid];
            }
            else if ([subWay isEqualToString:@"点数_1"]){
                keyContinue = @"9";
                [self animationFrom:nil toView:self.bet_bg9_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20008 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_2"]){
                keyContinue = @"10";
                [self animationFrom:nil toView:self.bet_bg10_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20009 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_3"]){
                keyContinue = @"11";
                [self animationFrom:nil toView:self.bet_bg11_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20010 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_4"]){
                keyContinue = @"12";
                [self animationFrom:nil toView:self.bet_bg12_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20011 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_5"]){
                keyContinue = @"13";
                [self animationFrom:nil toView:self.bet_bg13_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20012 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_6"]){
                keyContinue = @"14";
                [self animationFrom:nil toView:self.bet_bg14_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20013 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_7"]){
                keyContinue = @"15";
                [self animationFrom:nil toView:self.bet_bg15_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20014 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_8"]){
                keyContinue = @"16";
                [self animationFrom:nil toView:self.bet_bg16_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20015 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_9"]){
                keyContinue = @"17";
                [self animationFrom:nil toView:self.bet_bg17_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20016 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_10"]){
                keyContinue = @"18";
                [self animationFrom:nil toView:self.bet_bg18_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20017 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_11"]){
                keyContinue = @"19";
                [self animationFrom:nil toView:self.bet_bg19_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20018 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_12"]){
                keyContinue = @"20";
                [self animationFrom:nil toView:self.bet_bg20_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20019 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_13"]){
                keyContinue = @"21";
                [self animationFrom:nil toView:self.bet_bg21_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20020 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_14"]){
                keyContinue = @"22";
                [self animationFrom:nil toView:self.bet_bg22_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20021 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_15"]){
                keyContinue = @"23";
                [self animationFrom:nil toView:self.bet_bg23_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20022 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_16"]){
                keyContinue = @"24";
                [self animationFrom:nil toView:self.bet_bg24_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20023 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_17"]){
                keyContinue = @"25";
                [self animationFrom:nil toView:self.bet_bg25_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20024 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_18"]){
                keyContinue = @"26";
                [self animationFrom:nil toView:self.bet_bg26_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20025 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_19"]){
                keyContinue = @"27";
                [self animationFrom:nil toView:self.bet_bg27_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20026 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_20"]){
                keyContinue = @"28";
                [self animationFrom:nil toView:self.bet_bg28_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20027 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_21"]){
                keyContinue = @"29";
                [self animationFrom:nil toView:self.bet_bg29_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20028 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_22"]){
                keyContinue = @"30";
                [self animationFrom:nil toView:self.bet_bg30_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20029 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_23"]){
                keyContinue = @"31";
                [self animationFrom:nil toView:self.bet_bg31_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20030 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_24"]){
                keyContinue = @"32";
                [self animationFrom:nil toView:self.bet_bg32_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20031 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_25"]){
                keyContinue = @"33";
                [self animationFrom:nil toView:self.bet_bg33_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20032 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_26"]){
                keyContinue = @"34";
                [self animationFrom:nil toView:self.bet_bg34_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20033 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_27"]){
                keyContinue = @"35";
                [self animationFrom:nil toView:self.bet_bg35_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20034 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_28"]){
                keyContinue = @"36";
                [self animationFrom:nil toView:self.bet_bg36_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20035 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_29"]){
                keyContinue = @"37";
                [self animationFrom:nil toView:self.bet_bg37_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20036 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_30"]){
                keyContinue = @"38";
                [self animationFrom:nil toView:self.bet_bg38_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20037 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_31"]){
                keyContinue = @"39";
                [self animationFrom:nil toView:self.bet_bg39_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20038 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_32"]){
                keyContinue = @"40";
                [self animationFrom:nil toView:self.bet_bg40_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20039 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_33"]){
                keyContinue = @"41";
                [self animationFrom:nil toView:self.bet_bg41_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20040 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_34"]){
                keyContinue = @"42";
                [self animationFrom:nil toView:self.bet_bg42_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20041 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_35"]){
                keyContinue = @"43";
                [self animationFrom:nil toView:self.bet_bg43_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20042 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"点数_36"]){
                keyContinue = @"44";
                [self animationFrom:nil toView:self.bet_bg44_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20043 moneyNum:subMoney] uid:betModel.msg.uid];
            }

            if (betModel.msg.uid == [[Config getOwnID] longLongValue] && !isContinueBet) {
                NSNumber *num = [NSNumber numberWithInt:[subMoney intValue]];
                NSMutableArray *array = [contiDic objectForKey:keyContinue];
                if (array) {
                    [array addObject:num];
                }else{
                    array = [NSMutableArray array];
                    [array addObject:num];
                    [contiDic setObject:array forKey:keyContinue];
                }
            }
        }

    }

}

-(void)animationFrom:(UIView *)FromView toView:(UIView*)toView betTotalMoney:(NSString*)totalMoney chipView:(UIImageView*)chipImgV uid:(long)uid
{
    if (uid != [[Config getOwnID] longLongValue] || uid ==0) {

        chipImgV.center = CGPointMake(self.betBgView.width/2, self.betBgView.height);

        if (uid == 0) {
            chipImgV.tag = chipImgV.tag+ 100000000;
        }
        [self.betBgView addSubview:chipImgV];
        WeakSelf
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            CGPoint toRectPoint = [strongSelf toRandomRectPointtoView:toView];
            chipImgV.frame = CGRectMake(toRectPoint.x, toRectPoint.y, 22, 22);
        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil||strongSelf->isExit) {
                return;
            }
            if (!strongSelf->voiceAwardMoney ||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"jiafamaaudio.mp3"].location == NSNotFound)) {
                NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"jiafamaaudio.mp3" withExtension:Nil];
                strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
                if ([common soundControlValue] == 2) {
                    [strongSelf->voiceAwardMoney setVolume:0];
                }else{
                    [strongSelf->voiceAwardMoney setVolume:1];
                }
            }
            [strongSelf->voiceAwardMoney prepareToPlay];
            [strongSelf->voiceAwardMoney play];
            if (uid == 0) {
                return;
            }

        }];
    }
}
-(CGPoint)toRandomRectPointtoView:(UIView *)toView
{
    CGRect toViewRect = toView.frame;
    toViewRect = CGRectMake(toViewRect.origin.x  +6, toViewRect.origin.y+12, toViewRect.size.width-12, toViewRect.size.height-12*2);
    CGPoint toRectPoint = CGPointMake(toViewRect.origin.x+[self getRandomNumber:0 to:toViewRect.size.width-18], toViewRect.origin.y+[self getRandomNumber:0 to:toViewRect.size.height-18]);
    return toRectPoint;
}
-(int)getRandomNumber:(int)from to:(int)to
{
  return (int)(from + (arc4random() % (to - from + 1)));
}
-(UIImageView*)getChipImgViewWithTag:(NSInteger)tagNum moneyNum:(NSString*)moneyNum{

//    int numberOfCurrent;
//    ///先移除多余的筹码
//    switch (tagNum) {
//        case 20000:
//            numberOfChips1++;
//            numberOfCurrent = numberOfChips1;
//            break;
//        case 20001:
//            numberOfChips2++;
//            numberOfCurrent = numberOfChips2;
//            break;
//        case 20002:
//            numberOfChips3++;
//            numberOfCurrent = numberOfChips3;
//            break;
//        case 20003:
//            numberOfChips4++;
//            numberOfCurrent = numberOfChips4;
//            break;
//        case 20004:
//            numberOfChips5++;
//            numberOfCurrent = numberOfChips5;
//            break;
//        case 20005:
//            numberOfChips6++;
//            numberOfCurrent = numberOfChips6;
//            break;
//        case 20006:
//            numberOfChips7++;
//            numberOfCurrent = numberOfChips7;
//            break;
//        case 20007:
//            numberOfChips8++;
//            numberOfCurrent = numberOfChips8;
//            break;
//        case 20008:
//            numberOfChips9++;
//            numberOfCurrent = numberOfChips9;
//            break;
//        case 20009:
//            numberOfChips10++;
//            numberOfCurrent = numberOfChips10;
//            break;
//        case 20010:
//            numberOfChips11++;
//            numberOfCurrent = numberOfChips11;
//            break;
//        case 20011:
//            numberOfChips12++;
//            numberOfCurrent = numberOfChips12;
//            break;
//        case 20012:
//            numberOfChips13++;
//            numberOfCurrent = numberOfChips13;
//            break;
//        case 20013:
//            numberOfChips14++;
//            numberOfCurrent = numberOfChips14;
//            break;
//        case 20014:
//            numberOfChips15++;
//            numberOfCurrent = numberOfChips15;
//            break;
//        case 20015:
//            numberOfChips16++;
//            numberOfCurrent = numberOfChips16;
//            break;
//        case 20016:
//            numberOfChips17++;
//            numberOfCurrent = numberOfChips17;
//            break;
//        case 20017:
//            numberOfChips18++;
//            numberOfCurrent = numberOfChips18;
//            break;
//        case 20018:
//            numberOfChips19++;
//            numberOfCurrent = numberOfChips19;
//            break;
//        case 20019:
//            numberOfChips20++;
//            numberOfCurrent = numberOfChips20;
//            break;
//        case 20020:
//            numberOfChips21++;
//            numberOfCurrent = numberOfChips21;
//            break;
//        case 20021:
//            numberOfChips22++;
//            numberOfCurrent = numberOfChips22;
//            break;
//        case 20022:
//            numberOfChips23++;
//            numberOfCurrent = numberOfChips23;
//            break;
//        case 20023:
//            numberOfChips24++;
//            numberOfCurrent = numberOfChips24;
//            break;
//        case 20024:
//            numberOfChips25++;
//            numberOfCurrent = numberOfChips25;
//            break;
//        case 20025:
//            numberOfChips26++;
//            numberOfCurrent = numberOfChips26;
//            break;
//        case 20026:
//            numberOfChips27++;
//            numberOfCurrent = numberOfChips27;
//            break;
//        case 20027:
//            numberOfChips28++;
//            numberOfCurrent = numberOfChips28;
//            break;
//        case 20028:
//            numberOfChips29++;
//            numberOfCurrent = numberOfChips29;
//            break;
//        case 20029:
//            numberOfChips30++;
//            numberOfCurrent = numberOfChips30;
//            break;
//        case 20030:
//            numberOfChips31++;
//            numberOfCurrent = numberOfChips31;
//            break;
//        case 20031:
//            numberOfChips32++;
//            numberOfCurrent = numberOfChips32;
//            break;
//        case 20032:
//            numberOfChips33++;
//            numberOfCurrent = numberOfChips33;
//            break;
//        case 20033:
//            numberOfChips34++;
//            numberOfCurrent = numberOfChips34;
//            break;
//        case 20034:
//            numberOfChips35++;
//            numberOfCurrent = numberOfChips35;
//            break;
//        case 20035:
//            numberOfChips36++;
//            numberOfCurrent = numberOfChips36;
//            break;
//        case 20036:
//            numberOfChips37++;
//            numberOfCurrent = numberOfChips37;
//            break;
//        case 20037:
//            numberOfChips38++;
//            numberOfCurrent = numberOfChips38;
//            break;
//        case 20038:
//            numberOfChips39++;
//            numberOfCurrent = numberOfChips39;
//            break;
//        case 20039:
//            numberOfChips40++;
//            numberOfCurrent = numberOfChips40;
//            break;
//        case 20040:
//            numberOfChips41++;
//            numberOfCurrent = numberOfChips41;
//            break;
//        case 20041:
//            numberOfChips42++;
//            numberOfCurrent = numberOfChips42;
//            break;
//        case 20042:
//            numberOfChips43++;
//            numberOfCurrent = numberOfChips43;
//            break;
//        case 20043:
//            numberOfChips44++;
//            numberOfCurrent = numberOfChips44;
//            break;
//        default:
//            numberOfCurrent = 0;
//            break;
//    }
//    if (numberOfCurrent>KNumberOfChipsLimit) {
//        NSArray *subViews = [NSArray arrayWithArray:self.betBgView.subviews];
//        for (int i = 0; i<subViews.count; i++) {
//            UIView *sub = subViews[i];
//            if (sub.tag ==tagNum) {
//                [sub removeFromSuperview];
//
//                break;
//            }
//        }
//    }

    UIImageView *chipImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    chipImgV.layer.zPosition = 10;
    chipImgV.tag = tagNum;
    UILabel *labelChip = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 18, 22)];
    labelChip.textAlignment = NSTextAlignmentCenter;
    labelChip.adjustsFontSizeToFitWidth = YES;
    labelChip.minimumScaleFactor = 0.5;
    labelChip.font = [UIFont systemFontOfSize:10];

    labelChip.textColor = [UIColor whiteColor];
    [chipImgV addSubview:labelChip];
    switch ([moneyNum intValue]) {
        case 2:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",1]];
            labelChip.text = @"2";
            break;
        case 10:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",2]];
            labelChip.text = @"10";
            break;
        case 100:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",3]];
            labelChip.text = @"100";
            break;
        case 200:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",4]];
            labelChip.text = @"200";
            break;
        case 500:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",5]];
            labelChip.text = @"500";
            break;
        case 1000:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",6]];
            labelChip.text = @"1000";
            break;
        default:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%d",7]];
            labelChip.text = moneyNum;
            break;
    }
    return chipImgV;
}
-(void)setLotteryInfo:(NSDictionary *)msg{
    
}
//刷新时间进程
-(void)refreshTimeUI{
    if(betLeftTime > sealingTime){
        //倒计时中 倒计时动画
        int seconds = (betLeftTime-sealingTime) % 60;
        if (!isFinance) {
            
            [self closeShaiguBoxAnimation];

//            if (contiDic.count>0) {
//                self.continueBtn.enabled = true;
//            }
            ///显示即将开始
            UIView *willReadyView = [self.contentView viewWithTag:2200];
            if (!willReadyView) {
                willReadyView = [[UIView alloc]initWithFrame:CGRectMake(40, 0,SCREEN_WIDTH-80, 73)];
                willReadyView.tag = 2200;
                [self.contentView addSubview:willReadyView];
                willReadyView.center = CGPointMake(SCREEN_WIDTH/2, 100);

                UIImageView *imgVReadybg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-80, 73)];
                imgVReadybg.image = [ImageBundle imagewithBundleName:@"gamecenter_will_begain"];
                [willReadyView addSubview:imgVReadybg];

                UILabel *labelTip = [[UILabel alloc]initWithFrame: CGRectMake((SCREEN_WIDTH/2)-220, 10, 200, 53)];
                labelTip.textColor = RGB(248, 210, 147);
                labelTip.textAlignment = NSTextAlignmentRight;
                labelTip.text = YZMsg(@"game_begain");
                labelTip.font = [UIFont boldSystemFontOfSize:20];
                [willReadyView addSubview:labelTip];

                UIButton *buttonick = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonick.tag = 100;
                buttonick.frame =  CGRectMake(labelTip.right+10, 19, 33, 37);
                [buttonick setBackgroundImage:[ImageBundle imagewithBundleName:@"gamecenter_secondimg"] forState:UIControlStateNormal];
                [buttonick setTitleColor:RGB(248, 210, 147) forState:UIControlStateNormal];
                buttonick.titleLabel.font = [UIFont boldSystemFontOfSize:16];
                [buttonick setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
                [willReadyView addSubview:buttonick];
            }
            willReadyView.layer.zPosition = 15;
            UIButton *buttonick = [willReadyView viewWithTag:100];
            if (buttonick) {
                [buttonick setTitle:minnum(seconds) forState:UIControlStateNormal];
            }
            if (seconds<5) {
                [buttonick shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
                }];
            }
        }
    }else if(betLeftTime == sealingTime){
        //封盘中 可以开始摇骰子动画
        if (!begainAnimationShaigu) {
            [self begainAnimationZP];
        }
    }
}

-(void)closeShaiguBoxAnimation
{
    UIView *ResultShowView = [self.contentView viewWithTag:2500];
    if (ResultShowView) {
        [ResultShowView removeFromSuperview];
    }

    if (!closeAnimationShaigu) {
        closeAnimationShaigu = YES;

        WeakSelf
        [UIView animateWithDuration:0.5 animations:^{

        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            UIView *resultShaigu = [strongSelf.shaiguImgView viewWithTag:1300];
            if (resultShaigu) {
                [resultShaigu removeFromSuperview];
            }


        }];

    }
}

//关闭骰子动画，显示结果
-(void)closeAnimationAndShowResult:(NSString*)result winways:(NSArray*)winways
{
    if (isExit) {
        return;
    }
 
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    begainAnimationShaigu = NO;
   

    if (!voiceAwardMoney||(voiceAwardMoney &&  [voiceAwardMoney.url.path rangeOfString:@"lunpanaudio_result.mp3"].location == NSNotFound)) {
        NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]URLForResource:@"lunpanaudio_result.mp3" withExtension:Nil];
        voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
        if ([common soundControlValue] == 2) {
            [voiceAwardMoney setVolume:0];
        }else{
            [voiceAwardMoney setVolume:1];
        }
    }
    [voiceAwardMoney prepareToPlay];
    [voiceAwardMoney play];

    ///悬浮开奖结果
    UIView *resultPopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,300, 300)];
    resultPopView.tag = 2500;
    resultPopView.layer.zPosition = 21;
    [self.contentView addSubview:resultPopView];
    resultPopView.center = CGPointMake(SCREEN_WIDTH/2, 100+ (396+ShowDiff)/2.0);

    LotteryBetResultePopView * popView = [[LotteryBetResultePopView alloc]initWithFrame:CGRectMake(0, 0,300, 300)];
    [popView animationWithSelectonIndex:[self resultPosition:result]];
    [resultPopView addSubview:popView];

}

-(void)initUI{
    bUICreated = true;
    // 刷新桌面信息
    [self initDeskInfo];
    // 刷新筹码和往期记录
    [self initCollection];
    // 监听按钮事件[历史期号]
    self.chargeView.userInteractionEnabled = YES;
    self.betHistoryIssueView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapHistoryIssue = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doShowHistory)];
    UITapGestureRecognizer *tapCharge = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doCharge:)];
    [self.chargeView addGestureRecognizer:tapCharge];
    [self.betHistoryIssueView addGestureRecognizer:tapHistoryIssue];
    // 监听按钮事件[历史投注]
    [self.betHistoryButton addTarget:self action:@selector(doShowBetHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.continueBtn setTitle:YZMsg(@"game_continue_bet") forState:UIControlStateNormal];
    self.continueBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.continueBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.continueBtn addTarget:self action:@selector(chipContinue) forControlEvents:UIControlEventTouchUpInside];
    [self.musicBtn addTarget:self action:@selector(musicSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_close_all"] forState:UIControlStateSelected];
    if ([common soundControlValue] == 2) {
        [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
        self.musicBtn.selected = YES;
    }else  if ([common soundControlValue] == 1) {
        self.musicBtn.selected = NO;
        [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_close"] forState:UIControlStateNormal];
        
    }else  if ([common soundControlValue] == 0) {
        self.musicBtn.selected = NO;
        [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
    }


}
-(void)musicSwitch:(UIButton*)button
{
    
    if ([common soundControlValue] == 0) {
        if (self.avplayer!=nil) {
            [self.avplayer pause];
            [common soundControl:1];
            [voiceAwardMoney setVolume:1];
            button.selected = NO;
            [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_close"] forState:UIControlStateNormal];
        }
    }else if ([common soundControlValue] == 1) {
        if (self.avplayer!=nil) {
            [self.avplayer pause];
            [common soundControl:2];
            [voiceAwardMoney setVolume:0];
            button.selected = YES;
            [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
        }
    }else if ([common soundControlValue] == 2) {
        if (self.avplayer!=nil) {
            [self.avplayer play];
            [common soundControl:0];
            [voiceAwardMoney setVolume:1];
            button.selected = NO;
            [self.musicBtn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
        }
        
    }
 
}
-(void)chipContinue{
    if (contiDic.count>0) {
        isContinueBet = YES;
        NSArray<UIView*> *betViews = @[self.bet_bg1_view,self.bet_bg2_view,self.bet_bg3_view,self.bet_bg4_view,self.bet_bg5_view,self.bet_bg6_view,self.bet_bg7_view,self.bet_bg8_view,self.bet_bg9_view,self.bet_bg10_view,self.bet_bg11_view,self.bet_bg12_view,self.bet_bg13_view,self.bet_bg14_view,self.bet_bg15_view,self.bet_bg16_view,self.bet_bg17_view,self.bet_bg18_view,self.bet_bg19_view,self.bet_bg20_view,self.bet_bg21_view,self.bet_bg22_view,self.bet_bg23_view,self.bet_bg24_view,self.bet_bg25_view,self.bet_bg26_view,self.bet_bg27_view,self.bet_bg28_view,self.bet_bg29_view,self.bet_bg30_view,self.bet_bg31_view,self.bet_bg32_view,self.bet_bg33_view,self.bet_bg34_view,self.bet_bg35_view,self.bet_bg36_view,self.bet_bg37_view,self.bet_bg38_view,self.bet_bg39_view,self.bet_bg40_view,self.bet_bg41_view,self.bet_bg42_view,self.bet_bg43_view,self.bet_bg44_view];
        NSArray *keysA = [contiDic allKeys];
        for (NSString *keystr in keysA) {
            NSArray *valueArr = [contiDic objectForKey:keystr];
            if (valueArr && valueArr.count>0) {
                for (NSNumber *num in valueArr) {
                    NSInteger valueNum = num.intValue;
                    NSInteger indexBetView = [keystr integerValue] - 1;
                    UIView *betView = betViews[indexBetView];
                    [self betWithView:betView chipNum:valueNum];
                }
            }

        }
        issueContinueBet = curIssue;
        _continueBtn.enabled = false;

    }


}

//刷新桌面信息
-(void)initDeskInfo{
    
    NSInteger maxCount = ways.count;
    NSString *titleMenueStr1 = @"";
    NSString *titleMenueStr2 = @"";
    
    NSMutableArray <NSDictionary *> *titles = _titleSts.mutableCopy;
    for (int i=0; i<maxCount; i++) {
        // 取信息
        NSDictionary *wayInfo = [ways objectAtIndex:i];
        NSString *name = wayInfo[@"name"];
        NSArray *options = wayInfo[@"options"];
        if (name&&[name isEqualToString:@"轮盘"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                NSString *value = [subWayDic objectForKey:@"value"];
                NSInteger betmine = [[subWayDic objectForKey:@"betmine"] integerValue];
                NSArray *betList = [subWayDic objectForKey:@"betlist"];
                UIView *toView = nil;
                NSInteger tagChipN = 0;
                if (title&&[title isEqualToString:@"点数_大"]) {
                    toView = self.bet_bg1_view;
                    tagChipN = 20000;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titleMenueStr1.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr1 = [titleMenueStr1 stringByAppendingString:@" "];
                    }
                    titleMenueStr1 = [titleMenueStr1 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"点数_小"]){
                    toView = self.bet_bg2_view;
                    tagChipN = 20001;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];;
                    if (titleMenueStr1.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr1 = [titleMenueStr1 stringByAppendingString:@" "];
                    }
                    titleMenueStr1 = [titleMenueStr1 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"颜色_红色"]){
                    toView = self.bet_bg3_view;
                    tagChipN = 20002;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                   
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titleMenueStr2.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr2 = [titleMenueStr2 stringByAppendingString:@" "];
                    }
                    titleMenueStr2 = [titleMenueStr2 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"颜色_黑色"]){
                    toView = self.bet_bg4_view;
                    tagChipN = 20003;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titleMenueStr2.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr2 = [titleMenueStr2 stringByAppendingString:@" "];
                    }
                    titleMenueStr2 = [titleMenueStr2 stringByAppendingString:titleSt];
                }else if (title&&[title isEqualToString:@"点数_1-12"]) {
                    toView = self.bet_bg5_view;
                    tagChipN = 20004;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_13-24"]){
                    toView = self.bet_bg6_view;
                    tagChipN = 20005;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_25-36"]){
                    toView = self.bet_bg7_view;
                    tagChipN = 20006;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    
                }else if(title&&[title isEqualToString:@"点数_0"]){
                    toView = self.bet_bg8_view;
                    tagChipN = 20007;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }
                else if(title&&[title isEqualToString:@"点数_1"]){
                    toView = self.bet_bg9_view;
                    tagChipN = 20008;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_2"]){
                    toView = self.bet_bg10_view;
                    tagChipN = 20009;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_3"]){
                    toView = self.bet_bg11_view;
                    tagChipN = 20010;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_4"]){
                    toView = self.bet_bg12_view;
                    tagChipN = 20011;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_5"]){
                    toView = self.bet_bg13_view;
                    tagChipN = 20012;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_6"]){
                    toView = self.bet_bg14_view;
                    tagChipN = 20013;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_7"]){
                    toView = self.bet_bg15_view;
                    tagChipN = 20014;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_8"]){
                    toView = self.bet_bg16_view;
                    tagChipN = 20015;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_9"]){
                    toView = self.bet_bg17_view;
                    tagChipN = 20016;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_10"]){
                    toView = self.bet_bg18_view;
                    tagChipN = 20017;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_11"]){
                    toView = self.bet_bg19_view;
                    tagChipN = 20018;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_12"]){
                    toView = self.bet_bg20_view;
                    tagChipN = 20019;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_13"]){
                    toView = self.bet_bg21_view;
                    tagChipN = 20020;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_14"]){
                    toView = self.bet_bg22_view;
                    tagChipN = 20021;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_15"]){
                    toView = self.bet_bg23_view;
                    tagChipN = 20022;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_16"]){
                    toView = self.bet_bg24_view;
                    tagChipN = 20023;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_17"]){
                    toView = self.bet_bg25_view;
                    tagChipN = 20024;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_18"]){
                    toView = self.bet_bg26_view;
                    tagChipN = 20025;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_19"]){
                    toView = self.bet_bg27_view;
                    tagChipN = 20026;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_20"]){
                    toView = self.bet_bg28_view;
                    tagChipN = 20027;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_21"]){
                    toView = self.bet_bg29_view;
                    tagChipN = 20028;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_22"]){
                    toView = self.bet_bg30_view;
                    tagChipN = 20029;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_23"]){
                    toView = self.bet_bg31_view;
                    tagChipN = 20030;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_24"]){
                    toView = self.bet_bg32_view;
                    tagChipN = 20031;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_25"]){
                    toView = self.bet_bg33_view;
                    tagChipN = 20032;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_26"]){
                    toView = self.bet_bg34_view;
                    tagChipN = 20033;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_27"]){
                    toView = self.bet_bg35_view;
                    tagChipN = 20034;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_28"]){
                    toView = self.bet_bg36_view;
                    tagChipN = 20035;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_29"]){
                    toView = self.bet_bg37_view;
                    tagChipN = 20036;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_30"]){
                    toView = self.bet_bg38_view;
                    tagChipN = 20037;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_31"]){
                    toView = self.bet_bg39_view;
                    tagChipN = 20038;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_32"]){
                    toView = self.bet_bg40_view;
                    tagChipN = 20039;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_33"]){
                    toView = self.bet_bg41_view;
                    tagChipN = 20040;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_34"]){
                    toView = self.bet_bg42_view;
                    tagChipN = 20041;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_35"]){
                    toView = self.bet_bg43_view;
                    tagChipN = 20042;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }else if(title&&[title isEqualToString:@"点数_36"]){
                    toView = self.bet_bg44_view;
                    tagChipN = 20043;
                    UILabel *titleLabel = [toView viewWithTag:200];
                    UILabel *valueLabel = [toView viewWithTag:201];
                  
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   
                }
                if (betmine> 0) {
                    LotteryBetSubView1 *lotterySubBetV = [self.betBgView viewWithTag:toView.tag+888888];
                    if (!lotterySubBetV) {
                        WeakSelf
                        lotterySubBetV = [LotteryBetSubView1 instanceLotteryBetSubViewwWithFrame:CGRectMake(toView.frame.origin.x+(toView.width-80)/2, toView.frame.origin.y-18, 80, 55) contentEdge:4 withBlock:^(BOOL sure) {
                            STRONGSELF
                            if (strongSelf == nil) {
                                return;
                            }
                            if (sure) {
                                [strongSelf doBetNetwork];
                            }else{
                                [strongSelf canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
                            }
                        }];
                        lotterySubBetV.layer.zPosition = 20;
                        lotterySubBetV.tag = toView.tag+888888;
                        [self.betBgView insertSubview:lotterySubBetV atIndex:50];
                        [lotterySubBetV updateMineNumb:betmine];
                    }else{
                        [lotterySubBetV updateMineNumb:betmine];
                    }

                }


                if (betList && betList.count>0 && toView && tagChipN>0) {
                    for (NSString *betSubMoney in betList) {
                        UIImageView *imgBetChip = [self getChipImgViewWithTag:tagChipN moneyNum:betSubMoney];
                        CGPoint toRectPoint = [self toRandomRectPointtoView:toView];
                        imgBetChip.frame = CGRectMake(toRectPoint.x, toRectPoint.y, 22, 22);
                        [self.betBgView addSubview:imgBetChip];
                    }
                }
            }
        }
    }
    _titleSts = titles.copy;
    
    if (chartSubV) {
        [chartSubV updateMenueStr1:titleMenueStr1?[titleMenueStr1 stringByReplacingOccurrencesOfString:@"色" withString:@""]:@"" Str2:titleMenueStr2?[titleMenueStr2 stringByReplacingOccurrencesOfString:@"色" withString:@""]:@""];
    }
}
- (void)initCollection {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 1;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.betChipCollectionView.collectionViewLayout = layout;

    UINib *nib=[UINib nibWithNibName:kChipChoiseCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.betChipCollectionView registerNib: nib forCellWithReuseIdentifier:kChipChoiseCell];
    self.betChipCollectionView.backgroundColor=[UIColor clearColor];
    self.betChipCollectionView.delegate = self;
    self.betChipCollectionView.dataSource = self;
    [self.betChipCollectionView reloadData];
//    WeakSelf
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        [strongSelf.betChipCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[common getChipIndex] inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
//    });

    // 最后一期开奖
    EqualSpaceFlowLayoutEvolve *flowLayout = [[EqualSpaceFlowLayoutEvolve alloc]    initWthType:AlignWithRight];
    flowLayout.betweenOfCell = 1;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);

    self.openResultCollection.delegate = self;
    self.openResultCollection.dataSource = self;
    self.openResultCollection.collectionViewLayout = flowLayout;
    self.openResultCollection.allowsMultipleSelection = self;
    UINib *nib2=[UINib nibWithNibName:kIssueCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultCollection registerNib: nib2 forCellWithReuseIdentifier:kIssueCollectionViewCell];
    self.openResultCollection.backgroundColor=[UIColor clearColor];

    self.msgView = [[LotteryCenterMsgView alloc] initWithFrame:CGRectMake(40, self.chartView.origin.y - 67, SCREEN_WIDTH-80, 65)];
    self.msgView.layer.zPosition = 10;
    [self.contentView addSubview:self.msgView];
    
    self.msgView.userInteractionEnabled = NO;
    
    UICollectionViewFlowLayout *openlayout = [[UICollectionViewFlowLayout alloc] init];
    openlayout.minimumLineSpacing = 0;
    openlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    openlayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    openlayout.itemSize =  CGSizeMake(_window_width,32);
    self.openResultList.collectionViewLayout = openlayout;
    
    UINib *copennibLH=[UINib nibWithNibName:kLotteryOpenViewCell_ZP bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    //[self.openResultCollection registerNib: copennibLH forCellWithReuseIdentifier:kLotteryOpenViewCell_LH];
    [self.openResultList registerNib: copennibLH forCellWithReuseIdentifier:kLotteryOpenViewCell_ZP];
    
    self.openResultList.backgroundColor= RGB_COLOR(@"#000000", 0.22);
    self.openResultList.delegate = self;
    self.openResultList.dataSource = self;
    self.openResultList.allowsMultipleSelection = YES;
    
    WeakSelf
    self.openResultList.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->openPage = 0;
        [strongSelf getOpenResultInfo];
        
    }];
    self.openResultList.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->openPage ++;
        [strongSelf getOpenResultInfo];
    }];
    
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
    [self.openResultList reloadData];
    [self.betHistoryList reloadData];
}


-(void)betAction:(UITapGestureRecognizer *)tap
{
    if (isFinance) {
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_bet_endBet")];
        return;
    }
    if (ways==nil) {
        return;
    }
    UIView *tapView = tap.view;
    if (issueContinueBet != nil && issueContinueBet.length>0 && ![curIssue isEqualToString:issueContinueBet]) {
        [contiDic removeAllObjects];
    }
    self.continueBtn.enabled = false;
    issueContinueBet = curIssue;
    isContinueBet = NO;
    [self betWithView:tapView chipNum:selectedChipModel.chipNumber];
}

-(void)betWithView:(UIView *)tapView chipNum:(NSInteger)chipNum
{
    LiveUser *user = [Config myProfile];
    float balanceNum = [user.coin floatValue] / 10;
    if (chipNum>balanceNum) {
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_NoBalanceDetailDes")];
        return;
    }

    if ([tapView isEqual:self.bet_bg1_view]) {
        [self doBetType:@"点数_大" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg2_view]){
        [self doBetType:@"点数_小" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg3_view]){
        [self doBetType:@"颜色_红色" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg4_view]){
        [self doBetType:@"颜色_黑色"chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg5_view]){
        [self doBetType:@"点数_1-12" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg6_view]){
        [self doBetType:@"点数_13-24" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg7_view]){
        [self doBetType:@"点数_25-36" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg8_view]){
        [self doBetType:@"点数_0" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg9_view]){
        [self doBetType:@"点数_1" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg10_view]){
        [self doBetType:@"点数_2" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg11_view]){
        [self doBetType:@"点数_3" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg12_view]){
        [self doBetType:@"点数_4" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg13_view]){
        [self doBetType:@"点数_5" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg14_view]){
        [self doBetType:@"点数_6" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg15_view]){
        [self doBetType:@"点数_7" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg16_view]){
        [self doBetType:@"点数_8" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg17_view]){
        [self doBetType:@"点数_9" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg18_view]){
        [self doBetType:@"点数_10" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg19_view]){
        [self doBetType:@"点数_11" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg20_view]){
        [self doBetType:@"点数_12" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg21_view]){
        [self doBetType:@"点数_13" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg22_view]){
        [self doBetType:@"点数_14" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg23_view]){
        [self doBetType:@"点数_15" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg24_view]){
        [self doBetType:@"点数_16" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg25_view]){
        [self doBetType:@"点数_17" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg26_view]){
        [self doBetType:@"点数_18" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg27_view]){
        [self doBetType:@"点数_19" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg28_view]){
        [self doBetType:@"点数_20" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg29_view]){
        [self doBetType:@"点数_21" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg30_view]){
        [self doBetType:@"点数_22" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg31_view]){
        [self doBetType:@"点数_23" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg32_view]){
        [self doBetType:@"点数_24" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg33_view]){
        [self doBetType:@"点数_25" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg34_view]){
        [self doBetType:@"点数_26" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg35_view]){
        [self doBetType:@"点数_27" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg36_view]){
        [self doBetType:@"点数_28" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg37_view]){
        [self doBetType:@"点数_29" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg38_view]){
        [self doBetType:@"点数_30" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg39_view]){
        [self doBetType:@"点数_31" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg40_view]){
        [self doBetType:@"点数_32" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg41_view]){
        [self doBetType:@"点数_33" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg42_view]){
        [self doBetType:@"点数_34" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg43_view]){
        [self doBetType:@"点数_35" chipNum:chipNum toView:tapView];
    }else if ([tapView isEqual:self.bet_bg44_view]){
        [self doBetType:@"点数_36" chipNum:chipNum toView:tapView];
    }
}
//是否移除未确认筹码。  是否移除所有的筹码。 当前下注区域
-(void)canBetHidenLastBetSubView:(BOOL)isRemoveAllBetSubView isClearAll:(BOOL)isClearAll toView:(UIView*)toView
{
    NSArray<UIView*> *betViews = @[self.bet_bg1_view,self.bet_bg2_view,self.bet_bg3_view,self.bet_bg4_view,self.bet_bg5_view,self.bet_bg6_view,self.bet_bg7_view,self.bet_bg8_view,self.bet_bg9_view,self.bet_bg10_view,self.bet_bg11_view,self.bet_bg12_view,self.bet_bg13_view,self.bet_bg14_view,self.bet_bg15_view,self.bet_bg16_view,self.bet_bg17_view,self.bet_bg18_view,self.bet_bg19_view,self.bet_bg20_view,self.bet_bg21_view,self.bet_bg22_view,self.bet_bg23_view,self.bet_bg24_view,self.bet_bg25_view,self.bet_bg26_view,self.bet_bg27_view,self.bet_bg28_view,self.bet_bg29_view,self.bet_bg30_view,self.bet_bg31_view,self.bet_bg32_view,self.bet_bg33_view,self.bet_bg34_view,self.bet_bg35_view,self.bet_bg36_view,self.bet_bg37_view,self.bet_bg38_view,self.bet_bg39_view,self.bet_bg40_view,self.bet_bg41_view,self.bet_bg42_view,self.bet_bg43_view,self.bet_bg44_view];

    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView1 *lotterySubBetV = [self.betBgView viewWithTag:betViews[i].tag+888888];
        if (lotterySubBetV) {
            if (toView.tag+888888 != betViews[i].tag+888888) {
                lotterySubBetV.isHiddenTopView = YES;
            }
            if (isRemoveAllBetSubView) {
                [lotterySubBetV clearBetView];
            }
            if (isClearAll) {
                [lotterySubBetV removeFromSuperview];
            }
        }
    }
    if (isRemoveAllBetSubView || isClearAll) {
        NSInteger numbers = self.betBgView.subviews.count;
        NSMutableArray *subViesA = [NSMutableArray array];
        for (int i=0;i<numbers;i++ ) {
            UIView  *subView = self.betBgView.subviews[i];
            if (subView.tag>100000000) {
                [subViesA addObject:subView];
            }
        }
        for (int i= 0; i<subViesA.count; i++) {
            UIView *sub = subViesA[i];
            [sub removeFromSuperview];
        }
    }

}


-(void)doBetType:(NSString*)subWay chipNum:(NSInteger)chipNum toView:(UIView*)toView {
    [self canBetHidenLastBetSubView:false isClearAll:false toView:toView];

    LotteryBetSubView1 *lotterySubBetV = [self.betBgView viewWithTag:toView.tag+888888];
    if (!lotterySubBetV) {
        WeakSelf
        lotterySubBetV = [LotteryBetSubView1 instanceLotteryBetSubViewwWithFrame:CGRectMake(toView.frame.origin.x+(toView.width-80)/2, toView.frame.origin.y-18, 80, 55) contentEdge:4 withBlock:^(BOOL sure) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (sure) {
                [strongSelf doBetNetwork];
            }else{
                [strongSelf canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
            }
        }];
        lotterySubBetV.layer.zPosition = 20;
        lotterySubBetV.tag = toView.tag+888888;
        [self.betBgView addSubview:lotterySubBetV];
    }

    [lotterySubBetV addBetNum:[NSString stringWithFormat:@"%ld",chipNum] ways:subWay];
    
    NSString *subMoney = [NSString stringWithFormat:@"%ld",chipNum];
    if ([subWay isEqualToString:@"点数_大"]) {
        [self animationFrom:nil toView:self.bet_bg1_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20000 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_小"]){
        [self animationFrom:nil toView:self.bet_bg2_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20001 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"颜色_红色"]){
        [self animationFrom:nil toView:self.bet_bg3_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20002 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"颜色_黑色"]){
        [self animationFrom:nil toView:self.bet_bg4_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20003 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_1-12"]){
        [self animationFrom:nil toView:self.bet_bg5_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20004 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_13-24"]){
        [self animationFrom:nil toView:self.bet_bg6_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20005 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_25-36"]){
        [self animationFrom:nil toView:self.bet_bg7_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20006 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_0"]){
        [self animationFrom:nil toView:self.bet_bg8_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20007 moneyNum:subMoney] uid:0];
    }
    else if ([subWay isEqualToString:@"点数_1"]){
        [self animationFrom:nil toView:self.bet_bg9_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20008 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_2"]){
        [self animationFrom:nil toView:self.bet_bg10_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20009 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_3"]){
        [self animationFrom:nil toView:self.bet_bg11_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20010 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_4"]){
        [self animationFrom:nil toView:self.bet_bg12_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20011 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_5"]){
        [self animationFrom:nil toView:self.bet_bg13_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20012 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_6"]){
        [self animationFrom:nil toView:self.bet_bg14_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20013 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_7"]){
        [self animationFrom:nil toView:self.bet_bg15_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20014 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_8"]){
        [self animationFrom:nil toView:self.bet_bg16_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20015 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_9"]){
        [self animationFrom:nil toView:self.bet_bg17_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20016 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_10"]){
        [self animationFrom:nil toView:self.bet_bg18_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20017 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_11"]){
        [self animationFrom:nil toView:self.bet_bg19_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20018 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_12"]){
        [self animationFrom:nil toView:self.bet_bg20_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20019 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_13"]){
        [self animationFrom:nil toView:self.bet_bg21_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20020 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_14"]){
        [self animationFrom:nil toView:self.bet_bg22_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20021 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_15"]){
        [self animationFrom:nil toView:self.bet_bg23_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20022 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_16"]){
        [self animationFrom:nil toView:self.bet_bg24_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20023 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_17"]){
        [self animationFrom:nil toView:self.bet_bg25_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20024 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_18"]){
        [self animationFrom:nil toView:self.bet_bg26_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20025 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_19"]){
        [self animationFrom:nil toView:self.bet_bg27_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20026 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_20"]){
        [self animationFrom:nil toView:self.bet_bg28_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20027 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_21"]){
        [self animationFrom:nil toView:self.bet_bg29_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20028 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_22"]){
        [self animationFrom:nil toView:self.bet_bg30_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20029 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_23"]){
        [self animationFrom:nil toView:self.bet_bg31_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20030 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_24"]){
        [self animationFrom:nil toView:self.bet_bg32_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20031 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_25"]){
        [self animationFrom:nil toView:self.bet_bg33_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20032 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_26"]){
        [self animationFrom:nil toView:self.bet_bg34_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20033 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_27"]){
        [self animationFrom:nil toView:self.bet_bg35_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20034 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_28"]){
        [self animationFrom:nil toView:self.bet_bg36_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20035 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_29"]){
        [self animationFrom:nil toView:self.bet_bg37_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20036 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_30"]){
        [self animationFrom:nil toView:self.bet_bg38_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20037 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_31"]){
        [self animationFrom:nil toView:self.bet_bg39_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20038 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_32"]){
        [self animationFrom:nil toView:self.bet_bg40_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20039 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_33"]){
        [self animationFrom:nil toView:self.bet_bg41_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20040 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_34"]){
        [self animationFrom:nil toView:self.bet_bg42_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20041 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_35"]){
        [self animationFrom:nil toView:self.bet_bg43_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20042 moneyNum:subMoney] uid:0];
    }else if ([subWay isEqualToString:@"点数_36"]){
        [self animationFrom:nil toView:self.bet_bg44_view betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20043 moneyNum:subMoney] uid:0];
    }

}
-(void)doBetNetwork{
    NSArray<UIView*> *betViews = @[self.bet_bg1_view,self.bet_bg2_view,self.bet_bg3_view,self.bet_bg4_view,self.bet_bg5_view,self.bet_bg6_view,self.bet_bg7_view,self.bet_bg8_view,self.bet_bg9_view,self.bet_bg10_view,self.bet_bg11_view,self.bet_bg12_view,self.bet_bg13_view,self.bet_bg14_view,self.bet_bg15_view,self.bet_bg16_view,self.bet_bg17_view,self.bet_bg18_view,self.bet_bg19_view,self.bet_bg20_view,self.bet_bg21_view,self.bet_bg22_view,self.bet_bg23_view,self.bet_bg24_view,self.bet_bg25_view,self.bet_bg26_view,self.bet_bg27_view,self.bet_bg28_view,self.bet_bg29_view,self.bet_bg30_view,self.bet_bg31_view,self.bet_bg32_view,self.bet_bg33_view,self.bet_bg34_view,self.bet_bg35_view,self.bet_bg36_view,self.bet_bg37_view,self.bet_bg38_view,self.bet_bg39_view,self.bet_bg40_view,self.bet_bg41_view,self.bet_bg42_view,self.bet_bg43_view,self.bet_bg44_view];
    NSMutableArray *orders = [NSMutableArray array];
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView1 *lotterySubBetV = [self.betBgView viewWithTag:(betViews[i].tag + 888888)];
        if (lotterySubBetV) {
            lotterySubBetV.isHiddenTopView = YES;
            [orders addObjectsFromArray:[lotterySubBetV.betInfos copy]];
        }
    }

    NSInteger maxCount = orders.count;
    NSString *way = @"[";
    NSString *money = @"[";

    
    NSMutableDictionary *subDicOrder = [NSMutableDictionary dictionary];
    for (int i=0; i<maxCount; i++) {
        NSString *title = orders[i][@"way"];
        NSInteger _money = [orders[i][@"money"] integerValue] * 1;
        NSInteger lastmoney = 0;
        if ([subDicOrder objectForKey:title] ) {
            lastmoney = [[subDicOrder objectForKey:title] integerValue];
        }
        lastmoney = lastmoney+_money;
        [subDicOrder setObject:[NSString stringWithFormat:@"%ld",(long)lastmoney] forKey:title];
        
    }
    NSInteger selectIdx = 0;
    for (int i=0; i<subDicOrder.allKeys.count; i++) {
        NSString *title = subDicOrder.allKeys[i];
        NSInteger _money = [[subDicOrder objectForKey:title] integerValue];
        if(selectIdx == 0){
            way = [NSString stringWithFormat:@"%@\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@%ld",money, (long)_money];
        }else{
            way = [NSString stringWithFormat:@"%@,\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@,%ld",money, (long)_money];
        }
        selectIdx++;
    }
    
    if(selectIdx == 0 || orders == nil){
        [self canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
//        [MBProgressHUD showError:YZMsg(@"LobbyBet_selecte_Warning")];
        return;
    }
    way = [NSString stringWithFormat:@"%@%@",way,@"]"];
    money = [NSString stringWithFormat:@"%@%@",money,@"]"];

    NSString *lottery_type = [NSString stringWithFormat:@"%ld",curLotteryType];
    NSString *issue = curIssue;

    NSInteger liveuid = [GlobalDate getLiveUID];
    NSString *liveuidstr = [NSString stringWithFormat:@"%ld", (long)liveuid];
    __block BOOL showHUDBOOL = true;

    NSString *betIdStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    WeakSelf
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting&uid=%@&token=%@&lottery_type=%@&money=%@&way=%@&serTime=%@&issue=%@&optionName=%@&liveuid=%@&betid=%@",[Config getOwnID],[Config getOwnToken],lottery_type,money,way,minnum([[NSDate date] timeIntervalSince1970]),issue,@"轮盘",@"0",betIdStr];//User.getPlats
    [[YBNetworking sharedManager] postNetworkWithUrl:betUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        showHUDBOOL = false;
        [MBProgressHUD hideHUD];
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            NSDictionary *dict = info;
            
//            [MBProgressHUD showError:msg];
            // 清空信息
            NSArray<UIView*> *betViews = @[strongSelf.bet_bg1_view,strongSelf.bet_bg2_view,strongSelf.bet_bg3_view,strongSelf.bet_bg4_view,strongSelf.bet_bg5_view,strongSelf.bet_bg6_view,strongSelf.bet_bg7_view,strongSelf.bet_bg8_view,strongSelf.bet_bg9_view,strongSelf.bet_bg10_view,strongSelf.bet_bg11_view,strongSelf.bet_bg12_view,strongSelf.bet_bg13_view,strongSelf.bet_bg14_view,strongSelf.bet_bg15_view,strongSelf.bet_bg16_view,strongSelf.bet_bg17_view,strongSelf.bet_bg18_view,strongSelf.bet_bg19_view,strongSelf.bet_bg20_view,strongSelf.bet_bg21_view,strongSelf.bet_bg22_view,strongSelf.bet_bg23_view,strongSelf.bet_bg24_view,strongSelf.bet_bg25_view,strongSelf.bet_bg26_view,strongSelf.bet_bg27_view,strongSelf.bet_bg28_view,strongSelf.bet_bg29_view,strongSelf.bet_bg30_view,strongSelf.bet_bg31_view,strongSelf.bet_bg32_view,strongSelf.bet_bg33_view,strongSelf.bet_bg34_view,strongSelf.bet_bg35_view,strongSelf.bet_bg36_view,strongSelf.bet_bg37_view,strongSelf.bet_bg38_view,strongSelf.bet_bg39_view,strongSelf.bet_bg40_view,strongSelf.bet_bg41_view,strongSelf.bet_bg42_view,strongSelf.bet_bg43_view,strongSelf.bet_bg44_view];
            for (int i = 0; i<betViews.count; i++) {
                LotteryBetSubView1 *lotterySubBetV = [strongSelf.betBgView viewWithTag:(betViews[i].tag + 888888)];
                if (lotterySubBetV) {
                    if(lotterySubBetV.isHiddenTopView){
                        [lotterySubBetV sureBetView];
                    }
                }
            }
            for (UIView *subV in strongSelf.betBgView.subviews) {
                if (subV.tag>100000000) {
                    subV.tag = subV.tag - 100000000;
                }
            }
            LiveUser *user = [Config myProfile];
            if([dict[@"left_coin"] floatValue] > [user.coin floatValue]){
//                return;
            }
            [common saveLastChipModel:strongSelf->selectedChipModel];
            user.coin = minstr(dict[@"left_coin"]);
            [Config updateProfile:user];
            [strongSelf refreshLeftCoinLabel];

        }
        else{
            [strongSelf canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        showHUDBOOL = false;
        [MBProgressHUD hideHUD];
        // 请求失败
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
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


- (void)refreshData:(NSNotification *)notification {
    if(!bUICreated){
        return;
    }
    NSString *leftCoin = (notification.userInfo[@"money"]);

    LiveUser *user = [Config myProfile];
    user.coin = minstr(leftCoin);
    [Config updateProfile:user];

    [self refreshLeftCoinLabel];
}


-(void)refreshLeftCoinLabel{
    LiveUser *user = [Config myProfile];
    self.leftCoinLabel.text = [NSString stringWithFormat:@"%.2f", [user.coin floatValue] / 10];
}

-(void)doShowBetHistory{
    LobbyHistoryAlertController *history = [[LobbyHistoryAlertController alloc]initWithNibName:@"LobbyHistoryAlertController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    WeakSelf
    history.closeCallback = ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
       
    };
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    history.view.frame = CGRectMake(0, _window_height, _window_width, _window_height);
    [self.view addSubview:history.view];
    [self addChildViewController:history];
    history.view.frame = CGRectMake(0, 0, _window_width, _window_height);
    [history.view didMoveToSuperview];
    [history didMoveToParentViewController:self];
}

-(void)doShowHistory{
    OpenHistoryViewController *chipVC = [[OpenHistoryViewController alloc] initWithNibName:@"OpenHistoryViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    WeakSelf
    chipVC.closeCallback = ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
    };
    [chipVC setLotteryType:curLotteryType];
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:chipVC.view];
    [self addChildViewController:chipVC];
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



#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if ([collectionView isEqual:self.betChipCollectionView]) {
        return chipsArraysAll.count;
    }else if (collectionView == self.openResultList){
        return self.allOpenResultData.count;
    }else if (collectionView == self.betHistoryList){
        return self.listModel.count;
    }else{
        if(!last_open_result) return 0;
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
        NSInteger result_count = open_result.count;
        if(curLotteryType == 8 ||curLotteryType == 7||curLotteryType == 32){
            result_count = result_count + 1;
        }
        return result_count;
    }


}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        ChipChoiseCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kChipChoiseCell forIndexPath:indexPath];
        ChipsModel *modelChip = chipsArraysAll[indexPath.row];
        [cell.chipImgView setImage:[ImageBundle imagewithBundleName:modelChip.chipIcon]];
        cell.chipNum = modelChip.chipNumber;
        cell.chipNumLabel.text = modelChip.chipStr;
        if (modelChip.isEdit) {
            cell.chipNumLabel.numberOfLines=2;
            if (modelChip.customChipNumber>0) {
                cell.chipNumLabel.font = [UIFont systemFontOfSize:13];
            }else{
                cell.chipNumLabel.font = [UIFont systemFontOfSize:20];
            }
        }else{
            cell.chipNumLabel.numberOfLines=1;
            cell.chipNumLabel.font = [UIFont systemFontOfSize:13];
        }

        cell.chipImgView.layer.cornerRadius = 16;
        if (modelChip.chipStr == selectedChipModel.chipStr) {
            [UIView animateWithDuration:0.3 animations:^{
                cell.bgView.transform = CGAffineTransformMakeScale(1.23, 1.23);
            }];
            cell.chipImgView.layer.borderWidth = 1;
            cell.chipImgView.layer.borderColor = [UIColor yellowColor].CGColor;
        }else{
            cell.chipImgView.layer.borderWidth = 0;
            cell.chipImgView.layer.borderColor = [UIColor yellowColor].CGColor;
            cell.bgView.transform = CGAffineTransformIdentity;
        }
        return cell;
    } else if (collectionView == self.betHistoryList){
        LiveBetListYFKSCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLiveBetListYFKSCell forIndexPath:indexPath];
        cell.model = self.listModel[indexPath.row];
        WeakSelf
        cell.clickBetBlock = ^(BetListDataModel * _Nonnull model) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf clickHistoryBetAction:model];
        };
        return cell;
    } else if(collectionView == self.openResultList){
        LotteryOpenViewCell_ZP *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_ZP forIndexPath:indexPath];
        lastResultModel * model = self.allOpenResultData[indexPath.row];
        cell.issuLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
        cell.rigthtLab.text = model.open_result;
        [cell updateConstraintsForFullscreen];
        NSString * number = model.open_result;
           NSArray * arr = @[@"32",@"4",@"21",@"25",@"34",@"27",@"36",@"30",@"23",@"5",@"16",@"1",@"14",@"9",@"18",@"7",@"12",@"3"];
           if ([model.open_result isEqualToString:@"0"]) {
               cell.rigthtLab.backgroundColor = [UIColor greenColor];
           }else if ([arr containsObject:number]){
               cell.rigthtLab.backgroundColor = [UIColor redColor];
           }else{
               cell.rigthtLab.backgroundColor = [UIColor blackColor];
           }
        return cell;
    } else{
        IssueCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell forIndexPath:indexPath];
        cell.titile.adjustsFontSizeToFitWidth = YES;
        cell.titile.minimumScaleFactor = 0.5;
        [cell.titile mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell);
            make.left.equalTo(cell).offset(2);
            make.right.equalTo(cell).offset(-2);
        }];
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];

        NSString *resultStr = @"";
        if(curLotteryType == 8 ||curLotteryType == 7||curLotteryType == 32){
            if(indexPath.row == 6){
                resultStr = @"+";
            }else if (indexPath.row == 7){
                resultStr = [open_result objectAtIndex:6];
            }else{
                resultStr = [open_result objectAtIndex:indexPath.row];
            }
        }else{
            resultStr = [open_result objectAtIndex:indexPath.row];
        }
        [cell setNumber:resultStr lotteryType:curLotteryType];
        [cell.titile setFont:[UIFont boldSystemFontOfSize:14.f]];
        return cell;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        return CGSizeMake(46, 46);
    }else if (collectionView == self.openResultList){
        return CGSizeMake(_window_width, 50);
    }else if (collectionView == self.betHistoryList){
        return CGSizeMake(_window_width, 32);
    }else{
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
        NSInteger result_count = open_result.count;
        if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            result_count = result_count + 1;
        }
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float scaleRate = MAX(MIN(matchW, 40), 20) / 80;
        return CGSizeMake(80*scaleRate, 80*scaleRate);
    }


}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        return CGSizeMake(40, 40);
    }else if (collectionView == self.openResultList){
        return CGSizeMake(_window_width, 50);
    }else if (collectionView == self.betHistoryList){
        return CGSizeMake(_window_width, 32);
    }else{
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
        NSInteger result_count = open_result.count;
        if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            result_count = result_count + 1;
        }

        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float scaleRate = MAX(MIN(matchW, 40), 20) / 80;

        //return CGSizeMake(80*scaleRate, 80*scaleRate);
        return CGSizeMake(60, 32);
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else if (collectionView == self.openResultList){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else if (collectionView == self.betHistoryList){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(0, 5, 0, 5);
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        NSArray *chipsModelList = chipsArraysAll;
        ChipsModel *model = chipsModelList[indexPath.row];
        if (model.isEdit && ([common getCustomChipNum]<=0||selectedChipModel.chipNumber == model.chipNumber)) {
            [self doCustomChip];
        }else{
//            ChipChoiseCell *cell = (ChipChoiseCell*)[collectionView cellForItemAtIndexPath:indexPath];
            selectedChipModel = chipsArraysAll[indexPath.row];
            [self.betChipCollectionView reloadData];
        }
    }else{
        [self doShowHistory];
    }
}

- (IBAction)playDes:(UIButton *)sender {

    popWebH5 *VC = [[popWebH5 alloc]init];
   VC.titles = YZMsg(@"LobbyLotteryVC_betExplain");
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
      
   };
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   [self.view addSubview:VC.view];
   [self addChildViewController:VC];

}

-(void)doCustomChip{
    WeakSelf
    myAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    //关闭事件 此时要置为不然会内存泄漏
    .wEventCloseSet(^(id anyID, id otherData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->myAlert = nil;
    })
    .wWidthSet(_window_width * 0.8)
    .wMainOffsetYSet(0)
    .wShowAnimationSet(AninatonZoomIn)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.25)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        STRONGSELF

        UILabel *title = [UILabel new];
        title.font = [UIFont systemFontOfSize:15.0f];
        title.text = YZMsg(@"ChipSwitch_input_custom_chip");

        title.frame = CGRectMake(0, 0, mainView.frame.size.width, 30);
        [title setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:title];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(mainView.frame.size.width/3*1/2, 50, mainView.frame.size.width/3*2, 30)];
        textField.placeholder = [NSString stringWithFormat:@"%@2-50000",YZMsg(@"LobbyBet_RangeBetMoney")];
        textField.font = [UIFont systemFontOfSize:15.0f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:textField];
        strongSelf->alertTextField = textField;


        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:cancelBtn];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        cancelBtn.frame = CGRectMake(0, 80+30, mainView.frame.size.width/2, 40);
        [cancelBtn setTitle:YZMsg(@"public_back") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        cancelBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        cancelBtn.layer.borderWidth = 1; //边框的宽度
//        cancelBtn.layer.cornerRadius = 10;
        [cancelBtn addTarget:strongSelf action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];

        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        confirmBtn.frame = CGRectMake(mainView.frame.size.width/2, 80+30, mainView.frame.size.width/2, 40);
        [confirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        confirmBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        confirmBtn.layer.borderWidth = 1; //边框的宽度
//        confirmBtn.layer.cornerRadius = 10;
        [confirmBtn addTarget:strongSelf action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
//        confirmBtn.tag = sender.tag;

//        mainView.layer.masksToBounds = YES;
//        mainView.layer.cornerRadius = 10;

        cancelBtn.bottom =  CGRectGetMaxY(mainView.frame);
        confirmBtn.bottom =  CGRectGetMaxY(mainView.frame);
        return mainView;
    })
    .wStart();
}

-(void)closeAction:(UIButton*)sender{
    [myAlert closeView];
}

-(void)confirmAction:(UIButton*)sender{
    if ([alertTextField.text integerValue]<=1 || [alertTextField.text integerValue]>50000) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@2-50000",YZMsg(@"LobbyBet_RangeBetMoney")]];
        return;
    }
    [common saveCustomChipNum:[alertTextField.text integerValue]];
    for (ChipsModel *model in chipsArraysAll) {
        if (model.isEdit && [alertTextField.text integerValue]>0) {
            model.chipNumber = [alertTextField.text integerValue];
            model.chipStr = [NSString stringWithFormat:@"?\n%@",alertTextField.text] ;
            model.customChipNumber= model.chipNumber ;
        }
    }
    [myAlert closeView];
    [self.betChipCollectionView reloadData];
}

-(void)exitView{

    [self releaseView];
//    [GameToolClass setCurOpenedLotteryType:curLotteryType];
   
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)releaseView
{
    isExit = YES;
    
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    voiceAwardMoney = nil;

    if (self.avplayer) {
        [self.avplayer pause];
        self.avplayer = nil;
    }
    [self clearSelectBetView];

    if (lotteryTime) {
        [lotteryTime invalidate];
        lotteryTime = nil;
    }
    if (socketDelegate) {
        socketDelegate.socketDelegate = nil;
        socketDelegate = nil;
    }
    if (self.ballBgView) {
        [self.ballBgView.layer removeAllAnimations];
    }
    if (self.shaiguImgView) {
        [self.shaiguImgView.layer removeAllAnimations];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotteryOpenAward" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"lotteryInfoNotify" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotteryAwardNotificationMsg" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBetDoNotificationMsg object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBetWinNotificationMsg object:nil];
   
    if (self.lotteryDelegate!= nil) {
        [self.lotteryDelegate lotteryCancless];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"dealloc");
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}



- (IBAction)returnLive:(id)sender {
    [self exitView];
//    if (self.lotteryDelegate!= nil) {
//        [self.lotteryDelegate returnCancless];
//    }
}

static BOOL begainAnimationShaigu;
-(void)begainAnimationZP{
//    [self backToStartPosition];
//    self.startButton.enabled = NO;
    if (isExit) {
        return;
    }
    //移除未下注的
    NSArray<UIView*> *betViews = @[self.bet_bg1_view,self.bet_bg2_view,self.bet_bg3_view,self.bet_bg4_view,self.bet_bg5_view,self.bet_bg6_view,self.bet_bg7_view,self.bet_bg8_view,self.bet_bg9_view,self.bet_bg10_view,self.bet_bg11_view,self.bet_bg12_view,self.bet_bg13_view,self.bet_bg14_view,self.bet_bg15_view,self.bet_bg16_view,self.bet_bg17_view,self.bet_bg18_view,self.bet_bg19_view,self.bet_bg20_view,self.bet_bg21_view,self.bet_bg22_view,self.bet_bg23_view,self.bet_bg24_view,self.bet_bg25_view,self.bet_bg26_view,self.bet_bg27_view,self.bet_bg28_view,self.bet_bg29_view,self.bet_bg30_view,self.bet_bg31_view,self.bet_bg32_view,self.bet_bg33_view,self.bet_bg34_view,self.bet_bg35_view,self.bet_bg36_view,self.bet_bg37_view,self.bet_bg38_view,self.bet_bg39_view,self.bet_bg40_view,self.bet_bg41_view,self.bet_bg42_view,self.bet_bg43_view,self.bet_bg44_view];
    BOOL isRemoveAll = false;
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView1 *lotterySubBetV = [self.betBgView viewWithTag:(betViews[i].tag + 888888)];
        if (lotterySubBetV) {
            isRemoveAll = !lotterySubBetV.isHiddenTopView;
            if (isRemoveAll) {
                break;
            }
        }
    }
    if (isRemoveAll) {
        [self canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
    }

    begainAnimationShaigu = YES;
    isFinance = YES;
    self.continueBtn.enabled = false;
    UIView *willReadyView = [self.contentView viewWithTag:2200];
    if (willReadyView) {
        [willReadyView removeFromSuperview];
    }
    UIView *ResultShowView = [self.contentView viewWithTag:2500];
    if (ResultShowView) {
        [ResultShowView removeFromSuperview];
    }
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];

    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    layer.toValue = @(M_PI*2*20);
    layer.duration = 40;
    layer.repeatCount = MAXFLOAT;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    layer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    layer.delegate = self;
    [self.shaiguImgView.layer addAnimation:layer forKey:nil];

    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    ballLayer.toValue = @(-M_PI*2*40);
    ballLayer.duration = 40;
    ballLayer.repeatCount = MAXFLOAT;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    ballLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    ballLayer.delegate = self;
    [self.ballBgView.layer addAnimation:ballLayer forKey:nil];

    if (!voiceAwardMoney||(voiceAwardMoney &&  [voiceAwardMoney.url.path rangeOfString:@"lunpanaudio_begain.mp3"].location == NSNotFound)) {
        NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]URLForResource:@"lunpanaudio_begain.mp3" withExtension:Nil];
        voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
        voiceAwardMoney.numberOfLoops = 10;
        if ([common soundControlValue] == 2) {
            [voiceAwardMoney setVolume:0];
        }else{
            [voiceAwardMoney setVolume:1];
        }
    }
    [voiceAwardMoney prepareToPlay];
    [voiceAwardMoney play];
}

-(void)animationWithSelectonIndex:(NSInteger)index{

    [self backToStartPosition];
//    self.startButton.enabled = NO;
    begainAnimationShaigu = NO;
    int x = arc4random() % 37;
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];

    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    layer.toValue = @(x*perSection + M_PI/2);
    layer.duration = 2;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    layer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    layer.delegate = self;
    [self.shaiguImgView.layer addAnimation:layer forKey:nil];

    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    ballLayer.toValue = @(x*perSection +perSection*index + M_PI/2);
    ballLayer.duration = 2;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    ballLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    ballLayer.delegate = self;

    [self.ballBgView.layer addAnimation:ballLayer forKey:nil];

}

-(void)backToStartPosition{
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    layer.toValue = @(0);
    layer.duration = 0.001;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    [self.shaiguImgView.layer addAnimation:layer forKey:nil];

    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    ballLayer.toValue = @(0);
    ballLayer.duration = 0.001;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    [self.ballBgView.layer addAnimation:ballLayer forKey:nil];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    //设置指针返回初始位置
//    self.startButton.enabled = YES;
//    if (self.rotaryEndTurnBlock) {
//        self.rotaryEndTurnBlock();
//    }
}

//开始进来时停在开奖的号码
-(void)animationWithBegainSelectonIndex:(NSInteger)index{

    CABasicAnimation *ballLayer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    ballLayer.toValue = @(perSection*index);
    ballLayer.duration = 0.001;
    ballLayer.removedOnCompletion = NO;
    ballLayer.fillMode = kCAFillModeForwards;
    ballLayer.delegate = self;
    [self.ballBgView.layer addAnimation:ballLayer forKey:nil];

}

//开奖结果 0  绿色。1 红色。2黑色
-(void)resultColor:(NSString *)str{
    NSArray * arr = @[@"32",@"4",@"21",@"25",@"34",@"27",@"36",@"30",@"23",@"5",@"16",@"1",@"14",@"9",@"18",@"7",@"12",@"3"];
    if ([str isEqualToString:@"0"]) {
        self.openResutLab.backgroundColor = [UIColor greenColor];
    }else if ([arr containsObject:str]){
        self.openResutLab.backgroundColor = [UIColor redColor];
    }else{
        self.openResutLab.backgroundColor = [UIColor blackColor];
    }
}

//开奖结果的位置
-(NSInteger)resultPosition:(NSString *)str{
    NSArray * arr = @[@"0",@"32",@"15",@"4",@"19",@"21",@"2",@"25",@"17",@"34",@"6",@"27",@"13",@"36",@"11",@"30",@"8",@"23",@"10",@"5",@"24",@"16",@"33",@"1",@"20",@"14",@"31",@"9",@"22",@"18",@"29",@"7",@"28",@"12",@"35",@"3",@"26"];
    NSInteger index = [arr indexOfObject:str];
//    for (NSInteger i =0; i <arr.count; i++) {
//        if ([str isEqualToString:arr[i]]) {
//            index = i;
//        }
//    }
    return index;
}
-(void)clearSelectBetView
{
    NSArray<UIView*> *betViews = @[self.bet_bg1_view,self.bet_bg2_view,self.bet_bg3_view,self.bet_bg4_view,self.bet_bg5_view,self.bet_bg6_view,self.bet_bg7_view,self.bet_bg8_view,self.bet_bg9_view,self.bet_bg10_view,self.bet_bg11_view,self.bet_bg12_view,self.bet_bg13_view,self.bet_bg14_view,self.bet_bg15_view,self.bet_bg16_view,self.bet_bg17_view,self.bet_bg18_view,self.bet_bg19_view,self.bet_bg20_view,self.bet_bg21_view,self.bet_bg22_view,self.bet_bg23_view,self.bet_bg24_view,self.bet_bg25_view,self.bet_bg26_view,self.bet_bg27_view,self.bet_bg28_view,self.bet_bg29_view,self.bet_bg30_view,self.bet_bg31_view,self.bet_bg32_view,self.bet_bg33_view,self.bet_bg34_view,self.bet_bg35_view,self.bet_bg36_view,self.bet_bg37_view,self.bet_bg38_view,self.bet_bg39_view,self.bet_bg40_view,self.bet_bg41_view,self.bet_bg42_view,self.bet_bg43_view,self.bet_bg44_view];
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView1 *lotterySubBetV = [self.betBgView viewWithTag:(betViews[i].tag + 888888)];
        if (lotterySubBetV) {
            [lotterySubBetV removeFromSuperview];
        }
    }
}

- (IBAction)doReturn:(id)sender {
    [self exitView];
}

- (IBAction)moreGame:(id)sender {
    SwitchLotteryViewController *lottery = [[SwitchLotteryViewController alloc]initWithNibName:@"SwitchLotteryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    lottery.isFromGameCenter = YES;
    lottery.lotteryDelegate = self.lotteryDelegate;
    lottery.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self addChildViewController:lottery];
    [self.view addSubview:lottery.view];
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

    NSString *game_music_img_name;
    if ([common soundControlValue] == 2) {
        game_music_img_name = @"game_music_open";
    }else  if ([common soundControlValue] == 1) {
        game_music_img_name = @"game_music_close";
    }else  if ([common soundControlValue] == 0) {
        game_music_img_name = @"game_music_close";
    }
    
    NSArray * imgArr = @[@"yfks_icon_zst",@"yfks_icon_tzjl",@"yfks_icon_kjjl",@"yfks_icon_wfsm",game_music_img_name,@"yfks_icon_lstz",@"yfks_icon_qhxb",@"yfks_icon_game"];

    CGFloat contentLength = 0;
    CGFloat buttonWidth = 30.0;
    CGFloat spacing = 5;
    
    UIButton *firstBtn;
    
    self.toolBtnArr = [NSMutableArray array];
    for (int i = 0; i< imgArr.count; i ++) {
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
        [livechatBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
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
        if (i == 0) {
            firstBtn = livechatBtn;
        }
        if (i == 4) {
            [livechatBtn setImage:[ImageBundle imagewithBundleName:@"game_music_close_all"] forState:UIControlStateSelected];
            if ([common soundControlValue] == 2) {
                [livechatBtn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
                livechatBtn.selected = YES;
            }else  if ([common soundControlValue] == 1) {
                livechatBtn.selected = NO;
                [livechatBtn setImage:[ImageBundle imagewithBundleName:@"game_music_close"] forState:UIControlStateNormal];
                
            }else  if ([common soundControlValue] == 0) {
                livechatBtn.selected = NO;
                [livechatBtn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
            }
        }
    }
    self.toolScrollView.contentSize = CGSizeMake(contentLength, 0);
    [self.toolBg addSubview:self.toolScrollView];
    [self titleBtnClick: firstBtn];
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
// 工具栏点击事件
-(void)titleBtnClick:(UIButton *)btn{
    if (btn.tag == 1004) {
        if ([common soundControlValue] == 0) {
            if (self.avplayer!=nil) {
                [self.avplayer pause];
                [common soundControl:1];
                [voiceAwardMoney setVolume:1];
                btn.selected = NO;
                [btn setImage:[ImageBundle imagewithBundleName:@"game_music_close"] forState:UIControlStateNormal];
            }
        }else if ([common soundControlValue] == 1) {
            if (self.avplayer!=nil) {
                [self.avplayer pause];
                [common soundControl:2];
                [voiceAwardMoney setVolume:0];
                btn.selected = YES;
                [btn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
            }
        }else if ([common soundControlValue] == 2) {
            if (self.avplayer!=nil) {
                [self.avplayer play];
                [common soundControl:0];
                [voiceAwardMoney setVolume:1];
                btn.selected = NO;
                [btn setImage:[ImageBundle imagewithBundleName:@"game_music_open"] forState:UIControlStateNormal];
            }
        }
        return;
    }
    if ([btn isEqual:self.selectedToolBtn]) {
//        btn.selected = NO;
//        [self rebackScrollView: NO];
//        self.selectedToolBtn = nil;
        return;
    }
    
    
    btn.selected = YES;
    //    顶部高度变化刷新聊天列表高度
    if(btn.tag < 1003){
        if (self.lotteryDelegate!= nil && !isShowTopList) {
            isShowTopList = YES;
            [self.lotteryDelegate refreshTableHeight:YES];
        }
        //        [UIView animateWithDuration:0.3 animations:^{
        //            [self updateViewFrame];
        //            [self.view layoutIfNeeded]; // 重要：强制布局更新以触发动画
        //        } completion:^(BOOL finished) {
        //            // 动画完成后执行任何必要的操作
        //        }];
        self.selectedToolBtn.selected = NO;
        self.selectedToolBtn = btn;
    }else{
        if(btn.tag != 1003 && btn.tag != 1005 && btn.tag != 1007){
            if (self.lotteryDelegate!= nil && isShowTopList) {
                isShowTopList = NO;
                [self.lotteryDelegate refreshTableHeight:NO];
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                //[self updateViewFrame];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.chartView.hidden = YES;
                self.betHistoryList.hidden = YES;
                self.openResultList.hidden = YES;
            }];
        }
    }
    if (btn.tag<=1005 || btn.tag == 1007) {
        [self.toolScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        CGFloat xOffset = self.toolScrollView.contentSize.width - self.toolScrollView.bounds.size.width;
        [self.toolScrollView setContentOffset:CGPointMake(xOffset, 0) animated:YES];
    }
    

    if(btn.tag == 1000){
        //  走势图
        self.chartView.hidden = NO;
        self.betHistoryList.hidden = YES;
        self.openResultList.hidden = YES;
        self.noView.hidden = YES;
        
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
        [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"yfks_anniu2"] forState:UIControlStateSelected];
        [btn setTitle:YZMsg(@"trend_title") forState:UIControlStateSelected];
        [UIView animateWithDuration:0.3 animations:^{
            self.toolScrollView.contentSize = CGSizeMake(35*self.toolBtnArr.count + 60, 0);
            for (int i = 0; i< self.toolBtnArr.count; i ++) {
                UIButton *livechatBtn = self.toolBtnArr[i];
                if(i == 0){
                    livechatBtn.frame = CGRectMake(5,5,80,30);
                }else{
                    livechatBtn.frame = CGRectMake(5+50+i*(30+5),5,30,30);
                }
            }
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }else if (btn.tag == 1001){
        //  投注记录
        self.betHistoryList.hidden = NO;
        self.chartView.hidden = YES;
        self.openResultList.hidden = YES;
        [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"yfks_anniu2"] forState:UIControlStateSelected];
        [btn setTitle:YZMsg(@"LobbyLotteryVC_BetRecord") forState:UIControlStateSelected];
        self.toolScrollView.contentSize = CGSizeMake(35*self.toolBtnArr.count + 80, 0);
        [self getBetInfo];
        [UIView animateWithDuration:0.3 animations:^{
            for (int i = 0; i< self.toolBtnArr.count; i ++) {
                UIButton *livechatBtn = self.toolBtnArr[i];
                if(i == 0){
                    livechatBtn.frame = CGRectMake(5,5,30,30);
                }else if(i == 1){
                    livechatBtn.frame = CGRectMake(5+i*(30+5),5,100,30);
                }else{
                    livechatBtn.frame = CGRectMake(5+70+i*(30+5),5,30,30);
                }
            }
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }else if (btn.tag == 1002){
        //  开奖记录
        self.noView.hidden = YES;
        self.openResultList.hidden = NO;
        self.openResultList.layer.cornerRadius = 15;
        self.betHistoryList.hidden = YES;
        self.chartView.hidden = YES;
        [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"yfks_anniu2"] forState:UIControlStateSelected];
        [btn setTitle:YZMsg(@"menu_lottery_result") forState:UIControlStateSelected];
        self.toolScrollView.contentSize = CGSizeMake(35*self.toolBtnArr.count + 80, 0);
        [self getOpenResultInfo];
        [UIView animateWithDuration:0.3 animations:^{
            for (int i = 0; i< self.toolBtnArr.count; i ++) {
                UIButton *livechatBtn = self.toolBtnArr[i];
                if(i <= 1){
                    livechatBtn.frame = CGRectMake(5+i*(30+5),5,30,30);
                }else if(i == 2){
                    livechatBtn.frame = CGRectMake(5+i*(30+5),5,100,30);
                }else{
                    livechatBtn.frame = CGRectMake(5+70+i*(30+5),5,30,30);
                }
            }
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
       

        if (btn.tag == 1003){
            //  玩法说明
            popWebH5 *VC = [[popWebH5 alloc]init];
            VC.titles = YZMsg(@"LobbyLotteryVC_betExplain");
            NSString *url = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"index.php?g=Appapi&m=LotteryArticle&a=index&lotteryType=%@&uid=%@&token=%@",minnum(curLotteryType), [Config getOwnID],[Config getOwnToken]];
            url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
            VC.urls = url;
//            VC.hightRate = 0.5;
            VC.isBetExplain = YES;
            WeakSelf
            UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [VC doCloseWeb];
                //[strongSelf updateViewFrame];
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
                //[strongSelf updateViewFrame];
            };
            self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.view addSubview:VC.view];
            [self addChildViewController:VC];
            
        }else if (btn.tag == 1005){
            //  投注历史
            [self doShowBetHistory];
        }else if (btn.tag == 1006){
            //  切换新旧版
            //[self rebackScrollView];
            //[self exitViewFromExchange];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotteryOpenAward" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"lotteryInfoNotify" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotteryAwardNotificationMsg" object:nil];
        //    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBetDoNotificationMsg object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:KBetWinNotificationMsg object:nil];
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate exchangeVersionToOld: curLotteryType];
            }
        }else if (btn.tag == 1007){
            //  游戏切换
            //self.selectedToolBtn.selected = NO;
            //[self rebackScrollView: NO];
            SwitchLotteryViewController *lottery = [[SwitchLotteryViewController alloc]initWithNibName:@"SwitchLotteryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            lottery.isFromGameCenter = YES;
            lottery.lotteryDelegate = self.lotteryDelegate;
            lottery.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self addChildViewController:lottery];
            [self.view addSubview:lottery.view];
        }
    }
}
// 投注记录
- (void)getBetInfo{
    //    if(!bUICreated){
    //        self.openResultList.hidden = YES;
    //    }
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
            if(strongSelf.listModel.count ==0){
                if(strongSelf.selectedToolBtn.tag == 1001){
                    strongSelf.noView.hidden = NO;
                }
            }else{
                strongSelf.noView.hidden = YES;
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
// 开奖历史
- (void)getOpenResultInfo{
    //    if(!bUICreated){
    //        self.openResultList.hidden = YES;
    //    }
    NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenHistory&uid=%@&token=%@&lottery_type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES andParameter:@{@"page":minnum(openPage)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.openResultList.mj_header endRefreshing];
        [strongSelf.openResultList.mj_footer endRefreshing];
        
        NSLog(@"xxxxxxxxx%@",info);
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        if(code == 0 && [info isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"%@",info);
            NSDictionary * infoDict = [[NSDictionary alloc] initWithDictionary:info];
            NSArray *dataArrays = [lastResultModel mj_objectArrayWithKeyValuesArray:[infoDict objectForKey:@"list"]];
            if(strongSelf->curLotteryType == 31 || strongSelf->curLotteryType == 29){
                dataArrays = [infoDict objectForKey:@"list"];
            }
            if ([dataArrays isKindOfClass:[NSArray class]]) {
                
                if (strongSelf->openPage == 0) {
                    strongSelf.allOpenResultData = [NSMutableArray arrayWithArray:dataArrays];
                }else{
                    if (dataArrays.count <= 0) {
                        [strongSelf.openResultList.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        for (lastResultModel *subModel in dataArrays) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issue CONTAINS[cd] %@" ,subModel.issue];
                            NSArray *arrays = [strongSelf.allOpenResultData filteredArrayUsingPredicate:predicate];
                            if(arrays.count>0){
                                continue;
                            }
                            [strongSelf.allOpenResultData addObject:subModel];
                        }
                        
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.openResultList reloadData];
                [strongSelf.openResultCollection reloadData];
               
            });
        }
        else{
            [strongSelf.openResultCollection reloadData];
           
//            [MBProgressHUD showError:YZMsg(@"public_networkError")];
            [strongSelf exitView];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.openResultCollection reloadData];
        
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf exitView];
    }];
}
-(void)rebackScrollView:(BOOL)isNeedHidden {
    if (self.lotteryDelegate!= nil && isShowTopList) {
        isShowTopList = NO;
        [self.lotteryDelegate refreshTableHeight:NO];
    }
    self.noView.hidden = YES;
    self.toolScrollView.contentSize = CGSizeMake(35*self.toolBtnArr.count + 10, 0);
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 0; i< self.toolBtnArr.count; i ++) {
            UIButton *livechatBtn = self.toolBtnArr[i];
            livechatBtn.frame = CGRectMake(5+i*(30+5),5,30,30);
        }
        //[self updateViewFrame];
        [self.view layoutIfNeeded]; // 重要：强制布局更新以触发动画
    } completion:^(BOOL finished) {
        if (isNeedHidden) {
            self.chartView.hidden = YES;
            self.betHistoryList.hidden = YES;
            self.openResultList.hidden = YES;
            self.noView.hidden = YES;
        }
    }];
}
- (void)clickHistoryBetAction:(BetListDataModel *)item {
    BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    betConfirmVC.isShowTopList = isShowTopList;
    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
        //        [self refreshCurrentChip];
        [betConfirmVC.view removeFromSuperview];
        [betConfirmVC removeFromParentViewController];
    }];
    __block NSDictionary *dict = nil;
    [ways enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *options = obj[@"options"];
        NSDictionary *option = [options vk_filter:@"title = %@", item.detail.way.firstObject].firstObject;
        if (option) {
            dict = obj;
            *stop = YES;
        }
    }];
    
    NSMutableArray *orders = [NSMutableArray array];
    NSArray *moneys = item.detail.money;
    [item.detail.way enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *order = [NSMutableDictionary dictionary];
        order[@"way"] = obj;
        order[@"money"] = moneys[idx];
        [orders addObject:order];
    }];
    
    NSDictionary *orderInfo = @{
        @"name":allData[@"name"],
        @"optionName":@"",
        @"optionNameSt":@"",
        @"lotteryType":[NSString stringWithFormat:@"%ld",curLotteryType],
        @"issue":curIssue,
        @"betLeftTime":[NSString stringWithFormat:@"%ld",betLeftTime],
        @"sealingTime":[NSString stringWithFormat:@"%ld",sealingTime],
        @"orders":orders,
    };
    
    [betConfirmVC setOrderInfo:orderInfo];
    WeakSelf
    __weak BetConfirmViewController * weakbetConfirmVC = betConfirmVC;
    betConfirmVC.betBlock = ^(NSInteger idx, NSUInteger num){
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf refreshLeftCoinLabel];
        if(strongSelf.selectedToolBtn.tag == 1001){
            strongSelf->betPage = 1;
            [strongSelf getBetInfo];
        }
        [common saveLastChipModel:strongSelf->selectedChipModel];
        //        [self refreshCurrentChip];
        [shadowView removeFromSuperview];
        [weakbetConfirmVC.view removeFromSuperview];
        [weakbetConfirmVC removeFromParentViewController];
        //        chipVC = nil;
    };
    [self.view addSubview:betConfirmVC.view];
    //    betConfirmVC.view.y = self.view.height - betConfirmVC.view.bottom;
    betConfirmVC.view.bottom = self.view.bottom;
    [self addChildViewController:betConfirmVC];
    return;
}
-(void)exitViewFromExchange{
    
    
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    voiceAwardMoney = nil;
    if (self.lotteryDelegate!= nil) {
        isExit = [self.lotteryDelegate cancelLuwu];
    }
    if(isExit) return;
    isExit = true;
    
    [self clearSelectBetView];
    [self canBetHidenLastBetSubView:YES isClearAll:true toView:nil];
    [self removeAllChip];
    
    [self.view layoutIfNeeded];
//    [self stopWobble];
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
       
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:@"lotterySecondNotify" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:@"LotteryOpenAward" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:KBetDoNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:strongSelf name:KBetWinAllUserNotificationMsg object:nil];
        if (strongSelf.lotteryDelegate!= nil) {
            [strongSelf.lotteryDelegate exchangeVersionToOld:strongSelf->curLotteryType];
        }
    }];
}
-(void)removeAllChip
{
    for (UIView *subV in self.contentView.subviews) {
        if (subV.tag>=2000 && subV.tag<=888888) {
            [subV removeFromSuperview];
        }
    }
}

@end
