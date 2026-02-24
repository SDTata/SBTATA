//
//  LotteryBetViewController.m
//
//

#import "LotteryBetViewController_SSC.h"
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
#import "LotteryBetSubView.h"
#import "NSString+Extention.h"
#import "ChartView.h"
#import "LotteryOpenViewCell_SSC.h"
#import "LotteryNNModel.h"
#import "LiveBetListYFKSCell.h"
#import "BetListModel.h"
#import "LotteryCodeView_Base.h"
#import "LotteryCustomChipView.h"


#define kChipChoiseCell @"ChipChoiseCell"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"

#define perSection    M_PI*2/37
#define kLotteryOpenViewCell_SSC @"LotteryOpenViewCell_SSC"
#define kLiveBetListYFKSCell @"LiveBetListYFKSCell"
#define bottomConstant 0

#define heightView LotteryWindowNewHeighSSC

@interface LotteryBetViewController_SSC ()<CAAnimationDelegate>{
    BOOL isShow;
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSDictionary *allData;
    NSMutableArray *ways;   // 投注选项
    
    BOOL bUICreated; // UI是否创建
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *last_open_result;
    NSDictionary *resultDict;
    
    AVAudioPlayer *voiceAwardMoney;
    
    BOOL isFinance;
    BOOL isOpenning;
    NSMutableDictionary *contiDic;
    NSString *issueContinueBet;
    BOOL isContinueBet;
    
    //飞向玩家筹码
    NSMutableArray *top5UserIDS;
    NSMutableArray *winUsersArray;
    
    int numberOfChips1;
    int numberOfChips2;
    int numberOfChips3;
    int numberOfChips4;
    int numberOfChips5;
    int numberOfChips6;
    int numberOfChips7;
    int numberOfChips8;
    
    NSMutableArray<ChipsModel*> *chipsArraysAll;
    ChipsModel *selectedChipModel;
    NSArray <NSDictionary *> *_titleSts;
    
    NSInteger openPage;
    NSInteger betPage;
    ChartView *chartSubV;

    NSInteger _currentState;
    NSTimeInterval _currentStartTime;
    NSTimeInterval _currentEndTime;
    BOOL _netFlag; //网络锁
    
    BOOL isShowTopList; //走势图等顶部视图是否显示
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property(nonatomic,strong)NSMutableArray * toolBtnArr;
@property(nonatomic,strong)UIButton * selectedToolBtn;
@property(nonatomic,strong)NSMutableArray *allOpenResultData;
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@property(nonatomic,strong) UIScrollView * toolScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomimgConstraint;

@end

@implementation LotteryBetViewController_SSC

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@0];
}
- (void)viewDidAppear:(BOOL)animated{
    if (!isShow) {
        isShow = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTime:) name:@"lotterySecondNotify" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpen:) name:@"LotteryOpenAward" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(betNotification:) name:KBetDoNotificationMsg object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(betWintification:) name:KBetWinAllUserNotificationMsg object:nil];
        openPage = 0;
        betPage = 1;
        _netFlag = YES;
        isShowTopList = NO;
        [self createToolScorllview];
        self.topHeight.constant = 0;
        
        [self getOpenResultInfo];
        [self getInfo];
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
    [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
    self.bottomimgConstraint.constant = 50+ShowDiff;
    self.bottomConstraint.constant =  (heightView+ShowDiff);
    self.view.height = heightView+ShowDiff;
    
    self.bet_big_View = [LotteryBetView new];
    self.bet_small_View = [LotteryBetView new];
    self.bet_single_View = [LotteryBetView new];
    self.bet_double_View = [LotteryBetView new];
    self.bet_shu1_View = [LotteryBetView new];
    self.bet_shu2_View = [LotteryBetView new];
    self.bet_shu3_View = [LotteryBetView new];
    
    CGFloat height = 58;
    
    UIView *betContentView = [UIView new];
    [self.contentView addSubview:betContentView];
    [betContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(-self.bottomimgConstraint.constant-50);
    }];
    
    UIStackView *betStackView = [UIStackView new];
    betStackView.axis = UILayoutConstraintAxisVertical;
    [betContentView addSubview:betStackView];
    [betStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(betContentView);
    }];
    
    UIStackView *stackView1 = [UIStackView new];
    stackView1.spacing = 5;
    stackView1.transform = CGAffineTransformMakeScale(1.0, 1.3);
    stackView1.distribution = UIStackViewDistributionFillEqually;
    [stackView1 addArrangedSubview:self.bet_big_View];
    [stackView1 addArrangedSubview:self.bet_small_View];
    [stackView1 addArrangedSubview:self.bet_single_View];
    [stackView1 addArrangedSubview:self.bet_double_View];
    [betStackView addArrangedSubview:stackView1];
    [stackView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    UIStackView *stackView2 = [UIStackView new];
    stackView2.spacing = 5;
    stackView2.transform = CGAffineTransformMakeScale(1.0, 1.2);
    stackView2.distribution = UIStackViewDistributionFillEqually;
    [stackView2 addArrangedSubview:self.bet_shu1_View];
    [stackView2 addArrangedSubview:self.bet_shu2_View];
    [stackView2 addArrangedSubview:self.bet_shu3_View];
    [betStackView addArrangedSubview:stackView2];
    [stackView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    betStackView.layer.transform = betTransform();
    [betStackView setCustomSpacing:22 afterView:stackView1];
    
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_shu1_View,self.bet_shu2_View,self.bet_shu3_View];

    for (int i = 0; i<betViews.count; i++) {
        betViews[i].tag = i+810;
        UITapGestureRecognizer *tapBet = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(betAction:)];
        [betViews[i] addGestureRecognizer:tapBet];
    }
 
    if (@available(iOS 11.0, *)) {
        self.openResultCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.openResultCollection.contentInset = UIEdgeInsetsMake(0, -7, 0, 0);
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
    
    top5UserIDS = [NSMutableArray array];
    winUsersArray = [NSMutableArray array];
    contiDic = [NSMutableDictionary dictionary];
    _titleSts = [NSArray <NSDictionary *> array];
    self.continueBtn.enabled = false;
    [self.KeyBTN setBackgroundImage:[[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(120, 30)] sd_imageByRoundCornerRadius:15] forState:UIControlStateNormal];
    [self.KeyBTN setTitle:YZMsg(@"Livebroadcast_SaySomething") forState:UIControlStateNormal];
//    [self stopWobble];
////   摇摆
//    [self startWobble];
    [self.betChipCollectionView reloadData];
    //创建手势 使用initWithTarget:action:的方法创建
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doShowHistory)];
    
    //别忘了添加到testView上
    [self.openResutLab addGestureRecognizer:tap];
    
    self.chartView.backgroundColor = [UIColor clearColor];
    chartSubV = [ChartView instanceChatViewWithType:curLotteryType];
    [self.chartView addSubview:chartSubV];
    self.chartView.hidden = YES;
    self.betHistoryList.hidden = YES;
    self.openResultList.hidden = YES;
    self.topHeight.constant = 0;
    
    NSDate *now = [NSDate date];
    NSDate *zero = [self getZeroTimeWithDate:now];
    NSDate *end = [self getEndTimeWithDate:now];
    _currentStartTime = [zero timeIntervalSince1970];
    _currentEndTime = [end timeIntervalSince1970];
    
    _currentState = -1;
    self.noLab.text = YZMsg(@"LiveGame_NoBetList");
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
    [GameToolClass setCurOpenedLotteryType:0-lotteryType];
}

-(void)createToolScorllview{
    
    if (self.toolScrollView) {
        [self.toolScrollView removeFromSuperview];
        self.toolScrollView = nil;
    }
    
    self.toolScrollView = [[CustomScrollView alloc] initWithFrame:CGRectMake(0, 0, self.toolBg.size.width, self.toolBg.size.height)];
    self.toolScrollView.delegate = self;
    self.toolScrollView.backgroundColor = [UIColor clearColor];
    self.toolScrollView.userInteractionEnabled = YES;

     NSArray * imgArr = @[@"yfks_icon_zst",@"yfks_icon_tzjl",@"yfks_icon_kjjl",@"yfks_icon_wfsm",@"yfks_icon_xxkq",@"yfks_icon_lstz",@"yfks_icon_qhxb",@"yfks_icon_lw",@"yfks_icon_game",@"live_redpack"];
    CGFloat contentLength = 0;
    CGFloat buttonWidth = 30.0;
    CGFloat spacing = 5;
    
    self.toolBtnArr = [NSMutableArray array];
    for (int i = 0; i< imgArr.count; i ++) {
        if (self.isFromLiveBroadcast && i >= 7) {
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
        if(i == 4){
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
            });
        }
        else{
//            [MBProgressHUD showError:YZMsg(@"public_networkError")];
            [strongSelf exitView];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf exitView];
    }];
}

// 投注记录
- (void)getBetInfo{
    //    if(!bUICreated){
    //        self.openResultList.hidden = YES;
    //    }
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Lottery.betList3" withBaseDomian:YES andParameter:@{@"page":@(betPage),@"lottery_type":@(0),@"status":@(_currentState),@"start_time":@(_currentStartTime),@"end_time":@(_currentEndTime)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
                strongSelf.noView.hidden = NO;
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

//获取彩种信息
- (void)getInfo{
    NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getBetViewInfo&uid=%@&token=%@&lottery_type=%@&live_id=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType],minnum([GlobalDate getLiveUID])];
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
            // test code start
//            NSString *dataStr = @"{\"name\":\"一分时时彩\",\"logo\":\"http://qd.bzkebzs.cn/logo_circle/620.png\",\"status\":0,\"left_time\":53,\"left_coin\":10,\"last_result\":[{\"bg\":\"http://www.baidu.com/red\",\"showString\":\"1\"}],\"bet_type\":[{\"name\":\"个位\",\"options\":[{\"name\":\"大\",\"rate\":\"1.97\",\"id\":1},{\"name\":\"小\",\"rate\":\"1.97\",\"id\":2}]},{\"name\":\"龙虎万千\",\"options\":[{\"name\":\"龙\",\"rate\":\"2.17\",\"id\":3},{\"name\":\"虎\",\"rate\":\"2.17\",\"id\":4},{\"name\":\"和\",\"rate\":\"9.97\",\"id\":5}]},{\"name\":\"十位\",\"options\":[{\"name\":\"单\",\"rate\":\"2.17\",\"id\":6},{\"name\":\"双\",\"rate\":\"2.17\",\"id\":7}]}]}";
//            NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];//转化为data
//            NSArray *info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            // test code end
            
            NSLog(@"%@",info);
            
            strongSelf->allData = [info firstObject];
            // 反向同步信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lotteryRsync" object:nil userInfo:strongSelf->allData];
            NSDictionary *dict = strongSelf->allData[@"lastResult"];
            strongSelf.curIssue = strongSelf->allData[@"issue"];
            strongSelf->betLeftTime = [strongSelf->allData[@"time"] integerValue];
            strongSelf->sealingTime = [strongSelf->allData[@"sealingTim"] integerValue];
            
            if(dict){
                strongSelf->last_open_result = dict[@"open_result"];
//                strongSelf.openResutLab.text = minstr(dict[@"open_result"]);
                [strongSelf refreshOpenListView];
            }else{
                strongSelf->last_open_result = @"";
//                self.openResutLab.hidden = YES;
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
    // 更新倒计时时间
    [self refreshTimeUI];
    if(!bUICreated){
        [self initUI];
    }
    self.openResultCollection.hidden = NO;
    
    // 更新余额
    [self refreshLeftCoinLabel];
    [self updateTop5];
    [self refreshOpenListView];
}
#pragma mark---Notification通知----
//时间刷新通知
- (void)refreshTime:(NSNotification *)notification {
    if(!bUICreated){
        return;
    }
    NSString * lotteryType = minstr(notification.userInfo[@"lotteryType"]);
    if(curLotteryType>0 && [lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        betLeftTime = [(notification.userInfo[@"betLeftTime"]) integerValue];
        sealingTime = [(notification.userInfo[@"sealingTime"]) integerValue];
        self.curIssue = minstr(notification.userInfo[@"issue"]);
        BOOL isReset = [notification.userInfo[@"isReset"] boolValue];
        if (isReset) {
            [self closeShaiguBoxAnimation];
        }
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
        last_open_result = result;
        resultDict = notification.userInfo;
        
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
//            strongSelf.openResutLab.text = minstr(result);
//            strongSelf.openResutLab.hidden = NO;
            [strongSelf refreshOpenListView];
            [strongSelf.openResultCollection reloadData];
            
            if(strongSelf.selectedToolBtn.tag == 1001){
                strongSelf->betPage = 1;
                [strongSelf getBetInfo];
            }
            [strongSelf getOpenResultInfo];
            [strongSelf->chartSubV updateChartData:strongSelf->last_open_result];
        });
        [self updateTop5];
        NSArray *winways = notification.userInfo[@"winWays"];
        
        //桌子点亮及砝码动效
        [self performSelector:@selector(tableAndChipsChangedWithWinways:) withObject:winways afterDelay:1];
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
}
- (void)tableAndChipsChangedWithWinways:(NSArray *)winways{
    ///下面是桌面赢方背景改变
    NSMutableArray *winViews = [NSMutableArray array];
    NSMutableArray *winChipsTags = [NSMutableArray array];
    for (NSString *winName in winways) {
        UIImageView *imgV;
        LotteryBetView *betView;
        if ([winName isEqualToString:@"总和_大"]) {
            betView = self.bet_big_View;
            imgV = [self.bet_big_View viewWithTag:300];
            [winChipsTags addObject:@"20000"];
            [winViews addObject:self.bet_big_View];
        }else if ([winName isEqualToString:@"总和_小"]){
            betView = self.bet_small_View;
            imgV = [self.bet_small_View viewWithTag:300];
            [winViews addObject:self.bet_small_View];
            [winChipsTags addObject:@"20001"];
        }else if ([winName isEqualToString:@"总和_单"]){
            betView = self.bet_single_View;
            imgV = [self.bet_single_View viewWithTag:300];
            [winViews addObject:self.bet_single_View];
            [winChipsTags addObject:@"20002"];
        }else if ([winName isEqualToString:@"总和_双"]){
            betView = self.bet_double_View;
            imgV = [self.bet_double_View viewWithTag:300];
            [winViews addObject:self.bet_double_View];
            [winChipsTags addObject:@"20003"];
        }else if ([winName isEqualToString:@"龙"]){
            betView = self.bet_shu1_View;
            imgV = [self.bet_shu1_View viewWithTag:300];
            [winViews addObject:self.bet_shu1_View];
            [winChipsTags addObject:@"20004"];
        }else if ([winName isEqualToString:@"和"]){
            betView = self.bet_shu2_View;
            imgV = [self.bet_shu2_View viewWithTag:300];
            [winViews addObject:self.bet_shu2_View];
            [winChipsTags addObject:@"20005"];
        }else if ([winName isEqualToString:@"虎"]){
            betView = self.bet_shu3_View;
            imgV = [self.bet_shu3_View viewWithTag:300];
            [winViews addObject:self.bet_shu3_View];
            [winChipsTags addObject:@"20006"];
        }
        betView.selected = YES;
    }
    ///下面是飞筹码动画
    NSArray *subViews = [NSArray arrayWithArray:self.contentView.subviews];
    NSMutableArray *chipLose = [NSMutableArray array];
    for (int i = 0; i<subViews.count; i++) {
        UIView *sub = subViews[i];
        if (sub.tag >=20000 && sub.tag<=888888) {
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
            sub.center = strongSelf.openResultCollection.center;
        }
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf==nil||strongSelf.isExit) {
            return;
        }
        if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"shoufamaaudio.mp3"].location == NSNotFound)) {
            NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"shoufamaaudio.mp3" withExtension:Nil];
            strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
//            if (strongSelf.musicBtn.selected) {
//                [strongSelf->voiceAwardMoney setVolume:0];
//            }else{
//                [strongSelf->voiceAwardMoney setVolume:1];
//            }
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
        if (strongSelf==nil||strongSelf.isExit) {
            return;
        }
        if (!strongSelf->voiceAwardMoney||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"shoufamaaudio.mp3"].location == NSNotFound)) {
            NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"shoufamaaudio.mp3" withExtension:Nil];
            strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
            if (strongSelf.musicBtn.selected) {
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
        if (strongSelf->winUsersArray.count>0) {
            NSMutableDictionary *dicWinWays = [NSMutableDictionary dictionary];
            for (LotteryProfit *betWinModel in strongSelf->winUsersArray) {
                NSString *winWaysStr = betWinModel.msg.winWay;
                NSString *winUersId = [NSString stringWithFormat:@"%u",betWinModel.msg.uid];
                if ([winWaysStr isEqualToString:@"总和_单"]||[winWaysStr isEqualToString:@"总和_双"]||[winWaysStr isEqualToString:@"总和_大"]||[winWaysStr isEqualToString:@"总和_小"]||[winWaysStr isEqualToString:@"龙"]||[winWaysStr isEqualToString:@"和"]||[winWaysStr isEqualToString:@"虎"]) {
                    NSMutableArray *arraysUsr = [dicWinWays objectForKey:winWaysStr];
                    if (arraysUsr && arraysUsr.count>0 && ![arraysUsr containsObject:winUersId]) {
                        [arraysUsr addObject:winUersId];
                        [dicWinWays setObject:arraysUsr forKey:winWaysStr];
                    }else{
                        NSMutableArray *arraysUsr = [NSMutableArray array];
                        [arraysUsr addObject:winUersId];
                        [dicWinWays setObject:arraysUsr forKey:winWaysStr];
                    }
                }
            }
            if (dicWinWays.count>0) {
                NSArray *winWaysStrs = dicWinWays.allKeys;
                for (int i = 0; i<winWaysStrs.count; i++) {
                    NSString *winSubWay = winWaysStrs[i];
                    NSArray *usersA = [dicWinWays objectForKey:winSubWay];
                    NSInteger tagChipsub = 0;
                    if ([winSubWay isEqualToString:@"总和_单"]) {
                        tagChipsub = 20000;
                    }else if([winSubWay isEqualToString:@"总和_双"]){
                        tagChipsub = 20001;
                    }else if([winSubWay isEqualToString:@"总和_大"]){
                        tagChipsub = 20002;
                    }else if([winSubWay isEqualToString:@"总和_小"]){
                        tagChipsub = 20003;
                    }else if([winSubWay isEqualToString:@"龙"]){
                        tagChipsub = 20004;
                    }else if([winSubWay isEqualToString:@"和"]){
                        tagChipsub = 20005;
                    }else if([winSubWay isEqualToString:@"虎"]){
                        tagChipsub = 20006;
                    }
                     
                    NSMutableArray *arraysubChip = [NSMutableArray array];
                    for (int i = 0; i<subViews.count; i++) {
                        UIView *sub = subViews[i];
                        if (sub.tag == tagChipsub) {
                            [arraysubChip addObject:sub];
                        }
                    }
                    NSInteger eachNum = floor(arraysubChip.count/(usersA.count+1));
                    for (int i = 0; i<arraysubChip.count; i++) {
                        UIView *sub = arraysubChip[i];
                        if (i<eachNum) {
                            /// 飞到第一个用户
                            NSString *userIDTo = usersA[0];
                            NSInteger indexUser = [strongSelf->top5UserIDS indexOfObject:userIDTo];
                            UIView *toView = [strongSelf.top5StackView viewWithTag:100+indexUser];
                            CGRect fromRct = CGRectMake(strongSelf.top5StackView.superview.left+toView.left, strongSelf.top5StackView.superview.top+toView.top, toView.width, toView.height);
                            sub.center = CGPointMake(fromRct.origin.x+toView.width/2, fromRct.origin.y+toView.height/2);
                            
                        }else if(i<eachNum*2){
                            /// 飞到第二个用户
                            if (usersA.count>1) {
                                NSString *userIDTo = usersA[1];
                                NSInteger indexUser = [strongSelf->top5UserIDS indexOfObject:userIDTo];
                                UIView *toView = [strongSelf.top5StackView viewWithTag:100+indexUser];
                                CGRect fromRct = CGRectMake(strongSelf.top5StackView.superview.left+toView.left, strongSelf.top5StackView.superview.top+toView.top, toView.width, toView.height);
                                sub.center = CGPointMake(fromRct.origin.x+toView.width/2, fromRct.origin.y+toView.height/2);
                                
                            }else{
                                if (sub.tag >=20000 && sub.tag<=888888) {
                                    sub.center = strongSelf.otherPlayerImgView.center;
                                }
                            }
                            
                            
                        }else if(i<eachNum*3){
                            /// 飞到第三个用户
                            if (usersA.count>2) {
                                NSString *userIDTo = usersA[2];
                                NSInteger indexUser = [strongSelf->top5UserIDS indexOfObject:userIDTo];
                                UIView *toView = [strongSelf.top5StackView viewWithTag:100+indexUser];
                                CGRect fromRct = CGRectMake(strongSelf.top5StackView.superview.left+toView.left, strongSelf.top5StackView.superview.top+toView.top, toView.width, toView.height);
                                sub.center = CGPointMake(fromRct.origin.x+toView.width/2, fromRct.origin.y+toView.height/2);
                            }else{
                                if (sub.tag >=20000 && sub.tag<=888888) {
                                    sub.center = strongSelf.otherPlayerImgView.center;
                                }
                            }
                        }else if(i<eachNum*4){
                            /// 飞到第四个用户
                            if (usersA.count>3) {
                                NSString *userIDTo = usersA[3];
                                NSInteger indexUser = [strongSelf->top5UserIDS indexOfObject:userIDTo];
                                UIView *toView = [strongSelf.top5StackView viewWithTag:100+indexUser];
                                CGRect fromRct = CGRectMake(strongSelf.top5StackView.superview.left+toView.left, strongSelf.top5StackView.superview.top+toView.top, toView.width, toView.height);
                                sub.center = CGPointMake(fromRct.origin.x+toView.width/2, fromRct.origin.y+toView.height/2);
                            }else{
                                if (sub.tag >=20000 && sub.tag<=888888) {
                                    sub.center = strongSelf.otherPlayerImgView.center;
                                }
                            }
                        }else if(i<eachNum*5){
                            /// 飞到第五个用户
                            if (usersA.count>4) {
                                NSString *userIDTo = usersA[4];
                                NSInteger indexUser = [strongSelf->top5UserIDS indexOfObject:userIDTo];
                                UIView *toView = [strongSelf.top5StackView viewWithTag:100+indexUser];
                                CGRect fromRct = CGRectMake(strongSelf.top5StackView.superview.left+toView.left, strongSelf.top5StackView.superview.top+toView.top, toView.width, toView.height);
                                sub.center = CGPointMake(fromRct.origin.x+toView.width/2, fromRct.origin.y+toView.height/2);
                            }else{
                                if (sub.tag >=20000 && sub.tag<=888888) {
                                    sub.center = strongSelf.otherPlayerImgView.center;
                                }
                            }
                        }else{
                            /// 飞到其他用户
                            if (sub.tag >=20000 && sub.tag<=888888) {
                                sub.center = strongSelf.otherPlayerImgView.center;
                            }
                        }
                    }
                }
            }else{
                for (int i = 0; i<subViews.count; i++) {
                    UIView *sub = subViews[i];
                    if (sub.tag >=20000 && sub.tag<=888888) {
                        sub.center = strongSelf.otherPlayerImgView.center;
                    }
                }
            }
        }else{
            for (int i = 0; i<subViews.count; i++) {
                UIView *sub = subViews[i];
                if (sub.tag >=20000 && sub.tag<=888888) {
                    sub.center = strongSelf.otherPlayerImgView.center;
                }
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
    [self closeShaiguBoxAnimation];
    
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        UIView *codeView = [strongSelf.contentView viewWithTag:99999999];
        [codeView removeFromSuperview];
        [strongSelf.animationView removeFromSuperview];
        strongSelf.animationView = nil;
        begainAnimationShaigu = NO;
        
        NSMutableArray *arraybgs = [NSMutableArray array];
        if (strongSelf.bet_big_View) [arraybgs addObject:strongSelf.bet_big_View];
        if (strongSelf.bet_small_View) [arraybgs addObject:strongSelf.bet_small_View];
        if (strongSelf.bet_single_View) [arraybgs addObject:strongSelf.bet_single_View];
        if (strongSelf.bet_double_View) [arraybgs addObject:strongSelf.bet_double_View];
        if (strongSelf.bet_shu1_View) [arraybgs addObject:strongSelf.bet_shu1_View];
        if (strongSelf.bet_shu2_View) [arraybgs addObject:strongSelf.bet_shu2_View];
        if (strongSelf.bet_shu3_View) [arraybgs addObject:strongSelf.bet_shu3_View];
        for (UIView *viewSub in arraybgs) {
//            UIImageView *imgV = [viewSub viewWithTag:300];
//            imgV.image = [ImageBundle imagewithBundleName:@"bet_bolder_zp"];
            UILabel *betAllLabel = [viewSub viewWithTag:101];
//          UILabel *betMineLabel = [viewSub viewWithTag:101];
            if (betAllLabel) {
                betAllLabel.text=@"0";
            }
//            if (betMineLabel) {
//                betMineLabel.text = @"0";
//            }
            if ([viewSub isKindOfClass:LotteryBetView.class]) {
                [(LotteryBetView *)viewSub setSelected:NO];
            }
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
            }else if (viewSub == strongSelf.bet_shu1_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 4) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_shu2_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 5) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else if (viewSub == strongSelf.bet_shu3_View){
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 6) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }else{
                for (NSDictionary *dc in strongSelf->_titleSts) {
                    if (((NSNumber *)dc[@"idx"]).integerValue == 13) {
                        [bubble setBetCount:dc[@"title"]];
                    }
                }
            }
            
        }
        
        ///显示即将开始
        UIView *willReadyView = [UIView new];
        willReadyView.tag = 2100;
        [strongSelf.contentView addSubview:willReadyView];
        [willReadyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(-heightView/2-ShowDiff);
            make.width.mas_equalTo(130);
            make.height.mas_equalTo(50);
        }];
        
        UIImageView *imgVReadybg = [UIImageView new];
        imgVReadybg.image = [ImageBundle imagewithBundleName:@"game_will_begain"];
        [willReadyView addSubview:imgVReadybg];
        [imgVReadybg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(18);
        }];
        
        UILabel *labelTip = [UILabel new];
        labelTip.textColor = RGB(252, 245, 146);
        labelTip.text = YZMsg(@"game_will_begain");
        labelTip.font = [UIFont boldSystemFontOfSize:20];
        labelTip.adjustsFontSizeToFitWidth = YES;
        labelTip.minimumScaleFactor = 0.1;
        [imgVReadybg addSubview:labelTip];
        [labelTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-8);
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(40);
        }];
        
        __block UIButton *buttonick = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonick.tag = 100;
        [buttonick setBackgroundImage:[ImageBundle imagewithBundleName:@"game_secondimg"] forState:UIControlStateNormal];
        [buttonick setTitleColor:RGB(182, 66, 16) forState:UIControlStateNormal];
        buttonick.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [buttonick setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
        [buttonick setTitle:@"4" forState:UIControlStateNormal];
        [willReadyView addSubview:buttonick];
        [buttonick mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(37);
            make.height.mas_equalTo(40);
        }];
        
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

///玩家赢
-(void)betWintification:(NSNotification*)notification
{
    NSDictionary * notifiDic = notification.userInfo;
    LotteryProfit *betModel = (LotteryProfit*)[notifiDic objectForKey:@"model"];
    if (![LotteryProfit isKindOfClass:[LotteryProfit class]]) {
        return;
    }
    NSString *winUersId = [NSString stringWithFormat:@"%u",betModel.msg.uid];
    ///是否包含top5玩家
    if ([top5UserIDS containsObject:winUersId]) {
        [winUsersArray addObject:betModel];
    }
    
    NSLog(@"QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
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
    
    
    if (betModel.msg.issue == [self.curIssue longLongValue] && curLotteryType == betModel.msg.lotteryType) {
        UIView *fromView = self.otherPlayerImgView;
        NSString *betUserId = [NSString stringWithFormat:@"%u",betModel.msg.uid];
        if (top5UserIDS && [top5UserIDS containsObject:betUserId]) {
            for (int i = 0; i<top5UserIDS.count; i++) {
                if (i<5) {
                    NSString *userIDStr = top5UserIDS[i];
                    if ( [userIDStr longLongValue] == betModel.msg.uid) {
                        fromView = [self.top5StackView viewWithTag:100+i];
                    }
                }
            }
        }
        
        for (int i = 0; i<arrWays.count; i++) {
            NSString *keyContinue = @"";
            NSString *subWay = arrWays[i];
            NSString *subMoney = arrMoney[i];
                        
            if ([subWay isEqualToString:@"总和_大"]) {
                keyContinue = @"1";
                [self animationFrom:fromView toView:self.bet_big_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20000 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"总和_小"]){
                keyContinue = @"2";
                [self animationFrom:fromView toView:self.bet_small_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20001 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"总和_单"]){
                keyContinue = @"3";
                [self animationFrom:fromView toView:self.bet_single_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20002 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"总和_双"]){
                keyContinue = @"4";
                [self animationFrom:fromView toView:self.bet_double_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20003 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"龙"]){
                keyContinue = @"5";
                [self animationFrom:fromView toView:self.bet_shu1_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20004 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"和"]){
                keyContinue = @"6";
                [self animationFrom:fromView toView:self.bet_shu2_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20005 moneyNum:subMoney] uid:betModel.msg.uid];
            }else if ([subWay isEqualToString:@"虎"]){
                keyContinue = @"7";
                [self animationFrom:fromView toView:self.bet_shu3_View betTotalMoney:subMoney chipView:[self getChipImgViewWithTag:20006 moneyNum:subMoney] uid:betModel.msg.uid];
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
        
        if ([FromView isEqual:self.otherPlayerImgView]) {
            chipImgV.center = FromView.center;
        }else{
            CGRect fromRct = CGRectMake(self.top5StackView.superview.left+FromView.left, self.top5StackView.superview.top+FromView.top, FromView.width, FromView.height);
            chipImgV.center = CGPointMake(fromRct.origin.x+FromView.width/2, fromRct.origin.y+FromView.height/2);
        }
        if (uid == 0) {
            chipImgV.tag = chipImgV.tag+ 100000000;
        }
        [self.contentView addSubview:chipImgV];
        WeakSelf
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            CGPoint toRectPoint = [strongSelf toRandomRectPointtoView:toView];
            chipImgV.frame = CGRectMake(toRectPoint.x, toRectPoint.y, 22, 22);
            [chipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                // 这里假设你想要设置lotterySubBetV的左上角坐标（x，y）相对于self.contentView的左上角
               
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-(self.contentView.height-chipImgV.bottom));   // 设置y坐标偏移
                // 如果需要设置lotterySubBetV的宽度和高度，可以使用下面的代码
                make.left.mas_equalTo(chipImgV.left);
                make.size.mas_equalTo(chipImgV.size);
            }];
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil||strongSelf.isExit) {
                return;
            }
            if (!strongSelf->voiceAwardMoney ||(strongSelf->voiceAwardMoney &&  [strongSelf->voiceAwardMoney.url.path rangeOfString:@"jiafamaaudio.mp3"].location == NSNotFound)) {
                NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([strongSelf class])]URLForResource:@"jiafamaaudio.mp3" withExtension:Nil];
                strongSelf->voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
                if (strongSelf.musicBtn.selected) {
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

            [strongSelf refreshChipsTexttoView:toView betModel:totalMoney uid:uid];
        }];
    }else{
        [self refreshChipsTexttoView:toView betModel:totalMoney uid:uid];

    }
}
-(CGPoint)toRandomRectPointtoView:(UIView *)toView
{
    CGRect toViewRect = [toView convertRect:toView.bounds toView:self.contentView];
//    toViewRect = CGRectMake(toViewRect.origin.x+6, toViewRect.origin.y+17, toViewRect.size.width-12, toViewRect.size.height-17*2);
    CGPoint toRectPoint = CGPointMake(toViewRect.origin.x+[self getRandomNumber:5 to:toViewRect.size.width-20], toViewRect.origin.y+[self getRandomNumber:5 to:toViewRect.size.height-20]);
    return toRectPoint;
}
-(int)getRandomNumber:(int)from to:(int)to
{
  return (int)(from + (arc4random() % (to - from + 1)));
}
-(UIImageView*)getChipImgViewWithTag:(NSInteger)tagNum moneyNum:(NSString*)moneyNum{
    
    int numberOfCurrent;
    ///先移除多余的筹码
    switch (tagNum) {
        case 20000:
            numberOfChips1++;
            numberOfCurrent = numberOfChips1;
            break;
        case 20001:
            numberOfChips2++;
            numberOfCurrent = numberOfChips2;
            break;
        case 20002:
            numberOfChips3++;
            numberOfCurrent = numberOfChips3;
            break;
        case 20003:
            numberOfChips4++;
            numberOfCurrent = numberOfChips4;
            break;
        case 20004:
            numberOfChips5++;
            numberOfCurrent = numberOfChips5;
            break;
        case 20005:
            numberOfChips6++;
            numberOfCurrent = numberOfChips6;
            break;
        case 20006:
            numberOfChips7++;
            numberOfCurrent = numberOfChips7;
            break;
        case 20007:
            numberOfChips8++;
            numberOfCurrent = numberOfChips8;
            break;
        default:
            numberOfCurrent = 0;
            break;
    }
    if (numberOfCurrent>KNumberOfChipsLimit) {
        NSArray *subViews = [NSArray arrayWithArray:self.contentView.subviews];
        for (int i = 0; i<subViews.count; i++) {
            UIView *sub = subViews[i];
            if (sub.tag ==tagNum) {
                [sub removeFromSuperview];
                switch (tagNum) {
                    case 20000:
                        numberOfChips1 = numberOfChips1-1;
                        
                        break;
                    case 20001:
                        numberOfChips2= numberOfChips2-1;
                        
                        break;
                    case 20002:
                        numberOfChips3 = numberOfChips3-1;
                        
                        break;
                    case 20003:
                        numberOfChips4 = numberOfChips4-1;
                        
                        break;
                    case 20004:
                        numberOfChips5 = numberOfChips5-1;
                        
                        break;
                    case 20005:
                        numberOfChips6 = numberOfChips6-1;
                        
                        break;
                    case 20006:
                        numberOfChips7 = numberOfChips7-1;
                        
                        break;
                    case 20007:
                        numberOfChips8 = numberOfChips8-1;
                        
                        break;
                    default:
                        
                        break;
                }
                break;
            }
        }
    }
    
    return creatChipImage(moneyNum, tagNum);
}
//刷新桌面筹码
-(void)refreshChipsTexttoView:(UIView*)toView betModel:(NSString*)totalMoney uid:(long)uid
{
    UILabel *totalChip = [toView viewWithTag:101];
    //UILabel *mineChip = [toView viewWithTag:101];
//    BetBubbleView *bubble = [toView viewWithTag:1010];
    totalChip.text = [NSString stringWithFormat:@"%ld",([totalChip.text integerValue]+[totalMoney integerValue])];
//    if (model.msg.uid == [[Config getOwnID] longLongValue]) {
//        //mineChip.text =  [NSString stringWithFormat:@"%ld",([mineChip.text integerValue]+[model.msg.ct.totalmoney integerValue])];
//        UILabel *label = [toView viewWithTag:200];
//        NSString *toTitleLabelStr = @"";
//        if (label) {
//            toTitleLabelStr = label.text;
//        }
//        if (bubble.betNum!= nil && ([bubble.betNum isEqualToString:toTitleLabelStr] || ![bubble.betNum isPureInt])) {
//            [bubble setBetCount:[NSString stringWithFormat:@"%ld",([model.msg.ct.totalmoney integerValue])]];
//        }else{
//            [bubble setBetCount:[NSString stringWithFormat:@"%ld",([bubble.betNum integerValue]+[model.msg.ct.totalmoney integerValue])]];
//        }
//
//
//    }
}

//刷新时间进程
-(void)refreshTimeUI{
    if(betLeftTime > sealingTime){
        //倒计时中 倒计时动画
        int seconds = (betLeftTime-sealingTime) % 60;
        if (!isFinance) {
            
            if (contiDic.count>0) {
                self.continueBtn.enabled = true;
            }
            
            ///显示即将开始
            UIView *willReadyView = [self.contentView viewWithTag:2200];
            if (!willReadyView) {
                
                willReadyView = [UIView new];
                willReadyView.tag = 2200;
                [self.contentView addSubview:willReadyView];
                [willReadyView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(0);
                    make.bottom.mas_equalTo(-heightView-ShowDiff+130);
                    make.width.mas_equalTo(130);
                    make.height.mas_equalTo(50);
                }];
                
                UIImageView *imgVReadybg = [UIImageView new];
                imgVReadybg.image = [ImageBundle imagewithBundleName:@"game_will_begain"];
                [willReadyView addSubview:imgVReadybg];
                [imgVReadybg mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(0);
                    make.left.right.mas_equalTo(0);
                    make.top.mas_equalTo(18);
                }];
                
                UILabel *labelTip = [UILabel new];
                labelTip.textColor = RGB(252, 245, 146);
                labelTip.text = YZMsg(@"game_begain");
                labelTip.font = [UIFont boldSystemFontOfSize:20];
                labelTip.adjustsFontSizeToFitWidth = YES;
                labelTip.minimumScaleFactor = 0.1;
                [imgVReadybg addSubview:labelTip];
                [labelTip mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-8);
                    make.centerY.mas_equalTo(0);
                    make.left.mas_equalTo(40);
                }];
                
                UIButton *buttonick = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonick.tag = 100;
                [buttonick setBackgroundImage:[ImageBundle imagewithBundleName:@"game_secondimg"] forState:UIControlStateNormal];
                [buttonick setTitleColor:RGB(182, 66, 16) forState:UIControlStateNormal];
                buttonick.titleLabel.font = [UIFont boldSystemFontOfSize:16];
                [buttonick setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
                [willReadyView addSubview:buttonick];
                [buttonick mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(0);
                    make.bottom.mas_equalTo(0);
                    make.width.mas_equalTo(37);
                    make.height.mas_equalTo(40);
                }];
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
    }else{
        //封盘中 可以开始摇骰子动画
        if (!begainAnimationShaigu) {
            [self begainAnimationZP];
        }
    }
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
    [self.continueBtn setTitle:YZMsg(@"game_continue_bet") forState:UIControlStateNormal];
    self.continueBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.continueBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.continueBtn addTarget:self action:@selector(chipContinue) forControlEvents:UIControlEventTouchUpInside];
    
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
-(void)chipContinue{
    if (contiDic.count>0) {
        isContinueBet = YES;
        NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_shu1_View,self.bet_shu2_View,self.bet_shu3_View];
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
        issueContinueBet = self.curIssue;
        _continueBtn.enabled = false;
        
    }
    
    
}

//刷新桌面信息
-(void)initDeskInfo{
    NSInteger maxCount = ways.count;
    NSMutableArray <NSDictionary *> *titles = _titleSts.mutableCopy;
    for (int i=0; i<maxCount; i++) {
        // 取信息
        NSDictionary *wayInfo = [ways objectAtIndex:i];
//        NSString *name = wayInfo[@"name"];
        NSArray *options = wayInfo[@"options"];
//        if (name&&[name isEqualToString:@""]) {
            for (int x = 0; x<options.count; x++) {
                NSDictionary *subWayDic = options[x];
                NSString *title = [subWayDic objectForKey:@"title"];
                NSString *titleSt = [subWayDic objectForKey:@"st"];
                NSString *value = [subWayDic objectForKey:@"value"];
                NSInteger betall = [[subWayDic objectForKey:@"betall"] integerValue];
                NSInteger betmine = [[subWayDic objectForKey:@"betmine"] integerValue];
                NSArray *betList = [subWayDic objectForKey:@"betlist"];
                UIView *toView = nil;
                NSInteger tagChipN = 0;
                if (title&&[title isEqualToString:@"总和_大"]) {
                    toView = self.bet_big_View;
                    tagChipN = 20000;
                    UILabel *titleLabel = [self.bet_big_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_big_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_big_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_player_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_big_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(0),@"title":titleSt}];
                    }
                }else if(title&&[title isEqualToString:@"总和_小"]){
                    toView = self.bet_small_View;
                    tagChipN = 20001;
                    UILabel *titleLabel = [self.bet_small_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_small_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_small_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_equal_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_small_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];;
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(1),@"title":titleSt}];
                    }
                }else if(title&&[title isEqualToString:@"总和_单"]){
                    toView = self.bet_single_View;
                    tagChipN = 20002;
                    UILabel *titleLabel = [self.bet_single_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_single_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_single_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_bank_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_single_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(2),@"title":titleSt}];
                    }
                }else if(title&&[title isEqualToString:@"总和_双"]){
                    toView = self.bet_double_View;
                    tagChipN = 20003;
                    UILabel *titleLabel = [self.bet_double_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_double_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_double_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_bank_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_double_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(3),@"title":titleSt}];
                    }
                }else if (title&&[title isEqualToString:@"龙"]) {
                    toView = self.bet_shu1_View;
                    tagChipN = 20004;
                    UILabel *titleLabel = [self.bet_shu1_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_shu1_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_shu1_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_bank_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_shu1_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(4),@"title":titleSt}];
                    }
                }else if(title&&[title isEqualToString:@"和"]){
                    toView = self.bet_shu2_View;
                    tagChipN = 20005;
                    UILabel *titleLabel = [self.bet_shu2_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_shu2_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_shu2_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_bank_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_shu2_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(5),@"title":titleSt}];
                    }
                }else if(title&&[title isEqualToString:@"虎"]){
                    toView = self.bet_shu3_View;
                    tagChipN = 20006;
                    UILabel *titleLabel = [self.bet_shu3_View viewWithTag:200];
                    UILabel *valueLabel = [self.bet_shu3_View viewWithTag:201];
                    UILabel *betAllLabel = [self.bet_shu3_View viewWithTag:101];
                    //UILabel *betMineLabel = [self.bet_bank_View viewWithTag:101];
                    BetBubbleView *bubble = [self.bet_shu3_View viewWithTag:1010];
                    betAllLabel.text = minnum(betall);
                    [bubble setBetCount:titleSt];
                    titleLabel.text = titleSt;
                    valueLabel.text = [@"X" stringByAppendingString:value];
                    if (titles.count < options.count) {
                        [titles addObject:@{@"idx":@(6),@"title":titleSt}];
                    }
                }
                
                if (betmine > 0) {
                    LotteryBetSubView *lotterySubBetV = [self createBetSubView:toView];
                    [lotterySubBetV updateMineNumb:betmine];
                }
                
                if (betList && betList.count>0 && toView && tagChipN>0) {
                    for (NSString *betSubMoney in betList) {
                        UIImageView *imgBetChip = [self getChipImgViewWithTag:tagChipN moneyNum:betSubMoney];
                        CGPoint toRectPoint = [self toRandomRectPointtoView:toView];
                        imgBetChip.frame = CGRectMake(toRectPoint.x, toRectPoint.y, 22, 22);
                        [self.contentView addSubview:imgBetChip];
                    }
                }
//            }
        }
    }
    _titleSts = titles.copy;
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
   
    UICollectionViewFlowLayout *openlayout = [[UICollectionViewFlowLayout alloc] init];
    openlayout.minimumLineSpacing = 0;
    openlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    openlayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    openlayout.itemSize =  CGSizeMake(_window_width,32);
    self.openResultList.collectionViewLayout = openlayout;
    
    UINib *copennib=[UINib nibWithNibName:kLotteryOpenViewCell_SSC bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennib forCellWithReuseIdentifier:kLotteryOpenViewCell_SSC];
    self.openResultList.backgroundColor= RGB_COLOR(@"#000000", 0.6);
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
    if (issueContinueBet != nil && issueContinueBet.length>0 && ![self.curIssue isEqualToString:issueContinueBet]) {
        [contiDic removeAllObjects];
    }
    self.continueBtn.enabled = false;
    issueContinueBet = self.curIssue;
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
        [self doBetType:@"总和_大" chipNum:chipNum toView:self.bet_big_View];
    }else if ([tapView isEqual:self.bet_small_View]){
        [self doBetType:@"总和_小" chipNum:chipNum toView:self.bet_small_View];
    }else if ([tapView isEqual:self.bet_single_View]){
        [self doBetType:@"总和_单" chipNum:chipNum toView:self.bet_single_View];
    }else if ([tapView isEqual:self.bet_double_View]){
        [self doBetType:@"总和_双"chipNum:chipNum toView:self.bet_double_View];
    }else if ([tapView isEqual:self.bet_shu1_View]){
        [self doBetType:@"龙" chipNum:chipNum toView:self.bet_shu1_View];
    }else if ([tapView isEqual:self.bet_shu2_View]){
        [self doBetType:@"和" chipNum:chipNum toView:self.bet_shu2_View];
    }else if ([tapView isEqual:self.bet_shu3_View]){
        [self doBetType:@"虎" chipNum:chipNum toView:self.bet_shu3_View];
    }
}
//是否移除未确认筹码。  是否移除所有的筹码。 当前下注区域
-(void)canBetHidenLastBetSubView:(BOOL)isRemoveAllBetSubView isClearAll:(BOOL)isClearAll toView:(UIView*)toView
{
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_shu1_View,self.bet_shu2_View,self.bet_shu3_View];
    
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView *lotterySubBetV = [self.contentView viewWithTag:betViews[i].tag+888888];
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
        NSInteger numbers = self.contentView.subviews.count;
        NSMutableArray *subViesA = [NSMutableArray array];
        for (int i=0;i<numbers;i++ ) {
            UIView  *subView = self.contentView.subviews[i];
            if (subView.tag>100000000) {
                [subViesA addObject:subView];
            }
        }
        for (int i= 0; i<subViesA.count; i++) {
            UIView *sub = subViesA[i];
            [sub removeFromSuperview];
            NSInteger tagNum = sub.tag - 100000000;
            switch (tagNum) {
                case 20000:
                    numberOfChips1 = numberOfChips1-1;
                    
                    break;
                case 20001:
                    numberOfChips2= numberOfChips2-1;
                    
                    break;
                case 20002:
                    numberOfChips3 = numberOfChips3-1;
                    
                    break;
                case 20003:
                    numberOfChips4 = numberOfChips4-1;
                    
                    break;
                case 20004:
                    numberOfChips5 = numberOfChips5-1;
                    
                    break;
                case 20005:
                    numberOfChips6 = numberOfChips6-1;
                    
                    break;
                case 20006:
                    numberOfChips7 = numberOfChips7-1;
                    
                    break;
                case 20007:
                    numberOfChips8 = numberOfChips8-1;
                    
                    break;
                default:
                    
                    break;
            }
        }
    }

}

-(void)removeAllChip
{
    for (UIView *subV in self.contentView.subviews) {
        if (subV.tag>=2000 && subV.tag<=888888) {
            [subV removeFromSuperview];
        }
    }
}

- (LotteryBetSubView *)createBetSubView:(UIView *)toView {
    WeakSelf
    return creatBetSubView(self.contentView, toView, ^(BOOL flag) {
        STRONGSELF
        if (!strongSelf) return;
        if (flag) {
            [strongSelf doBetNetwork];
        } else {
            [strongSelf canBetHidenLastBetSubView:YES isClearAll:false toView:nil];
        }
    });
}

-(void)doBetType:(NSString*)detailType chipNum:(NSInteger)chipNum toView:(UIView*)toView {
    [self canBetHidenLastBetSubView:false isClearAll:false toView:toView];
    
    LotteryBetSubView *lotterySubBetV = [self createBetSubView:toView];
    [lotterySubBetV addBetNum:[NSString stringWithFormat:@"%ld",chipNum] ways:detailType];
    
    UIView *fromView = self.otherPlayerImgView;
    NSString *betUserId = [NSString stringWithFormat:@"%@",[Config getOwnID]];
    if (top5UserIDS && [top5UserIDS containsObject:betUserId]) {
        for (int i = 0; i<top5UserIDS.count; i++) {
            if (i<5) {
                NSString *userIDStr = top5UserIDS[i];
                if ( [userIDStr longLongValue] == [betUserId longLongValue]) {
                    fromView = [self.top5StackView viewWithTag:100+i];
                }
            }
        }
    }
    NSString *chipNumStr = [NSString stringWithFormat:@"%ld",chipNum];
    if ([detailType isEqualToString:@"总和_大"]) {
        [self animationFrom:fromView toView:self.bet_big_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20000 moneyNum:chipNumStr] uid:0];
    }else if ([detailType isEqualToString:@"总和_小"]){
        [self animationFrom:fromView toView:self.bet_small_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20001 moneyNum:chipNumStr] uid:0];
    }else if ([detailType isEqualToString:@"总和_单"]){
        [self animationFrom:fromView toView:self.bet_single_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20002 moneyNum:chipNumStr] uid:0];
    }else if ([detailType isEqualToString:@"总和_双"]){
        [self animationFrom:fromView toView:self.bet_double_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20003 moneyNum:chipNumStr] uid:0];
    }else if ([detailType isEqualToString:@"龙"]){
        [self animationFrom:fromView toView:self.bet_shu1_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20004 moneyNum:chipNumStr] uid:0];
    }else if ([detailType isEqualToString:@"和"]){
        [self animationFrom:fromView toView:self.bet_shu2_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20005 moneyNum:chipNumStr] uid:0];
    }else if ([detailType isEqualToString:@"虎"]){
        [self animationFrom:fromView toView:self.bet_shu3_View betTotalMoney:chipNumStr chipView:[self getChipImgViewWithTag:20006 moneyNum:chipNumStr] uid:0];
    }
    
}
-(void)doBetNetwork{
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_shu1_View,self.bet_shu2_View,self.bet_shu3_View];
    NSMutableArray *orders = [NSMutableArray array];
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView *lotterySubBetV = [self.contentView viewWithTag:(betViews[i].tag + 888888)];
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
        NSInteger _money = [orders[i][@"rmbMoney"] integerValue] * 1;
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
    NSString *issue = self.curIssue;

    NSInteger liveuid = [GlobalDate getLiveUID];
    NSString *liveuidstr = [NSString stringWithFormat:@"%ld", (long)liveuid];
    __block BOOL showHUDBOOL = true;
    
    NSString *betIdStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    WeakSelf
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting&uid=%@&token=%@&lottery_type=%@&money=%@&way=%@&serTime=%@&issue=%@&optionName=%@&liveuid=%@&betid=%@",[Config getOwnID],[Config getOwnToken],lottery_type,money,way,minnum([[NSDate date] timeIntervalSince1970]),issue,@"轮盘",liveuidstr,betIdStr];//User.getPlats
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
            NSArray *betViews = @[strongSelf.bet_big_View,strongSelf.bet_small_View,strongSelf.bet_single_View,strongSelf.bet_double_View,strongSelf.bet_shu1_View,strongSelf.bet_shu2_View,strongSelf.bet_shu3_View];
            for (int i = 0; i<betViews.count; i++) {
                UIView * betView = betViews[i];
                LotteryBetSubView *lotterySubBetV = [strongSelf.contentView viewWithTag:(betView.tag + 888888)];
                if (lotterySubBetV) {
                    if(lotterySubBetV.isHiddenTopView){
                        [lotterySubBetV sureBetView];
                    }
                }
            }
            for (UIView *subV in strongSelf.contentView.subviews) {
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
            if(strongSelf.selectedToolBtn.tag == 1001){
                strongSelf->betPage = 1;
                [strongSelf getBetInfo];
            }
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


-(void)updateTop5{
    NSString *lotteryTypeCu = [NSString stringWithFormat:@"%ld", curLotteryType];
    NSString *userBaseUrl1 = [NSString stringWithFormat:@"Lottery.getLiveBetRank"];
    NSDictionary *dic = @{@"lottery_type":lotteryTypeCu,
                          @"live_id":minnum([GlobalDate getLiveUID])
                   
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl1 withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (info && [info isKindOfClass:[NSArray class]]&& [(NSArray*)info count]>0) {
            [strongSelf->top5UserIDS removeAllObjects];
             NSArray *top5Users = info;
            for (int i = 0;i<strongSelf.top5StackView.subviews.count;i++) {
                UIImageView *subV = strongSelf.top5StackView.subviews[i];
                UIImageView *bolderV = [subV viewWithTag:500];
                if (!bolderV) {
                    bolderV = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, subV.width, subV.height+3)];
                    bolderV.tag = 500;
                    [subV addSubview:bolderV];
                }
                bolderV.contentMode = UIViewContentModeScaleAspectFit;
                bolderV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"top_border_%d",i+1]];
                if ([subV isKindOfClass:[UIImageView class]]) {
                    if (i<top5Users.count) {
                        NSDictionary *subD = top5Users[i];
                        NSString *uidString =  [NSString stringWithFormat:@"%lld",[[subD objectForKey:@"uid"] longLongValue]];
                        [strongSelf->top5UserIDS addObject:uidString];
                        NSString *urlPhoto = [subD objectForKey:@"photo"];
                        if (urlPhoto && urlPhoto.length>3) {
                            [subV sd_setImageWithURL:[NSURL URLWithString:urlPhoto] placeholderImage:[ImageBundle imagewithBundleName:@"top_avatar"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                if (image== nil) {
                                    subV.image = [ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"];
                                    return;
                                }
                                float height = image.size.width;
                                if (image.size.width>image.size.height) {
                                    height = image.size.height;
                                }
                                image = [image sd_resizedImageWithSize:CGSizeMake(height, height) scaleMode:SDImageScaleModeAspectFill];
                                subV.image = [image sd_imageByRoundCornerRadius:height/2.0];
                            }];
                            
                        }else{
                            subV.image = [ImageBundle imagewithBundleName:@"top_avatar"];
                        }
                    }else{
                        subV.image = [ImageBundle imagewithBundleName:@"top_avatar"];
                    }
                }
            }
        }
        
       
    }fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
}



-(void)refreshLeftCoinLabel{
    LiveUser *user = [Config myProfile];
    self.leftCoinLabel.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
}

-(void)doShowBetHistory{
    LobbyHistoryAlertController *history = [[LobbyHistoryAlertController alloc]initWithNibName:@"LobbyHistoryAlertController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    WeakSelf
    history.closeCallback = ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-ShowDiff-140, SCREEN_WIDTH, 396+ShowDiff+140);
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
        strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-ShowDiff-140, SCREEN_WIDTH, 396+ShowDiff+140);
    };
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [chipVC setLotteryType:curLotteryType];
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
        if(curLotteryType == 8){
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
        
//        cell.chipImgView.layer.cornerRadius = 19;
        if (modelChip.chipStr == selectedChipModel.chipStr) {
            [UIView animateWithDuration:0.3 animations:^{
                cell.bgView.transform = CGAffineTransformMakeScale(1.23, 1.23);
            }];
//            cell.chipImgView.layer.borderWidth = 1;
//            cell.chipImgView.layer.borderColor = [UIColor yellowColor].CGColor;
        }else{
            cell.chipImgView.layer.borderWidth = 0;
//            cell.chipImgView.layer.borderColor = [UIColor yellowColor].CGColor;
            cell.bgView.transform = CGAffineTransformIdentity;
        }
        return cell;
    }else if(collectionView == self.openResultList){
        // 赛车
        LotteryOpenViewCell_SSC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_SSC forIndexPath:indexPath];
        lastResultModel * model = self.allOpenResultData[indexPath.row];
        cell.model = model;
        return cell;
    }else if (collectionView == self.betHistoryList){
        LiveBetListYFKSCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLiveBetListYFKSCell forIndexPath:indexPath];
        cell.model = self.listModel[indexPath.row];
        return cell;
    }else{
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
        if(curLotteryType == 8){
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
        return CGSizeMake(36, 36);
    }else if (collectionView == self.openResultList){
        return CGSizeMake(_window_width, 50);
    }else if (collectionView == self.betHistoryList){
        return CGSizeMake(_window_width, 32);
    }else{
        return CGSizeMake(24,24);
    }
        
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isEqual:self.betChipCollectionView]) {
        return CGSizeMake(36, 36);
    }else if (collectionView == self.openResultList){
        return CGSizeMake(_window_width, 50);
    }else if (collectionView == self.betHistoryList){
        return CGSizeMake(_window_width, 32);
    }else{
        return CGSizeMake(24,24);
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
    }else if (collectionView == self.openResultList){
        
    }else if (collectionView == self.betHistoryList){
        
    }else{
        [self doShowHistory];
    }
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
        for (ChipsModel *model in strongSelf->chipsArraysAll) {
            if (model.isEdit) {
                model.chipNumber = amount;
                model.chipStr = [NSString stringWithFormat:@"?\n%@", [YBToolClass currencyCoverToK:[YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", amount]showUnit: NO]]];
                model.customChipNumber = model.chipNumber;
            }
        }
        [strongSelf.betChipCollectionView reloadData];
    };
}


-(void)exitView{
    
    [LotteryVoiceUtil.shared stopPlayBGM];
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared stopPlayAward];
   
    if (self.contentView.alpha<=0) {
        return;
    }
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    voiceAwardMoney = nil;
    
    if(_isExit) return;
    _isExit = true;
    [self.view layoutIfNeeded];
    [self clearSelectBetView];
    self.bottomConstraint.constant = 375;
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

-(void)dealloc
{
    NSLog(@"dealloc");
}


- (IBAction)doKey:(id)sender {
    //[self exitViewGame];
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 0;
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
        [self updateViewFrame];
    }];
}

- (IBAction)returnLive:(id)sender {
    [self exitView];
//    if (self.lotteryDelegate!= nil) {
//        [self.lotteryDelegate returnCancless];
//    }
}

-(void)exitViewGame{
    
    [LotteryVoiceUtil.shared stopPlayBGM];
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared stopPlayAward];
 
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    voiceAwardMoney = nil;
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
    if(_isExit) return;
    _isExit = true;
    [self clearSelectBetView];
    [self.view layoutIfNeeded];
    self.bottomConstraint.constant = 375;
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
        [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@2];
        if (strongSelf.lotteryDelegate!= nil) {
            [strongSelf.lotteryDelegate lotteryCancless];
        }
    }];
}

static BOOL begainAnimationShaigu;
-(void)begainAnimationZP{
//    [self backToStartPosition];
//    self.startButton.enabled = NO;
    if (_isExit) {
        return;
    }
    //移除未下注的
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_shu1_View,self.bet_shu2_View,self.bet_shu3_View];
    BOOL isRemoveAll = false;
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView *lotterySubBetV = [self.contentView viewWithTag:(betViews[i].tag + 888888)];
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
    
    [self showShaiguBoxAnimation];
}

/// 显示开奖动画
- (void)showShaiguBoxAnimation {
    [self.animationView removeFromSuperview];
    self.animationView = nil;
    
    self.animationView = [BetAnimationView_SSC new];
    self.animationView.layer.zPosition = 13;
    self.animationView.minLength = 5;
    [self.contentView addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-VK_BOTTOM_H-110);
    }];
    
    [self.contentView layoutIfNeeded];
    self.animationView.winValue = [NSString stringWithFormat:@"%@", @(rand() % 5000)];
    [self.animationView startAnimation];
}

/// 关闭开奖动画
- (void)closeShaiguBoxAnimation {
    [self.contentView layoutIfNeeded];
    NSString *result = [last_open_result stringByReplacingOccurrencesOfString:@"," withString:@""];
    self.animationView.winValue = result;
    [self.animationView stopAnimation];
    
    UIView *codeView = [self.contentView viewWithTag:99999999];
    [codeView removeFromSuperview];
    
    /// 悬浮开奖弹窗
    LotteryCodeView_Base *popCodeView = [LotteryCodeView_Base createWithType:curLotteryType];
    popCodeView.layer.cornerRadius = 5;
    popCodeView.layer.borderColor = vkColorRGB(248, 194, 66).CGColor;
    popCodeView.layer.borderWidth = 2;
    popCodeView.backgroundColor = vkColorRGBA(0, 0, 0, 0.5);
    popCodeView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    popCodeView.inset = UIEdgeInsetsMake(15, 15, 15, 15);
    popCodeView.tag = 99999999;
    popCodeView.hidden = YES;
    popCodeView.layer.zPosition = 13;
    popCodeView.resultDict = resultDict;
    [self.contentView addSubview:popCodeView];
    [popCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(self.animationView.mas_top).offset(-40);
    }];
    
    vkGcdAfter(1, ^{
        popCodeView.hidden = NO;
    });
}

-(void)clearSelectBetView
{
    NSArray<UIView*> *betViews = @[self.bet_big_View,self.bet_small_View,self.bet_single_View,self.bet_double_View,self.bet_shu1_View,self.bet_shu2_View,self.bet_shu3_View];
    for (int i = 0; i<betViews.count; i++) {
        LotteryBetSubView *lotterySubBetV = [self.contentView viewWithTag:(betViews[i].tag + 888888)];
        if (lotterySubBetV) {
            [lotterySubBetV removeFromSuperview];
        }
    }
}



// 工具栏点击事件
-(void)titleBtnClick:(UIButton *)btn{
    
    if (btn.tag == 1004){
        [self musicSwitch:btn];
        return;
    }
    
    if ([btn isEqual:self.selectedToolBtn]) {
        btn.selected = NO;
        [self rebackScrollView];
        self.selectedToolBtn = nil;
        return;
    }
    
    
//    顶部高度变化刷新聊天列表高度
    if(btn.tag < 1003){
        if (self.selectedToolBtn) {
            self.selectedToolBtn.selected = false;
        }
        btn.selected = YES;
        self.selectedToolBtn = btn;
        if (self.lotteryDelegate!= nil && !isShowTopList) {
            [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+100+ShowDiff;
            isShowTopList = YES;
            [self.lotteryDelegate refreshTableHeight:YES];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.topHeight.constant = 100;
            [self updateViewFrame];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        if(btn.tag != 1003 && btn.tag != 1004 && btn.tag != 1005&& btn.tag != 1009){
            if (self.lotteryDelegate!= nil && isShowTopList) {
                [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
                isShowTopList = NO;
                [self.lotteryDelegate refreshTableHeight:NO];
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.topHeight.constant = 0;
                [self updateViewFrame];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.chartView.hidden = YES;
                self.betHistoryList.hidden = YES;
                self.openResultList.hidden = YES;
            }];
        }
    }
    
    if (btn.tag<=1004) {
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
        } completion:^(BOOL finished) {
            
        }];
    }else if (btn.tag == 1002){
        //  开奖记录
        self.noView.hidden = YES;
        self.openResultList.hidden = NO;
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
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
       
      
        if (btn.tag == 1003){
            //  玩法说明
            popWebH5 *VC = [[popWebH5 alloc]init];
            VC.isBetExplain = YES;
            
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
                strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-ShowDiff-140, SCREEN_WIDTH, 396+ShowDiff+140);
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
                strongSelf.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-ShowDiff-140, SCREEN_WIDTH, 396+ShowDiff+140);
            };
            self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.view addSubview:VC.view];
            [self addChildViewController:VC];
            
        }else if (btn.tag == 1005){
            //  投注历史
            [self doShowBetHistory];
        }else if (btn.tag == 1006){
            //  切换新旧版
            [self rebackScrollView];
            [self exitViewFromExchange];
        }else if (btn.tag == 1007){
            //  礼物
//            [self exitView];
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate doLiwu];
            }
        }else if (btn.tag == 1008){
            //  游戏切换
            [self exitView];
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate doGame];
            }
        }else if (btn.tag == 1009){
            //  红包
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate showRedView];
            }
        }
    }
    
    
}

-(void)rebackScrollView{
    if (self.lotteryDelegate!= nil && isShowTopList) {
        [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
        isShowTopList = NO;
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
        self.chartView.hidden = YES;
        self.betHistoryList.hidden = YES;
        self.openResultList.hidden = YES;
        
    }];
}

-(void)exitViewFromExchange{
    
    [LotteryVoiceUtil.shared stopPlayBGM];
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared stopPlayAward];
    
    if (voiceAwardMoney) {
        [voiceAwardMoney stop];
    }
    voiceAwardMoney = nil;
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
    if(_isExit) return;
    _isExit = true;
    
    [self clearSelectBetView];
    [self.view layoutIfNeeded];
    self.bottomConstraint.constant = 375;
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


// 刷新开奖结果
-(void)refreshOpenListView{
    NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    int sum = 0;
    for (int i = 0; i < result_count; i++) {
        NSString * oneStr = open_result[i];
        sum = sum + [oneStr intValue];
    }
    self.shuLab.text = [NSString stringWithFormat:@"%d",sum];
    if(sum < 23){
        self.smallLab.text = @"小";
    }else{
        self.smallLab.text = @"大";
    }
    if(sum%2 == 0){
        self.openResutLab.text = @"双";
    }else{
        self.openResutLab.text = @"单";
    }
    NSInteger first = [open_result.firstObject integerValue];
    NSInteger last = [open_result.lastObject integerValue];
    if (first == last) {
        self.longLab.text = @"和";
    } else if (first > last) {
        self.longLab.text = @"龙";
    } else {
        self.longLab.text = @"虎";
    }
}

-(float)LobbyWindowHeight{
    if(isShowTopList){
        return 100;
    }else{
        return 0;
    }
}
-(void)updateViewFrame{
    self.view.frame = CGRectMake(0, SCREEN_HEIGHT-heightView-ShowDiff-[self LobbyWindowHeight], SCREEN_WIDTH, heightView+[self LobbyWindowHeight]+ShowDiff);
}

@end

