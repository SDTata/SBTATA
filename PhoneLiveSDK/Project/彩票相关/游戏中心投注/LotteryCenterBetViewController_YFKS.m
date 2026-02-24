//
//  LotteryBetViewController.m
//
//

#import "LotteryCenterBetViewController_YFKS.h"
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
#import "ChipsModel.h"
#import "NSString+Extention.h"
#import "LotteryBetSubView1.h"
#import "socketLivePlay.h"
#import "LotteryAwardVController.h"
#import "hotModel.h"
#import "SwitchLotteryViewController.h"
#import "LotteryCenterMsgView.h"
#import "ChartView.h"
#import "VIMediaCache.h"
#import "BetListModel.h"
#import "LiveBetListYFKSCell.h"
#import "LiveOpenListYFKSCell.h"
#import "LotteryNNModel.h"

#import "LiveGifImage.h"
#define kChipChoiseCell @"ChipChoiseCell"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"

@interface LotteryCenterBetViewController_YFKS ()<socketDelegate>{
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
    YYAnimatedImageView *animationShaigu;
    BOOL isFinance;
    BOOL isOpenning;
    NSMutableDictionary *contiDic;
    NSString *issueContinueBet;
    BOOL isContinueBet;
    
    //飞向玩家筹码
    NSMutableArray *winUsersArray;
    
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

    NSMutableArray<ChipsModel*> *chipsArraysAll;
    ChipsModel *selectedChipModel;
    NSArray <NSDictionary *> *_titleSts;
    BOOL closeAnimationShaigu;
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
    BOOL isStop; //停止闪烁
    NSMutableArray * messageList;
    
    BOOL isShowTopList; //走势图等顶部视图是否显示

}
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@property(nonatomic,strong)NSMutableArray *allOpenResultData;

@property (nonatomic, strong) VIResourceLoaderManager *resourceLoaderManager;
@property(nonatomic,strong)SocketIOClient *ChatSocket;
@property (nonatomic, strong)NSMutableArray * lotteryShowArr;
@property (nonatomic, strong)LotteryCenterMsgView * msgView;

@property(nonatomic,strong)AVPlayer *avplayer;

@property(nonatomic,strong) CustomScrollView * toolScrollView;
@property(nonatomic,strong)UIButton * selectedToolBtn;
@property(nonatomic,strong)NSMutableArray * toolBtnArr;

@end

@implementation LotteryCenterBetViewController_YFKS

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    if (!isShow) {
        isShow = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpen:) name:@"LotteryOpenAward" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(betNotification:) name:KBetDoNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLotteryInfo:) name:@"lotteryInfoNotify" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWinInfo:) name:KBetWinNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGameResult) name:@"errorDisConnect" object:nil];
        [self buildData];
    }
    
}
-(void)updateGameResult
{
    if (isFinance) {
        [self buildData];
    }
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSArray *las = self.navigationController.viewControllers;
    if (las==nil) {
        [self releaseView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = curLotteryType == 26 ? @"一分快三" : @"三分快三";
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.lotteryShowArr = [NSMutableArray array];
    chartSubV = [ChartView instanceChatViewWithType:26];
    [self.chartView addSubview:chartSubV];
    
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_sum4_View,self.bet_sum5_View,self.bet_sum6_View,self.bet_sum7_View,self.bet_sum8_View,self.bet_sum9_View,self.bet_sum10_View,self.bet_sum11_View,self.bet_sum12_View,self.bet_sum13_View,self.bet_sum14_View,self.bet_sum15_View,self.bet_sum16_View,self.bet_sum17_View,self.bet_bao1_View,self.bet_bao2_View,self.bet_bao3_View,self.bet_baozi_View,self.bet_bao4_View,self.bet_bao5_View,self.bet_bao6_View,self.bet_dui1_View,self.bet_dui2_View,self.bet_dui3_View,self.bet_dui4_View,self.bet_dui5_View,self.bet_dui6_View,self.bet_dian1_View,self.bet_dian2_View,self.bet_dian3_View,self.bet_dian4_View,self.bet_dian5_View,self.bet_dian6_View];

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
    
    winUsersArray = [NSMutableArray array];
    messageList = [NSMutableArray array];
    contiDic = [NSMutableDictionary dictionary];
    self.continueBtn.enabled = false;
    _titleSts = [NSArray <NSDictionary *> array];

    [self.betChipCollectionView reloadData];
    [self closeShaiguBoxAnimation];
    standTickCount= 0;
//    [socketDelegate sendSyncLotteryCMD:@"26"];
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

- (void)buildData {
    NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getHomeBetViewInfo"];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES  andParameter:curLotteryType==10?@{@"lottery_type":[NSString stringWithFormat:@"%ld", curLotteryType],@"support_nn":@(1)}:@{@"lottery_type":[NSString stringWithFormat:@"%ld", curLotteryType]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"xxxxxxxxx%@",info);
        if (strongSelf->isExit) {
            return;
        }
        if(code == 0)
        {
            if (strongSelf->allData) {
                [strongSelf closeShaiguBoxAnimation];
            }
            strongSelf->allData = [info firstObject];
            [strongSelf addNodeServer:minstr(strongSelf->allData[@"lobbyServer"])];
            // 反向同步信息
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"lotteryRsync" object:nil userInfo:strongSelf->allData];
            NSDictionary *dict = strongSelf->allData[@"lastResult"];
            if(dict){
                strongSelf->last_open_result = dict[@"open_result"];
            }else{
                strongSelf->last_open_result = @"";
            }
            strongSelf->curIssue = strongSelf->allData[@"issue"];
            strongSelf->betLeftTime = [strongSelf->allData[@"time"] integerValue];
            strongSelf->sealingTime = [strongSelf->allData[@"sealingTim"] integerValue];
            NSString *musicUrl = strongSelf->allData[@"music"];
            if (musicUrl!= nil && musicUrl.length>1) {
                [strongSelf playerBgMusic:musicUrl];
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
        [socketDelegate addNodeListen:model isFirstConnect:YES serverUrl:serverUrl];
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
    self.openResultCollection.hidden = NO;
   
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
        [self.openResultCollection reloadData];
        if (chartSubV) {
            [chartSubV updateChartData:result];
        }
        NSArray *winways = notification.userInfo[@"winWays"];
        //关闭骰子动画显示结果
        [self closeAnimationAndShowResult:result winways:winways];
        
        ///下面是桌面赢方背景改变
        
        NSMutableArray *winViews = [NSMutableArray array];
        NSMutableArray *winChipsTags = [NSMutableArray array];
        NSMutableArray *dianViews = [NSMutableArray array];
        for (NSString *winName in winways) {
            UIImageView *imgV;
            if ([winName rangeOfString:@"总和_大"].location!=NSNotFound) {
                imgV = [self.bet_big_View viewWithTag:300];
                [winChipsTags addObject:@"20000"];
                [winViews addObject:self.bet_big_View];
            }else if ([winName rangeOfString:@"总和_小"].location!=NSNotFound){
                imgV = [self.bet_small_View viewWithTag:300];
                [winViews addObject:self.bet_small_View];
                [winChipsTags addObject:@"20001"];
            }else if ([winName rangeOfString:@"总和_单"].location!=NSNotFound){
                imgV = [self.bet_single_View viewWithTag:300];
                [winViews addObject:self.bet_single_View];
                [winChipsTags addObject:@"20002"];
            }else if ([winName rangeOfString:@"总和_双"].location!=NSNotFound){
                imgV = [self.bet_double_View viewWithTag:300];
                [winViews addObject:self.bet_double_View];
                [winChipsTags addObject:@"20003"];
            }else if ([winName rangeOfString:@"总和_4"].location!=NSNotFound){
                imgV = [self.bet_sum4_View viewWithTag:300];
                [winViews addObject:self.bet_sum4_View];
                [winChipsTags addObject:@"20004"];
            }else if ([winName rangeOfString:@"总和_5"].location!=NSNotFound){
                imgV = [self.bet_sum5_View viewWithTag:300];
                [winViews addObject:self.bet_sum5_View];
                [winChipsTags addObject:@"20005"];
            }else if ([winName rangeOfString:@"总和_6"].location!=NSNotFound){
                imgV = [self.bet_sum6_View viewWithTag:300];
                [winViews addObject:self.bet_sum6_View];
                [winChipsTags addObject:@"20006"];
            }else if ([winName rangeOfString:@"总和_7"].location!=NSNotFound){
                imgV = [self.bet_sum7_View viewWithTag:300];
                [winViews addObject:self.bet_sum7_View];
                [winChipsTags addObject:@"20007"];
            }else if ([winName rangeOfString:@"总和_8"].location!=NSNotFound){
                imgV = [self.bet_sum8_View viewWithTag:300];
                [winViews addObject:self.bet_sum8_View];
                [winChipsTags addObject:@"20008"];
            }else if ([winName rangeOfString:@"总和_9"].location!=NSNotFound){
                imgV = [self.bet_sum9_View viewWithTag:300];
                [winViews addObject:self.bet_sum9_View];
                [winChipsTags addObject:@"20009"];
            }else if ([winName rangeOfString:@"总和_10"].location!=NSNotFound){
                imgV = [self.bet_sum10_View viewWithTag:300];
                [winViews addObject:self.bet_sum10_View];
                [winChipsTags addObject:@"20010"];
            }else if ([winName rangeOfString:@"总和_11"].location!=NSNotFound){
                imgV = [self.bet_sum11_View viewWithTag:300];
                [winViews addObject:self.bet_sum11_View];
                [winChipsTags addObject:@"20011"];
            }else if ([winName rangeOfString:@"总和_12"].location!=NSNotFound){
                imgV = [self.bet_sum12_View viewWithTag:300];
                [winViews addObject:self.bet_sum12_View];
                [winChipsTags addObject:@"20012"];
            }else if ([winName rangeOfString:@"总和_13"].location!=NSNotFound){
                imgV = [self.bet_sum13_View viewWithTag:300];
                [winViews addObject:self.bet_sum13_View];
                [winChipsTags addObject:@"20013"];
            }else if ([winName rangeOfString:@"总和_14"].location!=NSNotFound){
                imgV = [self.bet_sum14_View viewWithTag:300];
                [winViews addObject:self.bet_sum14_View];
                [winChipsTags addObject:@"20014"];
            }else if ([winName rangeOfString:@"总和_15"].location!=NSNotFound){
                imgV = [self.bet_sum15_View viewWithTag:300];
                [winViews addObject:self.bet_sum15_View];
                [winChipsTags addObject:@"20015"];
            }else if ([winName rangeOfString:@"总和_16"].location!=NSNotFound){
                imgV = [self.bet_sum16_View viewWithTag:300];
                [winViews addObject:self.bet_sum16_View];
                [winChipsTags addObject:@"20016"];
            }else if ([winName rangeOfString:@"总和_17"].location!=NSNotFound){
                imgV = [self.bet_sum17_View viewWithTag:300];
                [winViews addObject:self.bet_sum17_View];
                [winChipsTags addObject:@"20017"];
            }else if ([winName rangeOfString:@"豹子_1"].location!=NSNotFound){
                imgV = [self.bet_bao1_View viewWithTag:300];
                [winViews addObject:self.bet_bao1_View];
                [winChipsTags addObject:@"20018"];
            }else if ([winName rangeOfString:@"豹子_2"].location!=NSNotFound){
                imgV = [self.bet_bao2_View viewWithTag:300];
                [winViews addObject:self.bet_bao2_View];
                [winChipsTags addObject:@"20019"];
            }else if ([winName rangeOfString:@"豹子_3"].location!=NSNotFound){
                imgV = [self.bet_bao3_View viewWithTag:300];
                [winViews addObject:self.bet_bao3_View];
                [winChipsTags addObject:@"20020"];
            }else if ([winName rangeOfString:@"豹子_1-6"].location!=NSNotFound){
                imgV = [self.bet_baozi_View viewWithTag:300];
                [winViews addObject:self.bet_baozi_View];
                [winChipsTags addObject:@"20021"];
            }else if ([winName rangeOfString:@"豹子_4"].location!=NSNotFound){
                imgV = [self.bet_bao4_View viewWithTag:300];
                [winViews addObject:self.bet_bao4_View];
                [winChipsTags addObject:@"20022"];
            }else if ([winName rangeOfString:@"豹子_5"].location!=NSNotFound){
                imgV = [self.bet_bao5_View viewWithTag:300];
                [winViews addObject:self.bet_bao5_View];
                [winChipsTags addObject:@"20023"];
            }else if ([winName rangeOfString:@"豹子_6"].location!=NSNotFound){
                imgV = [self.bet_bao6_View viewWithTag:300];
                [winViews addObject:self.bet_bao6_View];
                [winChipsTags addObject:@"20024"];
            }else if ([winName rangeOfString:@"对子_1"].location!=NSNotFound){
                imgV = [self.bet_dui1_View viewWithTag:300];
                [winViews addObject:self.bet_dui1_View];
                [winChipsTags addObject:@"20025"];
            }else if ([winName rangeOfString:@"对子_2"].location!=NSNotFound){
                imgV = [self.bet_dui2_View viewWithTag:300];
                [winViews addObject:self.bet_dui2_View];
                [winChipsTags addObject:@"20026"];
            }else if ([winName rangeOfString:@"对子_3"].location!=NSNotFound){
                imgV = [self.bet_dui3_View viewWithTag:300];
                [winViews addObject:self.bet_dui3_View];
                [winChipsTags addObject:@"20027"];
            }else if ([winName rangeOfString:@"对子_4"].location!=NSNotFound){
                imgV = [self.bet_dui4_View viewWithTag:300];
                [winViews addObject:self.bet_dui4_View];
                [winChipsTags addObject:@"20028"];
            }else if ([winName rangeOfString:@"对子_5"].location!=NSNotFound){
                imgV = [self.bet_dui5_View viewWithTag:300];
                [winViews addObject:self.bet_dui5_View];
                [winChipsTags addObject:@"20029"];
            }else if ([winName rangeOfString:@"对子_6"].location!=NSNotFound){
                imgV = [self.bet_dui6_View viewWithTag:300];
                [winViews addObject:self.bet_dui6_View];
                [winChipsTags addObject:@"20030"];
            }else if ([winName rangeOfString:@"单骰_1"].location!=NSNotFound){
                BOOL isbool = [dianViews containsObject: self.bet_dian1_View];
                if(!isbool){
                    imgV = [self.bet_dian1_View viewWithTag:300];
                    [winViews addObject:self.bet_dian1_View];
                    [dianViews addObject:self.bet_dian1_View];
                    [winChipsTags addObject:@"20031"];
                }
            }else if ([winName rangeOfString:@"单骰_2"].location!=NSNotFound){
                BOOL isbool = [dianViews containsObject: self.bet_dian2_View];
                if(!isbool){
                    imgV = [self.bet_dian2_View viewWithTag:300];
                    [winViews addObject:self.bet_dian2_View];
                    [dianViews addObject:self.bet_dian2_View];
                    [winChipsTags addObject:@"20032"];
                }
            }else if ([winName rangeOfString:@"单骰_3"].location!=NSNotFound){
                BOOL isbool = [dianViews containsObject: self.bet_dian3_View];
                if(!isbool){
                    imgV = [self.bet_dian3_View viewWithTag:300];
                    [winViews addObject:self.bet_dian3_View];
                    [dianViews addObject:self.bet_dian3_View];
                    [winChipsTags addObject:@"20033"];
                }
            }else if ([winName rangeOfString:@"单骰_4"].location!=NSNotFound){
                BOOL isbool = [dianViews containsObject: self.bet_dian4_View];
                if(!isbool){
                    imgV = [self.bet_dian4_View viewWithTag:300];
                    [winViews addObject:self.bet_dian4_View];
                    [dianViews addObject:self.bet_dian4_View];
                    [winChipsTags addObject:@"20034"];
                }
            }else if ([winName rangeOfString:@"单骰_5"].location!=NSNotFound){
                BOOL isbool = [dianViews containsObject: self.bet_dian5_View];
                if(!isbool){
                    imgV = [self.bet_dian5_View viewWithTag:300];
                    [winViews addObject:self.bet_dian5_View];
                    [dianViews addObject:self.bet_dian5_View];
                    [winChipsTags addObject:@"20035"];
                }
            }else if ([winName rangeOfString:@"单骰_6"].location!=NSNotFound){
                BOOL isbool = [dianViews containsObject: self.bet_dian6_View];
                if(!isbool){
                    imgV = [self.bet_dian6_View viewWithTag:300];
                    [winViews addObject:self.bet_dian6_View];
                    [dianViews addObject:self.bet_dian6_View];
                    [winChipsTags addObject:@"20036"];
                }
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
                sub.center = CGPointMake(SCREEN_WIDTH/2, 0);
            }
        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf==nil ||strongSelf->isExit) {
                return;
            }
            if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"shoufamaaudio.mp3"].location == NSNotFound)) {
                NSURL *url=[[XBundle currentXibBundleWithResourceName:@""]URLForResource:@"shoufamaaudio.mp3" withExtension:Nil];
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
                NSURL *url=[[XBundle currentXibBundleWithResourceName:@""] URLForResource:@"shoufamaaudio.mp3" withExtension:Nil];
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
                    sub.center = CGPointMake(0, strongSelf.betBgView.height -11);
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
        
        
        ///
        [self closeAndReadyToBegain];
        
        [self clearChipsNumber];
    }
}

-(void)animationDeskOld:(NSArray *)arr
{
    UIImage * oldImg = arr[0];
    UIImage * img = arr[1];
    UIImageView * imgV = arr[2];
    if ([imgV.image isEqual:oldImg]) {
        imgV.image= img;
    }else{
        imgV.image= oldImg;
    }
    if (self == nil|| isExit || isStop == false) {
        imgV.image= oldImg;
    }else{
        [self performSelector:@selector(animationDeskOld:) withObject:arr  afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
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

}

-(void)closeAndReadyToBegain
{
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->closeAnimationShaigu = NO;
        [strongSelf closeShaiguBoxAnimation];
        NSMutableArray<UIView*> *arraybgs = [NSMutableArray array];
        if (strongSelf.bet_big_View) [arraybgs addObject:strongSelf.bet_big_View];
        if (strongSelf.bet_small_View) [arraybgs addObject:strongSelf.bet_small_View];
        if (strongSelf.bet_single_View) [arraybgs addObject:strongSelf.bet_single_View];
        if (strongSelf.bet_double_View) [arraybgs addObject:strongSelf.bet_double_View];
        if (strongSelf.bet_sum4_View) [arraybgs addObject:strongSelf.bet_sum4_View];
        if (strongSelf.bet_sum5_View) [arraybgs addObject:strongSelf.bet_sum5_View];
        if (strongSelf.bet_sum6_View) [arraybgs addObject:strongSelf.bet_sum6_View];
        if (strongSelf.bet_sum7_View) [arraybgs addObject:strongSelf.bet_sum7_View];
        if (strongSelf.bet_sum8_View) [arraybgs addObject:strongSelf.bet_sum8_View];
        if (strongSelf.bet_sum9_View) [arraybgs addObject:strongSelf.bet_sum9_View];
        if (strongSelf.bet_sum10_View) [arraybgs addObject:strongSelf.bet_sum10_View];
        if (strongSelf.bet_sum11_View) [arraybgs addObject:strongSelf.bet_sum11_View];
        if (strongSelf.bet_sum12_View) [arraybgs addObject:strongSelf.bet_sum12_View];
        if (strongSelf.bet_sum13_View) [arraybgs addObject:strongSelf.bet_sum13_View];
        if (strongSelf.bet_sum14_View) [arraybgs addObject:strongSelf.bet_sum14_View];
        if (strongSelf.bet_sum15_View) [arraybgs addObject:strongSelf.bet_sum15_View];
        if (strongSelf.bet_sum16_View) [arraybgs addObject:strongSelf.bet_sum16_View];
        if (strongSelf.bet_sum17_View) [arraybgs addObject:strongSelf.bet_sum17_View];
        if (strongSelf.bet_bao1_View) [arraybgs addObject:strongSelf.bet_bao1_View];
        if (strongSelf.bet_bao2_View) [arraybgs addObject:strongSelf.bet_bao2_View];
        if (strongSelf.bet_bao3_View) [arraybgs addObject:strongSelf.bet_bao3_View];
        if (strongSelf.bet_baozi_View) [arraybgs addObject:strongSelf.bet_baozi_View];
        if (strongSelf.bet_bao4_View) [arraybgs addObject:strongSelf.bet_bao4_View];
        if (strongSelf.bet_bao5_View) [arraybgs addObject:strongSelf.bet_bao5_View];
        if (strongSelf.bet_bao6_View) [arraybgs addObject:strongSelf.bet_bao6_View];
        if (strongSelf.bet_dui1_View) [arraybgs addObject:strongSelf.bet_dui1_View];
        if (strongSelf.bet_dui2_View) [arraybgs addObject:strongSelf.bet_dui2_View];
        if (strongSelf.bet_dui3_View) [arraybgs addObject:strongSelf.bet_dui3_View];
        if (strongSelf.bet_dui4_View) [arraybgs addObject:strongSelf.bet_dui4_View];
        if (strongSelf.bet_dui5_View) [arraybgs addObject:strongSelf.bet_dui5_View];
        if (strongSelf.bet_dui6_View) [arraybgs addObject:strongSelf.bet_dui6_View];
        if (strongSelf.bet_dian1_View) [arraybgs addObject:strongSelf.bet_dian1_View];
        if (strongSelf.bet_dian2_View) [arraybgs addObject:strongSelf.bet_dian2_View];
        if (strongSelf.bet_dian3_View) [arraybgs addObject:strongSelf.bet_dian3_View];
        if (strongSelf.bet_dian4_View) [arraybgs addObject:strongSelf.bet_dian4_View];
        if (strongSelf.bet_dian5_View) [arraybgs addObject:strongSelf.bet_dian5_View];
        if (strongSelf.bet_dian6_View) [arraybgs addObject:strongSelf.bet_dian6_View];
        for (UIView *viewSub in arraybgs) {
            if (viewSub == strongSelf.bet_big_View || viewSub == strongSelf.bet_small_View || viewSub == strongSelf.bet_single_View|| viewSub == strongSelf.bet_double_View) {
                UIImageView *imgV = [viewSub viewWithTag:300];
                imgV.image = [ImageBundle imagewithBundleName:@"yfks_betbg1"];
            }else if (viewSub == strongSelf.bet_sum4_View || viewSub == strongSelf.bet_sum5_View || viewSub == strongSelf.bet_sum6_View|| viewSub == strongSelf.bet_sum7_View|| viewSub == strongSelf.bet_sum8_View || viewSub == strongSelf.bet_sum9_View|| viewSub == strongSelf.bet_sum10_View|| viewSub == strongSelf.bet_sum11_View || viewSub == strongSelf.bet_sum12_View|| viewSub == strongSelf.bet_sum13_View|| viewSub == strongSelf.bet_sum14_View || viewSub == strongSelf.bet_sum15_View|| viewSub == strongSelf.bet_sum16_View|| viewSub == strongSelf.bet_sum17_View ){
                UIImageView *imgV = [viewSub viewWithTag:300];
                imgV.image = [ImageBundle imagewithBundleName:@"yfks_betbg2"];
            }else if (viewSub == strongSelf.bet_bao1_View || viewSub == strongSelf.bet_bao2_View || viewSub == strongSelf.bet_bao3_View|| viewSub == strongSelf.bet_bao4_View|| viewSub == strongSelf.bet_bao5_View|| viewSub == strongSelf.bet_baozi_View|| viewSub == strongSelf.bet_bao6_View){
                UIImageView *imgV = [viewSub viewWithTag:300];
                imgV.image = [ImageBundle imagewithBundleName:@"yfks_betbg3"];
            }else if (viewSub == strongSelf.bet_dui1_View || viewSub == strongSelf.bet_dui2_View || viewSub == strongSelf.bet_dui3_View|| viewSub == strongSelf.bet_dui4_View|| viewSub == strongSelf.bet_dui5_View|| viewSub == strongSelf.bet_dui6_View){
                UIImageView *imgV = [viewSub viewWithTag:300];
                imgV.image = [ImageBundle imagewithBundleName:@"yfks_betbg4"];
            }else if (viewSub == strongSelf.bet_dian1_View || viewSub == strongSelf.bet_dian2_View || viewSub == strongSelf.bet_dian3_View|| viewSub == strongSelf.bet_dian4_View|| viewSub == strongSelf.bet_dian5_View|| viewSub == strongSelf.bet_dian6_View){
                UIImageView *imgV = [viewSub viewWithTag:300];
                imgV.image = [ImageBundle imagewithBundleName:@"yfks_betbg5"];
            }
            UILabel *betAllLabel = [viewSub viewWithTag:101];
            strongSelf->isStop = NO;
//          UILabel *betMineLabel = [viewSub viewWithTag:101];
            if (betAllLabel) {
                betAllLabel.text=@"0";
            }
            //            if (betMineLabel) {
            //                betMineLabel.text = @"0";
            //            }
            BetBubbleView *bubble = [viewSub viewWithTag:1010];
            if (viewSub == strongSelf.bet_big_View) {
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 0) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_small_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 1) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_single_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 2) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_double_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 3) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_bao1_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 4) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_bao6_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 5) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }
        }
        
        ///显示即将开始
        UIView *willReadyView = [[UIView alloc]initWithFrame:CGRectMake(40, 0,SCREEN_WIDTH-80, 73)];
        willReadyView.tag = 2100;
        willReadyView.layer.zPosition = 21;
        [strongSelf.contentView addSubview:willReadyView];
        willReadyView.center = CGPointMake(SCREEN_WIDTH/2, (336+ShowDiff)/2.0);
        
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
    //清空top赢家
    if (winUsersArray.count>0) {
        [winUsersArray removeAllObjects];
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
        UIView *fromView = self.bet_dian3_View;
        for (int i = 0; i<arrWays.count; i++) {
            NSString *keyContinue = @"";
            NSString *subWay = arrWays[i];
            NSString *subMoney = arrMoney[i];
            
            if ([subWay rangeOfString:@"总和_大"].location!=NSNotFound) {
                keyContinue = @"1";
                [self animationFrom:fromView toView:self.bet_big_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20000 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_小"].location!=NSNotFound){
                keyContinue = @"2";
                [self animationFrom:fromView toView:self.bet_small_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20001 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_单"].location!=NSNotFound){
                keyContinue = @"3";
                [self animationFrom:fromView toView:self.bet_single_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20002 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_双"].location!=NSNotFound){
                keyContinue = @"4";
                [self animationFrom:fromView toView:self.bet_double_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20003 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_4"].location!=NSNotFound){
                keyContinue = @"5";
                [self animationFrom:fromView toView:self.bet_sum4_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20004 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_5"].location!=NSNotFound){
                keyContinue = @"6";
                [self animationFrom:fromView toView:self.bet_sum5_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20005 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_6"].location!=NSNotFound){
                keyContinue = @"7";
                [self animationFrom:fromView toView:self.bet_sum6_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20006 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_7"].location!=NSNotFound){
                keyContinue = @"8";
                [self animationFrom:fromView toView:self.bet_sum7_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20007 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_8"].location!=NSNotFound){
                keyContinue = @"9";
                [self animationFrom:fromView toView:self.bet_sum8_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20008 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_9"].location!=NSNotFound){
                keyContinue = @"10";
                [self animationFrom:fromView toView:self.bet_sum9_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20009 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_10"].location!=NSNotFound){
                keyContinue = @"11";
                [self animationFrom:fromView toView:self.bet_sum10_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20010 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_11"].location!=NSNotFound){
                keyContinue = @"12";
                [self animationFrom:fromView toView:self.bet_sum11_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20011 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_12"].location!=NSNotFound){
                keyContinue = @"13";
                [self animationFrom:fromView toView:self.bet_sum12_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20012 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_13"].location!=NSNotFound){
                keyContinue = @"14";
                [self animationFrom:fromView toView:self.bet_sum13_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20013 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_14"].location!=NSNotFound){
                keyContinue = @"15";
                [self animationFrom:fromView toView:self.bet_sum14_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20014 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_15"].location!=NSNotFound){
                keyContinue = @"16";
                [self animationFrom:fromView toView:self.bet_sum15_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20015 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_16"].location!=NSNotFound){
                keyContinue = @"17";
                [self animationFrom:fromView toView:self.bet_sum16_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20016 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"总和_17"].location!=NSNotFound){
                keyContinue = @"18";
                [self animationFrom:fromView toView:self.bet_sum17_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20017 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_1"].location!=NSNotFound){
                keyContinue = @"19";
                [self animationFrom:fromView toView:self.bet_bao1_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20018 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_2"].location!=NSNotFound){
                keyContinue = @"20";
                [self animationFrom:fromView toView:self.bet_bao2_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20019 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_3"].location!=NSNotFound){
                keyContinue = @"21";
                [self animationFrom:fromView toView:self.bet_bao3_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20020 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_1-6"].location!=NSNotFound){
                keyContinue = @"22";
                [self animationFrom:fromView toView:self.bet_baozi_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20021 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_4"].location!=NSNotFound){
                keyContinue = @"23";
                [self animationFrom:fromView toView:self.bet_bao4_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20022 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_5"].location!=NSNotFound){
                keyContinue = @"24";
                [self animationFrom:fromView toView:self.bet_bao5_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20023 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"豹子_6"].location!=NSNotFound){
                keyContinue = @"25";
                [self animationFrom:fromView toView:self.bet_bao6_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20024 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"对子_1"].location!=NSNotFound){
                keyContinue = @"26";
                [self animationFrom:fromView toView:self.bet_dui1_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20025 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"对子_2"].location!=NSNotFound){
                keyContinue = @"27";
                [self animationFrom:fromView toView:self.bet_dui2_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20026 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"对子_3"].location!=NSNotFound){
                keyContinue = @"28";
                [self animationFrom:fromView toView:self.bet_dui3_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20027 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"对子_4"].location!=NSNotFound){
                keyContinue = @"29";
                [self animationFrom:fromView toView:self.bet_dui4_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20028 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"对子_5"].location!=NSNotFound){
                keyContinue = @"30";
                [self animationFrom:fromView toView:self.bet_dui5_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20029 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"对子_6"].location!=NSNotFound){
                keyContinue = @"31";
                [self animationFrom:fromView toView:self.bet_dui6_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20030 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"单骰_1"].location!=NSNotFound){
                keyContinue = @"32";
                [self animationFrom:fromView toView:self.bet_dian1_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20031 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"单骰_2"].location!=NSNotFound){
                keyContinue = @"33";
                [self animationFrom:fromView toView:self.bet_dian2_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20032 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"单骰_3"].location!=NSNotFound){
                keyContinue = @"34";
                [self animationFrom:fromView toView:self.bet_dian3_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20033 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"单骰_4"].location!=NSNotFound){
                keyContinue = @"35";
                [self animationFrom:fromView toView:self.bet_dian4_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20034 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"单骰_5"].location!=NSNotFound){
                keyContinue = @"36";
                [self animationFrom:fromView toView:self.bet_dian5_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20035 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay rangeOfString:@"单骰_6"].location!=NSNotFound){
                keyContinue = @"37";
                [self animationFrom:fromView toView:self.bet_dian6_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20036 moneyNum:subMoney] uid:betModel.msg.uid];
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
        chipImgV.center = CGPointMake(SCREEN_WIDTH/2,self.betBgView.height);
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
                NSURL *url=[[XBundle currentXibBundleWithResourceName:@""]URLForResource:@"jiafamaaudio.mp3" withExtension:Nil];
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

//刷新时间进程
-(void)refreshTimeUI{
    if(betLeftTime > sealingTime){
        //倒计时中 倒计时动画
        int seconds = (betLeftTime-sealingTime) % 60;
        if(curLotteryType == 27){
            seconds = (int)(betLeftTime-sealingTime);
        }

        if (!isFinance) {
    
            [self closeShaiguBoxAnimation];
            
            ///显示即将开始
            UIView *willReadyView = [self.contentView viewWithTag:2200];
            if (!willReadyView) {
                willReadyView = [[UIView alloc]initWithFrame:CGRectMake(70, 0,SCREEN_WIDTH-140, 73)];
                willReadyView.tag = 2200;
                willReadyView.layer.zPosition = 15;
                [self.contentView addSubview:willReadyView];
                willReadyView.center = CGPointMake(SCREEN_WIDTH/2, 100);
                
                UIImageView *imgVReadybg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-140, 73)];
                imgVReadybg.image = [ImageBundle imagewithBundleName:@"gamecenter_will_begain"];
                [willReadyView addSubview:imgVReadybg];
                
                UILabel *labelTip = [[UILabel alloc]initWithFrame: CGRectMake((SCREEN_WIDTH/2)-200, 10, 160, 53)];
                labelTip.textColor = RGB(248, 210, 147);
                labelTip.textAlignment = NSTextAlignmentRight;
                labelTip.text = YZMsg(@"game_begain");
                labelTip.font = [UIFont boldSystemFontOfSize:20];
                [willReadyView addSubview:labelTip];
                
                UIButton *buttonick = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonick.tag = 100;
                buttonick.frame =  CGRectMake(labelTip.right+10, 19, 40, 46);
                [buttonick setBackgroundImage:[ImageBundle imagewithBundleName:@"gamecenter_secondimg"] forState:UIControlStateNormal];
                [buttonick setTitleColor:RGB(248, 210, 147) forState:UIControlStateNormal];
                buttonick.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                [buttonick setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
                [willReadyView addSubview:buttonick];
            }
            UIButton *buttonick = [willReadyView viewWithTag:100];
            if (buttonick) {
                [buttonick setTitle:minnum(seconds) forState:UIControlStateNormal];
            }
            if (seconds<5) {
                [buttonick shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
                }];
            }
        }
    }else{
        //封盘中 可以开始摇骰子动画
        [self begainAnimationShaigu];
    }
}

-(void)closeShaiguBoxAnimation
{
    UIView *ResultShowView = [self.contentView viewWithTag:2500];
    if (ResultShowView) {
        [ResultShowView removeFromSuperview];
    }
    begainAnimationShaigu = NO;
    if (!closeAnimationShaigu) {
        closeAnimationShaigu = YES;
        UIImageView *gaiziImg = [self.shaiguImgView viewWithTag:1200];
        if (!gaiziImg) {
            gaiziImg = [[UIImageView alloc] initWithFrame:CGRectMake(2, -32, 97, 77)];
            gaiziImg.image = [ImageBundle imagewithBundleName:@"yfks_gaizi"];
            gaiziImg.tag = 1200;
            gaiziImg.alpha = 0;
            [self.shaiguImgView addSubview:gaiziImg];
        }
        [self.shaiguImgView bringSubviewToFront:gaiziImg];
        WeakSelf
        [UIView animateWithDuration:0.5 animations:^{
            gaiziImg.frame = CGRectMake(9, -1, 74, 72);
            gaiziImg.alpha = 1;
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
///打开盖子摇骰子
static BOOL begainAnimationShaigu;
-(void)begainAnimationShaigu
{
    if (!begainAnimationShaigu) {
        //移除未下注的
        NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_sum4_View,self.bet_sum5_View,self.bet_sum6_View,self.bet_sum7_View,self.bet_sum8_View,self.bet_sum9_View,self.bet_sum10_View,self.bet_sum11_View,self.bet_sum12_View,self.bet_sum13_View,self.bet_sum14_View,self.bet_sum15_View,self.bet_sum16_View,self.bet_sum17_View,self.bet_bao1_View,self.bet_bao2_View,self.bet_bao3_View,self.bet_baozi_View,self.bet_bao4_View,self.bet_bao5_View,self.bet_bao6_View,self.bet_dui1_View,self.bet_dui2_View,self.bet_dui3_View,self.bet_dui4_View,self.bet_dui5_View,self.bet_dui6_View,self.bet_dian1_View,self.bet_dian2_View,self.bet_dian3_View,self.bet_dian4_View,self.bet_dian5_View,self.bet_dian6_View];
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
        
        UIImageView *gaiziImg = [self.shaiguImgView viewWithTag:1200];
        if (!gaiziImg) {
            gaiziImg = [[UIImageView alloc] initWithFrame:CGRectMake(7, 4, 74, 70)];
            gaiziImg.image = [ImageBundle imagewithBundleName:@"yfks_gaizi"];
            gaiziImg.tag = 1200;
            [self.shaiguImgView addSubview:gaiziImg];
        }
        gaiziImg.alpha = 1;
        gaiziImg.frame = CGRectMake(7, 4, 74, 70);
        WeakSelf
        [UIView animateWithDuration:0.5 animations:^{
            gaiziImg.frame = CGRectMake(0, -30, 97, 77);
            gaiziImg.alpha = 0;
        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil||strongSelf->isExit) {
                return;
            }
            //摇骰子
            if (strongSelf->animationShaigu == nil) {
                NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"shaizi_animation" ofType:@"gif"];
                LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
                [imgAnima setAnimatedImageLoopCount:0];
                strongSelf->animationShaigu = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(8, 2, 75, 73)];
                strongSelf->animationShaigu.image = imgAnima;
                [strongSelf.shaiguImgView addSubview:strongSelf->animationShaigu];
            }else{
                strongSelf->animationShaigu.hidden = NO;
                [strongSelf->animationShaigu startAnimating];
            }
            if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"yaoshaiziaudio.mp3"].location == NSNotFound)) {
                NSURL *url=[[XBundle currentXibBundleWithResourceName:@""]URLForResource:@"yaoshaiziaudio.mp3" withExtension:Nil];
                strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
                strongSelf->voiceAwardMoney.numberOfLoops = 10;
                if ([common soundControlValue] == 2) {
                    [strongSelf->voiceAwardMoney setVolume:0];
                }else{
                    [strongSelf->voiceAwardMoney setVolume:1];
                }
            }
            [strongSelf->voiceAwardMoney prepareToPlay];
            [strongSelf->voiceAwardMoney play];
        
        }];
    }
}

//关闭骰子动画，显示结果
-(void)closeAnimationAndShowResult:(NSString*)result winways:(NSArray*)winways
{
    if (isExit) {
        return;
    }
    [animationShaigu stopAnimating];
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    animationShaigu.hidden = YES;
    UIView *resultView = [[UIView alloc]initWithFrame:CGRectMake(5, 2,75,73)];
    resultView.tag = 1300;
    [self.shaiguImgView addSubview:resultView];
    NSArray *arrayResult = [result componentsSeparatedByString:@","];
    UIImageView *img1 = [[UIImageView alloc]initWithFrame:CGRectMake(24, 18, 18, 18)];
    img1.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"shaizi_result_%@",arrayResult[0]]];
    UIImageView *img2 = [[UIImageView alloc]initWithFrame:CGRectMake(42, 18, 18, 18)];
    img2.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"shaizi_result_%@",arrayResult[1]]];
    UIImageView *img3 = [[UIImageView alloc]initWithFrame:CGRectMake(35, 28, 18, 18)];
    img3.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"shaizi_result_%@",arrayResult[2]]];
    
    [resultView addSubview:img1];
    [resultView addSubview:img2];
    [resultView addSubview:img3];
    
    if (!voiceAwardMoney||(voiceAwardMoney &&  [voiceAwardMoney.url.path rangeOfString:@"opengameresultaudio.mp3"].location == NSNotFound)) {
        NSURL *url=[[XBundle currentXibBundleWithResourceName:@""]URLForResource:@"opengameresultaudio.mp3" withExtension:Nil];
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
    UIView *resultPopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,195, 74)];
    resultPopView.tag = 2500;
    resultPopView.layer.zPosition = 21;
    [self.contentView addSubview:resultPopView];
    resultPopView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_WIDTH-100)/2);
    
    UIImageView *imgresultPop = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 195, 74)];
    imgresultPop.image = [ImageBundle imagewithBundleName:@"game_kaijiang"];
    [resultPopView addSubview:imgresultPop];
    
    UILabel *labelTip = [[UILabel alloc]initWithFrame: CGRectMake(0, 8, 195, 26)];
    labelTip.textColor = [UIColor redColor];
    labelTip.textAlignment = NSTextAlignmentCenter;
    NSInteger maxCount = ways.count;
    NSString *winStr = @"";
    for (int i=0; i<maxCount; i++) {
        // 取信息
        NSDictionary *wayInfo = [ways objectAtIndex:i];
        NSString *name = wayInfo[@"name"];
        NSArray *options = wayInfo[@"options"];
        if (name&&[name isEqualToString:@"猜大小"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                if ([winways containsObject:title]) {
                    winStr = [NSString stringWithFormat:@"%@ %@",winStr,titleSt];
                }
            }
        }else if (name && [name isEqualToString:@"猜总和"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                if ([winways containsObject:title]) {
                    winStr = [NSString stringWithFormat:@"%@ %@",winStr,titleSt];
                }
            }
        }else if (name && [name isEqualToString:@"猜豹子"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                if ([winways containsObject:title]) {
                    winStr = [NSString stringWithFormat:@"%@ %@",winStr,titleSt];
                }
            }
        }else if (name && [name isEqualToString:@"猜单骰"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                if ([winways containsObject:title]) {
                    winStr = [NSString stringWithFormat:@"%@ %@",winStr,titleSt];
                }
            }
        }else if (name && [name isEqualToString:@"猜对子"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                if ([winways containsObject:title]) {
                    winStr = [NSString stringWithFormat:@"%@ %@",winStr,titleSt];
                }
            }
        }
    }
    labelTip.text = winStr;
    labelTip.font = [UIFont boldSystemFontOfSize:16];
    [resultPopView addSubview:labelTip];
    
    UIImageView *imgResult1 = [[UIImageView alloc]initWithFrame:CGRectMake(35, labelTip.bottom+2, 22, 22)];
    imgResult1.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@",arrayResult[0]]];
    UIImageView *imgResult2 = [[UIImageView alloc]initWithFrame:CGRectMake(65, labelTip.bottom+2, 22, 22)];
    imgResult2.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@",arrayResult[1]]];
    UIImageView *imgResult3 = [[UIImageView alloc]initWithFrame:CGRectMake(94, labelTip.bottom+2, 22, 22)];
    imgResult3.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@",arrayResult[2]]];
    
    [resultPopView addSubview:imgResult1];
    [resultPopView addSubview:imgResult2];
    [resultPopView addSubview:imgResult3];
    
    
    UILabel *labelAll = [[UILabel alloc]initWithFrame: CGRectMake(imgResult3.right+10, labelTip.bottom, 30, 26)];
    labelAll.textColor = RGB(243, 231, 191);
    labelAll.font = [UIFont boldSystemFontOfSize:20];
    labelAll.textAlignment = NSTextAlignmentCenter;
    labelAll.text = [NSString stringWithFormat:@"%d",[arrayResult[0] intValue]+[arrayResult[1] intValue]+[arrayResult[2] intValue]];
    [resultPopView addSubview:labelAll];
    
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
    [self.continueBtn addTarget:self action:@selector(chipContinue) forControlEvents:UIControlEventTouchUpInside];
    [self.continueBtn setTitle:YZMsg(@"game_continue_bet") forState:UIControlStateNormal];
    self.continueBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.continueBtn.titleLabel.minimumScaleFactor = 0.5;
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
        NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_sum4_View,self.bet_sum5_View,self.bet_sum6_View,self.bet_sum7_View,self.bet_sum8_View,self.bet_sum9_View,self.bet_sum10_View,self.bet_sum11_View,self.bet_sum12_View,self.bet_sum13_View,self.bet_sum14_View,self.bet_sum15_View,self.bet_sum16_View,self.bet_sum17_View,self.bet_bao1_View,self.bet_bao2_View,self.bet_bao3_View,self.bet_baozi_View,self.bet_bao4_View,self.bet_bao5_View,self.bet_bao6_View,self.bet_dui1_View,self.bet_dui2_View,self.bet_dui3_View,self.bet_dui4_View,self.bet_dui5_View,self.bet_dui6_View,self.bet_dian1_View,self.bet_dian2_View,self.bet_dian3_View,self.bet_dian4_View,self.bet_dian5_View,self.bet_dian6_View];
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
-(void)setLotteryInfo:(NSDictionary *)msg{
    
}
//刷新桌面信息
-(void)initDeskInfo{
    NSInteger maxCount = ways.count;
    NSMutableArray <NSDictionary *> *titles = _titleSts.mutableCopy;
    NSString *titleMenueStr1 = @"";
    NSString *titleMenueStr2 = @"";
    for (int i=0; i<maxCount; i++) {
        // 取信息
        NSDictionary *wayInfo = [ways objectAtIndex:i];
        NSString *name = wayInfo[@"name"];
        NSArray *options = wayInfo[@"options"];
        if (name&&[name isEqualToString:@"猜总和"]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                NSString *value = [subWayDic objectForKey:@"value"];
                NSInteger betmine = [[subWayDic objectForKey:@"betmine"] integerValue];
                NSArray *betList = [subWayDic objectForKey:@"betlist"];
                UIView *toView = nil;
                NSInteger tagChipN = 0;
                if (title&&[title isEqualToString:@"总和_大"]) {
                    toView = self.bet_big_View;
                    tagChipN = 20000;
                    UILabel *titleLabel = [self.bet_big_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_big_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(0),@"title":titleSt}];
                    if (titleMenueStr1.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr1 = [titleMenueStr1 stringByAppendingString:@" "];
                    }
                    titleMenueStr1 = [titleMenueStr1 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"总和_小"]){
                    toView = self.bet_small_View;
                    tagChipN = 20001;
                    UILabel *titleLabel = [self.bet_small_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_small_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];

                    [titles addObject:@{@"idx":@(1),@"title":titleSt}];
                    if (titleMenueStr1.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr1 = [titleMenueStr1 stringByAppendingString:@" "];
                    }
                    titleMenueStr1 = [titleMenueStr1 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"总和_单"]){
                    toView = self.bet_single_View;
                    tagChipN = 20002;
                    UILabel *titleLabel = [self.bet_single_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_single_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(2),@"title":titleSt}];
                    if (titleMenueStr2.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr2 = [titleMenueStr2 stringByAppendingString:@" "];
                    }
                    titleMenueStr2 = [titleMenueStr2 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"总和_双"]){
                    toView = self.bet_double_View;
                    tagChipN = 20003;
                    UILabel *titleLabel = [self.bet_double_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_double_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(3),@"title":titleSt}];
                    if (titleMenueStr2.length>0 && [RookieTools isEmptyCharator]) {
                        titleMenueStr2 = [titleMenueStr2 stringByAppendingString:@" "];
                    }
                    titleMenueStr2 = [titleMenueStr2 stringByAppendingString:titleSt];
                }else if(title&&[title isEqualToString:@"总和_4"]){
                    toView = self.bet_sum4_View;
                    tagChipN = 20004;
                    UILabel *titleLabel = [self.bet_sum4_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum4_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(4),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_5"]){
                    toView = self.bet_sum5_View;
                    tagChipN = 20005;
                    UILabel *titleLabel = [self.bet_sum5_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum5_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(5),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_6"]){
                    toView = self.bet_sum6_View;
                    tagChipN = 20006;
                    UILabel *titleLabel = [self.bet_sum6_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum6_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(6),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_7"]){
                    toView = self.bet_sum7_View;
                    tagChipN = 20007;
                    UILabel *titleLabel = [self.bet_sum7_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum7_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(7),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_8"]){
                    toView = self.bet_sum8_View;
                    tagChipN = 20008;
                    UILabel *titleLabel = [self.bet_sum8_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum8_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(8),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_9"]){
                    toView = self.bet_sum9_View;
                    tagChipN = 20009;
                    UILabel *titleLabel = [self.bet_sum9_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum9_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(9),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_10"]){
                    toView = self.bet_sum10_View;
                    tagChipN = 20010;
                    UILabel *titleLabel = [self.bet_sum10_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum10_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(10),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_11"]){
                    toView = self.bet_sum11_View;
                    tagChipN = 20011;
                    UILabel *titleLabel = [self.bet_sum11_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum11_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(11),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_12"]){
                    toView = self.bet_sum12_View;
                    tagChipN = 20012;
                    UILabel *titleLabel = [self.bet_sum12_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum12_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(12),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_13"]){
                    toView = self.bet_sum13_View;
                    tagChipN = 20013;
                    UILabel *titleLabel = [self.bet_sum13_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum13_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(13),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_14"]){
                    toView = self.bet_sum14_View;
                    tagChipN = 20014;
                    UILabel *titleLabel = [self.bet_sum14_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum14_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(14),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_15"]){
                    toView = self.bet_sum15_View;
                    tagChipN = 20015;
                    UILabel *titleLabel = [self.bet_sum15_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum15_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(15),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_16"]){
                    toView = self.bet_sum16_View;
                    tagChipN = 20016;
                    UILabel *titleLabel = [self.bet_sum16_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum16_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(16),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"总和_17"]){
                    toView = self.bet_sum17_View;
                    tagChipN = 20017;
                    UILabel *titleLabel = [self.bet_sum17_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_sum17_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    [titles addObject:@{@"idx":@(17),@"title":titleSt}];
                    
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
        }else if (name && [name isEqualToString:@"猜围骰"]) {
            for (int y = 0; y<options.count; y++) {
                NSDictionary *subWayDic = options[y];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                NSString *value = [subWayDic objectForKey:@"value"];
                NSInteger betmine = [[subWayDic objectForKey:@"betmine"] integerValue];
                NSArray *betList = [subWayDic objectForKey:@"betlist"];
                UIView *toView = nil;
                NSInteger tagChipN = 0;
                if (title&&[title isEqualToString:@"豹子_1"]) {
                    toView = self.bet_bao1_View;
                    tagChipN = 20018;
                    UILabel *titleLabel = [self.bet_bao1_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_bao1_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(18),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"豹子_2"]){
                    toView = self.bet_bao2_View;
                    tagChipN = 20019;
                    UILabel *titleLabel = [self.bet_bao2_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_bao2_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(19),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"豹子_3"]){
                    toView = self.bet_bao3_View;
                    tagChipN = 20020;
                    UILabel *titleLabel = [self.bet_bao3_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_bao3_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(20),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"豹子_1-6"]){
                    toView = self.bet_baozi_View;
                    tagChipN = 20021;
                    UILabel *titleLabel = [self.bet_baozi_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_baozi_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(21),@"title":titleSt}];
                }else if(title&&[title isEqualToString:@"豹子_4"]){
                    toView = self.bet_bao4_View;
                    tagChipN = 20022;
                    UILabel *titleLabel = [self.bet_bao4_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_bao4_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(22),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"豹子_5"]){
                    toView = self.bet_bao5_View;
                    tagChipN = 20023;
                    UILabel *titleLabel = [self.bet_bao5_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_bao5_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(23),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"豹子_6"]){
                    toView = self.bet_bao6_View;
                    tagChipN = 20024;
                    UILabel *titleLabel = [self.bet_bao6_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_bao6_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(24),@"title":titleSt}];
                    
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
        }else if (name && [name isEqualToString:@"猜对子"]) {
            for (int y = 0; y<options.count; y++) {
                NSDictionary *subWayDic = options[y];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                NSString *value = [subWayDic objectForKey:@"value"];
                NSInteger betmine = [[subWayDic objectForKey:@"betmine"] integerValue];
                NSArray *betList = [subWayDic objectForKey:@"betlist"];
                UIView *toView = nil;
                NSInteger tagChipN = 0;
                if (title&&[title isEqualToString:@"对子_1"]) {
                    toView = self.bet_dui1_View;
                    tagChipN = 20025;
                    UILabel *titleLabel = [self.bet_dui1_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dui1_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(25),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"对子_2"]){
                    toView = self.bet_dui2_View;
                    tagChipN = 20026;
                    UILabel *titleLabel = [self.bet_dui2_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dui2_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(26),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"对子_3"]){
                    toView = self.bet_dui3_View;
                    tagChipN = 20027;
                    UILabel *titleLabel = [self.bet_dui3_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dui3_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(27),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"对子_4"]){
                    toView = self.bet_dui4_View;
                    tagChipN = 20028;
                    UILabel *titleLabel = [self.bet_dui4_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dui4_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(28),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"对子_5"]){
                    toView = self.bet_dui5_View;
                    tagChipN = 20029;
                    UILabel *titleLabel = [self.bet_dui5_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dui5_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(29),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"对子_6"]){
                    toView = self.bet_dui6_View;
                    tagChipN = 20030;
                    UILabel *titleLabel = [self.bet_dui6_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dui6_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(30),@"title":titleSt}];
                    
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
        }else if (name && [name isEqualToString:@"猜单骰"]) {
            for (int y = 0; y<options.count; y++) {
                NSDictionary *subWayDic = options[y];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                NSString *value = [subWayDic objectForKey:@"value"];
                NSInteger betmine = [[subWayDic objectForKey:@"betmine"] integerValue];
                NSArray *betList = [subWayDic objectForKey:@"betlist"];
                UIView *toView = nil;
                NSInteger tagChipN = 0;
                if (title&&[title isEqualToString:@"单骰_1"]) {
                    toView = self.bet_dian1_View;
                    tagChipN = 20031;
                    UILabel *titleLabel = [self.bet_dian1_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dian1_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(31),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"单骰_2"]){
                    toView = self.bet_dian2_View;
                    tagChipN = 20032;
                    UILabel *titleLabel = [self.bet_dian2_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dian2_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(32),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"单骰_3"]){
                    toView = self.bet_dian3_View;
                    tagChipN = 20033;
                    UILabel *titleLabel = [self.bet_dian3_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dian3_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(33),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"单骰_4"]){
                    toView = self.bet_dian4_View;
                    tagChipN = 20034;
                    UILabel *titleLabel = [self.bet_dian4_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dian4_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(34),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"单骰_5"]){
                    toView = self.bet_dian5_View;
                    tagChipN = 20035;
                    UILabel *titleLabel = [self.bet_dian5_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dian5_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(35),@"title":titleSt}];
                    
                }else if(title&&[title isEqualToString:@"单骰_6"]){
                    toView = self.bet_dian6_View;
                    tagChipN = 20036;
                    UILabel *titleLabel = [self.bet_dian6_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_dian6_View viewWithTag:201];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                   [titles addObject:@{@"idx":@(36),@"title":titleSt}];
                    
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
        [chartSubV updateMenueStr1:titleMenueStr1 Str2:titleMenueStr2];
    }
}
- (void)initCollection {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 1;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.betChipCollectionView.collectionViewLayout = layout;

    UINib *nib=[UINib nibWithNibName:kChipChoiseCell bundle:[XBundle currentXibBundleWithResourceName:@""]];
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
    
    UINib *copennib=[UINib nibWithNibName:kLiveOpenListYFKSCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennib forCellWithReuseIdentifier:kLiveOpenListYFKSCell];
    
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
    UIView *tapView = tap.view;
    if (issueContinueBet != nil && issueContinueBet.length>0 && ![curIssue isEqualToString:issueContinueBet]) {
        [contiDic removeAllObjects];
    }
    issueContinueBet = curIssue;
    self.continueBtn.enabled = false;
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
    
    if ([tapView isEqual:self.bet_big_View]) {
        [self  doBetType:@"总和_大" chipNum:chipNum toView:self.bet_big_View];
    }else if ([tapView isEqual:self.bet_small_View]){
        [self doBetType:@"总和_小" chipNum:chipNum toView:self.bet_small_View];
    }else if ([tapView isEqual:self.bet_single_View]){
        [self doBetType:@"总和_单" chipNum:chipNum toView:self.bet_single_View];
    }else if ([tapView isEqual:self.bet_double_View]){
        [self doBetType:@"总和_双"chipNum:chipNum toView:self.bet_double_View];
    }else if ([tapView isEqual:self.bet_bao1_View]){
        [self doBetType:@"豹子_1"chipNum:chipNum toView:self.bet_bao1_View];
    }else if ([tapView isEqual:self.bet_bao2_View]){
        [self doBetType:@"豹子_2" chipNum:chipNum toView:self.bet_bao2_View];
    }else if ([tapView isEqual:self.bet_bao3_View]){
        [self doBetType:@"豹子_3" chipNum:chipNum toView:self.bet_bao3_View];
    }else if ([tapView isEqual:self.bet_baozi_View]){
        [self doBetType:@"豹子_1-6" chipNum:chipNum toView:self.bet_baozi_View];
    }else if ([tapView isEqual:self.bet_bao4_View]){
        [self doBetType:@"豹子_4" chipNum:chipNum toView:self.bet_bao4_View];
    }else if ([tapView isEqual:self.bet_bao5_View]){
        [self doBetType:@"豹子_5" chipNum:chipNum toView:self.bet_bao5_View];
    }else if ([tapView isEqual:self.bet_bao6_View]){
        [self doBetType:@"豹子_6" chipNum:chipNum toView:self.bet_bao6_View];
    }else if ([tapView isEqual:self.bet_sum4_View]){
        [self doBetType:@"总和_4" chipNum:chipNum toView:self.bet_sum4_View];
    }else if ([tapView isEqual:self.bet_sum5_View]){
        [self doBetType:@"总和_5" chipNum:chipNum toView:self.bet_sum5_View];
    }else if ([tapView isEqual:self.bet_sum6_View]){
        [self doBetType:@"总和_6" chipNum:chipNum toView:self.bet_sum6_View];
    }else if ([tapView isEqual:self.bet_sum7_View]){
        [self doBetType:@"总和_7" chipNum:chipNum toView:self.bet_sum7_View];
    }else if ([tapView isEqual:self.bet_sum8_View]){
        [self doBetType:@"总和_8" chipNum:chipNum toView:self.bet_sum8_View];
    }else if ([tapView isEqual:self.bet_sum9_View]){
        [self doBetType:@"总和_9" chipNum:chipNum toView:self.bet_sum9_View];
    }else if ([tapView isEqual:self.bet_sum10_View]){
        [self doBetType:@"总和_10" chipNum:chipNum toView:self.bet_sum10_View];
    }else if ([tapView isEqual:self.bet_sum11_View]){
        [self doBetType:@"总和_11" chipNum:chipNum toView:self.bet_sum11_View];
    }else if ([tapView isEqual:self.bet_sum12_View]){
        [self doBetType:@"总和_12" chipNum:chipNum toView:self.bet_sum12_View];
    }else if ([tapView isEqual:self.bet_sum13_View]){
        [self doBetType:@"总和_13" chipNum:chipNum toView:self.bet_sum13_View];
    }else if ([tapView isEqual:self.bet_sum14_View]){
        [self doBetType:@"总和_14" chipNum:chipNum toView:self.bet_sum14_View];
    }else if ([tapView isEqual:self.bet_sum15_View]){
        [self doBetType:@"总和_15" chipNum:chipNum toView:self.bet_sum15_View];
    }else if ([tapView isEqual:self.bet_sum16_View]){
        [self doBetType:@"总和_16" chipNum:chipNum toView:self.bet_sum16_View];
    }else if ([tapView isEqual:self.bet_sum17_View]){
        [self doBetType:@"总和_17" chipNum:chipNum toView:self.bet_sum17_View];
    }else if ([tapView isEqual:self.bet_dui1_View]){
        [self doBetType:@"对子_1" chipNum:chipNum toView:self.bet_dui1_View];
    }else if ([tapView isEqual:self.bet_dui2_View]){
        [self doBetType:@"对子_2" chipNum:chipNum toView:self.bet_dui2_View];
    }else if ([tapView isEqual:self.bet_dui3_View]){
        [self doBetType:@"对子_3" chipNum:chipNum toView:self.bet_dui3_View];
    }else if ([tapView isEqual:self.bet_dui4_View]){
        [self doBetType:@"对子_4" chipNum:chipNum toView:self.bet_dui4_View];
    }else if ([tapView isEqual:self.bet_dui5_View]){
        [self doBetType:@"对子_5" chipNum:chipNum toView:self.bet_dui5_View];
    }else if ([tapView isEqual:self.bet_dui6_View]){
        [self doBetType:@"对子_6" chipNum:chipNum toView:self.bet_dui6_View];
    }else if ([tapView isEqual:self.bet_dian1_View]){
        [self doBetType:@"单骰_1" chipNum:chipNum toView:self.bet_dian1_View];
    }else if ([tapView isEqual:self.bet_dian2_View]){
        [self doBetType:@"单骰_2" chipNum:chipNum toView:self.bet_dian2_View];
    }else if ([tapView isEqual:self.bet_dian3_View]){
        [self doBetType:@"单骰_3" chipNum:chipNum toView:self.bet_dian3_View];
    }else if ([tapView isEqual:self.bet_dian4_View]){
        [self doBetType:@"单骰_4" chipNum:chipNum toView:self.bet_dian4_View];
    }else if ([tapView isEqual:self.bet_dian5_View]){
        [self doBetType:@"单骰_5" chipNum:chipNum toView:self.bet_dian5_View];
    }else if ([tapView isEqual:self.bet_dian6_View]){
        [self doBetType:@"单骰_6" chipNum:chipNum toView:self.bet_dian6_View];
    }
}

//是否移除未确认筹码。  是否移除所有的筹码。 当前下注区域
-(void)canBetHidenLastBetSubView:(BOOL)isRemoveAllBetSubView isClearAll:(BOOL)isClearAll toView:(UIView*)toView
{
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_sum4_View,self.bet_sum5_View,self.bet_sum6_View,self.bet_sum7_View,self.bet_sum8_View,self.bet_sum9_View,self.bet_sum10_View,self.bet_sum11_View,self.bet_sum12_View,self.bet_sum13_View,self.bet_sum14_View,self.bet_sum15_View,self.bet_sum16_View,self.bet_sum17_View,self.bet_bao1_View,self.bet_bao2_View,self.bet_bao3_View,self.bet_baozi_View,self.bet_bao4_View,self.bet_bao5_View,self.bet_bao6_View,self.bet_dui1_View,self.bet_dui2_View,self.bet_dui3_View,self.bet_dui4_View,self.bet_dui5_View,self.bet_dui6_View,self.bet_dian1_View,self.bet_dian2_View,self.bet_dian3_View,self.bet_dian4_View,self.bet_dian5_View,self.bet_dian6_View];

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

-(void)doBetType:(NSString*)detailType chipNum:(NSInteger)chipNum toView:(UIView*)toView {
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
    [lotterySubBetV addBetNum:[NSString stringWithFormat:@"%ld",chipNum] ways:detailType];
    UIView *fromView = self.bet_dian3_View;

    NSString *chipNumStr = [NSString stringWithFormat:@"%ld",chipNum];
    if ([detailType rangeOfString:@"总和_大"].location!=NSNotFound) {
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20000 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_小"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20001 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_单"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20002 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_双"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20003 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_4"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20004 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_5"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20005 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_6"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20006 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_7"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20007 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_8"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20008 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_9"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20009 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_10"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20010 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_11"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20011 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_12"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20012 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_13"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20013 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_14"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20014 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_15"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20015 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_16"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20016 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"总和_17"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20017 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_1"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20018 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_2"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20019 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_3"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20020 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_4"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20021 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_5"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20022 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_6"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20023 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"豹子_1-6"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20024 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"对子_1"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20025 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"对子_2"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20026 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"对子_3"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20027 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"对子_4"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20028 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"对子_5"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20029 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"对子_6"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20030 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"单骰_1"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20031 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"单骰_2"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20032 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"单骰_3"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20033 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"单骰_4"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20034 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"单骰_5"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20035 moneyNum:chipNumStr] uid:0];
    }else if ([detailType rangeOfString:@"单骰_6"].location!=NSNotFound){
        [self animationFrom:fromView toView:toView betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20036 moneyNum:chipNumStr] uid:0];
    }

}

-(void)doBetNetwork{
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_sum4_View,self.bet_sum5_View,self.bet_sum6_View,self.bet_sum7_View,self.bet_sum8_View,self.bet_sum9_View,self.bet_sum10_View,self.bet_sum11_View,self.bet_sum12_View,self.bet_sum13_View,self.bet_sum14_View,self.bet_sum15_View,self.bet_sum16_View,self.bet_sum17_View,self.bet_bao1_View,self.bet_bao2_View,self.bet_bao3_View,self.bet_baozi_View,self.bet_bao4_View,self.bet_bao5_View,self.bet_bao6_View,self.bet_dui1_View,self.bet_dui2_View,self.bet_dui3_View,self.bet_dui4_View,self.bet_dui5_View,self.bet_dui6_View,self.bet_dian1_View,self.bet_dian2_View,self.bet_dian3_View,self.bet_dian4_View,self.bet_dian5_View,self.bet_dian6_View];

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
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting&uid=%@&token=%@&lottery_type=%@&money=%@&way=%@&serTime=%@&issue=%@&optionName=%@&liveuid=%@&betid=%@",[Config getOwnID],[Config getOwnToken],lottery_type,money,way,minnum([[NSDate date] timeIntervalSince1970]),issue,@"猜大小",@"0",betIdStr];//User.getPlats
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
            NSArray<UIView*> *betViews = @[strongSelf.bet_big_View,strongSelf.bet_small_View,strongSelf.bet_single_View,strongSelf.bet_double_View,strongSelf.bet_sum4_View,strongSelf.bet_sum5_View,strongSelf.bet_sum6_View,strongSelf.bet_sum7_View,strongSelf.bet_sum8_View,strongSelf.bet_sum9_View,strongSelf.bet_sum10_View,strongSelf.bet_sum11_View,strongSelf.bet_sum12_View,strongSelf.bet_sum13_View,strongSelf.bet_sum14_View,strongSelf.bet_sum15_View,strongSelf.bet_sum16_View,strongSelf.bet_sum17_View,strongSelf.bet_bao1_View,strongSelf.bet_bao2_View,strongSelf.bet_bao3_View,strongSelf.bet_baozi_View,strongSelf.bet_bao4_View,strongSelf.bet_bao5_View,strongSelf.bet_bao6_View,strongSelf.bet_dui1_View,strongSelf.bet_dui2_View,strongSelf.bet_dui3_View,strongSelf.bet_dui4_View,strongSelf.bet_dui5_View,strongSelf.bet_dui6_View,strongSelf.bet_dian1_View,strongSelf.bet_dian2_View,strongSelf.bet_dian3_View,strongSelf.bet_dian4_View,strongSelf.bet_dian5_View,strongSelf.bet_dian6_View];
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
        if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            result_count = result_count + 1;
        }
        return result_count;
    }
        
    
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        ChipChoiseCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kChipChoiseCell forIndexPath:indexPath];
        [cell.chipImgView setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"ic_chip_%ld",indexPath.row+1]]];
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
        
        
        cell.chipImgView.layer.cornerRadius = 19;
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
        LiveOpenListYFKSCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLiveOpenListYFKSCell forIndexPath:indexPath];
        lastResultModel * model = self.allOpenResultData[indexPath.row];
        cell.model = model;
        [cell updateConstraintsForFullscreen];
        return cell;
    } else {
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
        if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
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
        
        return cell;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        return CGSizeMake(46, 46);
    }else if (collectionView == self.openResultList){
        return CGSizeMake(_window_width, 32);
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
        return CGSizeMake(46, 46);
    }else if (collectionView == self.openResultList){
        return CGSizeMake(_window_width, 32);
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
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    if (socketDelegate) {
        socketDelegate.socketDelegate = nil;
        socketDelegate = nil;
    }
    if (self.avplayer) {
        [self.avplayer pause];
        self.avplayer = nil;
    }
    voiceAwardMoney = nil;
    isExit = YES;
    [self.view layoutIfNeeded];
    [self clearSelectBetView];
    
    if (lotteryTime) {
        [lotteryTime invalidate];
        lotteryTime = nil;
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

-(void)clearSelectBetView
{
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_sum4_View,self.bet_sum5_View,self.bet_sum6_View,self.bet_sum7_View,self.bet_sum8_View,self.bet_sum9_View,self.bet_sum10_View,self.bet_sum11_View,self.bet_sum12_View,self.bet_sum13_View,self.bet_sum14_View,self.bet_sum15_View,self.bet_sum16_View,self.bet_sum17_View,self.bet_bao1_View,self.bet_bao2_View,self.bet_bao3_View,self.bet_baozi_View,self.bet_bao4_View,self.bet_bao5_View,self.bet_bao6_View,self.bet_dui1_View,self.bet_dui2_View,self.bet_dui3_View,self.bet_dui4_View,self.bet_dui5_View,self.bet_dui6_View,self.bet_dian1_View,self.bet_dian2_View,self.bet_dian3_View,self.bet_dian4_View,self.bet_dian5_View,self.bet_dian6_View];
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
            self.selectedToolBtn.selected = NO;
            [self rebackScrollView: NO];
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
