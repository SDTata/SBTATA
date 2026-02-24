

#import <Foundation/Foundation.h>
#import "LiveUser.h"

static NSString *isShowGesturePwd = @"isShowGesturePwd";

@interface Config : NSObject


+ (void)saveProfile:(LiveUser *)user;
+ (void)updateProfile:(LiveUser *)user;
+ (void)clearProfile;
+ (LiveUser *)myProfile;
+(NSString *)getOwnID;
+(NSString *)getOwnNicename;
+(NSString *)getOwnToken;
+(NSString *)getOwnContactInfo;
+(NSArray *)getAppList;
+(NSString *)getOwnSignature;
+(NSString *)getavatar;
+(NSString *)getavatarThumb;
+(NSString *)getLevel;
+(NSString *)getSex;
+(NSString *)getcoin;
+(NSString *)level_anchor;//主播等级
+(NSString *)getChangeNameCost;
+(NSString *)getChatLevel; //发言等级
+(NSString *)getShowLevel; //进房间入屏提示等级
+(NSString *)getChessUrl;
+(NSString *)getGameUrl;
+(NSString *)getADText;
+(NSString *)getADUrl;
+(NSString *)getBalance;
+(NSString *)getMobile;
+(NSString *)getUser_login;
+(BOOL)getIsBindMobile;
+(NSString *)getRegionId;
+(NSString *)getRegion;
+(NSString *)getRegionCurreny;
+(NSString *)getRegionCurrenyChar;
+(NSString *)getExchangeRate;
+(NSString *)getVippayBalance;
+(NSString *)getUser_email;
+(NSDictionary *)getWithdrawInfo;
+(void)saveVipandliang:(NSDictionary *)subdic;//保存靓号和vip
+(NSString *)getVip_type;
+(NSString *)getliang;

+(NSString *)canshu;

+ (void)updateMoney:(NSString *)money;

+ (NSArray *)getVideoTickets;

+ (void)setVideoTickets:(NSArray *)items;

@end
