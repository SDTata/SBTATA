//
//  LobbyBetConfirmViewController.m
//
//

#import "LobbyBetConfirmViewController.h"
#import "WMZDialog.h"
#import "LobbyBetConfirmCollectionViewCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kLobbyBetConfirmCollectionViewCell @"LobbyBetConfirmCollectionViewCell"

@interface LobbyBetConfirmViewController ()<UICollectionViewDataSource>{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    NSArray * betScaleNumArray;
    NSArray * betScaleBtnArray;
    BOOL bUICreated; // UI是否创建
    
    WMZDialog *myAlert;//Dialog
    
    UITextField *alertTextField;
    
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSInteger curSelectedBetScaleIndex;
    NSMutableDictionary *orderInfo;
    
    NSMutableArray *orders;
    
    NSInteger curEditBetCellIndex;
}

@property (weak, nonatomic) IBOutlet UILabel *betConfirmtitleLabel;

@end

@implementation LobbyBetConfirmViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    
    
    // TODO 出现动画
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
}

- (void)refreshTime:(NSNotification *)notification {
    NSString *betLeftTime = (notification.userInfo[@"betLeftTime"]);
    NSString *sealingTime = (notification.userInfo[@"sealingTime"]);
    NSString *issue = (notification.userInfo[@"issue"]);
    NSString *lotteryType =  minstr((notification.userInfo[@"lotteryType"]));

    if(orderInfo[@"lotteryType"] && [minstr(lotteryType) isEqualToString:minstr(orderInfo[@"lotteryType"])]){
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


-(void)setOrderInfo:(NSDictionary *)dict betScale:(NSInteger)betScale{
    if(!orderInfo){
        orderInfo = [NSMutableDictionary dictionary];
    }
    for (NSString * key in dict) {
        orderInfo[key] = dict[key];
    }
    // orderInfo = dict;
    orders = [NSMutableArray arrayWithArray:orderInfo[@"orders"]];
    for (int i = 0; i<self.betScaleNumArray.count; i++) {
        NSInteger currentScale = [betScaleNumArray[i] integerValue];
        if (currentScale == betScale) {
            curSelectedBetScaleIndex = i;
            break;
        }
    }
    [self refrshBetScaleButton];
}

-(NSArray*)betScaleNumArray
{
    if (betScaleNumArray == nil) {
        betScaleNumArray = @[
            @1,
            @2,
            @5,
            @10,
            @20,
        ];
    }
    return betScaleNumArray;
}
-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    // 更新下注描述
    //[self refreshBetMoneyLabel];
    
}

-(void)exitView{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)initUI{
    bUICreated = true;
    [self initCollection];
    [self.betCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doClose)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.shadowView addGestureRecognizer:tapGestureRecognizer];
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

    [self refrshBetScaleButton];

    [self.emptyBtn addTarget:self action:@selector(doEmptyCart) forControlEvents:UIControlEventTouchUpInside];
    //[self.betConfirmBtn addTarget:self action:@selector(doConfirmBet) forControlEvents:UIControlEventTouchUpInside];
    //[self.closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
}

-(void)refrshBetScaleButton
{
    for (int i = 0; i < betScaleBtnArray.count; i++) {
        UIButton *btn = [betScaleBtnArray objectAtIndex:i];
        NSString *betS = [NSString stringWithFormat:@"BetCell_double%@",betScaleNumArray[i]];
        [btn setTitle:YZMsg(betS) forState:UIControlStateHighlighted];
        [btn setTitle:YZMsg(betS) forState:UIControlStateNormal];
        [btn setTitle:YZMsg(betS) forState:UIControlStateSelected];

        [btn setTag:i];
        [btn addTarget:self action:@selector(doSelectBetScale:) forControlEvents:UIControlEventTouchUpInside];
        
        if(curSelectedBetScaleIndex == i){
            // 高亮
            btn.backgroundColor = RGB(252, 54, 110);
            [btn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
            // 更新所有cell
            // 更新金额
        }else{
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitleColor:RGB(252, 54, 110) forState:UIControlStateNormal];
        }
    }
}

-(void)doEmptyCart{
    [common saveLotteryBetCart:@[]];
    self.betBlock(0,0);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedLotteryBetCart" object:nil userInfo:nil];
    return;
}

static BOOL isBetting;
-(void)doConfirmBet{
    NSInteger maxCount = orders.count;
    NSString *way = @"[";
    NSString *money = @"[";

    NSInteger selectIdx = 0;
    for (int i=0; i<maxCount; i++) {
        //LobbyBetConfirmCollectionViewCell *cell = [self.betCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//        LobbyBetConfirmCollectionViewCell *cell=[self.betCollectionView dequeueReusableCellWithReuseIdentifier:kLobbyBetConfirmCollectionViewCell forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *title = orders[i][@"title"];
        NSInteger _money = [orders[i][@"money"] integerValue] * [betScaleNumArray[curSelectedBetScaleIndex] floatValue];

        if(selectIdx == 0){
            way = [NSString stringWithFormat:@"%@\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@%ld",money, _money];
        }else{
            way = [NSString stringWithFormat:@"%@,\"%@\"",way, title];
            money = [NSString stringWithFormat:@"%@,%ld",money, _money];
        }
        selectIdx++;
    }
    if(selectIdx == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyBet_selecte_Warning")];
        return;
    }
    way = [NSString stringWithFormat:@"%@%@",way,@"]"];
    money = [NSString stringWithFormat:@"%@%@",money,@"]"];
    

//    uid    是    string    用户名
//    token    是    string    token
//    lottery_type    是    string    彩种
//    money    是    string    投注金额
//    way    是    string    投注选项
//    serTime    是    string    投注时间
//    issue    是    string    投注期号
    NSString *lottery_type = minstr(orderInfo[@"lotteryType"]);
    NSString *issue = minstr(orderInfo[@"issue"]);
    NSString *optionName = orderInfo[@"optionName"];
    NSInteger liveuid = [GlobalDate getLiveUID];

    NSString *liveuidstr = [NSString stringWithFormat:@"%ld", liveuid];
    

    [self showLoading];

    if (isBetting) {
        return;
    }
    NSString *betIdStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
   
    isBetting = YES;
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting"];//User.getPlats
    NSDictionary *paramDic = @{@"lottery_type":lottery_type,@"money":money,@"way":way,@"serTime":minnum([[NSDate date] timeIntervalSince1970]),@"issue":issue,@"optionName":optionName,@"liveuid":liveuidstr,@"betid":betIdStr};
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:betUrl withBaseDomian:YES andParameter:paramDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        isBetting = NO;
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
            
            [MBProgressHUD showError:msg];
            // 清空信息
            [strongSelf doClose];
        }
        else{
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        isBetting = NO;
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
    for (int i = 0; i < betScaleBtnArray.count; i++) {
        UIButton *btn = [betScaleBtnArray objectAtIndex:i];
        if(curSelectedBetScaleIndex == i){
            btn.backgroundColor = RGB(252, 54, 110);
            [btn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitleColor:RGB(252, 54, 110) forState:UIControlStateNormal];
        }
    }
    
    NSInteger betScale = [betScaleNumArray[curSelectedBetScaleIndex] integerValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedLotteryBetScale" object:nil userInfo:@{@"betScale":[NSString stringWithFormat:@"%ld", (long)betScale]}];
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
//    float leftMargin =0;
//    self.betCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,kScreenWidth,self.view.height) collectionViewLayout:flowLayout];
    
    self.betCollectionView.delegate = self;
    self.betCollectionView.dataSource = self;
    self.betCollectionView.collectionViewLayout = flowLayout;
    self.betCollectionView.allowsMultipleSelection = NO;
    
    UINib *nib=[UINib nibWithNibName:kLobbyBetConfirmCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [self.betCollectionView registerNib: nib forCellWithReuseIdentifier:kLobbyBetConfirmCollectionViewCell];
    
    //self.betCollectionView.backgroundColor=[UIColor clearColor];
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
    //LobbyBetConfirmCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLobbyBetConfirmCollectionViewCell forIndexPath:indexPath];
//    cell.selected = !cell.selected;
    [self doChangeChip:indexPath.row];
    // TODO 弹出修改注单
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //LobbyBetConfirmCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLobbyBetConfirmCollectionViewCell forIndexPath:indexPath];
//    cell.selected = !cell.selected;
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LobbyBetConfirmCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kLobbyBetConfirmCollectionViewCell forIndexPath:indexPath];
    /*
     @property (weak, nonatomic) IBOutlet UILabel *betWay;
     @property (weak, nonatomic) IBOutlet UILabel *betWayLabel;
     @property (weak, nonatomic) IBOutlet UILabel *betDescLabel;
     @property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
     @property (weak, nonatomic) IBOutlet UIButton *removeButton;
     */
    NSInteger optionIndex = indexPath.row;
//    NSLog([NSString stringWithFormat:@"设置%ld个为%@", (long)optionIndex, orders[optionIndex][@"title"]]);
    NSString *title = orders[optionIndex][@"st"];
//    NSArray *splite = [title componentsSeparatedByString:@"_"];
    
    
    
    cell.betWayLabel.text= title;//splite[splite.count-1];
    //cell.betDescLabel.text= [NSString stringWithFormat:@"%@-%@",orderInfo[@"name"], orderInfo[@"optionName"]];
    cell.betCountLabel.text = @"1"; // 默认都是1注
    cell.betScaleLabel.text = @"";//[NSString stringWithFormat:@"%ld", [betScaleNumArray[curSelectedBetScaleIndex] integerValue]]; // 倍率
    NSString *scaleN = [NSString stringWithFormat:@"%ld", [betScaleNumArray[curSelectedBetScaleIndex] integerValue]];
    NSString *scaleStr = [NSString stringWithFormat:YZMsg(@"LobbyBetCell_double_total"),scaleN];
    NSMutableAttributedString *attru = [[NSMutableAttributedString alloc]initWithString:scaleStr];
    [attru addAttribute:NSForegroundColorAttributeName value:cell.betScaleLabel.textColor range:NSMakeRange(1, scaleN.length)];
    [attru addAttribute:NSForegroundColorAttributeName value:cell.betScaleNameLabel.textColor range:NSMakeRange(1+scaleN.length, scaleStr.length-1-scaleN.length)];
    cell.betScaleNameLabel.attributedText = attru;
    
    cell.moneyLabel.text = [NSString stringWithFormat:@"¥%.1f", [betScaleNumArray[curSelectedBetScaleIndex] integerValue] * [orders[optionIndex][@"money"] floatValue] /* * [betScaleNumArray[curSelectedBetScaleIndex] integerValue]*/]; // 单注金额
    [cell.removeButton addTarget:self action:@selector(deleteCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self refreshHeight:cell.frame.size.height];
    
//    cell.betDescLabel.text=array[optionIndex][@"value"];
//    cell.backgroundColor=[UIColor clearColor];
//    cell.imageView.backgroundColor=[UIColor whiteColor];//UIColorFromRGB(0xF8FCF8);
//    //    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:meun.urlName] placeholderImage:[ImageBundle imagewithBundleName:kImageDefaultName]];
//
//    cell.imageView.layer.cornerRadius = 10;                           //圆角弧度
//    cell.imageView.layer.borderWidth = 1;
//    cell.imageView.layer.borderColor=[UIColor colorWithRed:188/255.0 green:190/255.0 blue:197/255.0 alpha:1.0].CGColor;
//    cell.imageView.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
//    ////    cell.layer.shadowRadius = 5;
//    cell.imageView.layer.shadowOpacity = 1;                         //阴影的不透明度
//    cell.imageView.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
    
    return cell;
}
- (void)deleteCellButtonPressed: (id)sender{
    if(orders.count <= 1){
        [common saveLotteryBetCart:@[]];
        self.betBlock(0,0);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedLotteryBetCart" object:nil userInfo:nil];
        return;
    }
    
    LobbyBetConfirmCollectionViewCell *cell = (LobbyBetConfirmCollectionViewCell *)[[sender superview] superview];//获取cell
    
    NSIndexPath *indexpath = [self.betCollectionView indexPathForCell:cell];//获取cell对应的indexpath;
    
    // 根据indexpath移除对应数据源
    [orders removeObjectAtIndex:indexpath.row];
    
    [common saveLotteryBetCart:orders];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedLotteryBetCart" object:nil userInfo:nil];
    
    // 根据数据源更新显示
    [self.betCollectionView reloadData];
    //[self refreshBetMoneyLabel];
    
    [self refreshHeight:cell.frame.size.height];
    
    NSLog(@"删除按钮，section:%ld ,   row: %ld",(long)indexpath.section,(long)indexpath.row);
    
    if (orders.count == 0) {
        [self doClose];
    }
}

-(void) refreshHeight:(CGFloat)height{
    CGFloat cellCountHeight = MIN(orders.count, 6) * height;
    CGFloat newHeight = MAX(145 + cellCountHeight, 200);
    BOOL bNeedAni = true;
    if(ABS(newHeight - ABS(self.bottomViewHeight.constant)) < 1){
        bNeedAni = false;
    }
    
    if(bNeedAni){
        WeakSelf
        [UIView animateWithDuration:0.25 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.bottomViewHeight.constant = newHeight * -1;
        } completion:^(BOOL finished) {
            //        [kWindow endEditing:YES];
        }];
    }else{
        self.bottomViewHeight.constant = newHeight * -1;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    return CGSizeMake(355, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(355, 45);
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
    .wMainOffsetYSet(0)
    .wShowAnimationSet(AninatonZoomIn)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.25)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        STRONGSELF
        UILabel *title = [UILabel new];
        title.font = [UIFont systemFontOfSize:15.0f];
        title.text = YZMsg(@"LobbyBet_changeBet");

        title.frame = CGRectMake(0, 0, mainView.frame.size.width, 30);
        [title setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:title];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(mainView.frame.size.width/3*1/2, 50, mainView.frame.size.width/3*2, 30)];
        textField.placeholder = [NSString stringWithFormat:@"%@2-50000",YZMsg(@"LobbyBet_RangeBetMoney")];
        textField.font = [UIFont systemFontOfSize:15.0f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
//        LobbyBetConfirmCollectionViewCell *cell=[strongSelf->.betCollectionView dequeueReusableCellWithReuseIdentifier:kLobbyBetConfirmCollectionViewCell forIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        //LobbyBetConfirmCollectionViewCell *cell = [self.betCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        
        double cellBetMoney =  [common getLastChipModel].chipNumber;
        if (cellBetMoney<1) {
            cellBetMoney = [common getChipNums];
        }
        if(strongSelf->orders.count>strongSelf->curEditBetCellIndex && strongSelf->orders[strongSelf->curEditBetCellIndex][@"betMoney"]){
            cellBetMoney = [strongSelf->orders[strongSelf->curEditBetCellIndex][@"betMoney"] integerValue];
        }
        textField.text = [NSString stringWithFormat:@"%f", cellBetMoney];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:textField];
        strongSelf->alertTextField = textField;
        [strongSelf->alertTextField becomeFirstResponder];
        strongSelf->curEditBetCellIndex = row;


        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        // confirmBtn.frame = CGRectMake(mainView.frame.size.width/2, 80+30, mainView.frame.size.width/2, 40);
        confirmBtn.frame = CGRectMake(0, 80+30, mainView.frame.size.width, 40);
        [confirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        confirmBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        confirmBtn.layer.borderWidth = 1; //边框的宽度
//        confirmBtn.layer.cornerRadius = 10;
        [confirmBtn addTarget:strongSelf action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
//        confirmBtn.tag = sender.tag;

//        mainView.layer.masksToBounds = YES;
//        mainView.layer.cornerRadius = 10;

//        cancelBtn.bottom =  CGRectGetMaxY(mainView.frame);
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
    
    if([alertTextField.text integerValue] < 1){
        [MBProgressHUD showError:[NSString stringWithFormat:YZMsg(@"LobbyBet_MinMoneyBet%@"),[common name_coin]]];
        return;
    }
    if (orders.count>curEditBetCellIndex) {
        NSMutableDictionary *subDic =  orders[curEditBetCellIndex];
        if (alertTextField.text.length>0) {
            [subDic setObject:alertTextField.text forKey:@"money"];
        }else{
            [subDic setObject:@"" forKey:@"money"];
        }
    }
    //    [ setObject:alertTextField.text forKey:@"betMoney"];
    [self.betCollectionView reloadData];
    //[self refreshBetMoneyLabel];
    [myAlert closeView];

//    UIButton *btn = allChipBtnArray[7];
//    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    [btn setTitle:[NSString stringWithFormat:@"%ld",[common getCustomChipNum]] forState:UIControlStateHighlighted];
//    [btn setTitle:[NSString stringWithFormat:@"%ld",[common getCustomChipNum]] forState:UIControlStateNormal];
//    [btn setTitle:[NSString stringWithFormat:@"%ld",[common getCustomChipNum]] forState:UIControlStateSelected];
////    btn.titleLabel.text = [NSString stringWithFormat:@"%d",[common getCustomChipNum]];
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
    self.view.width = _window_width;
    [self.emptyBtn setTitle:YZMsg(@"LobbyBet_ClearAll") forState:UIControlStateNormal];
    self.betConfirmtitleLabel.text = YZMsg(@"LobbyBet_betContent");
    [self.betScale1Btn setTitle:YZMsg(@"BetCell_double1") forState:UIControlStateNormal];
    self.betScale1Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betScale1Btn.titleLabel.minimumScaleFactor = 0.5;
    [self.betScale2Btn setTitle:YZMsg(@"BetCell_double2") forState:UIControlStateNormal];
    self.betScale2Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betScale2Btn.titleLabel.minimumScaleFactor = 0.5;
    [self.betScale5Btn setTitle:YZMsg(@"BetCell_double5") forState:UIControlStateNormal];
    self.betScale5Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betScale5Btn.titleLabel.minimumScaleFactor = 0.5;
    [self.betScale10Btn setTitle:YZMsg(@"BetCell_double10") forState:UIControlStateNormal];
    self.betScale10Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betScale10Btn.titleLabel.minimumScaleFactor = 0.5;
    [self.betScale20Btn setTitle:YZMsg(@"BetCell_double20") forState:UIControlStateNormal];
    self.betScale20Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betScale20Btn.titleLabel.minimumScaleFactor = 0.5;
    
    
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
