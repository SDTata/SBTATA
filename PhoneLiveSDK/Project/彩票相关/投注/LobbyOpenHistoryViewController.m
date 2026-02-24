//
//  LobbyOpenHistoryViewController.m
//
//

#import "LobbyOpenHistoryViewController.h"
#import "IssueCollectionViewCell2.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "OpenAwardCollectionViewCell.h"
#import "OpenNNHistoryCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kIssueCollectionViewCell2 @"IssueCollectionViewCell2"
#define kOpenAwardCollectionViewCell @"OpenAwardCollectionViewCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"

@interface LobbyOpenHistoryViewController ()<UICollectionViewDataSource>{
    NSInteger curLotteryType;
    
    BOOL bUICreated; // UI是否创建
    BOOL bUIPreInited; // UI预处理
    
    NSInteger curSelectedTypeBtnIndex;
    NSInteger curSelectedType;
    NSMutableArray *switchTypeBtnArray;
    
    NSMutableDictionary *awardTypeDict;
    NSInteger page;
}
@property(nonatomic,strong)NSMutableArray *repeatDatas;
@property(nonatomic,strong)NSMutableArray *allDatas;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet UILabel *periodsLabel;

@end

@implementation LobbyOpenHistoryViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HomeOpenAward_Changed) name:@"HomeOpenAward_Changed" object:nil];
    
    [self getInfo];
    
//    self.contentView.bottom = _window_height;
//    self.contentView.left = _window_width;
//    self.contentView.alpha = 0;
//    self.contentView.hidden = NO;
//    [UIView animateWithDuration:0.25 animations:^{
//        self.contentView.left = 0;
//        self.contentView.alpha = 1;
//    } completion:^(BOOL finished) {
//    }];
    
    self.contentView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentView.layer.shadowRadius = 2;
    if(!bUIPreInited){
        bUIPreInited = true;
        // 监听阴影层点击事件
        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitView)];
        myTap.cancelsTouchesInView = NO;
        [self.shadowView addGestureRecognizer:myTap];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.periodsLabel.text = YZMsg(@"LobbyOpenHistory_periods");
    self.allDatas = [NSMutableArray array];
    self.repeatDatas = [NSMutableArray array];
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.historyCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.view.width = _window_width;
    
    if (@available(iOS 11.0, *)) {
        self.constraintTop.constant = self.constraintTop.constant - ([UIApplication sharedApplication].keyWindow.safeAreaInsets.top -44);
    } else {
        // Fallback on earlier versions
    }
    
}
-(void)exitView{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
//    [UIView animateWithDuration:0.25 animations:^{
//        self.contentView.left = _window_width;
//        self.contentView.alpha = 0;
//    } completion:^(BOOL finished) {
//
//    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HomeOpenAward_Changed" object:nil];
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
}

- (void)HomeOpenAward_Changed{
    
    [self getInfo];
}

- (void)getInfo{
    if(!bUICreated){
        self.historyCollection.hidden = YES;
    }
    NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenHistory&uid=%@&token=%@&lottery_type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType]];
    if (curSelectedType > 1) {
        getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenAwardList&uid=%@&token=%@&lottery_type=%@&type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType], [NSString stringWithFormat:@"%ld", (long)(curSelectedType)]];
    }
   WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES  andParameter:@{@"page":minnum(page)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.historyCollection.mj_header endRefreshing];
        [strongSelf.historyCollection.mj_footer endRefreshing];
        
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            NSLog(@"%@",info);
            
            NSArray *datas = [info objectForKey:@"list"];
            if ([datas isKindOfClass:[NSArray class]]) {
                if (strongSelf->page == 0) {
                    [strongSelf.allDatas  removeAllObjects];
                    [strongSelf.repeatDatas  removeAllObjects];
                    for (NSDictionary *subDic in datas) {
                        NSString *issueSt = subDic[@"issue"];
                        [strongSelf.allDatas addObject:subDic];
                        if (issueSt) {
                            [strongSelf.repeatDatas addObject:issueSt];
                        }
                    }
                }else{
                    for (NSDictionary *subDic in datas) {
                        NSString *issueSt = subDic[@"issue"];
                        if (issueSt && ![strongSelf.repeatDatas containsObject:issueSt]) {
                            [strongSelf.repeatDatas addObject:issueSt];
                            [strongSelf.allDatas addObject:subDic];
                        }
                    }
                    if (datas.count == 0) {
                        [strongSelf.historyCollection.mj_footer endRefreshingWithNoMoreData];
                    }
                }
            }
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
                [strongSelf.historyCollection reloadData];
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
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf exitView];
    }];
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    
    self.historyCollection.hidden = NO;
}

-(void)initUI{
    bUICreated = true;
    
    // 初始化投注选项
    [self initCollection];
    // 初始化历史开奖类型切换按钮
    [self initOpenAwardTypwSwitchBtn];
}

- (void)initOpenAwardTypwSwitchBtn{
    NSArray *btnTitle;
    awardTypeDict = [NSMutableDictionary dictionary];
    awardTypeDict[YZMsg(@"LobbyOpenHistory_Type_Number")] = @1;
    awardTypeDict[YZMsg(@"LobbyOpenHistory_Type_Size")] = @2;
    awardTypeDict[YZMsg(@"LobbyOpenHistory_Type_SingleDouble")] = @3;
    awardTypeDict[YZMsg(@"LobbyOpenHistory_Type_total")] = @4;
    awardTypeDict[YZMsg(@"LobbyOpenHistory_Type_Tema")] = @5;
    awardTypeDict[YZMsg(@"LobbyOpenHistory_Type_WinnerDragonTiger")] = @6;
    
    if([GameToolClass isSC:curLotteryType]){
        btnTitle = @[YZMsg(@"LobbyOpenHistory_Type_Number"),YZMsg(@"LobbyOpenHistory_Type_Size"),YZMsg(@"LobbyOpenHistory_Type_SingleDouble"), YZMsg(@"LobbyOpenHistory_Type_WinnerDragonTiger")];
    }else if([GameToolClass isKS:curLotteryType]){
        btnTitle = @[YZMsg(@"LobbyOpenHistory_Type_Number"),YZMsg(@"LobbyOpenHistory_Type_Size"),YZMsg(@"LobbyOpenHistory_Type_SingleDouble"), YZMsg(@"LobbyOpenHistory_Type_total")];
    }else if([GameToolClass isLHC:curLotteryType]){
        btnTitle = @[YZMsg(@"LobbyOpenHistory_Type_Number"), YZMsg(@"LobbyOpenHistory_Type_total"),YZMsg(@"LobbyOpenHistory_Type_Tema")];
    }else if([GameToolClass isSSC:curLotteryType]){
        btnTitle = @[YZMsg(@"LobbyOpenHistory_Type_Number"),YZMsg(@"LobbyOpenHistory_Type_Size"),YZMsg(@"LobbyOpenHistory_Type_SingleDouble"),  YZMsg(@"LobbyOpenHistory_Type_total")];
    }
    NSInteger maxCount = btnTitle.count;
    // 统一创建好再调整布局
    switchTypeBtnArray = [NSMutableArray array];
    for (int i = 0; i < maxCount; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor = 0.5;
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        [btn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [self.switchTypeView addSubview:btn];
        [switchTypeBtnArray addObject:btn];
        [btn addTarget:self action:@selector(switchTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        
        CGSize btnSize = [btn sizeThatFits:CGSizeZero];
        btn.width = btnSize.width + 18;
        btn.height = 25;
        btn.layer.cornerRadius = 12.5;

    }
    CGFloat totalW = 0;
    for (int i = 0; i < maxCount; i ++) {
        UIButton *btn = switchTypeBtnArray[i];
        totalW += btn.width;
    }
    CGFloat gapX = (self.switchTypeView.width - totalW) / (maxCount + 1);
    CGFloat x = 0;
    CGFloat y = 0;
    for (int i = 0; i < maxCount; i ++) {
        UIButton *btn = switchTypeBtnArray[i];
        y = (self.switchTypeView.height - btn.height) / 2;
        x += gapX;
        btn.x = x;
        btn.y = y;
        x += btn.width;
    }
    
    [self switchTypeBtnClick:switchTypeBtnArray[0]];
}

- (void)switchTypeBtnClick:(UIButton *)sender{
    page=0;
    curSelectedTypeBtnIndex = sender.tag;
    curSelectedType = [awardTypeDict[sender.titleLabel.text] integerValue];
    if (self.historyCollection.visibleCells.count>0) {
         [self.historyCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    for (int i = 0; i < switchTypeBtnArray.count; i++) {
        UIButton *btn = [switchTypeBtnArray objectAtIndex:i];
        if(curSelectedTypeBtnIndex == i){
            btn.backgroundColor = RGB_COLOR(@"#FE0B78", 1);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = RGB_COLOR(@"#F7F7F7", 1);
            [btn setTitleColor:RGB_COLOR(@"#999999", 1) forState:UIControlStateNormal];
        }
    }
    
    if(curSelectedType > 1){
        //self.historyCollection.hidden = YES;
        NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenAwardList&uid=%@&token=%@&lottery_type=%@&type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType], [NSString stringWithFormat:@"%ld", (long)(curSelectedType)]];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES andParameter:@{@"page":minnum(page)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSLog(@"xxxxxxxxx%@",info);
            if(code == 0)
            {
               
               NSArray *datas = [info objectForKey:@"list"];
               if ([datas isKindOfClass:[NSArray class]]) {
                   if (strongSelf->page == 0) {
                       [strongSelf.allDatas  removeAllObjects];
                       [strongSelf.repeatDatas  removeAllObjects];
                       for (NSDictionary *subDic in datas) {
                           NSString *issueSt = subDic[@"issue"];
                           [strongSelf.allDatas addObject:subDic];
                           if (issueSt) {
                               [strongSelf.repeatDatas addObject:issueSt];
                           }
                       }
                   }else{
                       for (NSDictionary *subDic in datas) {
                           NSString *issueSt = subDic[@"issue"];
                           if (issueSt && ![strongSelf.repeatDatas containsObject:issueSt]) {
                               [strongSelf.repeatDatas addObject:issueSt];
                               [strongSelf.allDatas addObject:subDic];
                           }
                       }
                   }
               }
                dispatch_main_async_safe(^{
                    [strongSelf.historyCollection reloadData];
                    //self.historyCollection.hidden = NO;
                });
            }
            else{
                [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
            [MBProgressHUD showError:YZMsg(@"public_networkError")];
        }];
    }else{
        [self.historyCollection reloadData];
    }
}

- (void)initCollection {
    FLLayout *layout = [[FLLayout alloc]init];
    layout.dataSource = self;

    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing=0.f;//左右间隔
    flowLayout.minimumLineSpacing=0.f;
    
    self.historyCollection.delegate = self;
    self.historyCollection.dataSource = self;
    self.historyCollection.collectionViewLayout = flowLayout;
    self.historyCollection.allowsMultipleSelection = NO;

    if (curLotteryType == 10) {
        UINib *nib =[UINib nibWithNibName:@"OpenNNHistoryCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        [self.historyCollection registerNib: nib forCellWithReuseIdentifier:@"OpenNNHistoryCell"];
    }else{
        UINib *nib=[UINib nibWithNibName:kOpenAwardCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        [self.historyCollection registerNib: nib forCellWithReuseIdentifier:kOpenAwardCollectionViewCell];
    }
    
    
    
    self.historyCollection.backgroundColor=[UIColor clearColor];
    
    WeakSelf
    self.historyCollection.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->page = 0;
        [strongSelf getInfo];
        
    }];
    self.historyCollection.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->page ++;
        [strongSelf getInfo];
    }];
    
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allDatas.count;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSDictionary *dict = [self.allDatas objectAtIndex:indexPath.row];
    if (curLotteryType == 10) {
        OpenNNHistoryCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"OpenNNHistoryCell" forIndexPath:indexPath];
        lastResultModel *model = [lastResultModel mj_objectWithKeyValues:dict];
        cell.model = model;
        return cell;
    }else{
        OpenAwardCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kOpenAwardCollectionViewCell forIndexPath:indexPath];
        [cell setOpenAwardData:curLotteryType openData:dict selectType:curSelectedType];
        return cell;
    }
    
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if (curLotteryType == 10){
        return CGSizeMake(SCREEN_WIDTH, 90);
    }
    return CGSizeMake(_window_width, 70);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (curLotteryType == 10){
        return CGSizeMake(SCREEN_WIDTH, 90);
    }
    return CGSizeMake(_window_width, 70);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (curLotteryType == 10){
        return UIEdgeInsetsMake(0, 0, 5, 0);
    }
    return UIEdgeInsetsMake(0, 10, 5, 10);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (curLotteryType == 10){
        CGSize size={0,0};
        return size;
    }
    CGSize size={0,0};
    
    return size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
