#import "LobbyLotteryVC.h"
#import "CommonTableViewController.h"
#import "BetViewInfoModel.h"
#import "MJExtension.h"
/* 动画倒计时 */
#import "HSFTimeDownView.h"
#import "HSFTimeDownConfig.h"
// 开奖结果Collection
#import "IssueCollectionViewCell2.h"
#import "OptionModel.h"
#import "LobbyBetConfirmViewController.h"
#import "LobbyOpenHistoryViewController.h"
#import "PayViewController.h"
#import "popWebH5.h"
#import "UUMarqueeView.h"
#import "OpenNNHistory1Cell.h"
#import "UIImageView+WebCache.h"
#import "LobbyHistoryAlertController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

#define kIssueCollectionViewCell @"IssueCollectionViewCell2"
#define LotteryCartViewHeight (50 + ShowDiff)
#define BetViewHeight 95
#define BottomViewHeight (ShowDiff+40)

@interface LobbyLotteryVC ()<UITextFieldDelegate,UUMarqueeViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSDictionary *allData;
    NSArray *ways;   // 投注选项
    BOOL isExit;
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSString *curIssue; // 当前期号
    NSMutableArray *waysBtn;   // 投注分类按钮
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *last_open_result; // 上一期开奖结果
    LotteryNNModel *nnModel;
    // 筹码
    NSMutableArray *allChipBtnArray;
    NSMutableArray *allChipNumArray;
    // UI是否创建
    BOOL bCreatedUI;
    // 投注视图
    CommonTableViewController * betOptionsViewController;
    // 键盘高度
    CGFloat _keyBoardHeight;
    // 底部view显示类型 0 隐藏 1下注 2注单
    NSInteger bottomShowType;
    // 已选中的投注项
    NSArray *selectedOptions;
    // 注单列表界面
    LobbyBetConfirmViewController *betConfirmVC;
    // 倒计时
    HSFTimeDownView *timeLabel_hsf;
    // 倍投倍率
    NSInteger betScale;
    // 跑马灯数据源
    NSMutableArray *marqueueArr;
    // 当前跑马灯index
    NSInteger marqueueIndex;
    
    NSArray *winEmojiArr;
    NSArray *betEmojiArr;
    SocketManager *LobbySocketManager;
}
@property (nonatomic, strong) BetViewInfoModel *betViewModel;
@property (nonatomic, strong) UUMarqueeView *upwardMultiMarqueeView;
@property (nonatomic, strong) NSArray *upwardMultiMarqueeViewData;
@property (weak, nonatomic) IBOutlet UILabel *lotteryCardTotalLabel;

//@property (nonatomic, strong) NSDictionary *allData;

@end

@implementation LobbyLotteryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self cacheGameList];
    // Test
    //curLotteryType = 14;
//    [self.serviceBtn setTitle:YZMsg(@"客服") forState:UIControlStateNormal];
    bottomShowType = 0; // 默认底部视图隐藏
    betScale = 1;
    [common saveLotteryBetCart:@[]];
    [self.lotteryHelpBtn setTitle:YZMsg(@"LobbyLotteryVC_betExplain") forState:UIControlStateNormal];
    
    winEmojiArr = @[@"🤩", @"🥳", @"😎", @"😍"];
    betEmojiArr = @[@"🧐", @"🤔", @"☺️", @"😉"];
    
    
    [self.bottomMoreBtn setTitle:YZMsg(@"LobbyLotteryVC_moreBtn") forState:UIControlStateNormal];
    [self.emptySelectedBtn setTitle:YZMsg(@"LobbyBet_ClearAll") forState:UIControlStateNormal];
    [self.deviceRandomBtn setTitle:YZMsg(@"LobbyLotteryVC_deviceRandomBtn") forState:UIControlStateNormal];
    [self.betHistoryBtn setTitle:YZMsg(@"LobbyLotteryVC_BetRecord") forState:UIControlStateNormal];
    [self.chip7Btn setTitle:YZMsg(@"LobbyLotteryVC_betAll") forState:UIControlStateNormal];
    self.chip7Btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.chip7Btn.titleLabel.minimumScaleFactor = 0.7;
    [self.chipMinBtn setTitle:YZMsg(@"LobbyLotteryVC_betMin") forState:UIControlStateNormal];
    
    [self.betBtn setTitle:YZMsg(@"LobbyLotteryVC_Bet") forState:UIControlStateNormal];
    
    [self.addToLotteryCartBtn setTitle:YZMsg(@"LobbyLotteryVC_BetAddChoise") forState:UIControlStateNormal];
    self.addToLotteryCartBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.addToLotteryCartBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.betCancelBtn setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
    self.betCancelBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betCancelBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.totalBetBtn setTitle:YZMsg(@"LobbyLotteryVC_GoToBet") forState:UIControlStateNormal];
    self.lotteryCardTotalLabel.text = YZMsg(@"LobbyLotteryVC_total");
    
    if (self.lotteryNameStr) {
        self.viewTitleLabel.text = self.lotteryNameStr;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    if(!bCreatedUI){
        __weak LobbyLotteryVC *weakSelf = self;
        [self.lotteryCartView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view.mas_bottom).offset(150);
            make.width.equalTo(weakSelf.view.mas_width);
            make.height.mas_equalTo(LotteryCartViewHeight);
        }];
        [self.betView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view.mas_bottom).offset(150);
            make.width.equalTo(weakSelf.view.mas_width);
            make.height.mas_equalTo(BetViewHeight);
        }];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view.mas_bottom).offset(0);
            make.width.equalTo(weakSelf.view.mas_width);
            make.height.mas_equalTo(BottomViewHeight);
        }];
        self.openResultCollection.hidden = YES;
        
        // 顶部按钮
        // 返回
        [self.backBtn addTarget:self action:@selector(doBackVC) forControlEvents:UIControlEventTouchUpInside];
        [self.lotteryHelpBtn addTarget:self action:@selector(doShowLotteryHelp) forControlEvents:UIControlEventTouchUpInside];
        
        // 客服
//        [self.serviceBtn addTarget:self action:@selector(doChatService) forControlEvents:UIControlEventTouchUpInside];
    }
   
    [self buildData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HomeLottery_didSelected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangedLotteryBetCart" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangedLotteryBetScale" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    if(timeLabel_hsf){
        [timeLabel_hsf invaliTimer];
    }
    
}

- (void)dealloc
{
//    [self socketStop];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [self.view bringSubviewToFront:self.lotterInfoView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HomeLottery_didSelected) name:@"HomeLottery_didSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangedLotteryBetCart) name:@"ChangedLotteryBetCart" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangedLotteryBetScale:) name:@"ChangedLotteryBetScale" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CancelMachineSelection) name:@"CancelMachineSelection" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFeildChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
}

- (void)doShowHistory{
    LobbyOpenHistoryViewController *vc = [[LobbyOpenHistoryViewController alloc] initWithNibName:@"LobbyOpenHistoryViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [vc setLotteryType:curLotteryType];
    
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
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
           
            if(strongSelf.betViewModel.logo!= nil && strongSelf.betViewModel.logo.length>0){
                [strongSelf.gameImgeView sd_setImageWithURL:[NSURL URLWithString:strongSelf.betViewModel.logo] placeholderImage:[ImageBundle imagewithBundleName:@"tempShop2"]];
            }
            
            if (strongSelf->curLotteryType == 10) {
                strongSelf->nnModel = [LotteryNNModel mj_objectWithKeyValues:[info firstObject]];
            }
            
            LiveUser *user = [Config myProfile];
            user.coin = minstr(strongSelf.betViewModel.left_coin);
            [Config updateProfile:user];
            
            
            
            strongSelf->last_open_result = strongSelf.betViewModel.lastResult.open_result;
            
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
            });
//            NSString *curNum = [strongSelf.betViewModel.issue substringFromIndex:strongSelf.betViewModel.issue.length-1];
//            NSString *lastNum = [strongSelf.betViewModel.lastResult.issue substringFromIndex:strongSelf.betViewModel.lastResult.issue.length-1];
//            if ((curNum.intValue - lastNum.intValue) >=3) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    if (strongSelf!=nil) {
//                        [strongSelf buildData];
//                    }
//                });
//                return;
//            }
            if(strongSelf.betViewModel.issue != lastIssue && lastIssue.length > 0){
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@", YZMsg(@"LobbyLotteryVC_UpdateDate"),strongSelf.betViewModel.issue]];
            }
        }
        else{
            if(msg && msg.length > 0){
                [MBProgressHUD showError:msg];
            }else{
//                [MBProgressHUD showError:[NSString stringWithFormat:@"%@(%d)", YZMsg(@"public_networkError"), code]];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        //[MBProgressHUD showError:@"获取数据失败"];0-0
        /*
        UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"LobbyLotteryVC_UpdateError") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:suerA];
        
        UIAlertAction *suerB = [UIAlertAction actionWithTitle:YZMsg(@"public_retryAgain") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf buildData];
        }];
        [alertC addAction:suerB];
        if (currentVC.presentedViewController == nil) {
            [currentVC presentViewController:alertC animated:YES completion:nil];
        }
        */
    }];
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
//    if(textField == self.transferNameTextField){
//        [common saveTransferName:self.transferNameTextField.text];
//    }
}

-(void)textFeildChange {
    [self shootChip:[self.customAmountTextField.text integerValue] showhand:false];
    [self refreshBetDesc];
//    if( ![self.transferNameTextField.text isEqualToString:lastNameString] ){
//        lastNameString = self.transferNameTextField.text;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_TextFieldChange" object:nil userInfo:@{@"name" : self.transferNameTextField.text}];
//    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)refreshUI{
    //    if(!ways){
    //        ways = [NSMutableDictionary dictionary];
    //    }
    ways = self.betViewModel.ways;
    if(!bCreatedUI){
        [self initUI];
//        [self addNodeListen];
        self.openResultCollection.hidden = NO;
        //[self.leftTablew reloadData];
    }else{
        [self.openResultCollection reloadData];
        self.openResultCollection.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeOpenAward_Changed" object:nil userInfo:nil];
    }
    
    [self refreshBottomSpace];
    self.viewTitleLabel.text = self.betViewModel.name;
    
    NSMutableAttributedString *attCurl = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:YZMsg(@"LobbyLotteryVC_DateBetingNow%@"), self.betViewModel.issue]];
    [attCurl addAttribute:NSForegroundColorAttributeName value:RGB(255, 0, 0) range:NSMakeRange(0, attCurl.string.length)];
    if (YZMsg(@"LobbyLotteryVC_DateBetingNow1").length>0) {
        [attCurl addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([attCurl.string rangeOfString:YZMsg(@"LobbyLotteryVC_DateBetingNow1")].location, YZMsg(@"LobbyLotteryVC_DateBetingNow1").length)];
    }
    if (YZMsg(@"LobbyLotteryVC_DateBetingNow2").length>0) {
        [attCurl addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([attCurl.string rangeOfString:YZMsg(@"LobbyLotteryVC_DateBetingNow2")].location, YZMsg(@"LobbyLotteryVC_DateBetingNow2").length)];
    }
    
    self.curIssueLabel.attributedText = attCurl;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:YZMsg(@"LobbyLotteryVC_DateNow%@"), self.betViewModel.lastResult.issue]];
    [att addAttribute:NSForegroundColorAttributeName value:RGB(255, 0, 0) range:NSMakeRange(0, att.string.length)];
    if (YZMsg(@"LobbyLotteryVC_DateNow1").length>0) {
        [att addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([att.string rangeOfString:YZMsg(@"LobbyLotteryVC_DateNow1")].location, YZMsg(@"LobbyLotteryVC_DateNow1").length)];
    }
    if (YZMsg(@"LobbyLotteryVC_DateNow2").length>0) {
        [att addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([att.string rangeOfString:YZMsg(@"LobbyLotteryVC_DateNow2")].location, YZMsg(@"LobbyLotteryVC_DateNow2").length)];
    }
    
    self.lastIssueLabel.attributedText = att;
    [self refreshLeftCoin];
    
    if(timeLabel_hsf){
        timeLabel_hsf.visible = YES;
        [timeLabel_hsf refreshNumber:((self.betViewModel.time - [self.betViewModel.sealingTim integerValue]))];
//        self.lotteryStatusLabel.hidden = YES;
    }

    // 更新倒计时时间
    //betLeftTime = [allData[@"time"] integerValue];
    //sealingTime = [allData[@"sealingTim"] integerValue];
    //curIssue = allData[@"issue"];
    //if(betLeftTime > sealingTime){
    //    self.leftTimeTitleLabel.text = @"本期截止:";
    //    self.leftTimeLabel.text = [YBToolClass timeFormatted:(betLeftTime - sealingTime)];
    //}else{
    //    self.leftTimeTitleLabel.text = [NSString stringWithFormat:@"已封盘(%ld)", sealingTime - (sealingTime - betLeftTime)];
    //    self.leftTimeLabel.text = @"";
    //}
    //
    //// 更新余额
    //[self refreshLeftCoinLabel];
    //
    ////更新下注筹码
    //[self refreshCurrentChip];
    
}

-(void) refreshLeftCoin{
    self.leftCoinLabel.text = minfloat([self.betViewModel.left_coin integerValue] / 10.0);
}

-(void) refreshBetDesc{
    NSString *betCount = [NSString stringWithFormat:@"%ld", (long)selectedOptions.count];
    double chipValue = [common getChipNums];
    NSString *money = [NSString stringWithFormat:@"%f", (long)(chipValue * selectedOptions.count)];
    
    CGFloat minValue = 9999.0;
    CGFloat maxValue = 0.0;
    for (int i = 0; i < selectedOptions.count; i ++) {
        OptionModel *optionDict = selectedOptions[i];
        NSArray *value_splite = [optionDict.value componentsSeparatedByString:@"/"];
        if(value_splite.count>1&& value_splite[1]){
            // 六合彩连码单独处理
            CGFloat optionValue1 = [value_splite[0] floatValue];
            CGFloat optionValue2 = [value_splite[1] floatValue];
            if(minValue > optionValue1){
                minValue = optionValue1;
            }
            if(minValue > optionValue2){
                minValue = optionValue2;
            }
            if(maxValue < optionValue1){
                maxValue = optionValue1;
            }
            if(maxValue < optionValue2){
                maxValue = optionValue2;
            }
        }else{
            CGFloat optionValue = [optionDict.value floatValue];
            if(minValue > optionValue){
                minValue = optionValue;
            }
            if(maxValue < optionValue){
                maxValue = optionValue;
            }
        }
    }
    NSString *minPlanProfit = [NSString stringWithFormat:@"%.1f", minValue * chipValue];
    NSString *maxPlanProfit = [NSString stringWithFormat:@"%.1f", maxValue * chipValue];
    
    NSMutableAttributedString *att;
    if(minPlanProfit == maxPlanProfit){
        att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:YZMsg(@"LobbyLotteryVC_selectedCount%@_total%@%@_profit%@%@"), betCount, money,[common name_coin], minPlanProfit,[common name_coin]]];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length, betCount.length)];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length + betCount.length + YZMsg(@"LobbyLotteryVC_selectedCount2").length, money.length)];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length + betCount.length + YZMsg(@"LobbyLotteryVC_selectedCount2").length + money.length + [NSString stringWithFormat:YZMsg(@"LobbyLotteryVC_selectedCount3%@"),[common name_coin]].length, minPlanProfit.length)];
    }else{
        att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:YZMsg(@"LobbyLotteryVC2_selectedCount%@_total%@%@_profit1%@_profit2%@%@"), betCount, money, [common name_coin],minPlanProfit, maxPlanProfit,[common name_coin]]];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length, betCount.length)];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length + betCount.length + YZMsg(@"LobbyLotteryVC_selectedCount2").length, money.length)];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length + betCount.length + YZMsg(@"LobbyLotteryVC_selectedCount2").length + money.length + [NSString stringWithFormat:YZMsg(@"LobbyLotteryVC_selectedCount3%@"),[common name_coin]].length, minPlanProfit.length)];
        [att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#bf3c34", 1) range:NSMakeRange(YZMsg(@"LobbyLotteryVC_selectedCount1").length + betCount.length + YZMsg(@"LobbyLotteryVC_selectedCount2").length + money.length + [NSString stringWithFormat:YZMsg(@"LobbyLotteryVC_selectedCount3%@"),[common name_coin]].length + minPlanProfit.length + @"~".length, maxPlanProfit.length)];
    }
    
    [self.betDesc setAttributedText:att];
    self.betDesc.adjustsFontSizeToFitWidth = YES;
    self.betDesc.minimumScaleFactor = 0.5;
    
    //self.betDesc.text = [NSString stringWithFormat:@"已选%ld注，共计%ld元，预期可获%ld元",(long)0, (long)0, (long)0];
}

-(void) refreshBottomCart{
    // 更新注单数量
    WeakSelf;
    NSArray *betCart = [common getLotteryBetCart];
    self.totalBetCount.text = [NSString stringWithFormat:@"%ld", (long)betCart.count];
    if(betCart.count == 0){
        // 设置注单图标
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager loadImageWithURL:[NSURL URLWithString:minstr(self.betViewModel.logo)]
                          options:1
                         progress:nil
                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            STRONGSELF
                            if (image && strongSelf !=nil) {
                                
                                [strongSelf.lotteryLogo setImage:[strongSelf grayImage:image]];
                            }
                        }];
       
        self.totalBetBtn.backgroundColor = RGB_COLOR(@"#67686d", 1);
    }else{
        // 设置注单图标
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager loadImageWithURL:[NSURL URLWithString:minstr(self.betViewModel.logo)]
                          options:1
                         progress:nil
                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            STRONGSELF
                            if (image && strongSelf !=nil) {
                                
                                [strongSelf.lotteryLogo setImage:[strongSelf grayImage:image]];
                            }
        }];
        self.totalBetBtn.backgroundColor = RGB_COLOR(@"#c13931", 1);
    }
    self.lotteryLogo.userInteractionEnabled = false;
    
    NSInteger totalMoney = 0;
    CGFloat forecastProfit = 0;
    NSInteger maxCount = betCart.count;
    for (int i = 0; i < maxCount; i ++) {
        NSDictionary *dict = betCart[i];
        totalMoney += [dict[@"money"] integerValue];
        forecastProfit += [dict[@"money"] integerValue] * [dict[@"value"] floatValue];
    }
    // 注单总金额
    self.totalMoney.text = [NSString stringWithFormat:@"¥%ld", (long)totalMoney * betScale];
    // 注单预期收益
    self.totalPlanProfit.text = [NSString stringWithFormat:YZMsg(@"LobbyLotteryVC3_selectedCount%ld_scale%ld_profit%.1f%@"), (long)maxCount, (long)betScale, forecastProfit * betScale,[common name_coin]];
    self.totalPlanProfit.numberOfLines = 0;
    
    [self.totalBetBtn setEnabled:maxCount > 0];
}

-(UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

//-(void)addNodeListen{
//    _lobbySocketServerUrl = self.betViewModel.lobbyServer;
//    NSURL* url = [[NSURL alloc] initWithString:_lobbySocketServerUrl];
//    LobbySocketManager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @NO,@"forcePolling":@YES,@"reconnectWait":@1,@"reconnects":@YES,@"forceWebsockets":@YES,@"compress":@(YES)}];
//    _LobbySocket = [LobbySocketManager defaultSocket];
//
////    _LobbySocket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO,@"forcePolling":@YES,@"reconnectWait":@1,@"reconnects":@YES}];
//    [_LobbySocket connect];
//    NSArray *cur = @[@{@"username":[Config getOwnNicename],
//                       @"uid":[Config getOwnID],
//                       @"token":[Config getOwnToken],
//                       @"roomnum":@"lobby",
//                       @"stream":@"",
//                       }];
//    WeakSelf
//    [_LobbySocket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        [strongSelf.LobbySocket emit:@"conn" with:cur];
//    }];
//    [_LobbySocket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        NSLog(@"socket.io disconnect---%@",data);
//    }];
//    [_LobbySocket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        NSLog(@"socket.io error -- %@",data);
//        if(data && ([minstr(data[0]) isEqualToString:@"Tried emitting broadcast when not connected"] || [minstr(data[0]) isEqualToString:@"Session ID unknown"])){
//            if(strongSelf.lastReconnectDate){
//                // 等待几秒钟后再重连
//                NSInteger timeDistance = [[NSDate date] timeIntervalSinceDate:strongSelf.lastReconnectDate];
//                if(timeDistance > 8){
//                    [strongSelf socketStop];
//                    [strongSelf addNodeListen];
//                }
//            }else{
//                [strongSelf socketStop];
//                [strongSelf addNodeListen];
//                strongSelf.lastReconnectDate = [NSDate date];
//            }
//        }
//    }];
//    [_LobbySocket on:@"conn" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        NSLog(@"socket 进入房间");
//    }];
//    [_LobbySocket on:@"broadcastingListen" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        STRONGSELF
//        if (strongSelf == nil) {
//            return;
//        }
//        for (NSString *path in data[0]) {
//            NSDictionary *jsonArray = [path JSONValue];
//            NSDictionary *msg = [[jsonArray valueForKey:@"msg"] firstObject];
//            //NSString *retcode = [NSString stringWithFormat:@"%@",[jsonArray valueForKey:@"retcode"]];
//
//            NSString *method = [msg valueForKey:@"_method_"];
//            [strongSelf getmessage:msg andMethod:method];
//        }
//    }];
//}
//
////注销socket
//-(void)socketStop{
//    if(_LobbySocket){
//        [_LobbySocket disconnect];
//        [_LobbySocket off:@""];
//        [_LobbySocket leaveNamespace];
//        _LobbySocket = nil;
//    }
//}
//
//-(void)getmessage:(NSDictionary *)msg andMethod:(NSString *)method{
//    // 货币更新
//    if ([method isEqual:@"moneyChange"]){
//        if([msg valueForKey:@"money"]){
//            _betViewModel.left_coin = [msg valueForKey:@"money"];
//            [self refreshLeftCoin];
//        }
//    }
//    // 同步彩票信息
//    else if ([method isEqual:@"LotterySync"]){
//        if([msg valueForKey:@"lotteryInfo"]){
//            // [self.socketDelegate setLotteryInfo:msg];
//        }
//    }
//    // 开奖
//    else if ([method isEqual:@"LotteryOpenAward"]){
//        //[[NSNotificationCenter defaultCenter] postNotificationName:@"LotteryOpenAward" object:nil userInfo:msg];
//        //[self.socketDelegate addOpenAward:msg];
//        if([msg valueForKey:@"result"] && [minstr(msg[@"lotteryType"]) isEqualToString:self.betViewModel.lotteryType]){
//            self.betViewModel.lastResult.open_result = msg[@"result"];
//            self.betViewModel.lastResult.issue = minstr(msg[@"issue"]);
//            last_open_result = self.betViewModel.lastResult.open_result;
//
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@期已开奖", self.betViewModel.lastResult.issue]];
//            self.lastIssueLabel.text = self.betViewModel.lastResult.issue;
//            if(self.openResultCollection){
//                [self.openResultCollection reloadData];
//                self.openResultCollection.hidden = NO;
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeOpenAward_Changed" object:nil userInfo:nil];
//            }
//        }
//    }
//    // 跑马灯
//    else if ([method isEqual:@"MarqueueSync"]){
//        if([msg valueForKey:@"marqueueList"]){
//            NSArray *marqueueList = [msg valueForKey:@"marqueueList"];
//            NSInteger maxCount = marqueueList.count;
//            NSMutableArray *sourceArray = [NSMutableArray array];
//            for (int i = 0; i < maxCount; i ++) {
//                NSString *data_obj = marqueueList[i];
//                NSArray *jsonArray = [data_obj JSONValue][@"msg"];
//                NSDictionary *jsonDict = [jsonArray firstObject];
//
//                NSString *marqueueStr = jsonDict[@"ct"];
//                if([marqueueStr containsString:@"下注了"]){
//                    int idx = arc4random() % [betEmojiArr count];
//                    marqueueStr = [NSString stringWithFormat:@"%@%@", betEmojiArr[idx], jsonDict[@"ct"]];
//                }else if([marqueueStr containsString:@"中奖了"]){
//                    int idx = arc4random() % [winEmojiArr count];
//                    marqueueStr = [NSString stringWithFormat:@"%@%@", winEmojiArr[idx], jsonDict[@"ct"]];
//                }else{
//                    marqueueStr = [NSString stringWithFormat:@"%@", jsonDict[@"ct"]];
//                }
//
//                NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithData:[marqueueStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//
//                [sourceArray addObject:@{@"content":contentString, @"time":jsonDict[@"tm"]}];
//            }
//            marqueueArr = sourceArray;
//            _upwardMultiMarqueeViewData = marqueueArr;
//        }
//    }
//    // 中奖广播
//    else if ([method isEqual:@"LotteryProfit"]){
////        NSString *tmStr = [YBToolClass timeFormattedAge:[msg[@"tm"] integerValue]];
//
//        NSString *marqueueStr = msg[@"ct"];
//        if([marqueueStr containsString:@"下注了"]){
//            int idx = arc4random() % [betEmojiArr count];
//            marqueueStr = [NSString stringWithFormat:@"%@%@", betEmojiArr[idx], msg[@"ct"]];
//        }else if([marqueueStr containsString:@"中奖了"]){
//            int idx = arc4random() % [winEmojiArr count];
//            marqueueStr = [NSString stringWithFormat:@"%@%@", winEmojiArr[idx], msg[@"ct"]];
//        }else{
//            marqueueStr = [NSString stringWithFormat:@"%@", msg[@"ct"]];
//        }
//
//        NSAttributedString * contentString = [[NSAttributedString alloc] initWithData:[marqueueStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        if (!marqueueArr) {
//            marqueueArr = [NSMutableArray array];
//        }
//        [marqueueArr addObject:@{@"content":contentString, @"time":msg[@"tm"]}];
//        if(marqueueArr.count > 30)
//        {
//            [marqueueArr removeObjectAtIndex:0];
//        }
//    }
//    // 分红广播
//    else if ([method isEqual:@"LotteryDividend"]){
//        //[self.socketDelegate setLotteryDividendNot:msg];
//    }
//    // 投注广播
//    else if ([method isEqual:@"LotteryBet"]){
////        NSString *tmStr = [YBToolClass timeFormattedAge:[msg[@"tm"] integerValue]];
//
//        NSString *marqueueStr = msg[@"ct"];
//        if([marqueueStr containsString:@"下注了"]){
//            int idx = arc4random() % [betEmojiArr count];
//            marqueueStr = [NSString stringWithFormat:@"%@%@", betEmojiArr[idx], msg[@"ct"]];
//        }else if([marqueueStr containsString:@"中奖了"]){
//            int idx = arc4random() % [winEmojiArr count];
//            marqueueStr = [NSString stringWithFormat:@"%@%@", winEmojiArr[idx], msg[@"ct"]];
//        }else{
//            marqueueStr = [NSString stringWithFormat:@"%@", msg[@"ct"]];
//        }
//        NSAttributedString * contentString = [[NSAttributedString alloc] initWithData:[marqueueStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        if (!marqueueArr) {
//            marqueueArr = [NSMutableArray array];
//        }
//        [marqueueArr addObject:@{@"content":contentString, @"time":msg[@"tm"]}];
//        if(marqueueArr.count > 30)
//        {
//            [marqueueArr removeObjectAtIndex:0];
//        }
//        //[self.socketDelegate setLotteryBetNot:msg];
//    }
//    //断开链接
//    else if([method isEqual:@"disconnect"])
//    {
//        //[self.socketDelegate UserDisconnect:msg];
//    }
//}

-(void)initUI{
    bCreatedUI = true;
    [self initCollection];
    betOptionsViewController = [[CommonTableViewController alloc] initWithNibName:@"CommonTableViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [betOptionsViewController setLotteryType:curLotteryType];
    [betOptionsViewController setLotteryWays:ways];
    [self.view addSubview:betOptionsViewController.view];
    [self addChildViewController:betOptionsViewController];
    
    // 调整层级
    [self.view bringSubviewToFront:self.navBar];
    [self.view bringSubviewToFront:self.lotterInfoView];
    [self.view bringSubviewToFront:self.betView];
    [self.view bringSubviewToFront:self.bottomView];
    [self.view bringSubviewToFront:self.lotteryCartView];
    
    // 调整位置
    [self.lotteryCartView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(150);
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(LotteryCartViewHeight);
    }];
    [self.betView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(150);
        make.width.equalTo(self.view.mas_width);
    }];
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(BottomViewHeight);
    }];
    
    // 上期开奖区域
   
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doShowHistory)];
    tapGestureRecognizer1.cancelsTouchesInView = YES;
    [self.lotterInfoView addGestureRecognizer:tapGestureRecognizer1];
    
    // 充值区域
    UITapGestureRecognizer *chargeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doCharge)];
    chargeTapGestureRecognizer.cancelsTouchesInView = NO;
    [self.chargeView addGestureRecognizer:chargeTapGestureRecognizer];
    
    // 注单界面
    // 注单下注按钮
    [self.totalBetBtn addTarget:self action:@selector(doTotalBet) forControlEvents:UIControlEventTouchUpInside];
    // 注单列表
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doShowBetOptions)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.ballBgView addGestureRecognizer:tapGestureRecognizer];
    
    // 投注界面
    allChipNumArray = [NSMutableArray arrayWithArray:@[
        @10,
        @50,
        @100,
        @500,
        @1000,
        @2000,
    ]];
    allChipBtnArray = [NSMutableArray arrayWithArray:@[self.chip1Btn, self.chip2Btn, self.chip3Btn, self.chip4Btn, self.chip5Btn, self.chip6Btn, self.chip7Btn, self.chipMinBtn]];
    for (int i = 0; i < allChipBtnArray.count; i++) {
        UIButton *btn = [allChipBtnArray objectAtIndex:i];
        btn.titleLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        btn.titleLabel.layer.shadowRadius = 1;
        btn.titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
        btn.titleLabel.layer.shadowOpacity = 0.4;
        if(i < 6){
            // 前6个固定注额
            NSInteger chipValue = [allChipNumArray[i] integerValue];
            if(chipValue >= 10000){
                [btn setTitle:[NSString stringWithFormat:@"%.0fW", floor(chipValue / 10000)] forState:UIControlStateNormal];
            }else if(chipValue >= 1000){
                [btn setTitle:[NSString stringWithFormat:@"%.0fK", floor(chipValue / 1000)] forState:UIControlStateNormal];
            }else{
                [btn setTitle:[NSString stringWithFormat:@"%ld", chipValue] forState:UIControlStateNormal];
            }
            btn.tag = i;
            [btn addTarget:self action:@selector(doSelectChip:) forControlEvents:UIControlEventTouchUpInside];
        }else if(i == 6){
            // 梭哈
            [btn addTarget:self action:@selector(doSelectShowHand) forControlEvents:UIControlEventTouchUpInside];
        }else if(i == 7){
            // 最小投注
            [btn addTarget:self action:@selector(doSelectMinBet) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    // 下注
    [self.betBtn addTarget:self action:@selector(doBet) forControlEvents:UIControlEventTouchUpInside];
    // 加入注单
    [self.addToLotteryCartBtn addTarget:self action:@selector(doAdd2LotteryCart) forControlEvents:UIControlEventTouchUpInside];
    // 取消
    [self.betCancelBtn addTarget:self action:@selector(doBetCancel) forControlEvents:UIControlEventTouchUpInside];
    
    // 默认下注金额
    self.customAmountTextField.text = [NSString stringWithFormat:@"%ld", (long)[common getChipNums]];
    [self shootChip:[self.customAmountTextField.text integerValue] showhand:false];
    
    // 倒计时
    
    HSFTimeDownConfig *config = [[HSFTimeDownConfig alloc]init];
    config.timeType = HSFTimeType_HOUR_MINUTE_SECOND;
    config.bgColor = [UIColor whiteColor];
    config.fontColor = RGB_COLOR(@"#0600FF", 1);
    config.fontSize = 18.f;
    //    config.fontColor_placeholder = [UIColor orangeColor];
    //    config.fontSize_placeholder = 10.f;
    WeakSelf
    timeLabel_hsf = [[HSFTimeDownView alloc] initWityFrame:CGRectMake(0, 0, self.countdownView.frame.size.width, self.countdownView.frame.size.height) config:config timeChange:^(NSInteger time) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"hsf===%ld",(long)time);
        if(!strongSelf->timeLabel_hsf.visible){
            strongSelf.lotteryStatusLabel.hidden = NO;
            weakSelf.lotteryStatusLabel.text = [NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), time];
            weakSelf.lotteryStatusLabel.adjustsFontSizeToFitWidth = YES;
            weakSelf.lotteryStatusLabel.minimumScaleFactor = 0.5;
            if (strongSelf.LobbySocket.status != 3 && time == 0) {
//                [strongSelf socketStop];
//                [strongSelf addNodeListen];
                dispatch_main_async_safe(^{
                    [strongSelf refreshUI];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (strongSelf!= nil) {
                        [strongSelf buildData];
                    }
                   
                });
               
            }
        }else{
            weakSelf.lotteryStatusLabel.hidden = YES;
        }
    } timeEnd:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"hsf===倒计时结束");
        if(strongSelf->timeLabel_hsf.visible){
            strongSelf->timeLabel_hsf.visible = false;
            [strongSelf->timeLabel_hsf refreshNumber:[strongSelf.betViewModel.sealingTim integerValue]];
            strongSelf.lotteryStatusLabel.hidden = NO;
            strongSelf.lotteryStatusLabel.text = [NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), (long)5];
            strongSelf.lotteryStatusLabel.adjustsFontSizeToFitWidth = YES;
            strongSelf.lotteryStatusLabel.minimumScaleFactor = 0.5;
        }else{
            strongSelf.lotteryStatusLabel.text = YZMsg(@"LobbyLotteryVC_betOpen");
            if (strongSelf.LobbySocket.status != 3) {
//                [strongSelf socketStop];
//                [strongSelf addNodeListen];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf!= nil) {
                    [strongSelf buildData];
                }
               
            });
           
        }
    }];
 
    [self.countdownView addSubview:timeLabel_hsf];
    [timeLabel_hsf setcurentTime:(self.betViewModel.time - [self.betViewModel.sealingTim integerValue])];
    // 监听按钮事件[更多功能]
    [self.bottomMoreBtn addTarget:self action:@selector(doShowBottomMore) forControlEvents:UIControlEventTouchUpInside];
    // 监听按钮事件[清空]
    [self.emptySelectedBtn addTarget:self action:@selector(doEmptySelcted) forControlEvents:UIControlEventTouchUpInside];
    // 监听按钮事件[机选]
    [self.deviceRandomBtn addTarget:self action:@selector(doDeviceRandom) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceRandomBtn setTitleColor:RGB_COLOR(@"#FE0B78", 1) forState:UIControlStateSelected];
    // 监听按钮事件[历史投注]
    [self.betHistoryBtn addTarget:self action:@selector(doShowBetHistory) forControlEvents:UIControlEventTouchUpInside];
    //// 监听阴影层点击事件
    ////    [self.shadowView addTarget:self action:@selector(exitView) forControlEvents:UIControlEventTouchUpInside];
    
    // 键盘事件
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    keyboardToolbar.barStyle = UIBarStyleDefault;
    keyboardToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:YZMsg(@"public_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelWithKeyBoard)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:YZMsg(@"publictool_sure") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithKeyBoard)]];
    [keyboardToolbar sizeToFit];
    self.customAmountTextField.inputAccessoryView = keyboardToolbar;
    self.customAmountTextField.delegate = self;
    
    // 给自定义投注金额设置默认值
    self.customAmountTextField.text = @"10";
    [self shootChip:[self.customAmountTextField.text integerValue] showhand:false];
    
    // 通知更新最后开奖
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"LotteryOpenAward" object:nil userInfo:@{
//        @"result":self.betViewModel.lastResult.open_result,
//        @"lotteryType":[NSString stringWithFormat:@"%ld", (long)curLotteryType]
//    }];
    
    // 跑马灯
    self.upwardMultiMarqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(10, 0, self.marqueeView.width - 10 - 10, 30)];
    _upwardMultiMarqueeView.delegate = self;
    _upwardMultiMarqueeView.timeIntervalPerScroll = 0.7f;
    _upwardMultiMarqueeView.timeDurationPerScroll = 0.3f;
    _upwardMultiMarqueeView.touchEnabled = NO;
    [self.marqueeView addSubview:_upwardMultiMarqueeView];
    [_upwardMultiMarqueeView reloadData];
    
    if (self.urlName!= nil && self.urlName.length>0) {
        [self.gameImgeView sd_setImageWithURL:[NSURL URLWithString:self.urlName] placeholderImage:[ImageBundle imagewithBundleName:@"tempShop2"]];
    }
   

}

- (void)doShowBottomMore {
    [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_Stay_tuned_for")];
}

- (void)doEmptySelcted {
    self.deviceRandomBtn.selected = NO;
    [betOptionsViewController clearSelectedStatus];
    NSArray *betCart = [common getLotteryBetCart];
    if(betCart.count > 0){
        [self switchLotteryCartView];
    }else{
        [self switchBottomView];
    }
}

- (void)doDeviceRandom {
    self.deviceRandomBtn.selected = YES;
    [betOptionsViewController randomSelected];
}

-(void)doShowBetHistory{
//    popWebH5 *VC = [[popWebH5 alloc]init];
//    VC.titles = YZMsg(@"LobbyLotteryVC_betHistory");
//    NSString *url = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"index.php?g=Appapi&m=BettingRecord&a=index&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
//    // http://localhost:8888/api/public/?service=Lottery.betList&start_time=2020-03-05&end_time=2020-04-05&type=0&page=1&status=0&uid=2456142&token=cb6221b2f11a2e4c05fffec33307d268
//
//    VC.urls = url;
//
//    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
//        [VC doCloseWeb];
//    }];
//    __weak popWebH5 *VCWeak = VC;
//    VC.closeCallback = ^{
//        [shadowView removeFromSuperview];
//        [VCWeak.view removeFromSuperview];
//        [VCWeak removeFromParentViewController];
//    };
//
//    [self.view addSubview:VC.view];
//    [self addChildViewController:VC];
    LobbyHistoryAlertController *history = [[LobbyHistoryAlertController alloc]initWithNibName:@"LobbyHistoryAlertController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    history.view.frame = CGRectMake(0, _window_height, _window_width, _window_height);
    [self.view addSubview:history.view];
    [self addChildViewController:history];
    history.view.frame = CGRectMake(0, 0, _window_width, _window_height);
    [history.view didMoveToSuperview];
    [history didMoveToParentViewController:self];
//    [UIView animateWithDuration:0.5 animations:^{
//    } completion:^(BOOL finished) {
//
//    }];
    
}

- (void)doBackVC {
//    [self socketStop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doChatService {
    [YBToolClass showService];
}

- (void)doShowLotteryHelp {    
    popWebH5 *VC = [[popWebH5 alloc]init];
    VC.titles = YZMsg(@"LobbyLotteryVC_betExplain");
    VC.isBetExplain = YES;
    NSString *url = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"index.php?g=Appapi&m=LotteryArticle&a=index&lotteryType=%@&uid=%@&token=%@",minnum(curLotteryType), [Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    // http://localhost:8888/api/public/?service=Lottery.betList&start_time=2020-03-05&end_time=2020-04-05&type=0&page=1&status=0&uid=2456142&token=cb6221b2f11a2e4c05fffec33307d268
    
    VC.urls = url;
    
    UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
        [VC doCloseWeb];
    }];
    __weak popWebH5 *VCWeak = VC;
    VC.closeCallback = ^{
        [shadowView removeFromSuperview];
        [VCWeak.view removeFromSuperview];
        [VCWeak removeFromParentViewController];
    };
    
    [self.view addSubview:VC.view];
    [self addChildViewController:VC];
}

-(void)doCharge{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
}

-(void)doSelectChip:(UIButton *)sender{
    NSInteger chipValue = [allChipNumArray[sender.tag] integerValue];
    [self shootChip:chipValue showhand:false];
    self.customAmountTextField.text = [NSString stringWithFormat:@"%ld", (long)chipValue];
    [self refreshBetDesc];
    //[MBProgressHUD showError:[NSString stringWithFormat:@"选筹码%d", [allChipNumArray[sender.tag] integerValue]]];
}

-(void)shootChip:(NSInteger)chipValue showhand:(BOOL)showhand{
    NSInteger idx = -1;
    NSInteger maxCount = allChipNumArray.count;
    for (int i = 0; i < maxCount; i++) {
        if([allChipNumArray[i] integerValue] == chipValue){
            idx = i;
            break;
        }
    }
    
    LiveUser *user = [Config myProfile];
    NSInteger userLeftCoin = [user.coin integerValue] / 10;
    if(userLeftCoin == chipValue && showhand){
        idx = 6;
    }
    
    [common saveChipNums:chipValue];
    __block LobbyLotteryVC *weakSelf = self;
    for (int i = 0; i < allChipBtnArray.count; i++) {
        UIButton *btn = [allChipBtnArray objectAtIndex:i];
        if(i < 6){
            if(i == idx){
                [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(weakSelf.chipBgView.mas_centerY).offset(-10);
                }];
                btn.layer.shadowColor = [UIColor colorWithRed:193/255.0 green:57/255.0 blue:49/255.0 alpha:1].CGColor;//[UIColor yellowColor].CGColor;
                btn.layer.shadowOffset = CGSizeMake(0, 0);
                btn.layer.shadowRadius = 4;
                btn.layer.shadowOpacity = 0.7;
            }else{
                [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(weakSelf.chipBgView.mas_centerY).offset(0);
                }];
                btn.layer.shadowOpacity = 0;
            }
        }
        if(i == 6){
            if(idx == 6){
                [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(weakSelf.chipBgView.mas_centerY).offset(-10);
                }];
                btn.layer.shadowColor = [UIColor colorWithRed:193/255.0 green:57/255.0 blue:49/255.0 alpha:1].CGColor;//[UIColor yellowColor].CGColor;
                btn.layer.shadowOffset = CGSizeMake(0, 0);
                btn.layer.shadowRadius = 4;
                btn.layer.shadowOpacity = 0.7;
            }else{
                [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(weakSelf.chipBgView.mas_centerY).offset(0);
                }];
                btn.layer.shadowOpacity = 0;
            }
        }
    }
    [UIView animateWithDuration:0.1 animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}

-(void)doSelectShowHand{
    LiveUser *user = [Config myProfile];
    CGFloat chipValue = [user.coin integerValue] / 10.0;
    if(chipValue < 1){
        UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"LobbyLotteryVC_bet_balance_Error") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:suerA];
        WeakSelf
        UIAlertAction *suerB = [UIAlertAction actionWithTitle:YZMsg(@"PayReq_chargeNow") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf doCharge];
        }];
        [alertC addAction:suerB];
        if (currentVC.presentedViewController == nil) {
            [currentVC presentViewController:alertC animated:YES completion:nil];
        }
        
        return;
    }
    [self shootChip:chipValue showhand:true];
    self.customAmountTextField.text = [NSString stringWithFormat:@"%ld", (long)chipValue];
    [self refreshBetDesc];
}

-(void)doSelectMinBet{
    NSInteger chipValue;
    if(self.betViewModel.min_bet){
        chipValue = [self.betViewModel.min_bet integerValue];
    }else{
        chipValue = 1;
    }
    [self shootChip:chipValue showhand:false];
    self.customAmountTextField.text = [NSString stringWithFormat:@"%ld", (long)chipValue];
    [self refreshBetDesc];
}

static BOOL isBeeting;
-(void)doTotalBet{
    __block LobbyLotteryVC *weakSelf = self;
    if(!timeLabel_hsf.visible){
        // 封盘中
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_bet_endBet")];
//        if (self.LobbySocket.statusValue != 3) {
//            [self socketStop];
//            [self addNodeListen];
//            dispatch_main_async_safe(^{
//                [self refreshUI];
//            });
//        }
        return;
    }
    
    NSArray *betCart = [common getLotteryBetCart];
    if(betCart.count == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_betEmptySelecte")];
        return;
    }
    
    CGFloat totalMoney = 0;
    for (int i = 0; i < betCart.count; i ++) {
        NSDictionary *optionDict = betCart[i];
        //CGFloat optionValue = [optionDict.value floatValue];
//        NSString *title = optionDict[@"title"];
        NSInteger _money = [optionDict[@"money"] integerValue] * betScale;
        totalMoney += _money;
    }
    
    if([self.betViewModel.left_coin integerValue] / 10.0 < totalMoney){
        UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"LobbyLotteryVC_NoBalance") message:YZMsg(@"LobbyLotteryVC_NoBalanceDetailDes") preferredStyle:UIAlertControllerStyleAlert];
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
    
    NSString *way = @"[";
    NSString *money = @"[";

    for (int i = 0; i < betCart.count; i ++) {
        NSDictionary *optionDict = betCart[i];
        //CGFloat optionValue = [optionDict.value floatValue];
        NSString *title = optionDict[@"title"];
        NSInteger _money = [optionDict[@"money"] integerValue] * betScale;
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
    NSString *optionName = YZMsg(@"LobbyLotteryVC_titleBet");
    NSString *liveuidstr = @"0";
    
    NSInteger liveuid = [GlobalDate getLiveUID];
    liveuidstr = [NSString stringWithFormat:@"%ld", (long)liveuid];
    
    if (isBeeting) {
        return;
    }
    isBeeting = YES;
    NSString *betIdStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
   
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting&uid=%@&token=%@&lottery_type=%@&money=%@&way=%@&serTime=%@&issue=%@&optionName=%@&liveuid=%@&betid=%@",[Config getOwnID],[Config getOwnToken],lottery_type,money,way,minnum([[NSDate date] timeIntervalSince1970]),issue,optionName,liveuidstr,betIdStr];//User.getPlats
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:15];
    [[YBNetworking sharedManager] postNetworkWithUrl:betUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        isBeeting = NO;
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            NSDictionary *dict = info;
            
            LiveUser *user = [Config myProfile];
            user.coin = minstr(dict[@"left_coin"]);
            [Config updateProfile:user];
            strongSelf.betViewModel.left_coin = user.coin;
            [strongSelf refreshLeftCoin];
            
            [MBProgressHUD showError:msg];
            // 清空信息
            [common saveLotteryBetCart:@[]];
            strongSelf->betScale = 1;
            [strongSelf refreshBottomCart];
            //[self doBetCancel];
            [strongSelf displayLotteryCartView:NO];
            [strongSelf displayBetView:YES];
            if (strongSelf->betConfirmVC) {
                [strongSelf->betConfirmVC.view removeFromSuperview];
                [strongSelf->betConfirmVC removeFromParentViewController];
                strongSelf->betConfirmVC = nil;
            }
        }
        else{
            [MBProgressHUD showError:msg];
        }
       
    } fail:^(NSError * _Nonnull error) {
        isBeeting = NO;
        // 请求失败
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
    }];
}

-(void)doBet{
    __block LobbyLotteryVC *weakSelf = self;
    if(!timeLabel_hsf.visible){
        // 封盘中
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_bet_endBet")];
//        if (self.LobbySocket.statusValue != 3) {
//            [self socketStop];
//            [self addNodeListen];
//            dispatch_main_async_safe(^{
//                [self refreshUI];
//            });
//        }
        return;
    }
    
    if(selectedOptions.count == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_betEmptySelecte")];
        return;
    }
    NSInteger chipValue = [common getChipNums];
    NSInteger minZhu = [betOptionsViewController getMinZhu];
    NSString *optionName = [betOptionsViewController getOptionName]?[betOptionsViewController getOptionName]:YZMsg(@"LobbyLotteryVC_titleBet");
    if(minZhu > 1){
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
    
    NSString *way = @"[";
    NSString *money = @"[";
    for (int i = 0; i < selectedOptions.count; i ++) {
        OptionModel *optionDict = selectedOptions[i];
        //CGFloat optionValue = [optionDict.value floatValue];
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
    
   
    NSInteger liveuid = [GlobalDate getLiveUID];
    NSString *liveuidstr = [NSString stringWithFormat:@"%ld", (long)liveuid];
    
    if (isBeeting) {
        return;
    }
    isBeeting = YES;
    NSString *betIdStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
   
    NSString *betUrl = [NSString stringWithFormat:@"Lottery.Betting"];//User.getPlats
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:15];
    NSDictionary *param = @{@"lottery_type":lottery_type,
                            @"money":money,
                            @"way":way,
                            @"serTime":minnum([[NSDate date] timeIntervalSince1970]),
                            @"issue":issue,
                            @"optionName":optionName,
                            @"liveuid":liveuidstr,
                            @"betid":betIdStr
    };
    [[YBNetworking sharedManager] postNetworkWithUrl:betUrl withBaseDomian:YES andParameter:param data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        isBeeting = NO;
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            NSDictionary *dict = info;
            LiveUser *user = [Config myProfile];
            user.coin = minstr(dict[@"left_coin"]);
            [Config updateProfile:user];
            strongSelf.betViewModel.left_coin = user.coin;
            [strongSelf refreshLeftCoin];
            
            [MBProgressHUD showError:msg];
            // 清空信息
            //[weakSelf doBetCancel];
            [strongSelf doEmptySelcted];
        }
        else{
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        isBeeting = NO;
        // 请求失败
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
    }];
}

-(void)doAdd2LotteryCart{
    // 合并注单 start
    NSArray * options = [NSArray arrayWithArray:[betOptionsViewController getSelectedOptions]];
    NSMutableArray *newBetCart = [NSMutableArray array];
    NSMutableArray *betCart = [NSMutableArray arrayWithArray:[common getLotteryBetCart]];
    NSInteger chipValue = [common getChipNums];
    NSInteger minZhu = [betOptionsViewController getMinZhu];
    NSString *optionName = [betOptionsViewController getOptionName]?[betOptionsViewController getOptionName]:YZMsg(@"LobbyLotteryVC_titleBet");
    NSString *optionNameSt = [betOptionsViewController getOptionNameSt]?[betOptionsViewController getOptionNameSt]:YZMsg(@"LobbyLotteryVC_titleBet");
    if(minZhu > 1){
        // 合并注单
        NSString *new_title;
        NSString *new_st;
        NSString *new_value;
        for (int i = 0; i < options.count; i ++) {
            OptionModel *optionDict = options[i];
            NSArray *splite = [optionDict.title componentsSeparatedByString:@"_"];
            if(!new_title){
                NSString *spliteValue = splite[1];
                if ([optionName isEqualToString:@"连尾"]) {
                    spliteValue = [spliteValue stringByReplacingOccurrencesOfString:@"尾" withString:@""];
                }
                NSString *titleValue = splite[0];
                new_title = [NSString stringWithFormat:@"%@_%@", titleValue, spliteValue];
                new_st = [NSString stringWithFormat:@"%@_%@", optionNameSt, optionDict.st];
            }else{
                NSString *spliteValue = splite[1];
                if ([optionName isEqualToString:@"连尾"]) {
                    spliteValue = [spliteValue stringByReplacingOccurrencesOfString:@"尾" withString:@""];
                }
                new_title = [NSString stringWithFormat:@"%@,%@", new_title, spliteValue];
                new_st = [NSString stringWithFormat:@"%@,%@", new_st, optionDict.st];
            }
            new_value = optionDict.value;
        }
        OptionModel *model = [[OptionModel alloc]init];
        model.title = new_title;
        model.value = new_value;
        model.st_des = new_st;
        options = @[model];
    }else{
        for (int i = 0; i < options.count; i ++) {
            OptionModel *optionDict = options[i];
            optionDict.st_des = [NSString stringWithFormat:@"%@_%@", optionNameSt, optionDict.st];
        }
        
    }
    
    for (int i = 0; i < options.count; i ++) {
        OptionModel *optionDict = options[i];
        BOOL bFound = false;
        if(betCart){
            for (int j = 0; j < betCart.count; j ++) {
                NSDictionary *cartDict = betCart[i];
                
                if([minstr(cartDict[@"title"]) isEqualToString:optionDict.title]){
                    NSInteger newMoney = [cartDict[@"money"] integerValue] + chipValue;
                    [newBetCart addObject:@{@"title":optionDict.title,@"st":optionDict.st_des, @"money":[NSString stringWithFormat:@"%ld", (long)newMoney], @"value":optionDict.value}];
                    [betCart removeObject:cartDict];
                    bFound = true;
                    break;
                }
            }
        }
        if(!bFound){
            [newBetCart addObject:@{@"title":optionDict.title,@"st":optionDict.st_des, @"money":[NSString stringWithFormat:@"%ld", (long)chipValue], @"value":optionDict.value}];
        }
    }
    [newBetCart addObjectsFromArray:betCart];
    // 合并注单end
    
    // 缓存已选注单
    [common saveLotteryBetCart:newBetCart];
    // 清除选中状态
    [betOptionsViewController clearSelectedStatus];
    // 刷新已选注单界面
    [self refreshBottomCart];
    
    // 显示已选注单界面
    [self switchLotteryCartView];

}

-(void)doBetCancel{
    if(_keyBoardHeight > 0){
        [self.view endEditing:YES];
    }else{
        //[betOptionsViewController clearSelectedStatus];
        [self switchLotteryCartView];
    }
    //[MBProgressHUD showError:@"取消"];
}

-(void)doShowBetOptions{
    if(betConfirmVC){
        betConfirmVC.betBlock(0,0);
        betConfirmVC = nil;
        return;
    }
    NSArray *betCart = [common getLotteryBetCart];
    if(betCart.count == 0){
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_betEmptySelecte")];
        return;
    }
    NSDictionary *orderInfo = @{
        @"orders":betCart,
    };
    betConfirmVC = [[LobbyBetConfirmViewController alloc] initWithNibName:@"LobbyBetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    [betConfirmVC setOrderInfo:orderInfo betScale:betScale];
    __weak LobbyBetConfirmViewController* weakBetConfirmVC = betConfirmVC;
    WeakSelf
    betConfirmVC.betBlock = ^(NSInteger idx, NSUInteger num){
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        //[self refreshLeftCoinLabel];
        [weakBetConfirmVC.view removeFromSuperview];
        [weakBetConfirmVC removeFromParentViewController];
        strongSelf->betConfirmVC = nil;
        [strongSelf displayLotteryCartView:NO];
        [strongSelf displayBetView:YES];
    };
    [self.view addSubview:betConfirmVC.view];
//    betConfirmVC.view.y = self.view.height - betConfirmVC.view.bottom;
    betConfirmVC.view.width = _window_width;
    betConfirmVC.view.height = _window_height;
    betConfirmVC.view.bottom = self.view.bottom;
    [self addChildViewController:betConfirmVC];
    
    //[self.view bringSubviewToFront:self.betView];
    [self.view bringSubviewToFront:self.lotteryCartView];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    _keyBoardHeight = kbHeight;
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.betView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view.mas_bottom).offset(-1 * strongSelf->_keyBoardHeight);
        }];
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notify {
    WeakSelf
    // 键盘动画时间
    _keyBoardHeight = 0;
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.betView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(strongSelf.view.mas_bottom).offset(-1 * BottomViewHeight + -1 * strongSelf->_keyBoardHeight);
        }];
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
   
   NSLog(@"=== %@", [NSValue valueWithCGRect:textField.frame]);
//   self.fistField = textField;
//
//   if (_keyBoardHeight > 0) {
//       [self boardAutoAdjust:_keyBoardHeight];
//   }
   return YES;
}

-(void)HomeLottery_didSelected{
    NSArray * options = [betOptionsViewController getSelectedOptions];
    selectedOptions = options;
    [self refreshBetDesc];
    if(options && options.count >= [betOptionsViewController getMinZhu]){
        [self switchBetView];
    }else{
        NSArray *betCart = [common getLotteryBetCart];
        if(betCart.count > 0){
            [self switchLotteryCartView];
        }else{
            [self switchBottomView];
        }
        
    }
}

-(void)ChangedLotteryBetScale:(NSNotification *)notification {
    NSInteger _betScale = [[notification.userInfo objectForKey:@"betScale"] integerValue];
    if(_betScale > 0 && _betScale <= 20){
        betScale = _betScale;
    }
    [self refreshBottomCart];
}

-(void)ChangedLotteryBetCart{
    [self refreshBottomCart];
}

-(void) switchBottomView{
    bottomShowType = 0;
    [self refreshBottomSpace];
    [self displayBottomView:true];
    [self displayBetView:false];
    [self displayLotteryCartView:false];
}

-(void) switchBetView{
    bottomShowType = 1;
    [self refreshBottomSpace];
    [self displayBetView:true];
    [self displayBottomView:true];
    [self displayLotteryCartView:false];
}

-(void) switchLotteryCartView{
    bottomShowType = 2;
    [self refreshBottomSpace];
    [self displayBetView:false];
    [self displayBottomView:false];
    [self displayLotteryCartView:true];
    // 刷新已选注单界面
    [self refreshBottomCart];
}

-(void)refreshBottomSpace{
    if(bottomShowType == 0){
        [betOptionsViewController setBottomSpace:40];
    }else if(bottomShowType == 1){
        [betOptionsViewController setBottomSpace:40 + 95];
    }else if(bottomShowType == 2){
        [betOptionsViewController setBottomSpace:50];
    }
}

-(void)displayBottomView:(BOOL) isShow{
    WeakSelf
    self.bottomView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(isShow){
            [strongSelf.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(strongSelf.view.mas_bottom).offset(0);
            }];
        }else{
            [strongSelf.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(strongSelf.view.mas_bottom).offset(strongSelf.bottomView.height);
            }];
        }
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //self.betView.hidden = !isShow;
    }];
}

-(void)displayBetView:(BOOL) isShow{
    WeakSelf
    self.betView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(isShow){
            [strongSelf.betView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(strongSelf.view.mas_bottom).offset(-1 * BottomViewHeight);
            }];
        }else{
            [strongSelf.betView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(strongSelf.view.mas_bottom).offset(strongSelf.betView.height + 30);
            }];
        }
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //self.betView.hidden = !isShow;
    }];
}

-(void)displayLotteryCartView:(BOOL) isShow{
    WeakSelf
    self.lotteryCartView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(isShow){
            [strongSelf.lotteryCartView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(strongSelf.view.mas_bottom).offset(0);
            }];
        }else{
            [strongSelf.lotteryCartView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(strongSelf.view.mas_bottom).offset(strongSelf.lotteryCartView.height + 50);
            }];
        }
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //self.lotteryCartView.hidden = !isShow;
    }];
}

-(void)cancelWithKeyBoard{
    [self.customAmountTextField resignFirstResponder];
}

-(void)doneWithKeyBoard{
    [self.customAmountTextField resignFirstResponder];
}

-(void)initCollection{
    // 最后一期开奖
//    EqualSpaceFlowLayoutEvolve *flowLayout = [[EqualSpaceFlowLayoutEvolve alloc]    initWthType:AlignWithRight];
//    flowLayout.betweenOfCell = 1;
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
//    flowLayout.minimumLineSpacing = 0;
//    flowLayout.minimumInteritemSpacing = 0;
    
    self.openResultCollection.delegate = self;
    self.openResultCollection.dataSource = self;
//    self.openResultCollection.collectionViewLayout = flowLayout;
    self.openResultCollection.allowsMultipleSelection = self;
    UINib *nib2=[UINib nibWithNibName:kIssueCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    if (curLotteryType == 10) {
        [self.openResultCollection registerClass:[OpenNNHistory1Cell class] forCellWithReuseIdentifier:@"OpenNNHistory1Cell"];
        
    }
    
    [self.openResultCollection registerNib: nib2 forCellWithReuseIdentifier:kIssueCollectionViewCell];
    
    self.openResultCollection.backgroundColor=[UIColor clearColor];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.openResultCollection.collectionViewLayout;
    
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        flowLayout.minimumInteritemSpacing = 1.0f;// 左右间距
    }else{
        flowLayout.minimumInteritemSpacing = 1.0f;// 左右间距
    }
    
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (curLotteryType == 10){
        return 1;
    }
    if(!last_open_result) return 0;
    NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
    }
    return result_count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section{
    if (curLotteryType == 10){
        return 1;
    }
    
    if(!last_open_result) return 0;
    NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
    }
    return result_count;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"显示历史记录1");
    //[self doShowHistory];
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"显示历史记录2");
    //[self doShowHistory];
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (curLotteryType == 10) {
        OpenNNHistory1Cell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"OpenNNHistory1Cell" forIndexPath:indexPath];
        lastResultModel *model = nnModel.lastResult;
        cell.model = model;
        return cell;
    }else{
        IssueCollectionViewCell2 *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell forIndexPath:indexPath];
        NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
        
        NSString *resultStr = @"";
        NSMutableArray *extInfo;
        if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
            // 六合彩单独处理
            if(indexPath.row == 6){
                resultStr = @"+";
            }else if (indexPath.row == 7){
                resultStr = [open_result objectAtIndex:6];
            }else{
                resultStr = [open_result objectAtIndex:indexPath.row];
            }
            extInfo = [NSMutableArray arrayWithArray: self.betViewModel.lastResult.spare_2];
            [extInfo insertObject:@"" atIndex: 6];
            [cell setNumber:resultStr lotteryType:curLotteryType extinfo:@{@"index":[NSString stringWithFormat:@"%ld", indexPath.row], @"info":extInfo}];
        }else{
            resultStr = [open_result objectAtIndex:indexPath.row];
            [cell setNumber:resultStr lotteryType:curLotteryType extinfo:@{@"index":[NSString stringWithFormat:@"%ld", indexPath.row]}];
        }
        
        
        return cell;
    }
    
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    
    if (curLotteryType == 10){
        return CGSizeMake(collectionView.width, 45);
    }
    
    if([GameToolClass isLHC:curLotteryType]){
        return CGSizeMake(25, 35);
    }
    if([GameToolClass isSC:curLotteryType]){
        return CGSizeMake(24, 35);
    }
    return CGSizeMake(35, 35);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (curLotteryType == 10){
        return CGSizeMake(collectionView.width, 45);
    }
    if([GameToolClass isLHC:curLotteryType]){
        return CGSizeMake(25, 35);
    }
    if([GameToolClass isSC:curLotteryType]){
        return CGSizeMake(24, 35);
    }
    return CGSizeMake(35, 35);
}
-(NSInteger) getItemCountByLotteryType:(NSInteger)lottery{
    if (curLotteryType == 10){
        return 1;
    }
    NSArray *open_result = [last_open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if([GameToolClass isLHC:lottery]){
        result_count = result_count + 1;
    }
    return result_count;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if (curLotteryType == 10){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    CGFloat left = 0;
    CGFloat right = 0;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionView.collectionViewLayout;
    CGFloat spacing = flowLayout.minimumInteritemSpacing; //左右间隔
    
    
    NSInteger result_count = [self getItemCountByLotteryType:curLotteryType];
//    if([GameToolClass isLHC:curLotteryType]){
//        left = (collectionView.width - (25 + spacing * 1.5) * result_count) / 2;
//    }else if([GameToolClass isSC:curLotteryType]){
//        left = (collectionView.width - (24 + spacing * 1.5) * result_count) / 2;
//    }else{
//        left = (collectionView.width - (35 + spacing * 1.5) * result_count) / 2;
//    }
    right = left;
    return UIEdgeInsetsMake(4, left, 4, right);
}

// collection头部高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={100,0};
    return size;
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



#pragma mark - UUMarqueeViewDelegate
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    return 1;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    return _upwardMultiMarqueeViewData ? _upwardMultiMarqueeViewData.count : 0;
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _upwardMultiMarqueeView) {
        // for upwardMultiMarqueeView
        itemView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];

//        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
//        icon.tag = 1003;
//        [itemView addSubview:icon];

        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(itemView.bounds) - 75.0f, 0.0f, 70.0f, CGRectGetHeight(itemView.bounds))];
        time.textAlignment = NSTextAlignmentRight;
        time.font = [UIFont systemFontOfSize:9.0f];
        time.tag = 1002;
        [itemView addSubview:time];

        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + 16.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 75.0f, CGRectGetHeight(itemView.bounds))];
        content.font = [UIFont systemFontOfSize:10.0f];
        content.tag = 1001;
        [itemView addSubview:content];
    }
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    if (marqueeView == _upwardMultiMarqueeView) {
        // for upwardMultiMarqueeView
        UILabel *content = [itemView viewWithTag:1001];
        if(!_upwardMultiMarqueeViewData[index]){
            return;
        }
        [content setAttributedText:[_upwardMultiMarqueeViewData[index] objectForKey:@"content"]];
        //content.text = [_upwardMultiMarqueeViewData[index] objectForKey:@"content"];

        UILabel *time = [itemView viewWithTag:1002];
        NSString *tmStr = [YBToolClass timeFormattedAge:[[_upwardMultiMarqueeViewData[index] objectForKey:@"time"] integerValue]];
        time.text = tmStr;

//        UIImageView *icon = [itemView viewWithTag:1003];
//        icon.image = [ImageBundle imagewithBundleName:[_upwardMultiMarqueeViewData[index] objectForKey:@"icon"]];
    }
}

-(void)cacheGameList{
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

-(void)CancelMachineSelection{
    self.deviceRandomBtn.selected = NO;
}

@end
