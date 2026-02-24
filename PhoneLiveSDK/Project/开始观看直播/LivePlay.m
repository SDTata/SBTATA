#import "LivePlay.h"
#import "MessageListModel.h"
#import "RandomRule.h"
#import "ZYGlKImageView.h"
#import "impressVC.h"
#import "UIView+GYPop.h"
#import "NSTimer+Hook.h"
#import "OneBuyGirlViewController.h"
#import "LuckyDrawViewController.h"
#import "TaskCenterMainVC.h"
#import "LivePlayNOScrollView.h"
#import <UMCommon/UMCommon.h>
#import "WebViewController.h"

/*
 tableview->->backscrollview 4
 _danmuView->backscrollview 5
 gamevc->backscrollview 6
 userview->backscroll添加 7
 haohualiwuv->backscrollview 8
 liansongliwubottomview->backscrollview 8
 
 
 
 UI层次（从低到高，防止覆盖问题）
 tableview（聊天） 4
 弹幕 5
 game 5
 私信 7
 私信聊天 8
 礼物（连送、豪华）9
 弹窗 window add
 */

#import <ReplayKit/ReplayKit.h>
#import "MNFloatBtn.h"
#import "BetConfirmViewController.h"
#import "OpenAwardViewController.h"
#import "SwitchLotteryViewController.h"
#import "LotteryBetViewController.h"
#import "UUMarqueeView.h"
#import "TopTodayView.h"
#import "LotteryBarrageView.h"
#import "EnterLivePlay.h"
#import "LotteryAwardVController.h"
#import "LotteryBetViewController_NN.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "LiveEncodeCommon.h"
#import "LiveActivityView.h"
#import "TaskVC.h"
#import "GameHomeMainVC.h"
#import "myWithdrawVC2.h"
#import "RotationVC.h"
#import "NavWeb.h"
#import "UINavModalWebView.h"
#import "LiveContactView.h"
#import "jubaoVC.h"
#import "FirstInvestAlert.h"
#import "LiveClosePopView.h"
#import "LotteryBetViewController_YFKS.h"
#import "LotteryBetViewController_BJL.h"
#import "LotteryBetViewController_ZP.h"
#import "LotteryBetViewController_ZJH.h"
#import "LotteryBetViewController_LH.h"
#import "LotteryBetViewController_LB.h"
#import "LotteryBetViewController_SC.h"
#import "LotteryBetViewController_LHC.h"
#import "HotAndAttentionPreviewLogic.h"
#import "LotteryBetViewController_SSC.h"
#import "LotteryBetViewController_NNN.h"

#import "CustomAlertView.h"
#import "SDCycleScrollView.h"

#undef NO

//新礼物结束
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define upViewW     _window_width*0.8
#define _tableViewTop  _window_height - _window_height*0.35 - 40 - 50 - ShowDiff
#define _tableViewBottom  setFrontV.frame.size.height - 50 - ShowDiff -40


@import RyukieSwifty;
@interface moviePlay ()
<
UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,dianjishijian,UIScrollViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate ,catSwitchDelegate,UIAlertViewDelegate,socketDelegate,frontviewDelegate,sendGiftDelegate,upmessageKickAndShutUp,haohuadelegate,listDelegate,shouhuViewDelegate,guardShowDelegate,redListViewDelegate,TopTodatDelegate,LotteryBarrageDelegate,TaskJumpDelegate,lotteryBetViewDelegate,LiveContactView,NodePlayerDelegate,CAAnimationDelegate
,RemoteControllerViewControllerDelegate, RemoteInterfaceViewDelegate,UUMarqueeViewDelegate, SDCycleScrollViewDelegate>
{
    LotteryBarrageView *lotteryView;
    LotteryAwardVController *lotteryAwardVC;
    BOOL showAwardVC;
    UIImageView  *bigAvatarImageView1;
    BOOL showContactButton;
    
    NSMutableArray *msgList;
    NSMutableArray *messageList;  // 非用户消息
    FirstInvestAlert *alertGiftShow;
    UIAlertController  *Feedeductionalertc;//扣费alert
    UIAlertController *md5AlertController;
    BOOL isSuperAdmin;
    int startLinkTime;
    //切换房间后5s倒计时
//    NSTimer *changeliveTimer;
    int startchangeTime;
    
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
    
    
    SwitchLotteryViewController *curSwitchLotteryVC;
    // 横向 跑马灯
    UUMarqueeView *_horizontalMarquee;
    CGFloat lastOpenedHeight; /// 记录上次视图尺寸
    NSMutableArray *lastOpenedIssues;
    
    BOOL isencryption;
    ///新消息提醒
    UIButton *newMsgButton;
    BOOL isShowingMore;
    LotteryBetViewController *curLotteryBetVC;
    NSTimeInterval timeLimitNumber;
    NSTimeInterval timeLimitNumberUser;
    BOOL isOpenLotteryWindow;
    BOOL isConnectSocket;
    BOOL isFirstLoad;
}
@property(nonatomic,strong)NSMutableArray *lotteryBarrageArrays;
// 右邊按鈕選單
@property (nonatomic, strong) UIStackView *circleManualStackView;
@property(nonatomic,strong) LiveActivityButton *v_getContact;//获取名片 live_contact
@property(nonatomic,strong) LiveActivityButton *v_remoteToy;//遙控玩具 live_toy
@property(nonatomic,strong) LiveActivityButton *v_giveOrders;//下達指令 live_command
@property(nonatomic,strong) LiveActivityButton *v_recharge;//充值 charge
@property (nonatomic, strong) dispatch_queue_t messageQueue;

// 更多驚喜
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSMutableArray *otherIcons;

@property(nonatomic,strong) LiveActivityButton *v_lottery;//彩票
@property(nonatomic,strong) LiveActivityButton *v_circle;//大转盘
@property(nonatomic,strong) LiveActivityButton *v_thirdLink;//外链 custom_url

@property(nonatomic,strong) UIView *showMoreMessageView;//外链
@property(nonatomic,assign) int quikSayNum;//外链
@property (nonatomic, strong)LiveClosePopView * liveClosePopView;
@property (nonatomic, strong)NSDate * starteDate;    // 进入直播间的时间
@property (nonatomic, strong)NSString * isAttention; // 是否关注主播
@property(nonatomic,assign) int countNum;  // 退出弹框最少观看时间
@property(nonatomic,assign) BOOL isLotteryBetView;  // 投注界面是否在展示
@property (nonatomic, strong)NSMutableArray * lotteryShowArr;

@property (nonatomic, strong)CustomAlertView *alertShowForLive;

@property (strong, nonatomic) NSMutableArray<dispatch_block_t> *pendingDleayBlocks;
@property(nonatomic, strong) RemoteInterfaceView *remoteInterfaceView;
@property(nonatomic, strong) RemoteControllerViewController *remoteController;

@property (nonatomic, strong) NSArray *leftwardMarqueeViewData;

@end
int d =1;
@implementation moviePlay

-(void)changeBtnFrame:(CGFloat)hhh{
    hhh = hhh - ShowDiff;
   
    CGFloat  wwwssss = 30;
    keyBTN.frame = CGRectMake(_window_width + 15,hhh, 120, www);
    _returnCancle.frame = CGRectMake(_window_width*2-wwwssss-10,hhh,wwwssss,wwwssss);
    _fenxiangBTN.frame = CGRectMake(_window_width*2 - wwwssss*2-20,hhh,wwwssss,wwwssss);
    _messageBTN.frame = CGRectMake(_window_width*2 - wwwssss*3-30,hhh, wwwssss, wwwssss);
    sendBagBtn.frame = CGRectMake(_window_width*2 - wwwssss*4-40,hhh, wwwssss,wwwssss);
    _liwuBTN.frame = CGRectMake(_window_width*2 - wwwssss*5-50,hhh, wwwssss,wwwssss);
    _closeAdBTN.frame = CGRectMake(_window_width*2 - wwwssss*6-50,hhh, wwwssss,wwwssss);
    self.v_lottery.frame = CGRectMake(_window_width*2 - AD(70), _tableViewTop-30, AD(70), AD(70));
    NSArray *shareplatforms = [common share_type];
    
    if (shareplatforms.count == 0) {
        _fenxiangBTN.hidden = true;
        _messageBTN.frame = CGRectMake(_window_width*2 - wwwssss*2-20,hhh,wwwssss,wwwssss);
        sendBagBtn.frame = CGRectMake(_window_width*2 - wwwssss*3-30,hhh, wwwssss, wwwssss);
        _liwuBTN.frame = CGRectMake(_window_width*2 - wwwssss*4-40,hhh, wwwssss, wwwssss);
        _gameBTN.frame = CGRectMake(_window_width*2 - wwwssss*5-40,hhh,wwwssss,wwwssss);
        _closeAdBTN.frame = CGRectMake(_window_width*2 - wwwssss*6-50,hhh, wwwssss,wwwssss);
    }
    
}

//*****************************************************************************
-(void)superAdmin:(NSString *)state{
    if (socketDelegate) {
        [socketDelegate superStopRoom];
    }
    
    haohualiwuV.expensiveGiftCount = nil;
    [self releaseObservers];
    [self lastView];
}
-(void)roomCloseByAdmin{
    [self lastView];
}
-(void)addZombieByArray:(NSArray *)array{
    if (!listView) {
        listView = [[ListCollection alloc]initWithListArray:_listArray andID:self.playDocModel.zhuboID andStream:[NSString stringWithFormat:@"%@",self.playDocModel.stream]];
        listView.delegate = self;
        listView.frame = CGRectMake(_window_width+110, 20 + statusbarHeight, _window_width-130, 40);
        listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-130, 40);
        if (_remoteInterfaceView) {
            [backScrollView insertSubview:listView belowSubview:_remoteInterfaceView];
        } else {
            [backScrollView addSubview:listView];
        }
    }
    [listView listarrayAddArray:array];
    userCount += array.count;

}
-(void)light:(NSDictionary *)chats{
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chats];
}
-(void)messageListen:(NSDictionary *)chats{
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chats];
}
-(void)lotterConnect{
    if (!isConnectSocket) {
        isConnectSocket = true;
        
        UIViewController *superController = self.parentViewController;
        if ([superController isKindOfClass:[LivePlayTableVC class]]) {
            LivePlayTableVC *superVC = (LivePlayTableVC*)superController;
            
            if (isOpenLotteryWindow && lotteryTime != nil && superVC.shouldTriggerDecelerating) {
                if(!([_livetype isEqualToString:@"2"]||[_livetype isEqualToString:@"3"])){
                    if(_isChckedLive){
                        [self doLottery];
                    }else{
                        //等检查完弹框
                        WeakSelf
                        dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                            // 你的延迟代码
                            STRONGSELF
                                                       if(strongSelf == nil||strongSelf->lotteryTime == nil){
                                                           return;
                                                       }
                                                       [strongSelf lotterConnect];
                        });

                        [self.pendingDleayBlocks addObject:delayBlock];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
                    }
                   
                }
               
            }
        }else{
            if (isOpenLotteryWindow && lotteryTime != nil) {
                [self doLottery];
            }
        }
       
    }
}
-(void)UserLeave:(NSDictionary *)msg{
    userCount -= 1;
    if (listView) {
        [listView userLive:msg];
    }
}
//********************************用户进入动画********************************************//
-(void)UserAccess:(NSDictionary *)msg{
    //用户进入
    userCount += 1;
    if (listView) {
        [listView userAccess:msg];
    }
    //    setFrontV.onlineLabel.text = [NSString stringWithFormat:@"%lld",userCount];
    NSString *vipType = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"vip_type"]];
    NSString *guard_type = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"guard_type"]];
    NSString *user_level = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"level"]];
    NSString *king_icon = [NSString stringWithFormat:@"%@",[[msg valueForKey:@"ct"] valueForKey:@"king_icon"]];
    
    int userLevel = [user_level intValue];
    int levelLimits = [[Config getShowLevel] intValue];
    if ([Config getShowLevel]==nil) {
        levelLimits = 15;
        [[NSNotificationCenter defaultCenter] postNotificationName:KGetBaseInfoNotification object:nil];
    }
    
    BOOL bShowInChatView = true;
    if (userLevel >= levelLimits||[vipType isEqual:@"1"] || [guard_type isEqual:@"1"] || [guard_type isEqual:@"2"] /*|| ![PublicObj checkNull:king_icon]*/) {
        if(!_isLotteryBetView){
            [useraimation addUserMove:msg];
            useraimation.frame = CGRectMake(_window_width + 10,_tableViewTop - 40,_window_width,20);
        }
    }else if(userLevel < levelLimits){
        [nuseraimation addUserMove:msg];
        nuseraimation.frame = CGRectMake(_window_width + 10,_tableViewBottom,_window_width,20);
        bShowInChatView = false;
    }
   
    NSString *car_id = minstr([[msg valueForKey:@"ct"] valueForKey:@"car_id"]);
    if (![car_id isEqual:@"0"] && !_isLotteryBetView) {
        if (!vipanimation) {
            WeakSelf
            vipanimation = [[viplogin alloc]initWithFrame:CGRectMake(_window_width,0,_window_width,_window_height) andBlock:^(id arrays) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf->vipanimation removeFromSuperview];
                strongSelf->vipanimation = nil;
            }];
            vipanimation.frame =CGRectMake(_window_width,0,_window_width,_window_height);
            [backScrollView insertSubview:vipanimation atIndex:11];
            vipanimation.userInteractionEnabled = false;
         
        }
        [vipanimation addUserMove:msg];
    }
    
    if(bShowInChatView){
        [self userLoginSendMSG:msg];
    }
}
//用户进入直播间发送XXX进入了直播间
-(void)userLoginSendMSG:(NSDictionary *)dic {
    titleColor = @"userLogin";
    NSString *uname = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"user_nicename"]];
    NSString *levell = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"level"]];
    NSString *ID = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"id"]];
    NSString *vip_type = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"vip_type"]];
    NSString *king_icon = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"king_icon"]];
    
    NSString *liangname = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"liangname"]];
    NSString *usertype = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"usertype"]];
    NSString *guard_type = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"guard_type"]];
    
    NSString *conttt = [@" " stringByAppendingString:YZMsg(@"nuserLoginAnimation_enter_room")];
    NSString *isadminn;
    if ([[NSString stringWithFormat:@"%@",[[dic valueForKey:@"ct"] valueForKey:@"usertype"]] isEqual:@"40"]) {
        isadminn = @"1";
    }else{
        isadminn = @"0";
    }
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",conttt,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",usertype,@"usertype",guard_type,@"guard_type",king_icon?king_icon:@"",@"king_icon",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
////////////////////////////////////////////////////
-(void)LiveOff{
    [self lastView];
}
-(void)sendLight{
    [self staredMove];
}
-(void)socketShowChatSystem:(NSDictionary *)msg
{
    titleColor = @"firstlogin";
    NSString *ct = [msg valueForKey:@"ct"];
    NSString *uname = YZMsg(@"Livebroadcast_LiveMsgs");
    NSString *ID = @"";
    NSString * isSeverMsg = @"";
    if (ct.length > 50){
        isSeverMsg = @"1";
    }
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",ID,@"id",titleColor,@"titleColor",isSeverMsg,@"isSeverMsg",nil];

    titleColor = @"0";
    if(self){
        [self addMessageFromMsgDic:chat];
    }
    [self lotterConnect];
}
-(void)timeDelayUpdate:(long long)timeDelayNum
{
    [setFrontV updateSpeedValue:timeDelayNum];
}


-(void)setSystemNot:(NSDictionary *)msg{
    titleColor = @"firstlogin";
    NSString *ct = [msg valueForKey:@"ct"];
    NSString *uname = YZMsg(@"Livebroadcast_LiveMsgs");
    NSString *ID = @"";
    NSString * isSeverMsg = @"";
    if (ct.length > 50){
        isSeverMsg = @"1";
    }
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",ID,@"id",titleColor,@"titleColor",isSeverMsg,@"isSeverMsg",nil];

    titleColor = @"0";
    if (isSeverMsg.length>0) {
        [self addMessageFromOtherMsgDic:chat];
    }else{
        [self addMessageFromMsgDic:chat];
    }
    [self lotterConnect];
}

-(void)setGameNot:(kyGame *)msg{
    //    titleColor = [msg valueForKey:@"titleColor"];
    titleColor = @"kygame";
    NSString *ct = msg.msg.ct;
    NSString *gamePlat = minstr(msg.msg.gamePlat);
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
    NSString *gamePlat = minstr(msg.msg.gamePlat);
    NSString *gameKindID = minstr(msg.msg.gameKindId);
    NSString *uname = YZMsg(@"");
    NSString *ID = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",ID,@"id",titleColor,@"titleColor",gamePlat,@"gamePlat",gameKindID,@"gameKindID",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
//从http请求回来的信息 逆同步
- (void)lotteryRsync:(NSNotification *)notification {
    NSString* lotteryType = minstr(notification.userInfo[@"lotteryType"]);
    NSDictionary *msg = @{
        @"lotteryType":lotteryType,
        @"lotteryInfo":notification.userInfo
    };
    [self setLotteryInfo:msg];
}


// 从nodejs来的LotterySync数据
-(void)setLotteryInfo:(NSDictionary *)msg{
    if(!lotteryInfo){
        lotteryInfo = [NSMutableDictionary dictionary];
    }
    NSString *lotteryType = msg[@"lotteryType"];
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
    if(roomLotteryInfo != nil && ((roomLotteryInfo[@"lotteryType"] &&[[PublicObj checkNull:roomLotteryInfo[@"lotteryType"]]?@"0":roomLotteryInfo[@"lotteryType"] intValue] == 40) ||curSwitchLotteryVC.gameTag == 40 )){
        self.v_lottery.hidden = false;
        [self.v_lottery setTitle:@"" forState:UIControlStateNormal];
//            拉霸打开投注页面,开奖的时候刷新奖池
        if(curLotteryBetVC  && [((LotteryBetViewController_LB*)curLotteryBetVC) respondsToSelector:@selector(getPoolDataInfo)] ){
            [((LotteryBetViewController_LB*)curLotteryBetVC) getPoolDataInfo];
        }else{
            if(curSwitchLotteryVC && curSwitchLotteryVC.gameTag == 40){
                [curSwitchLotteryVC getPoolDataInfo];
            }
        }
        
    }

}
-(void)setLotteryBetNot:(LotteryBet *)msg{
    NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(msg.msg.ct.totalmoney) showUnit:YES];
    NSString *ctStr = [NSString stringWithFormat:YZMsg(@"Livebroadcast_name%@_BetType%@_betMoney%@%@"),msg.msg.ct.nickname,msg.msg.ct.lotteryName,currencyCoin,@""];
    titleColor = @"lotteryBet";
    NSString *ct = ctStr;
    NSString *lotteryType = minnum(msg.msg.lotteryType);
    NSString *ways = msg.msg.waySt;
    NSString *way = msg.msg.way;
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
    NSString *optionName = msg.msg.optionName;
    NSString *optionNameSt = msg.msg.optionNameSt;
    NSString *uname = YZMsg(@"");
    NSString *ID = [NSString stringWithFormat:@"%u",msg.msg.uid];
    BOOL chat_self_show = msg.msg.chatSelfShow;
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:
                          uname,@"userName",
                          ct,@"contentChat",
                          ID,@"id",
                          titleColor,@"titleColor",
                          lotteryType,@"lotteryType",
                          way,@"way",
                          ways,@"ways",
                          money,@"money",
                          issue,@"issue",
                          optionName,@"optionName",
                          optionNameSt,@"optionNameSt",
                          nil];
    
    titleColor = @"0";
    if (chat_self_show) {
        if ([[Config getOwnID] isEqualToString:ID]||([[Config getOwnID] integerValue] == msg.msg.uid)) {
            [self addNewMsgFromMsgDic:chat];
        }
    }else{
        [self addNewMsgFromMsgDic:chat];
    }
   
    ///
}
-(void)addOpenAward:(NSDictionary *)msg{
    
    
    if (!lastOpenedIssues) {
        lastOpenedIssues = [NSMutableArray array];
    }
    NSString *lastType = msg[@"lotteryType"];
    NSString *lastIssue = [minstr(msg[@"issue"]) stringByAppendingString:lastType];
    if ([lastIssue isKindOfClass:[NSString class]] ) {
        if ([lastOpenedIssues containsObject:lastIssue]) {
            return;
        }else{
            [lastOpenedIssues addObject:lastIssue];
            if (lastOpenedIssues.count>20) {
                [lastOpenedIssues removeObjectsInRange:NSMakeRange(0, 5)];
            }
        }
    }
    
    
    BOOL isC =  [minstr(msg[@"lotteryType"]) isEqualToString:minstr(roomLotteryInfo[@"lotteryType"])];
    BOOL isOpen = [minstr(msg[@"lotteryType"]) isEqualToString:[NSString stringWithFormat:@"%ld", [GameToolClass getCurOpenedLotteryType]]];
    
    NSString *type = minstr(msg[@"lotteryType"]);
    
    NSString *openCurrentType = [NSString stringWithFormat:@"%ld",labs([GameToolClass getCurOpenedLotteryType])];
    NSString *currentType = roomLotteryInfo[@"lotteryType"];
    
    
    NSString *currentIssue = minstr(lotteryInfo[minstr(currentType)][@"issue"]);
    NSString *currentOpenWindowIssue = minstr(lotteryInfo[openCurrentType][@"issue"]);
    
    if(!currentIssue || ([type isEqualToString:openCurrentType]&&([minstr(msg[@"issue"]) isEqualToString:currentOpenWindowIssue]||(curLotteryBetVC && [curLotteryBetVC.curIssue isEqualToString:minstr(msg[@"issue"])] ))) ||([type isEqualToString:currentType]&&[minstr(msg[@"issue"]) isEqualToString:currentIssue]) ){
        if (socketDelegate) {
            [socketDelegate sendSyncLotteryCMD:minstr(msg[@"lotteryType"])];
        }
        
    }
    
    
    if ([GameToolClass getCurOpenedLotteryType] < 0 && [type isEqualToString:openCurrentType]) {
        return;
    }
    
    if(isC || isOpen){
        
        if ((type.integerValue == 8 || type.integerValue == 10 || type.integerValue == 11|| type.integerValue == 6 ||
            type.integerValue == 14 || type.integerValue == 26|| type.integerValue == 27||type.integerValue == 30||type.integerValue == 28||type.integerValue == 29||type.integerValue == 31)) {
            NSMutableDictionary *dicResult =  [NSMutableDictionary dictionaryWithDictionary:@{
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
            if (type.integerValue == 28||type.integerValue == 29||type.integerValue == 31) {
                [open setOpenAwardInfo:msg];
                open.view.height = 70;
            }else if(type.integerValue == 10){
                [open setOpenAwardInfo:dicResult];
                open.view.height = 90;
            }else{
                [open setOpenAwardInfo:dicResult];
                open.view.height = 54;
            }
           
            
//            CGFloat p = guardView.bottom;
            CGFloat offset = 0;
            if(lastShowOpenAward && [[NSDate date] timeIntervalSinceDate:lastShowOpenAward] < 8){
                if (lastOpenedHeight>0) { ///避免不同尺寸引起错误
                    offset = lastOpenedHeight + 5;
                }else{
                    offset = open.view.height + 5;
                }

            }
//            UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30;
            open.view.top = UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30 + 35 + offset;
            open.view.left = _window_width*2 + open.view.height/2.0;;
            [UIView animateWithDuration:0.2 animations:^{
                open.view.left = 5+_window_width + open.view.height/2.0;
            }];

            [self addChildViewController:open];
            if (_remoteInterfaceView) {
                [backScrollView insertSubview:open.view belowSubview:_remoteInterfaceView];
            } else {
                [backScrollView addSubview:open.view];
            }
            
            lastOpenedHeight = open.view.height;
            NSLog(@"请求同步彩票3");
        }
        
        
        lastShowOpenAward = [NSDate date];
        
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
                    NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(subDic.ct.totalmoney) showUnit:YES];
                    NSString *contentStr  = [NSString stringWithFormat:YZMsg(@"LotteryBarrageView_name%@_type%@_way%@_money%@%@"),subDic.ct.nickname,subDic.ct.lotteryName,subDic.ct.way,currencyCoin,@""];
                    model.content = contentStr;
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
static BOOL isShowingLotteryBarrage = false;

-(void)showLotteryBarrageView:(NSMutableArray<LotteryBarrageModel*>*)models
{
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
        isShowingLotteryBarrage = true;
        WeakSelf
        lotteryView = [LotteryBarrageView showInView:setFrontV Model:model complete:^{
            STRONGSELF
            if (strongSelf == nil) {
                isShowingLotteryBarrage = false;
                return;
            }
            if (strongSelf.lotteryBarrageArrays.count>0) {
                [strongSelf.lotteryBarrageArrays removeObjectAtIndex:0];
            }
            isShowingLotteryBarrage= false;
            if (strongSelf.lotteryBarrageArrays.count>0) {
                [strongSelf showLotteryBarrage:strongSelf.lotteryBarrageArrays.firstObject];
            }
            
        } delegate:self];
    }
}

-(void)setLotteryAward:(LotteryAward *)msg
{
    float timeDelay = 2;
    NSArray *childVC = self.childViewControllers;
    if (childVC!= nil) {
        for (int i = 0; i<childVC.count; i++) {
            id childV = childVC[i];
            if ([childV isKindOfClass:[LotteryBetViewController class]] ||
                [childV isKindOfClass:[LotteryBetViewController_NN class]])
            {
                timeDelay = 0;
                break;
            }
        }
    }
    if ([curLotteryBetVC isKindOfClass:[LotteryBetViewController class]] ||
        [curLotteryBetVC isKindOfClass:[LotteryBetViewController_NN class]])
    {
        timeDelay = 0;
    } else if ([curLotteryBetVC isKindOfClass:[LotteryBetViewController_SC class]]) {
        timeDelay = 4;
    } else if ([curLotteryBetVC isKindOfClass:[LotteryBetViewController_SSC class]]) {
        timeDelay = 1;
    } else if ([curLotteryBetVC isKindOfClass:[LotteryBetViewController_LHC class]]) {
        timeDelay = 3;
    }
    
    WeakSelf
    dispatch_block_t delayBlock = dispatch_block_create(0, ^{
        // 你的延迟代码
        STRONGSELF
        if (strongSelf == nil||strongSelf->lotteryTime == nil) {
            return;
        }
        [strongSelf.lotteryShowArr addObject:msg];
        if (!strongSelf->showAwardVC) {
            [strongSelf showNextLotteryAward];
        }
    });
    
    [self.pendingDleayBlocks addObject:delayBlock];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
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
    dispatch_async(self.quenMessageReceive, ^{
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
            model.isCurrentUser = true;
            model.lotteryType = @"";
            
            strongSelf->lotteryAwardVC = [[LotteryAwardVController alloc]initWithNibName:@"LotteryAwardVController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            strongSelf->lotteryAwardVC.model = model;
            strongSelf->lotteryAwardVC.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [strongSelf addChildViewController:strongSelf->lotteryAwardVC];
            [strongSelf.view addSubview:strongSelf->lotteryAwardVC.view];
            strongSelf->showAwardVC = YES;
            dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                // 你的延迟代码
               
                if (strongSelf == nil && strongSelf->lotteryTime == nil) {
                                    return;
                                }
                                strongSelf->showAwardVC = false;
                dispatch_block_t delayBlock1 = dispatch_block_create(0, ^{
                    // 你的延迟代码
                    if (strongSelf == nil && strongSelf->lotteryTime == nil) {
                                                            return;
                                                        }
                                                        [strongSelf showNextLotteryAward];
                });

                [strongSelf.pendingDleayBlocks addObject:delayBlock1];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),delayBlock1);
            });

            [strongSelf.pendingDleayBlocks addObject:delayBlock];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
        });
    });
    
}

-(void)lotteryBarrageClick:(LotteryBarrageModel *)model
{
    [self hidenToolbar];
    [self doCancle];
    if (model.isCurrentUser) {
        return;
    }
    if (model.liveuid.integerValue>0) {
        if (model.liveuid.integerValue == [self.playDocModel.zhuboID integerValue]) {
            
            [self doLotteryWithtype:[model.lotteryType integerValue]];
        }else{
            
            ///进入直播间
            [[EnterLivePlay sharedInstance]showLivePlayFromLiveID:model.liveuid.integerValue fromInfoPage:false];
        }
    }else{
        [self doLotteryWithtype:[model.lotteryType integerValue]];
    }
}



-(void)setAdmin:(setAdmin *)msg{
    NSString *touid = [NSString stringWithFormat:@"%u",msg.msg.touid];
    
    if ([touid isEqual:[Config getOwnID]]) {
        if ([minnum(msg.msg.action) isEqual:@"0"]) {
            usertype = @"0";
        }else{
            usertype = @"40";
        }
    }
    titleColor = @"firstlogin";
    NSString *ct = msg.msg.ct;
    NSString *uname = YZMsg(@"Livebroadcast_LiveMsgs");
    NSString *ID = @"";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",ID,@"id",titleColor,@"titleColor",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
}
-(void)sendGift:(NSDictionary *)chats andLiansong:(NSString *)liansong andTotalCoin:(NSString *)votestotal andGiftInfo:(NSDictionary *)giftInfo{
    votesTatal = votestotal;
    [setFrontV changeState:votestotal];
    
    //      NSNumber *number = [giftInfo valueForKey:@"giftid"];
    //      NSString *giftid = [NSString stringWithFormat:@"%@",number];
    NSInteger type = [minstr([giftInfo valueForKey:@"type"]) integerValue];
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]init];
        [liansongliwubottomview addSubview:continueGifts];
        //初始化礼物空位
        [continueGifts initGift];
    }
    if (type == 1) {
        [self expensiveGift:giftInfo];
    } else if (type == 3 || type == 4) {
        OrderUserModel *model = [[OrderUserModel alloc] init];
        if (type == 3) { // 跳蛋
            model.type = LiveToyInfoRemoteControllerForToy;
        } else if (type == 4) { //指令
            model.type = LiveToyInfoRemoteControllerForAnchorman;
        }
        model.uid = minstr([giftInfo valueForKey:@"uid"]);
        model.giftID = minstr([giftInfo valueForKey:@"giftid"]);
        model.name = minstr([giftInfo valueForKey:@"nicename"]);
        model.avatar = minstr([giftInfo valueForKey:@"avatar"]);
        model.orderName = minstr([giftInfo valueForKey:@"giftname"]);
        model.second = minstr([giftInfo valueForKey:@"swftime"]);
        model.swiftType = minstr([giftInfo valueForKey:@"swftype"]);
        [_remoteInterfaceView receiveOrderModel:model];
    }
    else{
        [continueGifts GiftPopView:giftInfo andLianSong:haohualiwu];
    }
    //    titleColor = @"0";
    
    [self addNewMsgFromMsgDic:chats];
}
-(void)SendBarrage:(SendBarrage *)msg{
    SendBarrage_CTStruct *ct = msg.msg.ct;
    NSString *name = msg.msg.uname;
    NSString *icon = msg.msg.uhead;
    NSDictionary *userinfo = [[NSDictionary alloc] initWithObjectsAndKeys:ct.content,@"title",name,@"name",icon,@"icon",nil];
    [_danmuView setModel:userinfo];
    long totalcoin = [self.danmuprice intValue];
    [self addCoin:totalcoin];
}
-(void)StartEndLive{
    [self lastView];
}
-(void)UserDisconnect:(disconnect *)msg{
    userCount -= 1;
    //    setFrontV.onlineLabel.text = [NSString stringWithFormat:@"%lld",userCount];
    if (listView) {
        NSDictionary *dic = @{@"ct":@{@"id":minnum(msg.msg.uid)}};
        [listView userLive:dic];
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
    [self.tableViewUserMsg reloadData];
//    _canScrollToBottom = false;
    _canScrollToBottomUser = false;
    
}
-(void)KickUser:(NSDictionary *)chats{
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chats];
}
-(void)kickOK{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:YZMsg(@"LivePlay_KickedRoom") message:nil delegate:self cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil, nil];
    [alert show];
    [self dissmissVC];
}
#pragma ====mark frontview 信息页面==========================
-(void)gongxianbang{
    //跳往魅力值界面
    [self doCancle];
    webH5 *jumpC = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=contribute&a=index&uid=%@&touid=%@&token=%@",[DomainManager sharedInstance].domainGetString,minstr(self.playDocModel.zhuboID),[Config getOwnID],[Config getOwnToken]];
    
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    jumpC.urls = url;
   
    [self.navigationController pushViewController:jumpC animated:true];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"贡献榜"};
    [MobClick event:@"live_room_menue_click" attributes:dict];
}

//加载信息页面
-(void)zhubomessage{
    if (userView) {
        [userView removeFromSuperview];
        userView = nil;
    }
    if (!userView) {
        //        [MNFloatBtn hidden];
        userView = [[upmessageInfo alloc]initWithFrame:CGRectMake(_window_width*0.1,_window_height+20,upViewW,upViewW*4/3+20) andPlayer:@"movieplay"];
        //添加用户列表弹窗
        userView.upmessageDelegate = self;
        userView.backgroundColor = [UIColor whiteColor];
        userView.layer.cornerRadius = 10;
        UIWindow *mainwindows = [UIApplication sharedApplication].keyWindow;
        [mainwindows addSubview:userView];
        //        [MNFloatBtn show];
    }
    self.tanChuangID = self.playDocModel.zhuboID;
    NSDictionary *subdic = @{@"id":self.playDocModel.zhuboID};
    [self GetInformessage:subdic];
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->userView.frame = CGRectMake(_window_width*0.1,(_window_height-upViewW*4/3)/2,upViewW,upViewW*4/3+20);
    }];
    [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@0];
    [MobClick event:@"live_room_contact_click" attributes:@{@"eventType": @(1)}];
}
//改变tableview高度
-(void)tableviewheight:(CGFloat)h{
    CGFloat  userTableH = 0;
    for (int i = 0; i< msgList.count; i++) {
        chatModel * model = msgList[i];
        userTableH = userTableH + model.rowHH + 10;
    }
    if(userTableH > _window_height*0.11 || msgList.count>=3){
        self.tableViewMsg.frame = CGRectMake(_window_width + 5,h - 40,tableWidth,_window_height*0.24);
        self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h - 40+ _window_height*0.24,tableWidth,_window_height*0.11);
    }else{
        self.tableViewMsg.frame = CGRectMake(_window_width + 5,h - 40,tableWidth,_window_height*0.35 - userTableH);
        self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h - 40 + _window_height*0.35 - userTableH,tableWidth,userTableH);
    }
    useraimation.frame = CGRectMake(_window_width + 10,_tableViewTop - 40,_window_width,20);
    //    nuseraimation.frame = CGRectMake(_window_width + 10,self.tableView.bottom,_window_width,20);
    nuseraimation.frame = CGRectMake(_window_width + 10,h - 40 + _window_height*0.35  + 10,_window_width,20);
}
//点击礼物ye消失
-(void)zhezhaoBTNdelegate{
    [self hidenToolbar];
    if (giftview && giftview.giftCountView && giftview.giftCountView.hidden == false) {
        [giftview hideGiftCountView];
        return;
    }

    giftViewShow = false;
    giftview.push.enabled = false;
    setFrontV.ZheZhaoBTN.hidden = true;
    giftview.continuBTN.hidden = true;
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->setFrontV.frame = CGRectMake(_window_width,0,_window_width,_window_height);
        strongSelf->listView.frame = CGRectMake(strongSelf->listcollectionviewx, 20+statusbarHeight, _window_width-130,40);
        strongSelf->listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-130, 40);
        if (strongSelf->giftViewShow) {
            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35- 265];
        }
        else{
//            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff];
        }
        
        [strongSelf changeGiftViewFrameY:_window_height *3];
        
    }];
    keyBTN.hidden = false;
    //wangminxinliwu
    [self changecontinuegiftframe];
    
    
    [self showBTN];
   
}
//页面退出
-(void)returnCancless{
    NSInteger  timeCount = [self timeForReturn:self.starteDate endTime:[NSDate date]];
    
    if ([self.isAttention intValue] == 0  && timeCount > self.countNum) {
        [self.liveClosePopView.titleImgV sd_setImageWithURL:[NSURL URLWithString:minstr(_playDocModel.zhuboIcon)] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
        [self.view gy_creatPopViewWithContentView:self.liveClosePopView withContentViewSize:CGSizeMake(AD(270.f), AD(290.f))];
    }else{
        [self dissmissVC];
    }
    [MobClick event:@"live_room_exit_click" attributes:@{@"eventType": @(1)}];
}

-(void)lotteryCancless
{
    [curSwitchLotteryVC lotteryCancless];
    curLotteryBetVC = nil;
}

-(void)changeGiftViewFrameY:(CGFloat)Y{
    if(giftview!= nil){
        giftview.frame = CGRectMake(0,Y, _window_width, _window_width/2+100+ShowDiff);
        if (Y >= _window_height) {
            if (liansongliwubottomview!= nil) {
                liansongliwubottomview.frame = CGRectMake(0, _tableViewTop-150,300,140);
            }
           
        }
    }
   
    //    if ([[self iphoneType] isEqualToString:@"iPhone X"]) {
    //        giftview.frame = CGRectMake(0,Y-10, _window_width, (_window_width-20)/2+120+ShowDiff);
    //        [giftview setBottomAdd];
    //    }
    
}

-(void)doLottery{
    [self hidenToolbar];
    [self doCancle];
    [self doLotteryWithtype:[minstr(roomLotteryInfo[@"lotteryType"]) integerValue]];
    [self scrollToLastCell];
    [self scrollToLastUserCell];
}
// 游戏弹出时移动聊天列表和直播位置
-(void)doMoveTableMsg{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        CGFloat h = UIApplication.sharedApplication.statusBarFrame.size.height + 45;
     
        CGFloat tableH = _window_height - h -   [YBToolClass sharedInstance].lotteryLiveWindowHeight;
        CGFloat viewH = 25+statusbarHeight;
        
        strongSelf.tableViewMsg.frame = CGRectMake(_window_width + 5,h,_window_width/2 -10,0.7 * tableH);
        strongSelf.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h + 0.7 * tableH,_window_width/2 -10,0.3 * tableH);
        [strongSelf->videoView setFrame: CGRectMake(_window_width/2,viewH,_window_width/2 -5,_window_height -  [YBToolClass sharedInstance].lotteryLiveGameHeight +70  - ShowDiff - viewH)];
        
        strongSelf->videoView.layer.cornerRadius = 5;
        strongSelf->videoView.layer.masksToBounds = YES;
        [strongSelf tableViewHieghtDeal];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf scrollToLastCell];
        [strongSelf scrollToLastUserCell];
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
        if (strongSelf.playDocModel.lottery_type == 10) {
            strongSelf.tableViewMsg.frame = CGRectMake(_window_width + 5,strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.24);
            strongSelf.tableViewUserMsg.frame = CGRectMake(_window_width + 5,strongSelf->setFrontV.frame.size.height - _window_height*0.11 - 50 - ShowDiff -40,tableWidth,_window_height*0.11);
                [strongSelf->videoView setFrame: CGRectMake(0,0,_window_width,_window_height)];
        }else if(strongSelf.playDocModel.lottery_type == 26 || strongSelf.playDocModel.lottery_type == 28){
            strongSelf.tableViewMsg.frame = CGRectMake(_window_width + 5,strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.24);
            strongSelf.tableViewUserMsg.frame = CGRectMake(_window_width + 5,strongSelf->setFrontV.frame.size.height - _window_height*0.11 - 50 - ShowDiff -40,tableWidth,_window_height*0.11);
                [strongSelf->videoView setFrame: CGRectMake(0,0,_window_width,_window_height)];
        } else{
            strongSelf.tableViewMsg.frame = CGRectMake(_window_width + 5,strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.24);
            strongSelf.tableViewUserMsg.frame = CGRectMake(_window_width + 5,strongSelf->setFrontV.frame.size.height - _window_height*0.11 - 50 - ShowDiff -40,tableWidth,_window_height*0.11);
                [strongSelf->videoView setFrame: CGRectMake(0,0,_window_width,_window_height)];
        }
          strongSelf->videoView.layer.cornerRadius = 0;
        [strongSelf tableViewHieghtDeal];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf scrollToLastCell];
        [strongSelf scrollToLastUserCell];
    }];
}

// 点击了投注位置的聊天按钮游戏消失时移动聊天列表和直播位置
-(void)doRecoverTableMsgSecond{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.playDocModel.lottery_type == 10) {

                [strongSelf->videoView setFrame: CGRectMake(0,0,_window_width,_window_height)];
        }else if(strongSelf.playDocModel.lottery_type == 26 || strongSelf.playDocModel.lottery_type == 28){

                [strongSelf->videoView setFrame: CGRectMake(0,0,_window_width,_window_height)];

        } else{

                [strongSelf->videoView setFrame: CGRectMake(0,0,_window_width,_window_height)];

        }

        strongSelf->videoView.layer.cornerRadius = 0;
        [strongSelf tableViewHieghtDeal];
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf scrollToLastCell];
        [strongSelf scrollToLastUserCell];
    }];
}

-(void)doLotteryWithtype:(NSInteger)type
{
    if (curLotteryBetVC!= nil && curLotteryBetVC.parentViewController!= nil) {
        if ([curLotteryBetVC respondsToSelector:@selector(exitView)]) {
            [curLotteryBetVC exitView];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            WeakSelf
            dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                // 你的延迟代码
                STRONGSELF
                                if (strongSelf == nil || strongSelf->lotteryTime == nil) {
                                    return;
                                }
                                [hud hideAnimated:YES];
                                [strongSelf doLotteryWithtype:type];
            });

            [self.pendingDleayBlocks addObject:delayBlock];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
            return;
        }
    }
    if(curSwitchLotteryVC!= nil && curSwitchLotteryVC.parentViewController!= nil){
        if ([curSwitchLotteryVC respondsToSelector:@selector(exitView)]) {
            [curSwitchLotteryVC doExitView];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            WeakSelf
            dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                // 你的延迟代码
                STRONGSELF
                                if (strongSelf == nil|| strongSelf->lotteryTime == nil) {
                                    return;
                                }
                                [hud hideAnimated:YES];
                                [strongSelf doLotteryWithtype:type];

            });

            [self.pendingDleayBlocks addObject:delayBlock];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
            return;
        }
    }
    CGFloat height = LotteryWindowNewHeigh;
    WeakSelf
    if (type == 10) {
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_NN alloc]initWithNibName:@"LotteryBetViewController_NN" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_NN*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowOldNNHeigh;
    }else if(type == 26 && ![YBToolClass sharedInstance].default_old_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_YFKS alloc]initWithNibName:@"LotteryBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_YFKS*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowNewHeighYFKS;
    } else if(type == 28 && ![YBToolClass sharedInstance].default_oldBJL_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_BJL alloc]initWithNibName:@"LotteryBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        height = LotteryWindowNewHeighBJL;
        ((LotteryBetViewController_BJL*)curLotteryBetVC).lotteryDelegate = weakSelf;
    }else if(type == 30 && ![YBToolClass sharedInstance].default_oldZP_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZP alloc]initWithNibName:@"LotteryBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        height = LotteryWindowNewHeighZP;
        ((LotteryBetViewController_ZP*)curLotteryBetVC).lotteryDelegate = weakSelf;
    }else if(type == 29 && ![YBToolClass sharedInstance].default_oldZJH_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZJH alloc]initWithNibName:@"LotteryBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZJH*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowNewHeighZJH;
    }else if(type == 31 && ![YBToolClass sharedInstance].default_oldLH_view){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LH alloc]initWithNibName:@"LotteryBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        height = LotteryWindowNewHeighLH;
        ((LotteryBetViewController_LH*)curLotteryBetVC).lotteryDelegate = weakSelf;
    }else if(type ==40){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LB alloc]initWithNibName:@"LotteryBetViewController_LB" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LB*)curLotteryBetVC).lotteryDelegate = weakSelf;
    }else if(type ==14){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SC alloc]initWithNibName:@"LotteryBetViewController_SC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowNewHeighSC;
    }else if(type ==8){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LHC alloc]initWithNibName:@"LotteryBetViewController_LHC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LHC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowNewHeighLHC;
    }else if((type == 11 || type == 6)){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SSC alloc]initWithNibName:@"LotteryBetViewController_SSC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SSC*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowNewHeighSSC;
     }else{
        curLotteryBetVC = [[LotteryBetViewController alloc]initWithNibName:@"LotteryBetViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController*)curLotteryBetVC).lotteryDelegate = weakSelf;
        height = LotteryWindowOldHeigh;
    }
    [YBToolClass sharedInstance].lotteryLiveWindowHeight = height+ShowDiff;
    [curLotteryBetVC setLotteryType:type];
    
    [self addChildViewController:curLotteryBetVC];
    [self.view addSubview:curLotteryBetVC.view];
    curLotteryBetVC.view.frame = CGRectMake(0, SCREEN_HEIGHT-height-ShowDiff, SCREEN_WIDTH, height+ShowDiff);
    
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
    if (vc!= nil) {
        NSDictionary *dict = @{ @"eventType": @(0),
                                   @"game_name": vc.navigationItem.title?vc.navigationItem.title:@""};
           [MobClick event:@"live_room_game_name_click" attributes:dict];
    }
   
}
-(void)doGame{
    [self hidenToolbar];
    [self doCancle];
    [curSwitchLotteryVC doExitView];
    // switch
    SwitchLotteryViewController *lottery = [[SwitchLotteryViewController alloc]initWithNibName:@"SwitchLotteryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    lottery.lotteryDelegate =self;
    lottery.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self addChildViewController:lottery];
    [self.view addSubview:lottery.view];
    //    [self.view bringSubviewToFront:lottery.view];
    curSwitchLotteryVC = lottery;
    
    //    [GameToolClass enterGame:@"ky" kindID:@"0" autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    //
    //    } fail:^{
    //
    //    }];
    [MobClick event:@"live_room_game_menue_click" attributes:@{@"eventType": @(1)}];
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
    if(curLotteryBetVC){
        [curLotteryBetVC.view removeFromSuperview];
        [curLotteryBetVC removeFromParentViewController];
        curLotteryBetVC = nil;
    }
    curLotteryBetVC = [[LotteryBetViewController alloc]initWithNibName:@"LotteryBetViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    [YBToolClass sharedInstance].lotteryLiveWindowHeight = LotteryWindowOldHeigh+ShowDiff;
    ((LotteryBetViewController*)curLotteryBetVC).lotteryDelegate = self;
    [(LotteryBetViewController *)curLotteryBetVC setLotteryType:curLotteryType];
    
    if ([self.parentViewController isKindOfClass:[SwitchLotteryViewController class]]) {
        [self.parentViewController.view addSubview:curLotteryBetVC.view];
        [self.parentViewController addChildViewController:curLotteryBetVC];
    }else{
        [self.view addSubview:curLotteryBetVC.view];
        [self addChildViewController:curLotteryBetVC];
    }
    curLotteryBetVC.view.frame = CGRectMake(0, SCREEN_HEIGHT-LotteryWindowOldHeigh-ShowDiff, SCREEN_WIDTH, LotteryWindowOldHeigh+ShowDiff);
}
- (void)exchangeVersionToNew:(NSInteger)curLotteryType{
    
    if(curLotteryBetVC){
        [curLotteryBetVC.view removeFromSuperview];
        [curLotteryBetVC removeFromParentViewController];
        curLotteryBetVC = nil;
    }
    
    CGFloat height = LotteryWindowNewHeigh;
    if(curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_YFKS alloc]initWithNibName:@"LotteryBetViewController_YFKS" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_YFKS*)curLotteryBetVC).lotteryDelegate = self;
        [YBToolClass sharedInstance].default_old_view = false;
        height = LotteryWindowNewHeighYFKS;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_old_view"];
    } else if(curLotteryType == 28){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_BJL alloc]initWithNibName:@"LotteryBetViewController_BJL" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_BJL*)curLotteryBetVC).lotteryDelegate = self;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldBJL_view"];
        [YBToolClass sharedInstance].default_oldBJL_view = false;
        height = LotteryWindowNewHeighBJL;
    }else if(curLotteryType == 30){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZP alloc]initWithNibName:@"LotteryBetViewController_ZP" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZP*)curLotteryBetVC).lotteryDelegate = self;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZP_view"];
        [YBToolClass sharedInstance].default_oldZP_view = false;
        height = LotteryWindowNewHeighZP;
    }else if(curLotteryType == 29){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_ZJH alloc]initWithNibName:@"LotteryBetViewController_ZJH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_ZJH*)curLotteryBetVC).lotteryDelegate = self;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldZJH_view"];
        [YBToolClass sharedInstance].default_oldZJH_view = false;
        height = LotteryWindowNewHeighZJH;
    }else if(curLotteryType == 31){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LH alloc]initWithNibName:@"LotteryBetViewController_LH" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LH*)curLotteryBetVC).lotteryDelegate = self;
        [YBToolClass sharedInstance].default_oldLH_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLH_view"];
        height = LotteryWindowNewHeighLH;
    }else if(curLotteryType == 14){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SC alloc]initWithNibName:@"LotteryBetViewController_SC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SC*)curLotteryBetVC).lotteryDelegate = self;
        [YBToolClass sharedInstance].default_oldSC_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSC_view"];
        height = LotteryWindowNewHeighSC;
    }else if(curLotteryType == 11 || curLotteryType == 6){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_SSC alloc]initWithNibName:@"LotteryBetViewController_SSC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_SSC*)curLotteryBetVC).lotteryDelegate = self;
        [YBToolClass sharedInstance].default_oldSSC_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldSSC_view"];
        height = LotteryWindowNewHeighSSC;
    }else if(curLotteryType == 8){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_LHC alloc]initWithNibName:@"LotteryBetViewController_LHC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_LHC*)curLotteryBetVC).lotteryDelegate = self;
        [YBToolClass sharedInstance].default_oldLHC_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldLHC_view"];
        height = LotteryWindowNewHeighLHC;
    }else if(curLotteryType == 10){
        curLotteryBetVC = (LotteryBetViewController*)[[LotteryBetViewController_NNN alloc]initWithNibName:@"LotteryBetViewController_NNN" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        ((LotteryBetViewController_NNN*)curLotteryBetVC).lotteryDelegate = self;
        [YBToolClass sharedInstance].default_oldNN_view = false;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"default_oldNN_view"];
        height = LotteryWindowNewNNHeigh;
    }
    [YBToolClass sharedInstance].lotteryLiveWindowHeight = height+ShowDiff;
    [curLotteryBetVC setLotteryType:curLotteryType];
  
    if ([self.parentViewController isKindOfClass:[SwitchLotteryViewController class]]) {
        [self.parentViewController.view addSubview:curLotteryBetVC.view];
        [self.parentViewController addChildViewController:curLotteryBetVC];
    }else{
        [self.view addSubview:curLotteryBetVC.view];
        [self addChildViewController:curLotteryBetVC];
    }
    curLotteryBetVC.view.frame = CGRectMake(0, SCREEN_HEIGHT-height-ShowDiff, SCREEN_WIDTH, height+ShowDiff);
}

-(BOOL)cancelLuwu
{
    BOOL canceled = false;
    if (giftview!= nil && giftview.top<SCREEN_HEIGHT) {
        canceled = true;
    }
    if (giftview) {
        [self hidenToolbar];
        [self changeGiftViewFrameY:_window_height*10];
    }
    
    
    
    return canceled;
}

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
    [MobClick event:@"live_room_gift_click" attributes:@{@"eventType": @(1)}];
}

-(void)refreshTableHeight:(BOOL)isShowTopView{

    [self tableViewHieghtDeal];
}

#pragma gift delegate
- (void)contactViewSendDoLiwuMessage:(LiveContactView *)view{
    [self doLiwu];
}
//发送礼物
-(void)sendGift:(NSMutableArray *)myDic andPlayModel:(hotModel *)playModel andData:(NSArray *)datas andLianFa:(NSString *)lianfa{
    haohualiwu = lianfa;
    NSString *info = [[datas firstObject] valueForKey:@"gifttoken"];
    level = [[datas firstObject] valueForKey:@"level"];
    LiveUser *users = [Config myProfile];
    users.level = level;
    [Config updateProfile:users];
    if (socketDelegate) {
        [socketDelegate sendGift:level andINfo:info andlianfa:lianfa];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = false;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    isShowingMore = false;
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    [backScrollView setContentOffset:CGPointMake(_window_width,0) animated:true];
    self.unRead = 0;
    [self livePlayStart];
}

//手指拖拽弹窗移动
-(void)musicPan:(UIPanGestureRecognizer *)sender{
    CGPoint point = [sender translationInView:sender.view];
    CGPoint center = sender.view.center;
    center.x += point.x;
    center.y += point.y;
    userView.center = center;
    //清空
    [sender setTranslation:CGPointZero inView:sender.view];
}

-(void)shajincheng{
    
    
}
-(void)initArray{
    [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"isPlaying"];
    _canScrollToBottom  = true;
    _scrollToBottomCount = 5;
    _bDraggingScroll = false;
    _canScrollToBottomUser  = true;
    _scrollToBottomCountUser = 5;
    _bDraggingScrollUser = false;
    
    haohualiwuV.expensiveGiftCount = [NSMutableArray array];
    
    level = (NSString *)[Config getLevel];
    self.content = [NSString stringWithFormat:@" "];
    
    userCount = 0;
    starisok = 0;
    heartNum = @1;
    
    firstStar = 0;//点亮
    titleColor = @"0";
    isRotationGame = false;
    isZhajinhuaGame = false;

}


-(void)screenshots:(NSNotification *)notification {
    UIScreen *screen = notification.object;
    if (@available(iOS 11.0, *)) {
        NSLog(@"receive notification: Screen is captured: %@", screen.isCaptured ? @"YES" : @"NO");
        if(screen.isCaptured) {
          

            if (_nplayer) {
                [self onStopVideo:false];
            }
            backScrollView.hidden = true;
            UIAlertController  *alertlianmaiVC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:@"禁止录屏" preferredStyle:UIAlertControllerStyleAlert];
            //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
            WeakSelf
            UIAlertAction *defaultActionss = [UIAlertAction actionWithTitle:YZMsg(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                exit(0);
            }];
            [alertlianmaiVC addAction:defaultActionss];
            if (self.presentedViewController == nil) {
                [self presentViewController:alertlianmaiVC animated:1 completion:nil];
            }
        }else{

            
        }
    } else {
        
    }
    
}
-(void)screenshots2:(NSNotification *)notification {
    if (_nplayer) {
        [self onStopVideo:false];
    }
    self.tableViewMsg.hidden = true;
    self.tableViewUserMsg.hidden = true;
    UIAlertController  *alertlianmaiVC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"Live_ProhibitScreenRecording") preferredStyle:UIAlertControllerStyleAlert];
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    WeakSelf
    UIAlertAction *defaultActionss = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        exit(0);
    }];
    [alertlianmaiVC addAction:defaultActionss];
    if (self.presentedViewController == nil) {
        [self presentViewController:alertlianmaiVC animated:1 completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [IQKeyboardManager sharedManager].enable = false;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    if (lotteryTime == nil) {
//        [self changeRoom:self.playDocModel];
//        if(_nplayer){
//            [_nplayer start:_playDocModel.pull];
//        }
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = false;
    UIScreen * sc = [UIScreen mainScreen];
    if (@available(iOS 11.0, *)) {
        if (sc.isCaptured) {
            if (_nplayer) {
                [_nplayer stop];
            }
            return;
        }
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 11.0, *)) {
        // 检测到当前设备录屏状态发生变化
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenshots:) name:UIScreenCapturedDidChangeNotification object:nil];
    } else {
        // Fallback on earlier versions
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenshots2:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    //TODO1:判断是否付费
    //TODO2:没满7s退出时取消after
    
    
    [_horizontalMarquee start];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].enableAutoToolbar = true;
    
    [self livePlayStop];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].enableAutoToolbar = true;
    self.navigationController.interactivePopGestureRecognizer.enabled = true;
    [self stopWobble];
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenCapturedDidChangeNotification object:nil];
    } else {
        // Fallback on earlier versions
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [_horizontalMarquee pause];
    //将代理置空，防止计时再次出现
    [self hidenToolbar];
    [self doCancle];
}

- (void)livePlayStop {
    if (_nplayer!= nil) {
        [self releaseDatas];
        [self releaseObservers];
        if(self.alertShowForLive){
            [self.alertShowForLive removeFromSuperview];
            self.alertShowForLive = nil;
        }
    }
}

- (void)livePlayStart {
    if (isFirstLoad) {
        isFirstLoad = false;
        return;
    }
    if (_nplayer!= nil) {
        NSString *url = [minstr(self.playDocModel.pull) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [_nplayer start:url];
        [self changeRoom:self.playDocModel];
    }
}

- (void)loadView {
#if defined(DEBUG)
    self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
#else
    if (@available(iOS 13.0, *)) {
        self.view = [ScreenShieldView createWithFrame:UIScreen.mainScreen.bounds];
    } else {
        // Fallback on earlier versions
        self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
#endif
}
-(void)loadDatas{
    [self getNodeJSInfo];//初始化nodejs信息
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化消息处理队列
    _messageQueue = dispatch_queue_create("com.yourcompany.liveplay.messageQueue", DISPATCH_QUEUE_SERIAL);
    isFirstLoad = YES;
    isencryption = self.playDocModel.encryption;
    
    self.pendingDleayBlocks = [NSMutableArray array];
    @synchronized(self) {
        [self setView];//加载信息页面
    }
   
    if (@available(iOS 11.0, *)) {
        self.tableViewMsg.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableViewUserMsg.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        buttomscrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    buttomscrollview.shouldIgnoreScrollingAdjustment  = false;
    
   
}

-(void)getLotteryList{
    NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getLotteryList&uid=%@&token=%@&type=live",[Config getOwnID],[Config getOwnToken]];
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
-(void)timeShowChargeAction
{
    if(alertGiftShow==nil){
        alertGiftShow = [FirstInvestAlert instanceNotificationAlertWithMessages];
        [alertGiftShow alertShowAnimationWithSuperView:self.view];
    }
}

#pragma mark --显示隐藏table
-(void)showOrHidenMessageTableView:(NSNotification*)notifiObj
{
    NSNumber *obj = notifiObj.object;
    [self handleNotificationChangeTabView:obj.integerValue];
}

-(void)handleNotificationChangeTabView:(NSInteger)number{
    if (number == 0) {
        self.tableViewMsg.hidden = false;
        self.tableViewUserMsg.hidden = false;
        UIView *viewShadown = [backScrollView viewWithTag:1201202];
        if (viewShadown) {
            viewShadown.hidden = YES;
        }
        [setFrontV hiddenTopViewForChat:YES];
        self.horizontalMarquee.hidden = YES;
        keyBTN.hidden = YES;
        _returnCancle.hidden = YES;
        _liwuBTN.hidden = YES;
        _closeAdBTN.hidden = YES;
        sendBagBtn.hidden = YES;
        newMsgButton.hidden = YES;
        _gameBTN.hidden = YES;
        nuseraimation.hidden = YES;
        redBagBtn.hidden = YES;
        self.v_lottery.hidden = YES;
        _v_circle.hidden = YES;
        self.cycleScrollView.hidden = YES;
        self.v_thirdLink.hidden = YES;
        self.circleManualStackView.hidden = true;
        self.isLotteryBetView = YES;
        [self doMoveTableMsg];

        CGRect frontViewRect = [setFrontV getLeftViewFrame];
        [_remoteInterfaceView forceShrink:CGPointMake(0, CGRectGetMaxY(frontViewRect) + 10)];
    }else if(number == 2){
        self.tableViewMsg.hidden = false;
        self.tableViewUserMsg.hidden = false;
        [setFrontV hiddenTopViewForChat:false];
        self.horizontalMarquee.hidden = false;
        UIView *viewShadown = [backScrollView viewWithTag:1201202];
        if (viewShadown) {
            viewShadown.hidden = false;
        }
        keyBTN.hidden = false;
        _liwuBTN.hidden = false;
        _closeAdBTN.hidden = false;
        _returnCancle.hidden = false;
        _gameBTN.hidden = false;
        nuseraimation.hidden = false;
        sendBagBtn.hidden = false;
        redBagBtn.hidden = false;
        self.v_lottery.hidden = false;
        _v_circle.hidden = false;
        self.cycleScrollView.hidden = false;
        self.v_thirdLink.hidden = false;
        self.circleManualStackView.hidden = false;
        self.isLotteryBetView = false;
        [self doRecoverTableMsgSecond];
    }else{
        [setFrontV hiddenTopViewForChat:false];
        self.horizontalMarquee.hidden = false;
        UIView *viewShadown = [backScrollView viewWithTag:1201202];
        if (viewShadown) {
            viewShadown.hidden = false;
        }
        self.tableViewMsg.hidden = false;
        self.tableViewUserMsg.hidden = false;
        keyBTN.hidden = false;
        _liwuBTN.hidden = false;
        _closeAdBTN.hidden = false;
        _returnCancle.hidden = false;
        sendBagBtn.hidden = false;
        _gameBTN.hidden = false;
        nuseraimation.hidden = false;
        redBagBtn.hidden = false;
        self.v_lottery.hidden = false;
        _v_circle.hidden = false;
        self.cycleScrollView.hidden = false;
        self.v_thirdLink.hidden = false;
        self.circleManualStackView.hidden = false;
        self.isLotteryBetView = false;
        [self doRecoverTableMsg];
    }
    [self tableViewHieghtDeal];
}

static int timeCountLB = 0;
- (void)lotteryInterval{
    if(!lotteryInfo) return;
    
    // NSLog(@"%@ 时间0:%ld", roomLotteryInfo[@"lotteryType"], standTickCount);
    for (NSString * lotteryType in lotteryInfo.allKeys) {
        NSMutableDictionary *dict = lotteryInfo[lotteryType];
        //NSInteger time = [dict[@"time"] integerValue];
        
        NSDate * nowDate = [NSDate date];
        NSInteger timeDistance = [lotteryInfo[lotteryType][@"openTime"] timeIntervalSinceDate:nowDate];
        
        BOOL bCurLottery = lotteryType == minstr(roomLotteryInfo[@"lotteryType"]);
        if(timeDistance > [dict[@"sealingTim"] integerValue]){
            if(bCurLottery){
                standTickCount = 0;
         
                [self.v_lottery setTitle:[YBToolClass timeFormatted:timeDistance-[dict[@"sealingTim"] integerValue]] forState:UIControlStateNormal];
               
            }else{
                NSInteger openedLotteryType = labs([GameToolClass getCurOpenedLotteryType]);
                if([lotteryType integerValue] == openedLotteryType && openedLotteryType > 0 && (openedLotteryType != [minstr(roomLotteryInfo[@"lotteryType"]) integerValue])){
                    openedTickCount = 0;
                    
                }
            }
        }else{
            if(timeDistance > 0){
                //                self.leftTimeTitleLabel.text = @"本期截止:";
                //                self.leftTimeLabel.text = @"封盘中";//[self timeFormatted:openLeftTime];
                if(bCurLottery){
                    
                    [self.v_lottery setTitle:[NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LobbyLotteryVC_betEnd"), [dict[@"sealingTim"] integerValue] - ([dict[@"sealingTim"] integerValue] - timeDistance)] forState:UIControlStateNormal];
                }
            }else if([dict[@"stopOrSell"] integerValue] == 2){
                if(bCurLottery){
                 
                    [self.v_lottery setTitle:YZMsg(@"Livebroadcast_lotteryDisable") forState:UIControlStateNormal];
                }
            }else{
                if(bCurLottery){
                  
                    [self.v_lottery setTitle:YZMsg(@"LobbyLotteryVC_betOpen") forState:UIControlStateNormal];
                    if(standTickCount == 2 || (standTickCount > 0 && standTickCount % 6 == 0)){
                        // 一直没等来开奖消息 递增等待时间主动拉取
                        // NSLog(@"standTickCount=[%ld] 请求同步彩票2-1", standTickCount);
                        if (socketDelegate) {
                            [socketDelegate sendSyncLotteryCMD:lotteryType];
                        }
                        [self getLotteryBetInfo];
                        //[socketDelegate sendSyncOpenAwardCMD:lotteryType];
                    }
                    standTickCount ++;
                }else{
                    NSInteger openedLotteryType = labs([GameToolClass getCurOpenedLotteryType]);
                    if([lotteryType integerValue] == openedLotteryType && openedLotteryType > 0 && (openedLotteryType != [minstr(roomLotteryInfo[@"lotteryType"]) integerValue])){
                        if(openedTickCount == 2 || (openedTickCount > 0 && openedTickCount % 6 == 0)){
                            // 一直没等来开奖消息 递增等待时间主动拉取
                            // NSLog(@"standTickCount=[%ld] 请求同步彩票2-2", standTickCount);
                            if (socketDelegate) {
                                [socketDelegate sendSyncLotteryCMD:[NSString stringWithFormat:@"%ld", openedLotteryType]];
                                [socketDelegate sendSyncOpenAwardCMD:[NSString stringWithFormat:@"%ld", openedLotteryType]];
                            }
                            [self getLotteryBetInfo];
                        }
                        openedTickCount ++;
                    }
                }
            }
//            拉霸打开投注页面,开奖的时候刷新奖池
            if(self.isLotteryBetView  && [((LotteryBetViewController_LB*)curLotteryBetVC) respondsToSelector:@selector(getPoolDataInfo)]){
                [((LotteryBetViewController_LB*)curLotteryBetVC) getPoolDataInfo];
            }
        }
        dict[@"time"] = [NSString stringWithFormat:@"%ld", timeDistance];
        // NSLog(@"%@ 时间2:%@", lotteryType, dict[@"time"]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lotterySecondNotify" object:nil userInfo:@{
            @"betLeftTime":dict[@"time"],
            @"sealingTime":dict[@"sealingTim"],
            @"issue":dict[@"issue"],
            @"lotteryType":lotteryType,
        }];
    }
    
    if((roomLotteryInfo[@"lotteryType"] &&[[PublicObj checkNull:roomLotteryInfo[@"lotteryType"]]?@"0":roomLotteryInfo[@"lotteryType"] intValue] == 40) || curSwitchLotteryVC.gameTag == 40){
        self.v_lottery.hidden = false;
        [self.v_lottery setTitle:@"" forState:UIControlStateNormal];
//            拉霸打开投注页面,开奖的时候刷新奖池
        timeCountLB++;
        if (timeCountLB == 60) {
            if(curLotteryBetVC  && [((LotteryBetViewController_LB*)curLotteryBetVC) respondsToSelector:@selector(getPoolDataInfo)] ){
                [((LotteryBetViewController_LB*)curLotteryBetVC) getPoolDataInfo];
            }
            if(curSwitchLotteryVC){
                [curSwitchLotteryVC getPoolDataInfo];
            }
            timeCountLB =0;
        }
        return;
    }
    
}
//获取彩种信息
- (void)getLotteryBetInfo{
    NSString *userBaseUrl = [NSString stringWithFormat:@"Lottery.getBetViewInfo&uid=%@&token=%@&lottery_type=%@&live_id=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%@", roomLotteryInfo[@"lotteryType"]],minnum([GlobalDate getLiveUID])];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
      
        if(code == 0)
        {
            NSDictionary *dict = [info firstObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lotterySecondNotify" object:nil userInfo:@{
                @"betLeftTime":dict[@"time"],
                @"sealingTime":dict[@"sealingTim"],
                @"issue":dict[@"issue"],
                @"lotteryType":strongSelf->roomLotteryInfo[@"lotteryType"],
                @"isReset":@YES
            }
            ];
        }
        
    } fail:^(NSError * _Nonnull error) {
       
    }];
}
//显示进场标题
- (void)showTitle{
    if (minstr(self.playDocModel.title).length > 0 && [self.view viewWithTag:789] == nil) {
        CGFloat titleWidth = [[YBToolClass sharedInstance] widthOfString:minstr(self.playDocModel.title) andFont:[UIFont systemFontOfSize:14] andHeight:30];
        UIImageView *titleBackImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width, 110, 35+titleWidth+20, 30)];
        titleBackImgView.image = [ImageBundle imagewithBundleName:@"moviePlay_title"];
        titleBackImgView.alpha = 0.5;
        titleBackImgView.layer.cornerRadius = 15;
        titleBackImgView.layer.masksToBounds = true;
        titleBackImgView.tag = 789;
        [self.view addSubview:titleBackImgView];
        UIImageView *laba = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 15, 15)];
        laba.image = [ImageBundle imagewithBundleName:@"moviePlay_laba"];
        [titleBackImgView addSubview:laba];
        UILabel *titL = [[UILabel alloc]initWithFrame:CGRectMake(laba.right+10, 0, titleWidth+20, 30)];
        titL.text = minstr(self.playDocModel.title);
        titL.textColor = [UIColor whiteColor];
        titL.font = [UIFont systemFontOfSize:14];
        [titleBackImgView addSubview:titL];
        [UIView animateWithDuration:3 animations:^{
            titleBackImgView.alpha = 1;
            titleBackImgView.x = 10;
        }];
        WeakSelf
        dispatch_block_t delayBlock = dispatch_block_create(0, ^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            [UIView animateWithDuration:2 animations:^{
                titleBackImgView.alpha = 0;
                titleBackImgView.x = -_window_width;
            } completion:^(BOOL finished) {
                [titleBackImgView removeFromSuperview];
            }];
        });
        [self.pendingDleayBlocks addObject:delayBlock];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(),delayBlock);
    } else if (minstr(self.playDocModel.title).length > 0 && [self.view viewWithTag:789] != nil) {
        [[self.view viewWithTag:789] removeFromSuperview];
        [self showTitle];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (textField == keyField) {
        [self pushMessage:nil];
    }
    return true;
}

-(void)socketShutUp:(NSString *)name andID:(NSString *)ID{
    if (socketDelegate) {
        [socketDelegate shutUp:name andID:ID];
    }
}
-(void)socketkickuser:(NSString *)name andID:(NSString *)ID{
    if (socketDelegate) {
        [socketDelegate kickuser:name andID:ID];
    }
}
-(void)socketSendContactInfo:(NSString *)contactInfo andID:(NSString *)ID{
    if (socketDelegate) {
        [socketDelegate sendContactInfo:contactInfo andID:ID];
    }
}

-(void)GetInformessage:(NSDictionary *)subdic{
    if (userView) {
        [userView removeFromSuperview];
        userView = nil;
    }
    
    if (!userView) {
        //添加用户列表弹窗
        //        [MNFloatBtn hidden];
        userView = [[upmessageInfo alloc]initWithFrame:CGRectMake(_window_width*0.1,_window_height,upViewW,upViewW*4/3+20) andPlayer:@"movieplay"];
        userView.upmessageDelegate = self;
        userView.backgroundColor = [UIColor whiteColor];
        userView.layer.cornerRadius = 10;
        UIWindow *mainwindows = [UIApplication sharedApplication].keyWindow;
        [mainwindows addSubview:userView];
        
        //        [MNFloatBtn show];
    }
    //用户弹窗
    self.tanChuangID = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
    [userView getUpmessgeinfo:subdic andzhuboModel:self.playDocModel];
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->userView.frame = CGRectMake(_window_width*0.1,_window_height*0.2,upViewW,upViewW*4/3+20);
    }];
    
    [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@0];
    
    /*
     _danmuView->backscrollview 5
     gamevc->backscrollview 6
     userview->backscroll添加 7
     haohualiwuv->backscrollview 8
     liansongliwubottomview->backscrollview 8
     */
}
//几秒后隐藏消失
-(void)doAlpha{
    WeakSelf
    [UIView animateWithDuration:3.0 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->starImage.alpha = 0;
        
        dispatch_block_t delayBlock = dispatch_block_create(0, ^{
            if (strongSelf == nil) {
                return;
            }
            [strongSelf->starImage removeFromSuperview];
        });

        [strongSelf.pendingDleayBlocks addObject:delayBlock];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),delayBlock);
    }];
}
//点亮星星
-(void)starok{
    [self doCancle];
    //wangminxinliwu
    [self changecontinuegiftframe];
    [self toolbarHidden];
    [self hidenToolbar];
    [self showBTN];
    keyBTN.hidden = false;
    [self staredMove];
    //♥点亮
    if (firstStar == 0) {
        firstStar = 1;
        if (socketDelegate) {
            [socketDelegate starlight:level :heartNum andUsertype:usertype andGuardType:minstr([guardInfo valueForKey:@"type"])];
        }
        titleColor = @"0";
    }
    [self getweidulabel];
    [self zhezhaoBTNdelegate];
}
-(void)staredMove{
    
    CGFloat starX;
    CGFloat starY;
    starX = _returnCancle.frame.origin.x - 10;
    starY = _liwuBTN.frame.origin.y - 20;
    NSInteger random = arc4random()%5;
    starImage = [[UIImageView alloc]initWithFrame:CGRectMake(starX+random,starY-random,30,30)];
    
    starImage.alpha = 0;
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"plane_heart_cyan.png",@"plane_heart_pink.png",@"plane_heart_red.png",@"plane_heart_yellow.png",@"plane_heart_heart.png", nil];
    
    srand((unsigned)time(0));
    
    starImage.image = [ImageBundle imagewithBundleName:[array objectAtIndex:random]];
    
    heartNum = [NSNumber numberWithInteger:random];
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->starImage.alpha = 1.0;
        strongSelf->starImage.frame = CGRectMake(starX+random - 10, starY-random - 30, 30, 30);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(1.3, 1.3);
        strongSelf->starImage.transform = CGAffineTransformScale(transfrom, 1, 1);
    }];
    [backScrollView insertSubview:starImage atIndex:11];
    
    CGFloat finishX = _window_width*2 - round(arc4random() % 200);
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
    if (starisok == 0) {
        starisok = 1;
        dispatch_block_t delayBlock = dispatch_block_create(0, ^{
            // 你的延迟代码
            STRONGSELF
                        if (strongSelf == nil) {
                            return;
                        }
                        strongSelf->starisok = 0;
        });

        [self.pendingDleayBlocks addObject:delayBlock];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
        //    [socketDelegate starlight];
        
    }
}
/// 动画完后销毁iamgeView
- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UIImageView *imageViewsss = (__bridge UIImageView *)(context);
    [imageViewsss removeFromSuperview];
    imageViewsss = nil;
}
/*==================  以上是点亮  ================*/
-(void)setView{
    
    bigAvatarImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,_window_width, _window_height)];
    bigAvatarImageView1.contentMode = UIViewContentModeScaleAspectFill;
    if (![PublicObj checkNull:_playDocModel.zhuboImage]) {
         [bigAvatarImageView1 sd_setImageWithURL:[NSURL URLWithString:_playDocModel.zhuboImage] placeholderImage:[ImageBundle imagewithBundleName:@"image_placehold"]];
     }else{
         [bigAvatarImageView1 sd_setImageWithURL:[NSURL URLWithString:_playDocModel.avatar_thumb] placeholderImage:[ImageBundle imagewithBundleName:@"image_placehold"]];
     }
    
    [self.view insertSubview:bigAvatarImageView1 atIndex:0];
    
    backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height)];
    backScrollView.delegate = self;
    backScrollView.pagingEnabled = 1;
    backScrollView.scrollEnabled = true;
//    backScrollView.delaysContentTouches =YES;
    backScrollView.backgroundColor = [UIColor clearColor];
    backScrollView.showsHorizontalScrollIndicator = false;
    backScrollView.bounces = false;
    backScrollView.userInteractionEnabled = 1;
    [self.view addSubview:backScrollView];
    backScrollView.translatesAutoresizingMaskIntoConstraints = false;
    [backScrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = true;
    [backScrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = true;
    [backScrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = true;
    [backScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = true;
    backScrollViewContentSizeWidthConstraint = [backScrollView.contentLayoutGuide.widthAnchor constraintEqualToConstant:_window_width * 2];
    backScrollViewContentSizeWidthConstraint.active = true;
    
//    //加载背景模糊图
//    buttomimageviews = [[UIImageView alloc]init];
//    [buttomimageviews sd_setImageWithURL:[NSURL URLWithString:self.playDocModel.zhuboIcon]];
//    buttomimageviews.frame = CGRectMake(0,0, _window_width, _window_height);
//    buttomimageviews.userInteractionEnabled = 1;
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//    effectview.frame = CGRectMake(0, 0,_window_width,_window_height);
//    [buttomimageviews addSubview:effectview];
//    [backScrollView addSubview:buttomimageviews];
    
    setFrontV = [[setViewM alloc] initWithModel:self.playDocModel];
    setFrontV.frame = CGRectMake(_window_width,0,_window_width,_window_height);
    setFrontV.frontviewDelegate = self;
    setFrontV.clipsToBounds = 1;
    [backScrollView addSubview:setFrontV];
    
    
    self.tableViewMsg = [[UITableView alloc]initWithFrame:CGRectMake(_window_width + 2,setFrontV.frame.size.height - _window_height*0.20 - 40 - ShowDiff,tableWidth,_window_height*0.24) style:UITableViewStylePlain];
    [self tableviewheight:setFrontV.frame.size.height - _window_height*0.35 - 40 - ShowDiff];
    self.tableViewMsg.delegate = self;
    self.tableViewMsg.dataSource = self;
    self.tableViewMsg.backgroundColor = [UIColor clearColor];
    self.tableViewMsg.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewMsg.showsVerticalScrollIndicator = false;
    self.tableViewMsg.shouldIgnoreScrollingAdjustment  = 1;
    
    self.tableViewUserMsg = [[UITableView alloc]initWithFrame:CGRectMake(_window_width + 2,setFrontV.frame.size.height - _window_height*0.40 - 40 - ShowDiff,tableWidth,_window_height*0.11) style:UITableViewStylePlain];
    [self tableviewheight:setFrontV.frame.size.height - _window_height*0.35 - 40 - ShowDiff];
    self.tableViewUserMsg.delegate = self;
    self.tableViewUserMsg.dataSource = self;
    self.tableViewUserMsg.backgroundColor = [UIColor clearColor];
    self.tableViewUserMsg.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewUserMsg.showsVerticalScrollIndicator = false;
    self.tableViewUserMsg.shouldIgnoreScrollingAdjustment  = 1;
    
    newMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newMsgButton addTarget:self action:@selector(scrollToLastCell) forControlEvents:UIControlEventTouchUpInside];
    newMsgButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    [newMsgButton setTitleColor:RGB(95, 159, 210) forState:UIControlStateNormal];
    [newMsgButton setImage:[ImageBundle imagewithBundleName:@"arrowDown"] forState:UIControlStateNormal];
    newMsgButton.layer.cornerRadius = 10;
    newMsgButton.layer.masksToBounds = 1;
    newMsgButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    newMsgButton.titleLabel.minimumScaleFactor = 0.5;
    newMsgButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    [newMsgButton setTitle:YZMsg(@"Livebroadcast_haveNewMsgs") forState:UIControlStateNormal];
    newMsgButton.alpha = 0;
    newMsgButton.frame = CGRectMake(self.tableViewMsg.left,_tableViewBottom, 80, 20);
    
    
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [backScrollView insertSubview:self.tableViewMsg atIndex:4];
    [backScrollView insertSubview:self.tableViewUserMsg atIndex:4];
    [self.tableViewMsg.superview addSubview:newMsgButton];
    self.tableViewMsg.clipsToBounds = 1;
    self.tableViewUserMsg.clipsToBounds = 1;
    
    useraimation = [[userLoginAnimation alloc]init];
    useraimation.frame = CGRectMake(_window_width + 10,_tableViewTop - 40,_window_width,20);
    [backScrollView insertSubview:useraimation atIndex:5];
    
    nuseraimation = [[nuserLoginAnimation alloc]init];
    nuseraimation.frame = CGRectMake(_window_width + 10,_tableViewBottom + 10,_window_width,20);
    [backScrollView insertSubview:nuseraimation atIndex:5];
    
    _danmuView = [[GrounderSuperView alloc] initWithFrame:CGRectMake(_window_width, 100, self.view.frame.size.width, 140)];
    [backScrollView insertSubview:_danmuView atIndex:6];//添加弹幕
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(starok)];
    [_danmuView addGestureRecognizer:tap];
    
    
    UIView *msgView = [[UIView alloc]initWithFrame:CGRectMake(_window_width + 3,UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30,self.horizontalMarquee.width+10,30)];
    msgView.backgroundColor = RGB_COLOR(@"#000000", 0.2);
    msgView.alpha = 1;
    msgView.layer.cornerRadius = 15;
    msgView.layer.masksToBounds = 1;
    msgView.tag = 1201202;
    [backScrollView insertSubview:msgView atIndex:2];
    
    NSString * adText = [Config getADText];
    self.leftwardMarqueeViewData = @[minstr(adText)];
    [self.horizontalMarquee reloadData];
    [backScrollView insertSubview:self.horizontalMarquee atIndex:3];
    [backScrollView bringSubviewToFront:self.horizontalMarquee];
    //    adAnimation = [[centerADAnimation alloc]init];
    //    adAnimation.frame = CGRectMake(_window_width,UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30,_window_width,30);
    ////    adAnimation.hidden = YES;
    //    //普通房间
    //    [backScrollView insertSubview:adAnimation atIndex:3];
    
    cs = [[catSwitch alloc] initWithFrame:CGRectMake(6,11+44,44,22)];
    cs.delegate = self;
    //输入框
    keyField = [[UITextField alloc]initWithFrame:CGRectMake(70,7+44,_window_width-90 - 50, 30)];
    keyField.returnKeyType = UIReturnKeySend;
    keyField.delegate = self;
    keyField.textColor = [UIColor blackColor];
    keyField.borderStyle = UITextBorderStyleNone;
    keyField.placeholder = YZMsg(@"Livebroadcast_SayHi");
    keyField.backgroundColor = [UIColor whiteColor];
    keyField.layer.cornerRadius = 15.0;
    keyField.layer.masksToBounds = 1;
    UIView *fieldLeft = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 30)];
    fieldLeft.backgroundColor = [UIColor whiteColor];
    keyField.leftView = fieldLeft;
    keyField.leftViewMode = UITextFieldViewModeAlways;
    keyField.font = [UIFont systemFontOfSize:15];
#pragma mark -- 绑定键盘
    www = 30;
    //点击弹出键盘
    keyBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyBTN setBackgroundImage:[[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(120, www)] sd_imageByRoundCornerRadius:www/2] forState:UIControlStateNormal];
    [keyBTN setTitle:YZMsg(@"Livebroadcast_SaySomething") forState:UIControlStateNormal];
    [keyBTN.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [keyBTN addTarget:self action:@selector(showkeyboard:) forControlEvents:UIControlEventTouchUpInside];
    keyBTN.frame = CGRectMake(_window_width + 15,_window_height - 45 - ShowDiff, 120, www);
    
    //发送按钮
    pushBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [pushBTN setTitle:YZMsg(@"发送") forState:UIControlStateNormal];
    [pushBTN setImage:[ImageBundle imagewithBundleName:@"chat_send_gray"] forState:UIControlStateNormal];
    [pushBTN setImage:[ImageBundle imagewithBundleName:@"chat_send_yellow"] forState:UIControlStateSelected];
    pushBTN.imageView.contentMode = UIViewContentModeScaleAspectFit;
    pushBTN.layer.masksToBounds = 1;
    pushBTN.layer.cornerRadius = 5;
    //    [pushBTN setTitleColor:RGB(255, 204, 0) forState:0];
    pushBTN.selected = false;
    //    pushBTN.backgroundColor = normalColors;
    [pushBTN addTarget:self action:@selector(pushMessage:) forControlEvents:UIControlEventTouchUpInside];
    pushBTN.frame = CGRectMake(_window_width-55,7+44,50,30);
    
    //tool绑定键盘
    toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height+10, _window_width, 88)];
    toolBar.hidden = 1;
    toolBar.backgroundColor = [UIColor clearColor];
    UIView *tooBgv = [[UIView alloc]initWithFrame:CGRectMake(0, 44, _window_width, 44)];
    tooBgv.backgroundColor = [UIColor whiteColor];
    tooBgv.alpha = 0.7;
    [toolBar addSubview:tooBgv];
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toolbarClick:)];
    UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(cs.right+9, cs.top, 1, 20)];
    line1.backgroundColor = RGB(176, 176, 176);
    line1.alpha = 0.5;
    [toolBar addSubview:line1];
    UILabel *line2 = [[UILabel alloc]initWithFrame:CGRectMake(keyField.right+7, line1.top, 1, 20)];
    line2.backgroundColor = line1.backgroundColor;
    line2.alpha = line1.alpha;
    [toolBar addSubview:line2];
    //    [toolBar addGestureRecognizer:tapGesture];
    
    [toolBar addSubview:pushBTN];
    [toolBar addSubview:keyField];
    [toolBar addSubview:cs];
    
    UIButton *buttonMore = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonMore.frame = CGRectMake(SCREEN_WIDTH-60,7, 60, 30);
    buttonMore.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    buttonMore.layer.cornerRadius = 14;
    buttonMore.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonMore setImageEdgeInsets:UIEdgeInsetsMake(0, 42, 0, 0)];
    [buttonMore setTitleEdgeInsets:UIEdgeInsetsMake(0, -13, 0, 0)];
    [buttonMore setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buttonMore.layer.masksToBounds = YES;
    [buttonMore setTitle:YZMsg(@"LobbyLotteryVC_moreBtn") forState:UIControlStateNormal];
    [buttonMore setImage:[ImageBundle imagewithBundleName:@"down_arrow"] forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(showMoreMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [toolBar addSubview:buttonMore];
    
    [self.view addSubview:toolBar];

    starTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(starok)];
    starTap.delegate = (id<UIGestureRecognizerDelegate>)self;
    starTap.numberOfTapsRequired = 1;
    starTap.numberOfTouchesRequired = 1;
    [setFrontV addGestureRecognizer:starTap];
    
    liansongliwubottomview = [[UIView alloc]init];
    liansongliwubottomview.frame = CGRectMake(0, _tableViewTop-150,300,140);
    
    
    
    UITapGestureRecognizer *gifttaps = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(starok)];
    [liansongliwubottomview addGestureRecognizer:gifttaps];
    
    //添加底部按钮
    _returnCancle = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnCancle.tintColor = [UIColor whiteColor];
    [_returnCancle setImage:[ImageBundle imagewithBundleName:@"live_closed"] forState:UIControlStateNormal];//直播间观众—关闭
    _returnCancle.backgroundColor = [UIColor clearColor];
    [_returnCancle addTarget:self action:@selector(returnCancless) forControlEvents:UIControlEventTouchUpInside];
   
    
    //礼物
    _liwuBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    _liwuBTN.tintColor = [UIColor whiteColor];
    [_liwuBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"live_gifts"] forState:UIControlStateNormal];
    [_liwuBTN addTarget:self action:@selector(doLiwu) forControlEvents:UIControlEventTouchUpInside];
    // 游戏
    _gameBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    _gameBTN.tintColor = [UIColor whiteColor];
    [_gameBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"live_game"] forState:UIControlStateNormal];
    [_gameBTN addTarget:self action:@selector(doGame) forControlEvents:UIControlEventTouchUpInside];
    //关闭广告
    
    _closeAdBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeAdBTN.tintColor = [UIColor whiteColor];
    _closeAdBTN.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"isCloseAdv"];
    [_closeAdBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"cloaseAd_normal"] forState:UIControlStateNormal];
    [_closeAdBTN setBackgroundImage:[ImageBundle imagewithBundleName:@"closeAd_selected"] forState:UIControlStateSelected];
//    _closeAdBTN.hidden = true;
    [_closeAdBTN addTarget:self action:@selector(closeAdAction:) forControlEvents:UIControlEventTouchUpInside];

    self.lotteryShowArr = [NSMutableArray array];
    
    //红包按钮
    sendBagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBagBtn setImage:[ImageBundle imagewithBundleName:@"live_redpack"]forState:UIControlStateNormal];
    [sendBagBtn addTarget:self action:@selector(showRedView) forControlEvents:UIControlEventTouchUpInside];
    
    [self setbtnframe];
    
    [backScrollView insertSubview:keyBTN atIndex:5];
    [backScrollView insertSubview:_returnCancle atIndex:5];
    
    NSArray *shareplatforms = [common share_type];
    if (shareplatforms.count != 0) {
        [backScrollView insertSubview:_fenxiangBTN atIndex:5];
    }
    
    //[backScrollView insertSubview:_messageBTN atIndex:5];
    [backScrollView insertSubview:_liwuBTN atIndex:5];
    [backScrollView insertSubview:_gameBTN atIndex:5];
    [backScrollView insertSubview:_closeAdBTN atIndex:5];
    [backScrollView insertSubview:sendBagBtn atIndex:5];
    [setFrontV addSubview:liansongliwubottomview];
    [setFrontV bringSubviewToFront:liansongliwubottomview];
    
    [backScrollView setContentOffset:CGPointMake(_window_width,0) animated:false];

    [self createRightMenu];
    
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:videoView];
    [self.view sendSubviewToBack:videoView];
    [self.view insertSubview:bigAvatarImageView1 atIndex:0];
    
    videoView.frame = CGRectMake(0,0, _window_width, _window_height);
}

- (void)createRightMenu {
    self.circleManualStackView = [[UIStackView alloc] initWithFrame:CGRectMake(_window_width*2 - AD(70), 68+statusbarHeight, AD(70), 110)];
    self.circleManualStackView.spacing = 5;
    self.circleManualStackView.axis = UILayoutConstraintAxisVertical;
    self.circleManualStackView.alignment = UIStackViewAlignmentCenter;
    [backScrollView addSubview:self.circleManualStackView];
    self.circleManualStackView.translatesAutoresizingMaskIntoConstraints = false;
    [self.circleManualStackView.topAnchor constraintEqualToAnchor:backScrollView.topAnchor constant:68 + statusbarHeight].active = true;
    [self.circleManualStackView.rightAnchor constraintEqualToAnchor:backScrollView.rightAnchor constant:0].active = true;

    WeakSelf
    //获取名片
    self.v_getContact = [[LiveActivityButton alloc] initWithFrame:CGRectMake(0, 0, AD(70), AD(70))];
    [self.v_getContact.widthAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.v_getContact.heightAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.circleManualStackView addArrangedSubview:self.v_getContact];
    self.v_getContact.hidden = true;
    [self.v_getContact setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.v_getContact setTagString:@"live_contact"];

    [self.v_getContact setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
        STRONGSELF
        [strongSelf doCancle];
        [strongSelf hidenToolbar];
        if ([tag isEqualToString:@"fuckactivity"]) {
            OneBuyGirlViewController *oneBuyGirlVC = [[OneBuyGirlViewController alloc]initWithNibName:@"OneBuyGirlViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            [strongSelf.navigationController pushViewController:oneBuyGirlVC animated:YES];
        }else{
            [LiveContactView showContactWithAnimationAddto:strongSelf->backScrollView liver:strongSelf.playDocModel setDelegate:strongSelf];
        }
    }];

    //遙控玩具
    self.v_remoteToy = [[LiveActivityButton alloc] initWithFrame:CGRectMake(0, AD(70), AD(70), AD(70))];
    [self.v_remoteToy.widthAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.v_remoteToy.heightAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.circleManualStackView addArrangedSubview:self.v_remoteToy];
    self.v_remoteToy.hidden = true;
    [self.v_remoteToy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.v_remoteToy setTagString:@"live_toy"];

    [self.v_remoteToy setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hidenToolbar];
        [strongSelf doCancle];
        [strongSelf actionForLiveButton:sende.tagString linkSt:sende.linkString];
    }];

    //下達指令
    self.v_giveOrders = [[LiveActivityButton alloc] initWithFrame:CGRectMake(0, AD(70) * 2, AD(70), AD(70))];
    [self.v_giveOrders.widthAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.v_giveOrders.heightAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.circleManualStackView addArrangedSubview:self.v_giveOrders];
    self.v_giveOrders.hidden = true;
    [self.v_giveOrders setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.v_giveOrders setTagString:@"live_command"];

    [self.v_giveOrders setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hidenToolbar];
        [strongSelf doCancle];
        [strongSelf actionForLiveButton:sende.tagString linkSt:sende.linkString];
    }];

    //充值
    self.v_recharge = [[LiveActivityButton alloc] initWithFrame:CGRectMake(0, AD(70) * 3, AD(70), AD(70))];
    [self.v_recharge.widthAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.v_recharge.heightAnchor constraintEqualToConstant:AD(70)].active = true;
    [self.circleManualStackView addArrangedSubview:self.v_recharge];
    self.v_recharge.hidden = true;
    [self.v_recharge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.v_recharge setTagString:@"charge"];

    [self.v_recharge setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hidenToolbar];
        [strongSelf doCancle];
        [strongSelf actionForLiveButton:sende.tagString linkSt:sende.linkString];
    }];

    // 彩票
    self.v_lottery = [[LiveActivityButton alloc]initWithFrame:CGRectMake(_window_width * 2 - AD(70)
                                                                         , CGRectGetMinY(self.circleManualStackView.frame) + AD(70) * 4 + 5 * 4,
                                                                         AD(70),
                                                                         AD(70))];

    [self.v_lottery setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.v_lottery setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
        STRONGSELF
        [strongSelf hidenToolbar];
        [strongSelf doCancle];
        [strongSelf doLottery];
    }];
    [backScrollView addSubview:self.v_lottery];

    //外链
    self.v_thirdLink = [[LiveActivityButton alloc]initWithFrame:CGRectMake(_window_width * 2 - AD(70),
                                                                           self.v_lottery.bottom,
                                                                           AD(70),
                                                                           AD(70))];
    self.v_thirdLink.hidden = true;
    [self.v_thirdLink setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.v_thirdLink setTargetClick:^(NSString *tag,LiveActivityButton *sende) {
        //外链
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf hidenToolbar];
        [strongSelf doCancle];
        [strongSelf actionForLiveButton:sende.tagString linkSt:sende.linkString];
    }];
    [backScrollView addSubview:self.v_thirdLink];

    // 更多驚喜
    // 輪播
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(_window_width * 2 - (AD(70)),
                                                                                                self.v_thirdLink.top - AD(10) + AD(70),
                                                                                                AD(70),
                                                                                                AD(70))
                                                                            delegate:self
                                                                    placeholderImage:[ImageBundle imagewithBundleName:@"cardImgLdsponsor"]];
    cycleScrollView.layer.cornerRadius = 7;
    cycleScrollView.layer.masksToBounds = false;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    cycleScrollView.autoScrollTimeInterval = 3;
    cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    cycleScrollView.titleLabelTextFont = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    cycleScrollView.titleLabelTextAlignment = NSTextAlignmentCenter;
    cycleScrollView.titleLabelTextColor = [UIColor whiteColor];
    cycleScrollView.titleType = SDCycleScrollViewTitleTypeBottom;
    cycleScrollView.placeholderImage = nil;
    cycleScrollView.backgroundColor = UIColor.clearColor;
    cycleScrollView.showPageControl = false;
    _cycleScrollView = cycleScrollView;
    [backScrollView addSubview:self.cycleScrollView];
}

-(void)closeAdAction:(UIButton*)button
{
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
    
//    if(tool.isCloseAdv && messageList.count){
//        [messageList removeAllObjects];
//    }
}
-(void)actionForLiveButton:(NSString*)type linkSt:(NSString*)linkS
{
    if ([type isEqualToString:@"task"]) {
        TaskCenterMainVC *vc = [TaskCenterMainVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([type isEqualToString:@"luckdraw"]){
//        RotationVC *rotationVC = [[RotationVC alloc]initWithNibName:@"RotationVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//        rotationVC.liveUid = self.playDocModel.zhuboID;
//        rotationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//        [[MXBADelegate sharedAppDelegate].topViewController presentViewController:rotationVC animated:YES completion:nil];
        LuckyDrawViewController *vc = [LuckyDrawViewController new];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:navController animated:YES completion:nil];
    }else if ([type isEqualToString:@"custom_url"]){
        if (linkS == nil || linkS.length == 0) {
            return;
        }
        NSDictionary *data = @{@"scheme": linkS};
        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];

//        NavWeb *VC = [[NavWeb alloc]init];
//        VC.titles = @"";
//
//        VC.urls = linkS;
//        UINavModalWebView * navController = [[UINavModalWebView alloc] initWithRootViewController:VC];
//        if (@available(iOS 13.0, *)) {
//            navController.modalPresentationStyle = UIModalPresentationAutomatic;
//        } else {
//            navController.modalPresentationStyle = UIModalPresentationFullScreen;
//        }
//        VC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YZMsg(@"public_back") style:UIBarButtonItemStylePlain target:self action:@selector(closeService:)];
//        VC.navigationItem.title = @"";
//
//        if ([[MXBADelegate sharedAppDelegate] topViewController].presentedViewController != nil)
//        {
//            [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:false completion:nil];
//        }
//        if ([[MXBADelegate sharedAppDelegate] topViewController].presentedViewController==nil) {
//            [[[MXBADelegate sharedAppDelegate] topViewController] presentViewController:navController animated:true completion:nil];
//        }
    }else if ([type isEqualToString:@"charge"]){
        [self pushCoinV];
    } else if ([type isEqualToString:@"live_toy"]) {
        [self getLiveToyInfo:LiveToyInfoRemoteControllerForToy];
    } else if ([type isEqualToString:@"live_command"]) {
        [self getLiveToyInfo:LiveToyInfoRemoteControllerForAnchorman];
    } else if ([type isEqualToString:@"fuckactivity"]){
        OneBuyGirlViewController *oneBuyGirlVC = [[OneBuyGirlViewController alloc]initWithNibName:@"OneBuyGirlViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        [self.navigationController pushViewController:oneBuyGirlVC animated:YES];
    } else {
        if (linkS == nil || linkS.length == 0) {
            return;
        }
        NSDictionary *data = @{@"scheme": linkS};
        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
    }
}
- (void)closeService:(id)sender{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}
-(void)taskJumpWithTaskID:(NSInteger)taskID
{
    switch (taskID) {
        case 1:
        case 4:
        case 7:
        case 8:
            [self pushCoinV];
            break;
        case 2:
        case 6:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 16:
        {
            GameHomeMainVC *VC = [[GameHomeMainVC alloc] init];
            [self.navigationController pushViewController:VC animated:YES];
        }
            
            break;
        case 3:
        case 5:
        case 15:
        {
            myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
            withdraw.titleStr = YZMsg(@"public_WithDraw");
            [self.navigationController pushViewController:withdraw animated:YES];
        }
            
            break;
            
        default:
            break;
    }
}
- (UUMarqueeView *)horizontalMarquee {
    if (!_horizontalMarquee) {
        _horizontalMarquee = [[UUMarqueeView alloc] initWithFrame:CGRectMake(_window_width + 4,UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30,_window_width - 88,30) direction:UUMarqueeViewDirectionLeftward];
        
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
    return 1;
}

- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
    // for leftwardMarqueeView
    itemView.backgroundColor = [UIColor clearColor];

    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, (CGRectGetHeight(itemView.bounds) - 16.0f) / 2.0f, 16.0f, 16.0f)];
    icon.tag = 1002;
    [itemView addSubview:icon];

    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + 16.0f + 5.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 5.0f - 16.0f - 5.0f - 5.0f, CGRectGetHeight(itemView.bounds))];
    content.font = [UIFont systemFontOfSize:13.0f];
    content.textColor = [UIColor whiteColor];
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
    content.font = [UIFont systemFontOfSize:13.0f];
    content.text = _leftwardMarqueeViewData[index];
    return (5.0f + 16.0f + 5.0f) + content.intrinsicContentSize.width;  // icon width + label width (it's perfect to cache them all)
}

- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    
    NSString * adUrl = [Config getADUrl];
    if(adUrl.length > 0){
        NSDictionary *data = @{@"scheme": adUrl, @"showType": @"0"};
        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
//        [self actionForLiveButton:@"custom_url" linkSt:adUrl];
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"公告"};
    [MobClick event:@"live_room_menue_click" attributes:dict];
}


-(void)setbtnframe{
    
    CGFloat  wwwwww = 30;
    CGFloat hhh = _window_height - wwwwww - 15 - ShowDiff;
    _returnCancle.frame = CGRectMake(_window_width*2-wwwwww-10,hhh,wwwwww,wwwwww);
    _fenxiangBTN.frame = CGRectMake(_window_width*2 - wwwwww*2-20,hhh,wwwwww,wwwwww);
    //_messageBTN.frame = CGRectMake(_window_width*2 - wwwwww*3-30,hhh, wwwwww, wwwwww);
    sendBagBtn.frame = CGRectMake(_window_width*2 - wwwwww*3-40,hhh, wwwwww,wwwwww);
    _liwuBTN.frame = CGRectMake(_window_width*2 - wwwwww*4-50,hhh, wwwwww,wwwwww);
    _closeAdBTN.frame = CGRectMake(_window_width*2 - wwwwww*5-50,hhh, wwwwww,wwwwww);
    self.v_lottery.frame = CGRectMake(_window_width * 2 - AD(70), _tableViewTop-30, AD(70), AD(70));

    NSArray *shareplatforms = [common share_type];
    
    if (shareplatforms.count == 0) {
        _fenxiangBTN.hidden = 1;
        //_messageBTN.frame = CGRectMake(_window_width*2 - wwwwww*2-20,hhh,wwwwww,wwwwww);
        sendBagBtn.frame = CGRectMake(_window_width*2 - wwwwww*2-20,hhh, wwwwww, wwwwww);
        _liwuBTN.frame = CGRectMake(_window_width*2 - wwwwww*3-30,hhh, wwwwww, wwwwww);
        _gameBTN.frame = CGRectMake(_window_width*2 - wwwwww*4-40,hhh,wwwwww,wwwwww);
        _closeAdBTN.frame = CGRectMake(_window_width*2 - wwwwww*5-50,hhh, wwwwww,wwwwww);
    }
    [self stopWobble];
    [self startWobble];
}
-(void)toolbarHidden
{
    
    toolBar.frame = CGRectMake(0, _window_height+10, _window_width, 88);
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.showMoreMessageView.top =_window_height+10;
//        strongSelf->chatsmall.view.frame = CGRectMake(0, _window_height*3, _window_width, _window_height*0.4);
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.showMoreMessageView.hidden = true;
        strongSelf->toolBar.hidden = 1;
    }];

}

-(void)toolbarClick:(id)sender
{
    [self hidenToolbar];
    [self toolbarHidden];
    //    toolBar.hidden = YES;
}
-(void)guanzhuZhuBo{
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->setFrontV.leftView.frame = CGRectMake(10, 25+statusbarHeight, 103, leftW);
        strongSelf->listcollectionviewx = _window_width+105;
        strongSelf->listView.frame = CGRectMake(strongSelf->listcollectionviewx, 20+statusbarHeight, _window_width-105,40);
        strongSelf->listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-105, 40);
    }];
    setFrontV.newattention.hidden = 1;
    if (socketDelegate) {
        [socketDelegate attentionLive];
        [self isAttentionLive:@"1"];
    }
}
- (void) addObservers {
    //播放器播放完成
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(handlePlayerNotify:)
//                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
//                                              object:nil];
    
}
#pragma mark - 连麦鉴权信息
-(void)reloadChongzhi:(NSString *)coin{
    if (giftview) {
        [giftview chongzhiV:coin];
    }
}
#pragma mark ---- 私信方法
//-(void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error{
//    //显示消息数量
////    [self labeiHid];
//}
//-(void)labeiHid{
//    self.unRead = [[JMSGConversation getAllUnreadCount] intValue];
//    self.unReadLabel.text = [NSString stringWithFormat:@"%d",self.unRead];
//    if ([self.unReadLabel.text isEqual:@"0"]) {
//        self.unReadLabel.hidden =1;
//    }
//    else
//    {
//        self.unReadLabel.hidden = false;
//    }
//}

-(void)getweidulabel{
   
}

- (void)hideSysTemView{
    [sysView.view removeFromSuperview];
    sysView = nil;
    sysView.view = nil;
    
}

-(void)doUpMessageGuanZhu{
    if ([userView.forceBtn.titleLabel.text isEqual:YZMsg(@"upmessageInfo_followed")]) {
        [userView.forceBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
        [userView.forceBtn setTitleColor:normalColors forState:UIControlStateNormal];
        setFrontV.leftView.frame = CGRectMake(10,25+statusbarHeight,145,leftW);
        listcollectionviewx = _window_width+150;
        setFrontV.newattention.hidden = false;
        listView.frame = CGRectMake(listcollectionviewx, 20+statusbarHeight, _window_width-150,40);
        listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-150, 40);
        [userView.forceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else{
        setFrontV.leftView.frame = CGRectMake(10,25+statusbarHeight,103,leftW);
        listcollectionviewx = _window_width+105;
        setFrontV.newattention.hidden = 1;
        listView.frame = CGRectMake(listcollectionviewx, 20+statusbarHeight, _window_width-105,40);
        listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-105, 40);
        //EMError *error = [[EMClient sharedClient].contactManager removeUserFromBlackList:self.tanChuangID];
        // NSLog(@"%@",error.errorDescription);
        [userView.forceBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
        [userView.forceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        if(self.tanChuangID == self.playDocModel.zhuboID)
        {
            if (socketDelegate) {
                [socketDelegate attentionLive];
            }
        }
        userView.forceBtn.enabled = false;
    }
}
-(void)pushZhuYe:(NSString *)IDS{
    [self doCancle];
    otherUserMsgVC  *person = [[otherUserMsgVC alloc]init];
    person.userID = IDS;
    [self.navigationController pushViewController:person animated:1];
}
-(void)doupCancle{
    [self doCancle];
}
#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (!keyField.isFirstResponder) {
        return;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@0];
    isShowingMore = false;
    self.showMoreMessageView.hidden = true;
    if (redBview) {
        return;
    }
    if ([md5AlertController.textFields.firstObject becomeFirstResponder]) {
        return;
    }
    [self doCancle];
    [self hideBTN];
    
    keyBTN.hidden = 1;
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    CGFloat heightw = keyboardRect.size.height;
    int newHeight = _window_height - height -44-44;
    toolBar.hidden = false;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        if(!strongSelf.isLotteryBetView){
            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 40-44 - heightw];
//        }else{
//            CGFloat h = UIApplication.sharedApplication.statusBarFrame.size.height + 10;
//            strongSelf.tableViewMsg.top = h;
//            strongSelf.tableViewUserMsg.top = strongSelf.tableViewMsg.bottom;
//        }
        strongSelf->toolBar.frame = CGRectMake(0,height-88,_window_width,88);
        strongSelf->listView.frame = CGRectMake(strongSelf->listcollectionviewx,-height,_window_width-130-44,40);
        strongSelf->listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-130, 40);
        strongSelf->setFrontV.frame = CGRectMake(_window_width,-newHeight,_window_width,_window_height);
        strongSelf.horizontalMarquee.hidden = true;
        UIView *viewShadown = [strongSelf->backScrollView viewWithTag:1201202];
        if (viewShadown) {
            viewShadown.hidden = true;
        }
        
        [strongSelf changeGiftViewFrameY:_window_height*10];
        //wangminxinliwu
        [strongSelf changecontinuegiftframe];
       
    }];
}
-(void)showMoreMessage{
    if (!isShowingMore) {
        isShowingMore = YES;
        [self.view endEditing:YES];
        [self createMoreMsgs];
        self.showMoreMessageView.hidden = false;
        self.showMoreMessageView.frame = CGRectMake(0, toolBar.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-toolBar.bottom);
        UIScrollView *scrollViewContent = [self.showMoreMessageView viewWithTag:10002];
        scrollViewContent.frame = self.showMoreMessageView.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:self.showMoreMessageView];
    }else{
        [self hidenToolbar];
    }
    
}

-(void)updatePlanceHolder{
    int levelLimits = [[Config getChatLevel] intValue];
    int currentLevel = [[Config getLevel] intValue];
    if (self.chat_total_free_times>0 && currentLevel < levelLimits) {
        if (self.chat_free_times>0) {
            keyField.placeholder = [NSString stringWithFormat:YZMsg(@"LivePlay_sayTimes%ld"),(long)self.chat_free_times];
        }else{
            keyField.placeholder = YZMsg(@"LivePlay_sayTimeOver");
        }
    }else{
        keyField.placeholder = YZMsg(@"Livebroadcast_SayHi");
    }
}

-(void)createMoreMsgs{
    if (socketDelegate == nil || self.view.window == nil||[UIApplication sharedApplication].keyWindow == nil) {
        return;
    }
    
    [self updatePlanceHolder];
    if (self.showMoreMessageView == nil) {
        self.showMoreMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, toolBar.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-toolBar.bottom)];
        self.showMoreMessageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.showMoreMessageView];
        UIScrollView *scrollViewContent = [[UIScrollView alloc]initWithFrame:self.showMoreMessageView.bounds];
        scrollViewContent.backgroundColor = [UIColor clearColor];
        scrollViewContent.tag = 10002;
        [self.showMoreMessageView addSubview:scrollViewContent];
        
        CGFloat tagsTotalWidth = 20;
        CGFloat tagsTotalHeigh = 0;
        CGFloat tagHeight = 0;
        NSMutableArray *subArrayShort = [NSMutableArray array];
        for (NSString *str in [common getQuickSay]) {
            if (str.length<=10) {
                [subArrayShort addObject:str];
            }
        }
        for (UIView *subV in  toolBar.subviews) {
            if(subV.tag >= 10000){
                [subV removeFromSuperview];
            }
        }
        NSMutableArray *allMsgArrays = [NSMutableArray arrayWithArray:[common getQuickSay]];
        if (subArrayShort.count>0) {
            int x1 = arc4random() % subArrayShort.count;
            NSString *str1 = subArrayShort[x1];
            [subArrayShort removeObject:str1];
            NSString *str2 =@"";
            NSString *str3 =@"";
            if (subArrayShort.count>0) {
                int x2 = arc4random() % subArrayShort.count;
                str2 = subArrayShort[x2];
                [subArrayShort removeObject:str2];
            }
           
            if (subArrayShort.count>0) {
                int x3 = arc4random() % subArrayShort.count;
                str3 = subArrayShort[x3];
                [subArrayShort removeObject:str3];
            }
            
            NSMutableArray *arrayShow = [NSMutableArray array];
            if (str1.length>0) {
                [arrayShow addObject:str1];
            }
            if (str2.length>0) {
                [arrayShow addObject:str2];
            }
            if (str3.length>0) {
                [arrayShow addObject:str3];
            }
            
            CGFloat tagsTotalWidth1 = 10;
            int dddd = 0;
            for (NSString *subSt in arrayShow) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(tagsTotalWidth1, 7, 0, 28)];
                label.font = [UIFont systemFontOfSize:14];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = RGB(240,240,240);
                label.text = subSt;
                label.tag = 10000+dddd;
                label.userInteractionEnabled = YES;
                label.textColor = [UIColor blackColor];
                [label sizeToFit];
                label.frame = CGRectMake(tagsTotalWidth1, 7, CGRectGetWidth(label.frame) + 10, 28);
                tagsTotalWidth1 += CGRectGetWidth(label.frame)+15;
                tagHeight = 28;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSendMsg:)];
                [label addGestureRecognizer:tapGesture];
                
                if (tagsTotalWidth1 > SCREEN_WIDTH-60) {
                    label.hidden = YES;
                }else{
                    [allMsgArrays removeObject:subSt];
                }
                [toolBar addSubview:label];
                label.layer.cornerRadius = 14;
                label.layer.masksToBounds = YES;
                dddd++;
            }
        }
        
        for (NSString *str in allMsgArrays) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(tagsTotalWidth, tagsTotalHeigh, 0, 28)];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = RGB(240,240,240);
            label.text = str;
            label.userInteractionEnabled = YES;
            label.textColor = [UIColor blackColor];
            [label sizeToFit];
            label.frame = CGRectMake(tagsTotalWidth, tagsTotalHeigh, CGRectGetWidth(label.frame) + 10, 28);
            tagsTotalWidth += CGRectGetWidth(label.frame)+15;
            tagHeight = 28;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSendMsg:)];
            [label addGestureRecognizer:tapGesture];
            if (tagsTotalWidth > SCREEN_WIDTH) {
                int heightNew = 28;
                int widthNew = CGRectGetWidth(label.frame) + 10;
                BOOL addmore = false;
                if (widthNew>SCREEN_WIDTH-10) {
                    addmore = true;
                    widthNew = SCREEN_WIDTH-20;
                    heightNew = heightNew*2;
                }
                tagsTotalHeigh += 28 + 10;
                tagsTotalWidth = 10;
                if (addmore) {
                    UIView *subV  = [[UIView alloc]initWithFrame:CGRectMake(tagsTotalWidth, tagsTotalHeigh, widthNew-5, heightNew)];
                    [scrollViewContent addSubview:subV];
                    subV.backgroundColor = RGB(240,240,240);
                    subV.layer.cornerRadius = 14;
                    subV.layer.masksToBounds = YES;
                    label.frame = CGRectMake(tagsTotalWidth+10, tagsTotalHeigh, widthNew-5 , heightNew);
                }else{
                    label.frame = CGRectMake(tagsTotalWidth, tagsTotalHeigh, widthNew , heightNew);
                }
                
                tagsTotalWidth += CGRectGetWidth(label.frame)+15;
                if (addmore) {
                    tagsTotalHeigh = tagsTotalHeigh+28;
                    label.textAlignment = NSTextAlignmentLeft;
                    label.numberOfLines = 2;
                    
                }
            }
            [scrollViewContent addSubview:label];
            label.layer.cornerRadius = 14;
            label.layer.masksToBounds = YES;
        }
        tagsTotalHeigh += tagHeight+20;
        [scrollViewContent setContentSize:CGSizeMake(SCREEN_WIDTH, tagsTotalHeigh)];
        self.showMoreMessageView.hidden = YES;
    }
}
-(void)tapSendMsg:(UIGestureRecognizer*)tapG
{
    UILabel *tapView = (UILabel*)tapG.view;
    self.content = tapView.text;
    if (socketDelegate) {
        if (self.chat_total_free_times>0) {
            self.chat_free_times--;
            [self updatePlanceHolder];
        }
        int levelLimits = [[Config getChatLevel] intValue];
        int currentLevel = [[Config getLevel] intValue];
        if(currentLevel < levelLimits && self.chat_free_times <= 0){
            isShowingMore = false;
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            UIAlertController  *alertlianmaiVC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:[NSString stringWithFormat:YZMsg(@"LivePlay_SayRule%d"),levelLimits] preferredStyle:UIAlertControllerStyleAlert];
            //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
            WeakSelf
            UIAlertAction *defaultActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_GoCharge") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf pushCoinV];
            }];
            UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_GoSendGifts") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf doLiwu];
            }];
            [alertlianmaiVC addAction:defaultActionss];
            [alertlianmaiVC addAction:cancelActionss];
            if (self.presentedViewController == nil) {
                [self presentViewController:alertlianmaiVC animated:1 completion:nil];
            }
            return;
        }
        if (self.quikSayNum<2) {
            [socketDelegate sendmessage:self.content andLevel:level andUsertype:usertype andGuardType:minstr([guardInfo valueForKey:@"type"])];
            self.quikSayNum++;
            if (self.quikSayNum >=2) {
                WeakSelf
                dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                    // 你的延迟代码
                    STRONGSELF
                                        if (strongSelf == nil|| strongSelf->lotteryTime == nil) {
                                            return;
                                        }
                                        strongSelf.quikSayNum = 0;
                });

                [self.pendingDleayBlocks addObject:delayBlock];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
            }
        }else{
            [MBProgressHUD showError:YZMsg(@"LivePlay_SaidMoreQuikly")];
        }
       
    }
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@1];
    [self hidenKeyboard];
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
            strongSelf.horizontalMarquee.hidden = false;
            UIView *viewShadown = [strongSelf->backScrollView viewWithTag:1201202];
            if (viewShadown) {
                viewShadown.hidden = false;
            }
            
        }
       
        
        if (strongSelf->giftViewShow&&!strongSelf.isLotteryBetView) {
            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35- 265];
        }
        if (!strongSelf.isLotteryBetView) {
            [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff];
        }else{
            [strongSelf doMoveTableMsg];

        }
        
        //wangminxinliwu
        [strongSelf changecontinuegiftframe];
        strongSelf->toolBar.frame = CGRectMake(0,_window_height + 10,_window_width,88);
        [strongSelf changeGiftViewFrameY:_window_height*3];
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
-(void)hideBTN{
    _returnCancle.hidden = 1;
    _liwuBTN.hidden = 1;
    _closeAdBTN.hidden =1;
    _fenxiangBTN.hidden = 1;
    _messageBTN.hidden = 1;
    keyBTN.hidden = 1;
    redBagBtn.hidden = 1;
}
//按钮出现
-(void)showBTN{
    _returnCancle.hidden = false;
    _liwuBTN.hidden = false;
    _closeAdBTN.hidden = false;
    _fenxiangBTN.hidden = false;
    _messageBTN.hidden = false;
    keyBTN.hidden = false;
    redBagBtn.hidden = false;
}
//列表信息退出
-(void)doCancle{
    
    userView.forceBtn.enabled = 1;
    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->userView.frame = CGRectMake( _window_width*0.1,_window_height*2, upViewW,upViewW);
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->userView != nil) {
            [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@1];
        }
        [strongSelf->userView removeFromSuperview];
        strongSelf->userView = nil;
    }];
    self.tableViewMsg.userInteractionEnabled = 1;
    self.tableViewUserMsg.userInteractionEnabled = 1;
}
//发送消息
-(void)sendBarrage
{
    if (socketDelegate) {
        WeakSelf
        [socketDelegate sendBarrageID:self.playDocModel.zhuboID andTEst:keyField.text andModel:self.playDocModel success:^(int code, NSArray *info, NSString *msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            
            if(code == 0)
            {
                strongSelf->level = [[info firstObject] valueForKey:@"level"];
                if (strongSelf->socketDelegate) {
                    [strongSelf->socketDelegate sendBarrage:strongSelf->level andmessage:[[info firstObject] valueForKey:@"barragetoken"]];
                }
                //刷新本地魅力值
                LiveUser *liveUser = [Config myProfile];
                strongSelf->keyField.text = @"";
                liveUser.coin = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"coin"]];
                liveUser.level = strongSelf->level;
                [Config updateProfile:liveUser];
                if (strongSelf->giftview) {
                    NSString *coinst = [NSString stringWithFormat:@"%.2f", [liveUser.coin floatValue] / 10];
                    [strongSelf->giftview chongzhiV:coinst];
                }
            }
            else
            {
                [MBProgressHUD showError:msg];
                strongSelf->giftview.continuBTN.hidden = 1;
            }
        } fail:^(NSError *error) {
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }
}
-(void)pushMessage:(UITextField *)sender{
    if (keyField.text.length >50) {
        [MBProgressHUD showError:YZMsg(@"Livebroadcast_Input_word_limit50")];
        return;
    }
    int levelLimits = [[Config getChatLevel] intValue];
    int currentLevel = [[Config getLevel] intValue];
    if(currentLevel < levelLimits && self.chat_free_times <= 0){
        isShowingMore = false;
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        UIAlertController  *alertlianmaiVC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:[NSString stringWithFormat:YZMsg(@"LivePlay_SayRule%d"),levelLimits] preferredStyle:UIAlertControllerStyleAlert];
        //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
        WeakSelf
        UIAlertAction *defaultActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_GoCharge") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf pushCoinV];
        }];
        UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_GoSendGifts") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf doLiwu];
        }];
        [alertlianmaiVC addAction:defaultActionss];
        [alertlianmaiVC addAction:cancelActionss];
        if (self.presentedViewController == nil) {
            [self presentViewController:alertlianmaiVC animated:1 completion:nil];
        }
        return;
    }
    pushBTN.enabled = false;
    WeakSelf
    dispatch_block_t delayBlock = dispatch_block_create(0, ^{
        // 你的延迟代码
        STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf->pushBTN.enabled = 1;
    });

    [self.pendingDleayBlocks addObject:delayBlock];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),delayBlock);
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimedString = [keyField.text stringByTrimmingCharactersInSet:set];
    if ([trimedString length] == 0) {
        return ;
    }

    [keyField resignFirstResponder];

    if(cs.state == 1)//发送
    {
        if (keyField.text.length <=0) {
            return;
        }
        [self sendBarrage];
        keyField.text =nil;
        pushBTN.selected = false;
        return;
    }
    else{
        titleColor = @"0";
        self.content = keyField.text;
        if (socketDelegate) {
            if (self.chat_total_free_times>0) {
                self.chat_free_times--;
                [self updatePlanceHolder];
            }
            [socketDelegate sendmessage:self.content andLevel:level andUsertype:usertype andGuardType:minstr([guardInfo valueForKey:@"type"])];
        }
        keyField.text =nil;
        pushBTN.selected = false;
        [self scrollToLastCell];
    }
}
//聊天输入框
-(void)showkeyboard:(UIButton *)sender{
//    if (chatsmall) {
//        chatsmall.view.hidden = 1;
//        [chatsmall.view removeFromSuperview];
//        chatsmall.view = nil;
//        chatsmall = nil;
//    }
    [keyField becomeFirstResponder];
    [keyField canBecomeFirstResponder];
    
    //    [keyField reloadInputViews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @synchronized (messageList) {
        if (tableView == self.tableViewUserMsg) {
            return msgList.count;
        }else{
            return messageList.count;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableViewMsg deselectRowAtIndexPath:indexPath animated:1];
    chatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCELL"];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"chatMsgCell"] loadNibNamed:@"chatMsgCell" owner:nil options:nil] lastObject];
    }
    
    @synchronized (messageList) {
        if (tableView == self.tableViewUserMsg) {
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
            [strongSelf->socketDelegate sendTranslateMsg:chatModel.contentChat];
        }else if (IsUser.length>1){
            // 普通消息
            NSDictionary *subdic = @{@"id":chatModel.userID};
            [strongSelf GetInformessage:subdic];
        }
    };
    return cell;
}

// 点击聊天信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    chatModel *model = [[chatModel alloc] init];
    if (tableView == self.tableViewUserMsg) {
        model = msgList[indexPath.row];
    }else{
        model = messageList[indexPath.row];
    }
    isShowingMore = false;
    [self hidenToolbar];
    
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
        if (dict == nil) {
            if (socketDelegate) {
                [socketDelegate sendSyncLotteryCMD:lotteryType];
                WeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    [strongSelf tableView:tableView didSelectRowAtIndexPath:indexPath];
                });
            }
            
        }
        if(lotteryType && dict){
            // model.lotteryInfo[@"lotteryType"]
            
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
    }else if([minstr(model.titleColor) isEqualToString:@"lotteryDividend"]){
        [self doCancle];
        // 如果是彩票分红
        if (IsUser.length > 1) {
            NSDictionary *subdic = @{@"id":model.userID,
                                     @"name":model.userName
            };
            [self GetInformessage:subdic];
        }
    }else if(model.gamePlat.length > 0 && model.gameKindID.length > 0 && ([minstr(model.titleColor) isEqualToString:@"kygame"]||[minstr(model.titleColor) isEqualToString:@"platgame"])){
        // 如果是开元或平台游戏
        [self doCancle];
        // 进游戏
        [GameToolClass enterGame:model.gamePlat menueName:@"" kindID:model.gameKindID iconUrlName:@"" parentViewController: self autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            
        } fail:^{
            
        }];
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"game_name": model.gamePlat};
        [MobClick event:@"live_room_follow_game_click" attributes:dict];
    }else if (IsUser.length > 1) {
        // 普通消息
        NSDictionary *subdic = @{@"id":model.userID};
        [self GetInformessage:subdic];
    }else{
        [self doCancle];
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"chat_string": model.contentChat};
        [MobClick event:@"live_room_short_string_click" attributes:dict];
    }
    [self toolbarHidden];
    //    toolBar.hidden = YES;
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    CGFloat h = UIApplication.sharedApplication.statusBarFrame.size.height + 45;
 
    CGFloat tableH = _window_height - h -   [YBToolClass sharedInstance].lotteryLiveWindowHeight;
    h = UIApplication.sharedApplication.statusBarFrame.size.height + (keyField.isFirstResponder?10.0:45.0);

    if (scrollView == self.tableViewUserMsg) {
        _bDraggingScrollUser = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
        if (self.isLotteryBetView) {
            self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h ,_window_width/2 -10,tableH);
        }else{
            if (keyField.isFirstResponder) {
                self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h,tableWidth,_window_height*0.35);
            }else{
                self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.35);
            }
        }
        self.tableViewMsg.hidden = YES;
    }else if(scrollView == self.tableViewMsg){
        _bDraggingScroll = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
        if (self.isLotteryBetView) {
            self.tableViewMsg.frame = CGRectMake(_window_width + 5,h ,_window_width/2 -10,tableH);
        }else{
            if (keyField.isFirstResponder) {
                self.tableViewMsg.frame = CGRectMake(_window_width + 5,h,tableWidth,_window_height*0.35);
            }else{
                self.tableViewMsg.frame = CGRectMake(_window_width + 5,setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40,tableWidth,_window_height*0.35);
            }
        }
        self.tableViewUserMsg.hidden = YES;
    }
    //_canScrollToBottom = NO;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //_canScrollToBottom = YES;
    if (scrollView == self.tableViewUserMsg) {
        _bDraggingScrollUser = false;
    //    滑动结束3秒后显示分屏视图
//        [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:5];
    }else if(scrollView == self.tableViewMsg){
        _bDraggingScroll = false;
    //    滑动结束3秒后显示分屏视图
//        [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:5];
    }
//    else{
//        _bDraggingScroll = false;
//    }

}

//显示分屏视图
-(void)showFenpingView{
    
    self.tableViewUserMsg.hidden = false;
    if (_bDraggingScrollUser) {
        return;
    }
    self.tableViewMsg.hidden = false;
    [self tableViewHieghtDeal];
    [self scrollToLastUserCell];
    [self scrollToLastCell];
    
}

//聊天table高度处理
-(void)tableViewHieghtDeal{
        CGFloat  userTableH = 0;
        for (int i = 0; i< msgList.count; i++) {
            chatModel * model = msgList[i];
            if(self.isLotteryBetView){
                [YBToolClass sharedInstance].liveTableWidth = _window_width/2 -10;
            }else{
                [YBToolClass sharedInstance].liveTableWidth = tableWidth;
            }
           
            [model setChatFrame];
            userTableH = userTableH + model.rowHH + 10;
        }
        if (self.isLotteryBetView) {
            CGFloat h = UIApplication.sharedApplication.statusBarFrame.size.height + 45.0;
            CGFloat tableH = _window_height - h -   [YBToolClass sharedInstance].lotteryLiveWindowHeight ;
            h = UIApplication.sharedApplication.statusBarFrame.size.height + (keyField.isFirstResponder?10.0:45.0);
            if(userTableH > 0.6 * tableH || msgList.count>=3){
                self.tableViewMsg.frame = CGRectMake(_window_width + 5,h ,_window_width/2 -10,0.4 * tableH);
                self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h + 0.4 * tableH,_window_width/2 -10,0.6 * tableH);
                
            }else{
                self.tableViewMsg.frame = CGRectMake(_window_width + 5,h ,_window_width/2 -10,tableH - userTableH);
                self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,h + tableH - userTableH+5,_window_width/2 -10,userTableH);
            }
            [self scrollToLastCell];
        }else{
            if(userTableH > _window_height*0.11 || msgList.count>=3){
                self.tableViewMsg.frame = CGRectMake(_window_width + 5,keyField.isFirstResponder?self.tableViewMsg.top:(setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40),tableWidth,_window_height*0.24);
                self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,keyField.isFirstResponder?self.tableViewMsg.bottom:(setFrontV.frame.size.height - _window_height*0.11 - 50 - ShowDiff -40),tableWidth,_window_height*0.11);
            }else{
                self.tableViewMsg.frame = CGRectMake(_window_width + 5,keyField.isFirstResponder?self.tableViewMsg.top:(setFrontV.frame.size.height - _window_height*0.35 - 50 - ShowDiff -40  ),tableWidth,_window_height*0.35 - userTableH);
                self.tableViewUserMsg.frame = CGRectMake(_window_width + 5,keyField.isFirstResponder?self.tableViewMsg.bottom:(setFrontV.frame.size.height - userTableH - 50 - ShowDiff -40),tableWidth,userTableH);
            }
            [self scrollToLastCell];
        }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == backScrollView) {
        if (backScrollView.contentOffset.x == 0) {
            _danmuView.hidden = 1;
        }
        else{
            _danmuView.hidden = false;
        }
        isShowingMore = false;
        [self hidenToolbar];
        [self toolbarHidden];
        //        toolBar.hidden = YES;
        //NSLog(@"%f, %f", toolBar.frame.origin.x, toolBar.frame.origin.y);
        [self showBTN];
        keyBTN.hidden = false;
    }
    if(scrollView == buttomscrollview){
        videoView.frame = CGRectMake(0, _window_height+10, _window_width, 44);
        //NSLog(@"%f, %f", videoView.frame.origin.x, videoView.frame.origin.y);
    }

    if(scrollView == self.tableViewMsg && _bDraggingScroll){
        if(scrollView.contentSize.height > scrollView.height){
            if(scrollView.contentOffset.y + scrollView.height + 5 < scrollView.contentSize.height){
                _canScrollToBottom = false;
                //NSLog(@"_canScrollToBottom NO");
            //    滑动结束3秒后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:3];
            }else{
                _canScrollToBottom = 1;
                //NSLog(@"_canScrollToBottom YES");
                [self hidenNewMessages:1];
            //    滑动到底3秒后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
            }
        }
        else{
            //    滑动结束5秒后显示分屏视图
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
        }
    }
    if(scrollView == self.tableViewUserMsg && _bDraggingScrollUser){
        if(scrollView.contentSize.height > scrollView.height){
            if(scrollView.contentOffset.y + scrollView.height + 5 < scrollView.contentSize.height){
                _canScrollToBottomUser = false;
                //NSLog(@"_canScrollToBottom NO");
            //    滑动结束5秒后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:3];
            }else{
                _canScrollToBottomUser = 1;
                //NSLog(@"_canScrollToBottom YES");
                [self hidenNewMessages:1];
            //    滑动到底3秒后显示分屏视图
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
            }
        }
        else{
            //    滑动结束5秒后显示分屏视图
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
                [self performSelector:@selector(showFenpingView) withObject:nil afterDelay:0.5];
        }
    }
}
/*************   以上socket.io 监听  *********/
//直播结束跳到此页面
-(void)lastView{
    NSDictionary *userInfo = @{@"roomId": _playDocModel.zhuboID};
    [[NSNotificationCenter defaultCenter] postNotificationName:LivePlayTableVCRemoveRoomIdNotifcation object:nil userInfo:userInfo];
    NSString *streamStr =_playDocModel.stream;
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isPlaying"];
    if (self.lotteryBarrageArrays) {
        [self.lotteryBarrageArrays removeAllObjects];
    }
    
    if (lotteryView) {
        [lotteryView removeFromSuperview];
    }
    
    [timecoast invalidate];
    timecoast = nil;
    [lotteryTime invalidate];
    lotteryTime = nil;
    [Feedeductionalertc dismissViewControllerAnimated:1 completion:nil];
    [self removetimer];
    
    [userView removeFromSuperview];
    userView = nil;
    [self releaseDatas];
   
    [haohualiwuV stopHaoHUaLiwu];
    [self onStopVideo:false];
    haohualiwuV.expensiveGiftCount = nil;
    [continueGifts stopTimerAndArray];
    continueGifts = nil;
    [haohualiwuV removeFromSuperview];

    [setFrontV removeFromSuperview];
    [listView removeFromSuperview];
    listView = nil;
    [self requestLiveAllTimeandVotes:streamStr];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
    //    lastv = [[lastview alloc]initWithFrame:self.view.bounds block:^(NSString *nulls) {
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //        [self.navigationController popViewControllerAnimated:YES];
    //    } andavatar:[NSString stringWithFormat:@"%@",[self.playDoc valueForKey:@"avatar"]]];
    //    [self.view addSubview:lastv];
}
#pragma mark ================ 直播结束 ===============
- (void)requestLiveAllTimeandVotes:(NSString *)stremString{
    NSString *url = [NSString stringWithFormat:@"Live.stopInfo&stream=%@",stremString];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:1 andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSDictionary *subdic = [info firstObject];
            [strongSelf lastview:subdic];
        }else{
            [strongSelf lastview:nil];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf lastview:nil];
    }];
    
}
-(void)lastview:(NSDictionary *)dic{
    //无数据都显示0
    if (!dic) {
        dic = @{@"votes":@"0",@"nums":@"0",@"length":@"0"};
    }
    UIImageView *lastView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    lastView.userInteractionEnabled = 1;
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
    backView.layer.masksToBounds = 1;
    [lastView addSubview:backView];
    
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width/2-50, labell.bottom, 100, 100)];
    [headerImgView sd_setImageWithURL:[NSURL URLWithString:minstr(_playDocModel.zhuboIcon)] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    headerImgView.layer.masksToBounds = 1;
    headerImgView.layer.cornerRadius = 50;
    [lastView addSubview:headerImgView];
    
    
    UILabel *nameL= [[UILabel alloc]initWithFrame:CGRectMake(0,50, backView.width, backView.height*0.55-50)];
    nameL.textColor = [UIColor whiteColor];
    nameL.text = minstr(_playDocModel.zhuboName);
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
    button.layer.masksToBounds  =1;
    [lastView addSubview:button];
    [self.view addSubview:lastView];
    
    //    if(curLotteryBetVC && curLotteryBetVC.view){
    //        [self.view bringSubviewToFront:curLotteryBetVC.view];
    //    }
    //    if(curSwitchLotteryVC && curSwitchLotteryVC.view){
    //        [self.view bringSubviewToFront:curSwitchLotteryVC.view];
    //    }
}
- (void)doExit{
    [self dissmissVC];
    [self dismissViewControllerAnimated:1 completion:nil];
    [self.navigationController popViewControllerAnimated:1];
}

//注销计时器
-(void)removetimer{
    
    [starMove invalidate];
    starMove = nil;
    [listTimer invalidate];
    listTimer = nil;
    [lianmaitimer invalidate];
    lianmaitimer = nil;
    [timecoast invalidate];
    timecoast = nil;
    [lotteryTime invalidate];
    lotteryTime = nil;
}

-(void)releaseAll
{
    // 1. 先移除所有观察者
    [self releaseObservers];
    
    // 2. 停止播放器
    if(_nplayer){

        [self.fromCell setupNPlayer:_nplayer];
        if (self.fromCell == nil) {
            [_nplayer stop];
            [_nplayer detachView];
            _nplayer = nil;
        }

    }
    
    // 3. 清理数据
    [self releaseDatas];
    
    [self removeVideoCover];
    
    self.tableViewUserMsg.delegate = nil;
    self.tableViewMsg.delegate = nil;
    if(msgList){
        [msgList removeAllObjects];
    }
    if(messageList){
        [messageList removeAllObjects];
    }
   
    // 4. 移除视图 - 在主线程执行
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf.view removeAllSubviews];
        strongSelf->setFrontV.bigAvatarImageView.hidden = false;
    });
}

- (void)cancelAllPendingBlocks {
    for (dispatch_block_t block in self.pendingDleayBlocks) {
        dispatch_block_cancel(block);
    }
    [self.pendingDleayBlocks removeAllObjects];
}

-(void)releaseDatas{

    [self cancelAllPendingBlocks];
   
    _type_val = 0;
    _livetype = 0;
    _isPreviewSecond = 0;
    _isChckedLive = false;
    
    [self handleNotificationChangeTabView:1];
    if (self.lotteryBarrageArrays) {
        [self.lotteryBarrageArrays removeAllObjects];
    }
    if (self.showMoreMessageView) {
        [self.showMoreMessageView removeFromSuperview];
        self.showMoreMessageView = nil;
    }
    if (alertGiftShow) {
        [alertGiftShow removeFromSuperview];
        alertGiftShow = nil;
    }
//    if(self.alertShowForLive){
//        [self.alertShowForLive removeFromSuperview];
//        self.alertShowForLive = nil;
//    }
//
    if (lotteryView) {
        [lotteryView removeFromSuperview];
    }
    if(curLotteryBetVC){
        if([curLotteryBetVC respondsToSelector:@selector(exitView)]){
            [curLotteryBetVC exitView];
        }
        [curLotteryBetVC removeFromParentViewController];
        [curLotteryBetVC.view removeFromSuperview];
        curLotteryBetVC = nil;
    }

    if (self.remoteController) {
        [self dismissRemoteController];
    }
    
    if(Feedeductionalertc!= nil){
        [Feedeductionalertc dismissViewControllerAnimated:1 completion:nil];
    }
   
    [self removetimer];
   

    [[UIApplication sharedApplication] setIdleTimerDisabled:1];
    haohualiwuV.expensiveGiftCount = nil;
    if (continueGifts) {
        [continueGifts stopTimerAndArray];
        continueGifts = nil;
    }
   
    [self onStopVideo:YES];
    [self releaseObservers];
   
    if (socketDelegate) {
        [socketDelegate socketStop];
        socketDelegate.socketDelegate = nil;
        socketDelegate = nil;
    }
    if (listTimer) {
        [listTimer invalidate];
        listTimer = nil;
    }
    
    

}

//直播结束时退出房间
-(void)dissmissVC {
   
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isPlaying"];
    
    // 1. 先隐藏和移除 UI
    [userView removeFromSuperview];
    userView = nil;
    self.tableViewMsg.hidden = 1;
    self.tableViewUserMsg.hidden = 1;
    [self releaseAll];
    [self dismissViewControllerAnimated:YES completion:^{
        
       
    }];
    [GlobalDate setLiveUID:0];
    [self.navigationController popViewControllerAnimated:YES];
}
//获取进入直播间所需要的所有信息全都在这个enterroom这个接口返回
-(void)getNodeJSInfo
{
    socketDelegate = [[socketMovieplay alloc]init];
    socketDelegate.socketDelegate = self;
    [GlobalDate setLiveUID:[_playDocModel.zhuboID integerValue]];
    WeakSelf
    [socketDelegate setnodejszhuboModel:self.playDocModel Handler:^(id arrays) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        NSDictionary *info = [arrays firstObject];
//        strongSelf->isencryption = [[info objectForKey:@"encryption"] boolValue];
        NSDictionary *ep = [info objectForKey:@"ep"];
        if ([ep isKindOfClass:[NSDictionary class]]) {
            BOOL enableEn = [minstr([ep objectForKey:@"enable"]) boolValue];
            if (enableEn) {
                strongSelf->isencryption = enableEn;
//                [LiveEncodeCommon sharedInstance].enableEn = enableEn;
            }
            BOOL flip = [[ep objectForKey:@"flip"] boolValue];
            BOOL bitwise_not = [[ep objectForKey:@"bitwise_not"] boolValue];
            int column = [[ep objectForKey:@"column"] intValue];
            int line = [[ep objectForKey:@"line"] intValue];
            [LiveEncodeCommon sharedInstance].flip = flip;
            [LiveEncodeCommon sharedInstance].bitwise_not = bitwise_not;
            [LiveEncodeCommon sharedInstance].column = column;
            [LiveEncodeCommon sharedInstance].line = line;
        }

        if ([info.allKeys containsObject:@"live_icon"]) {
            if (![info[@"live_icon"] isKindOfClass:[NSArray class]]) {
                return;
            }
            NSMutableArray *allIcon = [NSMutableArray arrayWithArray:info[@"live_icon"]];
//            NSMutableArray *tempIcons = [NSMutableArray array];
//            __block NSArray *tempKeys = @[@"fuckactivity", @"task", @"luckdraw"];
//            for (NSString *key in tempKeys) {
//                [allIcon enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
//                    if ([dict[@"type"] isEqualToString:key]) {
//                        [tempIcons addObject:dict];
//                    }
//                }];
//            }
//
//            [allIcon removeObjectsInArray:tempIcons];
//            [allIcon addObjectsFromArray:tempIcons];
//
//            if (tempIcons.count <= 1) {
//                self.moreSurpriseButton.hidden = true;
//                self.moreSurpriseTopButton.alpha = 1;
//            } else {
//                self.moreSurpriseButton.hidden = false;
//                self.moreSurpriseTopButton.alpha = 0;
//            }

            NSMutableArray *otherIcons = [NSMutableArray array];
            for (NSDictionary *icon in allIcon) {
                LiveActivityButton *tempButton;
                if ([icon[@"type"] isEqualToString:@"live_contact"]) { //获取名片
                    tempButton = strongSelf.v_getContact;
                } else if ([icon[@"type"] isEqualToString:@"live_toy"]) { //遙控玩具
                    tempButton = strongSelf.v_remoteToy;
                    [strongSelf.remoteInterfaceView showConnectView];
                } else if ([icon[@"type"] isEqualToString:@"live_command"]) { //下達指令
                    tempButton = strongSelf.v_giveOrders;
                    [strongSelf.remoteInterfaceView showConnectView];
                } else if ([icon[@"type"] isEqualToString:@"charge"]) { //充值
                    tempButton = strongSelf.v_recharge;
                } else if ([icon[@"type"] isEqualToString:@"custom_url"]) { //外链 custom_url
                    tempButton = strongSelf.v_thirdLink;
                } else {
                    [otherIcons addObject:icon];
                }
//                else if ([icon[@"type"] isEqualToString:@"fuckactivity"] || //一元空降 fuckactivity
//                           [icon[@"type"] isEqualToString:@"task"] || //任务大厅 task
//                           [icon[@"type"] isEqualToString:@"luckdraw"]) { //獎池派送 luckdraw
//                    if (self.moreSurpriseTopButton.tagString.length <= 0) {
//                        tempButton = strongSelf.moreSurpriseTopButton;
//                    } else if (self.moreSurpriseLeftButton.tagString.length <= 0) {
//                        tempButton = strongSelf.moreSurpriseLeftButton;
//                    } else if (self.moreSurpriseBottomButton.tagString.length <= 0) {
//                        tempButton = strongSelf.moreSurpriseBottomButton;
//                    }
//                }

                if (tempButton != nil) {
                    tempButton.hidden = false;
                    [tempButton setTagString:icon[@"type"]];
                    [tempButton setLinkString:icon[@"jump_url"]];
                    [tempButton setTitle:icon[@"name"] forState:UIControlStateNormal];
                    [tempButton setButtonImageWithUrl:icon[@"icon"] forState:UIControlStateNormal];
                }
            }
            
            self.otherIcons = otherIcons;
            NSArray *imageArray = [otherIcons valueForKeyPath:@"icon"];
            self.cycleScrollView.imageURLStringsGroup = imageArray;
            NSArray *nameArray = [otherIcons valueForKeyPath:@"name"];
            self.cycleScrollView.titlesGroup = nameArray;
            self.cycleScrollView.hidden = otherIcons.count == 0;
        }

        if ([info.allKeys containsObject:@"live_toy_info_list"]) {
            NSArray *models = info[@"live_toy_info_list"];
            if (![models isKindOfClass:[NSArray class]]) {
                return;
            }
            // 處理未完成的遙控與指令
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
            NSArray *sortedArray = [models sortedArrayUsingDescriptors:@[sortDescriptor]];

            for (int i = 0; i<sortedArray.count; i++) {
                NSDictionary *modelDic = sortedArray[i];
                if (![modelDic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSDictionary *receiveGiftInfo = modelDic[@"gift_info"];
                if (![receiveGiftInfo isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSTimeInterval expire_time = [modelDic[@"expire_time"] intValue];
                NSTimeInterval swftime = [receiveGiftInfo[@"shocktime"] floatValue];
                NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval remainingTime = expire_time - currentTimestamp;
                if (i == 0) {
                    if (remainingTime > swftime) {
                        remainingTime = swftime;
                    }
                    if (remainingTime <= 0) {
                        continue;
                    }
                } else {
                    remainingTime = swftime;
                }

                if (modelDic[@"gift_result"]) {
                    NSDictionary *giftResult = modelDic[@"gift_result"];
                    int type = [giftResult[@"type"] intValue];
                    OrderUserModel *model = [[OrderUserModel alloc] init];
                    if (type == 3) { // 跳蛋
                        model.type = LiveToyInfoRemoteControllerForToy;
                    } else if (type == 4) { //指令
                        model.type = LiveToyInfoRemoteControllerForAnchorman;
                    } else {
                        continue;
                    }

                    model.uid = minstr(modelDic[@"uid"]);
                    model.giftID = minstr(giftResult[@"giftid"]);
                    model.name = minstr(modelDic[@"user_nicename"]);
                    model.avatar = minstr(modelDic[@"avatar"]);
                    model.orderName = minstr(receiveGiftInfo[@"giftname"]);
                    model.second = [NSString stringWithFormat:@"%d", (int)remainingTime];
                    model.swiftType = minstr(giftResult[@"swftype"]);
                    [_remoteInterfaceView receiveOrderModel:model];
                }
            }
        }
    
        strongSelf.chat_free_times = [info[@"chat_free_times"] integerValue];
        strongSelf.chat_total_free_times = [info[@"chat_total_free_times"] integerValue];
        
        
        strongSelf->guardInfo = [info valueForKey:@"guard"];
        strongSelf->roomLotteryInfo = [info valueForKey:@"roomLotteryInfo"];
        [strongSelf.v_lottery setButtonImageWithUrl:minstr(strongSelf->roomLotteryInfo[@"logo"]) placeholderImage:[ImageBundle imagewithBundleName:@"game_center_small_placeholder"] forState:UIControlStateNormal];
        
        
        [common saveagorakitid:minstr([info valueForKey:@"agorakitid"])];//保存声网ID
        if ([minstr([info valueForKey:@"issuper"]) isEqual:@"1"]) {
            strongSelf->isSuperAdmin = 1;
        }else{
            strongSelf->isSuperAdmin = false;
        }
        strongSelf->usertype = minstr([info valueForKey:@"usertype"]);
        //保存靓号和vip信息
        NSDictionary *liang = [info valueForKey:@"liang"];
        NSString *liangnum = minstr([liang valueForKey:@"name"]);
        NSDictionary *vip = [info valueForKey:@"vip"];
        NSString *type = minstr([vip valueForKey:@"type"]);
        
        
        NSDictionary *subdic = [NSDictionary dictionaryWithObjects:@[type?type:@"",liangnum?liangnum:@""] forKeys:@[@"vip_type",@"liang"]];
        [Config saveVipandliang:subdic];
        NSArray *quickSay = [info valueForKey:@"quickSay"];
        if (quickSay && quickSay.count>0) {
            [common saveQuickSay:quickSay];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf createMoreMsgs];
        });
     
        strongSelf.danmuprice = [info valueForKey:@"barrage_fee"];
        strongSelf.listArray = [info valueForKey:@"userlists"];
        LiveUser *users = [Config myProfile];
        users.coin = [NSString stringWithFormat:@"%@",[info valueForKey:@"coin"]];
        [Config updateProfile:users];
        
        
        NSString *isattention = [NSString stringWithFormat:@"%@",[info valueForKey:@"isattention"]];
        strongSelf.countNum = [[info valueForKey:@"exit_tip_time"] intValue];
        //    进入直播间的时间
        strongSelf.starteDate = [NSDate date];
        strongSelf->userCount = [[info valueForKey:@"nums"] intValue];
        dispatch_main_async_safe((^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf->votesTatal = minstr([info valueForKey:@"votestotal"]);
            [strongSelf->setFrontV changeState:strongSelf->votesTatal];
            if (![minstr([info valueForKey:@"guard_nums"]) isEqual:@"0"]) {
                [strongSelf->setFrontV changeGuardButtonFrame:minstr([info valueForKey:@"guard_nums"])];
            }
            
            //           setFrontV.onlineLabel.text = [NSString stringWithFormat:@"%lld",userCount];
            //userlist_time 间隔时间
            //获取用户列表
            strongSelf->listView = [[ListCollection alloc]initWithListArray:[info valueForKey:@"userlists"] andID:strongSelf.playDocModel.zhuboID andStream:[NSString stringWithFormat:@"%@",strongSelf.playDocModel.stream]];
            strongSelf->listView.delegate = strongSelf;
            strongSelf->userlist_time = [[info valueForKey:@"userlist_time"] intValue];
            int timeDelayReload = MIN(MAX(10, strongSelf->userlist_time),60);
            if (!strongSelf->listTimer) {
                strongSelf->listTimer = [NSTimer scheduledTimerWithTimeInterval:timeDelayReload target:strongSelf selector:@selector(reloadUserList) userInfo:nil repeats:1];
            }
            [strongSelf->backScrollView addSubview:strongSelf->listView];
            if (strongSelf->_remoteInterfaceView) {
                [strongSelf->backScrollView insertSubview:strongSelf->listView belowSubview:_remoteInterfaceView];
            } else {
                [strongSelf->backScrollView addSubview:strongSelf->listView];
            }
            [strongSelf isAttentionLive:isattention];
        }));
        //游戏******************************************
        //获取庄家信息
        NSString *coin = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_coin"]];
        
        NSString *game_banker_limit = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_limit"]];
        NSString *uname = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_name"]];
        NSString *uhead = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_banker_avatar"]];
        NSString *uid = [NSString stringWithFormat:@"%@",[info valueForKey:@"game_bankerid"]];
        NSDictionary *zhuangdic = @{
            @"coin":coin,
            @"game_banker_limit":game_banker_limit,
            @"uname":uname,
            @"uhead":uhead,
            @"id":uid
        };
        [gameState savezhuanglimit:game_banker_limit];//缓存上庄钱数限制
        strongSelf->zhuangstartdic = zhuangdic;
        NSString *gametime = [NSString stringWithFormat:@"%@",[info valueForKey:@"gametime"]];
        NSString *gameaction = [NSString stringWithFormat:@"%@",[info valueForKey:@"gameaction"]];
        if (!gametime || [gametime isEqual:[NSNull null]] || [gametime isEqual:@"<null>"] || [gametime isEqual:@"null"] || [gametime isEqual:@"0"]) {
            //没有游戏
            
        }
        else{
            //有游戏 1炸金花  2海盗  3转盘  4牛牛  5二八贝
            if ([gameaction isEqual:@"1"] || [gameaction isEqual:@"4"] || [gameaction isEqual:@"2"]) {
                
                
                [strongSelf changeBtnFrame:_window_height - 260];
              
                [strongSelf->backScrollView insertSubview:strongSelf.liwuBTN atIndex:5];
                [strongSelf tableviewheight:_window_height - _window_height*0.35 - 260];
            }else if ([gameaction isEqual:@"5"]){
                [strongSelf changeBtnFrame:_window_height - 45 - 215];
                [strongSelf tableviewheight:strongSelf->setFrontV.frame.size.height - _window_height*0.35- 265];
            }
        }
        [strongSelf changecontinuegiftframe];
        
        //进入房间的时候checklive返回的收费金额
        if ([strongSelf.livetype isEqual:@"3"] || [strongSelf.livetype isEqual:@"2"]) {
            //此处用于计时收费
            //刷新所有人的影票
            [strongSelf addCoin:[strongSelf.type_val longLongValue]];
            if(strongSelf->socketDelegate){
                [strongSelf->socketDelegate addvotesenterroom:minstr(strongSelf.type_val)];
            }
            
        }
        if (![minstr([info valueForKey:@"linkmic_uid"]) isEqual:@"0"]) {
            [strongSelf playLinkUserUrl:minstr([info valueForKey:@"linkmic_pull"]) andUid:minstr([info valueForKey:@"linkmic_uid"])];
        }
        
        if ([minstr([info valueForKey:@"isred"]) isEqual:@"1"]) {
            if (!strongSelf->redBagBtn) {
                //PK按钮
                strongSelf->redBagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [strongSelf->redBagBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"redpack-right"] forState:UIControlStateNormal];
                [strongSelf->redBagBtn addTarget:strongSelf action:@selector(redBagBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [strongSelf resetRedBagBtnFrame];
                [strongSelf->backScrollView insertSubview:strongSelf->redBagBtn aboveSubview:strongSelf.horizontalMarquee];
            }
        }
        NSDictionary *pkinfo = [info valueForKey:@"pkinfo"];
        if (![minstr([pkinfo valueForKey:@"pkuid"]) isEqual:@"0"]) {
            //            [strongSelf anchor_agreeLink:pkinfo];
            if ([minstr([pkinfo valueForKey:@"ifpk"]) isEqual:@"1"]) {
                [strongSelf showPKView:pkinfo];
                NSMutableDictionary *pkDic = [NSMutableDictionary dictionary];
                [pkDic setObject:minstr(strongSelf.playDocModel.zhuboID) forKey:@"pkuid1"];
                [pkDic setObject:minstr([pkinfo valueForKey:@"pk_gift_liveuid"]) forKey:@"pktotal1"];
                [pkDic setObject:minstr([pkinfo valueForKey:@"pk_gift_pkuid"]) forKey:@"pktotal2"];
                [strongSelf changePkProgressViewValue:pkDic];
            }
        }
        
        strongSelf->isOpenLotteryWindow = [[info objectForKey:@"auto_show_game"] boolValue];
        
        
    }andlivetype:_livetype];
}
//改变连送礼物的frame
-(void)changecontinuegiftframe{
    
    liansongliwubottomview.frame = CGRectMake(0, _tableViewTop - 150,300,140);
    
}
//改变连送礼物的frame
-(void)changecontinuegiftframeIndoliwu{
    
    liansongliwubottomview.frame = CGRectMake(0, _window_height - (_window_width/2+100+ShowDiff)-140,_window_width/2,140);
}

-(void)reloadUserList{
    [listView listReloadNoew];
//    if (isencryption && _nplayer !=nil) {
//        NSString *randomEnCodeStr = [[RandomRule randomWithColumn:4 Line:4 seeds:[_playDocModel.zhuboID integerValue] others:nil] substringToIndex:16];
//        [_nplayer setCryptoKey:randomEnCodeStr];
//    }
}
- (void)reloadLiveplayAttion:(NSNotification *)notObj{
    NSDictionary *dic = [notObj object];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *isattention = minstr([dic valueForKey:@"isattent"]);
        [self isAttentionLive:isattention];
        if (![isattention isEqual:@"0"]) {
            if (socketDelegate) {
                [socketDelegate attentionLive];
            }
        }
    }
}
-(void)isAttentionLive:(NSString *)isattention{
    self.isAttention = isattention;
    if ([isattention isEqual:@"0"]) {
        //未关注
        setFrontV.newattention.hidden = false;
        setFrontV.leftView.frame = CGRectMake(10,25+statusbarHeight,145,leftW);
        listcollectionviewx = _window_width+150;
        listView.frame = CGRectMake(listcollectionviewx, 20+statusbarHeight, _window_width-150,40);
        listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-150, 40);
    }
    else{
        //关注
        setFrontV.newattention.hidden = 1;
        setFrontV.leftView.frame = CGRectMake(10,25+statusbarHeight,103,leftW);
        listcollectionviewx = _window_width+105;
        listView.frame = CGRectMake(listcollectionviewx, 20+statusbarHeight, _window_width-105,40);
        listView.listCollectionview.frame = CGRectMake(0, 0, _window_width-105, 40);
        
        
    }
}

- (void)setupObservers
{
    [self releaseObservers];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lotteryRsync:) name:@"lotteryRsync" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toolbarHidden) name:@"toolbarHidden" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(qiehuanfangjian:) name:@"qiehuanfangjian" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dissmissVC) name:KLogOutNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadLiveplayAttion:) name:@"reloadLiveplayAttion" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(livePlayStop) name:@"LivePlayStop" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(livePlayStart) name:@"LivePlayStart" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOrHidenMessageTableView:) name:KShowLotteryBetViewControllerNotification object:nil];

}
- (void)releaseObservers
{
 
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"toolbarHidden" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"sixinok" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"qiehuanfangjian" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadLiveplayAttion" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KLogOutNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    
}

-(void)checkIfEncryption
{
    NSString *zhubID = _playDocModel.zhuboID;
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

-(void)setAudioEnable:(BOOL)audioEnable{
    if ( _nplayer ) {
        _nplayer.volume = audioEnable;
    }
    if (!audioEnable) {
        setFrontV.bigAvatarImageView.hidden = false;
    }
}


- (void)onPlayNodeVideoPlayer:(NodePlayer*)nPlayerC audioEnable:(BOOL)audioEnable{

//    if(videoView == nil|| videoView.superview == nil){
//        videoView = [[UIView alloc] init];
//        videoView.backgroundColor = [UIColor redColor];
//
//    }
//    [self.view addSubview:videoView];
//    [self.view sendSubviewToBack:videoView];
//    videoView.frame = CGRectMake(0,0, _window_width, _window_height);
    
    _nplayer = nPlayerC;
    NSLog(@"--------------------------准备播放");
    
//    NSString *lastComStr = self.playDocModel.pull.lastPathComponent;
    
    
//    if(self.playDocModel.isvideo && [self.playDocModel.isvideo boolValue]){
//        isencryption = false;
//    }

    WeakSelf
    _nplayer.nodePlayerDelegate = weakSelf;
    [_nplayer setBufferTime:400];
   
    [self checkIfEncryption];
    
    NSString * url = [minstr(self.playDocModel.pull) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [_nplayer setHWAccelEnable:false];
    [_nplayer setScaleMode:2];
    [_nplayer attachView:videoView];
    [_nplayer setLogLevel:0];
    _nplayer.scaleMode = 2;
    _nplayer.RTSPTransport = RTSP_TRANSPORT_TCP;
    _nplayer.volume = audioEnable?1:0;
    
    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
    [_nplayer start:url];
    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
    _nplayer.volume = audioEnable?1:0;
    
    
    if (!audioEnable) {
        setFrontV.bigAvatarImageView.hidden = false;
    }

}
-(void) onEventCallback:(id _Nonnull)sender event:(int)event msg:(NSString* _Nonnull)msg
{
    NSLog(@"--------------------------播放%@",[NSString stringWithFormat:@"%d  %@",event,msg]);
    switch (event) {
        case 1104:
        {
          
//            if(_livetype == 0){
#ifdef LIVE
            WeakSelf
            dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                // 你的延迟代码
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                
                dispatch_main_async_safe(^{
                    strongSelf->setFrontV.bigAvatarImageView.hidden = 1;
                    strongSelf->setFrontV.bigAvatarImageView.alpha = 1;
                    strongSelf->backScrollView.userInteractionEnabled = 1;
                    strongSelf->backScrollViewContentSizeWidthConstraint.constant = _window_width * 2;
                    
//                        if(strongSelf->isChckedLive && ![strongSelf->_livetype isEqualToString:@"0"]){
//                            [strongSelf addVideoCover];
//                        }
                });
            });

              [self.pendingDleayBlocks addObject:delayBlock];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(),delayBlock);
#else
            dispatch_main_async_safe(^{
                if(self.isChckedLive){
                    self->setFrontV.bigAvatarImageView.hidden = 1;
                    self->setFrontV.bigAvatarImageView.alpha = 1;
                    self->backScrollView.userInteractionEnabled = 1;
                    self->backScrollViewContentSizeWidthConstraint.constant = _window_width * 2;
//                    if(![self->_livetype isEqualToString:@"0"]){
//                        [self addVideoCover];
//                    }
                }
                    
                  
                });
#endif
//            }
        }
            break;
        case 1103:
        case 1005:
        case 1001:
        case 1002:
            [_nplayer pause:false];
        case 1006:
        {

        }
        default:
            break;
    }

}


- (void)onStopVideo:(BOOL)hiddenCover{

    if (_nplayer) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isPlaying"] == false && self.fromCell != nil) {

        } else {
            [_nplayer stop];
        }
    }
    setFrontV.bigAvatarImageView.hidden = hiddenCover;
    
}
/*************** 以上视频播放 ***************/
//礼物效果
/************ 礼物弹出及队列显示开始 *************/
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        //[backScrollView addSubview:haohualiwuV];
        [backScrollView insertSubview:haohualiwuV atIndex:10];
        CGAffineTransform t = CGAffineTransformMakeTranslation(_window_width, 0);
        haohualiwuV.transform = t;
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
        [backScrollView insertSubview:haohualiwuV atIndex:10];
        //[backScrollView addSubview:haohualiwuV];
        CGAffineTransform t = CGAffineTransformMakeTranslation(_window_width, 0);
        haohualiwuV.transform = t;
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
/*
 *添加魅力值数
 */
-(void)addCoin:(long)coin
{
    long long ordDate = [votesTatal longLongValue];
    votesTatal = [NSString stringWithFormat:@"%lld",ordDate + coin];
    [setFrontV changeState: votesTatal];
}
-(void)addvotesdelegate:(NSString *)votes{
    [self addCoin:[votes longLongValue]];
}
/************  杨志刚 礼物弹出及队列显示结束 *************/
//跳转充值
-(void)pushCoinV{
    [self pushRecharge];
    [MobClick event:@"live_room_charge_click" attributes:@{@"eventType": @(1)}];
}
-(void)pushRecharge{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:1];
}

//聊天自动上滚
-(void)jumpLast
{
    if (_canScrollToBottom || _scrollToBottomCount > 0) {
        _scrollToBottomCount--;
        NSUInteger sectionCount = [self.tableViewMsg numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [self.tableViewMsg numberOfRowsInSection:0];
            if (rowCount!=NSNotFound) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tableViewMsg numberOfRowsInSection:0]-1 inSection:0];
                if(indexPath.row!= messageList.count-1) {
                    return;
                }
                if (indexPath.row>0) {
                    [self.tableViewMsg scrollToRowAtIndexPath:indexPath
                                             atScrollPosition:UITableViewScrollPositionBottom animated:1];
                }
                
                [self hidenNewMessages:1];
                
            }
        }
    }else{
        [self hidenNewMessages:false];
    }
}

//用户聊天自动上滚
-(void)userjumpLast
{
    if (_canScrollToBottomUser || _scrollToBottomCountUser > 0) {
        _scrollToBottomCountUser--;
        NSUInteger sectionCount = [self.tableViewUserMsg numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [self.tableViewUserMsg numberOfRowsInSection:0];
            if (rowCount!=NSNotFound) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.tableViewUserMsg numberOfRowsInSection:0]-1 inSection:0];
                if(indexPath.row!= msgList.count-1) {
                    return;
                }
                if (indexPath.row>0) {
                    [self.tableViewUserMsg scrollToRowAtIndexPath:indexPath
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
    _canScrollToBottom = 1;
    [self jumpLast];
    [self scrollToLastUserCell];
}

//用户消息
-(void)scrollToLastUserCell
{
    _canScrollToBottomUser = 1;
    [self userjumpLast];
}

-(void)hidenNewMessages:(BOOL)hiden
{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->newMsgButton.alpha = hiden?0:1;
        strongSelf->newMsgButton.top =  _tableViewBottom + (hiden?0:-30);
    }];
}
//切换聊天和弹幕
-(void)switchState:(BOOL)state
{
    if(!state) {
        [self updatePlanceHolder];
    } else {
        NSString *currencyCoin = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%@", self.danmuprice] showUnit:YES];
        keyField.placeholder = [NSString stringWithFormat:@"%@，%@/%@",YZMsg(@"Livebroadcast_Open_msg_notifys"),currencyCoin,YZMsg(@"public_itemMsg")];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    isShowingMore = false;
    [self.view endEditing:1];
}
//执行扣费
-(void)timecoastmoney{
    coasttime -= 1;
    if (coasttime <= 0) {
        [timecoast invalidate];
        timecoast = nil;
        coasttime = 60;
        [self docoasttime];
    }
}
#pragma mark ==========切换计时房间类型===================
-(void)changeLive:(NSString *)type_val changetype:(NSString *)type{
    if (isSuperAdmin) {
        return;
    }
    
    [self addVideoCover];
    NSString *currencyCoin = [YBToolClass getRateCurrency:type_val showUnit:YES];
    if ([minstr(type) isEqualToString:@"3"]) {
        
        _type_val = type_val;
        if (timecoast) {
            [timecoast invalidate];
            timecoast = nil;
        }
        coasttime = 0;
        Feedeductionalertc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:YZMsg(@"LivePlay_RommSwitchTime_%@%@Price"),currencyCoin,@""] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
        WeakSelf
        UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_No") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf cancelOrNextRoom];
        }];
        UIAlertAction *surelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf docoasttime];
        }];
        [Feedeductionalertc addAction:cancelActionss];
        [Feedeductionalertc addAction:surelActionss];
        if (self.presentedViewController == nil) {
            [self presentViewController:Feedeductionalertc animated:1 completion:nil];
        }
    }else{
        
        _type_val = type_val;
     
        if (timecoast) {
            [timecoast invalidate];
            timecoast = nil;
        }
        coasttime = 0;

        Feedeductionalertc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:YZMsg(@"LivePlay_RommSwitchTicket_%@%@Price"),currencyCoin,@""] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
        WeakSelf
        UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_No") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf cancelOrNextRoom];
        }];
        UIAlertAction *surelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf docostmenpiao];
        }];
        
        [Feedeductionalertc addAction:cancelActionss];
        [Feedeductionalertc addAction:surelActionss];
        if (self.presentedViewController == nil) {
            [self presentViewController:Feedeductionalertc animated:1 completion:nil];
        }
    }
    
    
}
//门票扣费
-(void)docostmenpiao{
    
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=%@",@"Live.roomCharge"];
    NSDictionary *subdic = @{
        @"uid":[Config getOwnID],
        @"token":[Config getOwnToken],
        @"liveuid":self.playDocModel.zhuboID,
        @"stream":self.playDocModel.stream
    };
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:url withBaseDomian:false andParameter:subdic data:nil success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
           
            NSDictionary *info = [infos firstObject];
            NSString *live_votes = minstr([info valueForKey:@"live_votes"]);
            strongSelf->votesTatal = live_votes;
            [strongSelf->setFrontV changeState:strongSelf->votesTatal];
            LiveUser *user = [Config myProfile];
            user.coin = minstr([info valueForKey:@"coin"]);
            [Config updateProfile:user];
            [strongSelf removeVideoCover];
        }else{
            UIAlertController  *alertlianmaiVC = [UIAlertController alertControllerWithTitle:YZMsg(@"LivePlay_BalanceNot") message:@"" preferredStyle:UIAlertControllerStyleAlert];
            //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
            UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_GoCharge") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

                [strongSelf pushRecharge];
                [strongSelf.alertShowForLive showWithAnimation:strongSelf.view];
            }];
            if (strongSelf->timecoast) {
                [strongSelf->timecoast invalidate];
                strongSelf->timecoast = nil;
            }
            [strongSelf addVideoCover];
          
            [alertlianmaiVC addAction:cancelActionss];
            dispatch_main_async_safe(^{
                if (strongSelf.presentedViewController == nil) {
                    [strongSelf presentViewController:alertlianmaiVC animated:1 completion:nil];
                }
                
            });
        }
    } fail:^(id fail) {
        
    }];
}
//计时扣费
-(void)docoasttime{
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=%@",@"Live.timeCharge"];
    NSDictionary *subdic = @{
        @"uid":[Config getOwnID],
        @"token":[Config getOwnToken],
        @"liveuid":self.playDocModel.zhuboID,
        @"stream":self.playDocModel.stream
    };
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:url withBaseDomian:false andParameter:subdic data:nil success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {

            strongSelf->coasttime = 60;
            if (!strongSelf->timecoast) {
                strongSelf->timecoast = [NSTimer scheduledTimerWithTimeInterval:1.0 target:strongSelf selector:@selector(timecoastmoney) userInfo:nil repeats:1];
                [[NSRunLoop currentRunLoop]addTimer:strongSelf->timecoast forMode:NSRunLoopCommonModes];
            }
            NSDictionary *info = [infos firstObject];
            NSString *live_votes = minstr([info valueForKey:@"live_votes"]);
            strongSelf->votesTatal = live_votes;
            [strongSelf->setFrontV changeState:strongSelf->votesTatal];
            LiveUser *user = [Config myProfile];
            user.coin = minstr([info valueForKey:@"coin"]);
            [Config updateProfile:user];
            [strongSelf removeVideoCover];
            
        }else{
            UIAlertController  *alertlianmaiVC = [UIAlertController alertControllerWithTitle:YZMsg(@"LivePlay_BalanceNot") message:@"" preferredStyle:UIAlertControllerStyleAlert];
            //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
            UIAlertAction *cancelActionss = [UIAlertAction actionWithTitle:YZMsg(@"LivePlay_GoCharge") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf pushRecharge];
                [strongSelf.alertShowForLive showWithAnimation:strongSelf.view];
            }];
            if (strongSelf->timecoast) {
                [strongSelf->timecoast invalidate];
                strongSelf->timecoast = nil;
            }
            [strongSelf addVideoCover];
            
         
            [alertlianmaiVC addAction:cancelActionss];
            dispatch_main_async_safe(^{
                if (strongSelf.presentedViewController == nil) {
                    [strongSelf presentViewController:alertlianmaiVC animated:1 completion:nil];
                }
                
            });
        }
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->timecoast) {
            [strongSelf->timecoast invalidate];
            strongSelf->timecoast = nil;
        }
        [strongSelf dissmissVC];
    }];
}
////竞拍失败
//-(void)jingpaifailed{
//    [gifhour addjingpairesultview:3 anddic:nil];
//}
//-(void)jingpaisuccess:(NSDictionary *)dic{
//    [gifhour addjingpairesultview:4 anddic:dic];
//}
////有人竞拍获取新竞拍信息
//-(void)getnewjingpaipersonmessage:(NSDictionary *)dic{
//    [gifhour getnewmessage:dic];
//}
//交了保证金后刷新钻石
//-(void)jingpaizuanshi{
//
//    if (gifhour) {
//        [gifhour getcoins];
//    }
//    if (giftview) {
//        [giftview chongzhiV:[Config getcoin]];
//    }
//}
////竞拍 //获取竞拍信息
//-(void)getjingpaimessagedelegate:(NSDictionary *)dic{
//
//    if (!gifhour) {
//        WeakSelf
//        gifhour  = [[Hourglass alloc]initWithModel:self.playDocModel andFrame:CGRectMake(_window_width*2 - 60,_window_height*0.35,60,100) Block:^(NSString *task) {
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            //点击竞拍压住
//            [strongSelf->socketDelegate sendmyjingpaimessage:task];
//            [strongSelf jingpaizuanshi];
//
//        } andtask:^(NSString *task) {
//
//
//        } andjingpaixiangqingblock:^(NSString *task) {
//            //进入详情页面
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            webH5 *VC = [[webH5 alloc]init];
//            VC.isjingpai = @"isjingpai";
//            VC.urls = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"/index.php?g=Appapi&m=Auction&a=detail&id=%@&uid=%@&token=%@",task,[Config getOwnID],[Config getOwnToken]];
//            dispatch_main_async_safe(^{
//                if (strongSelf.presentedViewController == nil) {
//                    [strongSelf presentViewController:VC animated:YES completion:nil];
//                }
//            });
//        } andchongzhi:^(NSString *task) {
//            //跳往充值页面
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            [strongSelf pushCoinV];
//        }];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jingpaizuanshi) name:@"isjingpai" object:nil];
//        [backScrollView addSubview:gifhour];
//        [backScrollView insertSubview:gifhour atIndex:4];
//        [gifhour addnowfirstpersonmessahevc];
//    }
//    if (gifhour) {
//        [gifhour getjingpaimessage:dic];
//    }
//}

- (void)changeRoom:(hotModel *)infoModel{
    
    _type_val = 0;
    _livetype = 0;
    _isPreviewSecond = 0;
    _isChckedLive =false;
    [self handleNotificationChangeTabView:1];
//    _isJpush = @"1";
    coasttime = 60;
    isencryption = infoModel.encryption;
    self.quikSayNum = 0;
    ksynotconnected = false;
    ksyclosed = false;
    isshow = 0;
    if (curLotteryBetVC) {
        curLotteryBetVC.isExit = true;
    }
    giftViewShow = false;
    isSuperAdmin = false;
    
    if (socketDelegate) {
        [socketDelegate socketStop];
    }
    if (self.showMoreMessageView) {
        [self.showMoreMessageView removeFromSuperview];
        self.showMoreMessageView = nil;
    }
    if (alertGiftShow) {
        [alertGiftShow removeFromSuperview];
        alertGiftShow = nil;
    }
    if(curLotteryBetVC){
        if([curLotteryBetVC respondsToSelector:@selector(exitView)]){
            [curLotteryBetVC exitView];
        }
        [curLotteryBetVC removeFromParentViewController];
        [curLotteryBetVC.view removeFromSuperview];
        curLotteryBetVC = nil;
    }
    if(self.alertShowForLive){
        [self.alertShowForLive removeFromSuperview];
        self.alertShowForLive = nil;
    }
    if (socketDelegate) {
        [socketDelegate socketStop];
        socketDelegate.socketDelegate = nil;
        socketDelegate = nil;
    }
    
    [self initArray];
    [self.tableViewMsg reloadData];
    [self.tableViewUserMsg reloadData];
    
    [continueGifts stopTimerAndArray];
    [continueGifts initGift];
    [continueGifts removeFromSuperview];
    continueGifts = nil;
    haohualiwuV.expensiveGiftCount = nil;
    haohualiwuV.expensiveGiftCount = [NSMutableArray array];
    [haohualiwuV stopHaoHUaLiwu];
    [self releaseObservers];
    [self removeVideoCover];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFenpingView) object:nil];
    
    if (msgList == nil) {
        msgList = [NSMutableArray array];
    }
    if (messageList == nil) {
        messageList = [NSMutableArray array];
    }
  
   
    WeakSelf
    dispatch_main_async_safe(^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableViewMsg reloadData];
        [strongSelf.tableViewUserMsg reloadData];
    });
    
    
    
    NSString *path = self.playDocModel.zhuboIcon;
    NSURL *url = [NSURL URLWithString:path];
    [setFrontV.IconBTN sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    [setFrontV.levelimage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"host_%@",minstr(self.playDocModel.level_anchor)]]];
    
    userCount = 0;
    [listView initArray];
    listView = nil;
   
   
    [self removetimer];

    [[UIApplication sharedApplication] setIdleTimerDisabled:1];
    haohualiwuV.expensiveGiftCount = nil;
    if (continueGifts) {
        [continueGifts stopTimerAndArray];
        continueGifts = nil;
    }
   
    if (giftview) {
        [giftview removeFromSuperview];
        giftview = nil;
    }
    [self showBTN];
 
   
    [curLotteryBetVC exitView];
    myUser = [Config myProfile];
    _listArray = [NSMutableArray array];
  
    //显示进场标题
    [self showTitle];
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
    
   
  
    [self getLotteryList];
    
   
    [self setupObservers];
    [self getNodeJSInfo]; //初始化nodejs信息
    
    LiveUser *user = [Config myProfile];
    if(user.isZeroCharge){
        WeakSelf
        dispatch_block_t delayBlock = dispatch_block_create(0, ^{
            // 你的延迟代码
            STRONGSELF
                        if (strongSelf == nil || strongSelf->socketDelegate == nil) {
                            return;
                        }
                        if(strongSelf->lotteryTime!= nil && strongSelf.isChckedLive){
                            [strongSelf changeGiftViewFrameY:_window_height*10];
                            [strongSelf timeShowChargeAction];
                        }
        });

        [self.pendingDleayBlocks addObject:delayBlock];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(user.liveShowChargeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
    }
    
    if(videoView == nil|| videoView.superview == nil){
        videoView = [[UIView alloc] init];
        videoView.backgroundColor = [UIColor redColor];
        
    }
    [self.view addSubview:videoView];
    [self.view sendSubviewToBack:videoView];
    [self.view insertSubview:bigAvatarImageView1 atIndex:0];
    videoView.frame = CGRectMake(0,0, _window_width, _window_height);
    if(_nplayer){
        _nplayer.nodePlayerDelegate = self;
        [_nplayer attachView:videoView];
        [_nplayer pause:false];
    }
    
    
    setFrontV.bigAvatarImageView.hidden = false;
    //收费检查
    [self checkLive];
 
    
    
}

-(void)checkLive{
    /* 測試用
    _weakify(self)
    vkGcdAfter(1, ^{
        _strongify(self)
        if ([self.playDocModel.zhuboID isEqualToString:@"35417740"]) {
            NSDictionary *userInfo = @{@"roomId": self.playDocModel.zhuboID};
            [[NSNotificationCenter defaultCenter] postNotificationName:LivePlayTableVCRemoveRoomIdNotifcation object:nil userInfo:userInfo];
        }
    });
     */
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.checkLive"];
    NSDictionary *dic = @{@"uid":[Config getOwnID],@"token":[Config getOwnToken],@"liveuid":_playDocModel.zhuboID,@"stream":_playDocModel.stream};
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:false andParameter:dic data:nil success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil || strongSelf->lotteryTime == nil) {
            return;
        }
        int timeSecondPreview = 7;
        int timeNumberPreview = 3;
        if (code == 0) {
           
            NSDictionary *info = [infos firstObject];
            NSString *type = [NSString stringWithFormat:@"%@",[info valueForKey:@"type"]];
            
            strongSelf->_type_val =  [NSString stringWithFormat:@"%@",[info valueForKey:@"type_val"]];
            strongSelf->_livetype =  type;
            if([info valueForKey:@"timeSecondPreview"]!= nil){
                timeSecondPreview = [[info valueForKey:@"timeSecondPreview"] intValue];
            }
            if([info valueForKey:@"timeNumberPreview"]!= nil){
                timeNumberPreview = [[info valueForKey:@"timeNumberPreview"] intValue];
            }
            strongSelf.isPreviewSecond = timeSecondPreview;
            
            if ([type isEqualToString:@"0"]) {
                [strongSelf removeVideoCover];
             
            }else if([type isEqualToString:@"2"] ||
                     [type isEqualToString:@"3"])
            {
                NSMutableArray *previewArr = [[HotAndAttentionPreviewLogic sharedManager] getMyPreviewArr];
                //如果预览过或者预览次数超过3次了。
                if([previewArr containsObject:[NSString stringWithFormat:@"%@%@",[Config getOwnID],strongSelf.playDocModel.stream]] || timeNumberPreview<=0)
                {
                    //付费弹框 2 ｜ 3
                    [strongSelf checkLiveByCoast:minstr([info valueForKey:@"type_msg"]) TextFiledType:false];
                }else{
                    [previewArr addObject:[NSString stringWithFormat:@"%@%@",[Config getOwnID],strongSelf.playDocModel.stream]];
                    [[HotAndAttentionPreviewLogic sharedManager] setMyPreviewArr:previewArr];
                    
                    if(strongSelf.isPreviewSecond>0)
                    {
                        [strongSelf removeVideoCover];
                        //付费和计时房间可以先看7s
                        //s之后退出
                        WeakSelf
                        dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                            // 你的延迟代码
                            STRONGSELF
                            if (strongSelf == nil||strongSelf->lotteryTime == nil) {
                                return;
                            }
                            if(strongSelf.alertShowForLive != nil){
                                return;
                            }
                            //恢复付费
                            [strongSelf checkLiveByCoast:minstr([info valueForKey:@"type_msg"]) TextFiledType:false];
                        });

                        [strongSelf.pendingDleayBlocks addObject:delayBlock];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(strongSelf.isPreviewSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
                    }else{
                        [strongSelf checkLiveByCoast:minstr([info valueForKey:@"type_msg"]) TextFiledType:false];
                    }
                }
                
            }else if ([type isEqual:@"1"]){
                
                NSString *_MD5 = [NSString stringWithFormat:@"%@",[info valueForKey:@"type_msg"]];
                //密码
                [strongSelf checkLiveByCoast:_MD5 TextFiledType:YES];
                
            }
          
        }else if(code == 1005){
            [strongSelf StartEndLive];
        }else if(code == 1004){
            WeakSelf
            self.alertShowForLive = [CustomAlertView showAlertInView:self.view withTitle:YZMsg(@"public_warningAlert") message:msg cancelTitle:@"" confirmTitle:YZMsg(@"publictool_sure") cancelBlock:^{
                STRONGSELF
                if(strongSelf == nil){
                    return;
                }
//                [strongSelf cancelOrNextRoom];
                [strongSelf releaseAll];
                [strongSelf dissmissVC];
                [[MXBADelegate sharedAppDelegate].navigationViewController popViewControllerAnimated:YES];
                [[MXBADelegate sharedAppDelegate].topViewController dismissViewControllerAnimated:false completion:nil];

            } confirmBlock:^{
                STRONGSELF
                if(strongSelf == nil){
                    return;
                }
//                [strongSelf cancelOrNextRoom];
                [strongSelf releaseAll];
                [strongSelf dissmissVC];
                [[MXBADelegate sharedAppDelegate].navigationViewController popViewControllerAnimated:YES];
                [[MXBADelegate sharedAppDelegate].topViewController dismissViewControllerAnimated:false completion:nil];
                
            }];
            [strongSelf onStopVideo:false];
        }else{
            [strongSelf addVideoCover];
            [MBProgressHUD showError:msg];
        }
        strongSelf.isChckedLive = true;
    } fail:^(id fail) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf addVideoCover];
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        strongSelf.isChckedLive = false;
    }];
}
BOOL isclickButton = false;
-(void)checkLiveByCoast:(NSString*)msg TextFiledType:(BOOL)textFieldType {
    //视图加蒙层
    [self addVideoCover];
    
    if(textFieldType){
        WeakSelf
        CustomAlertView *extractedExpr = [CustomAlertView showAlertWithTextFieldInView:self.view withTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"EnterLivePlay_pwdRoomWarning") placeholder:YZMsg(@"EnterLivePlay_input_pwd") cancelTitle:YZMsg(@"public_cancel") confirmTitle:YZMsg(@"publictool_sure") cancelBlock:^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            [strongSelf cancelOrNextRoom];
            isclickButton = true;
        } confirmBlock:^(NSString *textFieldContent) {
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            if ([msg isEqualToString:[PublicObj stringToMD5:textFieldContent]]) {
                
                [strongSelf removeVideoCover];
            }else{
                
                [MBProgressHUD showError:YZMsg(@"EnterLivePlay_pwd_error")];
                [strongSelf removeVideoCover];
                [strongSelf checkLiveByCoast:msg TextFiledType:textFieldType];
            }
            isclickButton = true;
        }];

        extractedExpr.textField.keyboardType = UIKeyboardTypeASCIICapable;
        extractedExpr.textField.returnKeyType = UIReturnKeyDone;

        self.alertShowForLive = extractedExpr;
    }else{
        WeakSelf
        self.alertShowForLive = [CustomAlertView showAlertInView:self.view withTitle:YZMsg(@"public_warningAlert") message:msg cancelTitle:YZMsg(@"public_cancel") confirmTitle:YZMsg(@"publictool_sure") cancelBlock:^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            [strongSelf cancelOrNextRoom];
            isclickButton = true;
        } confirmBlock:^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            if([strongSelf->_livetype integerValue] == 3){
                [strongSelf docoasttime];
            }else{
                [strongSelf docostmenpiao];
            }
            isclickButton = true;
        }];
    }
    WeakSelf
    dispatch_block_t delayBlock = dispatch_block_create(0, ^{
        // 你的延迟代码
        STRONGSELF
                                   if(strongSelf == nil){
                                       return;
                                   }
        if (!isclickButton) {
            [strongSelf cancelOrNextRoom];
        }                       
    });

    [self.pendingDleayBlocks addObject:delayBlock];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
    
}
-(void)cancelOrNextRoom{
    //滚动下一个或者返回
    UIViewController *superController = self.parentViewController;
    if ([superController isKindOfClass:[LivePlayTableVC class]]) {
        //自动滚动
        LivePlayTableVC *supertableView = (LivePlayTableVC*)superController;
        // 获取当前可见的第一个 cell 的 index path
        NSIndexPath *currentIndexPath = [[supertableView.tableView indexPathsForVisibleRows] firstObject];

        // 计算下一个 cell 的 index path
        NSInteger nextRow = currentIndexPath.row + 1;
        NSInteger nextSection = currentIndexPath.section;

        // 计算上一个 cell 的 index path
        NSInteger previousRow = currentIndexPath.row - 1;
        NSInteger previousSection = currentIndexPath.section;

        NSIndexPath *nextIndexPath = nil;
        NSIndexPath *previousIndexPath = nil;

        // 检查是否存在下一个 cell
        if (nextRow < [supertableView.tableView numberOfRowsInSection:currentIndexPath.section]) {
            nextIndexPath = [NSIndexPath indexPathForRow:nextRow inSection:nextSection];
        }

        // 检查是否存在上一个 cell
        if (previousRow >= 0) {
            previousIndexPath = [NSIndexPath indexPathForRow:previousRow inSection:previousSection];
        }

        // 优先滚动到下一个 cell，如果不存在，滚动到上一个 cell
        if (nextIndexPath) {
            [supertableView.tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [supertableView scrollViewDidEndDecelerating:supertableView.tableView];
            });
           
        } else if (previousIndexPath) {
            [supertableView.tableView scrollToRowAtIndexPath:previousIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [supertableView scrollViewDidEndDecelerating:supertableView.tableView];
            });
        } else {
            NSLog(@"没有更多的 cell 可以滚动");
            [self dissmissVC];
            [[MXBADelegate sharedAppDelegate].navigationViewController popViewControllerAnimated:YES];
            [[MXBADelegate sharedAppDelegate].topViewController dismissViewControllerAnimated:false completion:nil];
        }
        
    }else{
        [self releaseAll];
        [self dissmissVC];
        [[MXBADelegate sharedAppDelegate].navigationViewController popViewControllerAnimated:YES];
        [[MXBADelegate sharedAppDelegate].topViewController dismissViewControllerAnimated:false completion:nil];
    }
}

- (void)qiehuanfangjian:(NSNotification *)notObj{
    NSDictionary *dic = [notObj object];
//    _isJpush = @"1";
    [self dissmissVC];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"jinruzhibojiantongzhi" object:dic];
}

//加蒙层
-(void)addVideoCover{
  
    UIVisualEffectView *effectview = [self.view.superview viewWithTag:100001];
    if(effectview == nil){
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.frame = CGRectMake(0, 0,_window_width,_window_height);
        effectview.tag = 100001;
        effectview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:effectview];
    }
    [videoView addSubview:effectview];
    setFrontV.bigAvatarImageView.hidden = true;
    
}
-(void)removeVideoCover{
    setFrontV.bigAvatarImageView.hidden = true;
    UIVisualEffectView *blurEffectView = [videoView viewWithTag:100001];
    if(blurEffectView){
        [blurEffectView removeFromSuperview];
    }
}

#pragma mark ================ s添加印象 ===============
- (void)setLabel:(NSString *)touid{
    impressVC *vc = [[impressVC alloc]init];
    vc.isAdd = 1;
    vc.touid = touid;
    [self.navigationController pushViewController:vc animated:1];
}
#pragma mark ================ 改变发送按钮图片 ===============
- (void)ChangePushBtnState{
    if (keyField.text.length > 0) {
        pushBTN.selected = 1;
    }else{
        pushBTN.selected = false;
    }
}
#pragma mark ================ 守护功能 ===============
-(void)showGuardView{
    [self doCancle];
    if (giftview) {
        [self hidenToolbar];
        [self changeGiftViewFrameY:_window_height*10];
    }
    gShowView = [[guardShowView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andUserGuardMsg:guardInfo andLiveUid:minstr(_playDocModel.zhuboID)];
    gShowView.delegate = self;
    [self.view addSubview:gShowView];
    [gShowView show];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"守护榜"};
    [MobClick event:@"live_room_menue_click" attributes:dict];
}
-(void)hidenToolbar
{
    
    giftViewShow = false;
    isShowingMore = false;
    if (keyField.isFirstResponder) {
        [keyField resignFirstResponder];
    }else{
        [self hidenKeyboard];
    }
}
#pragma mark ================ 实时榜 ===============
-(void)showTopTodayView
{
    [self doCancle];
    [TopTodayView showInView:self.view model:_playDocModel delegate:self];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"实时榜单"};
    [MobClick event:@"live_room_menue_click" attributes:dict];
}
-(void)sendGiftAction
{
    [self doLiwu];
}

- (void)buyOrRenewGuard{
    [self removeShouhuView];
    if (!guardView) {
        guardView = [[shouhuView alloc]init];
        guardView.liveUid = minstr(_playDocModel.zhuboID);
        guardView.stream = minstr(_playDocModel.stream);
        guardView.delegate = self;
        guardView.guardType = minstr([guardInfo valueForKey:@"type"]);
        [self.view addSubview:guardView];
    }
    [guardView show];
}
- (void)removeShouhuView{
    if (guardView) {
        [guardView removeFromSuperview];
        guardView = nil;
    }
    if (gShowView) {
        [gShowView removeFromSuperview];
        gShowView = nil;
    }
    if (redList) {
        [redList removeFromSuperview];
        redList = nil;
    }
}
- (void)buyShouhuSuccess:(NSDictionary *)dic{
    guardInfo = dic;
    if (socketDelegate) {
        [socketDelegate buyGuardSuccess:dic];
    }
    
}
- (void)updateGuardMsg:(NSDictionary *)dic{
    [setFrontV changeState:minstr([dic valueForKey:@"votestotal"])];
    [setFrontV changeGuardButtonFrame:minstr([dic valueForKey:@"guard_nums"])];
    if (listView) {
        [listView listReloadNoew];
    }
    
}
#pragma mark ================ 红包 ===============
- (void)showRedView{
    [self doCancle];
    redBview = [[redBagView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    __weak moviePlay *wSelf = self;
    redBview.block = ^(NSString *type) {
        [wSelf sendRedBagSuccess:type];
    };
    redBview.zhuboModel = _playDocModel;
    [self.view addSubview:redBview];
    [MobClick event:@"live_room_redpack_click" attributes:@{@"eventType": @(1)}];
}
- (void)sendRedBagSuccess:(NSString *)type{
    [redBview removeFromSuperview];
    redBview = nil;
    if ([type isEqual:@"909"]) {
        return;
    }
    if (socketDelegate) {
        [socketDelegate fahongbaola];
    }
    
}
- (void)showRedbag:(SendRed *)dic{
    if (!redBagBtn) {
        //PK按钮
        redBagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [redBagBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"redpack-right"] forState:UIControlStateNormal];
        [redBagBtn addTarget:self action:@selector(redBagBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self resetRedBagBtnFrame];
        [backScrollView insertSubview:redBagBtn aboveSubview:self.horizontalMarquee];
    }
    redBagBtn.hidden = false;
    NSString *uname;
    if ([minnum(dic.msg.uid) isEqual:_playDocModel.Id]) {
        uname = YZMsg(@"Livebroadcast_LiveAnchor");
    }else{
        uname = minstr(dic.msg.uname);
    }
    NSString *levell = minnum(dic.msg.level);
    NSString *ID = minnum(dic.msg.uid);
    NSString *vip_type = minnum(dic.msg.vipType);
    NSString *liangname = dic.msg.liangname;
    NSString *isUserMsg = @"1";
    NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",minstr(dic.msg.ct),@"contentChat",levell,@"levelI",ID,@"id",@"redbag",@"titleColor",vip_type,@"vip_type",liangname,@"liangname",isUserMsg,@"isUserMsg",nil];
    
    titleColor = @"0";
    [self addNewMsgFromMsgDic:chat];
    
}

- (void)resetRedBagBtnFrame {
    CGFloat height = 0;
    NSString *type = minstr(roomLotteryInfo[@"lotteryType"]);
    if (type.integerValue == 28||type.integerValue == 29||type.integerValue == 31) {
        height = 70;
    }else if(type.integerValue == 10){
        height = 90;
    }else{
        height = 60;
    }

    CGFloat top = UIApplication.sharedApplication.statusBarFrame.size.height + 45 + 30 + 35 + height + 5;
    redBagBtn.frame = CGRectMake(CGRectGetMinX(self.horizontalMarquee.frame) + 5, top, 40, 50);
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
    dispatch_block_t delayBlock = dispatch_block_create(0, ^{
        // 你的延迟代码
        STRONGSELF
                if (strongSelf == nil||strongSelf->lotteryTime == nil) {
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

//    [self.pendingDleayBlocks addObject:delayBlock];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
    
}

//非用户消息刷新显示
-(void)addMessageFromOtherMsgDic:(NSDictionary*)chat
{
    WeakSelf
    dispatch_sync(self.quenMessageReceive, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        chatModel *model = [chatModel modelWithDic:chat];
        [model setChatFrame];
        if ([strongSelf->messageList respondsToSelector:@selector(addObject:)]) {
            [strongSelf->messageList addObject:model];
        }
       
        dispatch_main_async_safe(^{
                    STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf->messageList.count>70) {
                [strongSelf->messageList removeObjectsInRange:NSMakeRange(0, 20)];
            }
            NSTimeInterval timeLim = [[NSDate date] timeIntervalSince1970]*1000;
            if ((timeLim-strongSelf->timeLimitNumber)>200) {
              
                [strongSelf.tableViewMsg reloadData];
                [strongSelf jumpLast];
            }else{
                if (strongSelf->messageList.count<3) {
                    [strongSelf.tableViewMsg reloadData];
                    [strongSelf jumpLast];
                }else{
                    dispatch_block_t delayBlock = dispatch_block_create(0, ^{
                        // 你的延迟代码
                       
                        NSTimeInterval timeLim1 = [[NSDate date] timeIntervalSince1970]*1000;
                                                if ((timeLim-strongSelf->timeLimitNumber)>200) {
                                                    [strongSelf.tableViewMsg reloadData];
                                                    [strongSelf jumpLast];
                                                }
                                                strongSelf->timeLimitNumber = timeLim1;
                    });

                    [strongSelf.pendingDleayBlocks addObject:delayBlock];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);
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
            @synchronized (strongSelf->msgList) {
            if (strongSelf->msgList.count>70) {
//                [strongSelf->msgList removeObjectsInRange:NSMakeRange(0, 20)];
             }
            }
            NSTimeInterval timeLim = [[NSDate date] timeIntervalSince1970]*1000;
            if ((timeLim-strongSelf->timeLimitNumberUser)>200) {
                if (strongSelf->msgList.count<=3&& !strongSelf->_bDraggingScroll && !strongSelf->_bDraggingScrollUser) {
                    [strongSelf tableViewHieghtDeal];
                    [strongSelf jumpLast];
                }
                [strongSelf.tableViewUserMsg reloadData];
                [strongSelf userjumpLast];
            }else{
                if (strongSelf->msgList.count<=3&& !strongSelf->_bDraggingScroll && !strongSelf->_bDraggingScrollUser) {
                    [strongSelf tableViewHieghtDeal];
                    [strongSelf.tableViewUserMsg reloadData];
                    [strongSelf userjumpLast];
                    [strongSelf jumpLast];
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSTimeInterval timeLim1 = [[NSDate date] timeIntervalSince1970]*1000;
                        if ((timeLim-strongSelf->timeLimitNumberUser)>200) {
                            [strongSelf.tableViewUserMsg reloadData];
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

- (void)redBagBtnClick{
    redList = [[redListView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) withZHuboMsgModel:_playDocModel];
    redList.delegate =self;
    [self.view addSubview:redList];
}

#pragma mark ============举报=============

-(void)doReportAnchor:(NSString *)touid{
    [self doCancle];
    
    jubaoVC *vc = [[jubaoVC alloc]init];
    vc.dongtaiId = touid;
    vc.isLive = 1;
    if (self.presentedViewController == nil) {
        [self presentViewController:vc animated:1 completion:nil];
    }
    
}

- (void)adminList {
    
}


- (void)setAdminSuccess:(NSString *)isadmin andName:(NSString *)name andID:(NSString *)ID {
    
}


#pragma mark ============摇摆=============
#define RADIANS(degrees) (((degrees) * M_PI) / 180.0)

- (void)startWobble {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, RADIANS(-10));
    _gameBTN.transform = transform;
    WeakSelf
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.gameBTN.transform = CGAffineTransformMakeRotation(RADIANS(10));
    }
                     completion:^(BOOL finished) {
    }
     ];
}

- (void)stopWobble {
    WeakSelf
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.gameBTN.transform = CGAffineTransformIdentity;
    }
                     completion:NULL
     ];
}

-(void)dealloc
{
//    _nplayer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}
- (void)applyforzhuang {
    
}

- (void)downzhuang {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//
//}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}

- (void)setNeedsFocusUpdate {
    
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return 1;
}

- (void)updateFocusIfNeeded {
    
}

// 退出时的关注提示框
-(LiveClosePopView *)liveClosePopView{
    if (!_liveClosePopView) {
        _liveClosePopView = [[LiveClosePopView alloc] init];
        WeakSelf
        _liveClosePopView.startBtnClickBlock = ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf gaunzhuLive];
        };
        _liveClosePopView.lookBtnClickBlock = ^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.view gy_popViewdismiss];
            [strongSelf dissmissVC];
        };
    }
    return _liveClosePopView;
}

-(NSInteger)timeForReturn:(NSDate *)beginTime endTime:(NSDate *)endTime{
    
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit =NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:beginTime toDate:endTime options:0];
    NSInteger count = cmps.minute * 60 + cmps.second;
    return count;
}

// 关注并退出
- (void)gaunzhuLive{
    NSString *toUid = [NSString stringWithFormat:@"%@",self.playDocModel.zhuboID];

    if ([[Config getOwnID] intValue]<=0) {
        [PublicObj warnLogin];
        return;
    }
    if ([[Config getOwnID] isEqual:toUid]) {
        [MBProgressHUD showError:YZMsg(@"RankVC_FollowMeError")];
        return;
    }
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=User.setAttent&uid=%@&touid=%@&token=%@&is_follow=%@",[Config getOwnID],toUid,[Config getOwnToken],@"1"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url   withBaseDomian:false andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        [hud hideAnimated:YES];
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
        }else{
            [MBProgressHUD showError:msg];
        }
        [strongSelf.view gy_popViewdismiss];
        [strongSelf dissmissVC];
    } fail:^(id fail) {
         STRONGSELF
         [hud hideAnimated:YES];
         if (strongSelf == nil) {
            return;
         }
         [strongSelf.view gy_popViewdismiss];
         [strongSelf dissmissVC];
    }];
}

#pragma mark - live toy
- (void)getLiveToyInfo:(LiveToyInfInfoType)type {
    RemoteControllerViewController *remoteController = [[RemoteControllerViewController alloc] init];
    remoteController.delegate = self;
    [remoteController addPlayModel:self.playDocModel];
    remoteController.view.frame = self.view.bounds;
    [remoteController setupViewsForType:type toyName:[self.v_remoteToy getTitle] orderName:[self.v_giveOrders getTitle]];
    [self.view addSubview:remoteController.view];
    [self addChildViewController:remoteController];
    self.remoteController = remoteController;
}

- (void)dismissRemoteController {
    [self.remoteController.view removeFromSuperview];
    [self.remoteController removeFromParentViewController];
    self.remoteController = nil;
}
#pragma mark - RemoteControllerViewControllerDelegate
- (void)remoteControllerViewControllerForGetInfo:(LiveToyInfInfoType)type completed:(Completed)completed {
    [socketDelegate getLiveToyInfo:type uid:self.playDocModel.zhuboID Handler:^(id arrays) {
        NSDictionary *info = [arrays firstObject];
        if (![info isKindOfClass:[NSDictionary class]]) {
            return;
        }
        completed(info);
    }];
}

- (void)remoteControllerViewControllerForDismiss {
    [self dismissRemoteController];
}

- (void)remoteControllerViewControllerForSendGiftInfo:(NSArray *)datas andLianFa:(NSString *)lianfa {
//    haohualiwu = lianfa;
    NSString *info = [[datas firstObject] valueForKey:@"gifttoken"];
//    level = [[datas firstObject] valueForKey:@"level"];
    LiveUser *users = [Config myProfile];
    users.level = level;
    [Config updateProfile:users];
}

- (void)remoteControllerViewControllerForRecharge {
    [self pushRecharge];
}

#pragma mark - remote control interface
- (RemoteInterfaceView*)remoteInterfaceView {
    if (_remoteInterfaceView != nil) {
        return _remoteInterfaceView;
    }
    RemoteInterfaceView *view = [[RemoteInterfaceView alloc] initWithArchir:false];
    view.delegate = self;
    view.frame = CGRectMake(_window_width, 0, _window_width, _window_height);
    [backScrollView addSubview:view];
    _remoteInterfaceView = view;
    return view;
}

#pragma mark - RemoteInterfaceViewDelegate
- (void)remoteInterfaceViewDelegateForShowPanel {
    if (!self.v_remoteToy.isHidden) {
        [self getLiveToyInfo:LiveToyInfoRemoteControllerForToy];
    } else if (!self.v_giveOrders.isHidden) {
        [self getLiveToyInfo:LiveToyInfoRemoteControllerForAnchorman];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSDictionary *infoDic = [self.otherIcons objectAtIndex:index];

    NSString *type = minstr([infoDic objectForKey:@"type"]);
    NSString *url = minstr(infoDic[@"jump_url"]);

    [self actionForLiveButton:type linkSt:url];
}

@end

