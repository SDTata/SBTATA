#import "Livebroadcast.h"
/********************  TiFaceSDK添加 开始 ********************/
//#include "TiUIView.h"
//#include "TiUIManager.h"
//#include "TiSDKInterface.h"
/********************  TiFaceSDK添加 结束 ********************/

#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD+MJ.h"
#import "MNFloatBtn.h"
#import "OpenAwardViewController.h"
#import "UIButton+WebCache.h"
#import <Masonry/Masonry.h>
#import "BetConfirmViewController.h"

#import "LotteryBetViewController.h"
#import "UIImageView+WebCache.h"
#import "WMZDialog.h"
#ifdef LIVE
//#import "FUAPIDemoBar.h"
//#import "FUManager.h"
#import "FUDemoManager.h"
#import "ArchorSelectOrderListViewController.h"
#import "RemoteOrderModel.h"
#import "SearchToyVC.h"
#import <Lovense/Lovense.h>
#import "NodeMediaClient/NodeMediaClient.h"
#import "NodePublisher+PublisherCustom.h"
#endif

#import "TopTodayView.h"
#import "LotteryBarrageView.h"
#import "LotteryAwardVController.h"
#import "LotteryBetViewController_NN.h"
#import "LotteryBetViewController_YFKS.h"
#import "ButtonTouchScrollView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "RandomRule.h"
#import "LiveEncodeCommon.h"
#import "LotteryBetViewController_BJL.h"
#import "LotteryBetViewController_ZP.h"
#import "LotteryBetViewController_ZJH.h"
#import "LotteryBetViewController_LH.h"
#import "LotteryBetViewController_LB.h"
#import "LotteryBetViewController_SC.h"
#import "LotteryBetViewController_LHC.h"
#import "LotteryBetViewController_SSC.h"
#import "LotteryBetViewController_NNN.h"
#import "EditContactInfo.h"
#import "RemoteInterfaceView.h"
#import "UUMarqueeView.h"
//#import "liwuview.h"
#import "setViewM.h"
#import "AnchorNoticeEditAlertView.h"
#import "VKButton.h"
#import "AnchorSelectGameCell.h"
#import "UITextView+JKPlaceHolder.h"
#import "AnchorCardEditAlertView.h"
#import "AnchorLovenseEditAlertView.h"
#import "AnchorCmdListAlertView.h"
#import "AnchorRoomEditAlertView.h"


#define upViewW  _window_width*0.8
@import CoreTelephony;
@interface Livebroadcast ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,catSwitchDelegate,haohuadelegate,socketLiveDelegate,listDelegate,upmessageKickAndShutUp,listDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,adminDelegate,guardShowDelegate,redListViewDelegate,lotteryBetViewDelegate, NodePlayerDelegate//, sendGiftDelegate
#ifdef LIVE
,NodePublisherCustomDelegate,NodePublisherDelegate
, ArchorSelectOrderListViewControllerDelegate, OBSViewControllerDelegate, RemoteInterfaceViewDelegate
#endif
,LotteryBarrageDelegate>

#define _tableViewTop  _window_height - _window_height*0.35 - 40 - 50 - ShowDiff
#define _tableViewBottom  _window_height - 50 - ShowDiff -40
{
    //BOOL giftViewShow;//是否显示礼物view
    BOOL isShowingMore;
    //liwuview *giftview;//礼物界面
    NSDictionary *guardInfo;
    UIScrollView *backScrollView;//
    setViewM *setFrontV;//页面UI
    SwitchLotteryViewController *curSwitchLotteryVC;
    // 横向 跑马灯
    UUMarqueeView *_horizontalMarquee;
    CGFloat listcollectionviewx;//用户列表的x
    
    LotteryBarrageView *lotteryView;
    
    NSMutableArray *msgList;
    NSMutableArray *messageList;  // 非用户消息
    //    NSMutableArray *joinMsgList;
    CGSize roomsize;
    UILabel *roomID;
    UIView *bgmView;
    //预览的视图
    SDAnimatedImageView *preThumbImgV;//上传封面按钮
    UILabel *thumbLabel;//上传封面状态的label
  
    UITextView *liveTitleTextView;
    
    VKButton *preTypeBtn;
    UIScrollView *roomTypeView;//选择房间类型
    NSMutableArray *roomTypeBtnArray;//房间类型按钮
    NSString *roomType;//房间类型
    NSString *roomTypeValue;//房间价值
    
    NSString *liveClassID;
    NSString *lotteryType;
    UIView *preMiddleView;
    NSArray *lotteryList;

    // 彩票信息
    NSMutableDictionary *lotteryInfo;
    // 彩票定时器
    NSTimer *lotteryTime;
    NSInteger standTickCount;
    NSInteger openedTickCount;
    NSInteger runTickCount;
    // 最后请求同步彩票信息时间
    NSMutableDictionary *lastSyncLotteryTimeDict;
    // 最后一次显示开奖信息时间
    NSDate *lastShowOpenAward;
    // 最后一次同步在线状态
    NSDate *lastSyncLiveStatus;
    
    LotteryBetViewController *curLotteryBetVC;
    //预览的视图结束
    //直播时长
    UIView *liveTimeBGView;
    UILabel *liveTimeLabel;
    int liveTime;
    NSTimer *liveTimer;
    BOOL isTorch;
    BOOL isQie;
    NSString *typesc;
    CGFloat lastOpenedHeight; /// 记录上次视图尺寸
    NSMutableArray *lastOpenedIssues; /// 查重复
    ///新消息提醒
    UIButton *newMsgButton;
    NSInteger contactPriceNum;
    UIButton *hidenAdvBtn;
    DataForUpload *dataUpload;
    LotteryAwardVController *lotteryAwardVC;
    BOOL showAwardVC;
    NSTimeInterval timeLimitNumber;
    NSTimeInterval timeLimitNumberUser;
#ifdef LIVE
    BOOL isConnectLovense;
    // 連接/未連接
    UILabel *isConnectLabel;
    // 所選擇的指令陣列
    NSArray<RemoteOrderModel*> *selectedOrderListModels;
    BOOL isOBSStart;
#endif
}
/********************  美颜SDK添加 开始 ********************/
#ifdef LIVE
//@property (strong, nonatomic) FUAPIDemoBar *demoBar;
//@property (strong, nonatomic) BeautyMenuView *beautyView;
@property (nonatomic, assign) BOOL isOBS;
// OBS view
@property (strong,nonatomic) OBSViewController *obsInfoView;
// lovense
//@property(nonatomic,strong) NSMutableArray<LovenseToy*> * allConnectedToys;
@property(nonatomic,assign) LovenseToy *connectedToy;
#endif
/* 比对按钮 */
@property (strong, nonatomic) UIButton *compBtn;
/* 是否开启比对 */
@property (assign, nonatomic) BOOL openComp;

@property(nonatomic,strong)UIButton *filterButtonClose;
/******************** TiFaceSDK添加 结束 ********************/
@property (nonatomic,strong)UIView *preFrontView;
//@property(nonatomic, strong) GPUImageView *gpuPreviewView;
//@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
//@property (nonatomic, strong) CIImage *outputImage;
//@property (nonatomic, assign) size_t outputWidth;
//@property (nonatomic, assign) size_t outputheight;
@property(nonatomic,strong)NSMutableArray *lotteryBarrageArrays;
@property (strong,nonatomic) NodePlayer *nplayer;
@property(nonatomic, strong) RemoteInterfaceView *remoteInterfaceView;

@property(nonatomic,strong) UIView *showMoreMessageView;//外链
@property(nonatomic,assign) BOOL isLotteryBetView;  // 投注界面是否在展示
@property(nonatomic,strong)UIButton *speedButton;      //网速
@property(nonatomic,strong)VKBaseCollectionView *gameTableView;
@property (assign, nonatomic) BOOL orderSwitchStatus;
@property (assign, nonatomic) BOOL toySwitchStatus;
@property (nonatomic, strong) dispatch_queue_t messageQueue;
@end
@implementation Livebroadcast

#ifdef LIVE

#pragma mark ================ tiuivew代理 ===============

- (VKBaseCollectionView *)gameTableView {
    if (!_gameTableView) {
        _gameTableView = [VKBaseCollectionView new];
        _gameTableView.viewStyle = VKCollectionViewStyleHorizontal;
        _gameTableView.registerCellClass = [AnchorSelectGameCell class];
        
        @weakify(self)
        _gameTableView.didSelectCellBlock = ^(NSIndexPath *indexPath, VKActionModel *item) {
            @strongify(self)
            [self.gameTableView selectIndexPath:indexPath key:@"selected"];
            self->lotteryType = item.value;
        };
    }
    return _gameTableView;
}

-(void)showPreFrontView{
    if (_preFrontView) {
        _preFrontView.hidden = NO;
    }

//    if (_beautyView) {
//        _beautyView.hidden = YES;
//    }
//    [FURenderer onCameraChange];
    
    [FUDemoManager.shared hideDemoView];

    if (_compBtn) {
        _compBtn.hidden = YES;
    }
    if (_filterButtonClose) {
        _filterButtonClose.hidden = YES;
    }
    
    
}

#pragma mark ================ 直播开始之前的预览 ===============
- (void)creatPreFrontView{
    WeakSelf
    _preFrontView = [[UIView alloc] init];
    _preFrontView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_preFrontView];
    [_preFrontView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePreTextView)];
    [_preFrontView addGestureRecognizer:tap];
    
    UIButton *preCloseBtn = [UIButton buttonWithType:0];
    [preCloseBtn setImage:[ImageBundle imagewithBundleName:@"live_close"] forState:0];
    [preCloseBtn addTarget:self action:@selector(doClosePreView) forControlEvents:UIControlEventTouchUpInside];
    [_preFrontView addSubview:preCloseBtn];
    [preCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
        make.right.equalTo(weakSelf.view).offset(-10);
        make.size.equalTo(@30);
    }];

    // 中間畫面
    preMiddleView = [[UIView alloc] init];
    preMiddleView.backgroundColor = UIColor.clearColor;
    preMiddleView.layer.cornerRadius = 10;
    [_preFrontView addSubview:preMiddleView];
    [preMiddleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop).offset(AD(80));
        make.left.right.equalTo(weakSelf.view).inset(10);
    }];
    
    UIView *backMaskView1 = [UIView new];
    backMaskView1.backgroundColor = RGB_COLOR(@"#0000000", 0.3);
    [backMaskView1 vk_border:nil cornerRadius:5];
    [preMiddleView addSubview:backMaskView1];
    [backMaskView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(AD(70)+20);
    }];
    
    UIView *backMaskView2 = [UIView new];
    backMaskView2.backgroundColor = RGB_COLOR(@"#0000000", 0.3);
    [backMaskView2 vk_border:nil cornerRadius:5];
    [preMiddleView addSubview:backMaskView2];
    [backMaskView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(backMaskView1.mas_bottom).offset(10);
        make.bottom.mas_equalTo(0);
    }];

    // 封面
    preThumbImgV = [SDAnimatedImageView new];
    preThumbImgV.contentMode = UIViewContentModeScaleAspectFill;
    preThumbImgV.image = [ImageBundle imagewithBundleName:@"avataropenlive"];
    preThumbImgV.userInteractionEnabled = YES;
    [preThumbImgV vk_addTapAction:self selector:@selector(doUploadPicture)];
    preThumbImgV.layer.cornerRadius = 5.0;
    preThumbImgV.layer.masksToBounds = YES;
    [preMiddleView addSubview:preThumbImgV];
    [preThumbImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(preMiddleView.mas_top).offset(10);
        make.left.equalTo(preMiddleView.mas_left).offset(10);
        make.size.equalTo(@(AD(70)));
    }];

    // 封面內 - 直播標題
    thumbLabel = [[UILabel alloc] init];
    thumbLabel.textColor = UIColor.whiteColor;
    thumbLabel.backgroundColor = RGB_COLOR(@"#0000000", 0.3);
    thumbLabel.textAlignment = NSTextAlignmentCenter;
    thumbLabel.text = YZMsg(@"Livebroadcast_live_cover");
    thumbLabel.font = [UIFont systemFontOfSize:13];
    thumbLabel.adjustsFontSizeToFitWidth = YES;
    thumbLabel.minimumScaleFactor = 0.5;
    thumbLabel.numberOfLines = 2;
    [preThumbImgV addSubview:thumbLabel];
    [thumbLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(preThumbImgV);
        make.bottom.equalTo(preThumbImgV);
        make.height.mas_equalTo(18);
    }];

    // 给直播写个标题吧
    liveTitleTextView = [[UITextView alloc]init];
    liveTitleTextView.delegate = self;
    liveTitleTextView.font = [UIFont systemFontOfSize:20];
    liveTitleTextView.textColor = [UIColor whiteColor];
    liveTitleTextView.backgroundColor = [UIColor clearColor];
    liveTitleTextView.textContainerInset = UIEdgeInsetsZero;
    [liveTitleTextView jk_addPlaceHolder:YZMsg(@"Livebroadcast_live_title_tip")];
    liveTitleTextView.jk_placeHolderTextView.textColor = UIColor.whiteColor;
    [preMiddleView addSubview:liveTitleTextView];
    [liveTitleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(preThumbImgV.mas_right).offset(10);
        make.top.equalTo(preThumbImgV.mas_top).offset(4);
        make.right.equalTo(preMiddleView).offset(-4);
        make.height.equalTo(@(AD(80 * 0.6)));
    }];

    // 推送名片：
    UILabel *contactPriceLabel = [[UILabel alloc]init];
    contactPriceLabel.tag = 1211110;
    contactPriceLabel.font = [UIFont systemFontOfSize:15];
    contactPriceLabel.userInteractionEnabled = YES;
    contactPriceLabel.textColor = [UIColor whiteColor];
    contactPriceLabel.text = [NSString stringWithFormat:@"%@",YZMsg(@"Livebroadcast_push_card")];
    contactPriceLabel.adjustsFontSizeToFitWidth = YES;
    contactPriceLabel.minimumScaleFactor = 0.5;
    [preMiddleView addSubview:contactPriceLabel];
    UITapGestureRecognizer *tapPriceContact1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureContactPrice)];
    [contactPriceLabel addGestureRecognizer:tapPriceContact1];
    [contactPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(liveTitleTextView.mas_bottom).offset(4);
        make.left.equalTo(liveTitleTextView.mas_left);
    }];

    // 不推送
    UILabel *contactActionLabel = [[UILabel alloc]init];
    contactActionLabel.tag = 1211111;
    contactActionLabel.userInteractionEnabled = YES;
    contactActionLabel.font = [UIFont systemFontOfSize:15];
    contactActionLabel.textColor = vkColorHex(0xFF63AC);
    contactActionLabel.text = [NSString stringWithFormat:@"%@",YZMsg(@"Livebroadcast_Nopush_card")];
    [preMiddleView addSubview:contactActionLabel];
    UITapGestureRecognizer *tapPriceContact = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureContactPrice)];
    [contactActionLabel addGestureRecognizer:tapPriceContact];
    [contactActionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contactPriceLabel.mas_right).offset(4);
        make.centerY.equalTo(contactPriceLabel);
    }];
    
    VKButton *noticeButton = [VKButton buttonWithType:UIButtonTypeCustom];
    [noticeButton vk_button:@"公告设置" image:@"live_arrow_white" font:vkFont(12) color:UIColor.whiteColor];
    noticeButton.imageSize = CGSizeMake(10, 10);
    noticeButton.imagePosition = VKButtonImagePositionRight;
    [noticeButton vk_addTapAction:self selector:@selector(clickNoticeAction)];
    [preMiddleView addSubview:noticeButton];
    [noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(contactPriceLabel.mas_centerY);
    }];
    
    VKButton *gameButton = [VKButton buttonWithType:UIButtonTypeCustom];
    [gameButton vk_button:@"选择游戏" image:@"live_game_edit" font:vkFont(14) color:UIColor.whiteColor];
    gameButton.imageSize = CGSizeMake(12, 12);
    gameButton.imagePosition = VKButtonImagePositionLeft;
    gameButton.spacingBetweenImage = 0;
    gameButton.userInteractionEnabled = NO;
    [preMiddleView addSubview:gameButton];
    [gameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backMaskView2.mas_left).offset(4);
        make.top.mas_equalTo(backMaskView2.mas_top).offset(8);
        make.height.mas_equalTo(20);
    }];
    
    [preMiddleView addSubview:self.gameTableView];
    [self.gameTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backMaskView2.mas_left).offset(8);
        make.top.mas_equalTo(gameButton.mas_bottom).offset(6);
        make.right.mas_equalTo(backMaskView2.mas_right).offset(-8);
        make.height.mas_equalTo(AnchorSelectGameCell.itemHeight);
        make.bottom.mas_equalTo(backMaskView2.mas_bottom).offset(-8);
    }];
    [self getLotteryList];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [_preFrontView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-VK_BOTTOM_H-180);
    }];
    
    VKButton *switchBtn = [VKButton buttonWithType:0];
    [switchBtn setTitle:@"翻转" forState:0];
    [switchBtn setImage:[ImageBundle imagewithBundleName:@"pre_camer"] forState:0];
    switchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [switchBtn addTarget:self action:@selector(rotateCamera) forControlEvents:UIControlEventTouchUpInside];
    switchBtn.imagePosition = VKButtonImagePositionTop;
    switchBtn.spacingBetweenImage = 5;
    [stackView addArrangedSubview:switchBtn];
    
    //美颜
    VKButton *preFitterBtn = [VKButton buttonWithType:0];
    [preFitterBtn setTitle:YZMsg(@"bottombuttonv_beauty") forState:0];
    [preFitterBtn setImage:[ImageBundle imagewithBundleName:@"pre_fitter"] forState:0];
    preFitterBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [preFitterBtn addTarget:self action:@selector(showFitterView) forControlEvents:UIControlEventTouchUpInside];
    preFitterBtn.imagePosition = VKButtonImagePositionTop;
    preFitterBtn.spacingBetweenImage = 5;
    [stackView addArrangedSubview:preFitterBtn];
    
    //房间类型
    preTypeBtn = [VKButton buttonWithType:0];
    [preTypeBtn setTitle:YZMsg(@"Livebroadcast_room_type") forState:0];
    [preTypeBtn setImage:[ImageBundle imagewithBundleName:@"pre_room"] forState:0];
    preTypeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [preTypeBtn addTarget:self action:@selector(dochangelivetype) forControlEvents:UIControlEventTouchUpInside];
    preTypeBtn.imagePosition = VKButtonImagePositionTop;
    preTypeBtn.spacingBetweenImage = 5;
    [stackView addArrangedSubview:preTypeBtn];
    
    // 跳蛋
    VKButton *toyFitterBtn = [VKButton buttonWithType:0];
    [toyFitterBtn setTitle:YZMsg(@"bottombuttonv_toy") forState:0];
    [toyFitterBtn setImage:[ImageBundle imagewithBundleName:@"pre_toy"] forState:0];
    toyFitterBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [toyFitterBtn addTarget:self action:@selector(showToyConnectView) forControlEvents:UIControlEventTouchUpInside];
    toyFitterBtn.imagePosition = VKButtonImagePositionTop;
    toyFitterBtn.spacingBetweenImage = 5;
    [stackView addArrangedSubview:toyFitterBtn];
    
    // 連接/未連接
    isConnectLabel = [[UILabel alloc] init];
    isConnectLabel.textColor = [UIColor redColor];
    isConnectLabel.text = [NSString stringWithFormat:@"● %@", YZMsg(@"live_toy_close")];
    isConnectLabel.font = [UIFont systemFontOfSize:12];
    [_preFrontView addSubview:isConnectLabel];
    [isConnectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(toyFitterBtn.mas_top).offset(-10);
        make.centerX.equalTo(toyFitterBtn.mas_centerX).offset(0);
    }];
    
    // 指令
    VKButton *orderFitterBtn = [VKButton buttonWithType:0];
    [orderFitterBtn setTitle:YZMsg(@"bottombuttonv_order") forState:0];
    [orderFitterBtn setImage:[ImageBundle imagewithBundleName:@"pre_cmd"] forState:0];
    orderFitterBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [orderFitterBtn addTarget:self action:@selector(showOrderListView) forControlEvents:UIControlEventTouchUpInside];
    orderFitterBtn.imagePosition = VKButtonImagePositionTop;
    orderFitterBtn.spacingBetweenImage = 5;
    [stackView addArrangedSubview:orderFitterBtn];
    
    //开播按钮
    UIButton *startLiveBtn = [UIButton buttonWithType:0];
    startLiveBtn.layer.cornerRadius = 25.0;
    startLiveBtn.layer.masksToBounds = YES;
    [startLiveBtn addTarget:self action:@selector(doHidden:) forControlEvents:UIControlEventTouchUpInside];
    [startLiveBtn setTitle:YZMsg(@"Livebroadcast_begain_live") forState:0];
    startLiveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_preFrontView addSubview:startLiveBtn];
    [startLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_preFrontView).inset(10);
        make.height.equalTo(@50);
        make.bottom.mas_equalTo(-VK_BOTTOM_H-100);
    }];
    startLiveBtn.horizontalColors = @[vkColorHex(0xFF63AC), vkColorHex(0xFF838E)];

    // OBS推流直播
    UIButton *obsPushBtn = [UIButton buttonWithType:0];
    obsPushBtn.layer.cornerRadius = 25.0;
    obsPushBtn.layer.masksToBounds = YES;
    obsPushBtn.layer.borderWidth = 1.0;
    obsPushBtn.layer.borderColor = vkColorHex(0xFF63AC).CGColor;
    [obsPushBtn addTarget:self action:@selector(showOBSView) forControlEvents:UIControlEventTouchUpInside];
    [obsPushBtn setTitle:YZMsg(@"Livebroadcast_OBS_live") forState:0];
    obsPushBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [obsPushBtn setTitleColor:vkColorHex(0xFF63AC) forState:UIControlStateNormal];
    [_preFrontView addSubview:obsPushBtn];
    [obsPushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_preFrontView).inset(10);
        make.height.equalTo(@50);
        make.top.equalTo(startLiveBtn.mas_bottom).offset(24);
    }];
}

- (void)clickNoticeAction {
    AnchorNoticeEditAlertView *view = [AnchorNoticeEditAlertView new];
    [view showFromBottom];
}

-(void)tapGestureContactPrice{
    AnchorCardEditAlertView *view = [AnchorCardEditAlertView new];
    [view showFromBottom];
    
    WeakSelf
    view.selectPriceBlock = ^(NSInteger index, NSString *title) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->contactPriceNum = index;
        UILabel *contactActionLabel = [strongSelf->preMiddleView viewWithTag:1211111];
        contactActionLabel.text = title;
    };
}
-(void)getLotteryList{
    NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getLotteryList&uid=%@&token=%@&type=live",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"xxxxxxxxx%@",info);
        if(code == 0)
        {
            NSLog(@"%@",info);
            NSDictionary *dict = [info firstObject];
            strongSelf->lotteryList = dict[@"lotteryList"];
            if (dict[@"defaultLotteryType"]) {
                strongSelf ->lotteryType = minstr(dict[@"defaultLotteryType"]);
            }
            
            [common savelotterycontroller:strongSelf->lotteryList];
            dispatch_main_async_safe(^{
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf refreshLotterySelectBtn];
            });
        }
        else{
            if ([common getlotteryc]) {
                strongSelf->lotteryList = [common getlotteryc];
                dispatch_main_async_safe(^{
                    if (strongSelf == nil) {
                        return;
                    }
                    [strongSelf refreshLotterySelectBtn];
                });
            }
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if ([common getlotteryc]) {
            strongSelf->lotteryList = [common getlotteryc];
            dispatch_main_async_safe(^{
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf refreshLotterySelectBtn];
            });
        }
        
    }];
}
-(void)refreshLotterySelectBtn{
    NSMutableArray *results = [NSMutableArray array];
    if ([lotteryList isKindOfClass:[NSArray class]] && lotteryList.count>0) {
        for (int i = 0; i<lotteryList.count; i++) {
            NSDictionary *dict = lotteryList[i];
            NSString *type = minstr(dict[@"lotteryType"]);
            if([type integerValue] > 0){
                VKActionModel *model = [VKActionModel new];
                model.title = dict[@"name"];
                model.icon = dict[@"logo"];
                model.value = type;
                model.selected = [lotteryType isEqualToString:type];
                [results addObject:model];
            }
        }
    }
    self.gameTableView.dataItems = results;
    [self.gameTableView reloadData];
}

-(void)dochangelivetype{
    NSArray *arrays = [common live_type];
    NSMutableArray *roomTypeArr = [NSMutableArray array];
    
    for (NSArray *arr in arrays) {
        NSString *typestring = arr[0];
        int types = [typestring intValue];
        switch (types) {
            case 0:
                [roomTypeArr addObject:YZMsg(@"Livebroadcast_room_type_nomal")];
                break;
            case 1:
                [roomTypeArr addObject:YZMsg(@"Livebroadcast_room_type_pwd")];
                break;
            case 2:
                [roomTypeArr addObject:YZMsg(@"Livebroadcast_room_type_tickets")];
                break;
            case 3:
                [roomTypeArr addObject:YZMsg(@"Livebroadcast_room_type_time")];
                break;
            default:
                break;
        }
    }
    if (!roomTypeView) {
        roomTypeView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height*0.15)];
        roomTypeView.backgroundColor = RGB_COLOR(@"#000000", 0.7);
        roomTypeView.contentSize = CGSizeMake(_window_width/4*roomTypeArr.count, 0);
        [_preFrontView addSubview:roomTypeView];
        CGFloat speace;
        if (roomTypeArr.count > 3) {
            speace = 0;
        }else{
            speace = (_window_width-_window_width/4*roomTypeArr.count)/2;
        }
        roomTypeBtnArray = [NSMutableArray array];
        for (int i = 0; i < roomTypeArr.count; i++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(speace+i*_window_width/4, 0, _window_width/4, roomTypeView.height);
            [btn addTarget:self action:@selector(doRoomType:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:[NSString stringWithFormat:@"%@%@",YZMsg(roomTypeArr[i]),YZMsg(@"Livebroadcast_room")] forState:UIControlStateSelected];
            [btn setTitle:[NSString stringWithFormat:@"%@%@",YZMsg(roomTypeArr[i]),YZMsg(@"Livebroadcast_room")] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:normalColors forState:UIControlStateSelected];
            
            if ([roomTypeArr[i] isEqualToString:YZMsg(@"Livebroadcast_room_type_nomal")]) {
                [btn setImage:[ImageBundle imagewithBundleName:@"room_nom_nor"] forState:UIControlStateNormal];
                [btn setImage:[ImageBundle imagewithBundleName:@"room_nom_sel"] forState:UIControlStateSelected];
            }else if ([roomTypeArr[i] isEqualToString:YZMsg(@"Livebroadcast_room_type_pwd")]){
                [btn setImage:[ImageBundle imagewithBundleName:@"room_pwd_nor"] forState:UIControlStateNormal];
                [btn setImage:[ImageBundle imagewithBundleName:@"room_pwd_sel"] forState:UIControlStateSelected];
            }else if ([roomTypeArr[i] isEqualToString:YZMsg(@"Livebroadcast_room_type_tickets")]){
                [btn setImage:[ImageBundle imagewithBundleName:@"room_tiket_nor"] forState:UIControlStateNormal];
                [btn setImage:[ImageBundle imagewithBundleName:@"room_tiket_sel"] forState:UIControlStateSelected];
            }else if ([roomTypeArr[i] isEqualToString:YZMsg(@"Livebroadcast_room_type_time")]){
                [btn setImage:[ImageBundle imagewithBundleName:@"room_timer_nor"] forState:UIControlStateNormal];
                [btn setImage:[ImageBundle imagewithBundleName:@"room_timer_sel"] forState:UIControlStateSelected];
            }
            
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            btn.imageEdgeInsets = UIEdgeInsetsMake(7.5, _window_width/8-10, 22.5, 10);
            btn.titleEdgeInsets = UIEdgeInsetsMake(30, -22.5, 0, 0);
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            btn.titleLabel.minimumScaleFactor = 0.5;
            if (i == 0) {
                btn.selected = YES;
            }else{
                btn.selected = NO;
            }
            [roomTypeView addSubview:btn];
            [roomTypeBtnArray addObject:btn];
        }
        WeakSelf
        [UIView animateWithDuration:0.5 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->roomTypeView.y = _window_height*0.85;
        }];
    }else{
        WeakSelf
        [UIView animateWithDuration:0.5 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->roomTypeView.y = _window_height*0.85;
        }];
    }
}
#pragma mark=================房间类型==========================
- (void)doRoomType:(UIButton *)sender{
    NSLog(@"%@",sender.titleLabel.text);
    if ([sender.titleLabel.text isEqual:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_nomal"),YZMsg(@"Livebroadcast_room")]]) {
        [self changeRoomBtnState:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_nomal"),YZMsg(@"Livebroadcast_room")]];
        roomType = @"0";
        roomTypeValue = @"0";
    }
    if ([sender.titleLabel.text isEqual:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_pwd"),YZMsg(@"Livebroadcast_room")]]) {
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"Livebroadcast_please_set_room_pwd")    message:@"" preferredStyle:UIAlertControllerStyleAlert];
        WeakSelf
        [alertContro addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            textField.placeholder = YZMsg(@"EnterLivePlay_input_pwd");
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.secureTextEntry = true;
            [textField addTarget:strongSelf action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
              
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertContro addAction:cancleAction];
       
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            UITextField *envirnmentNameTextField = alertContro.textFields.firstObject;
            if (envirnmentNameTextField.text == nil || envirnmentNameTextField.text == NULL || envirnmentNameTextField.text.length == 0 || envirnmentNameTextField.text.length > 8) {
                [MBProgressHUD showError:YZMsg(@"Livebroadcast_please_enter_right_pwd")];
                if (strongSelf.presentedViewController == nil) {
                    [strongSelf presentViewController:alertContro animated:YES completion:nil];
                }
                
            }else{
                strongSelf ->roomTypeValue = envirnmentNameTextField.text;
                strongSelf ->roomType = @"1";
                [strongSelf changeRoomBtnState:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_pwd"),YZMsg(@"Livebroadcast_room")]];
            }
        }];
        [alertContro addAction:sureAction];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertContro animated:YES completion:nil];
        }
    }
    if ([sender.titleLabel.text isEqual:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_tickets"),YZMsg(@"Livebroadcast_room")]]) {
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"Livebroadcast_please_set_ticket_price")    message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertContro addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {                textField.placeholder = YZMsg(@"Livebroadcast_please_enterPrice");
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertContro addAction:cancleAction];
        WeakSelf
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            UITextField *envirnmentNameTextField = alertContro.textFields.firstObject;
            if (envirnmentNameTextField.text == nil || envirnmentNameTextField.text == NULL || envirnmentNameTextField.text.length == 0) {
                [MBProgressHUD showError:YZMsg(@"Livebroadcast_please_rightTicket_price")];
                if (strongSelf.presentedViewController == nil) {
                    [strongSelf presentViewController:alertContro animated:YES completion:nil];
                }
                
            }else{
                NSString *rmbCoin = [YBToolClass getRmbCurrency:envirnmentNameTextField.text];
                strongSelf->roomTypeValue = rmbCoin;
                strongSelf->roomType = @"2";
                [strongSelf changeRoomBtnState:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_tickets"),YZMsg(@"Livebroadcast_room")]];
            }
        }];
        [alertContro addAction:sureAction];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertContro animated:YES completion:nil];
        }
    }
    if ([sender.titleLabel.text isEqual:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_time"),YZMsg(@"Livebroadcast_room")]]) {
        [self doupcoast];
    }
}

// 监听输入变化
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 8) {
        textField.text = [textField.text substringToIndex:8]; // 截取前8位
    }
}

- (void)changeRoomBtnState:(NSString *)roomName{
    for (UIButton *btn  in roomTypeBtnArray) {
        if ([btn.titleLabel.text isEqual:roomName]) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->roomTypeView.y = _window_height*2;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->preTypeBtn setTitle:roomName forState:0];
    }];
    
}
- (void)showFitterView{
    _preFrontView.hidden = YES;
    [self initTiFaceUI];//美颜相芯科技
    
}
//创建房间
-(void)createroom{
    if (frontView!=nil) {
        return;
    }
    [MBProgressHUD hideHUD];
    NSString *title = liveTitleTextView.text;
    NSString *priceCont = @"0";
    if ([common getContactPrice]!= nil && [common getContactPrice].count>0) {
        priceCont = minstr([common getContactPrice][contactPriceNum]);
    }
    [GlobalDate setLiveUID:[[Config getOwnID] integerValue]];
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingString:@"?service=Live.createRoom"];
    NSMutableDictionary *pDic = [NSMutableDictionary dictionary];
    [pDic setObject:[Config getOwnNicename] forKey:@"user_nicename"];
//    [pDic setObject:[Config getavatar] forKey:@"avatar"];
//    [pDic setObject:[Config getavatarThumb] forKey:@"avatar_thumb"];
    [pDic setObject:title forKey:@"title"];
    [pDic setObject:@"" forKey:@"province"];
    [pDic setObject:[cityDefault getMyCity] forKey:@"city"];
    
    if (priceCont.length>0) {
        [pDic setObject:priceCont forKey:@"contactCost"];
    }
    
    [pDic setObject:roomType forKey:@"type"];
    [pDic setObject:roomTypeValue forKey:@"type_val"];
    [pDic setObject:liveClassID forKey:@"liveclassid"];
    [pDic setObject:lotteryType forKey:@"lotteryType"];
    [pDic setObject:minnum([LiveEncodeCommon sharedInstance].isOpenEncode) forKey:@"encryption"];
    
    if ([common getAnchorNoticeSwitch]) {
        pDic[@"slogan"] = [common getAnchorNoticeText];
        pDic[@"interval_seconds"] = [common getAnchorNoticeTime];
    }
    
    WeakSelf
    [pDic setObject:minnum(self.isOBS) forKey:@"is_obs"];
    // 如果有選擇玩具，判斷是否有連線
    if (self.toySwitchStatus) {
        if (!self.connectedToy.isConnected) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:YZMsg(@"Livebroadcast_toy_unconnect") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:YZMsg(@"Livebroadcast_order_confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf showToyConnectView];
            }];
            [alertVc addAction:cancelBtn];
            [self presentViewController:alertVc animated:YES completion:nil];
            return;
        }
    }
    [pDic setObject:minnum(self.toySwitchStatus) forKey:@"supportVibrator"];

    // 如果有選擇指令，判斷是否有選擇指令
    if (self.orderSwitchStatus) {
        NSMutableArray *orderIds = [NSMutableArray array];
        NSMutableArray *userOrderIds = [NSMutableArray array];
        for (int i = 0; i<selectedOrderListModels.count; i++) {
            RemoteOrderModel *model = selectedOrderListModels[i];
            if (model.cmdType.integerValue == 1) {
                [userOrderIds addObject:model.ID];
            } else {
                [orderIds addObject:model.ID];
            }
        }
        if (orderIds.count <= 0 && userOrderIds.count <= 0) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:YZMsg(@"Livebroadcast_order_unselect") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:YZMsg(@"Livebroadcast_order_confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf showOrderListView];
            }];
            [alertVc addAction:cancelBtn];
            [self presentViewController:alertVc animated:YES completion:nil];
            return;
        }

        [pDic setObject:[orderIds componentsJoinedByString:@","] forKey:@"cmdList"];
        [pDic setObject:[userOrderIds componentsJoinedByString:@","] forKey:@"userCmdList"];
    }
    
    [MBProgressHUD showMessage:@""];
    [[YBNetworking sharedManager]postNetworkWithUrl:url withBaseDomian:NO andParameter:pDic data:dataUpload success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        if (code == 0) {
            if (strongSelf->frontView!=nil) {
                return;
            }
            NSDictionary *info = [infos firstObject];
            NSString *coin = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_coin"]];
            NSString *game_banker_limit = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_limit"]];
            NSString *uname = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_name"]];
            NSString *uhead = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_avatar"]];
            NSString *uid = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_bankerid"]];
            NSDictionary *zhuangdic = @{
                @"coin":coin,
                @"game_banker_limit":game_banker_limit,
                @"user_nicename":uname,
                @"avatar":uhead,
                @"id":uid
            };
        
            NSString *agorakitid = [NSString stringWithFormat:@"%@",[info valueForKey:@"agorakitid"]];
            [common saveagorakitid:agorakitid];//保存声网ID
            //保存靓号和vip信息
            hotModel *model = [hotModel mj_objectWithKeyValues:info];
            NSDictionary *ep = [info objectForKey:@"ep"];
            if ([ep isKindOfClass:[NSDictionary class]]) {
                BOOL enableEn = [[ep objectForKey:@"enable"] boolValue];
                BOOL flip = [[ep objectForKey:@"flip"] boolValue];
                BOOL bitwise_not = [[ep objectForKey:@"bitwise_not"] boolValue];
                int column = [[ep objectForKey:@"column"] intValue];
                int line = [[ep objectForKey:@"line"] intValue];
                int bitrate = [[ep objectForKey:@"bitrate"] intValue];
                
                [LiveEncodeCommon sharedInstance].enableEn = enableEn;
                [LiveEncodeCommon sharedInstance].flip = flip;
                [LiveEncodeCommon sharedInstance].bitwise_not = bitwise_not;
                [LiveEncodeCommon sharedInstance].column = column;
                [LiveEncodeCommon sharedInstance].line = line;
                [LiveEncodeCommon sharedInstance].bitrate = bitrate;
                
            }
            
            if ([LiveEncodeCommon sharedInstance].isOpenEncode && ![LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
                //                NSString *randomEnCodeStr = [RandomRule randomWithColumn:[LiveEncodeCommon sharedInstance].column Line:[LiveEncodeCommon sharedInstance].line seeds:[[Config getOwnID] intValue] others:nil];
                //                [strongSelf.gpuStreamers setColumn:[LiveEncodeCommon sharedInstance].column Line:[LiveEncodeCommon sharedInstance].line flip: [LiveEncodeCommon sharedInstance].flip bitwise_not:[LiveEncodeCommon sharedInstance].bitwise_not RandomRuleString:randomEnCodeStr];
            }
            
            NSDictionary *liang = model.liang;
            NSString *liangnum = minstr([liang valueForKey:@"name"]);
            NSDictionary *vip = model.vip;
            NSString *type = minstr([vip valueForKey:@"type"]);
            NSDictionary *subdic = [NSDictionary dictionaryWithObjects:@[type,liangnum] forKeys:@[@"vip_type",@"liang"]];
            [Config saveVipandliang:subdic];
            NSString *auction_switch = minstr([info valueForKey:@"auction_switch"]);//竞拍开关
            NSArray *game_switch = model.game_switch;//游戏开关
            strongSelf.type = [strongSelf->roomType intValue];
            strongSelf.shut_time = model.shut_time;
            strongSelf.roomModel = model;
            if (strongSelf.type == 0 || strongSelf.type == 2) {
                strongSelf.canFee = YES;
            }else{
                strongSelf.canFee = NO;
            }
            strongSelf.auction_switch = auction_switch;
            strongSelf.game_switch = game_switch;
            strongSelf.zhuangDic = zhuangdic;
            //移除预览UI
            [strongSelf.preFrontView removeFromSuperview];
            strongSelf.preFrontView = nil;
            //注册通知
            [strongSelf nsnotifition];
            //开始直播
            if (strongSelf.isOBS) {
                [strongSelf gotoOBS:model.push];
            } else {
                [strongSelf startUI];
            }
        }
        else{
            strongSelf.isOBS = false;
            UIAlertView  *alertsexper = [[UIAlertView alloc]initWithTitle:msg message:nil delegate:strongSelf cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil, nil];
            [alertsexper show];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD hideHUD];

        weakSelf.isOBS = false;
        [MBProgressHUD showError:[error isKindOfClass:[NSError class]]?[NSString stringWithFormat:@"%@%ld:%@",YZMsg(@"public_networkError"),error.code,error.localizedDescription]:error.toJson];
    }];
    
}

-(void)doHidden:(UIButton *)sender{
    self.isOBS = false;
    isOBSStart = false;
    if ([liveClassID isEqual:@"-99999999"]) {
        [MBProgressHUD showError:YZMsg(@"Livebroadcast_Choise_live_type")];
        return;
    }
    //判断是否开启了推送名片
    NSArray *applist = [Config getAppList];
    BOOL isConfigContact = NO;
    for (LiveAppItem *app in applist) {
        if (app.info.length > 0) {
            isConfigContact = YES;
        }
    }
    if (contactPriceNum != 0 && !isConfigContact) {
        //设置了推送名片 且 没有编辑名片
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"ContactInfo_notEditTipsTitle") message:YZMsg(@"ContactInfo_notEditTipsMsg") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:YZMsg(@"ContactInfo_notEditTipsSure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            EditContactInfo *EditContactInfoView = [[EditContactInfo alloc] init];
            [[MXBADelegate sharedAppDelegate] pushViewController:EditContactInfoView animated:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"ContactInfo_notEditTipsCancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertC addAction:sure];
        [alertC addAction:cancel];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertC animated:YES completion:nil];
        }
        
    }else{
        //设置不推送名片或者已经编辑名片
        [self doLive];
    }
    
    
}
/**
 开始直播
 */
- (void)doLive{
   
    [MBProgressHUD showMessage:@""];
//    if ([selectShareName isEqual:@""]) {
        [self createroom];
//    }else if([selectShareName isEqual:@"qq"]){
//        [self simplyShare:SSDKPlatformSubTypeQQFriend];
//    }else if([selectShareName isEqual:@"qzone"]){
//        [self simplyShare:SSDKPlatformSubTypeQZone];
//    }else if([selectShareName isEqual:@"wx"]){
//        [self simplyShare:SSDKPlatformSubTypeWechatSession];
//    }else if([selectShareName isEqual:@"wchat"]){
//        [self simplyShare:SSDKPlatformSubTypeWechatTimeline];
//    }else if([selectShareName isEqual:@"facebook"]){
//        [self simplyShare:SSDKPlatformTypeFacebook];
//    }else if([selectShareName isEqual:@"twitter"]){
//        [self simplyShare:SSDKPlatformTypeTwitter];
//    }else if([selectShareName isEqual:@"weibo"]){
//        [self simplyShare:SSDKPlatformTypeSinaWeibo];
//    }
}
//- (void)simplyShare:(int)SSDKPlatformType
//{
//    /**
//     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
//     **/
//    
//    int SSDKContentType = SSDKContentTypeAuto;
//    
//    NSURL *ParamsURL;
//    
//    
//    if(SSDKPlatformType == SSDKPlatformTypeSinaWeibo)
//    {
//        SSDKContentType = SSDKContentTypeImage;
//    }
//    else if((SSDKPlatformType == SSDKPlatformSubTypeWechatSession || SSDKPlatformType == SSDKPlatformSubTypeWechatTimeline))
//    {
//        NSString *strFullUrl = [[common wx_siteurl] stringByAppendingFormat:@"%@",[Config getOwnID]];
//        ParamsURL = [NSURL URLWithString:strFullUrl];
//    }else{
//        
//        ParamsURL = [NSURL URLWithString:[common app_ios]];
//    }
//    //获取我的头像
//    LiveUser *user = [Config myProfile];
//    //创建分享参数
//    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@%@",[Config getOwnNicename],[common share_des]]
//                                     images:user.avatar_thumb
//                                        url:ParamsURL
//                                      title:[common share_title]
//                                       type:SSDKContentType];
//    [shareParams SSDKEnableUseClientShare];
//    [MBProgressHUD hideHUD];
//    WeakSelf
//    [ShareSDK share:SSDKPlatformType parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
//        STRONGSELF
//        if (state == SSDKResponseStateSuccess) {
//            [MBProgressHUD showError:YZMsg(@"fenXiangView_ShareSuccess")];
//        }
//        else if (state == SSDKResponseStateFail){
//            [MBProgressHUD showError:YZMsg(@"fenXiangView_ShareError")];
//        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (strongSelf == nil) {
//                return;
//            }
//            [strongSelf createroom];
//        });
//    }];
//}

- (void)hidePreTextView{
    [liveTitleTextView resignFirstResponder];
    if (roomTypeView) {
        WeakSelf
        [UIView animateWithDuration:0.5 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->roomTypeView.y = _window_height;
        }];
        
    }
}


//选择封面
-(void)doUploadPicture{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"Livebroadcast_please_choise_uploadWay") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    WeakSelf
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:YZMsg(@"Livebroadcast_Alumb") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [alertContro addAction:picAction];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:YZMsg(@"Livebroadcast_Camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
    }];
    [alertContro addAction:photoAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    if (self.presentedViewController == nil) {
        [self presentViewController:alertContro animated:YES completion:nil];
    }
    
}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;

    // 添加支持的媒体类型，包括静态图片、GIF和实况照片
    // 添加所有图片类型，包括 GIF 和实况照片
    NSMutableArray *mediaTypes = [NSMutableArray array];
    [mediaTypes addObject:(NSString *)kUTTypeImage];          // 静态图片
    [mediaTypes addObject:(NSString *)kUTTypeGIF];            // 动态GIF图片

    // 检查是否支持实况照片
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeLivePhoto]) {
            [mediaTypes addObject:(NSString *)kUTTypeLivePhoto]; // 实况照片
        }
    }

    imagePickerController.mediaTypes = mediaTypes;
    
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    if (self.presentedViewController == nil) {
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
       NSData *data = nil;
       NSString *fileName = @"image.jpg";
       NSString *mimeType = @"image/jpeg";
       
       UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
       if (!image) {
           image = [info objectForKey:UIImagePickerControllerOriginalImage];
       }
      NSURL *imgUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    
      if ([type isEqualToString:(NSString *)kUTTypeGIF]||(imgUrl!= nil &&[imgUrl.absoluteString containsString:@"ext=GIF"])) {
           // 处理 GIF 图片
          NSURL *dataUrl = [info objectForKey:UIImagePickerControllerImageURL];
          if (dataUrl) {
              data = [NSData dataWithContentsOfURL:dataUrl];
          }
          
           image = [info objectForKey:UIImagePickerControllerOriginalImage];
          
           image = [SDAnimatedImage imageWithData:data];
          
           fileName = @"image.gif";
           mimeType = @"image/gif";
       } else if ([type isEqualToString:(NSString *)kUTTypeLivePhoto]) {
           // 处理实况照片
//           PHLivePhoto *livePhoto = [info objectForKey:UIImagePickerControllerLivePhoto];
           // 可以在此处提取 Live Photo 的 movie 部分
           fileName = @"image.jpeg";
           mimeType = @"image/jpeg";
           data = UIImageJPEGRepresentation(image, 0.5);
       } else if ([type isEqualToString:(NSString *)kUTTypePNG]) {
           data = UIImagePNGRepresentation(image);
           fileName = @"image.png";
           mimeType = @"image/png";
       } else {
           // 默认使用 JPEG 格式
           data = UIImageJPEGRepresentation(image, 0.5);
           fileName = @"image.jpg";
           mimeType = @"image/jpeg";
       }

       thumbLabel.text = YZMsg(@"Livebroadcast_Change_Cover");
       thumbLabel.backgroundColor = RGB_COLOR(@"#0000000", 0.3);
       [preThumbImgV setImage:image];
       
       dataUpload = [[DataForUpload alloc]init];
       dataUpload.datas = data;
       dataUpload.name = @"file";
       dataUpload.filename = fileName;
       dataUpload.mimeType = mimeType;
       
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

//退出预览
- (void)doClosePreView{
    self.isRedayCloseRoom = YES;
    //    [_gpuStreamers stopPreview];
    //    _gpuStreamers = nil;

    if (_np) {
        [_np closeCamera];
        [_np detachView];
        _np = nil;
    }
    
    NSString *toyidentifuer = self.connectedToy.identifier;
    if (self.connectedToy && self.connectedToy.isConnected) {
        [[Lovense shared] disconnectToy:toyidentifuer];
        for (LovenseToy *subToy in [Lovense shared].listToys) {
            if ([subToy.identifier isEqualToString:toyidentifuer]) {
                [[Lovense shared] removeToyById:toyidentifuer];
            }
        }
        self.connectedToy = nil;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[FUManager shareManager] destoryItems];
        [FUDemoManager destory];
    });
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLiveing"];
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark ================ 预览结束 ===============

#pragma mark ================ 直播结束 ===============
- (void)requestLiveAllTimeandVotes:(NSString*)streamStr{
    NSString *url = [NSString stringWithFormat:@"Live.stopInfo&stream=%@",streamStr];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (strongSelf.isOBS && !strongSelf->isOBSStart) {
            [strongSelf doExit];
        } else {
            if (code == 0) {
                NSDictionary *subdic = [info firstObject];
                [strongSelf lastview:subdic];
            }else{
                [strongSelf lastview:nil];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (strongSelf.isOBS && !strongSelf->isOBSStart) {
            [strongSelf doExit];
        } else {
            [strongSelf lastview:nil];
        }
    }];
    
}
-(void)lastview:(NSDictionary *)dic{
    //无数据都显示0
    if (!dic) {
        dic = @{@"votes":@"0",@"nums":@"0",@"length":@"0"};
    }
    UIImageView *lastView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    lastView.userInteractionEnabled = YES;
    [lastView sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]]];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = CGRectMake(0, 0,_window_width,_window_height);
    [lastView addSubview:effectview];
    
    
    UILabel *labell= [[UILabel alloc]initWithFrame:CGRectMake(0,24+statusbarHeight, _window_width, _window_height*0.17)];
    labell.textColor = RGB_COLOR(@"#cacbcc", 1);
    labell.text = YZMsg(@"Livebroadcast_Live_End");
    labell.textAlignment = NSTextAlignmentCenter;
    labell.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    [lastView addSubview:labell];
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.1, labell.bottom+50, _window_width*0.8, _window_width*0.8*8/13)];
    backView.backgroundColor = RGB_COLOR(@"#000000", 0.2);
    backView.layer.cornerRadius = 5.0;
    backView.layer.masksToBounds = YES;
    [lastView addSubview:backView];
    
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width/2-50, labell.bottom, 100, 100)];
    [headerImgView sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    headerImgView.layer.masksToBounds = YES;
    headerImgView.layer.cornerRadius = 50;
    [lastView addSubview:headerImgView];
    
    
    UILabel *nameL= [[UILabel alloc]initWithFrame:CGRectMake(0,50, backView.width, backView.height*0.55-50)];
    nameL.textColor = [UIColor whiteColor];
    nameL.text = [Config getOwnNicename];
    nameL.textAlignment = NSTextAlignmentCenter;
    nameL.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [backView addSubview:nameL];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, nameL.bottom, backView.width-20, 1) andColor:RGB_COLOR(@"#585452", 1) andView:backView];
    
    NSArray *labelArray = @[YZMsg(@"Livebroadcast_LiveTimes"),
                            [NSString stringWithFormat:@"%@",YZMsg(@"Livebroadcast_harvest")],
                            YZMsg(@"Livebroadcast_watchNumbers")];
    for (int i = 0; i < labelArray.count; i++) {
        UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*backView.width/3, nameL.bottom, backView.width/3, backView.height/4)];
        topLabel.font = [UIFont boldSystemFontOfSize:18];
        topLabel.textColor = normalColors;
        topLabel.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            topLabel.text = minstr([dic valueForKey:@"length"]);
        }
        if (i == 1) {
            topLabel.text = [YBToolClass getRateCurrency:minstr([dic valueForKey:@"votes"]) showUnit:YES];
        }
        if (i == 2) {
            topLabel.text = minstr([dic valueForKey:@"nums"]);
        }
        [backView addSubview:topLabel];
        UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(topLabel.left, topLabel.bottom, topLabel.width, 14)];
        footLabel.font = [UIFont systemFontOfSize:13];
        footLabel.textColor = RGB_COLOR(@"#cacbcc", 1);
        footLabel.textAlignment = NSTextAlignmentCenter;
        footLabel.text = labelArray[i];
        [backView addSubview:footLabel];
    }
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(_window_width*0.1,_window_height *0.75, _window_width*0.8,50);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doExit) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:normalColors];
    [button setTitle:YZMsg(@"pay_wait_page_back") forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.layer.cornerRadius = 25;
    button.layer.masksToBounds  =YES;
    [lastView addSubview:button];
    [self.view addSubview:lastView];
    
}
- (void)doExit{
    self.isRedayCloseRoom = YES;
    
    NSString *toyidentifuer = self.connectedToy.identifier;
    if (self.connectedToy && self.connectedToy.isConnected) {
        [[Lovense shared] disconnectToy:toyidentifuer];
        for (LovenseToy *subToy in [Lovense shared].listToys) {
            if ([subToy.identifier isEqualToString:toyidentifuer]) {
                [[Lovense shared] removeToyById:toyidentifuer];
            }
        }
        self.connectedToy = nil;
    }
    
    [FUDemoManager destory];
//    [[FUManager shareManager] destoryItems];

    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark ================ 直播结束 ===============

-(void)sendBarrage:(NSDictionary *)msg{
    NSString *text = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"content"]];
    NSString *name = [msg valueForKey:@"uname"];
    NSString *icon = [msg valueForKey:@"uhead"];
    NSDictionary *userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:text,@"title",name,@"name",icon,@"icon",nil];
    [danmuview setModel:userinfo];
}
-(void)sendMessage:(NSDictionary *)dic{
    [self addNewMsgFromMsgDic:dic];
}
-(void)sendDanMu:(SendBarrage *)dic{
    SendBarrage_CTStruct *ct = dic.msg.ct;
    NSString *name = dic.msg.uname;
    NSString *icon = dic.msg.uhead;
    NSDictionary *userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:ct.content,@"title",name,@"name",icon,@"icon",nil];
    [danmuview setModel:userinfo];
  
    _voteNums = ct.strvotestotal;
    [self changeState];
}
-(void)getZombieList:(NSArray *)list{
    if (!list) {
        return;
    }
    NSArray *arrays =[list firstObject];
    userCount += arrays.count;
    //    onlineLabel.text = [NSString stringWithFormat:@"%lld",userCount];
    if (!listView) {
        listView = [[ListCollection alloc]initWithListArray:list andID:[Config getOwnID] andStream:[NSString stringWithFormat:@"%@",self.roomModel.stream]];
        listView.delegate = self;
        listView.frame = CGRectMake(130, 20+statusbarHeight, _window_width-130, 40);
        [frontView addSubview:listView];
    }
    [listView listarrayAddArray:[list firstObject]];
}
-(void)jumpLast
{
    if (_canScrollToBottom || _scrollToBottomCount > 0) {
        _scrollToBottomCount--;
        NSUInteger sectionCount = [self.tableView numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
            if (rowCount!=NSNotFound) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
                if(indexPath.row!= messageList.count-1) {
                    return;
                }
                if (indexPath.row>0) {
                    [self.tableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                
                [self hidenNewMessages:YES];
            }
        }
    }else{
        [self hidenNewMessages:NO];
    }
}

//用户聊天自动上滚
-(void)userjumpLast
{
    if (_canScrollToBottomUser || _scrollToBottomCountUser > 0) {
        _scrollToBottomCountUser--;
        NSUInteger sectionCount = [self.userTableView numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [self.userTableView numberOfRowsInSection:0];
            if (rowCount!=NSNotFound) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.userTableView numberOfRowsInSection:0]-1 inSection:0];
                if(indexPath.row!= msgList.count-1) {
                    return;
                }
                if (indexPath.row>0) {
                    [self.userTableView scrollToRowAtIndexPath:indexPath
                                             atScrollPosition:UITableViewScrollPositionBottom animated:1];
                }
                
                [self hidenNewMessages:1];
                
            }
        }
    }else{
        [self hidenNewMessages:false];
    }
}


-(void)scrollToLastCell
{
    _canScrollToBottom = YES;
    [self jumpLast];
    [self scrollToLastUserCell];
}

//用户消息
-(void)scrollToLastUserCell
{
    _canScrollToBottomUser = 1;
    [self userjumpLast];
}

-(void)quickSort1:(NSMutableArray *)userlist
{
    for (int i = 0; i<userlist.count; i++)
    {
        for (int j=i+1; j<[userlist count]; j++)
        {
            int aac = [[[userlist objectAtIndex:i] valueForKey:@"level"] intValue];
            int bbc = [[[userlist objectAtIndex:j] valueForKey:@"level"] intValue];
            NSDictionary *da = [NSDictionary dictionaryWithDictionary:[userlist objectAtIndex:i]];
            NSDictionary *db = [NSDictionary dictionaryWithDictionary:[userlist objectAtIndex:j]];
            if (aac >= bbc)
            {
                [userlist replaceObjectAtIndex:i withObject:da];
                [userlist replaceObjectAtIndex:j withObject:db];
            }else{
                [userlist replaceObjectAtIndex:j withObject:da];
                [userlist replaceObjectAtIndex:i withObject:db];
            }
        }
    }
}
-(void)socketUserLive:(NSString *)ID and:(NSDictionary *)msg{
    userCount -= 1;
    //    onlineLabel.text = [NSString stringWithFormat:@"%lld",userCount];
    if (listView) {
        [listView userLive:msg];
    }
    
    
}
-(void)socketUserLogin:(NSString *)ID andDic:(NSDictionary *)dic{
    userCount += 1;
    if (listView) {
        [listView userAccess:dic];
    }
    //    onlineLabel.text = [NSString stringWithFormat:@"%lld",userCount];
    //进场动画级别限制
    //    NSString *levelLimit = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"level"]];
    //    int levelLimits = [levelLimit intValue];
    //    int levelLimitsLocal = [[common enter_tip_level] intValue];
    //    if (levelLimitsLocal >levelLimits) {
    //    }
    //    else{
    NSString *user_level = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"level"]];
    int userLevel = [user_level intValue];
    int levelLimits = [[Config getShowLevel] intValue];
    if ([Config getShowLevel]==nil) {
        levelLimits = 15;
        [[NSNotificationCenter defaultCenter] postNotificationName:KGetBaseInfoNotification object:nil];
    }
    NSString *vipType = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"vip_type"]];
    NSString *guard_type = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"guard_type"]];
    NSString *king_icon = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"king_icon"]];
    
    BOOL bShowInChatView = true;
    if (userLevel >= levelLimits|| [vipType isEqual:@"1"] || [guard_type isEqual:@"1"] || [guard_type isEqual:@"2"]/*||![PublicObj checkNull:king_icon]*/) {
        [useraimation addUserMove:dic];
        useraimation.frame = CGRectMake(10,_tableViewTop - 40,_window_width,20);
    }else if(userLevel < levelLimits){
        [nuseraimation addUserMove:dic];
        nuseraimation.frame = CGRectMake(10,_tableViewBottom - 5,_window_width,20);
        bShowInChatView = false;
    }
    
    NSString *car_id = minstr([[dic valueForKey:@"ct"] valueForKey:@"car_id"]);
    if (![car_id isEqual:@"0"]) {
        if (!vipanimation) {
            WeakSelf
            vipanimation = [[viplogin alloc]initWithFrame:CGRectMake(0,80,_window_width,_window_width*0.8) andBlock:^(id arrays) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf-> vipanimation removeFromSuperview];
                strongSelf->vipanimation = nil;
            }];
            vipanimation.userInteractionEnabled = NO;
            vipanimation.frame =CGRectMake(0,80,_window_width,_window_width*0.8);
            [self.view insertSubview:vipanimation atIndex:11];
            [self.view bringSubviewToFront:vipanimation];
        }
        [vipanimation addUserMove:dic];
    }
    
    if(bShowInChatView){
        [self userLoginSendMSG:dic];
    }
    
}
//用户进入直播间发送XXX进入了直播间
-(void)userLoginSendMSG:(NSDictionary *)dic {
    titleColor = @"userLogin";
    NSString *uname = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"user_nicename"]];
    NSString *levell = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"level"]];
    NSString *ID = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"id"]];
    NSString *vip_type = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"vip_type"]];
    NSString *liangname = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"liangname"]];
    NSString *usertype = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"usertype"]];
    NSString *guard_type = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"guard_type"]];
    NSString *king_icon = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"king_icon"]];
    
    NSString *conttt = [@" " stringByAppendingString:YZMsg(@"nuserLoginAnimation_enter_room")];
    NSString *isadmin;
    if ([[NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"usertype"]] isEqual:@"40"]) {
        isadmin = @"1";
    }else{
        isadmin = @"0";
    }
    //    chat_level
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",conttt,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",usertype,@"usertype",guard_type,@"guard_type",king_icon?king_icon:@"",@"king_icon",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
-(void)socketShowChatSystem:(NSString *)ct
{
    titleColor = @"firstlogin";
    NSString *uname = YZMsg(@"Livebroadcast_LiveMsgs");
    NSString *levell = @" ";
    NSString *ID = @" ";
    NSString *vip_type = @"0";
    NSString *liangname = @"0";
    NSString * isSeverMsg = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",isSeverMsg,@"isSeverMsg",nil];
    titleColor = @"0";
    [self addMessageFromMsgDic:chat];
}
-(void)timeDelayUpdate:(long long)timeDelayNum
{
    [YBToolClass.sharedInstance checkNetworkflow];
    NSString *title = [NSString stringWithFormat:@"%lldms\n↑%@/s", timeDelayNum, YBToolClass.sharedInstance.sendNetworkSpeed?:@"0"];
    [self.speedButton setTitle:title forState:UIControlStateNormal];
    
    if (timeDelayNum > 350 || timeDelayNum <= 0) {
        [self.speedButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    } else if (timeDelayNum > 150) {
        [self.speedButton setTitleColor:UIColor.orangeColor forState:UIControlStateNormal];
    } else {
        [self.speedButton setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
    }
}

-(void)socketSystem:(NSString *)ct{
    titleColor = @"firstlogin";
    NSString *uname = YZMsg(@"Livebroadcast_LiveMsgs");
    NSString *levell = @" ";
    NSString *ID = @" ";
    NSString *vip_type = @"0";
    NSString *liangname = @"0";
    NSString * isSeverMsg = @"";
    if (ct.length > 50){
        isSeverMsg = @"1";
    }
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",isSeverMsg,@"isSeverMsg",nil];
    titleColor = @"0";

    if (isSeverMsg.length>0) {
        [self addMessageFromOtherMsgDic:chat];
    }else{
        [self addMessageFromMsgDic:chat];
    }
}

-(void)socketGame:(NSDictionary *)msg{
    titleColor = [msg valueForKey:@"titleColor"];
    NSString *uname = YZMsg(@"");
    NSString *levell = @" ";
    NSString *ID = @" ";
    NSString *vip_type = @"0";
    NSString *liangname = @"0";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",[msg valueForKey:@"ct"],@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",nil];
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
-(void)socketLight{
    starX = closeLiveBtn.frame.origin.x ;
    starY = closeLiveBtn.frame.origin.y - 30;
    starImage = [[UIImageView alloc]initWithFrame:CGRectMake(starX, starY, 30, 30)];
    starImage.contentMode = UIViewContentModeScaleAspectFit;
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"plane_heart_cyan.png",@"plane_heart_pink.png",@"plane_heart_red.png",@"plane_heart_yellow.png",@"plane_heart_heart.png", nil];
    NSInteger random = arc4random()%array.count;
    starImage.image = [ImageBundle imagewithBundleName:[array objectAtIndex:random]];
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->starImage.alpha = 1.0;
        strongSelf->starImage.frame = CGRectMake(strongSelf->starX+random - 10, strongSelf->starY-random - 30, 30, 30);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(1.3, 1.3);
        strongSelf->starImage.transform = CGAffineTransformScale(transfrom, 1, 1);
    }];
    [self.view insertSubview:starImage atIndex:11];
    CGFloat finishX = _window_width - round(arc4random() % 200);
    //  动画结束点的Y值
    CGFloat finishY = 200;
    //  imageView在运动过程中的缩放比例
    CGFloat scale = round(arc4random() % 2) + 0.7;
    // 生成一个作为速度参数的随机数
    CGFloat speed = 1 / round(arc4random() % 900) + 0.6;
    //  动画执行时间
    NSTimeInterval duration = 4 * speed;
    //  如果得到的时间是无穷大，就重新附一个值（这里要特别注意，请看下面的特别提醒）
    if (duration == INFINITY) duration = 2.412346;
    //  开始动画
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(starImage)];
    //  设置动画时间
    [UIView setAnimationDuration:duration];
    
    
    //  设置imageView的结束frame
    starImage.frame = CGRectMake( finishX, finishY, 30 * scale, 30 * scale);
    
    //  设置渐渐消失的效果，这里的时间最好和动画时间一致
    [UIView animateWithDuration:duration animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->starImage.alpha = 0;
    }];
    
    //  结束动画，调用onAnimationComplete:finished:context:函数
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    //  设置动画代理
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}
-(void)sendGift:(NSDictionary *)msg{
    titleColor = @"2";
    NSString *haohualiwuss =  [NSString stringWithFormat:@"%@",[msg valueForKey:@"evensend"]];
    NSDictionary *ct = [msg valueForKey:@"ct"];
    NSDictionary *GiftInfo = @{@"uid":[msg valueForKey:@"uid"],
                               @"nicename":[msg valueForKey:@"uname"],
                               @"giftname":[ct valueForKey:@"giftname"],
                               @"gifticon":[ct valueForKey:@"gifticon"],
                               @"giftcount":[ct valueForKey:@"giftcount"],
                               @"giftid":[ct valueForKey:@"giftid"],
                               @"level":[msg valueForKey:@"level"],
                               @"avatar":[msg valueForKey:@"uhead"],
                               @"type":[ct valueForKey:@"type"],
                               @"swf":minstr([ct valueForKey:@"swf"]),
                               @"swftime":minstr([ct valueForKey:@"swftime"]),
                               @"swftype":minstr([ct valueForKey:@"swftype"]),
    };
    
    _voteNums = minstr([ct valueForKey:@"strvotestotal"]);
    [self changeState];

    NSInteger type = [[ct valueForKey:@"type"] integerValue];
    if (type == 1) {
        [self expensiveGift:GiftInfo];
    } else if (type == 3 || type == 4) {
        OrderUserModel *model = [[OrderUserModel alloc] init];
        if (type == 3) { // 跳蛋
            model.type = LiveToyInfoRemoteControllerForToy;
        } else if (type == 4) { //指令
            model.type = LiveToyInfoRemoteControllerForAnchorman;
        }
        model.uid = minstr([ct valueForKey:@"uid"]);
        model.giftID = minstr([ct valueForKey:@"giftid"]);
        model.name = minstr([msg valueForKey:@"uname"]);
        model.avatar = minstr([msg valueForKey:@"uhead"]);
        model.orderName = minstr([ct valueForKey:@"giftname"]);
        model.second = minstr([ct valueForKey:@"swftime"]);
        model.swiftType = minstr([ct valueForKey:@"swftype"]);
        [_remoteInterfaceView receiveOrderModel:model];
    }
    else{
        if (!continueGifts) {
            continueGifts = [[continueGift alloc]init];
            [liansongliwubottomview addSubview:continueGifts];
            //初始化礼物空位
            [continueGifts initGift];
        }
        [continueGifts GiftPopView:GiftInfo andLianSong:haohualiwuss];
    }
    
    NSString *ctt = @"";
    if (type == 3 || type == 4) {
        ctt = [NSString stringWithFormat:@"%@",[ct valueForKey:@"giftname"]];
    } else {
        ctt = [NSString stringWithFormat:YZMsg(@"Livebroadcast_LiveSend%d_gift%@"),[[ct valueForKey:@"giftcount"] integerValue], [NSString stringWithFormat:@"%@",[ct valueForKey:@"giftname"]]];
    }
    
    NSString* uname = [msg valueForKey:@"uname"];
    NSString *levell = [msg valueForKey:@"level"];
    NSString *ID = [msg valueForKey:@"uid"];
    NSString *avatar = [msg valueForKey:@"uhead"];
    NSString *vip_type =minstr([msg valueForKey:@"vipType"]);
    NSString *liangname =minstr([msg valueForKey:@"liangname"]);
    
    NSDictionary *chat6 = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ctt,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",avatar,@"avatar",vip_type,@"vip_type",liangname,@"liangname",nil];
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat6];
    
}

-(void)socketShutUp:(NSString *)name andID:(NSString *)ID{
    if (socketL) {
        [socketL shutUp:ID andName:name];
    }
}
-(void)socketkickuser:(NSString *)name andID:(NSString *)ID{
    if (socketL) {
        [socketL kickuser:ID andName:name];
    }
}
-(void)socketSendContactInfo:(NSString *)contactInfo andID:(NSString *)ID{
    if (socketL) {
        [socketL sendContactInfo:contactInfo andID:ID];
    }
}
//弹幕翻译
-(void)transalteMsg:(TranslateContent *)translateMsg
{
    NSString *translateStr = translateMsg.msg.ct;
    NSString *originaStr = translateMsg.msg.content;
    for (int i =0 ; i<msgList.count; i++) {
        chatModel * model = msgList[i];
        if ([model.contentChat isEqualToString:originaStr]) {
            model.contentChat = translateStr;
            model.isTranslate = false;
            [model setChatFrame];
        }
    }
    [self.userTableView reloadData];
    _canScrollToBottomUser = false;
}

static int startKeyboard = 0;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //_canScrollToBottom = NO;
    _bDraggingScroll = YES;

    CGFloat h = UIApplication.sharedApplication.statusBarFrame.size.height + 45;
    h = UIApplication.sharedApplication.statusBarFrame.size.height + (keyField.isFirstResponder?10.0:45.0);

    if (scrollView == self.userTableView) {
        _bDraggingScrollUser = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
        if (keyField.isFirstResponder) {
            self.userTableView.frame = CGRectMake(10,h,tableWidth,_window_height*0.35);
        }else{
            self.userTableView.frame = CGRectMake(10,_window_height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.35);
        }
        self.tableView.hidden = YES;
    }else if(scrollView == self.tableView){
        _bDraggingScroll = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
        if (keyField.isFirstResponder) {
            self.tableView.frame = CGRectMake(10,h,tableWidth,_window_height*0.35);
        }else{
            self.tableView.frame = CGRectMake(10,_window_height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.35);
        }
        self.userTableView.hidden = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //_canScrollToBottom = YES;
    if (scrollView == self.userTableView) {
        _bDraggingScrollUser = false;
    }else if(scrollView == self.tableView){
        _bDraggingScroll = false;
    }
}

//显示分屏视图
-(void)showFenpingView{
    
    self.userTableView.hidden = false;
    if (_bDraggingScrollUser) {
        return;
    }
    self.tableView.hidden = false;
    [self tableViewHieghtDeal];
    [self scrollToLastUserCell];
    [self scrollToLastCell];
    
}

//聊天table高度处理
-(void)tableViewHieghtDeal{
        CGFloat  userTableH = 0;
        for (int i = 0; i< msgList.count; i++) {
            chatModel * model = msgList[i];
            userTableH = userTableH + model.rowHH + 10;
        }
        if(userTableH > _window_height*0.11 || msgList.count>=3){
            self.tableView.frame = CGRectMake(10,keyField.isFirstResponder?self.tableView.top:(_window_height - _window_height*0.35 - 50 - ShowDiff -40),tableWidth,_window_height*0.24);
            self.userTableView.frame = CGRectMake(10,keyField.isFirstResponder?self.tableView.bottom:(_window_height - _window_height*0.11 - 50 - ShowDiff -40),tableWidth,_window_height*0.11);
        }else{
            self.tableView.frame = CGRectMake(10,keyField.isFirstResponder?self.tableView.top:(_window_height - _window_height*0.35 - 50 - ShowDiff -40  ),tableWidth,_window_height*0.35 - userTableH);
            self.userTableView.frame = CGRectMake(10,keyField.isFirstResponder?self.tableView.bottom:(_window_height - userTableH - 50 - ShowDiff -40),tableWidth,userTableH);
        }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.tableView && _bDraggingScroll){
        if(scrollView.contentSize.height > scrollView.height){
            if(scrollView.contentOffset.y + scrollView.height + 5 < scrollView.contentSize.height){
                _canScrollToBottom = NO;
                //NSLog(@"_canScrollToBottom NO");
            }else{
                _canScrollToBottom = YES;
                [self hidenNewMessages:YES];
                //NSLog(@"_canScrollToBottom YES");
            }
        }
    }
    
    if(scrollView == self.tableView && _bDraggingScroll){
        if(scrollView.contentSize.height > scrollView.height){
            if(scrollView.contentOffset.y + scrollView.height + 5 < scrollView.contentSize.height){
                _canScrollToBottom = false;
                //NSLog(@"_canScrollToBottom NO");
            //    滑动结束后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:3];
            }else{
                _canScrollToBottom = 1;
                //NSLog(@"_canScrollToBottom YES");
                [self hidenNewMessages:1];
            //    滑动到底后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
            }
        }
        else{
            //    滑动结束后显示分屏视图
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
        }
    }
    if(scrollView == self.userTableView && _bDraggingScrollUser){
        if(scrollView.contentSize.height > scrollView.height){
            if(scrollView.contentOffset.y + scrollView.height + 5 < scrollView.contentSize.height){
                _canScrollToBottomUser = false;
                //NSLog(@"_canScrollToBottom NO");
            //    滑动结束后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:3];
            }else{
                _canScrollToBottomUser = 1;
                //NSLog(@"_canScrollToBottom YES");
                [self hidenNewMessages:1];
            //    滑动到底后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
            }
        }
        else{
            //    滑动结束后显示分屏视图
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
        }
    }
}

-(void)chushihua{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLiveing"];
    self.isRedayCloseRoom = NO;
    backTime = 0;
    [gameState saveProfile:@"0"];//重置游戏状态
    _canScrollToBottom = YES;
    _bDraggingScroll = NO;
    _scrollToBottomCount = 5;
    _canScrollToBottomUser  = YES;
    _scrollToBottomCountUser = 5;
    _bDraggingScrollUser = NO;
    _voteNums = @"0";//主播一开始的收获数
    userCount = 0;//用户人数计算
    haohualiwuV.expensiveGiftCount = [NSMutableArray array];//豪华礼物数组
    titleColor = @"0";//用此字段来判别文字颜色
    msgList = [[NSMutableArray alloc] init];//聊天数组
    messageList = [[NSMutableArray alloc] init];//非聊天数组
    //    joinMsgList = [[NSMutableArray alloc] init];//进入房间数组
    ismessgaeshow = NO;
    //预览界面的信息
    liveClassID = @"1";
    lotteryType = @"10";
    roomType = @"0";
    roomTypeValue = @"";
   
    isAnchorLink = NO;
    isTorch = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        strongSelf.unRead = [[JMSGConversation getAllUnreadCount] intValue];
        
    });

    // lovense
//    self.allConnectedToys = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccessCallback:) name:kToyConnectSuccessNotification object:nil];     //Connected toy successfully notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectBreakCallback:) name:kToyConnectBreakNotification object:nil];     //Toy is disconnected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toyGetBatteryChange:) name:kToyCallbackNotificationBattery object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = true;
    [self doCancle];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
   
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate =nil;
    
    if ((self.connectedToy != nil && !self.connectedToy.isConnected) || (self.connectedToy== nil && self.toySwitchStatus)) {
        [self changeToyStatus:false];
    }
    
}
///初始化美颜
-(void)loadBeautyManager
{
    [FUDemoManager setupFUSDK];
    
//    //    fuSetDefaultRotationMode([FUManager shareManager].deviceOrientation);
//    [[FUManager shareManager] loadFilter];
//    [[FUManager shareManager] loadBundleWithName:@"fxaa" aboutType:FUNamaHandleTypeFxaa];
//    /* 同步 */
//    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
//    /* 最大识别人脸数 */
//    [FUManager shareManager].enableMaxFaces = YES;
//    fuSetDefaultRotationMode(3);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化消息处理队列
    _messageQueue = dispatch_queue_create("com.yourcompany.livebroadcast.messageQueue", DISPATCH_QUEUE_SERIAL);

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
   
//    [self requestAccess];
    [self initView];
}



-(void)initView{
   
    self.view.backgroundColor = [UIColor whiteColor];
    //弹出相机权限
   
    isQie = YES;
    isclosenetwork = NO;
    //顶部弹窗
    
   
    [self chushihua];
    [self nsnotifition];
    
    if (pushbottomV == nil) {
        pushbottomV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        pushbottomV.backgroundColor = [UIColor clearColor];
        [self.view addSubview:pushbottomV];
        
        videobottom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        videobottom.backgroundColor = [UIColor clearColor];
        [pushbottomV addSubview:videobottom];
    }
    
   
    
    [self initPushStreamer];//创建推流器
    

    
    managerAFH = [AFNetworkReachabilityManager sharedManager];
    WeakSelf
    [managerAFH setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                strongSelf->isclosenetwork = YES;
                [strongSelf backGround];
                //                [notifications displayNotificationWithMessage:@"网络断开连接" forDuration:8];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                strongSelf->isclosenetwork = YES;
                [strongSelf backGround];
                //                [notifications displayNotificationWithMessage:@"网络断开连接" forDuration:8];
                break;
            case  AFNetworkReachabilityStatusReachableViaWWAN:
                strongSelf->isclosenetwork = NO;
                [strongSelf forwardGround];
                //                [notifications dismissNotification];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                strongSelf->isclosenetwork = NO;
                [strongSelf forwardGround];
                //                [notifications dismissNotification];
                break;
            default:
                break;
        }
    }];
    [managerAFH startMonitoring];
#pragma mark 回到后台+来电话
    [MBProgressHUD hideHUD];
    [self creatPreFrontView];
    //    [self startUI];//初始化UI
    //彩票计时器
    if (lotteryTime) {
        [lotteryTime invalidate];
        lotteryTime = nil;
    }
    if (!lotteryTime) {
        lotteryTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(lotteryInterval) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:lotteryTime forMode:NSRunLoopCommonModes];
    }
    lastSyncLotteryTimeDict = [NSMutableDictionary dictionary];
    standTickCount = 0;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOrHidenMessageTableView:) name:KShowLotteryBetViewControllerNotification object:nil];
    
    [self loadBeautyManager];
}

-(void)showOrHidenMessageTableView:(NSNotification*)notifiObj
{
    NSNumber *obj = notifiObj.object;
    if (obj.integerValue == 0) {
        self.tableView.hidden = false;
//        [self doMoveTableMsg];
        [self hideBTN];
    }else{
        self.tableView.hidden = false;
//        [self doRecoverTableMsg];
        [self showBTN];
    }
}

// 游戏弹出时移动聊天列表和直播位置
-(void)doMoveTableMsg{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSInteger type = [minstr(strongSelf->roomLotteryInfo[@"lotteryType"]) integerValue];
        CGFloat h = UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 65;
        CGFloat viewH = 25+statusbarHeight;
        if (type == 10) {
            strongSelf.tableView.frame = CGRectMake(10,h,_window_width/2 - 10,_window_height - h - 360 - ShowDiff);
            [strongSelf->videobottom setFrame: CGRectMake(_window_width/2,viewH,_window_width/2 -5,_window_height -360 - ShowDiff - viewH)];
        }else if(type == 26 || type == 28){
            strongSelf.tableView.frame = CGRectMake(10,h,_window_width/2 - 10,_window_height - h - 360 - ShowDiff);
            [strongSelf->videobottom setFrame: CGRectMake(_window_width/2,viewH,_window_width/2 -5,_window_height -360 - ShowDiff - viewH)];
        } else{
            strongSelf.tableView.frame = CGRectMake(10,h,_window_width/2 - 10,_window_height - h - 360 - ShowDiff);
            [strongSelf->videobottom setFrame: CGRectMake(_window_width/2,viewH,_window_width/2 -5,_window_height -360 - ShowDiff - viewH)];
        }
        strongSelf->videobottom.layer.cornerRadius = 5;
        strongSelf->videobottom.layer.masksToBounds = YES;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
}
// 游戏消失时移动聊天列表和直播位置
-(void)doRecoverTableMsg{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSInteger type = [minstr(strongSelf->roomLotteryInfo[@"lotteryType"]) integerValue];
        if (type == 10) {
            strongSelf.tableView.frame = CGRectMake(10, _window_height - _window_height*0.35 - 50 - ShowDiff - 40 ,tableWidth,_window_height*0.35);
            [strongSelf->videobottom setFrame: CGRectMake(0,0,_window_width,_window_height)];
        }else if(type == 26 || type == 28){
            strongSelf.tableView.frame = CGRectMake(10, _window_height - _window_height*0.35 - 50 - ShowDiff - 40 ,tableWidth,_window_height*0.35);
            [strongSelf->videobottom setFrame: CGRectMake(0,0,_window_width,_window_height)];
        } else{
            strongSelf.tableView.frame = CGRectMake(10, _window_height - _window_height*0.35 - 50 - ShowDiff - 40 ,tableWidth,_window_height*0.35);
            [strongSelf->videobottom setFrame: CGRectMake(0,0,_window_width,_window_height)];
        }
        strongSelf->videobottom.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
}

static int timeCountLB = 0;
- (void)lotteryInterval{
    
    
    
    if(liveTime > 10 && (!lastSyncLiveStatus || [[NSDate date] timeIntervalSinceDate:lastSyncLiveStatus] >= 59)){
        lastSyncLiveStatus = [NSDate date];
        NSDictionary *getLiveStatus = @{
            @"uid":[Config getOwnID],
            @"token":[Config getOwnToken]
        };
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.getLiveStatus" withBaseDomian:YES andParameter:getLiveStatus data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                
            }else{
                if(msg){
                    if (strongSelf->socketL!=nil) {
                        UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:minstr(msg) preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [strongSelf hostStopRoom];
                        }];
                        UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        
                        [alertC addAction:suerA];
                        [alertC addAction:cancelActionss];
                        if (currentVC.presentedViewController == nil) {
                            [currentVC presentViewController:alertC animated:YES completion:nil];
                        }
                    }else{
                        [strongSelf cancelTimeoutLiveStatus];
                    }
                }
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];
    }
    if(!lotteryInfo) return;
    // NSLog(@"%@ 时间0:%ld", roomLotteryInfo[@"lotteryType"], standTickCount);
    for (NSString * lotteryType in lotteryInfo) {
        NSMutableDictionary *dict = lotteryInfo[lotteryType];
        //NSInteger time = [dict[@"time"] integerValue];
        NSDate * nowDate = [NSDate date];
        NSInteger timeDistance = [lotteryInfo[lotteryType][@"openTime"] timeIntervalSinceDate:nowDate];
        
        BOOL bCurLottery = lotteryType == minstr(roomLotteryInfo[@"lotteryType"]);
        if(timeDistance > [dict[@"sealingTim"] integerValue]){
            if(bCurLottery){
                standTickCount = 0;
                lotteryBTN.hidden = NO;
                [lotteryBTN setTitle:[YBToolClass timeFormatted:timeDistance-[dict[@"sealingTim"] integerValue]] forState:UIControlStateNormal];
                lotteryBTN.titleLabel.adjustsFontSizeToFitWidth = YES;
                lotteryBTN.titleLabel.minimumScaleFactor = 0.3;
               
            }else{
                NSInteger openedLotteryType = labs([GameToolClass getCurOpenedLotteryType]);
                if([lotteryType integerValue] == openedLotteryType && openedLotteryType > 0 && (openedLotteryType != [minstr(roomLotteryInfo[@"lotteryType"]) integerValue])){
                    openedTickCount = 0;
                   
                }
            }
            
        }else{
            if(timeDistance > 0){
                if(bCurLottery){
                    lotteryBTN.hidden = NO;
                    [lotteryBTN setTitle:[NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), [dict[@"sealingTim"] integerValue] - ([dict[@"sealingTim"] integerValue] - timeDistance)] forState:UIControlStateNormal];
                    lotteryBTN.titleLabel.adjustsFontSizeToFitWidth = YES;
                    lotteryBTN.titleLabel.minimumScaleFactor = 0.5;
                }
            }else if([dict[@"stopOrSell"] integerValue] == 2){
                if(bCurLottery){
                    lotteryBTN.hidden = NO;
                    [lotteryBTN setTitle:YZMsg(@"Livebroadcast_lotteryDisable") forState:UIControlStateNormal];
                }
            }else{
                if(bCurLottery){
                    lotteryBTN.hidden = NO;
                    [lotteryBTN setTitle:YZMsg(@"LobbyLotteryVC_betOpen") forState:UIControlStateNormal];
                    if(standTickCount == 2 || standTickCount % 6 == 0){
                        // 一直没等来开奖消息 递增等待时间主动拉取
                        // NSLog(@"standTickCount=[%ld] 请求同步彩票2-1", standTickCount);
                        if (socketL) {
                            [socketL sendSyncLotteryCMD:lotteryType];
                        }
                        
                        //[socketL sendSyncOpenAwardCMD:lotteryType];
                    }
                    standTickCount ++;
                }else{
                    NSInteger openedLotteryType = labs([GameToolClass getCurOpenedLotteryType]);
                    if([lotteryType integerValue] == openedLotteryType && openedLotteryType > 0 && (openedLotteryType != [minstr(roomLotteryInfo[@"lotteryType"]) integerValue])){
                        if(openedTickCount == 2 || openedTickCount % 6 == 0){
                            // 一直没等来开奖消息 递增等待时间主动拉取
                            // NSLog(@"standTickCount=[%ld] 请求同步彩票2-2", standTickCount);
                            if (socketL) {
                                [socketL sendSyncLotteryCMD:[NSString stringWithFormat:@"%ld", openedLotteryType]];
                                [socketL sendSyncOpenAwardCMD:[NSString stringWithFormat:@"%ld", openedLotteryType]];
                            }
                        }
                        openedTickCount ++;
                    }
                }
            }
        }
        dict[@"time"] = [NSString stringWithFormat:@"%ld", timeDistance];
        // NSLog(@"%@ 时间2:%@", lotteryType, dict[@"time"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lotterySecondNotify" object:nil userInfo:@{
            @"betLeftTime":dict[@"time"]?:@"",
            @"sealingTime":dict[@"sealingTim"]?:@"",
            @"issue":dict[@"issue"]?:@"",
            @"lotteryType":lotteryType,
            @"liveid":self.roomModel.zhuboID?:@""
        }];
    }
    
    if(lotteryType&&[lotteryType isEqualToString:@"40"]){
        if (lotteryBTN.hidden) {
            lotteryBTN.hidden = NO;
            [lotteryBTN setTitle:@"" forState:UIControlStateNormal];
        }
        //            拉霸打开投注页面,开奖的时候刷新奖池
        timeCountLB++;
        if(curLotteryBetVC  && [((LotteryBetViewController_LB*)curLotteryBetVC) respondsToSelector:@selector(getPoolDataInfo)] && timeCountLB == 60){
            [((LotteryBetViewController_LB*)curLotteryBetVC) getPoolDataInfo];
            timeCountLB =0;
        }
        return;
    }
}

//杀进程
-(void)shajincheng{
    [self getCloseShow];
    if (socketL) {
        [socketL closeRoom];
        [socketL colseSocket];
    }
}
-(void)backgroundselector{
    backTime +=1;
    NSLog(@"返回后台时间%d",backTime);
    if (backTime > 60) {
//        [self hostStopRoom];
    }
}
-(void)backGround{
    //进入后台
    if (!backGroundTimer) {
        [self sendEmccBack];
        backGroundTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(backgroundselector) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:backGroundTimer forMode:NSRunLoopCommonModes];
    }
}
-(void)forwardGround{
    if (backTime != 0 && socketL) {
        [socketL phoneCall:YZMsg(@"Livebroadcast_backtoRoom")];
    }
    //进入前台
    if (backTime > 60) {
//        [self hostStopRoom];
    }
    if (isclosenetwork == NO) {
        [backGroundTimer invalidate];
        backGroundTimer  = nil;
        backTime = 0;
    }
}
-(void)appactive{
    NSLog(@"哈哈哈哈哈哈哈哈哈哈哈哈 app回到前台");
    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
        
    }else{
        //        [_gpuStreamers appBecomeActive];
    }
    
    [self forwardGround];
}
-(void)appnoactive{
    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
        
    }else{
        //        [_gpuStreamers appEnterBackground];
    }
    
    
    [self backGround];
    NSLog(@"0000000000000000000 app进入后台");
}
//来电话
-(void)sendEmccBack
{
    if (socketL) {
        [socketL phoneCall:YZMsg(@"Livebroadcast_liveinbackgroud")];
    }
}
-(void)startUI{
    frontView = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height)];
    frontView.clipsToBounds = YES;
    [self.view insertSubview:frontView atIndex:3];
    
    listView = [[ListCollection alloc]initWithListArray:nil andID:[Config getOwnID] andStream:[NSString stringWithFormat:@"%@",_roomModel.stream]];
    listView.frame = CGRectMake(130,20+statusbarHeight,_window_width-130,40);
    listView.delegate = self;
    [frontView addSubview:listView];
    dispatch_main_async_safe(^{
        [self setView];//加载信息页面
    });
    //倒计时动画
    backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    backView.opaque = YES;
    label1 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2 -100, _window_height/2-200, 100, 100)];
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont systemFontOfSize:90];
    label1.text = @"3";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.center = backView.center;
    label2 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2 -100, _window_height/2-200, 100, 100)];
    label2.textColor = [UIColor whiteColor];
    label2.font = [UIFont systemFontOfSize:90];
    label2.text = @"2";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.center = backView.center;
    label3 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2 -100, _window_height/2-200, 100, 100)];
    label3.textColor = [UIColor whiteColor];
    label3.font = [UIFont systemFontOfSize:90];
    label3.text = @"1";
    label3.textAlignment = NSTextAlignmentCenter;
    label3.center = backView.center;
    label1.hidden = YES;
    label2.hidden = YES;
    label3.hidden = YES;
    [backView addSubview:label3];
    [backView addSubview:label1];
    [backView addSubview:label2];
    [frontView addSubview:backView];
    [self creatLiveTimeView];
    [self kaishidonghua];
    self.view.backgroundColor = [UIColor clearColor];
}
//开始321
-(void)kaishidonghua{
    [self hideBTN];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->label1.hidden = NO;
        [strongSelf donghua:strongSelf->label1];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->label1.hidden = YES;
        strongSelf->label2.hidden = NO;
        [strongSelf donghua:strongSelf->label2];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->label2.hidden = YES;
        strongSelf->label3.hidden = NO;
        [strongSelf donghua:strongSelf->label3];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->label3.hidden = YES;
        strongSelf->backView.hidden = YES;
        [strongSelf->backView removeFromSuperview];
        [strongSelf showBTN];
        [strongSelf getStartShow];//请求直播
    });
}

- (void) addObservers {
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(onStreamStateChange:)
    //                                                 name:KSYStreamStateDidChangeNotification
    //                                               object:nil];
    //
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(onNetStateEvent:)
    //                                                 name:KSYNetStateEventNotification
    //                                               object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:kKSYReachabilityChangedNotification object:nil];
    [backGroundTimer invalidate];
    backGroundTimer  = nil;
    NSLog(@"1212121212121212121");
    
}
//释放通知
- (void) rmObservers {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:KSYStreamStateDidChangeNotification
    //                                                  object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:KSYNetStateEventNotification
    //                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:@"wangminxindemusicplay"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"wangminxindemusicplay" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"shajincheng" object:nil];
    //shajincheng
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"sixinok" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"fenxiang" object:nil];
#pragma make - lovense
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kToyConnectSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kToyConnectBreakNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kToyCallbackNotificationBattery object:nil];
}
//手指拖拽弹窗移动
-(void)message:(UIPanGestureRecognizer *)sender{
    CGPoint point = [sender translationInView:sender.view];
    CGPoint center = sender.view.center;
    center.x += point.x;
    center.y += point.y;
    userView.center = center;
    //清空
    [sender setTranslation:CGPointZero inView:sender.view];
}

#pragma mark - UI responde
- (void)onQuit:(id)sender {
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }

    if (_np) {
        [_np stop];
        [_np closeCamera];
        [_np detachView];
        _np = nil;
    }
    
//    [[FUManager shareManager] destoryItems];
    [FUDemoManager destory];
}

- (void)onStream:(id)sender {
    NSString *sss = _hostURL.absoluteString;

    [_np start:sss];
}
//推流成功后更新直播状态 1开播
-(void)changePlayState:(int)status{
    NSDictionary *changelive = @{
        @"stream":urlStrtimestring,
        @"status":[NSString stringWithFormat:@"%d",status]
    };
    
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.changeLive" withBaseDomian:YES andParameter:changelive data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            //            [self creatLiveTimeView];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark ================ 直播时长的view ===============
- (void)creatLiveTimeView{
    
    liveTimeBGView = [[UIView alloc]initWithFrame:CGRectMake(10, 30+leftW +statusbarHeight+25, 60, 20)];
    liveTimeBGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    liveTimeBGView.layer.cornerRadius = 10.0;
    liveTimeBGView.layer.masksToBounds = YES;
    [frontView addSubview:liveTimeBGView];
    UIView *pointView = [[UIView alloc]initWithFrame:CGRectMake(10, 8.5, 3, 3)];
    pointView.backgroundColor = normalColors;
    pointView.layer.cornerRadius = 1.5;
    pointView.layer.masksToBounds = YES;
    [liveTimeBGView addSubview:pointView];
    
    liveTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(pointView.right+3, 0, 31, 20)];
    liveTimeLabel.textColor = [UIColor whiteColor];
    liveTimeLabel.font = [UIFont systemFontOfSize:10];
    liveTimeLabel.textAlignment = NSTextAlignmentCenter;
    liveTimeLabel.text = @"00:00";
    [liveTimeBGView addSubview:liveTimeLabel];
    liveTime = 0;
    if (!liveTimer) {
        liveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(liveTimeChange) userInfo:nil repeats:YES];
    }
    [[NSRunLoop mainRunLoop] addTimer:liveTimer forMode:NSRunLoopCommonModes];
}
- (void)liveTimeChange{
    liveTime ++;
    if (liveTime < 3600) {
        liveTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",liveTime/60,liveTime%60];
    }else{
        if (liveTimeBGView.width < 73) {
            liveTimeBGView.width = 73;
            liveTimeLabel.width = 44;
        }
        liveTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",liveTime/3600,(liveTime%3600)/60,(liveTime%3600)%60];
    }
}
#pragma mark - state handle
- (void)onStreamError {
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        //        [strongSelf.gpuStreamers.streamerBase stopStream];
        //        [strongSelf.gpuStreamers.streamerBase startStream:strongSelf.hostURL];
    });
}
- (void)onNetStateEvent:(NSNotification *)notification {
    //    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
    //        return;
    //    }
    //    KSYNetStateCode netEvent = _gpuStreamers.streamerBase.netStateCode;
    //    //NSLog(@"net event : %ld", (unsigned long)netEvent );
    //    if ( netEvent == KSYNetStateCode_SEND_PACKET_SLOW ) {
    //
    //        NSLog(@"发送包时间过长，( 单次发送超过 500毫秒 ）");
    //    }
    //    else if ( netEvent == KSYNetStateCode_EST_BW_RAISE ) {
    //
    //        NSLog(@"估计带宽调整，上调" );
    //    }
    //    else if ( netEvent == KSYNetStateCode_EST_BW_DROP ) {
    //
    //
    //        NSLog(@"估计带宽调整，下调" );
    //    }
    //    else if ( netEvent == KSYNetStateCode_KSYAUTHFAILED ) {
    //
    //        NSLog(@"SDK 鉴权失败 (暂时正常推流5~8分钟后终止推流)" );
    //    }
}
- (void) onStreamStateChange:(NSNotification *)notification {
    //    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
    //        return;
    //    }
    //    if ( _gpuStreamers.streamerBase.streamState == KSYStreamStateIdle) {
    //        NSLog(@"推流状态:初始化时状态为空闲");
    //    }
    //    else if ( _gpuStreamers.streamerBase.streamState == KSYStreamStateConnected){
    //        NSLog(@"推流状态:已连接");
    //        [self changePlayState:1];//推流成功后改变直播状态
    //        if (_gpuStreamers.streamerBase.streamErrorCode == KSYStreamErrorCode_KSYAUTHFAILED ) {
    //            //(obsolete)
    //            NSLog(@"推流错误:(obsolete)");
    //        }
    //    }
    //    else if (_gpuStreamers.streamerBase.streamState == KSYStreamStateConnecting ) {
    //        NSLog(@"推流状态:连接中");
    //    }
    //    else if (_gpuStreamers.streamerBase.streamState == KSYStreamStateDisconnecting ) {
    //        NSLog(@"推流状态:断开连接中");
    //        [self onStreamError];
    //    }
    //    else if (_gpuStreamers.streamerBase.streamState == KSYStreamStateError ) {
    //        NSLog(@"推流状态:推流出错");
    //        [self onStreamError];
    //        return;
    //    }
}
//直播结束选择 alertview
- (void)onQuit {
    UIAlertController  *alertlianmaiVCtc = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"Livebroadcast_liveEnd")  preferredStyle:UIAlertControllerStyleAlert];
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    WeakSelf
    UIAlertAction *defaultActionss = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hostStopRoom];
    }];
    
    UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    
    if (version.doubleValue < 9.0) {
        
    }
    else{
        [defaultActionss setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [cancelActionss setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    }
    
    [alertlianmaiVCtc addAction:defaultActionss];
    [alertlianmaiVCtc addAction:cancelActionss];
    
    if (alertlianmaiVCtc.presentedViewController == nil) {
        [self presentViewController:alertlianmaiVCtc animated:YES completion:nil];
    }
}
//警告框  //直播关闭
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }else{
        [self hostStopRoom];
    }
}
//关闭直播做的操作
-(void)hostStopRoom{
    [self getCloseShow];//请求关闭直播接口
}
//直播结束时 停止所有计时器
-(void)liveOver{
    if (lrcTimer) {
        [lrcTimer invalidate];
        lrcTimer = nil;
    }
    if (backGroundTimer) {
        [backGroundTimer invalidate];
        backGroundTimer  = nil;
    }
    if (listTimer) {
        [listTimer invalidate];
        listTimer = nil;
    }
    if (liveTimer) {
        [liveTimer invalidate];
        liveTimer = nil;
    }
    if (hartTimer) {
        [hartTimer invalidate];
        hartTimer = nil;
    }
}
//直播结束时退出房间
-(void)dismissVC{
    if (self.lotteryBarrageArrays) {
        [self.lotteryBarrageArrays removeAllObjects];
    }
    
    if (lotteryView) {
        [lotteryView removeFromSuperview];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLiveing"];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [managerAFH stopMonitoring];
    if (bottombtnV) {
        [bottombtnV removeFromSuperview];
        bottombtnV = nil;
    }
    [userView removeFromSuperview];
    userView = nil;
    [gameState saveProfile:@"0"];//清除游戏状态
    [managerAFH stopMonitoring];
    managerAFH = nil;
    if (continueGifts) {
        [continueGifts stopTimerAndArray];
        [continueGifts initGift];
        [continueGifts removeFromSuperview];
        continueGifts = nil;
    }
    if (haohualiwuV) {
        [haohualiwuV stopHaoHUaLiwu];
        [haohualiwuV removeFromSuperview];
        haohualiwuV.expensiveGiftCount = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
    
    NSDictionary *subdic = [NSDictionary dictionaryWithObjects:@[minstr(urlStrtimestring)] forKeys:@[@"stream"]];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"coin" object:nil userInfo:subdic];
}
/***********  以上推流  *************/
/***************     以下是信息页面          **************/
//加载信息页面
-(void)zhuboMessage{
    if (userView) {
        [userView removeFromSuperview];
        userView = nil;
    }
    
    if (!userView) {
        
        
        //添加用户列表弹窗
        userView = [[upmessageInfo alloc]initWithFrame:CGRectMake(_window_width*0.1,_window_height*2, upViewW, upViewW/3*4+20) andPlayer:@"Livebroadcast"];
        userView.upmessageDelegate = self;
        userView.backgroundColor = [UIColor whiteColor];
        userView.layer.cornerRadius = 10;
        
        //        [MNFloatBtn hidden];
        UIWindow *mainwindows = [UIApplication sharedApplication].keyWindow;
        [mainwindows addSubview:userView];
        //        [MNFloatBtn show];
        
    }
    self.tanChuangID = [Config getOwnID];
    self.tanchuangName = [Config getOwnNicename];
    NSDictionary *subdic = @{@"id":[Config getOwnID]};
    [self GetInformessage:subdic];
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->userView.frame = CGRectMake(_window_width*0.1,(_window_height-upViewW*4/3)/2,upViewW,upViewW*4/3+20);
    }];
}
-(void)GetInformessage:(NSDictionary *)subdic{
    if (userView) {
        [userView removeFromSuperview];
        userView = nil;
    }
    
    NSDictionary *subdics = @{@"uid":[Config getOwnID],
                              @"avatar":[Config getavatar]
    };
    if (!userView) {
        //添加用户列表弹窗
        //            [MNFloatBtn hidden];
        userView = [[upmessageInfo alloc]initWithFrame:CGRectMake(_window_width*0.1,_window_height*2, upViewW, upViewW*4/3+20) andPlayer:@"Livebroadcast"];
        userView.upmessageDelegate = self;
        userView.backgroundColor = [UIColor whiteColor];
        userView.layer.cornerRadius = 10;
        UIWindow *mainwindows = [UIApplication sharedApplication].keyWindow;
        [mainwindows addSubview:userView];
        //            [MNFloatBtn show];
    }
    //用户弹窗
    self.tanChuangID = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
    self.tanchuangName = [subdic valueForKey:@"name"];
    [userView getUpmessgeinfo:subdic andzhuboModel:[hotModel mj_objectWithKeyValues:subdics]];
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->userView.frame = CGRectMake(_window_width*0.1,(_window_height-upViewW*4/3)/2,upViewW,upViewW*4/3+20);
    }];
}
/// 动画完后销毁iamgeView
- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UIImageView *imageViewsss = (__bridge UIImageView *)(context);
    [imageViewsss removeFromSuperview];
    imageViewsss = nil;
}
-(void)setView{
    
    //左上角 直播live
    leftView = [[UIView alloc]initWithFrame:CGRectMake(10,25+statusbarHeight,115,leftW)];
    leftView.layer.cornerRadius = leftW/2;
    leftView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    //主播头像button
    UIButton *IconBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [IconBTN addTarget:self action:@selector(zhuboMessage) forControlEvents:UIControlEventTouchUpInside];
    IconBTN.frame = CGRectMake(1, 1, leftW-2, leftW-2);
    IconBTN.layer.masksToBounds = YES;
    IconBTN.layer.borderWidth = 1;
    IconBTN.layer.borderColor = normalColors.CGColor;
    IconBTN.layer.cornerRadius = leftW/2-1;
    UITapGestureRecognizer *tapleft = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboMessage)];
    tapleft.numberOfTapsRequired = 1;
    tapleft.numberOfTouchesRequired = 1;
    [leftView addGestureRecognizer:tapleft];
    LiveUser *user = [[LiveUser alloc]init];
    user = [Config myProfile];
    NSURL *url = [NSURL URLWithString:[Config getavatar]];
//    [IconBTN sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[ImageBundle imagewithBundleName:@"default_head.png"]];
    [IconBTN sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];

    UIImageView *levelimage = [[UIImageView alloc]initWithFrame:CGRectMake(IconBTN.right - 15,IconBTN.bottom - 15,15,15)];
    NSDictionary *levelDic = [common getAnchorLevelMessage:[Config level_anchor]];
    [levelimage sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb_mark"])]];
    
    
    //主播名称
    UILabel *nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftW+4,2,65,leftW/2)];
    nickNameLabel.textAlignment = NSTextAlignmentLeft;
    nickNameLabel.text = [Config getOwnNicename];
    nickNameLabel.textColor = [UIColor whiteColor];
    //liveLabel.shadowColor = [UIColor lightGrayColor];
    nickNameLabel.shadowOffset = CGSizeMake(1,1);//设置阴影
    nickNameLabel.font = fontMT(10);
    float nameWidth = [[YBToolClass sharedInstance] widthOfString:[Config getOwnNicename] andFont:fontMT(10) andHeight:leftW/2];
    if (nameWidth>80) {
        nameWidth = 80;
    }
    if (nameWidth<65) {
        nameWidth = 65;
    }
    nickNameLabel.width = nameWidth;
    leftView.width = leftW+4 + nameWidth+4;
    
    //主播ID
    onlineLabel = [[UILabel alloc]init];
    onlineLabel.frame = CGRectMake(leftW+4,leftW/2,65,leftW/2);
    onlineLabel.textAlignment = NSTextAlignmentLeft;
    onlineLabel.textColor = [UIColor whiteColor];
    onlineLabel.font = fontMT(10);
    NSString *liangname = [NSString stringWithFormat:@"%@",[_roomModel.liang valueForKey:@"name"]];
    if ([liangname isEqual:@"0"]) {
        onlineLabel.text = [NSString stringWithFormat:@"ID:%@",[Config getOwnID]];
    }else{
        onlineLabel.text = [NSString stringWithFormat:@"%@:%@",YZMsg(@"public_liang"),liangname];
    }
    
    //聊天
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, _window_height - _window_height*0.35 - 40 - ShowDiff,tableWidth,_window_height*0.24) style:UITableViewStylePlain];
    [self tableviewheight:_window_height - _window_height*0.35 - 40 - ShowDiff];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.clipsToBounds = YES;
    self.tableView.shouldIgnoreScrollingAdjustment  = YES;
    
    self.userTableView = [[UITableView alloc]initWithFrame:CGRectMake(10,_window_height - _window_height*0.11 - 40 - ShowDiff,tableWidth,_window_height*0.11) style:UITableViewStylePlain];
    [self tableviewheight:_window_height - _window_height*0.35 - 40 - ShowDiff];
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    self.userTableView.backgroundColor = [UIColor clearColor];
    self.userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userTableView.showsVerticalScrollIndicator = false;
    self.userTableView.shouldIgnoreScrollingAdjustment  = 1;
    
    newMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newMsgButton addTarget:self action:@selector(scrollToLastCell) forControlEvents:UIControlEventTouchUpInside];
    newMsgButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [newMsgButton setTitleColor:RGB(95, 159, 210) forState:UIControlStateNormal];
    [newMsgButton setImage:[ImageBundle imagewithBundleName:@"arrowDown"] forState:UIControlStateNormal];
    newMsgButton.layer.cornerRadius = 10;
    newMsgButton.layer.masksToBounds = YES;
    newMsgButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    [newMsgButton setTitle:YZMsg(@"Livebroadcast_haveNewMsgs") forState:UIControlStateNormal];
    newMsgButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    newMsgButton.titleLabel.minimumScaleFactor = 0.5;
    newMsgButton.alpha = 0;
    newMsgButton.frame = CGRectMake(self.tableView.left, _tableViewBottom, 80, 20);
    
    
    //输入框
    keyField = [[UITextField alloc]initWithFrame:CGRectMake(70,7,_window_width-90 - 50, 30)];
    keyField.returnKeyType = UIReturnKeySend;
    keyField.delegate  = self;
    keyField.borderStyle = UITextBorderStyleNone;
    keyField.placeholder = YZMsg(@"Livebroadcast_SayHi");
    keyField.backgroundColor = [UIColor whiteColor];
    keyField.layer.cornerRadius = 15.0;
    keyField.layer.masksToBounds = YES;
    UIView *fieldLeft = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 30)];
    fieldLeft.backgroundColor = [UIColor whiteColor];
    keyField.leftView = fieldLeft;
    keyField.leftViewMode = UITextFieldViewModeAlways;
    keyField.font = [UIFont systemFontOfSize:15];
    
    www = 30;
    //键盘出现
    keyBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    keyBTN.tintColor = [UIColor whiteColor];
    keyBTN.userInteractionEnabled = YES;
    [keyBTN setBackgroundImage:[[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(120, www)] sd_imageByRoundCornerRadius:www/2] forState:UIControlStateNormal];
    [keyBTN setTitle:YZMsg(@"Livebroadcast_SaySomething") forState:UIControlStateNormal];
    [keyBTN.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [keyBTN addTarget:self action:@selector(showkeyboard:) forControlEvents:UIControlEventTouchUpInside];
    keyBTN.layer.masksToBounds = YES;
    keyBTN.layer.shadowColor = [UIColor blackColor].CGColor;
    keyBTN.layer.shadowOffset = CGSizeMake(1, 1);
    
    
    //隐藏广告
    hidenAdvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hidenAdvBtn.tintColor = [UIColor whiteColor];
    hidenAdvBtn.userInteractionEnabled = YES;
    [hidenAdvBtn setTitle:YZMsg(@"Livebroadcast_OnlyMsgs") forState:UIControlStateNormal];
    [hidenAdvBtn setImage:[ImageBundle imagewithBundleName:@"select_chat"] forState:UIControlStateSelected];
    [hidenAdvBtn setImage:[ImageBundle imagewithBundleName:@"selectN_chat"] forState:UIControlStateNormal];
    [hidenAdvBtn setBackgroundImage:[[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(80, www)] sd_imageByRoundCornerRadius:www/2] forState:UIControlStateNormal];
    [hidenAdvBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    hidenAdvBtn.layer.masksToBounds = YES;
    hidenAdvBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    hidenAdvBtn.layer.shadowOffset = CGSizeMake(1, 1);
    [hidenAdvBtn addTarget:self action:@selector(hidenAdvAction:) forControlEvents:UIControlEventTouchUpInside];
    hidenAdvBtn.frame = CGRectMake(140, _window_height - 45-ShowDiff, 70, 30);
    [hidenAdvBtn sizeToFit];
    hidenAdvBtn.frame = CGRectMake(140, _window_height - 45-ShowDiff, hidenAdvBtn.width, 30);
    BOOL isCloseAdv = [[NSUserDefaults standardUserDefaults] boolForKey:@"isCloseAdv"];
    hidenAdvBtn.selected = isCloseAdv;
    
    //发送按钮
    pushBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [pushBTN setImage:[ImageBundle imagewithBundleName:@"chat_send_gray"] forState:UIControlStateNormal];
    [pushBTN setImage:[ImageBundle imagewithBundleName:@"chat_send_yellow"] forState:UIControlStateSelected];
    pushBTN.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    pushBTN.layer.masksToBounds = YES;
    pushBTN.layer.cornerRadius = 5;
    [pushBTN addTarget:self action:@selector(pushMessage:) forControlEvents:UIControlEventTouchUpInside];
    pushBTN.frame = CGRectMake(_window_width-55,7,50,30);
    cs = [[catSwitch alloc] initWithFrame:CGRectMake(6,11,44,22)];
    cs.delegate = self;
    //退出页面按钮
    closeLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeLiveBtn.tintColor = [UIColor whiteColor];
    [closeLiveBtn setImage:[ImageBundle imagewithBundleName:@"cancleliveshow"] forState:UIControlStateNormal];
    [closeLiveBtn addTarget:self action:@selector(onQuit) forControlEvents:UIControlEventTouchUpInside];
    //消息按钮
    
    
    
    // 彩票
    lotteryBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    lotteryBTN.tintColor = [UIColor whiteColor];
    lotteryBTN.layer.shadowColor = [UIColor blackColor].CGColor;
    lotteryBTN.layer.shadowOffset = CGSizeMake(3, 3);
    lotteryBTN.layer.shadowOpacity = 0.7;
    lotteryBTN.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    lotteryBTN.titleLabel.layer.shadowOffset = CGSizeMake(1, 1);
    lotteryBTN.titleLabel.layer.shadowOpacity = 0.7;
    lotteryBTN.titleLabel.adjustsFontSizeToFitWidth = YES;
    lotteryBTN.hidden = YES;
    
    [lotteryBTN setTitle:@"" forState:UIControlStateNormal]; // 11111111111
    //    [_lotteryBTN setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    lotteryBTN.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    //    oneKeyRecoverBtn.titleLabel.textColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:153/255.f alpha:1.f];
    [lotteryBTN.titleLabel setTextColor:RGB_COLOR(@"#FF3399", 1)];
    //    _lotteryBTN.titleLabel.hidden = NO;
    //_lotteryBTN.titleEdgeInsets = UIEdgeInsetsMake(45, 0, 0, 0);
    [lotteryBTN setTitleEdgeInsets:UIEdgeInsetsMake(75, 0, 0, 0)];
    
    [lotteryBTN addTarget:self action:@selector(doLottery) forControlEvents:UIControlEventTouchUpInside];
    
    //camera按钮
    moreBTN = [UIButton buttonWithType:UIButtonTypeSystem];
    moreBTN.tintColor = [UIColor whiteColor];
    [moreBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"Function"] forState:UIControlStateNormal];
    [moreBTN addTarget:self action:@selector(showmoreview) forControlEvents:UIControlEventTouchUpInside];
    
    //PK按钮
    redBagBtn = [UIButton buttonWithType:0];
    [redBagBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"redpack-right"] forState:UIControlStateNormal];
    [redBagBtn addTarget:self action:@selector(redBagBtnClick) forControlEvents:UIControlEventTouchUpInside];
    redBagBtn.hidden = YES;
    /*==================  连麦  ================*/
    //tool绑定键盘
    toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height+10, _window_width, 44)];
    toolBar.backgroundColor = [UIColor clearColor];
    UIView *tooBgv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 44)];
    tooBgv.backgroundColor = [UIColor whiteColor];
    tooBgv.alpha = 0.7;
    [toolBar addSubview:tooBgv];
    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(cs.right+9, cs.top, 1, 20)];
    line1.backgroundColor = RGB(176, 176, 176);
    line1.alpha = 0.5;
    [toolBar addSubview:line1];
    UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(keyField.right+7, line1.top, 1, 20)];
    line2.backgroundColor = line1.backgroundColor;
    line2.alpha = line1.alpha;
    [toolBar addSubview:line2];
    [toolBar addSubview:pushBTN];
    [toolBar addSubview:keyField];
    [toolBar addSubview:cs];
    [frontView addSubview:keyBTN];
    
    
    [frontView addSubview:hidenAdvBtn];
    //关闭连麦按钮
    //直播间按钮（竞拍，游戏，扣费，后台控制隐藏,createroom接口传进来）
    [self changeBtnFrame:_window_height - 45];
    [leftView addSubview:onlineLabel];
    [leftView addSubview:nickNameLabel];
    [leftView addSubview:IconBTN];
    [leftView addSubview:levelimage];
    
    [frontView addSubview:leftView];
    [frontView addSubview:moreBTN];
    [frontView addSubview:closeLiveBtn];
    [self.view addSubview:redBagBtn];
    
    [self hideBTN];
    /*==================  连麦  ================*/
    [self.view addSubview:toolBar];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangePushBtnState) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.view insertSubview:self.tableView atIndex:4];
    [self.view insertSubview:self.userTableView atIndex:4];
    
    useraimation = [[userLoginAnimation alloc]init];
    useraimation.frame = CGRectMake(10,_tableViewTop - 40,_window_width,20);
    [self.view insertSubview:useraimation atIndex:5];
    useraimation.userInteractionEnabled = false;
    
    nuseraimation = [[nuserLoginAnimation alloc]init];
    nuseraimation.frame = CGRectMake(10,_tableViewBottom - 5,_window_width,20);
    [self.view insertSubview:nuseraimation atIndex:5];
    nuseraimation.userInteractionEnabled = false;
    
    danmuview = [[GrounderSuperView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 140)];
    [frontView insertSubview:danmuview atIndex:6];
    liansongliwubottomview = [[UIView alloc]init];
    [frontView insertSubview:liansongliwubottomview atIndex:10];
    liansongliwubottomview.frame = CGRectMake(0,_tableViewTop -150,_window_width/2,140);
    
    [self.tableView.superview addSubview:newMsgButton];
    
}
-(void)hidenAdvAction:(UIButton*)button{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    BOOL isCloseAdv = [defaults boolForKey:@"isCloseAdv"];
    if(!isCloseAdv){
        UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *pickAction = [UIAlertAction actionWithTitle:YZMsg(@"filter_belowf") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
            [defaults setObject: @"100" forKey:@"live_betNum"];
            [defaults setBool:button.selected forKey:@"isCloseAdv"];
            [defaults synchronize];
            [MBProgressHUD showSuccess:YZMsg(@"live_close_adv")];
        }];
        UIAlertAction *pickAction1 = [UIAlertAction actionWithTitle:YZMsg(@"filter_belows") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
            [defaults setObject: @"1000" forKey:@"live_betNum"];
            [defaults setBool:button.selected forKey:@"isCloseAdv"];
            [defaults synchronize];
            [MBProgressHUD showSuccess:YZMsg(@"live_close_adv")];
        }];
        UIAlertAction *pickAction2 = [UIAlertAction actionWithTitle:YZMsg(@"filter_belowt") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            button.selected = !button.selected;
            [defaults setObject: @"10000" forKey:@"live_betNum"];
            [defaults setBool:button.selected forKey:@"isCloseAdv"];
            [defaults synchronize];
            [MBProgressHUD showSuccess:YZMsg(@"live_close_adv")];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [actionSheetController addAction:cancelAction];
        [actionSheetController addAction:pickAction];
        [actionSheetController addAction:pickAction1];
        [actionSheetController addAction:pickAction2];
        [self presentViewController:actionSheetController animated:YES completion:nil];
    }else{
        button.selected = !button.selected;
        [defaults setBool:button.selected forKey:@"isCloseAdv"];
        [defaults synchronize];
        [MBProgressHUD showSuccess:YZMsg(@"live_open_adv")];
    }
}
-(void)hidecoastview{
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->coastview.frame = CGRectMake(0, -_window_height, _window_width, _window_height);
    }];
}
#pragma mark ===========//弹出门票
-(void)menpiaos{
    roomType = @"2";
    NSDictionary *subdic = @{
        @"uid":[NSNumber numberWithInt:[[Config getOwnID]intValue]],
        @"token":[Config getOwnToken],
        @"stream":urlStrtimestring,
        @"type":@"2",
        @"type_val":roomTypeValue
    };
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.changeLiveType"];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:subdic data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showError:msg];
            strongSelf->isQie = NO;
            if (strongSelf->socketL) {
                [strongSelf->socketL changeLiveType:strongSelf->roomTypeValue changetype:strongSelf->roomType];
            }
            [MBProgressHUD hideHUD];
        }
    } fail:^(id fail) {
        [MBProgressHUD hideHUD];
    }];
}
#pragma mark ============//弹出收费弹窗
-(void)doupcoast{
    NSString *textstring = @"3";
    //roomType = @"3";
    if (!coastview) {
        WeakSelf
        coastview = [[coastselectview alloc]initWithFrame:CGRectMake(0, -_window_height, _window_width, _window_height) andsureblock:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.preFrontView) {
                strongSelf->roomType = @"3";
                strongSelf->roomTypeValue = type;
                [strongSelf changeRoomBtnState:[NSString stringWithFormat:@"%@%@",YZMsg(@"Livebroadcast_room_type_time"),YZMsg(@"Livebroadcast_room")]];
                [strongSelf hidecoastview];
            }else{
                strongSelf->coastmoney = type;
                //Live.changeLiveType
                NSDictionary *subdic = @{
                    @"uid":[NSNumber numberWithInt:[[Config getOwnID]intValue]],
                    @"token":[Config getOwnToken], @"stream":strongSelf->urlStrtimestring,
                    @"type":@"3",
                    @"type_val":strongSelf->coastmoney
                };
                NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.changeLiveType"];
                [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:subdic data:nil success:^(int code, NSArray *info, NSString *msg) {
                    //NSLog(@"===%@",data);
                    if (strongSelf == nil) {
                        return;
                    }
                    if (code == 0) {
                        strongSelf->isQie = NO;
                        [MBProgressHUD showError:msg];
                        if (strongSelf->socketL) {
                            [strongSelf->socketL changeLiveType:strongSelf->coastmoney changetype:textstring];
                        }
                        //收费金额
                        [strongSelf hidecoastview];
                        //[MBProgressHUD hideHUD];
                    }
                } fail:^(id fail) {
                    [MBProgressHUD hideHUD];
                }];
                
            }
        } andcancleblock:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            //取消
            [strongSelf hidecoastview];
        }];
        [self.view addSubview:coastview];
    }
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->coastview.frame = CGRectMake(0,0, _window_width, _window_height);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [UIView animateWithDuration:0.1 animations:^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf->coastview.frame = CGRectMake(0,20,_window_width, _window_height);
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [UIView animateWithDuration:0.1 animations:^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf->coastview.frame = CGRectMake(0, 0, _window_width, _window_height);
        }];
    });
    coastview.userInteractionEnabled = YES;
}
- (void)doShareViewShow{
    if (!fenxiangV) {
        //分享弹窗
        fenxiangV = [[fenXiangView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height)];
        NSDictionary *mudic = @{
            @"user_nicename":[Config getOwnNicename],
            @"avatar_thumb":[Config getavatarThumb],
            @"uid":[Config getOwnID]
        };
        
        [fenxiangV GetModel:[hotModel mj_objectWithKeyValues:mudic]];
        [self.view addSubview:fenxiangV];
    }else{
        [fenxiangV show];
    }
    
}
-(void)toolbarHidden
{
    [self showBTN];
    toolBar.frame = CGRectMake(0, _window_height+10, _window_width, 44);
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
    
}
///新消息提醒
-(void)hidenNewMessages:(BOOL)hiden
{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->newMsgButton.alpha = hiden?0:1;
        strongSelf->newMsgButton.top = _tableViewBottom + (hiden?0:-30);
    }];
}

-(void)toolbarClick:(id)sender
{
    [keyField resignFirstResponder];
    toolBar.frame = CGRectMake(0, _window_height+10, _window_width, 44);
}
///浪花显示
-(void)changeState{
    NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(_voteNums) showUnit:YES];
    if (!yingpiaoLabel) {
        //魅力值//魅力值
        //修改 魅力值 适应字体 欣
        UIFont *font1 = [UIFont systemFontOfSize:12];
        NSString *str = [NSString stringWithFormat:@"%@ >",currencyCoin];
        CGFloat width = [[YBToolClass sharedInstance] widthOfString:str andFont:font1 andHeight:20];
        yingpiaoLabel  = [[UILabel alloc]init];
        yingpiaoLabel.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        yingpiaoLabel.font = font1;
        yingpiaoLabel.text = str;
        yingpiaoLabel.frame = CGRectMake(10,30+leftView.frame.size.height +statusbarHeight, width+30,20);
        yingpiaoLabel.textAlignment = NSTextAlignmentCenter;
        yingpiaoLabel.textColor = [UIColor whiteColor];
        yingpiaoLabel.layer.cornerRadius = 10.0;
        yingpiaoLabel.layer.masksToBounds  =YES;
        UITapGestureRecognizer *yingpiaoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yingpiao)];
        [yingpiaoLabel addGestureRecognizer:yingpiaoTap];
        yingpiaoLabel.userInteractionEnabled = YES;
        [frontView addSubview:yingpiaoLabel];
    }else{
        UIFont *font1 = [UIFont systemFontOfSize:12];
        NSString *str = [NSString stringWithFormat:@"%@ >", currencyCoin];
        CGFloat width = [[YBToolClass sharedInstance] widthOfString:str andFont:font1 andHeight:20]+30;
        yingpiaoLabel.width = width;
        yingpiaoLabel.text = str;
        guardBtn.frame = CGRectMake(yingpiaoLabel.right+5, yingpiaoLabel.top, guardWidth+20, yingpiaoLabel.height);
        [self todayTopButtonShow];
    }
}
///守护按钮
- (void)changeGuardNum:(NSString *)nums{
    if (!guardBtn) {
        guardWidth = [[YBToolClass sharedInstance] widthOfString:YZMsg(@"setViewM_guardTitle") andFont:[UIFont systemFontOfSize:12] andHeight:20];
        guardBtn = [UIButton buttonWithType:0];
        guardBtn.frame = CGRectMake(yingpiaoLabel.right+5, yingpiaoLabel.top, guardWidth+20, yingpiaoLabel.height);
        guardBtn.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [guardBtn addTarget:self action:@selector(guardBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [guardBtn setTitle:YZMsg(@"setViewM_guardTitle") forState:0];
        guardBtn.layer.cornerRadius = 10;
        guardBtn.layer.masksToBounds = YES;
        guardBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [frontView addSubview:guardBtn];
    }
    //if (![nums isEqual:@"0"]) {
        [guardBtn setTitle:[NSString stringWithFormat:@"%@ %@%@ >",YZMsg(@"setViewM_Guard"),nums,YZMsg(@"setViewM_People")] forState:0];
        guardWidth = [[YBToolClass sharedInstance] widthOfString:guardBtn.titleLabel.text andFont:[UIFont systemFontOfSize:12] andHeight:20];
        guardBtn.frame = CGRectMake(yingpiaoLabel.right+5, yingpiaoLabel.top, guardWidth+20, yingpiaoLabel.height);
    //}
    [self todayTopButtonShow];
}
///实时榜
-(void)todayTopButtonShow
{
    ///实时榜单
    if (!topTodayButton) {
        topTodayButton = [UIButton buttonWithType:0];
        topTodayButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        [topTodayButton addTarget:self action:@selector(topTodayClick) forControlEvents:UIControlEventTouchUpInside];
        [topTodayButton setTitle:YZMsg(@"setViewM_Top_list") forState:0];
        topTodayButton.layer.cornerRadius = 10;
        topTodayButton.layer.masksToBounds = YES;
        topTodayButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [frontView addSubview:topTodayButton];
        
        UIButton *speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        speedButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        speedButton.layer.cornerRadius = 10;
        speedButton.layer.masksToBounds = YES;
        speedButton.titleLabel.font = [UIFont systemFontOfSize:8];
        speedButton.titleLabel.textColor = UIColor.whiteColor;
        speedButton.titleLabel.numberOfLines = 0;
        speedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        speedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        speedButton.userInteractionEnabled = NO;
        [frontView addSubview:speedButton];
        self.speedButton = speedButton;
        [speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(topTodayButton.mas_centerY);
            make.left.mas_equalTo(topTodayButton.mas_right).offset(5);
            make.height.mas_equalTo(topTodayButton.mas_height);
        }];
    }
    topTodayButton.frame = CGRectMake(guardBtn.right+5, yingpiaoLabel.top, 70, yingpiaoLabel.height);
}
///弹出实时榜
-(void)topTodayClick
{
    [self doCancle];
    [TopTodayView showInView:self.view model:nil delegate:nil];
    
}

#pragma ====mark//跳往魅力值界面
-(void)yingpiao{
    
    webH5 *jumpC = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=contribute&a=index&uid=%@&touid=%@&token=%@",[DomainManager sharedInstance].domainGetString,[Config getOwnID],[Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    jumpC.urls = url;
    [self.navigationController pushViewController:jumpC animated:YES];
    
}
-(void)changeMusic:(NSNotification *)notifition{
    
    //    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
    //        return;
    //    }
    //    _count = 0;
    //    [musicV removeFromSuperview];
    //    musicV = nil;
    //
    //    [_gpuStreamers.bgmPlayer stopPlayBgm];
    //
    //    _isPlayLrcing = NO;
    //    if (lrcTimer) {
    //        [lrcTimer invalidate];
    //        lrcTimer =nil;
    //    }
    //    NSDictionary *dic = [notifition userInfo];
    //    NSString *musicPath  = [dic valueForKey:@"music"];
    //    muaicPath = [dic valueForKey:@"lrc"];
    //    NSFileManager *managers=[NSFileManager defaultManager];
    //    if ([managers fileExistsAtPath:musicPath]) {
    //        [_gpuStreamers.bgmPlayer startPlayBgm:musicPath isLoop:NO];
    //        _gpuStreamers.bgmPlayer.bgmVolume = 0.2;
    //        [_gpuStreamers.aMixer setMixVolume:0.2 of:_gpuStreamers.bgmTrack];
    //        [_gpuStreamers.aMixer setMixVolume:1.0 of:_gpuStreamers.micTrack];
    //
    //    }
    //    else{
    //        NSLog(@"歌曲不存在");
    //    }
}
//手指拖拽音乐移动
-(void)musicPan:(UIPanGestureRecognizer *)sender{
    CGPoint point = [sender translationInView:sender.view];
    CGPoint center = sender.view.center;
    center.x += point.x;
    center.y += point.y;
    musicV.center = center;
    //清空
    [sender setTranslation:CGPointZero inView:sender.view];
}
//TODO:更新ing歌曲播放时间
-(void)updateMusicTimeLabel{
    //    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
    //        return;
    //    }
    //    if ((int)_gpuStreamers.bgmPlayer.bgmPlayTime % 60 < 10) {
    //        self.timeLabel.text = [NSString stringWithFormat:@"%d:0%d",(int)_gpuStreamers.bgmPlayer.bgmPlayTime / 60, (int)_gpuStreamers.bgmPlayer.bgmPlayTime % 60];
    //    }
    //    else {
    //        self.timeLabel.text = [NSString stringWithFormat:@"%d:%d",(int)_gpuStreamers.bgmPlayer.bgmPlayTime / 60, (int)_gpuStreamers.bgmPlayer.bgmPlayTime % 60];
    //    }
    //    NSDictionary *dic = self.lrcList[_count];
    //    NSArray *array = [dic[@"lrctime"] componentsSeparatedByString:@":"];//把时间转换成秒
    //    NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
    //    //判断是否播放歌词
    //    if (_gpuStreamers.bgmPlayer.bgmPlayTime >= currentTime && _isPlayLrcing == NO) {
    //        [lrcView beganLrc:self.lrcList];
    //        _isPlayLrcing = YES;
    //    }
    //    if (_gpuStreamers.bgmPlayer.bgmPlayerState != KSYBgmPlayerStatePlaying) {
    //        [self musicPlay];
    //    }
}
//关闭音乐
-(void)musicPlay{
//    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
//        return;
//    }
    
    if (lrcView.timelrc) {
        [lrcView.timelrc invalidate];
        lrcView.timelrc = nil;
    }
    if (lrcView) {
        [lrcView removeFromSuperview];
        lrcView = nil;
    }
    _count = 0;
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    //    [_gpuStreamers.bgmPlayer stopPlayBgm];
    [musicV removeFromSuperview];
    if (lrcTimer) {
        [lrcTimer invalidate];
        lrcTimer = nil;
    }
    
}

-(void)showmoreviews{
    //添加的镜像，闪光灯。。。
    WeakSelf
    if (!bottombtnV) {
        bottombtnV = [[bottombuttonv alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height) music:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
//            if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
//                return;
//            }
            [strongSelf justplaymusic];//播放音乐
        } meiyan:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf initTiFaceUI];//萌颜
            
        } coast:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf doShareViewShow];//分享
        } light:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf toggleTorch];//闪光灯
            //            [weakself showBGMView];
            
        } camera:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf rotateCamera];//切换摄像头
        } game:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            
        } jingpai:^(NSString *type) {
            //开始竞拍
            
        } hongbao:^(NSString *type) {
            //红包
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf showRedView];
        } lianmai:^(NSString *type) {
            
        } jishi:^(NSString *type){//计时房间
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf jishi];
        } piaofang:^(NSString *type){//门票房间
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf menpiao];
        }showjingpai:@"0" showgame:_game_switch showcoase:_type hideself:^(NSString *type) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [UIView animateWithDuration:0.4 animations:^{
                if (strongSelf == nil) {
                    return;
                }
                strongSelf->bottombtnV.frame = CGRectMake(0, _window_height*2, _window_width, _window_height);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf->moreBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"Function"] forState:UIControlStateNormal];
                [strongSelf->bottombtnV removeFromSuperview];
                strongSelf->bottombtnV = nil;
            });
        } andIsTorch:isTorch];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:bottombtnV];
        bottombtnV.hidden = YES;
        [moreBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"Function_S"] forState:UIControlStateNormal];
    }
}
-(void)toggleTorch{
    
//    if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
//
//    }else{
//        //        if ([_gpuStreamers.vCapDev isTorchSupported]) {
//        //           [_gpuStreamers toggleTorch];
//        //        }
//    }
    isTorch = !isTorch;
   
    [_np enableTorch:isTorch];
    
}
-(void)rotateCamera{
    dispatch_main_async_safe(^{
        if ([LiveEncodeCommon sharedInstance].isOpenEncodeSDK) {
            [self.np switchCamera];
        }else{
            //        [_gpuStreamers.vCapDev rotateCamera];
        }
    });
}
#pragma mark =================计时==========================
-(void)jishi{
    if ([minstr(roomType) isEqualToString:@"0"]) {
        if (isQie == YES) {
            [self doupcoast];
        }else{
            [MBProgressHUD showError:YZMsg(@"Livebroadcast_switchRoom_cannot")];
        }
    }else{
        [MBProgressHUD showError:YZMsg(@"Livebroadcast_switchRoom_cannot1")];
    }
    
    
}
-(void)menpiao{
    if ([roomType isEqualToString:@"0"]) {
        if (isQie == YES) {
            UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"Livebroadcast_please_set_ticket_price")    message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alertContro addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {                textField.placeholder = YZMsg(@"Livebroadcast_please_enterPrice");
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertContro addAction:cancleAction];
            WeakSelf
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                UITextField *envirnmentNameTextField = alertContro.textFields.firstObject;
                if (envirnmentNameTextField.text == nil || envirnmentNameTextField.text == NULL || envirnmentNameTextField.text.length == 0) {
                    [MBProgressHUD showError:YZMsg(@"Livebroadcast_please_rightTicket_price")];
                    if (strongSelf.presentedViewController == nil) {
                        [strongSelf presentViewController:alertContro animated:YES completion:nil];
                    }
                    
                }else{
                    NSString *rmbCoin = [YBToolClass getRmbCurrency:envirnmentNameTextField.text];
                    strongSelf->roomTypeValue = rmbCoin;
                    strongSelf->roomType = @"2";
                    // [self changeRoomBtnState:@"门票房间"];
                    [strongSelf menpiaos];
                }
            }];
            [alertContro addAction:sureAction];
            if (self.presentedViewController == nil) {
                [self presentViewController:alertContro animated:YES completion:nil];
            }
        }else{
            [MBProgressHUD showError:YZMsg(@"Livebroadcast_switchRoom_cannot")];
        }
    }else{
        [MBProgressHUD showError:YZMsg(@"Livebroadcast_switchRoom_cannot1")];
    }
    
    
}
-(void)justplaymusic{
    musicView *music = [[musicView alloc]init];
    music.modalPresentationStyle = UIModalPresentationFullScreen;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:music];
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 1;
    self.animator.behindViewScale = 0.5f;
    self.animator.transitionDuration = 0.4f;
    music.transitioningDelegate = self.animator;
    self.animator.dragable = YES;
    self.animator.direction = ZFModalTransitonDirectionRight;
    
    if (self.presentedViewController == nil) {
        [self presentViewController:music animated:YES completion:nil];
    }
}

-(void)showmoreview{
    
    if (!bottombtnV) {
        [self showmoreviews];
    }
    WeakSelf
    if (bottombtnV.hidden == YES) {
        bottombtnV.hidden = NO;
        
        [UIView animateWithDuration:0.4 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->bottombtnV.frame = CGRectMake(0,0, _window_width, _window_height);
        }];
        
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->bottombtnV.frame = CGRectMake(0, _window_height*2, _window_width, _window_height);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->bottombtnV.hidden = YES;
        });
    }
}
-(void)donghua:(UILabel *)labels{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.8;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(4.0, 4.0, 4.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(3.0, 3.0, 3.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 2.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)]];
    animation.values = values;
    animation.removedOnCompletion = NO;//是不是移除动画的效果
    animation.fillMode = kCAFillModeForwards;//保持最新状态
    [labels.layer addAnimation:animation forKey:nil];
}
#pragma mark ---- 私信方法
-(void)nsnotifition{
    //注册进入后台的处理
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self
                     selector:@selector(appactive)
                         name:UIApplicationDidBecomeActiveNotification
                       object:nil];
    [notification addObserver:self
                     selector:@selector(appnoactive)
                         name:UIApplicationWillResignActiveNotification
                       object:nil];
    
    [notification addObserver:self selector:@selector(changeMusic:) name:@"wangminxindemusicplay" object:nil];
    [notification addObserver:self selector:@selector(shajincheng) name:@"shajincheng" object:nil];
    //@"shajincheng"
    //    [notification addObserver:self selector:@selector(forsixin:) name:@"sixinok" object:nil];
    [notification addObserver:self selector:@selector(getweidulabel) name:@"gengxinweidu" object:nil];
    [notification addObserver:self selector:@selector(toolbarHidden) name:@"toolbarHidden" object:nil];
    //    [notification addObserver:self selector:@selector(onAudioStateChange:)name:KSYAudioStateDidChangeNotification object:nil];
    
}
//更新未读消息
-(void)getweidulabel{
    
}

//-(void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error{
//    
//}
-(void)doLottery{
    [_remoteInterfaceView forceShrink:CGPointMake(0, CGRectGetMaxY(yingpiaoLabel.frame) + 10)];
    [self doLotteryWithtype:[minstr(roomLotteryInfo[@"lotteryType"]) integerValue]];
}
-(void)doLotteryWithtype:(NSInteger)type
{
    if (curLotteryBetVC!= nil && curLotteryBetVC.parentViewController!= nil) {
        if ([curLotteryBetVC respondsToSelector:@selector(exitView)]) {
            [curLotteryBetVC exitView];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [hud hideAnimated:YES];
                [strongSelf doLotteryWithtype:type];
            });
            return;
        }
    }
    WeakSelf
    if (type == 10) {
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_NN alloc]initWithNibName:@"LotteryBetViewController_NN" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_NN*)curLotteryBetVC).lotteryDelegate =  weakSelf;
        ((LotteryBetViewController_NN*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type == 26&& ![YBToolClass sharedInstance].default_old_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_YFKS alloc]initWithNibName:@"LotteryBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_YFKS*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_YFKS*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type == 28 && ![YBToolClass sharedInstance].default_oldBJL_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_BJL alloc]initWithNibName:@"LotteryBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_BJL*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_BJL*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type == 29 && ![YBToolClass sharedInstance].default_oldZJH_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZJH alloc]initWithNibName:@"LotteryBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZJH*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_ZJH*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type == 30 && ![YBToolClass sharedInstance].default_oldZP_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZP alloc]initWithNibName:@"LotteryBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZP*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_ZP*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type == 31 && ![YBToolClass sharedInstance].default_oldLH_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LH alloc]initWithNibName:@"LotteryBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LH*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_LH*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type ==40){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LB alloc]initWithNibName:@"LotteryBetViewController_LB" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LB*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_LB*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type ==14){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SC alloc]initWithNibName:@"LotteryBetViewController_SC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_SC*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type ==8){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LHC alloc]initWithNibName:@"LotteryBetViewController_LHC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LHC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_LHC*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }else if(type ==11){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SSC alloc]initWithNibName:@"LotteryBetViewController_SSC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SSC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        ((LotteryBetViewController_SSC*)curLotteryBetVC).isFromLiveBroadcast = YES;
     }else{
        curLotteryBetVC = [[LotteryBetViewController alloc]initWithNibName:@"LotteryBetViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController*)curLotteryBetVC).lotteryDelegate =  weakSelf;
         ((LotteryBetViewController*)curLotteryBetVC).isFromLiveBroadcast = YES;
    }
    [curLotteryBetVC setLotteryType:type];
    curLotteryBetVC.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-40-ShowDiff, SCREEN_WIDTH, 396+ShowDiff+40);
    [self addChildViewController:curLotteryBetVC];
    [self.view addSubview:curLotteryBetVC.view];
    
}
- (void)exchangeVersionToOld:(NSInteger)curLotteryType{
    if(curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27){
        [YBToolClass sharedInstance].default_old_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_old_view"];
    } else if(curLotteryType == 28){
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = true;
    }else if(curLotteryType == 30){
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = true;
    }else if(curLotteryType == 29){
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = true;
    }else if(curLotteryType == 31){
        [YBToolClass sharedInstance].default_oldLH_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldLH_view"];
    }else if(curLotteryType == 14){
        [YBToolClass sharedInstance].default_oldSC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldSC_view"];
    }else if(curLotteryType == 8){
        [YBToolClass sharedInstance].default_oldLHC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldLHC_view"];
    }else if(curLotteryType == 11){
        [YBToolClass sharedInstance].default_oldSSC_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldSSC_view"];
    }else if(curLotteryType == 10){
        [YBToolClass sharedInstance].default_oldNN_view = true;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"default_oldNN_view"];
    }


    WeakSelf
    curLotteryBetVC = [[LotteryBetViewController alloc]initWithNibName:@"LotteryBetViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    curLotteryBetVC.isFromLiveBroadcast = YES;
    ((LotteryBetViewController*)curLotteryBetVC).lotteryDelegate = weakSelf;
    ((LotteryBetViewController*)curLotteryBetVC).isFromLiveBroadcast = YES;
    [(LotteryBetViewController *)curLotteryBetVC setLotteryType:curLotteryType];
    curLotteryBetVC.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-40-ShowDiff, SCREEN_WIDTH, 396+ShowDiff+40);
    
    [self.view addSubview:curLotteryBetVC.view];
    [self addChildViewController:curLotteryBetVC];
    
}
- (void)exchangeVersionToNew:(NSInteger)curLotteryType{

    WeakSelf
    if(curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_YFKS alloc]initWithNibName:@"LotteryBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_YFKS*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [YBToolClass sharedInstance].default_old_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_old_view"];
    } else if(curLotteryType == 28){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_BJL alloc]initWithNibName:@"LotteryBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_BJL*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = false;
    }else if(curLotteryType == 30){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZP alloc]initWithNibName:@"LotteryBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZP*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = false;
    }else if(curLotteryType == 29){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZJH alloc]initWithNibName:@"LotteryBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZJH*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = false;

    }else if(curLotteryType == 31){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LH alloc]initWithNibName:@"LotteryBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LH*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [YBToolClass sharedInstance].default_oldLH_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLH_view"];
    }else if(curLotteryType ==14){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SC alloc]initWithNibName:@"LotteryBetViewController_SC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSC_view"];
        [YBToolClass sharedInstance].default_oldSC_view = false;
    }else if(curLotteryType ==8){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LHC alloc]initWithNibName:@"LotteryBetViewController_LHC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LHC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLHC_view"];
        [YBToolClass sharedInstance].default_oldLHC_view = false;
    }else if(curLotteryType ==11){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SSC alloc]initWithNibName:@"LotteryBetViewController_SSC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SSC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSSC_view"];
        [YBToolClass sharedInstance].default_oldSSC_view = false;
    }else if(curLotteryType ==10){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_NNN alloc]initWithNibName:@"LotteryBetViewController_NNN" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_NNN*)curLotteryBetVC).lotteryDelegate = weakSelf;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldNN_view"];
        [YBToolClass sharedInstance].default_oldNN_view = false;
    }
    [curLotteryBetVC setLotteryType:curLotteryType];
    curLotteryBetVC.isFromLiveBroadcast = YES;
    curLotteryBetVC.view.frame = CGRectMake(0, SCREEN_HEIGHT-396-40-ShowDiff, SCREEN_WIDTH, 396+40+ShowDiff);
    if ([self.parentViewController isKindOfClass:[SwitchLotteryViewController class]]) {
        [self.parentViewController.view addSubview:curLotteryBetVC.view];
        [self.parentViewController addChildViewController:curLotteryBetVC];
    }else{
        [self.view addSubview:curLotteryBetVC.view];
        [self addChildViewController:curLotteryBetVC];
    }
}

- (void)hideSysTemView{
    [sysView.view removeFromSuperview];
    sysView = nil;
    sysView.view = nil;
    
}

-(void)siXin:(NSString *)icon andName:(NSString *)name andID:(NSString *)ID andIsatt:(NSString *)isatt{
    //    [chatsmall.view removeFromSuperview];
    //    chatsmall = nil;
    //    chatsmall.view = nil;
    //    [huanxinviews.view removeFromSuperview];
    //    huanxinviews = nil;
    //    huanxinviews.view = nil;
    //    WeakSelf
    //    [JMSGConversation createSingleConversationWithUsername:[NSString stringWithFormat:@"%@%@",JmessageName,ID] completionHandler:^(id resultObject, NSError *error) {
    //        STRONGSELF
    //        if (strongSelf == nil) {
    //            return;
    //        }
    //        if (error == nil) {
    //            [strongSelf doCancle];
    //            if (!strongSelf->chatsmall) {
    //                strongSelf->chatsmall = [[JCHATConversationViewController alloc]init];
    //                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //                [dic setObject:minstr(icon) forKey:@"avatar"];
    //                [dic setObject:minstr(ID) forKey:@"id"];
    //                [dic setObject:minstr(name) forKey:@"user_nicename"];
    //                [dic setObject:minstr(name) forKey:@"name"];
    //                [dic setObject:resultObject forKey:@"conversation"];
    //                [dic setObject:isatt forKey:@"utot"];
    //                MessageListModel *model = [[MessageListModel alloc]initWithDic:dic];
    //                strongSelf->chatsmall.userModel = model;
    //                strongSelf->chatsmall.conversation = resultObject;
    //                strongSelf->chatsmall.view.frame = CGRectMake(_window_width, _window_height-_window_height*0.4, _window_width, _window_height*0.4);
    //                __weak __typeof(self)weakSelf1 = strongSelf;
    //                strongSelf->chatsmall.block = ^(int type) {
    //                    __strong __typeof(weakSelf)strongSelf1 = weakSelf1;
    //                    if (type == 0) {
    //                        [strongSelf1 hideChatMall];
    //                    }
    //                };
    //                [strongSelf.view insertSubview:strongSelf->chatsmall.view atIndex:10];
    //                if ([strongSelf->userView.forceBtn.titleLabel.text isEqual:YZMsg(@"已关注")]) {
    //                    [strongSelf->chatsmall reloadSamllChtaView:@"1"];
    //                }
    //                else{
    //                    [strongSelf->chatsmall reloadSamllChtaView:@"0"];
    //                }
    //                strongSelf->chatsmall.view.hidden =YES;
    //            }
    //            strongSelf->chatsmall.view.hidden = NO;
    //            [UIView animateWithDuration:0.5 animations:^{
    //                strongSelf->chatsmall.view.frame = CGRectMake(0, _window_height-_window_height*0.4, _window_width, _window_height*0.4);
    //            }];
    //        }
    //        else{
    //            [MBProgressHUD showError:error.localizedDescription];
    //        }
    //    }];
}
//- (void)hideChatMall{
//    if (huanxinviews) {
//        [huanxinviews forMessage];
//        CATransition *transition = [CATransition animation];    //创建动画效果类
//        transition.duration = 0.3; //设置动画时长
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];  //设置动画淡入淡出的效果
//        transition.type = kCATransitionPush;//{kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};设置动画类型，移入，推出等
//        //更多私有{@"cube",@"suckEffect",@"oglFlip",@"rippleEffect",@"pageCurl",@"pageUnCurl",@"cameraIrisHollowOpen",@"cameraIrisHollowClose"};
//        transition.subtype = kCATransitionFromLeft;//{kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};
//        [chatsmall.view.layer addAnimation:transition forKey:nil];       //在图层增加动画效果
//        [chatsmall.view removeFromSuperview];
//        chatsmall.view = nil;
//        chatsmall = nil;
//
//    }else{
//        WeakSelf
//        [UIView animateWithDuration:0.3 animations:^{
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            strongSelf->chatsmall.view.frame = CGRectMake(_window_width, _window_height*0.6, _window_width, _window_height*0.4);
//        } completion:^(BOOL finished) {
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            [strongSelf->chatsmall.view removeFromSuperview];
//            strongSelf->chatsmall.view = nil;
//            strongSelf->chatsmall = nil;
//        }];
//    }
//}

-(void)doUpMessageGuanZhu{
    if ([userView.forceBtn.titleLabel.text isEqual:YZMsg(@"upmessageInfo_followed")]) {
        [userView.forceBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
        [userView.forceBtn setTitleColor:UIColorFromRGB(0xff9216) forState:UIControlStateNormal];
    }
    else{
        [userView.forceBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
        [userView.forceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        userView.forceBtn.enabled = NO;
    }
}
-(void)pushZhuYe:(NSString *)IDS{
    [self doCancle];
    otherUserMsgVC  *person = [[otherUserMsgVC alloc]init];
    person.userID = IDS;
    [self.navigationController pushViewController:person animated:YES];
}
-(void)doupCancle{
    [self doCancle];
}
//键盘弹出隐藏下面四个按钮
-(void)hideBTN{
    closeLiveBtn.hidden = YES;
    keyBTN.hidden = YES;
    hidenAdvBtn.hidden = YES;
//    moreBTN.hidden = YES;
    bottombtnV.hidden = YES;
}
-(void)showBTN{
    closeLiveBtn.hidden = NO;
    keyBTN.hidden = NO;
    hidenAdvBtn.hidden = NO;
    moreBTN.hidden = NO;
    //    linkSwitchBtn.hidden = NO;
}
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //防止填写竞拍信息的时候弹出私信
    
    if (!ismessgaeshow) {
        
        return;
    }
    if (startKeyboard == 1) {
        return;
    }
    
    
    [self hideBTN];
    [self doCancle];
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->toolBar.frame = CGRectMake(0,height-44,_window_width,44);
        strongSelf->frontView.frame = CGRectMake(0,-height, _window_width, _window_height);
        [strongSelf tableviewheight:_window_height - _window_height*0.35 - keyboardRect.size.height - 40];
        [strongSelf.view bringSubviewToFront:strongSelf->toolBar];
        [strongSelf.view bringSubviewToFront:strongSelf.tableView];
        [strongSelf changecontinuegiftframe];
        
    }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //    startPKBtn.hidden = NO;
    
    ismessgaeshow = NO;
    [self showBTN];
    
    
    WeakSelf
    [UIView animateWithDuration:0.1 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->toolBar.frame = CGRectMake(0, _window_height+10, _window_width, 44);
        [strongSelf tableviewheight:_window_height - _window_height*0.35 - 50 - ShowDiff];
        strongSelf->frontView.frame = CGRectMake(0, 0, _window_width, _window_height);
        [strongSelf changecontinuegiftframe];
        
    }];
}
-(void)adminZhezhao{
    zhezhaoList.view.hidden = YES;
    self.tableView.hidden = NO;
    self.userTableView.hidden = NO;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->adminlist.view.frame = CGRectMake(0,_window_height*2, _window_width, _window_height*0.3);
    }];
}
//管理员列表
-(void)adminList{
    if (!adminlist) {
        //管理员列表
        zhezhaoList  = [[UIViewController alloc]init];
        zhezhaoList.view.frame = CGRectMake(0, 0, _window_width, _window_height);
        [self.view addSubview:zhezhaoList.view];
        zhezhaoList.view.hidden = YES;
        adminlist = [[adminLists alloc]init];
        adminlist.delegate = self;
        adminlist.view.frame = CGRectMake(0, _window_height*2, _window_width, _window_height);
        [self.view addSubview:adminlist.view];
        UITapGestureRecognizer *tapAdmin = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(adminZhezhao)];
        [zhezhaoList.view addGestureRecognizer:tapAdmin];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"adminlist" object:nil];
    [self doCancle];
    self.tableView.hidden = YES;
    self.userTableView.hidden = YES;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->zhezhaoList.view.hidden = NO;
        strongSelf->adminlist.view.frame = CGRectMake(0,0, _window_width, _window_height);
    }];
}
-(void)setAdminSuccess:(NSString *)isadmin andName:(NSString *)name andID:(NSString *)ID{
    //    NSString *cts;
    //    if ([isadmin isEqual:@"0"]) {
    //        //不是管理员
    //         cts = @"被取消管理员";
    //        [MBProgressHUD showError:YZMsg(@"取消管理员成功")];
    //    }else{
    //        //是管理员
    //          cts = @"被设为管理员";
    //        [MBProgressHUD showError:@"设置管理员成功"];
    //    }
    if (socketL) {
        [socketL setAdminID:ID andName:name andCt:isadmin];
    }
}

- (void)doReportAnchor:(NSString *)touid {
    
}


- (void)setLabel:(NSString *)touid {
    
}


- (void)superAdmin:(NSString *)state {
    
}

//弹窗退出
-(void)doCancle{
    userView.forceBtn.enabled = YES;
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf-> userView.frame = CGRectMake(_window_width*0.1,_window_height*2,upViewW, upViewW*4/3);
    }];
    self.tableView.userInteractionEnabled = YES;
    self.userTableView.userInteractionEnabled = YES;
}
-(void)superStopRoom:(NSString *)state{
    [self hostStopRoom];
}
//发送消息
-(void)sendBarrage
{
    /*******发送弹幕开始 **********/
    //    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.sendBarrage"];
    NSDictionary *subdic = @{
        @"liveuid":[Config getOwnID],
        @"stream":urlStrtimestring,
        @"giftid":@"1",
        @"giftcount":@"1",
        @"content":keyField.text
    };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.sendBarrage" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSString *barragetoken = [[info firstObject] valueForKey:@"barragetoken"];
            //刷新本地魅力值
            LiveUser *liveUser = [Config myProfile];
            liveUser.coin = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"coin"]];
            [Config updateProfile:liveUser];
            if (strongSelf->socketL) {
                [strongSelf->socketL sendBarrage:barragetoken];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
    
    /*********************发送礼物结束 ************************/
}
-(void)pushMessage:(UITextField *)sender{
    if (keyField.text.length >50) {
        [MBProgressHUD showError:YZMsg(@"Livebroadcast_Input_word_limit50")];
        return;
    }
    //    int levelLimits = [[Config getChatLevel] intValue];
    //    int currentLevel = [[Config getLevel] intValue];
    //
    pushBTN.enabled = NO;
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->pushBTN.enabled = YES;
    });
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [keyField.text stringByTrimmingCharactersInSet:set];
    if ([trimedString length] == 0) {
        
        return ;
    }
    if(cs.state == YES)//发送弹幕
    {
        
        if (keyField.text.length <=0) {
            return;
        }
        [self sendBarrage];
        keyField.text = @"";
        pushBTN.selected = NO;
        return;
    }
    if (socketL) {
        [socketL sendMessage:keyField.text];
    }
    keyField.text = @"";
    pushBTN.selected = NO;
    [self scrollToLastCell];
}
//聊天输入框
-(void)showkeyboard:(UIButton *)sender{
    //    if (chatsmall) {
    //        chatsmall.view.hidden = YES;
    //        [chatsmall.view removeFromSuperview];
    //        chatsmall.view = nil;
    //        chatsmall = nil;
    //    }
    ismessgaeshow = YES;
    [keyField becomeFirstResponder];
    
}
// 以下是 tableview的方法
///*******    连麦 注意下面的tableview方法    *******/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @synchronized (messageList) {
        if (tableView == self.userTableView) {
            return msgList.count;
        }else{
            return messageList.count;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    chatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCELL"];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"chatMsgCell"] loadNibNamed:@"chatMsgCell" owner:nil options:nil] lastObject];
    }
    @synchronized (messageList) {
        if (tableView == self.userTableView) {
            if (indexPath.row < msgList.count) {
                cell.model = msgList[indexPath.row];
            }
        } else {
            if (indexPath.row < messageList.count) {
                id model = messageList[indexPath.row];
                if ([model isKindOfClass:[chatModel class]]) {
                    cell.model = model;
                }
            }
        }
    }

    WeakSelf
    cell.translateBlock = ^(chatModel * _Nonnull chatModel, BOOL isPersonInfo) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSString *IsUser = [NSString stringWithFormat:@"%@",chatModel.userID];
        if (!isPersonInfo) {
            // 有翻译按钮的消息
            [strongSelf->socketL sendTranslateMsg:chatModel.contentChat];
        }else if (IsUser.length>1){
            // 普通消息
            NSDictionary *subdic = @{@"id":chatModel.userID,
                                     @"name":chatModel.userName
            };
            [strongSelf GetInformessage:subdic];
        }
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 5)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    chatModel *model = [[chatModel alloc] init];
    if (tableView == self.userTableView) {
        model = msgList[indexPath.row];
    }else{
        model = messageList[indexPath.row];
    }

    [keyField resignFirstResponder];
    if ([model.userName isEqual:YZMsg(@"Livebroadcast_LiveMsgs")]) {
        return;
    }
    NSString *IsUser = [NSString stringWithFormat:@"%@",model.userID];
    if([minstr(model.titleColor) isEqualToString:@"lotteryBet"]){
        // 如果是彩票投注
        // 呼出确认订单界面
        [self doCancle];
        if (model.optionName1!= nil && [model.optionName1 isEqualToString:@"水果拉霸"]) {
            [self doLotteryWithtype:40];
            return;
        }
        BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        betConfirmVC.isFromFollow = true;
        UIView *shadowView = [YBToolClass mengban:self.view clickCallback:^{
            //        [self refreshCurrentChip];
            [betConfirmVC.view removeFromSuperview];
            [betConfirmVC removeFromParentViewController];
        }];
        NSString *lotteryType = model.lotteryType;
        /*
         {"issue":"20200327051135","date":1585306500,"__ymd__":"2020-03-27 18:55:00","sealingTim":"5","lotteryType":11,"stopOrSell":1,"time":24,"QiHaoFirst":{"issue":"20200327050001","date":1585238460,"__ymd__":"2020-03-27 00:01:00"},"QiHaoLast":{"issue":"20200327051440","date":1585324800,"__ymd__":"2020-03-28 00:00:00"}}
         
         */
        NSMutableDictionary *dict = lotteryInfo[lotteryType];
        if (socketL) {
            [socketL sendSyncLotteryCMD:lotteryType];
//            WeakSelf
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                STRONGSELF
//                if (strongSelf == nil) {
//                    return;
//                }
//                [strongSelf tableView:tableView didSelectRowAtIndexPath:indexPath];
//            });
        }
        if(lotteryType && dict){
            NSString *way = model.way?model.way:@"";
            NSData *wayJsonData = [way dataUsingEncoding:NSUTF8StringEncoding];//转化为data
            NSArray *wayInfo = [NSJSONSerialization JSONObjectWithData:wayJsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            NSString *money = model.money;
            NSData *moneyJsonData = [money dataUsingEncoding:NSUTF8StringEncoding];//转化为data
            NSArray *moneyInfo = [NSJSONSerialization JSONObjectWithData:moneyJsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            if (moneyInfo == nil ) {
                if (wayInfo.count==1) {
                    moneyInfo = @[money];
                }else{
                    moneyInfo = [money componentsSeparatedByString:@","];
                }
            }
            NSString *ways = model.ways?model.ways:@"";
            NSData *waysJsonData = [ways dataUsingEncoding:NSUTF8StringEncoding];//转化为data
            NSArray *wayStsA = [NSJSONSerialization JSONObjectWithData:waysJsonData options:NSJSONReadingMutableContainers error:nil];//转化为字典
            
            NSMutableArray *orders = [NSMutableArray array];
            NSInteger wayCount = wayInfo.count;
            for (int i = 0; i < wayCount; i++) {
                NSString *way = [wayInfo objectAtIndex:i];
                NSString *money = [moneyInfo objectAtIndex:i];
                
                NSMutableDictionary *order = [NSMutableDictionary dictionary];
                [order setObject:way forKey:@"way"];
                if (wayStsA&& wayStsA.count>i) {
                    [order setObject:wayStsA[i] forKey:@"st"];
                }
                [order setObject:money forKey:@"money"];
                [orders addObject:order];
            }
            
            NSString *optionName = model.optionName1;
            NSString *optionNameSt = model.optionNameSt;
            if(!optionName){
                optionName = @"";
            }
            NSDictionary *orderInfo = @{
                @"name":dict[@"name"]?dict[@"name"]:@"",
                @"optionName":optionName?optionName:@"",
                @"optionNameSt":optionNameSt?optionNameSt:@"",
                @"lotteryType":minstr(lotteryType),
                @"issue":dict[@"issue"]?dict[@"issue"]:@"",
                @"betLeftTime":dict[@"time"]?dict[@"time"]:@"",
                @"sealingTime":dict[@"sealingTim"]?dict[@"sealingTim"]:@"",
                @"orders":orders?orders:@"",
            };
            //model.optionName
            
            [betConfirmVC setOrderInfo:orderInfo];
            __weak BetConfirmViewController *betConfirWeak = betConfirmVC;
            betConfirmVC.betBlock = ^(NSInteger idx, NSUInteger num){
                [shadowView removeFromSuperview];
                [betConfirWeak.view removeFromSuperview];
                [betConfirWeak removeFromParentViewController];
            };
            [self.view addSubview:betConfirmVC.view];
            //    betConfirmVC.view.y = self.view.height - betConfirmVC.view.bottom;
            betConfirmVC.view.bottom = self.view.bottom;
            [self addChildViewController:betConfirmVC];
        }
    }else if([minstr(model.titleColor) isEqualToString:@"lotteryProfit"]){
        // 如果是彩票中奖
        [self doCancle];
        NSLog(@"彩票中奖消息");
    }else if([minstr(model.titleColor) isEqualToString:@"lotteryDividend"]){
        [self doCancle];
        NSLog(@"彩票分红消息");
        if (IsUser.length > 1) {
            NSDictionary *subdic = @{@"id":model.userID,
                                     @"name":model.userName
            };
            [self GetInformessage:subdic];
        }
    }else{
        if (IsUser.length > 1) {
            NSDictionary *subdic = @{@"id":model.userID,
                                     @"name":model.userName
            };
            [self GetInformessage:subdic];
        }
    }
}
//请求直播
-(void)getStartShow
{
    if (_roomModel==nil || _roomModel.push == nil) {
        return;
    }
    _hostURL = [[NSURL alloc] initWithString:_roomModel.push];
    urlStrtimestring = _roomModel.stream;
    _socketUrl = _roomModel.chatserver;
    if(isTest){
        _socketUrl = chaturl;
    }
    roomLotteryInfo = _roomModel.roomLotteryInfo;
    WeakSelf
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:minstr(roomLotteryInfo[@"logo"])]
                      options:1
                     progress:nil
                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (image) {
            [strongSelf->lotteryBTN setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
    _danmuPrice = _roomModel.barrage_fee;

    if (self.isOBS) {
        [self onQuit:nil];
        [self createNodePlayer:_roomModel.pull];
    } else {
        [self onStream:nil];
    }

    if (self.toySwitchStatus || self.orderSwitchStatus) {
        [frontView addSubview:self.remoteInterfaceView];
        if (self.toySwitchStatus) {
            [_remoteInterfaceView changeToyStatus:self.toySwitchStatus];
            [_remoteInterfaceView changeBatteryInfo:_connectedToy.battery];
        }
    } else {
        [_remoteInterfaceView removeFromSuperview];
        _remoteInterfaceView = nil;
    }

    _voteNums = [NSString stringWithFormat:@"%@",_roomModel.votestotal];
    [self changeState];
    [self changeGuardNum:minstr(_roomModel.guard_nums)];
    [self resetRedBagBtnFrame];

    socketL = [[socketLive alloc]init];
    socketL.delegate = self;
    socketL.zhuboModel = _roomModel;
    [socketL getshut_time:_shut_time];//获取禁言时间
    [socketL addNodeListen:_socketUrl andTimeString:urlStrtimestring];
    userlist_time = [_roomModel.userlist_time intValue];
    int timeDelayReload = MIN(MAX(10, userlist_time),60);
    if (!listTimer) {
        listTimer = [NSTimer scheduledTimerWithTimeInterval:timeDelayReload target:self selector:@selector(reloadUserList) userInfo:nil repeats:YES];
    }
    if (!hartTimer) {
        hartTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(socketLight) userInfo:nil repeats:YES];
    }
    
}

-(void)hideself{
    
    self.tableView.hidden = NO;
    self.userTableView.hidden = NO;
    
}

//改变tableview高度
-(void)tableviewheight:(CGFloat)h{
    CGFloat  userTableH = 0;
    for (int i = 0; i< msgList.count; i++) {
        chatModel * model = msgList[i];
        userTableH = userTableH + model.rowHH + 10;
    }
    if(userTableH > _window_height*0.11 || msgList.count>=3){
        self.tableView.frame = CGRectMake(10,h - 40,tableWidth,_window_height*0.24);
        self.userTableView.frame = CGRectMake(10,h - 40+ _window_height*0.24,tableWidth,_window_height*0.11);
    }else{
        self.tableView.frame = CGRectMake(10,h - 40,tableWidth,_window_height*0.35 - userTableH);
        self.userTableView.frame = CGRectMake(10,h - 40 + _window_height*0.35 - userTableH,tableWidth,userTableH);
    }
//    self.tableView.frame = CGRectMake(10,h-40,tableWidth,_window_height*0.35);
    useraimation.frame = CGRectMake(10,_tableViewTop - 40,_window_width,20);
    nuseraimation.frame = CGRectMake(10,_tableViewBottom - 5,_window_width,20);
}
//改变连送礼物的frame
-(void)changecontinuegiftframe{
    liansongliwubottomview.frame = CGRectMake(0, _tableViewTop - 150,_window_width/2,140);
}

-(void)changeBtnFrame:(CGFloat)bottombtnH{
    if(bottombtnH == _window_height - 45){
        bottombtnH = bottombtnH-ShowDiff;
    }
    keyBTN.frame = CGRectMake(10, bottombtnH, 120, www);
    closeLiveBtn.frame = CGRectMake(_window_width - www- 10,bottombtnH, www, www);
    moreBTN.frame = CGRectMake(_window_width - www*2-20,bottombtnH, www, www);
    
    lotteryBTN.frame = CGRectMake(_window_width - 45 - 10, _window_height * 0.25, 45, 45);
    
    [frontView insertSubview:keyBTN atIndex:6];
    [frontView insertSubview:closeLiveBtn atIndex:6];
    [frontView insertSubview:lotteryBTN atIndex:6];
    [frontView insertSubview:moreBTN atIndex:6];
    [self showBTN];
    
}
-(void)pushCoinV{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr =YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    if (self.presentedViewController == nil) {
        [self presentViewController:payView animated:YES completion:nil];
    }
}


//********************************转盘*******************************************************************//
-(void)reloadUserList{
    if (listView) {
        [listView listReloadNoew];
    }
}
- (void)loginOnOtherDevice:(StartEndLive*)lievend{
    WeakSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:lievend.msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hostStopRoom];
    }]];
    if (self.presentedViewController == nil) {
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//请求关闭直播
-(void)getCloseShow
{
    NSString *streamStr = _roomModel.stream;
    [self musicPlay];
    NSString *url = [NSString stringWithFormat:@"Live.stopRoom&uid=%@&token=%@&stream=%@",[Config getOwnID],[Config getOwnToken],urlStrtimestring];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->socketL) {
            [strongSelf->socketL closeRoom];//发送关闭直播的socket
        }
        [MBProgressHUD hideHUD];
        [strongSelf dismissVC];
        [strongSelf liveOver];//停止计时器
        if (strongSelf->socketL) {
            [strongSelf->socketL colseSocket];//注销socket
        }
        strongSelf->socketL = nil;//注销socket
        //直播结束
        [strongSelf onQuit:nil];//停止音乐、停止推流
        [strongSelf rmObservers];//释放通知
        [strongSelf requestLiveAllTimeandVotes:streamStr];
        //            [self.navigationController popViewControllerAnimated:YES];
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        [MBProgressHUD hideHUD];
        [strongSelf dismissVC];
        [strongSelf liveOver];//停止计时器
        if (strongSelf->socketL) {
            [strongSelf->socketL colseSocket];//注销socket
        }
        strongSelf->socketL = nil;//注销socket
        //直播结束
        [strongSelf onQuit:nil];//停止音乐、停止推流
        [strongSelf rmObservers];//释放通知
        //        [self.navigationController popViewControllerAnimated:YES];
        [strongSelf requestLiveAllTimeandVotes:streamStr];
        
    }];
    
}
//礼物效果
/************ 礼物弹出及队列显示开始 *************/
//红包
-(void)redbag{
    
}
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view insertSubview:haohualiwuV atIndex:10];
    }
    if (giftData == nil) {
        
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
-(void)expensiveGift:(NSDictionary *)giftData{
    
    
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view insertSubview:haohualiwuV atIndex:10];
    }
    if (giftData == nil) {
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }

}
-(void)addvotesdelegate:(NSString *)votes{
    _voteNums = votes;
    [self changeState];
}
-(void)switchState:(BOOL)state
{
    NSLog(@"%d",state);
    if(!state) {
        keyField.placeholder = YZMsg(@"Livebroadcast_SayHi");
    } else {
        NSString *currencyCoin = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%@", self.danmuPrice] showUnit:YES];
        keyField.placeholder = [NSString stringWithFormat:@"%@，%@/%@",YZMsg(@"Livebroadcast_Open_msg_notifys"),currencyCoin,YZMsg(@"public_itemMsg")];
    }
}
- (BOOL)shouldAutorotate {
    return YES;
}

// 建立播放器
- (void)createNodePlayer:(NSString*)pullUrl {
    NSLog(@"--------------------------准备播放");

    _nplayer = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
    
    NSString *lastComStr = pullUrl.lastPathComponent;


    BOOL isencryption = [LiveEncodeCommon sharedInstance].isOpenEncode;
    if (lastComStr != nil && ([lastComStr containsString:@"mp4"] || [lastComStr containsString:@"MP4"])) {
        isencryption = false;
    }

    WeakSelf
    _nplayer.nodePlayerDelegate = weakSelf;
    [_nplayer setBufferTime:400];
//    #ifdef LIVE
//    [_nplayer setMaxBufferTime:1000];
//    [_nplayer setConnectWaitTimeout:1000];
//    [_nplayer setAutoReconnectWaitTimeout:500];
//    #else
//
//    #endif


    [self checkIfEncryption:isencryption];

    NSString * url = [minstr(pullUrl) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [_nplayer setHWAccelEnable:false];
  
    _nplayer.scaleMode = 2;
    [_nplayer attachView:videobottom];
    _nplayer.volume = 1;
    [_nplayer start:url];

}

-(void)checkIfEncryption:(BOOL)isencryption
{
    NSString *zhubID = [Config getOwnID] != nil ? [Config getOwnID] : @"";
    if (isencryption) {
        NSString *randomEnCodeStr = [[YBToolClass sharedInstance].dicForKeyPlay objectForKey:minnum(zhubID)];
        if([YBToolClass sharedInstance].dicForKeyPlay== nil ||[PublicObj checkNull:randomEnCodeStr]){
            randomEnCodeStr = [[RandomRule randomWithColumn:4 Line:4 seeds:[zhubID integerValue] others:nil] substringToIndex:16];
            if([YBToolClass sharedInstance].dicForKeyPlay== nil ){
                [YBToolClass sharedInstance].dicForKeyPlay = [NSMutableDictionary dictionary];
            }

            [[YBToolClass sharedInstance].dicForKeyPlay setObject:minnum(zhubID) forKey:randomEnCodeStr];
        }
        [_nplayer setCryptoKey:randomEnCodeStr];
    }else{
        [_nplayer setCryptoKey:@""];
    }
}

/*==================  初始化视频流  ================*/
-(void)initPushStreamer
{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 停用旧 session
    [session setActive:NO error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];


    _np = [[NodePublisher alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
    if ([LiveEncodeCommon sharedInstance].isOpenEncode) {
        NSString *randomEnCodeStr = [[RandomRule randomWithColumn:4 Line:4 seeds:[[Config getOwnID] intValue] others:nil] substringToIndex:16];
        _np.cryptoKey = randomEnCodeStr;
    }
    [MXBADelegate sharedAppDelegate].isAutoDirection = NO;
    [_np setVideoOrientation:VIDEO_ORIENTATION_PORTRAIT];
    [_np attachView:videobottom];
    [_np setAudioParamWithCodec:NMC_CODEC_ID_AAC profile:NMC_PROFILE_AAC_HE samplerate:48000 channels:1 bitrate:64*1000];
    [_np setVideoParamWithCodec:NMC_CODEC_ID_H264 profile:NMC_PROFILE_H264_MAIN width:640 height:_window_height*(640/_window_width) fps:23 bitrate:(int)1000*1000];
    [_np setKeyFrameInterval:3];
    [_np setVolume:1.0];
    [_np setHWAccelEnable:true];
    
    [_np setDenoiseEnable:true];
    
    _np.customDelegate = self;
    _np.nodePublisherDelegate = self;

    // 先尝试检查摄像头可用性
    AVCaptureDevice *frontCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                       mediaType:AVMediaTypeVideo
                                                                        position:AVCaptureDevicePositionFront];
    
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                        mediaType:AVMediaTypeVideo
                                                                         position:AVCaptureDevicePositionBack];
    

    if (!frontCamera && !backCamera) {
          [MBProgressHUD showError:@"摄像头不可用"];
          return;
      } else if (!frontCamera) {
          [MBProgressHUD showError:@"前置摄像头不可用，切换到后置"];
          [_np openCamera:NO]; // 使用后置摄像头
      } else {
          [_np openCamera:YES]; // 使用前置摄像头
      }
}

-(void)openCamera:(BOOL)frontCamera{
    
    [self.np openCamera:frontCamera];

    [self.np startFocusAndMeteringCenter];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.np startFocusAndMeteringCenter];
        [strongSelf forceUseBuiltInMic];
    });
}
- (void)forceUseBuiltInMic {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive:YES error:&error];

    // 儲存各種輸入類型
    AVAudioSessionPortDescription *usbAudio = nil;
    AVAudioSessionPortDescription *wiredMic = nil;
    AVAudioSessionPortDescription *bluetoothMic = nil;
    AVAudioSessionPortDescription *builtInMic = nil;

    // 遍歷所有可用輸入裝置
    for (AVAudioSessionPortDescription *port in [session availableInputs]) {
        NSLog(@"🔌 可用輸入: %@, 類型: %@", port.portName, port.portType);

        if ([port.portType isEqualToString:AVAudioSessionPortUSBAudio]) {
            usbAudio = port;
        } else if ([port.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
            wiredMic = port;
        } else if ([port.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
                   [port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
                   [port.portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
            bluetoothMic = port;
        } else if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            builtInMic = port;
        }
    }

    // 按照優先順序選擇輸入設備
    AVAudioSessionPortDescription *preferredPort = nil;
    if (usbAudio) {
        preferredPort = usbAudio;
    } else if (wiredMic) {
        preferredPort = wiredMic;
    } else if (bluetoothMic) {
        preferredPort = bluetoothMic;
    } else if (builtInMic) {
        preferredPort = builtInMic;
    }

    if (preferredPort) {
        NSError *setError = nil;
        BOOL success = [session setPreferredInput:preferredPort error:&setError];
        if (success) {
            NSLog(@"✅ 使用音频输入设备: %@ (%@)", preferredPort.portName, preferredPort.portType);
        } else {
            for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                    [session setPreferredInput:port error:&error];
                    if (error) {
                        NSLog(@"❌ 设置内建麦克风失败: %@", error.localizedDescription);
                    } else {
                        NSLog(@"✅ 成功强制使用内建麦克风");
                    }
                    break;
                }
            }
        }
    } else {
        NSLog(@"⚠️ 未找到任何可用输入设备");
        // 4. 遍历输入设备，强制设为内建麦克风
            for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                    [session setPreferredInput:port error:&error];
                    if (error) {
                        NSLog(@"❌ 设置内建麦克风失败: %@", error.localizedDescription);
                    } else {
                        NSLog(@"✅ 成功强制使用内建麦克风");
                    }
                    break;
                }
            }
    }
}


- (void)handleRouteChange:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable ||
        reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        NSLog(@"🔄 音频路由发生变化，重新检查输入设备");
       
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        [session setActive:YES error:&error];

        // 儲存各種輸入類型
        AVAudioSessionPortDescription *usbAudio = nil;
        AVAudioSessionPortDescription *wiredMic = nil;
        AVAudioSessionPortDescription *bluetoothMic = nil;
        AVAudioSessionPortDescription *builtInMic = nil;

        // 遍歷所有可用輸入裝置
        for (AVAudioSessionPortDescription *port in [session availableInputs]) {
            NSLog(@"🔌 可用輸入: %@, 類型: %@", port.portName, port.portType);

            if ([port.portType isEqualToString:AVAudioSessionPortUSBAudio]) {
                usbAudio = port;
            } else if ([port.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
                wiredMic = port;
            } else if ([port.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
                       [port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
                       [port.portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
                bluetoothMic = port;
            } else if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                builtInMic = port;
            }
        }

        // 按照優先順序選擇輸入設備
        AVAudioSessionPortDescription *preferredPort = nil;
        if (usbAudio) {
            preferredPort = usbAudio;
        } else if (wiredMic) {
            preferredPort = wiredMic;
        } else if (bluetoothMic) {
            preferredPort = bluetoothMic;
        } else if (builtInMic) {
            preferredPort = builtInMic;
        }

        if (preferredPort) {
            NSError *setError = nil;
            BOOL success = [session setPreferredInput:preferredPort error:&setError];
            if (success) {
                NSLog(@"✅ 使用音频输入设备: %@ (%@)", preferredPort.portName, preferredPort.portType);
            } else {
                for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                    if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                        [session setPreferredInput:port error:&error];
                        if (error) {
                            NSLog(@"❌ 设置内建麦克风失败: %@", error.localizedDescription);
                        } else {
                            NSLog(@"✅ 成功强制使用内建麦克风");
                        }
                        break;
                    }
                }
            }
        } else {
            NSLog(@"⚠️ 未找到任何可用输入设备");
            // 4. 遍历输入设备，强制设为内建麦克风
                for (AVAudioSessionPortDescription *port in [session availableInputs]) {
                    if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
                        [session setPreferredInput:port error:&error];
                        if (error) {
                            NSLog(@"❌ 设置内建麦克风失败: %@", error.localizedDescription);
                        } else {
                            NSLog(@"✅ 成功强制使用内建麦克风");
                        }
                        break;
                    }
                }
        }
        
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:&error];

        [session setMode:AVAudioSessionModeVideoChat error:&error];

       
    }
}

-(void) onEventCallback:(id _Nonnull)sender event:(int)event msg:(NSString* _Nonnull)msg;
{
    NSLog(@"====onEventCallback: %d, %@", event, msg);
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        STRONGSELF
    if (self == nil) {
        return;
    }
    switch (event) {
        case 1104:
            // 在播放页面的delegate回调会有返回画面代理case 1104:回调
            [self changePlayState:1];//推流成功后改变直播状态
        case 2000:
            NSLog(@"正在发布视频");
            break;
        case 2001:
            NSLog(@"视频发布成功");
            [self changePlayState:1];//推流成功后改变直播状态
            break;
        case 2002:
            NSLog(@"视频发布失败");
            //                [self.np  stop];
            //                [self.np start];
            break;
        case 2004:
            NSLog(@"视频发布结束");
            break;
        case 2005:
            NSLog(@"视频发布中途,网络异常,发布中断");
            break;
        case 2100:
            NSLog(@"网络阻塞, 发布卡顿");
            break;
        case 2101:
            NSLog(@"网络恢复, 发布流畅");
            break;
            
        default:
            break;
    }
    //    });
}
NSTimeInterval timeddddd = 0;
BOOL isBegainSwitch = false;
BOOL ssss = false;
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    if (!self.openComp) {
//        [[FUManager shareManager] isTracking];
//        //        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
//        //        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//        [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
//        //        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//
//    }
    
    if (!self.openComp) {
        //Faceunity核心接口，将道具及美颜效果作用到图像中，执行完此函数pixelBuffer即包含美颜及贴纸效果
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//        [[FUTestRecorder shareRecorder] processFrameWithLog];
        [FUDemoManager updateBeautyBlurEffect];
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.renderConfig.isFromFrontCamera = YES;
        input.renderConfig.isFromMirroredCamera = YES;
        input.pixelBuffer = pixelBuffer;
        input.renderConfig.readBackToPixelBuffer = YES;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        [[FURenderKit shareRenderKit] renderWithInput:input];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    CGPoint origin = [[touches anyObject] locationInView:self.view];
    CGPoint location;
    location.x = origin.x/self.view.frame.size.width;
    location.y = origin.y/self.view.frame.size.height;
    [self onSwitchRtcView:location];
}

//// 采集相关设置初始化
- (void) setCaptureCfg {
    //    if (!_gpuStreamers) {
    //        _gpuStreamers = [[KSYGPUStreamerKit alloc]initWithDefaultCfg];
    //    }
    //
    //    _gpuStreamers.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    _gpuStreamers.videoFPS = 16;
    //    _gpuStreamers.gpuOutputPixelFormat   = kCVPixelFormatType_32BGRA;
    //    _gpuStreamers.capturePixelFormat   = kCVPixelFormatType_32BGRA;
    //
    //    _gpuStreamers.previewDimension = CGSizeMake(_window_height, _window_width);
    //
    //    if ([LiveEncodeCommon sharedInstance].isOpenEncode) {
    //        _gpuStreamers.capPreset =  AVCaptureSessionPreset1280x720;
    //        _gpuStreamers.streamerBase.videoInitBitrate = [LiveEncodeCommon sharedInstance].bitrate;
    //        _gpuStreamers.streamerBase.videoMaxBitrate  = [LiveEncodeCommon sharedInstance].bitrate;
    //        _gpuStreamers.streamerBase.videoMinBitrate  =  1400;
    //        if ([LiveEncodeCommon sharedInstance].live_resolution!= nil && ![LiveEncodeCommon sharedInstance].live_resolution.bAuto) {
    //            _gpuStreamers.streamDimension = CGSizeMake([LiveEncodeCommon sharedInstance].live_resolution.width, [LiveEncodeCommon sharedInstance].live_resolution.height);
    //        }else{
    //            _gpuStreamers.streamDimension = CGSizeMake(544, (544/_window_width)*_window_height);
    //        }
    //
    //    }else{
    //        _gpuStreamers.capPreset =  AVCaptureSessionPreset1280x720;
    //        _gpuStreamers.streamerBase.videoInitBitrate = 1200;
    //        _gpuStreamers.streamerBase.videoMaxBitrate  = 1200;
    //        _gpuStreamers.streamerBase.videoMinBitrate  =  1000;
    //        _gpuStreamers.streamDimension = CGSizeMake(540, (540/_window_width)*_window_height);
    //    }
    //    _gpuStreamers.cameraPosition = AVCaptureDevicePositionFront;
    //    _gpuStreamers.streamerBase.videoCodec = KSYVideoCodec_X264;
    //    _gpuStreamers.streamerBase.videoEncodePerf = KSYVideoEncodePer_HighPerformance;
    //
    //    _gpuStreamers.streamerBase.audiokBPS        =  48;
    //    _gpuStreamers.streamerBase.videoCrf = 10;
    //#ifdef DEBUG
    //    [_gpuStreamers.streamerBase muteStream:YES];
    //#endif
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (textField == keyField) {
        [self pushMessage:nil];
    }
    return YES;
}
-(void) onSwitchRtcView:(CGPoint)location
{
    if (_np) {
        [_np startFocusAndMetering:&location withFlags:FLAG_AF];
    }
}


#pragma mark -初始化TillusorySDK的演示UI
- (void)initTiFaceUI{
    [self setUpFilterMenuBar];
    
}
///初始化美颜菜单
-(void)setUpFilterMenuBar
{
    [[FUDemoManager shared] addDemoViewToView:self.view originY:CGRectGetHeight(self.view.bounds) - FUBottomBarHeight - VK_BOTTOM_H];
    [FUDemoManager.shared showDemoView];
//    if (!_beautyView) {
//        _beautyView = [[BeautyMenuView alloc] init];
//        [self.view addSubview:_beautyView];
//        [_beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(-VK_BOTTOM_H);
//            make.left.right.mas_equalTo(0);
//        }];
//        [_beautyView reload];
//    }else{
//        _beautyView.hidden = NO;
//        [self.view addSubview:_beautyView];
//    }

    if (!_compBtn) {
        /* 比对按钮 */
        _compBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_compBtn setImage:[ImageBundle imagewithBundleName:@"demo_icon_contrast"] forState:UIControlStateNormal];
        [_compBtn addTarget:self action:@selector(TouchDown) forControlEvents:UIControlEventTouchDown];
        [_compBtn addTarget:self action:@selector(TouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.view addSubview:_compBtn];
        if (iPhoneX) {
            _compBtn.frame = CGRectMake(65 , self.view.frame.size.height - 70 - 182 - 34, 44, 44);
        }else{
            _compBtn.frame = CGRectMake(65 , self.view.frame.size.height - 70 - 182, 44, 44);
        }
    }else{
        _compBtn.hidden = NO;
        [self.view addSubview:_compBtn];
    }
    if (!_filterButtonClose) {
        _filterButtonClose = [UIButton buttonWithType:0];
        _filterButtonClose.frame = CGRectMake(15, _compBtn.top, 44, 44);
        [_filterButtonClose setImage:[ImageBundle imagewithBundleName:@"demo_icon_close"] forState:0];
        [_filterButtonClose addTarget:self action:@selector(showPreFrontView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_filterButtonClose];
    }else{
        _filterButtonClose.hidden = NO;
        [self.view addSubview:_filterButtonClose];
    }
    
    
}

- (void)TouchDown{
    self.openComp = YES;
}

- (void)TouchUp{
    self.openComp = NO;
}

#pragma mark ================ bgm监听 ===============
- (void) onAudioStateChange:(NSNotification *)notification {
    //    NSLog(@"bgmState:%ld %@",_gpuStreamers.bgmPlayer.bgmPlayerState, [_gpuStreamers.bgmPlayer getCurBgmStateName]);
    //    if (KSYBgmPlayerStatePlaying == _gpuStreamers.bgmPlayer.bgmPlayerState) {
    //        if (musicV) {
    //            return;
    //        }
    //        musicV = [[UIView alloc]initWithFrame:CGRectMake(50, _window_height*0.3, _window_width-100, 100)];
    //        musicV.backgroundColor = [UIColor clearColor];
    //        [self.view addSubview:musicV];
    //        UIPanGestureRecognizer *aPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(musicPan:)];
    //        aPan.minimumNumberOfTouches = 1;
    //        aPan.maximumNumberOfTouches = 1;
    //        [musicV addGestureRecognizer:aPan];
    //
    //        NSFileManager *managers=[NSFileManager defaultManager];
    //
    //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //        NSString *docDir = [paths objectAtIndex:0];
    //        lrcPath = [docDir stringByAppendingFormat:@"/%@.lrc",muaicPath];
    //        if ([managers fileExistsAtPath:lrcPath]) {
    //            lrcView = [[YLYOKLRCView alloc]initWithFrame:CGRectMake(0,40,_window_width-100, 30)];
    //            lrcView.lrcLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];//OKlrcLabel
    //            lrcView.OKlrcLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    //            lrcView.backgroundColor = [UIColor clearColor];
    //            [musicV addSubview:lrcView];
    //            YLYMusicLRC *lrc = [[YLYMusicLRC alloc]initWithLRCFile:lrcPath];
    //            if(lrc.lrcList.count == 0 || !lrc.lrcList)
    //            {
    //                [MBProgressHUD showError:YZMsg(@"Livebroadcast_No_lyrics")];
    //                buttonmusic = [UIButton buttonWithType:UIButtonTypeCustom];
    //                buttonmusic.frame = CGRectMake(80,0,50,30);
    //                [buttonmusic addTarget:self action:@selector(musicPlay) forControlEvents:UIControlEventTouchUpInside];
    //                [buttonmusic setTitle:YZMsg(@"Livebroadcast_end") forState:UIControlStateNormal];
    //                buttonmusic.backgroundColor = [UIColor clearColor];
    //                [buttonmusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //                buttonmusic.layer.masksToBounds = YES;
    //                buttonmusic.layer.cornerRadius = 10;
    //                buttonmusic.layer.borderWidth = 1;
    //                buttonmusic.layer.borderColor = [UIColor whiteColor].CGColor;
    //                [musicV addSubview:buttonmusic];
    //                return;
    //            }
    //            self.lrcList = lrc.lrcList;
    //            self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(140,0,50,30)];
    //            self.timeLabel.backgroundColor = [UIColor clearColor];
    //            self.timeLabel.textAlignment = NSTextAlignmentCenter;
    //            self.timeLabel.textColor = [UIColor whiteColor];
    //            self.timeLabel.layer.cornerRadius = 10;
    //            self.timeLabel.layer.borderWidth = 1;
    //            self.timeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    //            self.timeLabel.text = [NSString stringWithFormat:@"%d:0%d",0,0];
    //            [musicV addSubview:self.timeLabel];
    //        }
    //        else{
    //            NSLog(@"歌词不存在");
    //        }
    //        buttonmusic = [UIButton buttonWithType:UIButtonTypeCustom];
    //        buttonmusic.frame = CGRectMake(80,0,50,30);
    //        [buttonmusic addTarget:self action:@selector(musicPlay) forControlEvents:UIControlEventTouchUpInside];
    //        [buttonmusic setTitle:YZMsg(@"Livebroadcast_end") forState:UIControlStateNormal];
    //        buttonmusic.backgroundColor = [UIColor clearColor];
    //        [buttonmusic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //        buttonmusic.layer.masksToBounds = YES;
    //        buttonmusic.layer.cornerRadius = 10;
    //        buttonmusic.layer.borderWidth = 1;
    //        buttonmusic.layer.borderColor = [UIColor whiteColor].CGColor;
    //        [musicV addSubview:buttonmusic];
    //
    //        if (!lrcTimer) {
    //            lrcTimer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMusicTimeLabel) userInfo:self repeats:YES];
    //        }
    //
    //    }else{
    //        [musicV removeFromSuperview];
    //        musicV = nil;
    //        [lrcTimer invalidate];
    //        lrcTimer = nil;
    //    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound ||
        self.navigationController.viewControllers == nil ) {
        [self cancelTimeoutLiveStatus];
    }
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].enableAutoToolbar = true;
}
-(void)cancelTimeoutLiveStatus
{
    if (lotteryTime) {
        [lotteryTime invalidate];
        lotteryTime = nil;
    }
}
// 从nodejs来的LotterySync数据
-(void)setLotteryInfo:(NSDictionary *)msg{
    if(!lotteryInfo){
        lotteryInfo = [NSMutableDictionary dictionary];
    }
    NSString *lotteryType = minstr(msg[@"lotteryType"]);
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
    
    if(lotteryType&&[lotteryType isEqualToString:@"40"]){
        if (lotteryBTN.hidden) {
            lotteryBTN.hidden = NO;
            [lotteryBTN setTitle:@"" forState:UIControlStateNormal];
        }
        //            拉霸打开投注页面,开奖的时候刷新奖池
        if(curLotteryBetVC  && [((LotteryBetViewController_LB*)curLotteryBetVC) respondsToSelector:@selector(getPoolDataInfo)] && timeCountLB == 60){
            [((LotteryBetViewController_LB*)curLotteryBetVC) getPoolDataInfo];
        }
    }
}
-(void)setLotteryBetNot:(LotteryBet *)msg{
    NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(msg.msg.ct.totalmoney) showUnit:YES];
    NSString *ctStr = [NSString stringWithFormat:YZMsg(@"Livebroadcast_name%@_BetType%@_betMoney%@%@"),msg.msg.ct.nickname,msg.msg.ct.lotteryName,currencyCoin,@""];
    titleColor = @"lotteryBet";
    NSString *ct = ctStr;
    NSString *lotteryType = minnum(msg.msg.lotteryType);
    NSString *way = msg.msg.waySt;
    NSString *money = msg.msg.money;
    money = [money stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    money = [money stringByReplacingOccurrencesOfString:@"[" withString:@""];
    money = [money stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray * arr = [money componentsSeparatedByString:@","];
    float moneyNum = 0;
    for (int i= 0; i< arr.count; i++) {
        NSString * numStr = arr[i];
        moneyNum = moneyNum + [numStr floatValue];
    }
    BOOL isCloseAdv = [[NSUserDefaults standardUserDefaults] boolForKey:@"isCloseAdv"];
    NSString * live_betNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"live_betNum"];
    if (isCloseAdv && moneyNum < [live_betNum floatValue]) {
        return;
    }
    NSString *issue = minnum(msg.msg.issue);
    NSString *optionName = msg.msg.optionNameSt;
    NSString *uname = YZMsg(@"");
    BOOL chat_self_show = msg.msg.chatSelfShow;
    NSString *ID = [NSString stringWithFormat:@"%u",msg.msg.uid];
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:
                          uname,@"userName",
                          ct,@"contentChat",
                          ID,@"id",
                          titleColor,@"titleColor",
                          lotteryType,@"lotteryType",
                          way,@"way",
                          money,@"money",
                          issue,@"issue",
                          optionName,@"optionName",
                          nil];
    titleColor = @"0";
    
    if (chat_self_show) {
        if ([[Config getOwnID] isEqualToString:ID]||([[Config getOwnID] integerValue] == msg.msg.uid)) {
            [self addNewMsgFromMsgDic:chat];
        }
    }else{
        [self addNewMsgFromMsgDic:chat];
    }
}
-(void)addOpenAward:(NSDictionary *)msg{
    if([minstr(msg[@"lotteryType"]) isEqualToString:minstr(roomLotteryInfo[@"lotteryType"])] || [minstr(msg[@"lotteryType"]) isEqualToString:[NSString stringWithFormat:@"%ld", [GameToolClass getCurOpenedLotteryType]]]){
        
        NSString *lastIssue = minstr(msg[@"issue"]);
        if ([lastIssue isKindOfClass:[NSString class]] ) {
            if ([lastOpenedIssues containsObject:lastIssue]) {
                return;
            }else{
                [lastOpenedIssues addObject:lastIssue];
                if (lastOpenedIssues.count>15) {
                    [lastOpenedIssues removeObjectsInRange:NSMakeRange(0, 5)];
                }
            }
        }
        
        NSString *type = minstr(msg[@"lotteryType"]);
        if ((type.integerValue == 8 || type.integerValue == 10 || type.integerValue == 11 ||
             type.integerValue == 14 || type.integerValue == 26)) {
            NSMutableDictionary *dicResult = [NSMutableDictionary dictionaryWithDictionary:@{
                @"name":msg[@"name"],
                @"lastResult":@{@"open_result":msg[@"result"]},
                @"lotteryType":minstr(msg[@"lotteryType"]),
                @"issue":msg[@"issue"],
                
            }];
            OpenAwardViewController *open;
            if ([minstr(msg[@"lotteryType"]) integerValue] == 10) {
                
                open = [[OpenAwardViewController alloc] initWithNibName:@"OpenAwardNNViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                [dicResult setObject:msg[@"niu"] forKey:@"niu"];
                [dicResult setObject:msg[@"sum_result_str"] forKey:@"sum_result_str"];
            }else{
                open = [[OpenAwardViewController alloc] initWithNibName:@"OpenAwardViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            }
            
            
            [open setOpenAwardInfo:dicResult];
            
            //        CGFloat p = liveTimeBGView.bottom;
            //UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30
            CGFloat offset = 0;
            if(lastShowOpenAward && [[NSDate date] timeIntervalSinceDate:lastShowOpenAward] < 8){
                if (lastOpenedHeight>0) {
                    offset = lastOpenedHeight + 5;
                }else{
                    offset = open.view.height + 5;
                }
                
            }
            open.view.top = liveTimeBGView.bottom + offset + 5;
            open.view.left = _window_width + open.view.height/2.0;
            [UIView animateWithDuration:0.2 animations:^{
                open.view.left = 5 + open.view.height/2.0;
            }];
            
            [self addChildViewController:open];
            [frontView addSubview:open.view];
            
            NSLog(@"请求同步彩票3");
        }
        NSString *currentIssue = minstr(lotteryInfo[minstr(msg[@"lotteryType"])][@"issue"]);
        if(!currentIssue || [currentIssue isEqualToString:minstr(msg[@"issue"])]){
            if (socketL) {
                [socketL sendSyncLotteryCMD:minstr(msg[@"lotteryType"])];
            }
        }
        
        lastShowOpenAward = [NSDate date];
        //        lastOpenedHeight = open.view.height;
    }
}
-(void)setLotteryProfitNot:(LotteryProfit *)msg{
    NSString *ctStr = [NSString stringWithFormat:YZMsg(@"Livebroadcast_Congratulations_Name%@_game%@"),msg.msg.ct.nickname,msg.msg.ct.lotteryName];
    titleColor = @"lotteryProfit";
    NSString *ct = ctStr;
    NSString *uname = YZMsg(@"");
    NSString *ID = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:
                          uname,@"userName",
                          ct,@"contentChat",
                          ID,@"id",
                          titleColor,@"titleColor",
                          nil];
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
// 主播彩金消息
-(void)setLotteryDividendNot:(LotteryDividend *)msg{
    NSString *currencyCoin = [YBToolClass getNoScaleRateCurrency:minstr(msg.msg.ct.totalmoney) showUnit:YES];
    NSString *ctStr = [NSString stringWithFormat:YZMsg(@"Livebroadcast_shareMoney_fromName%@_lotteryName%@_money%@_%@"),
                       msg.msg.ct.fromName,
                       msg.msg.ct.lotteryName,
                       currencyCoin,
                       @""];
    titleColor = @"lotteryDividend";
    NSString *ct = ctStr;
    NSString *from_uid = minnum(msg.msg.fromUid);
    NSString *uname = YZMsg(@"");
    NSString *ID = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:
                          uname,@"userName",
                          ct,@"contentChat",
                          ID,@"id",
                          from_uid,@"from_uid",
                          @"1",@"lotteryDividend",
                          titleColor,@"titleColor",
                          nil];
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
//彩票中奖飘屏
-(void)setLotteryBarrage:(LotteryBarrage *)msg
{
    WeakSelf
    dispatch_async(self.quenMessageReceive, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        dispatch_main_async_safe((^{
            //        STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSArray *barrage_arr = msg.msg.barrageArrArray;
            if (barrage_arr && barrage_arr.count >0) {
                NSMutableArray *arraysModel = [NSMutableArray array];
                for (LotteryBarrage_Barrage *subDic in barrage_arr) {
                    NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(subDic.ct.totalmoney) showUnit:YES];
                    NSString *ct  = [NSString stringWithFormat:YZMsg(@"LotteryBarrageView_name%@_type%@_way%@_money%@%@"),subDic.ct.nickname,subDic.ct.lotteryName,subDic.ct.way,currencyCoin,@""];
                    NSString *liveuid = minnum(subDic.lid);
                    NSString *lotteryType = minnum(subDic.lt);
                    NSString *typeIcon = @"";
                    switch (subDic.st) {
                        case 1:
                            typeIcon = YZMsg(@"LotteryBarrageView_daxianshenshou");
                            break;
                        case 2:
                            typeIcon = YZMsg(@"LotteryBarrageView_yimingjinren");
                            break;
                        case 3:
                            typeIcon = YZMsg(@"LotteryBarrageView_shouqinitian");
                            break;
                        default:
                            break;
                    }
                    LotteryBarrageModel *model = [[LotteryBarrageModel alloc]init];
                    model.content = ct;
                    model.showImgName = typeIcon;
                    model.liveuid = liveuid;
                    model.lotteryType = lotteryType;
                    [arraysModel addObject:model];
                }
                if (arraysModel.count>0) {
                    [strongSelf showLotteryBarrageView:arraysModel];
                }
            }
        }));
    });
}
static BOOL isShowingLotteryBarrage = NO;

-(void)showLotteryBarrageView:(NSMutableArray<LotteryBarrageModel*>*)models
{
    if (models.count<1) {
        return;
    }
    if (self.lotteryBarrageArrays == nil) {
        self.lotteryBarrageArrays = [NSMutableArray array];
    }
    [self.lotteryBarrageArrays addObjectsFromArray:models];
    if (self.lotteryBarrageArrays.count>12) {
        // 修复：直接截取前12个元素，避免边删除边遍历导致的索引越界问题
        self.lotteryBarrageArrays = [[self.lotteryBarrageArrays subarrayWithRange:NSMakeRange(0, 12)] mutableCopy];
    }
    [self showLotteryBarrage:self.lotteryBarrageArrays.firstObject];
}

-(void)showLotteryBarrage:(LotteryBarrageModel*)model
{
    if (!isShowingLotteryBarrage) {
        isShowingLotteryBarrage = YES;
        WeakSelf
        lotteryView = [LotteryBarrageView showInView:frontView Model:model complete:^{
            STRONGSELF
            if (strongSelf == nil) {
                isShowingLotteryBarrage = NO;
                return;
            }
            if (strongSelf.lotteryBarrageArrays.count>0) {
                [strongSelf.lotteryBarrageArrays removeObjectAtIndex:0];
            }
            isShowingLotteryBarrage= NO;
            if (strongSelf.lotteryBarrageArrays.count>0) {
                [strongSelf showLotteryBarrage:strongSelf.lotteryBarrageArrays.firstObject];
            }
            
        } delegate:self];
    }
}

-(void)lotteryCancless
{
    [curSwitchLotteryVC lotteryCancless];
    curLotteryBetVC = nil;
}
-(void)setLotteryAward:(LotteryAward *)msg
{
    
    float delayTime = 2;
    if ([curLotteryBetVC isKindOfClass:[LotteryBetViewController class]]||[curLotteryBetVC isKindOfClass:[LotteryBetViewController_NN class]]) {
        delayTime = 0;
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        dispatch_sync(strongSelf.quenMessageReceive, ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            dispatch_main_async_safe(^{
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
                model.isCurrentUser = YES;
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
                });
            });
        });
    });
    
    
}
-(void)setGameNot:(kyGame *)msg{
    //    titleColor = [msg valueForKey:@"titleColor"];
    titleColor = @"kygame";
    NSString *ct = msg.msg.ct;
    NSString *gamePlat = msg.msg.gamePlat;
    NSString *gameKindID = minnum(msg.msg.gameKindId);
    NSString *uname = YZMsg(@"");
    NSString *ID = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",ID,@"id",titleColor,@"titleColor",gamePlat,@"gamePlat",gameKindID,@"gameKindID",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
-(void)setPlatGameNot:(platGame *)msg{
    //    titleColor = [msg valueForKey:@"titleColor"];
    titleColor = @"platgame";
    NSString *ct = msg.msg.ct;
    NSString *gamePlat = msg.msg.gamePlat;
    NSString *gameKindID = minnum(msg.msg.gameKindId);
    NSString *uname = YZMsg(@"");
    NSString *ID = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",ID,@"id",titleColor,@"titleColor",gamePlat,@"gamePlat",gameKindID,@"gameKindID",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}

-(void)lotteryBarrageClick:(LotteryBarrageModel *)model
{
    [self doCancle];
    if (model.isCurrentUser) {
        return;
    }
    [self doLotteryWithtype:[model.lotteryType integerValue]];
}

#pragma mark ================ 改变发送按钮图片 ===============
- (void)ChangePushBtnState{
    if (keyField.text.length > 0) {
        pushBTN.selected = YES;
    }else{
        pushBTN.selected = NO;
    }
}
#pragma mark ================ 守护 ===============
- (void)guardBtnClick{
    [self doCancle];
    gShowView = [[guardShowView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andUserGuardMsg:nil andLiveUid:[Config getOwnID]];
    gShowView.delegate = self;
    [self.view addSubview:gShowView];
    [gShowView show];
}

- (void)removeShouhuView{
    if (gShowView) {
        [gShowView removeFromSuperview];
        gShowView = nil;
    }
    
    if (redList) {
        [redList removeFromSuperview];
        redList = nil;
    }
}

- (void)buyOrRenewGuard {
    
}

- (void)updateGuardMsg:(NSDictionary *)dic{
    _voteNums = minstr([dic valueForKey:@"votestotal"]);
    [self changeState];
    [self changeGuardNum:minstr([dic valueForKey:@"guard_nums"])];
    if (listView) {
        [listView listReloadNoew];
    }
    
}
#pragma mark ================ 红包 ===============
- (void)showRedView{
    redBview = [[redBagView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    __weak Livebroadcast *wSelf = self;
    redBview.block = ^(NSString *type) {
        [wSelf sendRedBagSuccess:type];
    };
    redBview.zhuboModel = _roomModel;
    [self.view addSubview:redBview];
}
- (void)sendRedBagSuccess:(NSString *)type{
    [redBview removeFromSuperview];
    redBview = nil;
    if ([type isEqual:@"909"]) {
        return;
    }
    if (socketL) {
        [socketL fahongbaola];
    }
}
- (void)showRedbag:(SendRed *)dic{
    redBagBtn.hidden = NO;
    NSString *uname;
    if ([minnum(dic.msg.uid) isEqual:[Config getOwnID]]) {
        uname = YZMsg(@"Livebroadcast_LiveAnchor");
    }else{
        uname = minstr(dic.msg.uname);
    }
    NSString *levell = minnum(dic.msg.level);
    NSString *ID = minnum(dic.msg.uid);
    NSString *vip_type = minnum(dic.msg.vipType);
    NSString *liangname = dic.msg.liangname;
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",minstr(dic.msg.ct),@"contentChat",levell,@"levelI",ID,@"id",@"redbag",@"titleColor",vip_type,@"vip_type",liangname,@"liangname",nil];
    titleColor = @"0";
    [self addMessageFromMsgDic:chat];
}

- (void)resetRedBagBtnFrame {
    CGFloat height = 0;
    NSString *type = minstr(roomLotteryInfo[@"lotteryType"]);

    if ((type.integerValue == 8 || type.integerValue == 11 || type.integerValue == 14 || type.integerValue == 26)) {
        height = 60;
    } else if(type.integerValue == 10){
        height = 90;
    } else {
        height = 0;
    }
    CGFloat top = liveTimeBGView.bottom + 5 + height + 5;
    redBagBtn.frame = CGRectMake(10, top, 40, 50);
}

- (void)redBagBtnClick{
    redList = [[redListView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) withZHuboMsgModel:_roomModel];
    redList.delegate =self;
    [self.view addSubview:redList];
}

//所有消息addNewMsgFromMsgDic
-(void)addNewMsgFromMsgDic:(NSDictionary*)chat
{
    if ([chat[@"isUserMsg"] length] == 1) {
//        用户消息和系统通告
        [self addMessageFromMsgDic:chat];
    }else{
//        @synchronized (self) {
//            if (messageList.count>50) {
//                [messageList removeObjectsInRange:NSMakeRange(0,1)];
//            }
//            if(messageList.count<1){
//                [messageList addObject:chat];
//                [self dealWithMsgArr];
//            }else{
//                [messageList addObject:chat];
//            }
        //        非用户消息
                [self addMessageFromOtherMsgDic:chat];
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
            [strongSelf addMessageFromMsgDic:dicSub];
        }
        
        [strongSelf->messageList removeObjectAtIndex:0];
        if (strongSelf->messageList.count) {
            [strongSelf dealWithMsgArr];
        }
    });
    
}

//非用户消息刷新显示
-(void)addMessageFromOtherMsgDic:(NSDictionary*)chat
{
    WeakSelf
    dispatch_async(self.messageQueue, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        chatModel *model = [chatModel modelWithDic:chat];
        [model setChatFrame];
        
        @synchronized (strongSelf->messageList) {
            [strongSelf->messageList addObject:model];
            
            // 限制消息列表大小
            if (strongSelf->messageList.count > 70) {
                [strongSelf->messageList removeObjectsInRange:NSMakeRange(0, 20)];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimeInterval timeLim = [[NSDate date] timeIntervalSince1970]*1000;
            if ((timeLim-strongSelf->timeLimitNumber)>200) {
                [strongSelf.tableView reloadData];
                [strongSelf jumpLast];
            }else{
                if (strongSelf->messageList.count<3) {
                    [strongSelf.tableView reloadData];
                    [strongSelf jumpLast];
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSTimeInterval timeLim1 = [[NSDate date] timeIntervalSince1970]*1000;
                        if ((timeLim-strongSelf->timeLimitNumber)>200) {
                            [strongSelf.tableView reloadData];
                            [strongSelf jumpLast];
                        }
                        strongSelf->timeLimitNumber = timeLim1;
                    });
                }
               
            }
            strongSelf->timeLimitNumber = timeLim;
            
        });
    });
}


//用户消息刷新显示
-(void)addMessageFromMsgDic:(NSDictionary*)chat
{
    WeakSelf
    dispatch_sync(self.quenMessageReceive, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        chatModel *model = [chatModel modelWithDic:chat];
        [model setChatFrame];
        @synchronized (strongSelf->msgList) {
           [strongSelf->msgList addObject:model];
        }
        dispatch_main_async_safe(^{
            //        STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf->msgList.count>70) {
                @synchronized (strongSelf->msgList) {
                  [strongSelf->msgList removeObjectsInRange:NSMakeRange(0, 20)];
                }
            }
            NSTimeInterval timeLim = [[NSDate date] timeIntervalSince1970]*1000;
            if ((timeLim-strongSelf->timeLimitNumberUser)>200) {
                if (strongSelf->msgList.count<=3&& !strongSelf->_bDraggingScroll && !strongSelf->_bDraggingScrollUser) {
                    [strongSelf tableViewHieghtDeal];
                    [strongSelf jumpLast];
                }
                [strongSelf.userTableView reloadData];
                [strongSelf userjumpLast];
            }else{
                if (strongSelf->msgList.count<=3&& !strongSelf->_bDraggingScroll && !strongSelf->_bDraggingScrollUser) {
                    [strongSelf tableViewHieghtDeal];
                    [strongSelf.userTableView reloadData];
                    [strongSelf userjumpLast];
                    [strongSelf jumpLast];
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSTimeInterval timeLim1 = [[NSDate date] timeIntervalSince1970]*1000;
                        if ((timeLim-strongSelf->timeLimitNumberUser)>200) {
                            [strongSelf.userTableView reloadData];
                            [strongSelf userjumpLast];
                        }
                        strongSelf->timeLimitNumberUser = timeLim1;
                    });
                }
               
            }
            strongSelf->timeLimitNumberUser = timeLim;
        });
    });
}


-(dispatch_queue_t)quenMessageReceive
{
    if (_quenMessageReceive==nil) {
        _quenMessageReceive = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _quenMessageReceive;
}

// 選擇玩具
- (void)showToyConnectView {
//    SearchToyVC *vc = [[SearchToyVC alloc] init];
//    [self.navigationController pushViewController:vc animated:true];
    AnchorLovenseEditAlertView *view = [AnchorLovenseEditAlertView new];
    [view showFromBottom];
    
    @weakify(self)
    view.clickSwitchBlock = ^(UISwitch *sender) {
        @strongify(self)
        [self showToyConnectViewForSwitch:sender];
    };
}

- (void)showToyConnectViewForSwitch:(UISwitch*)sender {
    if (!sender.isOn) {
//        [self.allConnectedToys removeAllObjects];
        NSString *toyidentifuer = self.connectedToy.identifier;
        if (self.connectedToy && self.connectedToy.isConnected) {
            [[Lovense shared] disconnectToy:toyidentifuer];
            for (LovenseToy *subToy in [Lovense shared].listToys) {
                if ([subToy.identifier isEqualToString:toyidentifuer]) {
                    [[Lovense shared] removeToyById:toyidentifuer];
                }
            }
            [self changeToyStatus:self.connectedToy.isConnected];
        }
        
        return;
    }
    SearchToyVC *vc = [[SearchToyVC alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - ArchorSelectOrderListViewController 選擇指令
- (void)showOrderListView {
    AnchorCmdListAlertView *view = [AnchorCmdListAlertView new];
    view.selectedModels = selectedOrderListModels;
    view.orderSwitchStatus = self.orderSwitchStatus;
    [view showFromBottom];
    
    @weakify(self)
    view.clickSaveBlock = ^(NSArray<RemoteOrderModel *> *models, BOOL status) {
        @strongify(self)
        selectedOrderListModels = [NSArray arrayWithArray:models];
        self.orderSwitchStatus = status;
    };
}

// 選擇 OBS
- (void)showOBSView {
    self.isOBS = true;
    [self createroom];
}

- (void)gotoOBS:(NSString*)push {
    if (_obsInfoView!=nil) {
        return;
    }
    _obsInfoView = [[OBSViewController alloc] init];
    _obsInfoView.delegate = self;
    _obsInfoView.modalPresentationStyle = UIModalPresentationFullScreen;
    WeakSelf;
    [self presentViewController:_obsInfoView animated:true completion:^{
        STRONGSELF;
        [strongSelf onQuit:nil];
        [strongSelf.obsInfoView sendPushStream:push];
    }];
}

#pragma mark - OBSViewControllerDelegate
- (void)oBSViewControllerForCancel {
    [self hostStopRoom];
}

- (void)oBSViewControllerForStart {
    _obsInfoView = nil;
    isOBSStart = true;

    frontView = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height)];
    frontView.clipsToBounds = YES;
    [self.view addSubview:frontView];
    [self.view insertSubview:frontView atIndex:3];

    listView = [[ListCollection alloc]initWithListArray:nil andID:[Config getOwnID] andStream:[NSString stringWithFormat:@"%@",_roomModel.stream]];
    listView.frame = CGRectMake(130,20+statusbarHeight,_window_width-130,40);
    listView.delegate = self;
    [frontView addSubview:listView];
    dispatch_main_async_safe(^{
        [self setView];//加载信息页面
    });

    self.view.backgroundColor = [UIColor clearColor];
    [self showBTN];
    [self getStartShow];
}

#pragma mark - SearchToyVC
-(void)connectSuccessCallback:(NSNotification *)noti {
    NSDictionary * dict = [noti object];
    LovenseToy * connectedToy = [dict objectForKey:@"toy"];
    
    if (self.connectedToy && ![connectedToy.identifier isEqualToString:self.connectedToy.identifier]) {
        if (self.connectedToy.isConnected) {
            [[Lovense shared] disconnectToy:self.connectedToy.identifier];
            for (LovenseToy *subToy in [Lovense shared].listToys) {
                if ([subToy.identifier isEqualToString:self.connectedToy.identifier]) {
                    [[Lovense shared] removeToyById:self.connectedToy.identifier];
                }
            }
        }
    }
   

//    for (LovenseToy * toy in self.allConnectedToys)
//    {
//        if([toy.identifier isEqualToString:connectedToy.identifier])
//        {
//            [self.allConnectedToys removeObject:toy];
//            [self.allConnectedToys addObject:connectedToy];
//            break;
//        }
//    }

    // TODO: bill need test
    [self changeToyStatus:connectedToy.isConnected];
    [_remoteInterfaceView changeBatteryInfo:connectedToy.battery];
    self.connectedToy = connectedToy;
}

-(void)connectBreakCallback:(NSNotification *)noti {
    NSDictionary * resonDict = [noti object];
    LovenseToy * breakToy = [resonDict objectForKey:@"toy"];
    if ([breakToy.identifier isEqualToString:self.connectedToy.identifier]) {
        [self changeToyStatus:breakToy.isConnected];
    }

//    for (int i = 0; i < self.allConnectedToys.count; i++)
//    {
//        LovenseToy * myToy = [self.allConnectedToys objectAtIndex:i];
//        if([breakToy.identifier isEqualToString:myToy.identifier])
//        {
//            [self.allConnectedToys removeObject:myToy];
//            break;
//        }
//    }

    // TODO: bill need test change toy status
//    if (self.connectedToy == nil) {
//        LovenseToy *toy = [self.allConnectedToys firstObject];
//        self.connectedToy = toy;
//        
//    }
}

-(void)toyGetBatteryChange:(NSNotification *)noti {
    NSDictionary *dict = [noti object];
    NSString *batteryString = minstr(dict[@"battery"]);
    if ([dict isKindOfClass:[NSDictionary class]]) {
        LovenseToy *toysA = [dict objectForKey:@"receiveToy"];
        if (toysA ) {
            if ([self.connectedToy.identifier isEqualToString:toysA.identifier]) {
                self.connectedToy = toysA;
            }
        }
    }
    [_remoteInterfaceView changeBatteryInfo:[batteryString intValue]];
}


- (void)changeToyStatus:(BOOL)isConnected {
    [_remoteInterfaceView changeToyStatus:isConnected];
    if (isConnected) {
        self.toySwitchStatus = YES;
        isConnectLabel.text = [NSString stringWithFormat:@"● %@", YZMsg(@"live_toy_open")];
    } else {
        self.toySwitchStatus = NO;
        isConnectLabel.text = [NSString stringWithFormat:@"● %@", YZMsg(@"live_toy_close")];
        if (self.connectedToy!= nil) {
            [MBProgressHUD showError:YZMsg(@"Livebroadcast_error_toyDisconnect")];
            self.connectedToy = nil;
        }
    }
}

#pragma mark - remote control interface
- (RemoteInterfaceView*)remoteInterfaceView {
    if (_remoteInterfaceView != nil) {
        return _remoteInterfaceView;
    }
    RemoteInterfaceView *view = [[RemoteInterfaceView alloc] initWithArchir:true];
    view.delegate = self;
    view.frame = CGRectMake(0, 0, _window_width, _window_height);
    _remoteInterfaceView = view;
    return view;
}

#pragma mark - RemoteInterfaceViewDelegate
- (void)remoteInterfaceViewDelegateForStartToy:(OrderUserModel*)model {
    // TODO: bill send lovense command
    int seconds = [model.second intValue];
    int type = [model.swiftType intValue];
    
    //震动等级1-20
    //模式 1-2-3-4
    //1；波动 2；波浪 3：地震 4；烟花
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    switch (type) {
        case 0:
            [paramDict setObject:@(1) forKey:kSendCommandParamKey_VibrateLevel];
            break;
        case 1:
            [paramDict setObject:@(10) forKey:kSendCommandParamKey_VibrateLevel];
            break;
        case 2:
            [paramDict setObject:@(20) forKey:kSendCommandParamKey_VibrateLevel];
            break;
        case 3:
            [paramDict setObject:@(1) forKey:kSendCommandParamKey_PresetLevel];
            break;
        case 4:
            [paramDict setObject:@(2) forKey:kSendCommandParamKey_PresetLevel];
            break;
        case 5:
            [paramDict setObject:@(4) forKey:kSendCommandParamKey_PresetLevel];
            break;
        case 6:
            [paramDict setObject:@(3) forKey:kSendCommandParamKey_PresetLevel];
            break;
        default:
            [paramDict setObject:@(0) forKey:kSendCommandParamKey_VibrateLevel];
            break;
    }
    
    [[Lovense shared] sendCommandWithToyId:self.connectedToy.identifier andCommandType:type<3?COMMAND_VIBRATE:COMMAND_PRESET andParamDict:paramDict];
    //step 5
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopLast) object:nil];
    [self performSelector:@selector(stopLast) withObject:nil afterDelay:seconds+0.1 inModes:@[NSRunLoopCommonModes]];
    
}

-(void)stopLast{
    NSMutableDictionary * paramDictStop = [NSMutableDictionary dictionary];
    [paramDictStop setObject:@(0) forKey:kSendCommandParamKey_VibrateLevel];

    [[Lovense shared] sendCommandWithToyId:self.connectedToy.identifier andCommandType:COMMAND_VIBRATE andParamDict:paramDictStop];
}
- (void)remoteInterfaceViewDelegateForSelectToy {
    [self showToyConnectView];
}

#pragma mark - lotteryBetViewDelegate
-(void)doGame{
    [self hidenToolbar];
    [self doCancle];
    // switch
    SwitchLotteryViewController *lottery = [[SwitchLotteryViewController alloc]initWithNibName:@"SwitchLotteryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    lottery.lotteryDelegate =self;
    lottery.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self addChildViewController:lottery];
    [self.view addSubview:lottery.view];
    curSwitchLotteryVC = lottery;
}

-(BOOL)cancelLuwu
{
    return NO;
//    BOOL canceled = false;
//    if (giftview!= nil && giftview.top<SCREEN_HEIGHT) {
//        canceled = true;
//    }
//    if (giftview) {
//        [self hidenToolbar];
//        [self changeGiftViewFrameY:_window_height*10];
//    }
//    return canceled;
}
-(void)refreshTableHeight:(BOOL)isShowTopView{

    [self tableViewHieghtDeal];
}
- (void)setCurlotteryVC:(LotteryBetViewController *)vc{
    curLotteryBetVC = vc;
    if (_nplayer && vc == nil) {
//#ifdef LIVE
//        _nplayer.volume=0;
//#else
//        _nplayer.vomume=0;
//#endif
     
    }
}
/*
//礼物按钮
-(void)doLiwu{
    [self hidenToolbar];
    [self doCancle];
    if (giftViewShow == false) {
        giftViewShow = true;
        if (!giftview) {
            //礼物弹窗
            giftview = [[liwuview alloc]initWithModel:self.playDocModel andMyDic:nil];
            giftview.giftDelegate = self;
            [self changeGiftViewFrameY:_window_height*3];
            [self.view addSubview:giftview];
        }
        giftview.guradType = minstr([guardInfo valueForKey:@"type"]);
        
        [self.view bringSubviewToFront:giftview];
        
        backScrollView.userInteractionEnabled = true;
        setFrontV.ZheZhaoBTN.hidden = false;
        setFrontV.backgroundColor = [UIColor clearColor];
        LiveUser *user = [Config myProfile];
        NSString *coinst = [NSString stringWithFormat:@"%.2f", [user.coin floatValue] / 10];
        [giftview chongzhiV:coinst];
        WeakSelf
        [UIView animateWithDuration:0.1 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf changeGiftViewFrameY:_window_height - (_window_width/2+100+ShowDiff)];
        }];
        [self changecontinuegiftframeIndoliwu];
        [self showBTN];
        if (curLotteryBetVC) {
            curLotteryBetVC.isExit = true;
        }
       
    }
    [giftview reloadPushState];
}
 */
 
#pragma mark - 其他
-(void)hidenToolbar
{
    
    //giftViewShow = false;
    isShowingMore = false;
    if (keyField.isFirstResponder) {
        [keyField resignFirstResponder];
    }else{
        [self hidenKeyboard];
    }
}
-(void)hidenKeyboard{
    if (isShowingMore) {
        return;
    }
    [curLotteryBetVC appearToolBar];
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        self.showMoreMessageView.top = _window_height + 10;
        strongSelf->setFrontV.frame = CGRectMake(_window_width,0,_window_width,_window_height);
        strongSelf->listView.frame = CGRectMake(strongSelf->listcollectionviewx, 20+statusbarHeight, _window_width-130,40);
        strongSelf->listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-130, 40);
        if (!self.isLotteryBetView) {
            //strongSelf.horizontalMarquee.hidden = false;
            UIView *viewShadown = [strongSelf->backScrollView viewWithTag:1201202];
            if (viewShadown) {
                viewShadown.hidden = false;
            }
            
        }
       
        
//        if (strongSelf->giftViewShow&&!strongSelf.isLotteryBetView) {
//            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35- 265];
//        }
        if (!strongSelf.isLotteryBetView) {
            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff];
        }else{
            [strongSelf doMoveTableMsg];

        }
        
        //wangminxinliwu
        [strongSelf changecontinuegiftframe];
        strongSelf->toolBar.frame = CGRectMake(0,_window_height + 10,_window_width,88);
        //[strongSelf changeGiftViewFrameY:_window_height*3];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        self.showMoreMessageView.hidden = true;
        strongSelf->toolBar.hidden = 1;
    }];
   
    [self showBTN];
    keyBTN.hidden = false;
}
//-(void)changeGiftViewFrameY:(CGFloat)Y{
//    if(giftview!= nil){
//        giftview.frame = CGRectMake(0,Y, _window_width, _window_width/2+100+ShowDiff);
//        if (Y >= _window_height) {
//            if (liansongliwubottomview!= nil) {
//                liansongliwubottomview.frame = CGRectMake(0, _tableViewTop-150,300,140);
//            }
//           
//        }
//    }
//}
//改变连送礼物的frame
//-(void)changecontinuegiftframeIndoliwu{
//    
//    liansongliwubottomview.frame = CGRectMake(0, _window_height - (_window_width/2+100+ShowDiff)-140,_window_width/2,140);
//}
//- (JhtHorizontalMarquee *)horizontalMarquee {
//    if (!_horizontalMarquee) {
//        _horizontalMarquee = [[JhtHorizontalMarquee alloc] initWithFrame:CGRectMake(_window_width + 4,UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30,_window_width - 88,30) singleScrollDuration:0.0];
//        
//        _horizontalMarquee.tag = 100;
//        // 添加点击手势
//        UITapGestureRecognizer *htap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(marqueeTapGes:)];
//        [_horizontalMarquee addGestureRecognizer:htap];
//    }
//    
//    return _horizontalMarquee;
//}
#endif

@end


