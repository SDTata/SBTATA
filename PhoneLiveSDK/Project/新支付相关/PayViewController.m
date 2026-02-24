//
//  PayViewController.m
//
//

#import "PayViewController.h"
#import "PayBaseViewController.h"
#import "PayHeadViewController.h"
#import "PayChannelViewController.h"
#import "PayAmountViewController.h"
#import "PayTransferViewController.h"
#import "PayRichTextViewController.h"
#import "PayInsteadViewController.h"
#import "PayReqViewController.h"
#import "PayWaitConfirmViewController.h"
#import "myWithdrawVC2.h"

#import "UUMarqueeView.h"

#import "WMZDialog.h"
#import <CRBoxInputView/CRBoxInputView.h>
#import <CRBoxInputView/CRLineView.h>
#import <CRBoxInputView/CRSecrectImageView.h>
//#import <AlipaySDK/AlipaySDK.h>
#import "FilterCountryVC.h"
#import "UIImageView+WebCache.h"
#import "webH5.h"
#import <UMCommon/UMCommon.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define CRBOX_UIColorFromHEX(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define color_master CRBOX_UIColorFromHEX(0x313340)
#define color_FFECEC CRBOX_UIColorFromHEX(0xFFECEC)
#define WIDTH ([UIScreen  mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
//  适配对应 高度 < 5高度时，高度 = 5高度
#define LayOutHeight  ((HEIGHT < HEIGHT5) ? HEIGHT5 : HEIGHT)
#define WIDTH5 320.0
#define HEIGHT5 568.0
//  6
#define WIDTH6 375.0
#define HEIGHT6 667.0
#define XX_6(value)     (1.0 * (value) * WIDTH / WIDTH6)
#define YY_6(value)     (1.0 * (value) * LayOutHeight / HEIGHT6)

#define RegionPaySelected @"RegionPaySelected"
//@import LiveChat;
@interface PayViewController ()<FilterCountryDelegate,UUMarqueeViewDelegate>{
    WMZDialog *myAlert;
    
    NSDictionary *allData;
    NSMutableArray *ways;   // 投注选项
    NSInteger waySelectIndex; // 当前选择的投注索引
    BOOL bUICreated; // UI是否创建
    BOOL bInitTap; // 交互UI是否创建
    BOOL isExit;
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSString *curIssue; // 当前期号
    NSMutableArray *waysBtn;   // 投注分类按钮
    
    NSString *last_open_result;
    
    NSMutableArray *subVC;
    PayHeadViewController *headVC;
    PayChannelViewController *channelVC;
    PayAmountViewController *amountVC;
    PayTransferViewController *transferVC;
    PayRichTextViewController *richrextVC;
    PayReqViewController *reqVC;
    NSString *regionCurrent;
    // 横向 跑马灯
    UUMarqueeView *_horizontalMarquee;
    
    BOOL bNeedCode;
    BOOL bHomeMode;
    MBProgressHUD *hud;
}
@property (nonatomic, strong) NSDate *rotationStartDate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBalanceLayoutValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightBalanceLayoutValue;
@property (weak, nonatomic) IBOutlet UILabel *balanceTitleLabel;




@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTipViewConstraint;
@property (weak, nonatomic) IBOutlet UIView *countryFilterView;
@property (weak, nonatomic) IBOutlet UIImageView *countryImgView;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countryChoiseConstraint;

@property (weak, nonatomic) IBOutlet UIView *blanceBgV;
@property (weak, nonatomic) IBOutlet UIButton *refreshbalanceButton;
@property(nonatomic,strong)NSArray *pay_support_regions;
@property (weak, nonatomic) IBOutlet UILabel *kefudesLabel;
@property (weak, nonatomic) IBOutlet UILabel *kefudeslabel1;

@property (nonatomic, strong) NSArray *leftwardMarqueeViewData;
@end

@implementation PayViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTime:) name:@"lotterySecondNotify" object:nil];
   
//    [self getInfo];
    
//    self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
//    self.contentView.hidden = NO;
//    [UIView animateWithDuration:0.25 animations:^{
//        //        self.view.frame = f;
//        self.``contentView``.bottom = _window_height;
//    } completion:^(BOOL finished) {
//    }];
    
    if(!bInitTap){
        [self initTap];
    }
    
    [_horizontalMarquee setDirection:UUMarqueeViewDirectionLeftward];
    [_horizontalMarquee start];
    
    if (bHomeMode) {
        self.countryChoiseConstraint.constant = -25;
        [self.countryFilterView.superview layoutIfNeeded];
        [self.countryFilterView.superview setNeedsLayout];
    }
    [self refreshBalance];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor =[UIColor clearColor];
//    self.pageScrollview.backgroundColor =[UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutAllSubView) name:@"Pay_LayoutAllSubView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayType:) name:@"Pay_SelectPayType" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectPayChannel:) name:@"Pay_SelectPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doPayRequest:) name:@"Pay_NeedRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getInfo) name:@"Pay_getInfo" object:nil];
    
    self.kefudeslabel1.text = YZMsg(@"activity_login_connectkefu");
    self.kefudesLabel.text = YZMsg(@"activity_charge_connectkefu");
    self.balanceTitleLabel.text = YZMsg(@"PayVC_BalanceTitle");
    [self.withDrawBtn setTitle:YZMsg(@"public_WithDraw") forState:UIControlStateNormal];
    [self.listBtn setTitle:YZMsg(@"PayVC_Record") forState:UIControlStateNormal];
    self.balanceTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.balanceTitleLabel.minimumScaleFactor = 0.1;
    self.withDrawBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.withDrawBtn.titleLabel.minimumScaleFactor = 0.1;
    self.listBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.listBtn.titleLabel.minimumScaleFactor = 0.1;
     
    
    UIImageView * bj = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bj.image = [ImageBundle imagewithBundleName:@"bg_charge"];
    [self.view addSubview: bj];
    [self.view sendSubviewToBack:bj];
    self.pageScrollview.delegate = self;
//    self.pageScrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    regionCurrent = [[NSUserDefaults standardUserDefaults]objectForKey:RegionPaySelected];
    if (regionCurrent== nil) {
        regionCurrent = @"";
    }
    self.titleLabel.text = self.titleStr;
    [self.serviceBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"zjm_rg")] forState:UIControlStateNormal];
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.pageScrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    UITapGestureRecognizer *tapUpdate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshBalance)];
    [self.blanceBgV addGestureRecognizer:tapUpdate];
    
    // 设置圆角
    self.marqueeView.layer.cornerRadius = 10.0; // 调整为所需的圆角大小
    self.marqueeView.layer.masksToBounds = NO;  // 重要：这样阴影才会显示出来

    // 设置阴影
    self.marqueeView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.marqueeView.layer.shadowOpacity = 0.2;  // 调整为所需的透明度
    self.marqueeView.layer.shadowRadius = 2.0;   // 调整为所需的阴影模糊度
    self.marqueeView.layer.shadowOffset = CGSizeMake(0, 2.0);  // x为水平偏移，y为垂直偏移。此设置使阴影仅在下方显示。
    
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:[Config getExchangeRate]];
    if ([rate compare:[NSDecimalNumber decimalNumberWithString:@"0.0"]]!= NSOrderedDescending) {
        [[MXBADelegate sharedAppDelegate] getConfig:false complete:^(NSString *errormsg) {
            dispatch_main_async_safe(^{
            
            });
        }];
    }
    
    WeakSelf
    self.pageScrollview.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
           STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf getInfo];
        [strongSelf refreshBalance];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.pageScrollview.mj_header endRefreshing];
//            ((MJRefreshNormalHeader*)strongSelf.tableView.mj_header).ignoredScrollViewContentInsetTop = 0;
        });
    }];
    ((MJRefreshNormalHeader*)self.pageScrollview.mj_header).stateLabel.hidden = YES;
    ((MJRefreshNormalHeader*)self.pageScrollview.mj_header).arrowView.tintColor = [UIColor whiteColor];
    ((MJRefreshNormalHeader*)self.pageScrollview.mj_header).activityIndicatorViewStyle = UIScrollViewIndicatorStyleWhite;
    ((MJRefreshNormalHeader*)self.pageScrollview.mj_header).lastUpdatedTimeLabel.hidden = YES;
    [self getInfo];
//    [self refreshBalance];
}
-(void)exitView{
    if(isExit) return;
    [GameToolClass setCurOpenedLotteryType:0];
    isExit = true;
    CGFloat y = self.view.frame.origin.y;
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.view.bottom = _window_height + y;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
   
    [_horizontalMarquee pause];
    //[XLDouYinLoading hideInView:self.view];
}

- (void)getInfo{
    //[XLDouYinLoading showInView:self.view];
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getPayConfig"];
    NSLog(@"Req:%@",userBaseUrl);
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:@{@"region":regionCurrent} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0 && [info isKindOfClass:[NSArray class]])
        {
            strongSelf->allData = [info firstObject][@"data"];
            strongSelf.pay_support_regions = [CountryFilterModel mj_objectArrayWithKeyValuesArray: [info firstObject][@"pay_support_regions"]];
            CountryFilterModel *selectedModel = [CountryFilterModel mj_objectWithKeyValues:[info firstObject][@"pay_current_region"]];
            strongSelf->regionCurrent = selectedModel.countryCode;
            [strongSelf selectedView:selectedModel];
            // 弹窗
            NSString *alertMsg = strongSelf->allData[@"alertMsg"];
            if(alertMsg && alertMsg.length > 0){
                UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertC addAction:suerA];
                if (currentVC.presentedViewController == nil) {
                    [currentVC presentViewController:alertC animated:YES completion:nil];
                }
            }
            
            
            if(!strongSelf->allData[@"chargeClass"]){
                [MBProgressHUD showError:YZMsg(@"public_networkError")];
//                [self exitView];
                return;
            }
            
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
                [strongSelf refreshBalance];
            });
        }
        else{
            //[XLDouYinLoading hideInView:self.view];
            if(msg){
                [MBProgressHUD showError:msg];
            }else{
                [MBProgressHUD showError:YZMsg(@"public_networkError")];
            }
            //[self exitView];
        }

    } fail:^(NSError * _Nonnull error) {
        //[XLDouYinLoading hideInView:self.view];
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        //[self exitView];
        return;
    }];
}

-(void)refreshUI{
    if(!subVC){
        subVC = [NSMutableArray array];
    }
    if(!bUICreated){
        [self initUI];
    }else{
        for (int i = 0; i < subVC.count; i++) {
            if([subVC[i] isKindOfClass:PayHeadViewController.class]){
                NSArray * chargeClassArray = allData[@"chargeClass"];
                [subVC[i] setChargeData:chargeClassArray];
                break;
            }
          
        }
        NSArray *marquees = allData[@"marquee"][@"msg"];
        if ([marquees isKindOfClass:[NSArray class]] && marquees.count>0 && ![PublicObj checkNull:marquees[0]]) {
            self.leftwardMarqueeViewData = [self msgArrayToArray:marquees];
            [self.horizontalMarquee reloadData];
            self.topTipViewConstraint.constant = 35;
        }else{
           
            self.leftwardMarqueeViewData = @[@""];
            [self.horizontalMarquee reloadData];
            
            self.topTipViewConstraint.constant = 0;
        }
    }
    
}

-(NSMutableArray *)msgArrayToArray:(NSArray *)msgAr{
    NSMutableArray *ssssmsg = [NSMutableArray array];
    for (int i=0; i<msgAr.count; i++) {
        NSString *msgsM = msgAr[i];
        NSArray *msgSubS = [msgsM componentsSeparatedByString:@"\n"];
        [ssssmsg addObjectsFromArray:msgSubS];
    }
    return ssssmsg;
}

-(void)initTap{
    bInitTap = true;
    
    [self.serviceBtn addTarget:self action:@selector(doShowService) forControlEvents:UIControlEventTouchUpInside];
    [self.returnBtn addTarget:self action:@selector(doBackVC) forControlEvents:UIControlEventTouchUpInside];
    self.returnBtn.hidden = bHomeMode;
    self.countryFilterView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapActionFilterCountry)];
    [self.countryFilterView addGestureRecognizer:gesture];
}
-(void)tapActionFilterCountry{
    FilterCountryVC *filterCountryVC = [[FilterCountryVC alloc]initWithNibName:@"FilterCountryVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    filterCountryVC.delegate = self;
    filterCountryVC.isPayPage = YES;
    filterCountryVC.datas = self.pay_support_regions;
    [[MXBADelegate sharedAppDelegate] pushViewController:filterCountryVC animated:YES];
    [MobClick event:@"charge_country_click" attributes:@{@"eventType": @(1)}];
}
-(void)countryModelSelected:(CountryFilterModel *)model
{
    regionCurrent = model.countryCode;
    [[NSUserDefaults standardUserDefaults]setObject:regionCurrent forKey:RegionPaySelected];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self getInfo];
    [self selectedView:model];
}

-(void)selectedView:(CountryFilterModel*)model{
    self.countryNameLabel.text = model.name;
    [self.countryImgView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[ImageBundle imagewithBundleName:@""]];

}


-(void)initUI{
    bUICreated = true;
    bNeedCode = false;
    
    
    NSArray *marquees = allData[@"marquee"][@"msg"];
    if ([marquees isKindOfClass:[NSArray class]] && marquees.count>0 && ![PublicObj checkNull:marquees[0]]) {
        self.leftwardMarqueeViewData = [self msgArrayToArray:marquees];
        [self.horizontalMarquee reloadData];
     
        self.topTipViewConstraint.constant = 35;
    }else{
        self.topTipViewConstraint.constant = 0;
        self.leftwardMarqueeViewData = @[@""];
        [self.horizontalMarquee reloadData];
    }
   
    [self.marqueeView addSubview:self.horizontalMarquee];
  
    headVC = [[PayHeadViewController alloc] initWithNibName:@"PayHeadViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    NSArray * chargeClassArray = allData[@"chargeClass"];
    [headVC setChargeData:chargeClassArray];
    headVC.view.top = 100;
    headVC.view.width = SCREEN_WIDTH;
    [self.pageScrollview addSubview:headVC.view];
    [self addChildViewController:headVC];
    [subVC addObject:headVC];
    
//    channelVC = [[PayChannelViewController alloc] initWithNibName:@"PayChannelViewController" bundle:nil];
//    [self.contentView addSubview:channelVC.view];
//    [self addChildViewController:channelVC];
//    [subVC addObject:channelVC];
//
//    amountVC = [[PayAmountViewController alloc] initWithNibName:@"PayAmountViewController" bundle:nil];
//    [self.contentView addSubview:amountVC.view];
//    [self addChildViewController:amountVC];
//    [subVC addObject:amountVC];
//
//    transferVC = [[PayTransferViewController alloc] initWithNibName:@"PayTransferViewController" bundle:nil];
//    [self.contentView addSubview:transferVC.view];
//    [self addChildViewController:transferVC];
//    [subVC addObject:transferVC];
//
//    richrextVC = [[PayRichTextViewController alloc] initWithNibName:@"PayRichTextViewController" bundle:nil];
//    [self.contentView addSubview:richrextVC.view];
//    [self addChildViewController:richrextVC];
//    [subVC addObject:richrextVC];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (UUMarqueeView *)horizontalMarquee {
    if (!_horizontalMarquee) {
        _horizontalMarquee =  [[UUMarqueeView alloc] initWithFrame:CGRectMake(30, 0, self.marqueeView.width - 30 - 30, 35) direction:UUMarqueeViewDirectionLeftward];
        _horizontalMarquee.delegate = self;
        _horizontalMarquee.timeIntervalPerScroll = 0.0f;
        _horizontalMarquee.scrollSpeed = 60.0f;
        _horizontalMarquee.itemSpacing = 20.0f;
        _horizontalMarquee.touchEnabled = YES;
    }
    
    return _horizontalMarquee;
}

#pragma mark - UUMarqueeViewDelegate
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
   return 2;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
    return self.leftwardMarqueeViewData.count;
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    // for leftwardMarqueeView
    itemView.backgroundColor = [UIColor clearColor];

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
    icon.tag = 1002;
    [itemView addSubview:icon];

    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + 16.0f + 5.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 5.0f - 5.0f, CGRectGetHeight(itemView.bounds))];
    content.font = [UIFont systemFontOfSize:14.0f];
    content.tag = 1001;
    [itemView addSubview:content];
       
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
   
    // for leftwardMarqueeView
    UILabel *content = [itemView viewWithTag:1001];
    content.text = self.leftwardMarqueeViewData[index];

    UIImageView *icon = [itemView viewWithTag:1002];
    icon.image = [UIImage imageNamed:@"speaker"];
    
}



- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    // for leftwardMarqueeView
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:14.0f];
    content.text = _leftwardMarqueeViewData[index];
    return (5.0f + 16.0f + 5.0f) + content.intrinsicContentSize.width;  // icon width + label width (it's perfect to cache them all)
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"PayVC_AlertDestitle") message:self.leftwardMarqueeViewData[index] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alertC addAction:suerA];
    if (currentVC.presentedViewController == nil) {
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
    [MobClick event:@"charge_country_notice_click" attributes:@{ @"eventType": @(1)}];
}

- (void)refreshSelectPayType:(NSNotification *)notification {
    while (subVC.count > 1) {
        PayBaseViewController *lastVC = [subVC objectAtIndex:subVC.count-1];
        [lastVC removeFromParentViewController];
        [lastVC.view removeFromSuperview];
        [subVC removeLastObject];
    }
    
    NSArray *content = (notification.userInfo[@"content"]);
    NSString *charge_type = notification.userInfo[@"charge_type"];
    
    PayBaseViewController *channelVC = [[PayChannelViewController alloc] initWithNibName:@"PayChannelViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    channelVC.view.top = headVC.view.bottom;
    [self.pageScrollview addSubview:channelVC.view];
    [self addChildViewController:channelVC];
    [subVC addObject:channelVC];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_RefreshPayType" object:nil userInfo:@{@"content":content,
                                                                                                           @"charge_type": charge_type ? charge_type : @""}];
}

- (void)refreshSelectPayChannel:(NSNotification *)notification {
    NSArray *subContent = (notification.userInfo[@"subContent"]);
    NSInteger maxCount = subContent.count;
    BOOL bHaveChannel = false;
    for (int i=0; i<maxCount; i++) {
        NSString *classType = minstr(subContent[i][@"type"]);
        if([classType isEqualToString:@"channelClass"]){
            bHaveChannel = true;
        }
    }
    while (subVC.count > (bHaveChannel?2:1)) {
        PayBaseViewController *lastVC = [subVC objectAtIndex:subVC.count-1];
        [lastVC removeFromParentViewController];
        [lastVC.view removeFromSuperview];
        [subVC removeLastObject];
    }
    
    NSMutableArray *reqKey = [[NSMutableArray alloc]init];
    for (int i=0; i<maxCount; i++) {
        NSString *classType = minstr(subContent[i][@"type"]);
        PayBaseViewController *curVC;
        if([classType isEqualToString:@"channelClass"]){
            continue;
            //curVC = [[PayChannelViewController alloc] initWithNibName:@"PayChannelViewController" bundle:nil];
        }else if([classType isEqualToString:@"chosseAmountClass"]||[classType isEqualToString:@"chosseAmountRateGiveClass"]){
            amountVC = [[PayAmountViewController alloc] initWithNibName:@"PayAmountViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
            curVC = amountVC;
        }else if([classType isEqualToString:@"richtextClass"]){
            curVC = [[PayRichTextViewController alloc] initWithNibName:@"PayRichTextViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        }else if([classType isEqualToString:@"transferClass"]){
            curVC = [[PayTransferViewController alloc] initWithNibName:@"PayTransferViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        }else if([classType isEqualToString:@"insteadClass"]){
            curVC = [[PayInsteadViewController alloc] initWithNibName:@"PayInsteadViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        }else if([classType isEqualToString:@"reqClass"]){
            reqVC = [[PayReqViewController alloc] initWithNibName:@"PayReqViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
            [(PayReqViewController *)curVC setReqKey:reqKey];
            curVC = reqVC;
        }
        
        if(!curVC){
            continue;
        }
        NSArray * vcRequireKey = [curVC getRequireKeys];
        if(vcRequireKey){
            NSInteger reqMaxCount = vcRequireKey.count;
            for (int j=0; j<reqMaxCount; j++) {
                [reqKey addObject:vcRequireKey[j]];
            }
        }
        curVC.view.hidden = YES;
        
        [self.pageScrollview addSubview:curVC.view];
        [self addChildViewController:curVC];
        [subVC addObject:curVC];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_RefreshPayChannel" object:nil userInfo:subContent!=nil?@{@"subContent":subContent}:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pay_LayoutAllSubView" object:nil];
    
    [self refreshBalance];
}

- (void)layoutAllSubView
{
    NSInteger maxCount = subVC.count;
    if (maxCount<=3) {
        return;
    }
    for (int i=0; i<maxCount; i++) {
        PayBaseViewController *VC = subVC[i];
        PayBaseViewController *lastVC = NULL;
        if(i > 0){
            lastVC = subVC[i - 1];
        }
        
        if(i != (maxCount - 1)){
            if(lastVC){
                //NSLog([NSString stringWithFormat:@"1 layoutAllSubView_i:%ld, mas_bottom:%0.1f, viewHeight:%.1f", i, lastVC.view.bottom, VC.viewHeight.constant]);
                VC.view.top = lastVC.view.bottom;
                VC.view.width = SCREEN_WIDTH;
//                [VC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(lastVC.view.mas_bottom);
//                    make.left.mas_equalTo(0);
//                    make.right.mas_equalTo(0);
//                    make.height.mas_equalTo(VC.viewHeight.constant);
//                }];
            }else{
         
                [VC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                    make.left.mas_equalTo(0);
                    make.width.mas_equalTo(SCREEN_WIDTH);
                    make.right.mas_equalTo(0);
                    make.height.mas_equalTo(VC.viewHeight.constant);
                }];
            }
        }else{
            if(lastVC){
                //NSLog([NSString stringWithFormat:@"3 layoutAllSubView_i:%ld, mas_bottom:%0.1f, height:%.1f", i, lastVC.view.bottom, VC.viewHeight.constant]);
                VC.view.top = lastVC.view.bottom;
                VC.view.width = SCREEN_WIDTH;
                self.pageScrollview.contentSize = CGSizeMake(SCREEN_WIDTH, VC.view.bottom+50 + ShowDiff);
//                [VC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.top.equalTo(lastVC.view.mas_bottom);
//                    make.left.mas_equalTo(0);
//                    make.right.mas_equalTo(0);
//                    make.height.mas_equalTo(VC.viewHeight.constant);
//                    
//                    make.bottom.mas_equalTo(-50 - ShowDiff);
//                }];
            }else{
                //NSLog([NSString stringWithFormat:@"4 layoutAllSubView_i:%ld, mas_bottom:%0.1f, height:%.1f", i, 0.0,  VC.viewHeight.constant]);
                VC.view.top = 0;
                VC.view.width = SCREEN_WIDTH;
                self.pageScrollview.contentSize = CGSizeMake(SCREEN_WIDTH, VC.view.bottom+30 + ShowDiff);
                [VC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                    make.left.mas_equalTo(0);
                    make.right.mas_equalTo(0);
                    make.height.mas_equalTo(VC.viewHeight.constant);
                    make.width.mas_equalTo(SCREEN_WIDTH);
                    make.bottom.mas_equalTo(-30  - ShowDiff);
                }];
            }
        }
        
        VC.view.hidden = NO;
        VC.view.userInteractionEnabled = YES;
    }
//    self.contentView.height = self.pageScrollview.contentSize.height;
//    float heightss = self.pageScrollview.contentSize.height;
//    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(heightss);
//    }];
}

- (void)doShowService {
//    LiveChat.licenseId = livechatKey;
//    LiveChat.name = [Config getOwnID];
//    if (!LiveChat.isChatPresented) {
//        [LiveChat presentChatWithAnimated:YES completion:nil];
//    }else{
//        [LiveChat dismissChatWithAnimated:YES completion:^(BOOL finished) {
//
//        }];
//    }
    
    [YBToolClass showService];
}

- (void)doBackVC{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)haveTransferClass{
    BOOL bHave = false;
    for (int i = 0; i < subVC.count; i++) {
        if([subVC[i] isKindOfClass:PayTransferViewController.class]){
            bHave = true;
            break;
        }
    }
    
    return bHave;
}

- (void)doPayRequest:(NSNotification *)notification {
    //NSString *leftCoin = (notification.userInfo[@"money"]);
    // TODO
    bNeedCode = false;
    if(bNeedCode){
        [self showCode];
    }else{
        [self realyPay];
    }
}
-(NSMutableDictionary *)getRequestParams{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < subVC.count; i++) {
        NSDictionary *params = [subVC[i] getRequestParams];
        for (NSString *k in params) {
            [dict setObject:params[k] forKey:k];
        }
    }
    return dict;
}
-(void)dealloc
{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_LayoutAllSubView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_SelectPayType" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_SelectPayChannel" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_NeedRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pay_getInfo" object:nil];
}

-(void)realyPay{
    hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:15];
    BOOL bHaveTransfer = [self haveTransferClass];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"country_code": regionCurrent,
                            @"charge_type": ((PayChannelViewController *)subVC[1]).channelData[@"charge_type"],
                            @"charge_name": ((PayChannelViewController *)subVC[1]).channelData[@"title"]};
    [MobClick event:@"charge_sure_click" attributes:dict];

    if(bHaveTransfer){
        // 提取请求参数
        NSDictionary *params = [self getRequestParams];
        NSString *commitOrderUrl = [NSString stringWithFormat:@"User.newOrder"];
        // 请求接口
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:commitOrderUrl withBaseDomian:YES andParameter:params data:nil success:^(int code,id info,NSString *msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf->hud hideAnimated:YES];
            if (code == 0) {
                if(params[@"password"]){
                    [strongSelf getInfo];
                    [MBProgressHUD showSuccess:msg];
                    return;
                }
                //NSArray *infoA = [info objectAtIndex:0];
                // 提示先转账
                UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"PayVC_AlertImportDestitle") message:YZMsg(@"PayVC_AlertImportDetail") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"PayVC_finishedtransfer") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 显示等待财务核对
                    PayWaitConfirmViewController *VC = [[PayWaitConfirmViewController alloc]initWithNibName:@"PayWaitConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                    [strongSelf.navigationController pushViewController:VC animated:YES];
                }];
                UIAlertAction *suerB = [UIAlertAction actionWithTitle:YZMsg(@"PayVC_noTransfer") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertC addAction:suerB];
                [alertC addAction:suerA];
                if (alertC.presentedViewController == nil) {
                    [currentVC presentViewController:alertC animated:YES completion:nil];
                }
                
            }else{
                [MBProgressHUD showError:YZMsg(@"PayVC_OrderError")];
            }
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf->hud hideAnimated:YES];
            [MBProgressHUD showError:YZMsg(@"PayVC_OrderError")];
            
        }];
    }else{
        NSDictionary *params = [self getRequestParams];
        NSString *commitOrderUrl = [NSString stringWithFormat:@"User.newOrder&supportPaySDK=true"];
        // 请求接口
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:commitOrderUrl withBaseDomian:YES andParameter:params data:nil success:^(int code,id info,NSString *msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf->hud hideAnimated:YES];
            if (code == 0) {
                if(params[@"password"]){
                    [strongSelf getInfo];
                    [MBProgressHUD showSuccess:msg];
                    return;
                }
                NSString *payType = minstr(info[@"payType"]);
                NSString *url = minstr(info[@"turnUrl"]);
                 if([payType isEqualToString:@"aliPay"]) {
                     [strongSelf doAlipayPay:url];
                }else if ([payType isEqualToString:@"wxPay"]){
                    
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                    
                    // 提示先转账
                    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"PayVC_AlertImportDestitle") message:YZMsg(@"PayVC_TransferResultTitle") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"PayVC_PaySuccess") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        // 显示等待财务核对
                        PayWaitConfirmViewController *VC = [[PayWaitConfirmViewController alloc]initWithNibName:@"PayWaitConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                        [strongSelf.navigationController pushViewController:VC animated:YES];
                    }];
                    UIAlertAction *suerB = [UIAlertAction actionWithTitle:YZMsg(@"PayVC_PayError") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertC addAction:suerB];
                    [alertC addAction:suerA];
                    if (currentVC.presentedViewController == nil) {
                        [currentVC presentViewController:alertC animated:YES completion:nil];
                    }
                    
                }
                
                
            }else{
                if(msg && msg.length > 0){
                    [MBProgressHUD showError:msg];
                }else{
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@[%d]",YZMsg(@"PayVC_OrderError"), code]];
                }
                
            }
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf->hud hideAnimated:YES];
            [MBProgressHUD showError:YZMsg(@"PayVC_OrderError")];
        }];
        
    }
}

- (void)closeAction:(UIButton*)sender{
    NSLog(@"点击方法");
    //关闭
    [myAlert closeView];
}

-(void)showCode{
    if(myAlert){
        return;
    }
    WeakSelf
    myAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    //关闭事件 此时要置为不然会内存泄漏
    .wEventCloseSet(^(id anyID, id otherData) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->myAlert = nil;
    })
    .wShowAnimationSet(AninatonZoomIn)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.1)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        UILabel *la = [UILabel new];
        la.font = [UIFont systemFontOfSize:15.0f];
        NSInteger codeNumber = 1000 + (arc4random() % 999); // 验证码 1000 - 1999
        NSString * code = [NSString stringWithFormat:@"%ld", (long)codeNumber];
        la.text = [NSString stringWithFormat:@"%@【%@】",YZMsg(@"loginActivity_login_input_pwd"), code];
        
        la.numberOfLines = 0;
        la.frame = CGRectMake(10, 0, mainView.frame.size.width-20, 100);
        [la setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:la];
        
        CRBoxInputCellProperty *cellProperty = [CRBoxInputCellProperty new];
        cellProperty.cellBgColorNormal = color_FFECEC;
        cellProperty.cellBgColorSelected = [UIColor whiteColor];
        cellProperty.cellCursorColor = color_master;
        cellProperty.cellCursorWidth = 2;
        cellProperty.cellCursorHeight = 30;
        cellProperty.cornerRadius = 4;
        cellProperty.borderWidth = 0;
        cellProperty.cellFont = [UIFont boldSystemFontOfSize:24];
        cellProperty.cellTextColor = color_master;
        cellProperty.configCellShadowBlock = ^(CALayer * _Nonnull layer) {
            layer.shadowColor = [color_master colorWithAlphaComponent:0.2].CGColor;
            layer.shadowOpacity = 1;
            layer.shadowOffset = CGSizeMake(0, 2);
            layer.shadowRadius = 4;
        };
        
        CRBoxInputView *boxInputView = [CRBoxInputView new];
        boxInputView.boxFlowLayout.itemSize = CGSizeMake(40, 40);
        boxInputView.customCellProperty = cellProperty;
        [boxInputView loadAndPrepareViewWithBeginEdit:YES];
        [mainView addSubview:boxInputView];
        //            __weak __typeof(self)weakSelf = self;
        [boxInputView mas_makeConstraints:^(MASConstraintMaker *make) {
            //        __strong __typeof(weakSelf)strongSelf = weakSelf;
            make.width.mas_equalTo(XX_6(217));
            make.height.mas_equalTo(YY_6(52));
            make.centerX.offset(0);
            make.top.equalTo(la).offset(YY_6(58));
        }];
         __weak CRBoxInputView *weakBoxInputView = boxInputView;
        boxInputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            if(text.length == 4){
                if([text isEqualToString:minstr(code)]){
                    [strongSelf closeAction: NULL];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        if (strongSelf == nil) {
                            return;
                        }
                        [strongSelf realyPay];
                    });
                }else{
                    [weakBoxInputView clearAll];
                }
            }
            
        };
        boxInputView.frame = CGRectMake(10, la.y, 500, 200);
        
        UIButton *know = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:know];
        know.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        know.frame = CGRectMake(0, CGRectGetMaxY(la.frame) + 50, mainView.frame.size.width, 44);
        [know setTitle:YZMsg(@"public_close") forState:UIControlStateNormal];
        [know setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        [know addTarget:weakSelf action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        mainView.layer.masksToBounds = YES;
        mainView.layer.cornerRadius = 10;
        return know;
    })
    .wStart();
}

-(void)setHomeMode:(BOOL)isHomeMode{
    if(isHomeMode){
        self.navigationController.navigationBarHidden = YES;
        bHomeMode = true;
    }else{
        self.navigationController.navigationBarHidden = NO;
        bHomeMode = false;
    }
    if(self.returnBtn){
        self.returnBtn.hidden = bHomeMode;
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

- (void)doAlipayPay:(NSString*)orderString
{

    [MBProgressHUD showError:@"暂不支持，请联系客服"];
//    [[AlipaySDK defaultService] payOrder:orderString fromScheme:[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])] bundleIdentifier] callback:^(NSDictionary *resultDic) {
//        NSLog(@"reslut = %@",resultDic);
//        NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
//        NSLog(@"#######%ld",(long)resultStatus);
//        // NSString *publicKey = alipaypublicKey;
//        NSLog(@"支付状态信息---%ld---%@",(long)resultStatus,[resultDic valueForKey:@"memo"]);
//        // 是否支付成功
//        if (9000 == resultStatus) {
//            /*
//             *用公钥验证签名
//             */
//
//        }
//    }];
}

#pragma mark ================ socrollview代理 ===============
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y > 0){
        _topBalanceLayoutValue.constant = 10;
        _heightBalanceLayoutValue.constant = (84- scrollView.contentOffset.y*0.5)<60?60:(84- scrollView.contentOffset.y*0.5);
        _balanceTitleLabel.alpha = (1-scrollView.contentOffset.y/10);
        
    }else{
        _balanceTitleLabel.alpha = 1;
        _heightBalanceLayoutValue.constant = 84;
        _topBalanceLayoutValue.constant = 10-scrollView.contentOffset.y;
    }


}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}
- (IBAction)pushWithDraw:(id)sender {
    myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
    withdraw.titleStr = YZMsg(@"public_WithDraw");
    [[MXBADelegate sharedAppDelegate] pushViewController:withdraw animated:YES];
    [MobClick event:@"charge_country_withdraw_click" attributes:@{@"eventType": @(1)}];
}

- (IBAction)refreshBtnrefresh:(id)sender {
    [self refreshBalance];
}

-(void)refreshBalance{
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    [self startRotatingButton];
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf stopRotatingButton];
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            LiveUser *user = [Config myProfile];
            user.coin =  minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
            strongSelf.coinLab.text = [YBToolClass getRateBalance:user.coin showUnit:YES];
            
     
            NSString *balanceNum =  [infoDic valueForKey:@"balance"];
            NSString *noWithdrawAmount = minstr([infoDic valueForKey:@"noWithdrawAmount"]);
            
            NSDecimalNumber *subDecimal = [[NSDecimalNumber decimalNumberWithString:balanceNum] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:noWithdrawAmount]];
            NSString *balanceWithd = subDecimal.stringValue;
            if (strongSelf->amountVC && strongSelf->amountVC.currentViewType == 6) {
                strongSelf->amountVC.vippayCoinLab.text = [YBToolClass getRateCurrency:balanceWithd showUnit:YES];
                strongSelf->amountVC.vippayCoinLab.extraData = [YBToolClass getRateCurrencyWithoutK:balanceWithd];
            }

            if (strongSelf->reqVC) {
                strongSelf->reqVC.balanceQuota = balanceWithd;
            }
            
        }else{
            [MBProgressHUD showError:msg];
        }
        [MBProgressHUD hideHUD];
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
}


- (void)startRotatingButton {
    self.rotationStartDate = [NSDate date];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.refreshbalanceButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopRotatingButton {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.rotationStartDate];
    if (timeInterval < 1.0) {
        // 如果旋转时间少于1秒（即未完成一圈），则稍后再停止旋转
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1.0 - timeInterval) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            [strongSelf.refreshbalanceButton.layer removeAnimationForKey:@"rotationAnimation"];
        });
    } else {
        [self.refreshbalanceButton.layer removeAnimationForKey:@"rotationAnimation"];
    }
    
}


- (IBAction)pushListView:(id)sender {
    webH5 *web = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=Charge&a=index&uid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    
    web.urls = url;
    [self.navigationController pushViewController:web animated:YES];
    [MobClick event:@"charge_country_hostory_click" attributes:@{@"eventType": @(1)}];
}



@end
