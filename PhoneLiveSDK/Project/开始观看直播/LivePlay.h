#import <UIKit/UIKit.h>


#import "chatModel.h"
#import "NSString+StringSize.h"
#import "listModel.h"
#import "UIImageView+Util.h"
#import "listCell.h"
#import "UIImageView+WebCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "ZFModalTransitionAnimator.h"
#import "otherUserMsgVC.h"
#import "PayViewController.h"
#import "setViewM.h"

#import "catSwitch.h"
#import "GrounderSuperView.h"
//新礼物
#import "PresentView.h"
#import "GiftModel.h"
#import "AnimOperation.h"
#import "AnimOperationManager.h"
#import "GSPChatMessage.h"
#import "socketLivePlay.h"
#import "liwuview.h"
#import "continueGift.h"
#import "upmessageInfo.h"
#import "expensiveGiftV.h"//礼物
#import "ListCollection.h"//用户列表

#import "userLoginAnimation.h"//进场动画
#import "nuserLoginAnimation.h"//进场动画
#import "centerADAnimation.h"//滚动广告动画
#import "TouchSuperView.h"

#import "lastview.h"
//#import "Hourglass.h"
#import "webH5.h"
#import "viplogin.h"//用户进场动画
#import "JMListen.h"
#import "chatMsgCell.h"
#import "shouhuView.h"
#import "guardShowView.h"
//#import "JCHATConversationViewController.h"
#import "redBagView.h"
#import "redListView.h"
#import "MsgSysVC.h"
#import <NodeMediaClient/NodeMediaClient.h>

#import "RemoteControllerViewController.h" //遙控指令選項
#import "RemoteInterfaceView.h" //遙控指令介面
#import "LiveStreamViewCell.h"
@protocol dianjishijian <NSObject>
@optional
-(void)duihaoHidden;
@end



@interface moviePlay : JMListen
{
    viplogin *vipanimation;//坐骑进场动画
    userLoginAnimation *useraimation;//进场动画(横条飘进)
    nuserLoginAnimation *nuseraimation;//chat_level等级以下普通用户进场
    centerADAnimation *adAnimation;//滚动广告动画
    UIImageView *buttomimageviews;//背景模糊(一开始进入直播间未加载到视频的时候显示)
    ListCollection *listView;//用户列表
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
//    JCHATConversationViewController *chatsmall;//聊天

    UIView *chatsmallzhezhao;
    setViewM *setFrontV;//页面UI
    upmessageInfo *userView;//用户列表弹窗
    liwuview *giftview;//礼物界面
    UIView *videoView;//视频播放view
    ////////////////////////////////////////////////////////////////////////////
    UIScrollView *backScrollView;//
    NSLayoutConstraint *backScrollViewContentSizeWidthConstraint;
    UIScrollView *buttomscrollview;//上下滑屏切换
    UIView *buttomviews;//用来左右滑动;
    UIImageView *buttomimageview;//滑动显示下一个或上一个图片
    BOOL fangKeng;//防坑 ，第一次进房间不滑动
    int scrollvieweight;//判断滑动距离是否够切换
    ////////////////////////////////////////////////////////////////////////////
    socketMovieplay *socketDelegate;//socket监听
    ////////////////////////////////////////////////////////////////////////////
    UIImageView *starImage; //点亮图片
    NSNumber *heartNum;
    int starisok;
    UITapGestureRecognizer *starTap;
    BOOL firstStar;// 第一次点亮
    ////////////////////////////////////////////////////////////////////////////
    UIButton *pushBTN;
    UITextField *keyField;//聊天输入框
    UIView *toolBar;
    catSwitch *cs;//弹幕按钮
    UIButton *keyBTN;//点击弹出键盘
    ////////////////////////////////////////////////////////////////////////////
    LiveUser *myUser;//缓存个人信息
    CGFloat listcollectionviewx;//用户列表的x
    NSString *haohualiwu;//判断豪华礼物
    long long userCount;//用户数量
    CGFloat www;
    NSString *titleColor;//判断 回复颜色
    NSString *level;
    
    BOOL    _canScrollToBottom;//判断tableview可不可以滑动
    BOOL    _bDraggingScroll;
    NSInteger _scrollToBottomCount;//前几次自动滑动
    BOOL    _canScrollToBottomUser;//判断用户tableview可不可以滑动
    BOOL    _bDraggingScrollUser; //用户tableview
    NSInteger _scrollToBottomCountUser;//前几次用户消息自动滑动
    UIPanGestureRecognizer *panGestureRecognizer;
    UIView* _winRtcView;
    int userlist_time;//定时刷新用户列表时间
    BOOL isRegistLianMai;//判断连麦注册成功
    BOOL isRotationGame;//判断游戏
    BOOL isZhajinhuaGame;
    UIView *liansongliwubottomview;
    
    lastview *lastv;
    
    int coasttime;//扣费计时
    NSDictionary *zhuangstartdic;//庄家初始化信息
    BOOL giftViewShow;//是否显示礼物view
    UIPanGestureRecognizer *videopan;//视频拖拽手势
    UITapGestureRecognizer *videotap;
//    Hourglass *gifhour;//竞拍
    
    int isshow;//连麦相关
    BOOL ksynotconnected;
    BOOL ksyclosed;
    
    
    
    NSTimer *starMove;//点亮计时器
    NSTimer *listTimer;//定时刷新用户列表
    NSTimer *lianmaitimer;//主播同意连麦后超时响应时间
    NSTimer *timecoast;//计时扣费

    NSString *_myplayurl;
    NSString *usertype;
    NSString *votesTatal;
    shouhuView *guardView;
    guardShowView *gShowView;
    NSDictionary *guardInfo;
    redBagView *redBview;
    UIButton *redBagBtn;
    redListView *redList;
    UIButton *sendBagBtn;
    MsgSysVC *sysView;
    NSDictionary *roomLotteryInfo;
//    NSString *lianmaiLevel;

}
@property (strong,nonatomic) NodePlayer *nplayer;
@property(nonatomic,strong)NSString *livetype;
@property(nonatomic,strong)NSString *type_val;
@property(nonatomic,strong)NSString *mtype_val;
@property(nonatomic,strong)GrounderSuperView *danmuView;//弹幕
@property(nonatomic,copy)NSString *tanChuangID;//弹窗用户的id
@property(nonatomic,strong)NSString *danmuprice;//弹幕价格
@property(nonatomic,strong)UITableView *tableViewMsg;
@property(nonatomic,strong)UITableView *tableViewUserMsg; // 用户聊天消息
@property(nonatomic,strong)NSMutableArray *listArray;
@property(nonatomic,copy)NSString *content;//聊天内容
@property (strong, nonatomic) NSURL *url;
//@property (strong, nonatomic) KSYMoviePlayerController *player;

@property(nonatomic,strong)NSArray *models;
@property(nonatomic,strong)dispatch_queue_t quenMessageReceive;
@property(nonatomic,strong)UIButton *returnCancle;//退出
@property(nonatomic,strong)UIButton *messageBTN;//消息
@property(nonatomic,strong)UIButton *fenxiangBTN;//分享
@property(nonatomic,strong)UIButton *liwuBTN;//礼物
@property(nonatomic,strong)UIButton *gameBTN;//游戏
@property(nonatomic,strong)UIButton *closeAdBTN;//关闭广告
//@property(nonatomic,strong)UIButton *lotteryBTN;//彩票

@property(nonatomic,assign)NSInteger chat_free_times; //免费发言次数
@property(nonatomic,assign)NSInteger chat_total_free_times; //可免费发言次数

@property(nonatomic,assign)BOOL isJustPush; 

//@property(nonatomic,strong)NSMutableDictionary *modelCache;
/*
 *
 **总的主播数组
 */
//@property(nonatomic,strong)NSArray *scrollarray;
/*
 *
 **获取第几个主播
 */
@property(nonatomic,assign)int scrollindex;
@property(nonatomic,strong)NSString *isJpush;
@property(nonatomic,strong)hotModel *playDocModel;
@property(nonatomic,assign)int hiddenN;
@property(nonatomic,assign)id<dianjishijian>liwuDelegate;

@property(nonatomic,assign)BOOL isChckedLive;
@property (nonatomic ,assign) int isPreviewSecond;        //预览秒数
@property(nonatomic, assign) LiveStreamViewCell* fromCell;

-(void)releaseDatas;

-(void)releaseAll;

+(void)pushRecharge;

- (void)changeRoom:(hotModel *)infoModel;
- (void)onPlayNodeVideoPlayer:(NodePlayer*)nPlayerC audioEnable:(BOOL)audioEnable;
- (void)setAudioEnable:(BOOL)audioEnable;

@end
