#import <UIKit/UIKit.h>
#import "hotModel.h"
#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "S2C.pbobjc.h"
#import <Protobuf/GPBMessage.h>
#import "S2C.pbobjc.h"
#import <Protobuf/GPBMessage.h>

typedef void (^coastblock)(NSString *coast);//第一次进房间扣费通知

#pragma socket监听方法
@protocol socketDelegate <NSObject>
@optional
//房间被管理员关闭
-(void)roomCloseByAdmin;
//添加僵尸粉
-(void)addZombieByArray:(NSArray *)array;
//监听文字消息
-(void)messageListen:(NSDictionary *)chats;
//点亮消息
-(void)light:(NSDictionary *)chats;
//用户离开
-(void)UserLeave:(NSDictionary *)msg;
-(void)UserDisconnect:(disconnect *)msg;
//弹幕翻译
-(void)transalteMsg:(TranslateContent*)translateMsg;
//用户进入
-(void)UserAccess:(NSDictionary *)msg;
//通知直播关闭
-(void)LiveOff;
//点亮
-(void)sendLight;
//关注等系统消息
-(void)setSystemNot:(NSDictionary *)msg;
-(void)socketShowChatSystem:(NSDictionary *)msg;

//游戏消息
-(void)setGameNot:(kyGame *)msg;
//平台游戏
-(void)setPlatGameNot:(platGame *)msg;

//彩票投注消息
-(void)setLotteryBetNot:(LotteryBet *)msg;
//彩票中奖消息
-(void)setLotteryProfitNot:(LotteryProfit *)msg;
//彩票分红消息
-(void)setLotteryDividendNot:(LotteryDividend *)msg;
//同步下来的彩票消息
-(void)setLotteryInfo:(NSDictionary *)msg;
//彩票中奖飘屏
-(void)setLotteryBarrage:(LotteryBarrage *)msg;
//彩票中奖飘屏（当前用户）
-(void)setLotteryAward:(LotteryAward *)msg;

//显示开奖信息
-(void)addOpenAward:(NSDictionary *)msg;
//设置管理员
-(void)setAdmin:(setAdmin *)msg;
//送礼物
-(void)sendGift:(NSDictionary *)chats andLiansong:(NSString *)liansong andTotalCoin:(NSString *)votestotal andGiftInfo:(NSDictionary *)giftInfo;
//弹幕
-(void)SendBarrage:(SendBarrage *)msg;
//StartEndLive
-(void)StartEndLive;
//踢人
-(void)KickUser:(NSDictionary *)chats;
-(void)kickOK;
-(void)socketKick;
//红包
-(void)sendRed:(NSDictionary *)msg;
-(void)reloadChongzhi:(NSString *)coin;//刷新钻石数量
-(void)addLianMaiCoin;//更新主播收益
-(void)xiamai;//下麦
-(void)startConnectvideo;//主播同意连麦
-(void)confuseConnectvideo;//主播拒绝连麦
-(void)hostisbusy;//主播正忙碌（连麦）
-(void)hostout;//主播未响应（连麦）
-(void)changeLive:(NSString *)type_val changetype:(NSString *)type;//切换房间类型

-(void)addvotesdelegate:(NSString *)votes;//增加yingpiao

-(void)changeBank:(NSDictionary *)bankdic;//切换庄家

//准备开始炸金花游戏
-(void)prepGameandMethod:(NSString *)method andMsgtype:(NSString *)msgtype;
-(void)takePoker:(NSString *)gameid Method:(NSString *)method andMsgtype:(NSString *)msgtype;//开始发牌
-(void)stopGame ;
-(void)getResult:(NSArray *)array;//炸金花开奖结果
//开始倒数计时
-(void)startGame:(NSString *)time andGameID:(NSString *)gameid;
-(void)getCoin:(NSString *)type andMoney:(NSString *)money;//更新投注金额
//转盘游戏
-(void)prepRotationGame;//准备开始游戏
-(void)startRotationGame;//开始游戏，开始倒数计时
-(void)stopRotationGame;
-(void)startRotationGame:(NSString *)time andGameID:(NSString *)gameid;
-(void)getRotationResult:(NSArray *)array;//开奖结果
-(void)getRotationCoin:(NSString *)type andMoney:(NSString *)money;//更新投注金额
//二八贝游戏
-(void)shellprepGameandMethod:(NSString *)method andMsgtype:(NSString *)msgtype;
-(void)shelltakePoker:(NSString *)gameid Method:(NSString *)method andMsgtype:(NSString *)msgtype;//开始发牌
-(void)shellstopGame ;
-(void)shellgetResult:(NSArray *)array;//炸金花开奖结果
//开始倒数计时
-(void)shellstartGame:(NSString *)time andGameID:(NSString *)gameid;
-(void)shellgetCoin:(NSString *)type andMoney:(NSString *)money;//更新投注金额
//上庄操作
-(void)getzhuangjianewmessagedelegatem:(NSDictionary *)subdic;
//-(void)getjingpaimessagedelegate:(NSDictionary *)dic;//获得竞拍信息s
-(void)getnewjingpaipersonmessage:(NSDictionary *)dic;//获取新的竞拍信息
-(void)jingpaifailed;//竞拍失败
-(void)jingpaisuccess:(NSDictionary *)dic;//竞拍成功
#pragma mark ================ 连麦 ===============
- (void)playLinkUserUrl:(NSString *)playurl andUid:(NSString *)userid;
- (void)enabledlianmaibtn;
#pragma mark ================ 守护 ===============
- (void)updateGuardMsg:(NSDictionary *)dic;
#pragma mark ================ 发红包 ===============
- (void)showRedbag:(SendRed *)dic;
#pragma mark ================ 主播与主播连麦 ===============
- (void)anchor_agreeLink:(NSDictionary *)dic;
- (void)anchor_stopLink:(NSDictionary *)dic;
#pragma mark ================ PK ===============
- (void)showPKView:(NSDictionary *)dic;
- (void)showPKButton;
- (void)showPKResult:(LivePK *)dic;
- (void)changePkProgressViewValue:(NSDictionary *)dic;

-(void)timeDelayUpdate:(long long)timeDelayNum;

-(void)giveVideoTicketMessage:(GiveVideoTicket *)msg;

#pragma mark ================ 消息通知 ===============
-(void)giveAppTopNotice:(AppTopNotice *)msg;

@end
@interface socketMovieplay : NSObject<UIAlertViewDelegate>
{
    //环信接受私信
    int unRead;//未读消息
    int sendMessage;
    UILabel *label;
    //socket监听
    LiveUser *users;
    BOOL isReConSocket;
    BOOL isbusy;//主播是否忙碌（连麦）
    NSString *type_val;
    int justonce;
    //主播名片
    NSString *cardString;
    SocketManager *managerSocket;
}
@property(nonatomic,copy)NSString *livetype;
@property(weak)id<socketDelegate>socketDelegate;
//@property(nonatomic,strong)SocketManager *ChatSocketManager;
@property(nonatomic,strong)SocketIOClient *ChatSocket;
@property(nonatomic,strong)hotModel *playDocModel;
@property(nonatomic,copy)NSString *chatserver;
@property(nonatomic,copy)NSString *shut_time;//禁言时间
@property(nonatomic,assign)BOOL isCloseAdv; //是否关闭推送广告

//-(void)addNodeListen:(hotModel *)model;//添加cosket监听
//发红包
-(void)sendRed:(NSString *)money andNodejsInfo:(NSMutableArray *)nodejsInfo;//发红包
//点亮
-(void)starlight:(NSString *)level :(NSNumber *)num andUsertype:(NSString *)usertype andGuardType:(NSString *)guardType;;
//关注主播
-(void)attentionLive;
//发送消息
-(void)sendmessage:(NSString *)text andLevel:(NSString *)level andUsertype:(NSString *)usertype andGuardType:(NSString *)guardType;
//送礼物
-(void)sendGift:(NSString *)level andINfo:(NSString *)info andlianfa:(NSString *)lianfa;
//禁言
-(void)shutUp:(NSString *)name andID:(NSString *)ID;
//踢人
-(void)kickuser:(NSString *)name andID:(NSString *)ID;
-(void)sendContactInfo:(NSString *)contactInfo andID:(NSString *)uid;
//弹幕
-(void)sendBarrage:(NSString *)level andmessage:(NSString *)test;
//点亮
-(void)starlight;
//僵尸粉
-(void)getZombie;
//socket停止
-(void)socketStop;
typedef void (^getResults)(id arrays);
- (void)setnodejszhuboModel:(hotModel *)zhuboModel Handler:(getResults)handler andlivetype:(NSString *)livetypes;
-(void)sendBarrageID:(NSString *)ID andTEst:(NSString *)content andModel:(hotModel *)zhuboModel success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack;//发送弹幕
-(void)superStopRoom;

//-(instancetype)initWithcoastblock:(coastblock)coast;//扣费房间第一次进入扣费

//扣费
-(void)addvotes:(NSString *)votes isfirst:(NSString *)isfirst;
-(void)addvotesenterroom:(NSString *)votes;
//其他压住
-(void)stakePoke:(NSString *)type andMoney:(NSString *)money andMethod:(NSString *)method andMsgtype:(NSString *)msgtype;
//转盘压住
-(void)stakeRotationPoke:(NSString *)type andMoney:(NSString *)money;
//上庄
-(void)getzhuangjianewmessagem:(NSDictionary *)subdic;
//弹幕翻译
-(void)sendTranslateMsg:(NSString*)msgContent;
//竞拍
-(void)sendmyjingpaimessage:(NSString *)money;//我点击竞拍广播竞拍消息
#pragma mark ================ 连麦 ===============
-(void)connectvideoToHost;
-(void)sendSmallURL:(NSString *)playUrl andID:(NSString *)userID;
-(void)closeConnect;
#pragma mark ================ 守护 ===============
- (void)buyGuardSuccess:(NSDictionary *)dic;
#pragma mark ================ 红包 ===============
- (void)fahongbaola;
//监听切换房间
-(void)changeMtype:(NSString *)type money:(NSString *)money;
-(void)sendSyncLotteryCMD:(NSString *)lotteryType;
-(void)sendSyncOpenAwardCMD:(NSString *)lotteryType;
-(void)addNodeListen:(hotModel *)model isFirstConnect:(BOOL)isFirst serverUrl:(NSString*)serverUrl;
#pragma mark - 主播指令跳蛋指令
typedef NS_ENUM(NSUInteger, LiveToyInfInfoType) {
    LiveToyInfoRemoteControllerForAnchorman, // 主播指令
    LiveToyInfoRemoteControllerForToy,   // 跳蛋指令
};
- (void)getLiveToyInfo:(LiveToyInfInfoType)type uid:(NSString*)uid Handler:(getResults)handler;
@end
