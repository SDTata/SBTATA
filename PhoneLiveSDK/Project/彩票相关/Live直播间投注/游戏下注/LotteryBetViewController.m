//
//  LotteryBetViewController.m
//
//

#import "LotteryBetViewController.h"
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
#import "LotteryBetSubView.h"
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
#import "LotteryCustomChipView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height




#define heightView LotteryWindowOldHeigh

@interface LotteryBetViewController (){
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSDictionary *allData;
    NSMutableArray *ways;   // 投注选项
    NSInteger waySelectIndex; // 当前选择的投注索引
    BOOL bUICreated; // UI是否创建
    
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
   
    NSMutableArray *waysBtn;   // 投注分类按钮
    
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
    
}
@property (weak, nonatomic) IBOutlet UILabel *issueNumberLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property(nonatomic,strong)NSMutableArray *allOpenResultData;
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@property(nonatomic,strong) CustomScrollView * toolScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
@property(nonatomic,strong)NSMutableArray * toolBtnArr;
@property(nonatomic,strong)UIButton * selectedToolBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wayBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openResultCollectionTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openResultCollectionHeight;

@end

@implementation LotteryBetViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@0];
}
- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTime:) name:@"lotterySecondNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLastOpen:) name:@"LotteryOpenAward" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@0];
    
    openPage = 0;
    betPage = 1;
    _netFlag = YES;
    isShowTopList = NO;
    [self createToolScorllview];
    self.topHeight.constant = 0;
    
    [self getOpenResultInfo];
    [self getInfo];
//    self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [YBToolClass sharedInstance].lotteryLiveGameHeight = heightView+ShowDiff;
    //    self.navigationItem.title = @"投注中心";
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.rightCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.openResultCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.bottomConstraint.constant =  (heightView+ShowDiff);
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
    
    //    [self.chargeBtn setTitle:YZMsg(@"Bet_Charge_Title") forState:UIControlStateNormal];
    [self.betBtn setTitle:YZMsg(@"LobbyLotteryVC_Bet") forState:UIControlStateNormal];
    [self.KeyBTN setBackgroundImage:[[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(120, 30)] sd_imageByRoundCornerRadius:15] forState:UIControlStateNormal];
    [self.KeyBTN setTitle:YZMsg(@"Livebroadcast_SaySomething") forState:UIControlStateNormal];
    
    self.chartView.backgroundColor = [UIColor clearColor];
    chartSubV = [ChartView instanceChatViewWithType:curLotteryType];
    [self.chartView addSubview:chartSubV];
   
    self.chartView.hidden = YES;
    self.betHistoryList.hidden = YES;
    self.openResultList.hidden = YES;
    self.topHeight.constant = 0;
    self.view.height = heightView+ShowDiff;

    
    
    [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
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
        _openResultCollectionTop.constant = 5;
        _openResultCollectionHeight.constant = 50;
    }else{
        _openResultCollectionTop.constant = 25;
        _openResultCollectionHeight.constant = 30;
    }
    [self.view layoutIfNeeded];
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

    
    NSArray * imgArr = @[@"yfks_icon_zst",@"yfks_icon_tzjl",@"yfks_icon_kjjl",@"yfks_icon_wfsm",@"yfks_icon_lstz",@"yfks_icon_qhjb",@"yfks_icon_lw",@"yfks_icon_game",@"live_redpack"];
//    if (curLotteryType == 8||curLotteryType == 14||curLotteryType == 11||curLotteryType == 6) {
//        imgArr = @[@"yfks_icon_zst",@"yfks_icon_tzjl",@"yfks_icon_kjjl",@"yfks_icon_wfsm",@"yfks_icon_lstz",@"yfks_icon_lw",@"yfks_icon_game",@"live_redpack"];
//    }
    CGFloat contentLength = 0;
    CGFloat buttonWidth = 30.0;
    CGFloat spacing = 5;
    
    self.toolBtnArr = [NSMutableArray array];
    for (int i = 0; i< imgArr.count; i ++) {
        if (self.isFromLiveBroadcast && i >= 6) {
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
//        if ((curLotteryType == 8||curLotteryType == 14||curLotteryType == 11||curLotteryType == 6)&&i>4) {
//            livechatBtn.tag = 1000+i+1;
//        }else{
            livechatBtn.tag = 1000+i;
//        }
      
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


-(void)exitView{
    
    
    if (self.contentView.alpha<=0) {
        return;
    }
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"lotterySecondNotify" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotteryOpenAward" object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:KShowLotteryBetViewControllerNotification object:@1];
        if (strongSelf.lotteryDelegate!= nil) {
            [strongSelf.lotteryDelegate lotteryCancless];
        }
    }];
}
-(void)exitViewFromExchange{
    if (self.lotteryDelegate!= nil) {
        _isExit = [self.lotteryDelegate cancelLuwu];
    }
    
    if(_isExit) return;
    _isExit = true;
//    [self.view layoutIfNeeded];
    self.bottomConstraint.constant =  (heightView+ShowDiff+[self LobbyWindowHeight]);
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"lotterySecondNotify" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LotteryOpenAward" object:nil];
        if (strongSelf.lotteryDelegate!= nil) {
            [strongSelf.lotteryDelegate exchangeVersionToNew:strongSelf->curLotteryType];
        }
    }];
}
- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
    [GameToolClass setCurOpenedLotteryType:lotteryType];
}

- (void)getInfo{
    if(!bUICreated){
        self.wayBtnView.hidden = YES;
        self.rightCollection.hidden = YES;
    }
    NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getBetViewInfo&uid=%@&token=%@&lottery_type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType]];
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
            if(strongSelf->curLotteryType == 29){
                strongSelf->vsDic = dict;
            }else{
                strongSelf->vsDic = dict[@"vs"];
            }
           
            if(dict){
                strongSelf->last_open_result = dict[@"open_result"];
                strongSelf->last_open_resultZH = dict[@"open_result_zh"];
                
            }else{
                strongSelf->last_open_result = @"";
            }
            strongSelf.issueNumberLabel.text = [NSString stringWithFormat:YZMsg(@"history_betTitle%@"),dict[@"issue"]];
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
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf exitView];
        return;
    }];
}

-(void)refreshUI{
    if(!ways){
        ways = [NSMutableArray array];
    }
    if(!bUICreated){
        [self initUI];
    }
    self.wayBtnView.hidden = NO;
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
    self.curIssue = allData[@"issue"];
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
    waySelectIndex = 0;
    
    
    // 初始化投注方式按钮
    [self initWayBtn];
    // 初始化投注选项
    [self initCollection];
    // 监听按钮事件[充值]253, 156, 39
    self.chargeBtn.backgroundColor =  RGB_COLOR(@"#000000", 0.7);
    [self.chargeBtn addTarget:self action:@selector(doCharge:) forControlEvents:UIControlEventTouchUpInside];
    // 监听按钮事件[投注]
    [self.betBtn addTarget:self action:@selector(doBet) forControlEvents:UIControlEventTouchUpInside];
    // 监听阴影层点击事件
    //    [self.shadowView addTarget:self action:@selector(exitView) forControlEvents:UIControlEventTouchUpInside];

}
- (void)exchangeVersion:(UIButton *)sender{
    [self exitViewFromExchange];
    
//    [self.shadowView addTarget:self action:@selector(exitView) forControlEvents:UIControlEventTouchUpInside];

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

- (void)refreshTime:(NSNotification *)notification {
    if(!bUICreated){
        return;
    }
    NSInteger betLeftTime = [(notification.userInfo[@"betLeftTime"]) integerValue];
    NSInteger sealingTime = [(notification.userInfo[@"sealingTime"]) integerValue];
    NSString * issue = minstr(notification.userInfo[@"issue"]);
    NSString * lotteryType = minstr(notification.userInfo[@"lotteryType"]);
    if(curLotteryType>0 && [lotteryType isEqualToString:[NSString stringWithFormat:@"%ld",curLotteryType]]){
        self.curIssue = issue;
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
}

- (void)refreshLastOpen:(NSNotification *)notification {
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
            
            NSString *whowWinStr = [NSString stringWithFormat:@"%@",zjhDic[@"whoWin"]];
            NSString *open_result = @"";
            if ([whowWinStr isEqualToString:@"0"]) {
                open_result = @"玩家一";
            }else if ([whowWinStr isEqualToString:@"1"]) {
                open_result = @"玩家二";
            }else if ([whowWinStr isEqualToString:@"2"]) {
                open_result = @"玩家三";
            }
            
            if(paiA.count>2 && pai_type_strs.count>2){
                NSString *paiS_1 = paiA[0];
                NSString *paiS_2 = paiA[1];
                NSString *paiS_3 = paiA[2];
                if(paiS_1 && paiS_1.length>0 && paiS_2 && paiS_2.length>0 && paiS_3 && paiS_3.length>0){
                    NSString *pai_1 = [[paiS_1 stringByReplacingOccurrencesOfString:@"玩家1:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                    NSString *pai_2 = [[paiS_2 stringByReplacingOccurrencesOfString:@"玩家2:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                    NSString *pai_3 = [[paiS_3 stringByReplacingOccurrencesOfString:@"玩家3:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                    
                    
                    vsDic = @{@"open_result":open_result,@"who_win":zjhDic[@"whoWin"],@"vs":@{@"player1":@{@"pai":[pai_1 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[0]},
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
        [strongSelf updateViewFrame];
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
        [strongSelf updateViewFrame];
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
-(void)doBet{
    // 生成确认界面需要的信息
    NSMutableArray * orders = [NSMutableArray array];
    NSDictionary *dict = ways[waySelectIndex];
    NSArray *array = dict[@"options"];
    NSInteger maxCount = array.count;
    for (int i=0; i<maxCount; i++) {
        BetOptionCollectionViewCell *cell=[self.rightCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        //BetOptionCollectionViewCell *cell = [self.rightCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell.selected){
            NSDictionary *selectOption = [array objectAtIndex:i];
            NSMutableDictionary *order = [NSMutableDictionary dictionary];
            [order setObject:selectOption[@"st"] forKey:@"st"];
            [order setObject:selectOption[@"title"] forKey:@"way"];
            [order setObject:[NSString stringWithFormat:@"%f", selectedChipModel.chipNumber] forKey:@"money"];
            [orders addObject:order];
        }
    }
    
    if(orders.count == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyBet_selecte_Warning")];
        return;
    }
    BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    betConfirmVC.isShowTopList = isShowTopList;
    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
        //        [self refreshCurrentChip];
        [betConfirmVC.view removeFromSuperview];
        [betConfirmVC removeFromParentViewController];
    }];
    NSString *selectedName = dict[@"name"];
    NSString *selectedNameSt = dict[@"st"];
    if (waySelectIndex<ways.count) {
        NSDictionary *dic = ways[waySelectIndex];
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            selectedName = dic[@"name"];
        }
    }
    NSDictionary *orderInfo = @{
        @"name":allData[@"name"],
        @"optionName":selectedName,
        @"optionNameSt":selectedNameSt,
        @"lotteryType":[NSString stringWithFormat:@"%ld",curLotteryType],
        @"issue":self.curIssue,
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
    [self.view.superview addSubview:betConfirmVC.view];
    //    betConfirmVC.view.y = self.view.height - betConfirmVC.view.bottom;
    betConfirmVC.view.bottom = self.view.bottom;
    [self.parentViewController addChildViewController:betConfirmVC];
    //
    return;
    
    //    NSDictionary *dict =ways[waySelectIndex];
    //    NSArray *array = dict[@"options"];
    //    NSInteger maxCount = array.count;
    //    NSString *way = @"[";
    //    NSString *money = @"[";
    //
    //    NSInteger selectIdx = 0;
    //    for (int i=0; i<maxCount; i++) {
    //        BetOptionCollectionViewCell *cell=[self.rightCollection dequeueReusableCellWithReuseIdentifier:kBetOptionCollectionViewCell forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    //        if(cell.selected){
    //            NSDictionary *selectOption = [array objectAtIndex:i];
    //            NSLog([NSString stringWithFormat:@"选中[%@]赔率:%@",selectOption[@"title"],selectOption[@"value"]]);
    //
    //            if(selectIdx == 0){
    //                way = [NSString stringWithFormat:@"%@\"%@\"",way,selectOption[@"title"]];
    //                money = [NSString stringWithFormat:@"%@%ld",money,[common getChipNum]];
    //            }else{
    //                way = [NSString stringWithFormat:@"%@,\"%@\"",way,selectOption[@"title"]];
    //                money = [NSString stringWithFormat:@"%@,%ld",money,[common getChipNum]];
    //            }
    //            selectIdx++;
    //        }
    //    }
    //    way = [NSString stringWithFormat:@"%@%@",way,@"]"];
    //    money = [NSString stringWithFormat:@"%@%@",money,@"]"];
    //
    ////    uid    是    string    用户名
    ////    token    是    string    token
    ////    lottery_type    是    string    彩种
    ////    money    是    string    投注金额
    ////    way    是    string    投注选项
    ////    serTime    是    string    投注时间
    ////    issue    是    string    投注期号
    //    NSString *lottery_type = allData[@"lotteryType"];
    //    NSString *issue = allData[@"issue"];
    ////    NSString *money = [NSString stringWithFormat:@"[%ld]",[common getChipNum]];
    ////    NSString *way = [NSString stringWithFormat:@"[%ld]",[common getChipNum]];
    //
    //    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting&uid=%@&token=%@&lottery_type=%@&money=%@&way=%@&serTime=%@&issue=%@",[Config getOwnID],[Config getOwnToken],lottery_type,money,way,@"0",issue];//User.getPlats
    //    [YBToolClass postNetworkWithUrl:betUrl andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    //        NSLog(@"xxxxxxxxx%@",info);
    //        [testActivityIndicator stopAnimating]; // 结束旋转
    //        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    //        if(code == 0)
    //        {
    //            // 清空信息
    //        }
    //        else{
    //            [MBProgressHUD showError:msg];
    //        }
    //
    //    } fail:^{
    //        [testActivityIndicator stopAnimating]; // 结束旋转
    //        [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    //        // 请求失败
    //        [MBProgressHUD showError:@"请求失败"];
    //    }];
    
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
    
    NSString *selectedName = dict[@"name"];
    NSString *selectedNameSt = dict[@"st"];
    
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
        @"optionName":selectedName,
        @"optionNameSt":selectedNameSt,
        @"lotteryType":[NSString stringWithFormat:@"%ld",curLotteryType],
        @"issue":self.curIssue,
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
    [self.view.superview addSubview:betConfirmVC.view];
    //    betConfirmVC.view.y = self.view.height - betConfirmVC.view.bottom;
    betConfirmVC.view.bottom = self.view.bottom;
    [self.parentViewController addChildViewController:betConfirmVC];
    return;
}

-(void)doCharge:(UIButton *)sender{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
}

-(void)initWayBtn{
    self.wayBtnView.backgroundColor = RGB(185, 184, 180);
    self.wayBtnView.layer.masksToBounds = YES;
    self.wayBtnView.layer.cornerRadius = 15;
    NSInteger maxCount = ways.count;
    if(maxCount <= 1){
        self.wayBtnHeightConstraint.constant = 0;
        self.betContentHeightConstraint.constant = 150;
        return;
    }else{
        self.wayBtnHeightConstraint.constant = 30;
        self.betContentHeightConstraint.constant = 120;
    }
    waysBtn = [NSMutableArray array];
    
    UIImage *originalImage = [ImageBundle imagewithBundleName:@"yfks_anniu2"];
   
    CGSize originalSize = originalImage.size;

    // 计算新的尺寸，确保纵横比不变
    float widd = (_window_width - 20) / maxCount;
    float heightds = 30;
    
    CGFloat widthRatio =  widd/ originalSize.width;
    CGFloat heightRatio = heightds / originalSize.height;
    CGFloat scaleFactor = MIN(widthRatio, heightRatio);
    CGSize newSize = CGSizeMake(originalSize.width * scaleFactor, originalSize.height * scaleFactor);

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    newImage = [newImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 30) resizingMode:UIImageResizingModeStretch];
    
    for (int i=0; i<maxCount; i++) {
        // 取信息
        NSDictionary *wayInfo = [ways objectAtIndex:i];
        // 计算位置
        float posX,posY,W,H;
        W = (_window_width - 20) / maxCount;
        H = 30;
        posX = i*W;
        posY = 0;
        
       
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(posX, posY, W, H);
        [btn setBackgroundImage:newImage forState:UIControlStateDisabled];
        [btn setBackgroundImage:newImage forState:UIControlStateHighlighted];
        [btn setBackgroundImage:newImage forState:UIControlStateSelected];
        
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.numberOfLines = 2;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor = 0.1;
        btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        
        // 设置文本
        [btn setTitle:wayInfo[@"st"] forState:0];
        
        // 添加点击事件
        [btn addTarget:self action:@selector(switchWay:) forControlEvents:UIControlEventTouchUpInside];
        
        [waysBtn addObject:@{@"btn":btn, @"wayInfo":wayInfo}];
        // 添加到View
        [self.wayBtnView addSubview:btn];
        
        if(i == waySelectIndex){
            btn.selected = true;
        }
        
        // 假设您的按钮和文本如下
        NSString *buttonText = btn.titleLabel.text;
        CGSize buttonSize = btn.frame.size;

        // 开始字体大小
        CGFloat fontSize = 15;

        // 创建属性字典
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};

        // 循环减少字体大小，直到找到适合高度的大小
        CGFloat minHeight = buttonSize.height; // 您的按钮高度
        CGRect textRect;
        do {
            attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
            textRect = [buttonText boundingRectWithSize:CGSizeMake(buttonSize.width, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes
                                                context:nil];
            fontSize -= 1;
        } while (textRect.size.height > minHeight && fontSize > 0);

        // 设置按钮标题的字体
        btn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        
    }
}
-(void)switchWay:(UIButton *)sender {
    NSInteger maxCount = waysBtn.count;
    for (int i=0; i<maxCount; i++) {
        NSDictionary *dict = [waysBtn objectAtIndex:i];
        UIButton *btn = dict[@"btn"];
        if(btn == sender){
            //            NSDictionary *dict2 = dict[@"wayInfo"];
            btn.selected = true;
            waySelectIndex = i;
            [self reloadLayout];
            [self.rightCollection reloadData];
        }else{
            
            btn.selected = false;
        }
        
    }
}
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
//            NSInteger rowCount = (NSInteger)ceil((double)array.count / 5);
            if (array.count==6) {
                size = CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 3)-3*3, 6);
            }else if (array.count==7){
//                if (indexPath.row<4) {
                    size = CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
//                }else{
//                    size = CGSizeMake(kScreenWidth/3-3*3, self.rightCollection.height/2);
//                }
                valueSpace = MAX((kScreenWidth  - size.width * 4)-4*5, 6);
            }else if(array.count == 8){
                size = CGSizeMake(kScreenWidth/4-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 4)-4*3, 6);
            }else if(array.count == 9){
//                if (indexPath.row<5) {
                    size = CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 5)-5*3, 3);
//                }else{
//                    size = CGSizeMake(kScreenWidth/4-4*3, self.rightCollection.height/2);
//                }
            }else if(array.count == 10){
                size = CGSizeMake(kScreenWidth/5-8, self.rightCollection.height/2);
                valueSpace = MAX((kScreenWidth  - size.width * 5)-5*3, 6);
            }else if (array.count==11) {
//                if (indexPath.row<6) {
                    size = CGSizeMake(kScreenWidth/6-8, self.rightCollection.height/2);
//                }else{
//                    size = CGSizeMake(kScreenWidth/5-5*3, self.rightCollection.height/2);
//                }
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
    FLLayout *layout = [[FLLayout alloc]init];
    layout.dataSource = self;
    
    // self.rightCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,kScreenWidth,self.view.height) collectionViewLayout:flowLayout];
    
    self.rightCollection.delegate = self;
    self.rightCollection.dataSource = self;
    self.rightCollection.delaysContentTouches = NO;
    self.rightCollection.collectionViewLayout = layout;
    self.rightCollection.clipsToBounds = YES;
    self.rightCollection.allowsMultipleSelection = YES;
    
    UINib *nib=[UINib nibWithNibName:kBetOptionCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kBetOptionCollectionViewCell];
    
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
//
//    self.openResultCollection.allowsMultipleSelection = self;
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
    //    self.openResultList.hidden = YES;
    //    self.betHistoryList.hidden = YES;
    
    [self reloadLayout];
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
        BetOptionCollectionViewCell *cell=[collectionView cellForItemAtIndexPath:indexPath];
        //BetOptionCollectionViewCell *cell = [self.rightCollection cellForItemAtIndexPath:indexPath];
        cell.selected = YES;
        
    }else if (collectionView ==self.betChipCollectionView) {
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
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        BetOptionCollectionViewCell *cell=[collectionView cellForItemAtIndexPath:indexPath];
        //BetOptionCollectionViewCell *cell = [self.rightCollection cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
    }else if (collectionView == self.openResultList){
        
    }else if (collectionView == self.betHistoryList){
        
    }else{
      
    }
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        BetOptionCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kBetOptionCollectionViewCell forIndexPath:indexPath];
        
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        NSInteger optionIndex = indexPath.row;
        NSLog(@"%@", [NSString stringWithFormat:@"设置%ld个为%@",(long)optionIndex, array[optionIndex][@"title"]]);
        NSString *desc = array[optionIndex][@"desc"];
        cell.way = array[optionIndex][@"title"];
        cell.titile.text= array[optionIndex][@"st"];
        cell.rate.text=[NSString stringWithFormat:@"%.2f", [array[optionIndex][@"value"] floatValue]];
        cell.backgroundColor=[UIColor clearColor];
        cell.imageView.backgroundColor = [UIColor clearColor];
        cell.imageView.image = [UIImage sd_imageWithColor:RGB(110, 102, 112) size:CGSizeMake(280, 280)];
        //        cell.imageView.backgroundColor=[UIColor whiteColor];//UIColorFromRGB(0xF8FCF8);
        //    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName]];
        cell.selected = cell.selected;
        cell.tipBtn.tag = indexPath.row;
        [cell.tipBtn addTarget:self action:@selector(doOptionClick:) forControlEvents:UIControlEventTouchUpInside];
        if(desc){
            cell.tipBtn.hidden = NO;
        }else{
            cell.tipBtn.hidden = YES;
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
        
        
        cell.chipImgView.layer.cornerRadius = 19;
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
            return cell;
        }else if(curLotteryType == 14 || curLotteryType == 9){
            // 赛车
            LotteryOpenViewCell_SC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_SC forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            return cell;
        }else if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            // 六合彩
            LotteryOpenViewCell_LHC *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LHC forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            return cell;
        }else if(curLotteryType == 28){
            LotteryOpenViewCell_BJL *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_BJL forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            return cell;
        }else if(curLotteryType == 30){
            LotteryOpenViewCell_ZP *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_ZP forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.issuLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
            cell.rigthtLab.text = model.open_result;
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

            return cell;
        }else if(curLotteryType == 31){
            LotteryOpenViewCell_LH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LH forIndexPath:indexPath];
            NSDictionary * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
            return cell;
        }else{
            LiveOpenListYFKSCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLiveOpenListYFKSCell forIndexPath:indexPath];
            lastResultModel * model = self.allOpenResultData[indexPath.row];
            cell.model = model;
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
         if(curLotteryType == 28){
            LotteryOpenViewCell_BJL *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_BJL forIndexPath:indexPath];
             cell.isShowJustLast = YES;
             lastResultModel * model = [lastResultModel new];
             model.open_result = last_open_result;
             model.vs = [ResultVSModel mj_objectWithKeyValues:vsDic];
             cell.model = model;
            return cell;
        }else if(curLotteryType == 29){
            LotteryOpenViewCell_ZJH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH forIndexPath:indexPath];
            cell.isShowJustLast = YES;
            NSDictionary * model = vsDic;
            cell.model = model;

            return cell;
        }else if(curLotteryType == 31){
            LotteryOpenViewCell_LH *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LH forIndexPath:indexPath];
            cell.isShowJustLast = YES;
            NSDictionary *modelDic = @{@"open_result":last_open_result,@"vs":vsDic};
            cell.model = modelDic;
            return cell;
        }else{
            IssueCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell forIndexPath:indexPath];
            cell.isOldType = true;
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
}

-(void)doOptionClick:(UIButton *)sender{
    NSDictionary *dict =ways[waySelectIndex];
    NSArray *array = dict[@"options"];
    NSString *desc = array[sender.tag][@"desc"];
    
    if(desc){
        [MBProgressHUD showError:desc];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if(collectionView == self.rightCollection){
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        NSString *nameGame = [dict objectForKey:@"name"];
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
        }else if (array.count==40 && nameGame != nil && [nameGame isEqualToString:@"点数"]){
            if (indexPath.row<=2) {
                return CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
            }else if (indexPath.row>=38) {
                return CGSizeMake(kScreenWidth/2-8, self.rightCollection.height/2);
            }else{
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/2);
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
       
    }else  if (collectionView ==self.betChipCollectionView) {
        return CGSizeMake(46, 46);
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == self.rightCollection){
        NSDictionary *dict =ways[waySelectIndex];
        NSArray *array = dict[@"options"];
        NSString *nameGame = [dict objectForKey:@"name"];
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
        }else if (array.count==40 && nameGame != nil && [nameGame isEqualToString:@"点数"]){
            if (indexPath.row<=2) {
                return CGSizeMake(kScreenWidth/3-8, self.rightCollection.height/2);
            }else if (indexPath.row>=38) {
                return CGSizeMake(kScreenWidth/2-8, self.rightCollection.height/2);
            }else{
                return CGSizeMake(kScreenWidth/7-8, self.rightCollection.height/2);
            }
            
        }else{
            scaleRateX = MAX(MIN(matchW, 80), 45) / 80;
            scaleRateY = scaleRateX;
        }
        if (array.count == 2) {
            return CGSizeMake(80 * scaleRateX*2, 105 * scaleRateY);
        }else{
            return CGSizeMake(80 * scaleRateX, 105 * scaleRateY);
        }
    }else if (collectionView ==self.betChipCollectionView) {
        return CGSizeMake(46, 46);
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
        CGSize size={kScreenWidth,44};
        return size;
    }else  if(collectionView == self.betChipCollectionView){
        CGSize size={0,0};
        return size;
    }else{
        CGSize size={kScreenWidth,0};
        return size;
    }
}

- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
    //设置长宽
    //    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *original = resultImage;
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    // 开始一个Image的上下文
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:radius] addClip];
    // 绘制图片
    [original drawInRect:frame];
    // 接受绘制成功的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doKey:(id)sender {
    //[self exitViewGame];
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

- (IBAction)returnLive:(id)sender {
    [self exitView];
    //    if (self.lotteryDelegate!= nil) {
    //        [self.lotteryDelegate returnCancless];
    //    }
}

- (void)appearToolBar{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 1;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self updateViewFrame];
    }];
}
//#pragma mark ============摇摆=============
//#define RADIANS(degrees) (((degrees) * M_PI) / 180.0)
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
//    ];
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
//    ];
//}


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

// 工具栏点击事件
-(void)titleBtnClick:(UIButton *)btn{
    
    if ([btn isEqual:self.selectedToolBtn]) {
        btn.selected = NO;
        [self rebackScrollView];
        self.selectedToolBtn = nil;
        return;
    }
    
    
    btn.selected = YES;
//    顶部高度变化刷新聊天列表高度
    if(btn.tag < 1003){
        if (self.lotteryDelegate!= nil && !isShowTopList) {
            isShowTopList = YES;
            [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff+100;
            [self.lotteryDelegate refreshTableHeight:YES];
        }
        [chartSubV scrollToRight];
        [UIView animateWithDuration:0.3 animations:^{
            // 在动画中将高度恢复到100
            self.topHeight.constant = 100;
           
            [self updateViewFrame];
            [self.view layoutIfNeeded]; // 重要：强制布局更新以触发动画
        } completion:^(BOOL finished) {
            // 动画完成后执行任何必要的操作
        }];
        self.selectedToolBtn.selected = NO;
        self.selectedToolBtn = btn;
    }else{
        if(btn.tag != 1003 && btn.tag != 1004 && btn.tag != 1008){
            if (self.lotteryDelegate!= nil && isShowTopList) {
                isShowTopList = NO;
                [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
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
            VC.isBetExplain = YES;
            
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
                [strongSelf updateViewFrame];
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
                [strongSelf updateViewFrame];
            };
            self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.view addSubview:VC.view];
            [self addChildViewController:VC];
            
        }else if (btn.tag == 1004){
            //  投注历史
            [self doShowBetHistory];
        }else if (btn.tag == 1005){
            //  切换新旧版
            [self rebackScrollView];
            [self exitViewFromExchange];
        }else if (btn.tag == 1006){
            //  礼物
//            [self exitView];
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate doLiwu];
            }
        }else if (btn.tag == 1007){
            //  游戏切换
            [self.lotteryDelegate cancelLuwu];
            [self exitView];
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate doGame];
            }
        }else if (btn.tag == 1008){
            //  红包
            if (self.lotteryDelegate!= nil) {
                [self.lotteryDelegate showRedView];
            }
        }
    }
    
    
}

-(void)rebackScrollView{
    if (self.lotteryDelegate!= nil && isShowTopList) {
        isShowTopList = NO;
        [YBToolClass sharedInstance].lotteryLiveWindowHeight = heightView+ShowDiff;
        [self.lotteryDelegate refreshTableHeight:NO];
    }
    self.noView.hidden = YES;
    self.toolScrollView.contentSize = CGSizeMake(35*self.toolBtnArr.count + 10, 0);
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 0; i< self.toolBtnArr.count; i ++) {
            UIButton *livechatBtn = self.toolBtnArr[i];
            livechatBtn.frame = CGRectMake(5+i*(30+5),5,30,30);
        }
        self.topHeight.constant = 0;
        [self updateViewFrame];
        [self.view layoutIfNeeded]; // 重要：强制布局更新以触发动画
    } completion:^(BOOL finished) {
        self.chartView.hidden = YES;
        self.betHistoryList.hidden = YES;
        self.openResultList.hidden = YES;
        self.noView.hidden = YES;
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
