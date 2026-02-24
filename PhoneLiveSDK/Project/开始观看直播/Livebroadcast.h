//
//  ViewController.h
//  KSYGPUStreamerVC
//
//  Created by cat
//  Copyright (c) 2016 cat. All rights reserved.
//
//音乐界面
#import "musicView.h"
#import "Utils.h"

//歌词
#import "YLYMusicLRC.h"
#import "YLYOKLRCView.h"
//管理员
#import "adminLists.h"
#import "chatModel.h"
#import "otherUserMsgVC.h"
#import "ZFModalTransitionAnimator.h"
/*******  分享 头文件结束 *********/
#import "GrounderSuperView.h"
#import "catSwitch.h"
#import "expensiveGiftV.h"
#import "continueGift.h"
#import "socketLive.h"
#import "ListCollection.h"
#import "upmessageInfo.h"
#import "userLoginAnimation.h"
#import "nuserLoginAnimation.h"

//#import "WPFRotateView.h"
//推流
#import <AVFoundation/AVFoundation.h>
//#import "KSYMoviePlayerController.h"

#import "coastselectview.h"

#import "PayViewController.h"
#import "viplogin.h"
#import "bottombuttonv.h"
#import "JMListen.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Foundation/Foundation.h>
//#import <ShareSDK/ShareSDK.h>
#import "chatMsgCell.h"
#import "fenXiangView.h"
#import "webH5.h"
#import "guardShowView.h"
//#import "JCHATConversationViewController.h"
#import "redBagView.h"
#import "redListView.h"
#import "MsgSysVC.h"
#import <NodeMediaClient/NodeMediaClient.h>
#import "SwitchLotteryViewController.h"
#import "OBSViewController.h"

@interface Livebroadcast : JMListen
{
    viplogin *vipanimation;//坐骑
    userLoginAnimation *useraimation;//用户进入动画
    nuserLoginAnimation *nuseraimation;//用户进入动画
    
    upmessageInfo *userView;//用户列表弹窗

    socketLive *socketL;//socket
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
  
//    JCHATConversationViewController *chatsmall;//聊天
    NSString *urlStrtimestring;
    
    UIButton *lotteryBTN;//彩票
    UIButton *pushBTN;
    UIButton *buttonmusic;//音乐播放暂停
    NSString *haohualiwu;//判断豪华礼物
    NSString *titleColor;
    
    YLYOKLRCView *lrcView;
    bottombuttonv *bottombtnV;//更多
    //管理员列表
    adminLists *adminlist;
    UIViewController *zhezhaoList;
    UITextField *keyField;//聊天&输入框
    UIView *toolBar;
    UIView *frontView;//信息底部透明页面
    
    UILabel *onlineLabel;//在线人数
    
    UIButton *guardBtn;//守护b按钮
    CGFloat guardWidth;
    
    UIButton *topTodayButton; //实时榜单
    
    //信息UI
    UILabel *yingpiaoLabel;
    
    UIButton *closeLiveBtn;
    UIButton *keyBTN;
    CGFloat www;
    UIButton *moreBTN;//更多
    
    catSwitch *cs;//发送弹幕按钮
    //开始动画倒计时123
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UIView *backView;
    //点亮图片
    UIImageView *starImage;
    CGFloat starX;
    CGFloat  starY;
    
    UIView *leftView;
    //音乐
    NSString *muaicPath;//歌曲路径
    NSString *lrcPath;//歌词路径
    UIView *musicV;//音乐界面
    //弹幕
    
    GrounderSuperView *danmuview;//弹幕
    
    
    ListCollection *listView;//用户列表
    AFNetworkReachabilityManager *managerAFH;//判断网络状态
    
    
    
   
//    WPFRotateView *rotationV;
    
    UIView *liansongliwubottomview;//连送礼物底部view
    
    coastselectview * coastview;//价格选择列表
    NSString *coastmoney;//收费价格
    UIView *pushbottomV;
    UIView *videobottom;
    
    UIPanGestureRecognizer *videopan;//视频拖拽手势
    UITapGestureRecognizer *videotap;
    
    int _count;
    int backTime;//返回后台时间60s
    int lianmaitime;//连麦的请求时间10s
    int userlist_time;//定时刷新用户列表间隔
    long long userCount;//用户数量
    
    BOOL isclosenetwork;//判断断网回后台
    BOOL ismessgaeshow;//限制直有发送消息得时候键盘弹出
    BOOL _canScrollToBottom;
    BOOL _bDraggingScroll;
    NSInteger _scrollToBottomCount;
    BOOL    _canScrollToBottomUser;//判断用户tableview可不可以滑动
    BOOL    _bDraggingScrollUser; //用户tableview
    NSInteger _scrollToBottomCountUser;//前几次用户消息自动滑动
    BOOL _isPlayLrcing;//滚动歌词状态
    
    NSTimer *listTimer;//定时刷新用户列表
    NSTimer *backGroundTimer;//检测后台时间（超过60秒执行断流操作）
    NSTimer *lrcTimer;;//音乐
    
  
  
    fenXiangView *fenxiangV;//分享view
    guardShowView *gShowView;
 

    redBagView *redBview;
    UIButton *redBagBtn;
    redListView *redList;

    BOOL isAnchorLink;
    MsgSysVC *sysView;
    
    
    NSTimer *hartTimer;

    NSDictionary *roomLotteryInfo;
}
@property(nonatomic,assign)BOOL canFee;//是否开启计时收费
@property(nonatomic,strong)NSString *shut_time;//禁言时间
@property(nonatomic,strong)NSString *namesssssssss;
@property(nonatomic,assign)int type;//直播类型
@property(nonatomic,strong)NSString *type_val;//类型值
@property(nonatomic,strong)NSString *auction_switch;//竞拍开关　
@property(nonatomic,strong)UIImage *uploadImage;
@property(nonatomic,strong)hotModel *roomModel;//开始直播信息
@property(nonatomic,strong)NSArray *game_switch;//游戏开关
@property(nonatomic,strong)NSDictionary *zhuangDic;//上庄信息
@property(nonatomic,copy)NSString *isgameroom;//判断隐藏游戏图标
@property (nonatomic,assign)BOOL isRedayCloseRoom;;
@property(nonatomic,strong)dispatch_queue_t quenMessageReceive;
//@property KSYGPUStreamerKit * gpuStreamers;
@property (strong, nonatomic) NodePublisher *np;
//推流
@property (strong , nonatomic)AVAudioPlayer *player;


@property(nonatomic,copy)NSString *socketUrl;
@property(nonatomic,copy)NSString *danmuPrice;
//danmuprice
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@property(nonatomic,copy)NSString *tanChuangID;//弹窗用户的id
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UITableView *userTableView;
@property(nonatomic,strong)NSString *tanchuangName;
@property (strong , nonatomic)NSMutableArray *lrcList;//歌词
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)NSString *voteNums;//收获数
@property(nonatomic,copy)NSString *method;//游戏
@property(nonatomic,copy)NSString *msgtype;//游戏


// 推流地址 完整的URL
@property(nonatomic,strong) NSURL * hostURL;

//@property(nonatomic,strong)hotModel *playDocModel;
@end

