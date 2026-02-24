//
//  LotteryBetViewController_Fullscreen.m
//
//

#import "LotteryBetViewController_Fullscreen.h"
#import "BetOptionCollectionViewCell_Fullscreen.h"
#import "BetOptionCollectionViewCell.h"
#import "PayViewController.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "OpenHistoryViewController.h"
#import "IssueCollectionViewCell.h"
#import "popWebH5.h"

#import "LobbyHistoryAlertController.h"
#import "ChipChoiseCell.h"
#import "S2C.pbobjc.h"
#import "WMZDialog.h"
#import "UIView+Shake.h"
#import "ChipsModel.h"
#import "NSString+Extention.h"
#import "ChartView.h"
#import "LiveOpenListYFKSCell.h"
#import "LotteryNNModel.h"
#import "LiveBetListYFKSCell.h"
#import "BetListModel.h"
#import "LotteryOpenViewCell_SC.h"
#import "LotteryOpenViewCell_BJL.h"
#import "LotteryOpenViewCell_ZJH.h"
#import "LotteryOpenViewCell_LH.h"
#import "LotteryOpenViewCell_ZP.h"
#import "LotteryOpenViewCell_SSC.h"
#import "LotteryOpenViewCell_LHC.h"
#import "LotteryOpenViewCell_NN_Fullscreen.h"
#import "SwitchLotteryViewController.h"
#import "CustomRoundedBlurView.h"
#import "Masonry.h"
#import "LotteryNetworkUtil.h"
#import "LotteryBetModel.h"
#import "LotteryCustomChipView.h"

#import "socketLivePlay.h"
#import "hotModel.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kBetOptionCollectionViewCell_Fullscreen @"BetOptionCollectionViewCell_Fullscreen"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"
#define kChipChoiseCell @"ChipChoiseCell"
#define kLiveOpenListYFKSCell @"LiveOpenListYFKSCell"
#define kLiveBetListYFKSCell @"LiveBetListYFKSCell"

#define kLotteryOpenViewCell_SC @"LotteryOpenViewCell_SC"
#define kLotteryOpenViewCell_BJL @"LotteryOpenViewCell_BJL"
#define kLotteryOpenViewCell_ZJH @"LotteryOpenViewCell_ZJH"
#define kLotteryOpenViewCell_LH @"LotteryOpenViewCell_LH"
#define kLotteryOpenViewCell_ZP @"LotteryOpenViewCell_ZP"
#define kLotteryOpenViewCell_SSC @"LotteryOpenViewCell_SSC"
#define kLotteryOpenViewCell_LHC @"LotteryOpenViewCell_LHC"
#define kLotteryOpenViewCell_NN_Fullscreen @"LotteryOpenViewCell_NN_Fullscreen"
#define kCollectionHeader   @"LotteryCollectionHeader"
#define heightView LotteryWindowOldHeigh

@interface LotteryBetViewController_Fullscreen()<socketDelegate> {
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSMutableDictionary *allData;
    NSMutableArray *ways;   // 投注选项
    NSInteger waySelectIndex; // 当前选择的投注索引
    BOOL bUICreated; // UI是否创建
    
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSString *curIssue; // 当前期号
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *last_open_result;
    NSString *last_open_resultZH;
    
    NSMutableArray<ChipsModel*> *chipsArraysAll;
    ChipsModel *selectedChipModel;
    
    ChartView *chartSubV;
    BOOL isStop; //停止闪烁
    NSInteger openPage;
    NSInteger betPage;
    
    NSInteger _currentState;
    NSTimeInterval _currentStartTime;
    NSTimeInterval _currentEndTime;
    BOOL _netFlag; //网络锁
    NSDictionary *vsDic;
    BOOL isShowTopList; //走势图等顶部视图是否显示
    
    lastResultModel * lastOpenResult;
    NSMutableArray *didSelectOrderIndexPaths;   // 已选投注选项
    NSInteger timeReplyCount;
}
@property (nonatomic, strong) NSTimer *lotteryTime;
@property (weak, nonatomic) IBOutlet UILabel *issueNumberLabel;
@property(nonatomic,strong)NSMutableArray *allOpenResultData;
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@property(nonatomic,strong) CustomScrollView * toolScrollView;
@property(nonatomic,strong)NSMutableArray * toolBtnArr;
@property(nonatomic,strong)UIButton * selectedToolBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openResultCollectionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openResultViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openResultHeightConstraint;
@property (nonatomic, strong) socketMovieplay *socketDelegate;
@property (nonatomic, strong) CustomRoundedBlurView *customBlurView;
@end

@implementation LotteryBetViewController_Fullscreen

- (CustomRoundedBlurView *)customBlurView {
    if (!_customBlurView) {
        _customBlurView = [[CustomRoundedBlurView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    }
    return _customBlurView;
}
#pragma mark - 消息通知
- (void)createNotice {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataNotice:) name:@"moneyChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpenNotice:) name:@"LotteryOpenAward" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLotteryInfoNotice:) name:@"lotteryInfoNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTime:) name:@"lotterySecondNotify" object:nil];
}

- (void)deleteNotice {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/// 余额更新通知
- (void)refreshDataNotice:(NSNotification *)notification {
    if(!bUICreated){
        return;
    }
    NSString *leftCoin = (notification.userInfo[@"money"]);
    
    LiveUser *user = [Config myProfile];
    user.coin = minstr(leftCoin);
    [Config updateProfile:user];
    
    [self refreshLeftCoinLabel];
}
/// 开奖通知
- (void)refreshLastOpenNotice:(NSNotification *)notification {
    if(!bUICreated){
        return;
    }
    NSString * result = notification.userInfo[@"result"];
    NSString * lotteryType = minstr(notification.userInfo[@"lotteryType"]);
    if(curLotteryType>0 && [lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        //刷新历史
        if ([self.issueNumberLabel.text containsString:minstr(notification.userInfo[@"issue"])]) {
            return;
        }
        self.issueNumberLabel.text = [NSString stringWithFormat:YZMsg(@"history_betTitle%@"),minstr(notification.userInfo[@"issue"])];
        if (curLotteryType == 29) {
            NSArray *arrayResult = notification.userInfo[@"winWays"];
            if (arrayResult && [arrayResult isKindOfClass:[NSArray class]] && arrayResult.count>0) {
                last_open_result = arrayResult.firstObject;
            }else{
                last_open_result = result;
            }
            NSDictionary *zjhDic = (NSDictionary*)notification.userInfo[@"zjh"];
            NSArray *pai_type_strs = zjhDic[@"pai_type_str"];
            NSString *pairesultStr = notification.userInfo[@"result"];
            NSArray *paiA = [pairesultStr componentsSeparatedByString:@"|"];
            if(paiA.count>2 && pai_type_strs.count>2){
                NSString *paiS_1 = paiA[0];
                NSString *paiS_2 = paiA[1];
                NSString *paiS_3 = paiA[2];
                if(paiS_1 && paiS_1.length>0 && paiS_2 && paiS_2.length>0 && paiS_3 && paiS_3.length>0){
                    NSString *pai_1 = [[paiS_1 stringByReplacingOccurrencesOfString:@"玩家1:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                    NSString *pai_2 = [[paiS_2 stringByReplacingOccurrencesOfString:@"玩家2:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                    NSString *pai_3 = [[paiS_3 stringByReplacingOccurrencesOfString:@"玩家3:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                    
                    vsDic = @{@"who_win":zjhDic[@"whoWin"],@"vs":@{@"player1":@{@"pai":[pai_1 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[0]},
                                                                   @"player2":@{@"pai":[pai_2 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[1]},
                                                                   @"player3":@{@"pai":[pai_3 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[2]}}
                    };
                }
            }
            if (chartSubV) {
                [chartSubV updateChartData:last_open_result];
            }
        }else if(curLotteryType == 28){
            NSInteger whoWin =[[((NSDictionary*)notification.userInfo[@"bjl"]) objectForKey:@"whoWin"] integerValue];
            NSString *whoWinStr = @"";
            if (whoWin == 0) {
                whoWinStr = @"百家乐_庄胜";
            }else if (whoWin == 1){
                whoWinStr = @"百家乐_闲胜";
            }else if (whoWin == 2){
                whoWinStr = @"百家乐_和";
            }
            NSInteger maxCount = ways.count;
            for (int i=0; i<maxCount; i++) {
                // 取信息
                NSDictionary *wayInfo = [ways objectAtIndex:i];
                NSString *name = wayInfo[@"name"];
                NSArray *options = wayInfo[@"options"];
                if (name&&[name isEqualToString:@"百家乐"]) {
                    for (int x = 0; x<options.count; x++) {
                        NSDictionary *subWayDic = options[x];
                        NSString *title = [subWayDic objectForKey:@"title"];
                        NSString *titleSt = [subWayDic objectForKey:@"st"];
                        if ([whoWinStr isEqualToString:title]) {
                            last_open_result = titleSt;
                            last_open_resultZH = title;
                        }
                    }
                }
            }
            NSDictionary *lhDic = (NSDictionary*)notification.userInfo[@"bjl"];
            NSString *xian_dian = lhDic[@"xian_dian"];
            NSString *zhuang_dian = lhDic[@"zhuang_dian"];
            NSString *pairesultStr = notification.userInfo[@"result"];
            NSArray *paiA = [pairesultStr componentsSeparatedByString:@"|"];
            if(paiA.count>1){
                NSString *xian_paiS =paiA[0];
                NSString *zhuang_paiS = paiA[1];
                if(xian_paiS && xian_paiS.length>0 && [xian_paiS containsString:@"闲:"] && zhuang_paiS && zhuang_paiS.length>0 && [zhuang_paiS containsString:@"庄:"] ){
                    NSString *xian_p = [xian_paiS stringByReplacingOccurrencesOfString:@"闲:" withString:@""];
                    NSString *zhuang_p = [zhuang_paiS stringByReplacingOccurrencesOfString:@"庄:" withString:@""];
                    
                    vsDic = @{@"blue":@{@"pai":[xian_p componentsSeparatedByString:@","],@"dian":xian_dian},@"red":@{@"pai":[zhuang_p componentsSeparatedByString:@","],@"dian":zhuang_dian}};
                }
            }
            if (chartSubV) {
                [chartSubV updateChartData:last_open_resultZH];
            }
            
        } else if(curLotteryType == 31){
            NSInteger whoWin =[[((NSDictionary*)notification.userInfo[@"lh"]) objectForKey:@"whoWin"] integerValue];
            NSString *whoWinStr = @"";
            if (whoWin == 0) {
                whoWinStr = @"龙虎_龙";
            }else if (whoWin == 1){
                whoWinStr = @"龙虎_虎";
            }else if (whoWin == 2){
                whoWinStr = @"龙虎_和";
            }
            NSInteger maxCount = ways.count;
            for (int i=0; i<maxCount; i++) {
                // 取信息
                NSDictionary *wayInfo = [ways objectAtIndex:i];
                NSString *name = wayInfo[@"name"];
                NSArray *options = wayInfo[@"options"];
                if (name&&[name isEqualToString:@"龙虎"]) {
                    for (int x = 0; x<options.count; x++) {
                        NSDictionary *subWayDic = options[x];
                        NSString *title = [subWayDic objectForKey:@"title"];
                        NSString *titleSt = [subWayDic objectForKey:@"st"];
                        if ([whoWinStr isEqualToString:title]) {
                            last_open_result = titleSt;
                            last_open_resultZH = title;
                        }
                    }
                }
            }
            NSDictionary *lhDic = (NSDictionary*)notification.userInfo[@"lh"];
            NSString *dragon_dian = lhDic[@"dragon_dian"];
            NSString *tiger_dian = lhDic[@"tiger_dian"];
            NSString *pairesultStr = notification.userInfo[@"result"];
            NSArray *paiA = [pairesultStr componentsSeparatedByString:@"|"];
            if(paiA.count>1){
                NSString *dragon_paiS =paiA[0];
                NSString *tiger_paiS = paiA[1];
                if(dragon_paiS && dragon_paiS.length>0 && [dragon_paiS containsString:@"龙:"] && tiger_paiS && tiger_paiS.length>0 && [tiger_paiS containsString:@"虎:"] ){
                    NSString *dragon_p = [dragon_paiS stringByReplacingOccurrencesOfString:@"龙:" withString:@""];
                    NSString *tiger_p = [tiger_paiS stringByReplacingOccurrencesOfString:@"虎:" withString:@""];
                    
                    vsDic = @{@"dragon":@{@"pai":dragon_p,@"pai_type":dragon_dian},@"tiger":@{@"pai":tiger_p,@"pai_type":tiger_dian}};
                }
            }
            if (chartSubV) {
                [chartSubV updateChartData:last_open_resultZH];
            }
        }else{
            
            last_open_result = result;
            if (chartSubV) {
                [chartSubV updateChartData:last_open_result];
            }
        }
        
        
        if(self.selectedToolBtn.tag == 1001){
            betPage = 1;
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf getBetInfo];
            });
        }
        if(self.selectedToolBtn.tag != 1002){
            [self.openResultCollection reloadData];
            
            
        }else{
            [self getOpenResultInfo];
        }
        
        
    }
}
/// 期号更新通知
- (void)refreshLotteryInfoNotice:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    VKLOG(@"%@", dict);
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
- (void)setupView {
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    openPage = 0;
    betPage = 1;
    _netFlag = YES;
    isShowTopList = YES;
    [self createToolScorllview];
    self.contentView.hidden = NO;
    self.lotteryName.text = self.lotteryNameStr;
    waySelectIndex = 0;
    // 监听按钮事件[充值]253, 156, 39
    self.chargeBtn.backgroundColor =  RGB_COLOR(@"#000000", 0.7);
    [self.chargeBtn addTarget:self action:@selector(doCharge:) forControlEvents:UIControlEventTouchUpInside];
    // 监听按钮事件[投注]
    [self.betBtn addTarget:self action:@selector(doBet) forControlEvents:UIControlEventTouchUpInside];

    didSelectOrderIndexPaths = [NSMutableArray array];
    UIImageView * bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    bg.image = [ImageBundle imagewithBundleName:@"sy_bj"];
    [self.view addSubview: bg];
    [self.view addSubview:self.customBlurView];
    [self.view sendSubviewToBack:self.customBlurView];
    [self.view sendSubviewToBack:bg];
    [self.customBlurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.rightCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.openResultCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    // 菊花
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor whiteColor];
    [testActivityIndicator startAnimating]; // 开始旋转
    [testActivityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    
    chipsArraysAll = [[ChipsListModel sharedInstance] chipListArrays];
    selectedChipModel = chipsArraysAll[0];
    
    [self.betBtn setTitle:YZMsg(@"LobbyLotteryVC_Bet") forState:UIControlStateNormal];
    
    self.chartView.backgroundColor = [UIColor clearColor];
    chartSubV = [ChartView instanceChatViewWithType:curLotteryType];
    [self.chartView addSubview:chartSubV];
    
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
    
    
    switch (curLotteryType) {
        case 26:
        case 8:
        case 14:
        case 11:
        case 6:
        case 27:
            [chartSubV updateMenueStr1:YZMsg(@"Chart_Area_big_small") Str2:YZMsg(@"Chart_Area_single_double")];
            break;
        case 30:
            [chartSubV updateMenueStr1:YZMsg(@"Chart_Area_big_small") Str2:YZMsg(@"Chart_Area_red_black")];
            break;
            
            break;
        default:
            break;
    }
    
    if (curLotteryType==28||curLotteryType==29||curLotteryType==31) {
        _openResultCollectionHeight.constant = 50;
    }else{
        _openResultCollectionHeight.constant = 30;
    }
    
    [self.view layoutIfNeeded];
}
- (void)loadBetInfo {
    if(!bUICreated){
        self.rightCollection.hidden = YES;
    }
    WeakSelf
    [LotteryNetworkUtil getHomeBetViewInfo:curLotteryType block:^(NetworkData *networkData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.navigationController popViewControllerAnimated:YES];
            return;
        }
        LotteryBetModel *model = [LotteryBetModel modelFromJSON:networkData.data];
        /// 更新余额
        [Config updateMoney:model.left_coin];
        [strongSelf addNodeServer:model.lobbyServer];
        
        if (model.timeOffset > 0) {
            
        } else {
            [strongSelf createTimer];
        }
        strongSelf->allData = [NSMutableDictionary dictionaryWithDictionary: networkData.data];
        
        NSDictionary *dict = strongSelf->allData[@"lastResult"];
        
        strongSelf->allData[@"openTime"] = [NSDate dateWithTimeInterval:[strongSelf->allData[@"time"] integerValue] sinceDate:[NSDate date]];
        
        if(strongSelf->curLotteryType == 29) {
            strongSelf->vsDic = dict;
        } else {
            strongSelf->vsDic = dict[@"vs"];
        }
        
        if (dict) {
            strongSelf->last_open_result = dict[@"open_result"];
            strongSelf->last_open_resultZH = dict[@"open_result_zh"];
        } else {
            strongSelf->last_open_result = @"";
        }
        
        strongSelf.issueNumberLabel.text = [NSString stringWithFormat:YZMsg(@"history_betTitle%@"),dict[@"issue"]];
        NSMutableArray *arr = [strongSelf->allData[@"ways"] mutableCopy];
        if (strongSelf->curLotteryType == 8 || strongSelf->curLotteryType == 7||strongSelf->curLotteryType == 32) {
            id firstObj = [arr objectAtIndex:0];
            id secondObj = [arr objectAtIndex:1];
            id thirdObj = [arr objectAtIndex:2];
            [arr removeAllObjects];
            [arr addObject:thirdObj];
            [arr addObject:firstObj];
            [arr addObject:secondObj];
            NSMutableDictionary *allOptions = [[NSMutableDictionary alloc] init];
            NSMutableArray *optionsArray = [NSMutableArray array];
            [allOptions setObject:optionsArray forKey:@"options"];
            [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                [[allOptions objectForKey:@"options"] addObjectsFromArray: dic[@"options"]];
            }];
            NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
            NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
            [dictionaryA setObject: allOptions[@"options"] forKey:@"options"];
            strongSelf->ways = arrayOfDictionaries;
        }  else if (strongSelf->curLotteryType == 10) {
            if (arr.count > 3) {
                id firstObj = [arr objectAtIndex:0];
                id secondObj = [arr objectAtIndex:1];
                id thirdObj = [arr objectAtIndex:2];
                id fourObj = [arr objectAtIndex:3];
                [arr removeAllObjects];
                [arr addObject:thirdObj];
                [arr addObject:fourObj];
                [arr addObject:secondObj];
                [arr addObject:firstObj];
                NSMutableDictionary *allOptions = [[NSMutableDictionary alloc] init];
                NSMutableArray *optionsArray = [NSMutableArray array];
                [allOptions setObject:optionsArray forKey:@"options"];
                [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx == 0) {
                        NSMutableArray *arr = [dic[@"options"] mutableCopy];
                        id firstObj = [arr firstObject];
                        [arr removeObjectAtIndex:0];
                        [arr insertObject:firstObj atIndex:1];
                        [[allOptions objectForKey:@"options"] addObject: arr];
                    } else if (idx == 1) {
                        [[allOptions objectForKey:@"options"][0] addObjectsFromArray: dic[@"options"]];
                    } else {
                        [[allOptions objectForKey:@"options"] addObject: dic[@"options"]];
                    }
                }];
                NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
                NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
                [dictionaryA setObject: allOptions[@"options"] forKey:@"options"];
                strongSelf->ways = arrayOfDictionaries;
            }
        }
        else if (strongSelf->curLotteryType == 14) { //將一分賽車options順序調整
            NSArray *arr1 = [arr firstObject][@"options"];
            NSArray *optionsArr1 = [arr1 firstObject][@"data"]; //大,小,單,雙,大單,大雙,小單,小雙
            NSArray *arr2 = arr[3][@"options"];
            NSArray *optionsArr2 = arr2[1][@"data"]; // 3~19
            NSArray * mergeArr = [optionsArr1 arrayByAddingObjectsFromArray: optionsArr2];
            NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
            NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
            [dictionaryA setObject: mergeArr forKey:@"options"];
            strongSelf->ways = arrayOfDictionaries;
        }
        else if (strongSelf->curLotteryType == 29) { //將炸金花options順序調整
            NSDictionary *dic = [arr firstObject];
            NSMutableArray *optionsArr = [NSMutableArray arrayWithArray: dic[@"options"]];
            id obj1 = [optionsArr objectAtIndex:3]; // 三條
            id obj2 = [optionsArr objectAtIndex:4]; // 同花順
            id obj3 = [optionsArr objectAtIndex:5]; // 同花
            id obj4 = [optionsArr objectAtIndex:6]; // 順子
            [optionsArr removeObjectsInRange:NSMakeRange(3, optionsArr.count - 3)];
            [optionsArr insertObject:obj4 atIndex:3];
            [optionsArr insertObject:obj3 atIndex:4];
            [optionsArr insertObject:obj2 atIndex:5];
            [optionsArr insertObject:obj1 atIndex:6];
            NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
            NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
            [dictionaryA setObject: optionsArr forKey:@"options"];
            strongSelf->ways = arrayOfDictionaries;
        }
        else if (strongSelf->curLotteryType == 30) { //將輪盤options順序調整
            NSDictionary *dic = [arr firstObject];
            NSMutableArray *optionsArr = [NSMutableArray arrayWithArray: dic[@"options"]];
            id obj1 = [optionsArr objectAtIndex:0]; // 1-12
            id obj2 = [optionsArr objectAtIndex:1]; // 13-24
            id obj3 = [optionsArr objectAtIndex:2]; // 25-36
            id obj4 = [optionsArr objectAtIndex:3]; // 紅色
            id obj5 = [optionsArr objectAtIndex:4]; // 黑色
            id obj6 = [optionsArr objectAtIndex:5]; // 大
            id obj7 = [optionsArr objectAtIndex:6]; // 小
            [optionsArr removeObjectsInRange:NSMakeRange(0, 7)];
            [optionsArr insertObject:obj6 atIndex:0];
            [optionsArr insertObject:obj7 atIndex:1];
            [optionsArr insertObject:obj4 atIndex:2];
            [optionsArr insertObject:obj5 atIndex:3];
            [optionsArr insertObject:obj1 atIndex:4];
            [optionsArr insertObject:obj2 atIndex:5];
            [optionsArr insertObject:obj3 atIndex:6];
            NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
            NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
            [dictionaryA setObject: optionsArr forKey:@"options"];
            strongSelf->ways = arrayOfDictionaries;
        } else if (strongSelf->curLotteryType == 26 || strongSelf->curLotteryType == 27) {
            id oneObj = [arr objectAtIndex:0];  // 猜總和
            id fiveObj = [arr objectAtIndex:4]; // 猜圍毆
            id threeObj = [arr objectAtIndex:3];// 猜對子
            id sixObj = [arr objectAtIndex:5];  // 猜單摋
            [arr removeAllObjects];
            [arr addObject:oneObj];
            [arr addObject:fiveObj];
            [arr addObject:threeObj];
            [arr addObject:sixObj];
            NSMutableDictionary *allOptions = [[NSMutableDictionary alloc] init];
            NSMutableArray *optionsArray = [NSMutableArray array];
            [allOptions setObject:optionsArray forKey:@"options"];
            [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == 1) {
                    NSMutableArray *arr = [dic[@"options"] mutableCopy];
                    id lastObj = [arr lastObject];
                    [arr removeLastObject];
                    [arr insertObject:lastObj atIndex:3]; // 把猜圍毆"1-6"移到中間
                    [[allOptions objectForKey:@"options"] addObjectsFromArray: arr];
                } else {
                    [[allOptions objectForKey:@"options"] addObjectsFromArray: dic[@"options"]];
                }
            }];
            NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
            NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
            [dictionaryA setObject: allOptions[@"options"] forKey:@"options"];
            strongSelf->ways = arrayOfDictionaries;
        } else {
            NSMutableDictionary *allOptions = [[NSMutableDictionary alloc] init];
            NSMutableArray *optionsArray = [NSMutableArray array];
            [allOptions setObject:optionsArray forKey:@"options"];
            [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                [[allOptions objectForKey:@"options"] addObjectsFromArray: dic[@"options"]];
            }];
            NSMutableArray *arrayOfDictionaries = [NSMutableArray arrayWithObject:[[strongSelf->allData[@"ways"] firstObject] mutableCopy]];
            NSMutableDictionary *dictionaryA = [arrayOfDictionaries firstObject];
            [dictionaryA setObject: allOptions[@"options"] forKey:@"options"];
            strongSelf->ways = arrayOfDictionaries;
        }
        
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
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter postNotificationName:@"KHomeSocketDeleteKey" object:nil];
    [self setupView];
    [self loadBetInfo];
    [self createNotice];
    [self getOpenResultInfo];
    //彩票计时器
    [self createTimer];
}
- (void)viewWillAppear:(BOOL)animated {
    
}
- (void)viewDidAppear:(BOOL)animated {
    
}
- (BOOL)scrollView:(UIScrollView *)scrollView touchesShouldCancelInContentView:(UIView *)view {
    return YES;
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
    
    
    NSArray * imgArr = @[@"yfks_icon_zst",@"yfks_icon_tzjl",@"yfks_icon_kjjl",@"yfks_icon_wfsm",@"yfks_icon_lstz",@"yfks_icon_qhjb",@"yfks_icon_game"];
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


// 开奖历史
- (void)getOpenResultInfo{
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


-(void)exitView{
    [self deleteSocket];
    [self deleteTimer];
    [self deleteNotice];
    if (self.contentView.alpha<=0) {
        return;
    }
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
    if(_isExit) return;
    _isExit = true;
    
    
    if (self.lotteryDelegate!= nil && isShowTopList) {
        isShowTopList = NO;
        [self.lotteryDelegate refreshTableHeight:NO];
    }
    [GameToolClass setCurOpenedLotteryType:0];
    
    if (self.lotteryDelegate!= nil) {
        [self.lotteryDelegate lotteryCancless];
    }
    [self.navigationController popViewControllerAnimated:true];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)exitViewFromExchange{
    [self deleteSocket];
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
    if(_isExit) return;
    _isExit = true;
    
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
        [GameToolClass setCurOpenedLotteryType:strongSelf->curLotteryType];
        [self deleteNotice];
        if (strongSelf.lotteryDelegate!= nil) {
            [strongSelf.lotteryDelegate exchangeVersionToNew:strongSelf->curLotteryType];
        }
    }];
}
- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
    [GameToolClass setCurOpenedLotteryType:lotteryType];
}

-(void)refreshUI{
    if(!ways){
        ways = [NSMutableArray array];
    }
    if(!bUICreated){
        [self initUI];
    }
    self.rightCollection.hidden = NO;
    self.openResultCollection.hidden = NO;
    // 刷新彩种名字
    self.lotteryName.text = allData[@"name"];
    // 刷新彩种logo
    self.logo.contentMode = UIViewContentModeScaleAspectFit;
    WeakSelf
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:minstr(allData[@"logo"])]
                      options:1
                     progress:nil
                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        STRONGSELF
        if (image && strongSelf !=nil) {
            
            [strongSelf.logo setImage:image];
        }
    }];
    
    // 更新倒计时时间
    betLeftTime = [allData[@"time"] integerValue];
    sealingTime = [allData[@"sealingTim"] integerValue];
    curIssue = allData[@"issue"];
    self.leftTimeLabel.layer.shadowRadius = 5.0;
    
    if(betLeftTime > sealingTime){
        self.leftTimeTitleLabel.text = YZMsg(@"LotteryBetVC_TimeTitle");
        self.leftTimeLabel.text = [YBToolClass timeFormatted:(betLeftTime - sealingTime)];
    }else{
        self.leftTimeTitleLabel.text = [NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), sealingTime - (sealingTime - betLeftTime)];
        self.leftTimeTitleLabel.adjustsFontSizeToFitWidth = YES;
        self.leftTimeTitleLabel.minimumScaleFactor = 0.5;
        self.leftTimeLabel.text = @"";
    }
    
    // 更新余额
    [self refreshLeftCoinLabel];
    
}

-(void)initUI{
    bUICreated = true;
    // 初始化投注选项
    [self initCollection];
    
}
- (void)exchangeVersion:(UIButton *)sender{
    [self exitViewFromExchange];
}

- (void)refreshTime:(NSNotification *)notification {
    if(!bUICreated){
        return;
    }
    NSInteger betLeftTime = [(notification.userInfo[@"betLeftTime"]) integerValue];
    NSInteger sealingTime = [(notification.userInfo[@"sealingTime"]) integerValue];
    NSString * issue = minstr(notification.userInfo[@"issue"]);
    NSString * lotteryType = minstr(notification.userInfo[@"lotteryType"]);
    if(curLotteryType>0 && [lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        curIssue = issue;
        self.leftTimeTitleLabel.text = YZMsg(@"LotteryBetVC_TimeTitle");
        if(betLeftTime > sealingTime){
            self.leftTimeLabel.text = [YBToolClass timeFormatted:(betLeftTime-sealingTime)];
        }else{
            if(betLeftTime > 0){
                self.leftTimeLabel.text = [NSString stringWithFormat:@"%@(%ld)", YZMsg(@"LobbyLotteryVC_betEnd"),sealingTime - (sealingTime - betLeftTime)];
                self.leftTimeTitleLabel.adjustsFontSizeToFitWidth = YES;
                self.leftTimeTitleLabel.minimumScaleFactor = 0.5;
            }else{
                self.leftTimeLabel.text = YZMsg(@"LobbyLotteryVC_betOpen");
            }
        }
    }
    timeReplyCount ++;
    if (timeReplyCount % 3 == 0) {
        if (self.socketDelegate) {
            NSString *lotteryType = [NSString stringWithFormat:@"%ld", curLotteryType];
            [self.socketDelegate sendSyncLotteryCMD:lotteryType];
        }
        return;
    }
}

-(void)refreshLeftCoinLabel{
    LiveUser *user = [Config myProfile];
    self.leftCoinLabel.text =  [YBToolClass getRateBalance:user.coin showUnit:YES];
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
-(void)doBet{
    // 生成确认界面需要的信息
    NSMutableArray * orders = [NSMutableArray array];
    NSDictionary *dict = ways[waySelectIndex];
    
    if (curLotteryType == 10) {
        [didSelectOrderIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *selectOption = dict[@"options"][indexPath.section][indexPath.row];
            NSMutableDictionary *order = [NSMutableDictionary dictionary];
            [order setObject:selectOption[@"st"] forKey:@"st"];
            [order setObject:selectOption[@"title"] forKey:@"way"];
            [order setObject:[NSString stringWithFormat:@"%f", selectedChipModel.chipNumber] forKey:@"money"];
            [orders addObject:order];
        }];
    } else {
        NSArray *array = dict[@"options"];
        [didSelectOrderIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *selectOption = [array objectAtIndex:indexPath.row];
            NSMutableDictionary *order = [NSMutableDictionary dictionary];
            [order setObject:selectOption[@"st"] forKey:@"st"];
            [order setObject:selectOption[@"title"] forKey:@"way"];
            [order setObject:[NSString stringWithFormat:@"%f", selectedChipModel.chipNumber] forKey:@"money"];
            [orders addObject:order];
        }];
    }
    
    if(orders.count == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyBet_selecte_Warning")];
        return;
    }
    BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    betConfirmVC.isShowTopList = isShowTopList;
    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
        [betConfirmVC.view removeFromSuperview];
        [betConfirmVC removeFromParentViewController];
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
        [shadowView removeFromSuperview];
        [weakbetConfirmVC.view removeFromSuperview];
        [weakbetConfirmVC removeFromParentViewController];
    };
    [self.view addSubview:betConfirmVC.view];
    betConfirmVC.view.bottom = self.view.bottom;
    [self addChildViewController:betConfirmVC];
    return;
}

- (void)clickHistoryBetAction:(BetListDataModel *)item {
    BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    betConfirmVC.isShowTopList = isShowTopList;
    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
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
        [shadowView removeFromSuperview];
        [weakbetConfirmVC.view removeFromSuperview];
        [weakbetConfirmVC removeFromParentViewController];
    };
    [self.view addSubview:betConfirmVC.view];
    betConfirmVC.view.bottom = self.view.bottom;
    [self addChildViewController:betConfirmVC];
    return;
}

-(void)doCharge:(UIButton *)sender{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
}

#pragma mark   --- 大廳佈局 ---
-(void)reloadLayout
{
    FLLayout * l = (FLLayout*)self.rightCollection.collectionViewLayout;
    NSDictionary *dict =ways[waySelectIndex];
    NSArray *array = dict[@"options"];
    l.insets = UIEdgeInsetsMake(2, 7, 2, 7);
    float matchW = (kScreenWidth / array.count) - 6; // 6是最小间距
    float scaleRateX = 0, scaleRateY = 0;
    CGSize size = CGSizeZero;
    float valueSpace = 40;
    if(array.count <= 12){
        if (array.count<=5) {
            scaleRateX = MAX(MIN(matchW, 80), 65) / 80;
            scaleRateY = scaleRateX;
            
            if (array.count == 2) {
                size = CGSizeMake(80 * scaleRateX*2, 105 * scaleRateY);
            }else{
                size = CGSizeMake(80 * scaleRateX, 105 * scaleRateY);
            }
            
            valueSpace = MAX((kScreenWidth  - size.width * array.count)/array.count+AD(20)/array.count, 6);
        }else{
            if (array.count==6) {
                size = CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 3)-3*3, 6);
            }else if (array.count==7){
                size = CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 4)-4*5, 6);
            }else if(array.count == 8){
                size = CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 4)-4*3, 6);
            }else if(array.count == 9){
                size = CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 5)-5*3, 3);
            }else if(array.count == 10){
                size = CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 5)-5*3, 6);
            }else if (array.count==11) {
                size = CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 6)-6*3, 6);
            }else{
                size = CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width *6)-6*3 ,6);
            }
        }
    }else{
        scaleRateX = MAX(MIN(matchW, 80), 45) / 80;
        scaleRateY = scaleRateX;
        size = CGSizeMake(80 * scaleRateX, 105 * scaleRateY);
        int numberLinePeer = floor(kScreenWidth/size.width*1.0);
        valueSpace = MAX((kScreenWidth  - size.width * numberLinePeer)-numberLinePeer*3 ,6);
        
    }
    
    NSInteger lineCount = array.count/2;
    
    if (lineCount>=3) {
        if (array.count%2 == 0) {
            valueSpace = MAX((kScreenWidth  - size.width * (array.count/2))-(array.count/2)*3, 6);
        }
        l.insets = UIEdgeInsetsMake(2, (valueSpace/2.0)*(kScreenWidth/414), 2, 7);
    }else{
        l.insets = UIEdgeInsetsMake(2, (valueSpace/2.0), 2, 7);
    }
    [l resetDict];
}
- (void)initCollection {
    
    if (curLotteryType == 10) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        layout.headerReferenceSize = CGSizeMake(100, 22);
        layout.minimumLineSpacing = 0.0f;
        self.rightCollection.collectionViewLayout = layout;
    } else {
        FLLayout *layout = [[FLLayout alloc]init];
        layout.dataSource = self;
        self.rightCollection.collectionViewLayout = layout;
    }
    
    self.rightCollection.delegate = self;
    self.rightCollection.dataSource = self;
    self.rightCollection.delaysContentTouches = NO;
    
    self.rightCollection.clipsToBounds = YES;
    self.rightCollection.allowsMultipleSelection = YES;
    
    UINib *nib=[UINib nibWithNibName:kBetOptionCollectionViewCell_Fullscreen bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kBetOptionCollectionViewCell_Fullscreen];
    UINib *header=[UINib nibWithNibName:kCollectionHeader bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionHeader];
    self.rightCollection.backgroundColor=[UIColor clearColor];
    
    // 最后一期开奖
    
    if (curLotteryType==28||curLotteryType==29||curLotteryType==31) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.openResultCollection.collectionViewLayout = layout;
    }else{
        EqualSpaceFlowLayoutEvolve *flowLayout = [[EqualSpaceFlowLayoutEvolve alloc]    initWthType:AlignWithRight];
        flowLayout.betweenOfCell = 1;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
        self.openResultCollection.collectionViewLayout = flowLayout;
    }
    self.openResultCollection.delegate = self;
    self.openResultCollection.dataSource = self;
    UINib *nib2=[UINib nibWithNibName:kIssueCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.openResultCollection registerNib: nib2 forCellWithReuseIdentifier:kIssueCollectionViewCell];
    
    self.openResultCollection.backgroundColor=[UIColor clearColor];
    
    UICollectionViewFlowLayout *chiplayout = [[UICollectionViewFlowLayout alloc] init];
    chiplayout.minimumLineSpacing = 1;
    chiplayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    chiplayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    chiplayout.itemSize =  CGSizeMake(40,40);
    self.betChipCollectionView.collectionViewLayout = chiplayout;
    
    UINib *chipnib=[UINib nibWithNibName:kChipChoiseCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.betChipCollectionView registerNib: chipnib forCellWithReuseIdentifier:kChipChoiseCell];
    self.betChipCollectionView.backgroundColor=[UIColor clearColor];
    self.betChipCollectionView.delegate = self;
    self.betChipCollectionView.dataSource = self;
    self.rightCollection.allowsMultipleSelection = YES;
    
    
    UICollectionViewFlowLayout *openlayout = [[UICollectionViewFlowLayout alloc] init];
    openlayout.minimumLineSpacing = 0;
    openlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    openlayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    openlayout.itemSize =  CGSizeMake(_window_width,32);
    self.openResultList.collectionViewLayout = openlayout;
    
    UINib *copennib=[UINib nibWithNibName:kLiveOpenListYFKSCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennib forCellWithReuseIdentifier:kLiveOpenListYFKSCell];
    
    UINib *copennibSC=[UINib nibWithNibName:kLotteryOpenViewCell_SC bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennibSC forCellWithReuseIdentifier:kLotteryOpenViewCell_SC];
    [self.openResultCollection registerNib: copennibSC forCellWithReuseIdentifier:kLotteryOpenViewCell_SC];
    UINib *copennibBJL=[UINib nibWithNibName:kLotteryOpenViewCell_BJL bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennibBJL forCellWithReuseIdentifier:kLotteryOpenViewCell_BJL];
    UINib *copennibZJH=[UINib nibWithNibName:kLotteryOpenViewCell_ZJH bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.openResultCollection registerNib: copennibBJL forCellWithReuseIdentifier:kLotteryOpenViewCell_BJL];
    [self.openResultList registerNib: copennibZJH forCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH];
    [self.openResultCollection registerNib: copennibZJH forCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH];
    
    UINib *copennibLH=[UINib nibWithNibName:kLotteryOpenViewCell_LH bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultCollection registerNib: copennibLH forCellWithReuseIdentifier:kLotteryOpenViewCell_LH];
    [self.openResultList registerNib: copennibLH forCellWithReuseIdentifier:kLotteryOpenViewCell_LH];
    UINib *copennibZP=[UINib nibWithNibName:kLotteryOpenViewCell_ZP bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennibZP forCellWithReuseIdentifier:kLotteryOpenViewCell_ZP];
    UINib *copennibSSC=[UINib nibWithNibName:kLotteryOpenViewCell_SSC bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennibSSC forCellWithReuseIdentifier:kLotteryOpenViewCell_SSC];
    UINib *copennibLHC=[UINib nibWithNibName:kLotteryOpenViewCell_LHC bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultList registerNib: copennibLHC forCellWithReuseIdentifier:kLotteryOpenViewCell_LHC];
    UINib *copennibNN=[UINib nibWithNibName:kLotteryOpenViewCell_NN_Fullscreen bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [self.openResultCollection registerNib: copennibNN forCellWithReuseIdentifier:kLotteryOpenViewCell_NN_Fullscreen];
    [self.openResultList registerNib: copennibNN forCellWithReuseIdentifier:kLotteryOpenViewCell_NN_Fullscreen];
    
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
    
    if (curLotteryType != 10) {
        [self reloadLayout];
    }
    [self.rightCollection reloadData];
    [self.betChipCollectionView reloadData];
    [self.openResultList reloadData];
    [self.betHistoryList reloadData];
    
}

#pragma mark---imageCollectionView--------------------------
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(collectionView == self.rightCollection){
        if (ways.count==0) {
            return 0;
        } else if (curLotteryType == 10) {
            return ((NSMutableArray*)ways[waySelectIndex][@"options"]).count;
        }
        return 1;
    }else{
        return 1;
    }
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == self.rightCollection){
        if (ways.count==0) {
            return 0;
        }
        
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        if(!array){
            return 0;
        }
        if (curLotteryType == 10) {
            return ((NSMutableArray*)array[section]).count;
        }
        return array.count;
    }else if (collectionView ==self.betChipCollectionView) {
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
        } else if (curLotteryType == 10 || curLotteryType == 14) {
            result_count = 1;
        }
        return result_count;
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section{
    if(collectionView == self.rightCollection){
        if (ways.count==0) {
            return 0;
        }
        
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        if(!array){
            return 0;
        }
        return array.count;
    }else if (collectionView ==self.betChipCollectionView) {
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
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        BetOptionCollectionViewCell_Fullscreen *cell=[collectionView cellForItemAtIndexPath:indexPath];
        
        [didSelectOrderIndexPaths addObject:indexPath];
        
        cell.selected = YES;
    }else if (collectionView ==self.betChipCollectionView) {
        NSArray *chipsModelList = chipsArraysAll;
        ChipsModel *model = chipsModelList[indexPath.row];
        if (model.isEdit && ([common getCustomChipNum]<=0||selectedChipModel.chipNumber == model.chipNumber)) {
            [self doCustomChip];
        }else{
            selectedChipModel = chipsArraysAll[indexPath.row];
            [self.betChipCollectionView reloadData];
        }
    }else{
        [self doShowHistory];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        BetOptionCollectionViewCell_Fullscreen *cell=[collectionView cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        [didSelectOrderIndexPaths removeObject:indexPath];
    }else if (collectionView == self.openResultList){
        
    }else if (collectionView == self.betHistoryList){
        
    }else{
  
    }
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        BetOptionCollectionViewCell_Fullscreen *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kBetOptionCollectionViewCell_Fullscreen forIndexPath:indexPath];
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array;
        if (curLotteryType == 10) {
            array = dict[@"options"][indexPath.section];
        } else {
            array = dict[@"options"];
        }
        if ([didSelectOrderIndexPaths containsObject:indexPath]) {
            cell.selected = NO;
        }
        NSInteger optionIndex = indexPath.row;
        NSLog(@"%@", [NSString stringWithFormat:@"设置%ld个为%@",(long)optionIndex, array[optionIndex][@"title"]]);
        NSString *desc = array[optionIndex][@"desc"];
        cell.way = array[optionIndex][@"title"];
        cell.titleLabel.text= array[optionIndex][@"st"];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMinimumFractionDigits:0];
        NSNumber *number = [numberFormatter numberFromString:array[optionIndex][@"value"]];
        cell.rate.text = [numberFormatter stringFromNumber:number];
        cell.backgroundColor=[UIColor clearColor];
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.imageView.image = [UIImage sd_imageWithColor: RGB_COLOR(@"#000000", 0.22) size:CGSizeMake(280, 280)];
        cell.tipBtn.tag = indexPath.row;
        [cell.tipBtn addTarget:self action:@selector(doOptionClick:) forControlEvents:UIControlEventTouchUpInside];
        if(desc){
            if (curLotteryType == 10 || curLotteryType == 11 || curLotteryType == 14 || curLotteryType == 6) {
                cell.tipBtn.hidden = YES;
            } else {
                cell.tipBtn.hidden = NO;
            }
        }else{
            cell.tipBtn.hidden = YES;
        }
        if (curLotteryType == 26 || curLotteryType == 27) {
            [cell setImage];
        }
        return cell;
    }else if (collectionView ==self.betChipCollectionView) {
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
        
        
        cell.chipImgView.layer.cornerRadius = 18;
        if (modelChip.chipStr == selectedChipModel.chipStr) {
            [UIView animateWithDuration:0.3 animations:^{
                cell.bgView.transform = CGAffineTransformMakeScale(1.23, 1.23);
                [self.contentView layoutIfNeeded];
            }];
            cell.chipImgView.layer.borderWidth = 1;
            cell.chipImgView.layer.borderColor = [UIColor yellowColor].CGColor;
        }else{
            cell.chipImgView.layer.borderWidth = 0;
            cell.chipImgView.layer.borderColor = [UIColor yellowColor].CGColor;
            cell.bgView.transform = CGAffineTransformIdentity;
        }
        return cell;
    }else if(collectionView == self.openResultList){
        if(curLotteryType == 11 || curLotteryType == 6){
            // 时时彩
            LotteryOpenViewCell_SSC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_SSC forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            [cell updateConstraintsForFullscreen];
            return cell;
        }else if(curLotteryType == 14 || curLotteryType == 9){
            // 赛车
            LotteryOpenViewCell_SC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_SC forIndexPath:indexPath];
            lastOpenResult = self.allOpenResultData[indexPath.row];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            [cell updateConstraintsForFullscreen];
            return cell;
        }else if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            // 六合彩
            LotteryOpenViewCell_LHC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LHC forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            return cell;
        }else if(curLotteryType == 10){
            // 百人牛牛
            LotteryOpenViewCell_NN_Fullscreen *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_NN_Fullscreen forIndexPath:indexPath];
            lastOpenResult = self.allOpenResultData[indexPath.row];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            return cell;
        }else if(curLotteryType == 28){
            LotteryOpenViewCell_BJL *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_BJL forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            [cell updateConstraintsForFullscreen];
            return cell;
        }else if(curLotteryType == 30){
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
        }else if(curLotteryType == 29){
            LotteryOpenViewCell_ZJH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH forIndexPath:indexPath];
            
            NSDictionary * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            [cell updateConstraintsForFullscreen];
            return cell;
        }else if(curLotteryType == 31){
            LotteryOpenViewCell_LH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LH forIndexPath:indexPath];
            NSDictionary * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            [cell updateConstraintsForFullscreen];
            return cell;
        }else{
            LiveOpenListYFKSCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLiveOpenListYFKSCell forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            [cell updateConstraintsForFullscreen];
            return cell;
        }
    }else if (collectionView == self.betHistoryList){
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
    }else{
        if (curLotteryType == 10) {
            self.openResultViewHeight.constant = 130;
            self.openResultCollectionHeight.constant = 50;
            LotteryOpenViewCell_NN_Fullscreen *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_NN_Fullscreen forIndexPath:indexPath];
            cell.model = lastOpenResult;
            [cell updateConstraintsForLastResultCollection];
            [cell.issueLab setHidden: YES];
            return cell;
        } else if (curLotteryType == 14) {
            self.openResultViewHeight.constant = 130;
            self.openResultCollectionHeight.constant = 50;
            LotteryOpenViewCell_SC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_SC forIndexPath:indexPath];
            cell.model = lastOpenResult;
            [cell.issueLab setHidden:YES];
            return cell;
        } else if (curLotteryType == 28){
            LotteryOpenViewCell_BJL *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_BJL forIndexPath:indexPath];
            cell.isShowJustLast = YES;
            cell.isFullscreen = YES;
            lastResultModel * model = [lastResultModel new];
            model.open_result = last_open_result;
            model.vs = [ResultVSModel mj_objectWithKeyValues:vsDic];
            cell.model = model;
            return cell;
        }else if(curLotteryType == 29){
            LotteryOpenViewCell_ZJH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH forIndexPath:indexPath];
            cell.isShowJustLast = YES;
            cell.isFullscreen = YES;
            NSDictionary * model = vsDic;
            cell.model = model;
            return cell;
        }else if(curLotteryType == 31){
            LotteryOpenViewCell_LH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LH forIndexPath:indexPath];
            cell.isShowJustLast = YES;
            cell.isFullscreen = YES;
            NSDictionary *modelDic = @{@"open_result":last_open_result,@"vs":vsDic};
            cell.model = modelDic;
            return cell;
        }else{
            IssueCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell forIndexPath:indexPath];
            cell.isOldType = true;
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
            } else{
                resultStr = [open_result objectAtIndex:indexPath.row];
            }
            [cell setNumber:resultStr lotteryType:curLotteryType isFullscreen: YES];
            return cell;
        }
    }
}

-(void)doOptionClick:(UIButton *)sender{
    NSDictionary *dict =ways[waySelectIndex];
    NSArray *array = dict[@"options"];
    NSString *desc = array[sender.tag][@"desc"];
    
    if(desc){
        [MBProgressHUD showError:desc];
    }
}

#pragma mark   --- 大廳佈局1 ---
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if(collectionView == self.rightCollection){
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        NSString *nameGame = [dict objectForKey:@"name"];
        float matchW = (SCREEN_WIDTH / array.count) - 6; // 6是最小间距
        float scaleRateX = 0, scaleRateY = 0;
        if (curLotteryType == 6 || curLotteryType == 11) { //時時彩
            if (indexPath.row<=3) {
                return CGSizeMake((kScreenWidth/4-8)-2, self.rightCollection.height/5);
            } else {
                return CGSizeMake((kScreenWidth/3-8)-2, self.rightCollection.height/6);
            }
        }
        if(array.count <= 12){
            if (array.count<=5) {
                scaleRateX = MAX(MIN(matchW, 80), 65) / 80;
                scaleRateY = scaleRateX;
            }else{
                if (curLotteryType == 28) { // 百家樂
                    return CGSizeMake((kScreenWidth/3-8)-4, self.rightCollection.height/4);
                }else if (curLotteryType == 31 || curLotteryType == 29) { //龍虎, 炸金花
                    if (indexPath.row<3) {
                        return CGSizeMake((kScreenWidth/3-8)-2, self.rightCollection.height/4);
                    }else{
                        return CGSizeMake((kScreenWidth/2-8)-4, self.rightCollection.height/4);
                    }
                }else if(array.count == 8){
                    return CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                }else if(array.count == 9){
                    if (indexPath.row<4) {
                        return CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                    }else{
                        return CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                    }
                }else if(array.count == 10){
                    return CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                }else if (array.count==11) {
                    if (indexPath.row<5) {
                        return CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                    }else{
                        return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
                    }
                }else{
                    CGSize sizeF = CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
                    return sizeF;
                }
            }
        } else if (curLotteryType == 30) { // 輪盤
            if (indexPath.row<=3) {
                return CGSizeMake((kScreenWidth/4-8)-2, self.rightCollection.height/6);
            } else if (indexPath.row>=3 && indexPath.row<= 6) {
                return CGSizeMake((kScreenWidth/3-8)-2, self.rightCollection.height/6);
            } else if (indexPath.row == 7) {
                return CGSizeMake((kScreenWidth/1-8)-8, self.rightCollection.height/6);
            } else {
                return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/6);
            }
        } else if (curLotteryType == 26 || curLotteryType == 27) { // 一分快三, 三分快三
            if (indexPath.row<=3) {
                return CGSizeMake((kScreenWidth/4-8)-2, self.rightCollection.height/6);
            } else if (indexPath.row>=4 && indexPath.row<=17) {
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/6);
            } else if (indexPath.row>=18 && indexPath.row<=24) {
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/2.5);
            } else if (indexPath.row>=25 && indexPath.row<=30) {
                return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/3.5);
            } else {
                return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/5.5);
            }
        } else if ([nameGame containsString:@"牛"]) {
            if (indexPath.section == 0 && indexPath.row<=3) {
                return CGSizeMake((kScreenWidth/2-8)-2, self.rightCollection.height/6);
            } else {
                return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/8);
            }
        } else if (curLotteryType == 14) { // 一分赛车
            if (indexPath.row<=7) {
                return CGSizeMake((kScreenWidth/4-8)-2, self.rightCollection.height/6);
            } else if (indexPath.row>=8 && indexPath.row<= 19) {
                return CGSizeMake((kScreenWidth/6-8)-2, self.rightCollection.height/6);
            } else {
                return CGSizeMake((kScreenWidth/5-8)-2, self.rightCollection.height/6);
            }
        } else if ([nameGame containsString: @"特码"]) { //六合彩
            if (indexPath.row<=2) {
                return CGSizeMake((kScreenWidth/3-8)-2, self.rightCollection.height/5);
            } else if (indexPath.row>=3 && indexPath.row<= 6) {
                return CGSizeMake((kScreenWidth/4-8)-2, self.rightCollection.height/5);
            } else {
                return CGSizeMake((kScreenWidth/6-8)-2, self.rightCollection.height/6);
            }
        } else {
            scaleRateX = MAX(MIN(matchW, 80), 45) / 80;
            scaleRateY = scaleRateX;
        }
        if (array.count == 2) {
            return CGSizeMake(80 * scaleRateX*2, 105 * scaleRateY);
        }else{
            return CGSizeMake(80 * scaleRateX, 105 * scaleRateY);
        }
        
    }else  if (collectionView ==self.betChipCollectionView) {
        return CGSizeMake(42, 42);
    }else if (collectionView == self.openResultList){
        if(curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27 ||  curLotteryType == 30){
            return CGSizeMake(_window_width, 32);
        }else{
            return CGSizeMake(_window_width, 50);
        }
    }else if (collectionView == self.betHistoryList){
        return CGSizeMake(_window_width, 32);
    }else{
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
        
        NSInteger result_count = open_result.count;
        if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            result_count = result_count + 1;
        }
        
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float scaleRate = MAX(MIN(matchW, 30), 20) / 60;
        if (result_count == 1) {
            if (curLotteryType==28||curLotteryType==29||curLotteryType==31) {
                return CGSizeMake(self.openResultCollection.width,50);
            }else{
                return CGSizeMake(self.openResultList.width/3, 60*scaleRate);
            }
        }else{
            return CGSizeMake(60*scaleRate, 60*scaleRate);
        }
        
    }
}

#pragma mark   --- 大廳佈局2 (百人牛牛) ---
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        NSString *nameGame = [dict objectForKey:@"name"];
        if (curLotteryType == 10) { // 百人牛牛
            if (indexPath.section == 0 && indexPath.row<=3) {
                return CGSizeMake(kScreenWidth/2-14, self.rightCollection.height/5);
            } else {
                CGFloat collectionViewWidth = collectionView.frame.size.width;
                CGFloat leftRightInsets = 6.0; // 左右邊距
                CGFloat spacingBetweenCells = 6.0; // cell 之間的間距
                CGFloat totalSpacing = leftRightInsets * 2 + (5 * spacingBetweenCells); // 計算總的間距
                
                // 計算單個 cell 的寬度
                CGFloat cellWidth = (collectionViewWidth - totalSpacing) / 6.0;
                
                // 返回計算出的 cell 大小
                return CGSizeMake(cellWidth, cellWidth);
                //return CGSizeMake(kScreenWidth/8+6, self.rightCollection.height/7);
            }
        }
        float matchW = (SCREEN_WIDTH / array.count) - 6; // 6是最小间距
        float scaleRateX = 0, scaleRateY = 0;
        if(array.count <= 12){
            if (array.count<=5) {
                scaleRateX = MAX(MIN(matchW, 80), 65) / 80;
                scaleRateY = scaleRateX;
            }else{
                if (array.count==6) {
                    return CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
                }else if (array.count==7){
                    if (indexPath.row<3) {
                        return CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
                    }else{
                        return CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                    }
                    
                }else if(array.count == 8){
                    return CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                }else if(array.count == 9){
                    if (indexPath.row<4) {
                        return CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                    }else{
                        return CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                    }
                }else if(array.count == 10){
                    return CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                }else if (array.count==11) {
                    if (indexPath.row<5) {
                        return CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                    }else{
                        return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
                    }
                }else{
                    CGSize sizeF = CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
                    return sizeF;
                }
            }
        } else if (array.count==40 && nameGame != nil && [nameGame isEqualToString:@"点数"]) {
            if (indexPath.row<=2) {
                return CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
            }else if (indexPath.row>=38) {
                return CGSizeMake(kScreenWidth/2-8, self.rightCollection.height/2);
            }else{
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/2);
            }
            
        } else if (nameGame != nil && [nameGame isEqualToString:@"猜大小"]) {
            if (indexPath.row<=3) {
                return CGSizeMake((kScreenWidth/4-8)-2, self.rightCollection.height/8);
            } else if (indexPath.row>=4 && indexPath.row<=17) {
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/8);
            } else if (indexPath.row>=18 && indexPath.row<=24) {
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/3.2);
            } else if (indexPath.row>=25 && indexPath.row<=30) {
                return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/4.4);
            } else {
                return CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/6);
            }
        } else{
            scaleRateX = MAX(MIN(matchW, 80), 45) / 80;
            scaleRateY = scaleRateX;
        }
        if (array.count == 2) {
            return CGSizeMake(80 * scaleRateX*2, 105 * scaleRateY);
        }else{
            return CGSizeMake(80 * scaleRateX, 105 * scaleRateY);
        }
    }else if (collectionView ==self.betChipCollectionView) {
        return CGSizeMake(42, 42);
    }else if (collectionView == self.openResultList){
        if(curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27 || curLotteryType == 30){
            return CGSizeMake(_window_width, 32);
        }else{
            return CGSizeMake(_window_width, 50);
        }
    }else if (collectionView == self.betHistoryList){
        return CGSizeMake(_window_width, 32);
    }else{
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
        NSInteger result_count = open_result.count;
        if(curLotteryType == 8 ||curLotteryType == 7||curLotteryType == 32){
            result_count = result_count + 1;
        } else if (curLotteryType == 10 || curLotteryType == 14) {
            result_count = 1;
        }
        
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float scaleRate = MAX(MIN(matchW, 30), 20) / 60;
        if (result_count == 1) {
            if (curLotteryType==28||curLotteryType==29||curLotteryType==31||curLotteryType==14||curLotteryType==14||curLotteryType==10) {
                return CGSizeMake(self.openResultCollection.width,50);
            }else{
                return CGSizeMake(self.openResultList.width/3, 60*scaleRate);
            }
        }else{
            return CGSizeMake(60*scaleRate, 60*scaleRate);
        }
        
    }
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = kCollectionHeader;
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    view.width = self.rightCollection.width;
    [view removeAllSubviews];
    [[view viewWithTag:1] setHidden: YES];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.rightCollection.width - 20, 40)];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    NSString *sectionName;
    if (indexPath.section == 1) {
        sectionName = @"蓝方牛";
    } else if (indexPath.section == 2) {
        sectionName = @"红方牛";
    }
    label.text = sectionName;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(6, 0, self.rightCollection.width - 16, 40)];
    bgView.layer.cornerRadius = 20.0;
    bgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    bgView.layer.masksToBounds = YES;
    [bgView addSubview:label];
    [view addSubview:bgView];
    return view;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(collectionView == self.rightCollection){
        return UIEdgeInsetsMake(0, 6, 0, 6);
    }else if (collectionView ==self.betChipCollectionView) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else if (collectionView == self.openResultList){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else if (collectionView == self.betHistoryList){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(0, 5, 0, 5);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(collectionView == self.rightCollection){
        if (curLotteryType == 10 && section == 0) {
            CGSize size={kScreenWidth,0};
            return size;
        } else {
            CGSize size={kScreenWidth,44};
            return size;
        }
    }else  if(collectionView == self.betChipCollectionView){
        CGSize size={0,0};
        return size;
    }else{
        CGSize size={kScreenWidth,0};
        return size;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)returnLive:(id)sender {
    [self exitView];
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

-(void)dealloc
{
    NSLog(@"dealloc");
    [NSNotificationCenter.defaultCenter postNotificationName:@"KHomeSocketCreateKey" object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

// 工具栏点击事件
-(void)titleBtnClick:(UIButton *)btn{
    
    if ([btn isEqual:self.selectedToolBtn]) {
        return;
    }
    
    btn.selected = YES;
    //    顶部高度变化刷新聊天列表高度
    if(btn.tag < 1003){
        self.selectedToolBtn.selected = btn.tag == 1006;
        self.selectedToolBtn = btn;
    }else{
        if(btn.tag != 1003 && btn.tag != 1004 && btn.tag != 1006){
            if (self.lotteryDelegate!= nil && isShowTopList) {
                isShowTopList = NO;
                [self.lotteryDelegate refreshTableHeight:NO];
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                [self updateViewFrame];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.chartView.hidden = YES;
                self.betHistoryList.hidden = YES;
                self.openResultList.hidden = YES;
            }];
        }
    }
    if (btn.tag<=1004 || btn.tag == 1006) {
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
            VC.isBetExplain = YES;
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
            
        }else if (btn.tag == 1004){
            //  投注历史
            [self doShowBetHistory];
        }else if (btn.tag == 1005){
            //  切换新旧版
            [self deleteSocket];
            [self deleteNotice];
            [self deleteTimer];
            [self.lotteryDelegate exchangeVersionToNew: curLotteryType];
        }else if (btn.tag == 1006){
            //  游戏切换
            SwitchLotteryViewController *lottery = [[SwitchLotteryViewController alloc]initWithNibName:@"SwitchLotteryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            lottery.isFromGameCenter = YES;
            lottery.lotteryDelegate = self.lotteryDelegate;
            lottery.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self addChildViewController:lottery];
            [self.view addSubview:lottery.view];
        }
    }
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

- (void)lotteryInterval {
    if(!allData) return;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: allData] ;
    
    NSDate * nowDate = [NSDate date];
    NSInteger timeDistance = [dict[@"openTime"] timeIntervalSinceDate:nowDate];
    if (timeDistance == 0) {
        [self loadBetInfo];
    }
    dict[@"time"] = [NSString stringWithFormat:@"%ld", timeDistance];
    // NSLog(@"%@ 时间2:%@", lotteryType, dict[@"time"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lotterySecondNotify" object:nil userInfo:@{
        @"betLeftTime":dict[@"time"],
        @"sealingTime":dict[@"sealingTim"],
        @"issue":dict[@"issue"],
        @"lotteryType":dict[@"lotteryType"],
    }
    ];
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

-(void)releaseView {
    [self deleteSocket];
    [self deleteTimer];
    [self deleteNotice];
}

- (void)giveVideoTicketMessage:(GiveVideoTicket *)msg {
    NSString *text = msg.msg.ct;
    if (text.length) {
        [MBProgressHUD showBottomMessage:text];
    }
//    [VideoTicketFloatView refreshFloatData];
}

- (void)appearToolBar {
}

@end

