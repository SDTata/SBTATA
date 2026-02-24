
#import <Foundation/Foundation.h>

//added in v2.7.0 用于分享统计接口中的分享平台（sharePlatform）
typedef NSString *CorgiGame_SharePlatform NS_STRING_ENUM;

/**
 * 微信好友
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_WechatSession;
/**
 * 微信朋友圈
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_WechatTimeline;
/**
 * 微信收藏
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_WechatFavorite;
/**
 * 企业微信，国际版WeCom，原名WechatWork
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_WeCom;
/**
 * QQ好友
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_QQ;
/**
 * QQ空间
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Qzone;
/**
 * 新浪微博
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Sina;
/**
 * 腾讯微博
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_TencentWb;
/**
 * 腾讯Tim
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_TencentTim;
/**
 * 支付宝好友
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_APSession;
/**
 * 钉钉
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_DingDing;
/**
 * 抖音国内版
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_DouYin;
/**
 * 抖音海外版（TikTok）
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_TikTok;
/**
 * 快手
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Kuaishou;
/**
 * 快手国际版（Kwai）
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Kwai;
/**
 * 西瓜视频
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_WatermelonVideo;
/**
 * 西瓜视频国际版（BuzzVideo）
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_BuzzVideo;
/**
 * 人人网
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Renren;
/**
 * 豆瓣
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Douban;
/**
 * 邮箱
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Email;
/**
 * 短信
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Sms;
/**
 * Facebook
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Facebook;
/**
 * Facebook Messenger
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_FacebookMessenger;
/**
 * Facebook账户系统
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_FacebookAccount;
/**
 * 推特（Twitter）
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Twitter;
/**
 * Instragram
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Instagram;
/**
 * Whatsapp
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Whatsapp;
/**
 * youtube
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Youtube;
/**
 * SnapChat
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_SnapChat;

/**
 * 易信好友
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_YXSession;
/**
 * 易信朋友圈
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_YXTimeline;
/**
 * 易信收藏夹
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_YXFavorite;
/**
 * 明道
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_MingDao;
/**
 * 来往好友
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_LWSession;
/**
 * 来往朋友圈
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_LWTimeline;
/**
 * 分享到Line
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Line;
/**
 * 领英
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Linkedin;
/**
 * Reddit
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Reddit;
/**
 * Tumblr
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Tumblr;
/**
 * Pinterest
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Pinterest;
/**
 * Kakao Talk
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_KakaoTalk;
/**
 * Kakao story
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_KakaoStory;
/**
 * Flickr
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Flickr;
/**
 * 有道云笔记
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_YouDaoNote;
/**
 * 印象笔记
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_YinxiangNote;
/**
 * 印象笔记国际版
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_EverNote;
/**
 * google+
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_googlePlus;
/**
 *  Pocket
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Pocket;
/**
 *  dropbox
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_dropbox;
/**
 *  vkontakte
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_vkontakte;
/**
 * Instapaper
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Instapaper;
/**
 * Oasis
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Oasis;
/**
 * Apple
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_AppleAccount;
/**
 * copy
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Copy;
/**
 *  其它平台
 */
extern CorgiGame_SharePlatform const CorgiGame_SharePlatform_Other;

//added in v2.7.0 用于安装参数返回时的超时判断
typedef NS_ENUM(NSUInteger,CorgiGame_Codes) {
    OPCode_normal = 0,//初始化结束，并返回参数，自然安装下参数为空
    OPCode_timeout = 1,//获取参数超时，可在合适时机再去获取（可设置全局标识）
};

extern NSString *const app_Idfa_Id;
extern NSString *const app_ASA_Token;
extern NSString *const app_ASA_isDev;//added in v2.5.6

@interface CorgiGameData : NSObject<NSCopying>

- (instancetype)initWithData:(NSDictionary *)data
                 channelCode:(NSString *)channelCode;
                

@property (nonatomic,strong) NSDictionary *data;//动态参数
@property (nonatomic,copy) NSString *channelCode;//渠道编号
@property (nonatomic,assign) CorgiGame_Codes opCode;// (added in v2.7.0)

@end
