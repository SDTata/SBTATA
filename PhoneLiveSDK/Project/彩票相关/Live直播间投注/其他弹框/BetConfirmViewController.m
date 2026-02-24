//
//  BetConfirmViewController.m
//
//

#import "BetConfirmViewController.h"
#import "WMZDialog.h"
#import "BetConfirmCollectionViewCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kBetConfirmCollectionViewCell @"BetConfirmCollectionViewCell"

@interface BetConfirmViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSArray * betScaleNumArray;
    NSArray * betScaleBtnArray;
    BOOL bUICreated; // UI是否创建
    
    WMZDialog *myAlert;//Dialog
    
    UITextField *alertTextField;
    
    UIButton *maxButton;
    UIButton *halfButton;
    UIButton *doubleButton;
    UITextField *amountLabel;
    double baseRMB;
    
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSInteger curSelectedBetScaleIndex;
    NSMutableDictionary *orderInfo;
    
    NSMutableArray *orders;
    
    NSInteger curEditBetCellIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *betNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *confirmLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *yuanLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuanLabel1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_confirmWidthConstaint;
@end

@implementation BetConfirmViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTime:) name:@"lotterySecondNotify" object:nil];
    
    [self refreshUI];
}
- (void)showLoading{
    if(!testActivityIndicator){
        testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        testActivityIndicator.centerX = self.view.centerX;
        testActivityIndicator.centerY = self.view.height/2;
        [self.view addSubview:testActivityIndicator];
        testActivityIndicator.color = [UIColor whiteColor];
    }
    [testActivityIndicator startAnimating]; // 开始旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
}
- (void)hideLoading{
    [testActivityIndicator stopAnimating]; // 结束旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"lotterySecondNotify" object:nil];
}

- (void)refreshData:(NSNotification *)notification {
    NSString *leftCoin = (notification.userInfo[@"money"]);
    
    LiveUser *user = [Config myProfile];
    user.coin = minstr(leftCoin);
    [Config updateProfile:user];
    
    [self refreshLeftCoinLabel];
}

- (void)refreshTime:(NSNotification *)notification {
    NSString *betLeftTime = (notification.userInfo[@"betLeftTime"]);
    NSString *sealingTime = (notification.userInfo[@"sealingTime"]);
    NSString *issue = (notification.userInfo[@"issue"]);
    NSString *lotteryType = minstr(notification.userInfo[@"lotteryType"]);

    if(minstr(orderInfo[@"lotteryType"]) && [lotteryType isEqualToString:minstr(orderInfo[@"lotteryType"])]){
        if(![minstr(orderInfo[@"issue"]) isEqualToString:issue]){
            [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"LobbyBet_name%@_date%@_Alert"), orderInfo[@"name"], issue]];
            orderInfo[@"issue"] = issue;
        }
        NSInteger betLeftTimeInt = [betLeftTime integerValue];
        NSInteger sealingTimeInt = [sealingTime integerValue];
        if(betLeftTimeInt - sealingTimeInt > 0){
            [self.betConfirmBtn setEnabled:true];
            self.lotteryInfoLabel.text = [NSString stringWithFormat:YZMsg(@"LobbyBet_name%@_date%@_second%@timeTi"), orderInfo[@"name"], issue, [YBToolClass timeFormatted:(betLeftTimeInt - sealingTimeInt)]];
        }else if(betLeftTimeInt > 0){
            self.lotteryInfoLabel.text = [NSString stringWithFormat:YZMsg(@"LobbyBet_name%@_date%@_endbet"), orderInfo[@"name"], issue];
            [self.betConfirmBtn setEnabled:false];
        }else{
            self.lotteryInfoLabel.text = [NSString stringWithFormat:YZMsg(@"LobbyBet_name%@_date%@_betOpening"), orderInfo[@"name"], issue];
            [self.betConfirmBtn setEnabled:false];
        }
    }
}


-(void)setOrderInfo:(NSDictionary *)dict{
    if(!orderInfo){
        orderInfo = [NSMutableDictionary dictionary];
    }
    for (NSString * key in dict) {
        orderInfo[key] = dict[key];
    }
    // orderInfo = dict;
    orders = orderInfo[@"orders"];
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    // 更新下注描述
    [self refreshBetMoneyLabel];
    // 更新余额
    [self refreshLeftCoinLabel];
    
    self.lotteryInfoLabel.text = [NSString stringWithFormat:YZMsg(@"LobbyBet_name%@_date%@_second%@timeTi"), orderInfo[@"name"], orderInfo[@"issue"], [YBToolClass timeFormatted:([orderInfo[@"betLeftTime"] integerValue] - [orderInfo[@"sealingTime"] integerValue])]];
}
-(void)refreshLeftCoinLabel{
    LiveUser *user = [Config myProfile];
    NSString *coinst =  [YBToolClass getRateBalance:user.coin showUnit:YES];
    self.leftCoinLabel.text =coinst;
}

-(void)refreshBetMoneyLabel{
    CGFloat totalMoney = 0;
    for (int i = 0; i < orders.count; i++) {
        NSDictionary *dict = [orders objectAtIndex:i];
        totalMoney += [dict[@"money"] doubleValue];
    }
    NSInteger betScale = [betScaleNumArray[curSelectedBetScaleIndex] integerValue];
    totalMoney *= betScale;
    NSInteger orderCount = orders.count;
    NSString *orderCountStr = [NSString stringWithFormat:@"%ld", (long)orderCount];
    NSString *totalMoneyStr = [YBToolClass getRateCurrencyWithoutK:[NSString stringWithFormat:@"%.2f", totalMoney]];
    self.betCountLabel.text = orderCountStr;
    self.betMoneyLabel.text = totalMoneyStr;
}
-(void)exitView{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)initUI{
    bUICreated = true;
    [self initCollection];
    [self.betCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    /**
     @property (weak, nonatomic) IBOutlet UIButton *betScale1Btn;
     @property (weak, nonatomic) IBOutlet UIButton *betScale2Btn;
     @property (weak, nonatomic) IBOutlet UIButton *betScale5Btn;
     @property (weak, nonatomic) IBOutlet UIButton *betScale10Btn;
     @property (weak, nonatomic) IBOutlet UIButton *betScale20Btn;
     @property (weak, nonatomic) IBOutlet UILabel *lotteryInfoLabel;
     @property (weak, nonatomic) IBOutlet UILabel *betMoneyLabel;
     @property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;
     @property (weak, nonatomic) IBOutlet UIButton *betConfirmBtn;
     @property (weak, nonatomic) IBOutlet UICollectionView *betCollectionView;
     */
    curSelectedBetScaleIndex = 0;
    
    betScaleNumArray = @[
        @1,
        @2,
        @5,
        @10,
        @20,
    ];
    betScaleBtnArray = @[
        self.betScale1Btn,
        self.betScale2Btn,
        self.betScale5Btn,
        self.betScale10Btn,
        self.betScale20Btn
    ];
//    // TODO ？？？ 取出来值就不对了
//    NSInteger chipIdx = [common getChipIndex];
//    customChipNum = [common getCustomChipNum];

    for (int i = 0; i < betScaleBtnArray.count; i++) {
        UIButton *btn = [betScaleBtnArray objectAtIndex:i];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor = 0.5;
        NSString *betS = [NSString stringWithFormat:@"BetCell_double%@",betScaleNumArray[i]];
        [btn setTitle:YZMsg(betS) forState:UIControlStateHighlighted];
        [btn setTitle:YZMsg(betS) forState:UIControlStateNormal];
        [btn setTitle:YZMsg(betS) forState:UIControlStateSelected];
        [btn setTag:i];
        [btn addTarget:self action:@selector(doSelectBetScale:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if(curSelectedBetScaleIndex == i){
            // 高亮
            btn.backgroundColor = RGB(252, 54, 110);
            // 更新所有cell
            // 更新金额
        }else{
            btn.backgroundColor = [UIColor clearColor];
        }
    }

    [self.betConfirmBtn addTarget:self action:@selector(doConfirmBet) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
}

static BOOL isBettting;
-(void)doConfirmBet{
    NSInteger maxCount = orders.count;
    NSString *way = @"[";
    NSString *money = @"[";

    NSInteger selectIdx = 0;
    for (int i=0; i<maxCount; i++) {
        NSString *title = orders[i][@"way"];
        NSInteger _money = [orders[i][@"money"] integerValue] * [betScaleNumArray[curSelectedBetScaleIndex] floatValue];

        if(selectIdx == 0){
            way = [NSString stringWithFormat:@"%@\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@%ld",money, (long)_money];
        }else{
            way = [NSString stringWithFormat:@"%@,\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@,%ld",money, (long)_money];
        }
        selectIdx++;
    }
    if(selectIdx == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyBet_selecte_Warning")];
        return;
    }
    way = [NSString stringWithFormat:@"%@%@",way,@"]"];
    money = [NSString stringWithFormat:@"%@%@",money,@"]"];
    
    NSString *lottery_type = minstr(orderInfo[@"lotteryType"]);
    NSString *issue = minstr(orderInfo[@"issue"]);
    NSString *optionName = orderInfo[@"optionName"];
    NSInteger liveuid = [GlobalDate getLiveUID];
    NSString *liveuidstr = [NSString stringWithFormat:@"%ld", (long)liveuid];
    

    [self showLoading];
    if (isBettting) {
        return;
    }
    isBettting = YES;
    NSString *betIdStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
   
    WeakSelf
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting&uid=%@&token=%@&lottery_type=%@&money=%@&way=%@&serTime=%@&issue=%@&optionName=%@&liveuid=%@&betid=%@",[Config getOwnID],[Config getOwnToken],lottery_type,money,way,minnum([[NSDate date] timeIntervalSince1970]),issue,optionName,liveuidstr,betIdStr];//User.getPlats
    [[YBNetworking sharedManager] postNetworkWithUrl:betUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        isBettting = NO;
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"xxxxxxxxx%@",info);
        [strongSelf hideLoading];
        if(code == 0)
        {
            NSDictionary *dict = info;
            
            LiveUser *user = [Config myProfile];
            user.coin = minstr(dict[@"left_coin"]);
            [Config updateProfile:user];
            [strongSelf refreshLeftCoinLabel];
            [MBProgressHUD showError:msg];
            // 清空信息
            [strongSelf doClose];
        }
        else{
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        isBettting = NO;
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hideLoading];
        // 请求失败
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
    }];
}
-(void)doSelectBetScale:(UIButton *)sender{
    curSelectedBetScaleIndex = sender.tag;
    [self.betCollectionView reloadData];
    [self refreshBetMoneyLabel];
    for (int i = 0; i < betScaleBtnArray.count; i++) {
        UIButton *btn = [betScaleBtnArray objectAtIndex:i];
        if(curSelectedBetScaleIndex == i){
            btn.backgroundColor = RGB(252, 54, 110);
        }else{
            btn.backgroundColor = [UIColor clearColor];
        }
    }
}

-(void)doClose{
    self.betBlock(0,0);
}


- (void)initCollection {
    //    if (nil == _betCollectionView) {
    
//    FLLayout *layout = [[FLLayout alloc]init];
//    layout.dataSource = self;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing=0.f;//左右间隔
    flowLayout.minimumLineSpacing=0.f;
//    float leftMargin = 0.0;
//    self.betCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,kScreenWidth,self.view.height) collectionViewLayout:flowLayout];
    
    self.betCollectionView.delegate = self;
    self.betCollectionView.dataSource = self;
//    self.betCollectionView.collectionViewLayout = layout;
    self.betCollectionView.allowsMultipleSelection = YES;
    
    UINib *nib=[UINib nibWithNibName:kBetConfirmCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.betCollectionView registerNib: nib forCellWithReuseIdentifier:kBetConfirmCollectionViewCell];
    
    self.betCollectionView.backgroundColor=[UIColor clearColor];
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (orders.count==0) {
        return 0;
    }
    
    //    NSDictionary *dict =ways[waySelectIndex];
    //    NSArray *array = dict[@"options"];
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (orders.count==0) {
        return 0;
    }
    
    return orders.count;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //BetConfirmCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kBetConfirmCollectionViewCell forIndexPath:indexPath];
//    cell.selected = !cell.selected;
    [self doChangeChip:indexPath.row];
    // TODO 弹出修改注单
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //BetConfirmCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kBetConfirmCollectionViewCell forIndexPath:indexPath];
//    cell.selected = !cell.selected;
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BetConfirmCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kBetConfirmCollectionViewCell forIndexPath:indexPath];
    /*
     @property (weak, nonatomic) IBOutlet UILabel *betWay;
     @property (weak, nonatomic) IBOutlet UILabel *betWayLabel;
     @property (weak, nonatomic) IBOutlet UILabel *betDescLabel;
     @property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
     @property (weak, nonatomic) IBOutlet UIButton *removeButton;
     */
    NSInteger optionIndex = indexPath.row;
    NSLog(@"%@", [NSString stringWithFormat:@"设置%ld个为%@", (long)optionIndex, orders[optionIndex][@"way"]]);
    NSString * waySt = orders[optionIndex][@"st"];
    if ([PublicObj checkNull:waySt]) {
        waySt = orders[optionIndex][@"way"];
    }
    cell.betWayLabel.text= waySt;
    
    NSString * optionNameSt = orderInfo[@"optionNameSt"];
    if ([PublicObj checkNull:optionNameSt]) {
        optionNameSt = orderInfo[@"optionName"];
    }
    cell.betDescLabel.text= [NSString stringWithFormat:@"%@-%@",orderInfo[@"name"], optionNameSt];
    cell.betCountLabel.text = @"1"; // 默认都是1注
    cell.betScaleLabel.text = @"";//[NSString stringWithFormat:@"%ld", (long)[betScaleNumArray[curSelectedBetScaleIndex] integerValue]]; // 倍率
    
    NSString *scaleN = [NSString stringWithFormat:@"%ld", [betScaleNumArray[curSelectedBetScaleIndex] integerValue]];
    NSString *scaleStr = [NSString stringWithFormat:YZMsg(@"LobbyBetCell_double_total"),scaleN];
    NSMutableAttributedString *attru = [[NSMutableAttributedString alloc]initWithString:scaleStr];
    [attru addAttribute:NSForegroundColorAttributeName value:cell.betScaleLabel.textColor range:NSMakeRange(1, scaleN.length)];
    [attru addAttribute:NSForegroundColorAttributeName value:cell.betScaleNameLabel.textColor range:NSMakeRange(1+scaleN.length, scaleStr.length-1-scaleN.length)];
    cell.betScaleNameLabel.attributedText = attru;
    
   
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2fx1", [betScaleNumArray[curSelectedBetScaleIndex] integerValue] * [[YBToolClass getRateCurrencyWithoutK: orders[optionIndex][@"money"]] doubleValue] /* * [betScaleNumArray[curSelectedBetScaleIndex] integerValue]*/]; // 单注金额
    [cell.removeButton addTarget:self action:@selector(deleteCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self refreshHeight:cell.frame.size.height];
    
    return cell;
}
- (void)deleteCellButtonPressed: (id)sender{
    if(orders.count <= 1){
        [MBProgressHUD showError:YZMsg(@"LobbyBet_DeleteTip")];
        return;
    }
    
    
    BetConfirmCollectionViewCell *cell = (BetConfirmCollectionViewCell *)[[sender superview] superview];//获取cell
    
    NSIndexPath *indexpath = [self.betCollectionView indexPathForCell:cell];//获取cell对应的indexpath;
    
    // 根据indexpath移除对应数据源
    [orders removeObjectAtIndex:indexpath.row];
    
    // 根据数据源更新显示
    [self.betCollectionView reloadData];
    [self refreshBetMoneyLabel];
    
    [self refreshHeight:cell.frame.size.height];
    
    NSLog(@"删除按钮，section:%ld ,   row: %ld",(long)indexpath.section,(long)indexpath.row);
}

-(void)refreshHeight:(CGFloat)height{
    if (self.isFromFollow) {
        return;
    }
    CGRect f = self.view.frame;
    CGFloat cellCountHeight = (MIN(orders.count, 3)-1) * height;
    CGFloat newHeight = MAX(280 + cellCountHeight, 310);
    BOOL bNeedAni = true;
    if(ABS(newHeight - f.size.height) < 1){
        bNeedAni = false;
    }
    f.size.height = MAX(280 + cellCountHeight, 310);
    
    if(bNeedAni){
        [UIView animateWithDuration:0.25 animations:^{
            self.view.frame = CGRectMake(f.origin.x, SCREEN_HEIGHT-f.size.height, f.size.width, f.size.height);
            self.view.bottom = SCREEN_HEIGHT;
        } completion:^(BOOL finished) {
            //        [kWindow endEditing:YES];
        }];
    }else{
        self.view.frame = CGRectMake(f.origin.x, SCREEN_HEIGHT-f.size.height, self.view.frame.size.width, f.size.height);
        self.view.bottom =   SCREEN_HEIGHT;
    }
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    return CGSizeMake(355, 65);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(355, 65);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 3, 0, 3);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth,5};
    return size;
}

//-(void)doSelectChip:(UIButton *)sender{
//    NSInteger maxCount = allChipBtnArray.count;
//
//    for (int i = 0; i < maxCount; i ++) {
//        UIButton *btn = allChipBtnArray[i];
//        if(i == sender.tag){
//            btn.layer.borderWidth = 1;
//        }else{
//            btn.layer.borderWidth = 0;
//        }
//    }
//
//    if(iLastSelectIndex == sender.tag){
//        if(sender.tag == 7){
//            [self doCustomChip];
//        }else{
//            [common saveChipNum:[allChipNumArray[sender.tag] integerValue]];
//            [common saveChipIndex:sender.tag];
//        }
//    }
//    iLastSelectIndex = sender.tag;
//}
-(void)doChangeChip:(NSInteger)row{
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
    .wHeightSet(160)
    .wMainOffsetYSet(0)
    .wShowAnimationSet(AninatonZoomIn)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.25)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        STRONGSELF
        
        double cellBetMoney = [common getLastChipModel].chipNumber;
        if (strongSelf->orders[row][@"money"]) {
            if (strongSelf->orders.count > row && strongSelf->orders[row] != nil) {
                cellBetMoney = [[strongSelf->orders[row] objectForKey:@"money"] doubleValue];
            }
        }
        strongSelf->curEditBetCellIndex = row;
        strongSelf->baseRMB = cellBetMoney;
        
//        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 60)];
//        amountLabel.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", strongSelf->baseRMB]showUnit: YES];
//        amountLabel.textAlignment = NSTextAlignmentCenter;
//        amountLabel.textColor = RGB(91, 100, 126);
//        [mainView addSubview:amountLabel];
//        strongSelf->amountLabel = amountLabel;
        
        UITextField *amountLabel = [[UITextField alloc] initWithFrame:CGRectMake(60, 10, 100, 60)];
        strongSelf->baseRMB = [common getCustomChipNum] ? [common getCustomChipNum] : 2;
        amountLabel.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", strongSelf->baseRMB]showUnit: NO];
        amountLabel.textAlignment = NSTextAlignmentCenter;
        amountLabel.textColor = RGB(91, 100, 126);
        amountLabel.font = vkFont(16);
        amountLabel.keyboardType = UIKeyboardTypeNumberPad;
        [amountLabel addTarget:strongSelf action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel *unitLabel = [UILabel new];
        unitLabel.textColor = RGB(91, 100, 126);
        unitLabel.font = vkFont(16);
        unitLabel.frame = CGRectMake(0, 0, 40, 60);
        unitLabel.text = [Config getRegionCurrenyChar];
        amountLabel.leftView = unitLabel;
        amountLabel.leftViewMode = UITextFieldViewModeAlways;
        
        [mainView addSubview:amountLabel];
        strongSelf->amountLabel = amountLabel;
        
        
        UIButton *maxButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 60)];
        [maxButton setTitle: YZMsg(@"MaxMoney") forState: UIControlStateNormal];
        [maxButton setTitleColor:RGB(115, 119, 119) forState:UIControlStateNormal];
        [maxButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
        [maxButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [maxButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_max_button_normal"] forState:UIControlStateNormal];
        [maxButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_max_button_selected"] forState:UIControlStateSelected];
        [maxButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_max_button_selected"] forState:UIControlStateHighlighted];
        maxButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        maxButton.tag = 1;
        [maxButton addTarget:strongSelf action:@selector(customChipAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:maxButton];
        strongSelf->maxButton = maxButton;
        
        UIButton *halfButton = [[UIButton alloc] initWithFrame:CGRectMake(mainView.frame.size.width-50, 10, 40, 29)];
        [halfButton setTitle: @"1/2" forState: UIControlStateNormal];
        [halfButton setTitleColor:RGB(115, 119, 119) forState:UIControlStateNormal];
        [halfButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
        [halfButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [halfButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_normal"] forState:UIControlStateNormal];
        [halfButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateSelected];
        [halfButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateHighlighted];
        halfButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        halfButton.tag = 2;
        [halfButton addTarget:strongSelf action:@selector(customChipAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:halfButton];
        strongSelf->halfButton = halfButton;
        
        UIButton *doubleButton = [[UIButton alloc] initWithFrame:CGRectMake(mainView.frame.size.width-50, 42, 40, 29)];
        [doubleButton setTitle: @"2x" forState: UIControlStateNormal];
        [doubleButton setTitleColor:RGB(115, 119, 119) forState:UIControlStateNormal];
        [doubleButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
        [doubleButton setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [doubleButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_normal"] forState:UIControlStateNormal];
        [doubleButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateSelected];
        [doubleButton setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_half_button_selected"] forState:UIControlStateHighlighted];
        doubleButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        doubleButton.tag = 3;
        [doubleButton addTarget:strongSelf action:@selector(customChipAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:doubleButton];
        strongSelf->doubleButton = doubleButton;
        
        
        [maxButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(mainView.top).offset(18);
            make.leading.mas_equalTo(mainView.mas_leading).offset(20);
            make.height.mas_equalTo(74);
            make.width.mas_equalTo(46);
        }];
        
        [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(maxButton.mas_trailing).offset(4);
            make.height.centerY.mas_equalTo(maxButton);
            make.trailing.mas_equalTo(halfButton.mas_leading).inset(4);
        }];
        
        [halfButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(amountLabel.mas_trailing);
            make.trailing.mas_equalTo(mainView.mas_trailing).inset(20);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(46);
            make.top.mas_equalTo(maxButton);
        }];
        
        [doubleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(halfButton.mas_leading);
            make.trailing.mas_equalTo(mainView.mas_trailing).inset(20);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(46);
            make.bottom.mas_equalTo(maxButton);
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:cancelBtn];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        cancelBtn.frame = CGRectMake(0, 100+30, mainView.frame.size.width/2, 40);
        [cancelBtn setTitle:YZMsg(@"public_back") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_cancel_button"] forState:UIControlStateNormal];
        [cancelBtn addTarget:strongSelf action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(maxButton.mas_leading);
            make.trailing.mas_equalTo(mainView.mas_centerX).inset(5);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(mainView.mas_bottom).inset(10);
        }];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        confirmBtn.frame = CGRectMake(mainView.frame.size.width/2, 100+30, mainView.frame.size.width/2, 40);
        [confirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [confirmBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"custom_chip_alert_confirm_button"] forState:UIControlStateNormal];
        [confirmBtn addTarget:strongSelf action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.bottom =  CGRectGetMaxY(mainView.frame);
        confirmBtn.bottom =  CGRectGetMaxY(mainView.frame);
        
        [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(halfButton.mas_trailing);
            make.leading.mas_equalTo(mainView.mas_centerX).offset(5);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(mainView.mas_bottom).inset(10);
        }];
        mainView.layer.cornerRadius = 8;
        mainView.clipsToBounds = YES;
        return mainView;
    })
    .wStart();
}

- (void)textFieldDidChange:(UITextField *)textField {
    baseRMB = textField.text.integerValue;
  
}

-(void)customChipAction:(UIButton*)sender{
    if (sender.tag == 1) {
        baseRMB = 50000;
        [maxButton setSelected:YES];
        [halfButton setSelected:NO];
        [doubleButton setSelected:NO];
    } else if (sender.tag == 2){
        baseRMB = baseRMB > 2 ? (baseRMB/2 > 2 ? baseRMB/2 : 2) : 2;
        [maxButton setSelected:NO];
        [halfButton setSelected:YES];
        [doubleButton setSelected:NO];
    } else {
        
        baseRMB = (baseRMB >= 2 && baseRMB < 50000) ? (baseRMB*2 < 50000 ? baseRMB*2 : 50000) : 50000;
        [maxButton setSelected:NO];
        [halfButton setSelected:NO];
        [doubleButton setSelected:YES];
    }
    amountLabel.text = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%.2f", baseRMB]showUnit: YES];
}

-(void)closeAction:(UIButton*)sender{
    [myAlert closeView];
}

-(void)confirmAction:(UIButton*)sender{
    if (baseRMB <= 0) {
        return;
    }
    NSString *rmbStr = [YBToolClass getRmbCurrency:[NSString stringWithFormat:@"%.5f",baseRMB]];
    if ([rmbStr doubleValue]<2) {
        baseRMB =  [[YBToolClass getRateCurrency:@"2" showUnit: NO] doubleValue];
    }
    
    
    ChipsModel *lastModel = [common getLastChipModel];
    lastModel.chipNumber = baseRMB;
    [common saveLastChipModel:lastModel];
    [orders[curEditBetCellIndex] setObject:[NSString stringWithFormat:@"%f", baseRMB] forKey:@"money"];
    [self.betCollectionView reloadData];
    [self refreshBetMoneyLabel];
    [myAlert closeView];
}

//// 确认投注
//-(void)doConfirmBet{
//    NSInteger maxCount = allChipBtnArray.count;
//    for (int i = 0; i < maxCount; i ++) {
//        UIButton *btn = allChipBtnArray[i];
//        if(btn.layer.borderWidth == 1){
//            [common saveChipIndex:i];
//            if(i == 7){
//                [common saveChipNum:[common getCustomChipNum]];
//            }else{
//                [common saveChipNum:[allChipNumArray[i] integerValue]];
//            }
//        }
//    }
//
//    self.block();
//}
//
//-(void)doCharge:(UIButton *)sender{

//}
//
//- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
//    //设置长宽
////    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    UIImage *original = resultImage;
//    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
//    // 开始一个Image的上下文
//    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
//    // 添加圆角
//    [[UIBezierPath bezierPathWithRoundedRect:frame
//                                cornerRadius:radius] addClip];
//    // 绘制图片
//    [original drawInRect:frame];
//    // 接受绘制成功的图片
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.betCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.confirmLabelTitle.text = YZMsg(@"LobbyBetConfirm_title");
    NSDictionary *coinAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15]};
    CGSize size = [YZMsg(@"LobbyBetConfirm_title") sizeWithAttributes:coinAttrs];
    [self.betConfirmBtn setTitle:YZMsg(@"LobbyBetConfirm_title") forState:UIControlStateNormal];
    self.layout_confirmWidthConstaint.constant = size.width + 12;
    self.betNumLabel.text = YZMsg(@"LobbyBetCell_double_total11");
    self.balanceLabel.text = YZMsg(@"LobbyBetConfirm_balance");
    self.yuanLabel.text = [common name_coin];
    self.yuanLabel1.text = [common name_coin];
    self.view.width = _window_width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
