//
//  common.h
//  yunbaolive
//
//  Created by 王敏欣 on 2017/1/18.
//  Copyright © 2017年 cat. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "liveCommon.h"
#import "ChipsModel.h"
@interface common : NSObject
+ (void)saveProfile:(liveCommon *)common;
+ (void)clearProfile;
+(liveCommon *)myProfile;
+(NSString *)share_title;
+(NSString *)share_des;
+(NSString *)wx_siteurl;
+(NSString *)ipa_ver;
+(NSString *)app_ios;
+(NSString *)ios_shelves;
+(NSString *)name_coin;
+(NSString *)name_votes;
+(NSString *)enter_tip_level;


+(NSString *)maintain_switch; //维护开关
+(NSString *)maintain_tips;   //维护内容
+(NSString *)live_pri_switch; //私密房间开关
+(NSString *)live_cha_switch; //收费房间开关
+(NSString *)live_time_switch;//计时收费房间开关
+(NSArray  *)live_time_coin;  //收费阶梯
+(NSArray  *)live_type;       //房间类型
+(NSArray  *)share_type;  //分享类型
+(NSArray  *)liveclass;  //直播分类
+(NSArray  *)ad_list;  //精品推荐等广告
+(void)save_ad_list:(NSArray*)ad_list_Arry;


+(void)saveagorakitid:(NSString *)agorakitid;//声网ID
+(NSString  *)agorakitid;

+(NSString *)sprout_key;
+(NSString *)sprout_white;
+(NSString *)sprout_skin;
+(NSString *)sprout_saturated;
+(NSString *)sprout_pink;
+(NSString *)sprout_eye;
+(NSString *)sprout_face;
+(NSString *)jpush_sys_roomid;

+(NSString *)qiniu_domain;
+(NSString *)video_share_title;
+(NSString *)video_share_des;
#pragma mark - 后台审核开关
+(NSString *)getAuditSwitch;
#pragma mark - 腾讯空间
+(NSString *)getTximgfolder;
+(NSString *)getTxvideofolder;
#pragma mark - 存储类型（七牛-腾讯）
+(NSString *)cloudtype;


/**
 获取用户等级信息
 
 @param level 等级
 @return 用户等级信息字典
 */
+(NSDictionary *)getUserLevelMessage:(NSString *)level;

/**
 获取主播等级信息

 @param level 等级
 @return 主播等级信息字典
 */
+(NSDictionary *)getAnchorLevelMessage:(NSString *)level;

//保存游戏中心缓存
+(void)savegamecontroller:(NSArray *)arrays;
+(NSArray *)getgamec;

//保存游戏中心table高度
//+(void)savegamecontroller_table_height:(NSInteger)row height:(float)height;
//+(float)getgamecontroller_table_height:(NSInteger)row;

//自动兑换缓存
+(void)saveAutoExchange:(BOOL)bauto_exchange;
+(BOOL)getAutoExchange;
//筹码索引缓存
+(void)saveChipIndex:(NSInteger)chip_index;
+(NSInteger)getChipIndex;
//缓存筹码数
+(void)saveChipNums:(double)chip_num;
+(double)getChipNums;

//缓存筹码
+(void)saveLastChipModel:(ChipsModel*)chip_model;
+(ChipsModel*)getLastChipModel;

//缓存自定义筹码数(平台币)
+(void)saveCustomChipNum:(double)chip_num;
+(double)getCustomChipNum;
//缓存当前自定义筹码显示用
+(void)saveCustomChipStr:(NSString *)chip_str;
+(NSString *)getCustomChipStr;
+(void)saveTransferName:(NSString *)transfer_name;
+(NSString *)getTransferName;
//保存安装参数
+(void)saveInstallParams:(NSString *)installstr;
+(NSString *)getInstallParams;
//保存个人中心选项缓存
+(void)savepersoncontroller:(NSArray *)arrays;
+(NSArray *)getpersonc;
// 缓存彩票列表
+(void)savelotterycontroller:(NSArray *)arrays;
+(NSArray *)getlotteryc;
+(void)saveSystemMsg:(NSArray *)system_msg;
+(NSArray *)getSystemMsg;
// 保存注单
+(void)saveLotteryBetCart:(NSArray *)arrays;
+(NSArray *)getLotteryBetCart;
+(void)saveServiceUrl:(NSString *)urlstr;
+(void)getServiceUrl:(void (^)(NSString *kefuUrl))callback;
// 保存红包默认描述语
+(void)saveRedBagDes:(NSString *)redBagDes;
+(NSString *)getRedBagDes;
//名片价格
+(void)saveContactPrice:(NSArray *)arrays;
+(NSArray *)getContactPrice;

//主播公告设置
+(void)saveAnchorNoticeText:(NSString *)text;
+(NSString *)getAnchorNoticeText;
+(void)saveAnchorNoticeTime:(NSString *)time;
+(NSString *)getAnchorNoticeTime;
+(void)saveAnchorNoticeSwitch:(BOOL)isOpen;
+(BOOL)getAnchorNoticeSwitch;

//保存消息
+(void)saveSystemNewMsgs:(NSArray *)arrays;
+(NSArray *)getSystemNewMsgs;
///充值优惠
+(void)saveLivePopChargeInfo:(NSArray *)arrays;
+(NSArray *)getLivePopChargeInfo;

//快捷发言
+(void)saveQuickSay:(NSArray*)arrays;
+(NSArray*)getQuickSay;

//是否显示空降
+(void)setFuckActivity:(BOOL)isFucShow;
+(BOOL)isShowfuckactivity;

//静音   0有声音 1 只禁止背景音乐 2 禁止全部声音
+(void)soundControl:(int)soundStatus;
+(NSInteger)soundControlValue;

//游戏盾
+(void)closeGameShield:(BOOL)openGameShield;
+(BOOL)closeGameShield;


+(void)saveExtensionPage:(NSArray*)arrays;
+(NSArray*)getExtensionPage;

//搜索页、搜索历史
+(void)saveSearchRedcord:(NSArray *)array;
+(NSArray *)getSearchRedcord;
+(void)saveSearchRedcordExpand:(BOOL)isExpand;
+(BOOL)getSearchRedcordExpand;

//历史域名记录
+(void)saveAllDomians:(NSArray*)arrays;
+(NSArray*)getAllDomians;

// 首页推荐登入串行获取资料
+ (void)saveHomeRecommendData:(NSArray*)arrays;
+ (NSArray*)getHomeRecommendData;

//登录开关
+(void)saveLoginTypes:(NSArray *)loginTypes;
+(NSArray *)getLoginTypes;

@end
