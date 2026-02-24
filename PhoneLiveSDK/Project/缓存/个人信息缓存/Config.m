//
//  Config.m
//  yunbaolive
//
//  Created by cat on 16/3/9.
//  Copyright © 2016年 cat. All rights reserved.
//

#import "Config.h"
NSString * const KAvatar = @"avatar";
NSString * const KBirthday = @"birthday";
NSString * const KCoin = @"coin";
NSString * const KID = @"ID";
NSString * const KSex = @"sex";
NSString * const KToken = @"token";
NSString * const KUser_nicename = @"user_nicename";
NSString * const KSignature = @"signature";
NSString * const KContact_info = @"contact_info";
NSString * const Kcity = @"city";
NSString * const Klevel = @"level";
NSString * const Kking_level = @"king_level";
NSString * const kavatar_thumb = @"avatar_thumb";
NSString * const Klogin_type = @"login_type";
NSString * const Klevel_anchor = @"level_anchor";
NSString * const Kchange_name_cost = @"change_name_cost";
NSString * const Kchat_level = @"chat_level";
NSString * const Kshow_level = @"show_level";
NSString * const Kchess_url = @"chess_url";
NSString * const Kgame_url = @"game_url";
NSString * const Kad_text = @"live_ad_text";
NSString * const Kad_url = @"live_ad_url";
NSString * const Kmobile = @"mobile";
NSString * const kuser_email = @"user_email";
NSString * const KisBindMobile = @"isBindMobile";
NSString * const KisZeroCharge = @"isZeroCharge";
NSString * const KliveShowChargeTime = @"liveShowChargeTime";
NSString * const Kbalance = @"balanceNumbers";
NSString * const KAPP_List = @"usercontactapplist";
NSString * const KregionId = @"region_id";
NSString * const Kregion = @"region";
NSString * const Kregion_curreny = @"region_curreny";
NSString * const Kregion_curreny_char = @"region_curreny_char";
NSString * const Kexchange_rate = @"exchange_rate";
NSString * const Kvippay_balance = @"vippay_balance";

NSString * const Kuser_login = @"user_login";

NSString * const vip_type = @"vip_type";
NSString * const liang = @"liang";
NSString * const KwithdrawInfo = @"withdrawInfo";
@implementation Config

#pragma mark - user profile

//保存靓号和vip
+(void)saveVipandliang:(NSDictionary *)subdic{
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:minstr([subdic valueForKey:@"vip_type"]?[subdic valueForKey:@"vip_type"]:@"") forKey:vip_type];
    [userDefaults setObject:minstr([subdic valueForKey:@"liang"]?[subdic valueForKey:@"liang"]:@"") forKey:liang];
     [userDefaults synchronize];
}
+(NSString *)getVip_type{
    
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *viptype = minstr([userDefults objectForKey:vip_type]);
    return viptype;
    
}
+(NSString *)getliang{
    
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *liangnum = minstr( [userDefults objectForKey:liang]);
    return liangnum;
}

+ (void)saveProfile:(LiveUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user.avatar forKey:KAvatar];
    [userDefaults setObject:user.level_anchor forKey:Klevel_anchor];
    [userDefaults setObject:user.avatar_thumb forKey:kavatar_thumb];
    [userDefaults setObject:user.coin forKey:KCoin];
    [userDefaults setObject:user.sex forKey:KSex];
    [userDefaults setObject:user.ID forKey:KID];
    [userDefaults setObject:user.token forKey:KToken];
    [userDefaults setObject:user.user_nicename forKey:KUser_nicename];
    [userDefaults setObject:user.signature forKey:KSignature];
    [userDefaults setObject:user.contact_info forKey:KContact_info];
    NSData *app_list = [NSKeyedArchiver archivedDataWithRootObject:user.app_list];
    [userDefaults setObject:app_list forKey:KAPP_List];
    [userDefaults setObject:user.login_type forKey:Klogin_type];
    [userDefaults setObject:user.birthday forKey:KBirthday];
    [userDefaults setObject:user.city forKey:Kcity];
    [userDefaults setObject:user.level forKey:Klevel];
    [userDefaults setObject:user.king_level forKey:Kking_level];
    [userDefaults setObject:user.change_name_cost forKey:Kchange_name_cost];
    [userDefaults setObject:user.chat_level forKey:Kchat_level];
    [userDefaults setObject:user.show_level forKey:Kshow_level];
    [userDefaults setObject:user.chess_url forKey:Kchess_url];
    [userDefaults setObject:user.game_url forKey:Kgame_url];
    [userDefaults setObject:user.mobile forKey:Kmobile];
    [userDefaults setObject:user.user_email forKey:kuser_email];
    [userDefaults setObject:user.region_id forKey:KregionId];
    [userDefaults setObject:user.region forKey:Kregion];
    [userDefaults setObject:user.region_curreny forKey:Kregion_curreny];
    [userDefaults setObject:user.region_curreny_char forKey:Kregion_curreny_char];
    [userDefaults setObject:user.exchange_rate forKey:Kexchange_rate];
    [userDefaults setObject:user.vippay_balance forKey:Kvippay_balance];
    [userDefaults setBool:user.isBindMobile forKey:KisBindMobile];
    [userDefaults setBool:user.isZeroCharge forKey:KisZeroCharge];
    [userDefaults setBool:user.liveShowChargeTime forKey:KliveShowChargeTime];
    [userDefaults setBool:user.balance forKey:Kbalance];
    if (user.withdrawInfo != nil) {
        NSData *withdrawInfoData = [NSKeyedArchiver archivedDataWithRootObject:user.withdrawInfo];
        [userDefaults setObject:withdrawInfoData forKey:KwithdrawInfo];
    }
    [userDefaults synchronize];
    
}
+ (void)updateProfile:(LiveUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(user.user_nicename != nil) [userDefaults setObject:user.user_nicename forKey:KUser_nicename];
    if(user.level_anchor != nil) [userDefaults setObject:user.level_anchor forKey:Klevel_anchor];
    if(user.signature!=nil) [userDefaults setObject:user.signature forKey:KSignature];
    if(user.contact_info!=nil) [userDefaults setObject:user.contact_info forKey:KContact_info];
    if(user.app_list!=nil) {
        NSData *app_list = [NSKeyedArchiver archivedDataWithRootObject:user.app_list];
        [userDefaults setObject:app_list forKey:KAPP_List];
    }
    if(user.avatar!=nil) [userDefaults setObject:user.avatar forKey:KAvatar];
    if(user.avatar_thumb!=nil) [userDefaults setObject:user.avatar_thumb forKey:kavatar_thumb];
    if(user.coin!=nil) [userDefaults setObject:user.coin forKey:KCoin];
    if(user.birthday!=nil) [userDefaults setObject:user.birthday forKey:KBirthday];
    if(user.login_type!=nil) [userDefaults setObject:user.login_type forKey:Klogin_type];
    if(user.city!=nil) [userDefaults setObject:user.city forKey:Kcity];
    if(user.sex!=nil) [userDefaults setObject:user.sex forKey:KSex];
    if(user.level!=nil) [userDefaults setObject:user.level forKey:Klevel];
    if(user.king_level!=nil) [userDefaults setObject:user.king_level forKey:Kking_level];
    if(user.change_name_cost!=nil) [userDefaults setObject:user.change_name_cost forKey:Kchange_name_cost];
    if(user.chat_level!=nil) [userDefaults setObject:user.chat_level forKey:Kchat_level];
    if(user.show_level!=nil) [userDefaults setObject:user.show_level forKey:Kshow_level];
    if(user.chess_url!=nil) [userDefaults setObject:user.chess_url forKey:Kchess_url];
    if(user.game_url!=nil) [userDefaults setObject:user.game_url forKey:Kgame_url];
    if(user.live_ad_text!=nil) [userDefaults setObject:user.live_ad_text forKey:Kad_text];
    if(user.live_ad_url!=nil) [userDefaults setObject:user.live_ad_url forKey:Kad_url];
    if(user.mobile!=nil) [userDefaults setObject:user.mobile forKey:Kmobile];
    if(user.user_login!=nil) [userDefaults setObject:user.user_login forKey:Kuser_login];
    if(user.user_email!=nil) [userDefaults setObject:user.user_email forKey:kuser_email];
    if(user.region!=nil) [userDefaults setObject:user.region_id forKey:KregionId];
    if(user.region!=nil) [userDefaults setObject:user.region forKey:Kregion];
    if(user.region_curreny!=nil) [userDefaults setObject:user.region_curreny forKey:Kregion_curreny];
    if(user.region_curreny_char!=nil) [userDefaults setObject:user.region_curreny_char forKey:Kregion_curreny_char];
    if(user.exchange_rate!=nil) [userDefaults setObject:user.exchange_rate forKey:Kexchange_rate];
    if (user.balance != nil) {
        [userDefaults setObject:user.balance forKey:Kbalance];
    }
    if(user.vippay_balance!=nil) [userDefaults setObject:user.vippay_balance forKey:Kvippay_balance];
   
    
    [userDefaults setBool:user.isBindMobile forKey:KisBindMobile];
    [userDefaults setBool:user.isZeroCharge forKey:KisZeroCharge];
    [userDefaults setInteger:user.liveShowChargeTime forKey:KliveShowChargeTime];
    if (user.withdrawInfo != nil) {
         NSData *withdrawInfoData = [NSKeyedArchiver archivedDataWithRootObject:user.withdrawInfo];
         [userDefaults setObject:withdrawInfoData forKey:KwithdrawInfo];
     }
    [userDefaults synchronize];
}

+ (void)clearProfile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * keyStr = [NSString stringWithFormat:@"%@%@",isShowGesturePwd,[Config getOwnID]];
    [userDefaults setBool:NO forKey:keyStr];
    [userDefaults setObject:nil forKey:Klevel_anchor];
    [userDefaults setObject:nil forKey:KAvatar];
    [userDefaults setObject:nil forKey:KBirthday];
    [userDefaults setObject:nil forKey:KCoin];
    [userDefaults setObject:nil forKey:KID];
    [userDefaults setObject:nil forKey:KSex];
    [userDefaults setObject:nil forKey:KToken];
    [userDefaults setObject:nil forKey:KUser_nicename];
    [userDefaults setObject:nil forKey:Klogin_type];
    [userDefaults setObject:nil forKey:KSignature];
    [userDefaults setObject:nil forKey:Kcity];
    [userDefaults setObject:nil forKey:Klevel];
    [userDefaults setObject:nil forKey:Kking_level];
    [userDefaults setObject:nil forKey:kavatar_thumb];
    [userDefaults setObject:nil forKey:vip_type];
    [userDefaults setObject:nil forKey:liang];
    [userDefaults setObject:nil forKey:Kchange_name_cost];
    [userDefaults setObject:nil forKey:Kshow_level];
    [userDefaults setObject:nil forKey:Kchat_level];
    [userDefaults setObject:nil forKey:Kchess_url];
    [userDefaults setObject:nil forKey:Kgame_url];
    [userDefaults setObject:nil forKey:Kmobile];
    [userDefaults setObject:nil forKey:Kuser_login];
    [userDefaults setObject:nil forKey:kuser_email];
    [userDefaults setObject:nil forKey:KregionId];
    [userDefaults setObject:nil forKey:Kregion];
    [userDefaults setObject:nil forKey:Kregion_curreny];
    [userDefaults setObject:nil forKey:Kregion_curreny_char];
    [userDefaults setObject:nil forKey:Kexchange_rate];
    [userDefaults setObject:nil forKey:Kvippay_balance];
    [userDefaults setBool:false forKey:KisBindMobile];
    [userDefaults setBool:false forKey:KisZeroCharge];
    [userDefaults setInteger:60 forKey:KliveShowChargeTime];
    [userDefaults setObject:nil forKey:@"notifacationOldTime"];
    [userDefaults setObject:nil forKey:Kbalance];
    [userDefaults removeObjectForKey:KwithdrawInfo];
    [userDefaults synchronize];
}

+ (LiveUser *)myProfile
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    LiveUser *user = [[LiveUser alloc] init];
    user.avatar = [userDefaults objectForKey: KAvatar];
    user.birthday = [userDefaults objectForKey: KBirthday];
    user.coin = [userDefaults objectForKey: KCoin];
    user.level_anchor = [userDefaults objectForKey: Klevel_anchor];
    user.ID = [userDefaults objectForKey: KID];
    user.sex = [userDefaults objectForKey: KSex];
    user.token = [userDefaults objectForKey: KToken];
    user.user_nicename = [userDefaults objectForKey: KUser_nicename];
    user.signature = [userDefaults objectForKey:KSignature];
    user.contact_info = [userDefaults objectForKey:KContact_info];
    NSData *appdata = [userDefaults objectForKey:KAPP_List];
    NSArray *apps = [NSKeyedUnarchiver unarchiveObjectWithData:appdata];
    user.app_list = apps;
    user.level = [userDefaults objectForKey:Klevel];
    user.king_level = [userDefaults objectForKey:Kking_level];
    user.city = [userDefaults objectForKey:Kcity];
    user.avatar_thumb = [userDefaults objectForKey:kavatar_thumb];
    user.login_type = [userDefaults objectForKey:Klogin_type];
    user.change_name_cost = [userDefaults objectForKey:Kchange_name_cost];
    user.chat_level = [userDefaults objectForKey:Kchat_level];
    user.show_level = [userDefaults objectForKey:Kshow_level];
    user.chess_url = [userDefaults objectForKey:Kchess_url];
    user.game_url = [userDefaults objectForKey:Kgame_url];
    user.mobile = [userDefaults objectForKey:Kmobile];
    user.user_login = [userDefaults objectForKey:Kuser_login];
    user.user_email = [userDefaults objectForKey:kuser_email];
    user.region_id = [userDefaults objectForKey:KregionId];
    user.region = [userDefaults objectForKey:Kregion];
    user.region_curreny = [userDefaults objectForKey:Kregion_curreny];
    user.region_curreny_char = [userDefaults objectForKey:Kregion_curreny_char];
    user.exchange_rate = [userDefaults objectForKey:Kexchange_rate];
    user.vippay_balance = [userDefaults objectForKey:Kvippay_balance];
    user.isBindMobile = [userDefaults boolForKey:KisBindMobile];
    user.isZeroCharge = [userDefaults boolForKey:KisZeroCharge];
    user.balance = [userDefaults objectForKey:Kbalance];
    user.liveShowChargeTime = (int )[userDefaults integerForKey:KliveShowChargeTime];
    NSData *withdrawInfoData = [userDefaults objectForKey:KwithdrawInfo];
    if (withdrawInfoData) {
        user.withdrawInfo = [NSKeyedUnarchiver unarchiveObjectWithData:withdrawInfoData];
    }
    return user;
}

+ (void)updateMoney:(NSString *)money {
    if (money && money.length > 0) {
        LiveUser *user = [Config myProfile];
        user.coin = money;
        [Config updateProfile:user];
    }
}

+(NSString *)getOwnID
{
//    return @"5446005";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* ID = [userDefaults objectForKey: KID];
    return ID;
}

+(NSString *)getOwnNicename
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* nicename = [userDefaults objectForKey: KUser_nicename];
    return nicename;
}

+(NSString *)getOwnToken
{
//    return @"3fa518f1b593ba02b49de92aa131e292";
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefults objectForKey:KToken];
    return token;
}

+(NSString *)getOwnSignature
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *signature = [userDefults objectForKey:KSignature];
    return signature;
}
+(NSString *)getOwnContactInfo
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *contactInfo = [userDefults objectForKey:KContact_info];
    return contactInfo;
}
+(NSArray *)getAppList
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSData *appData = [userDefults objectForKey:KAPP_List];
    NSArray *apps = [NSKeyedUnarchiver unarchiveObjectWithData:appData];
    return apps;
}
+(NSString *)getavatar
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *avatar = [NSString stringWithFormat:@"%@",[userDefults objectForKey:KAvatar]];
    return avatar;
}
+(NSString *)getavatarThumb
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *signature = [userDefults objectForKey:kavatar_thumb];
    return signature;
}
+(NSString *)getLevel
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *level = [userDefults objectForKey:Klevel];
    return level;
}
+(NSString *)getSex
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *sex = [userDefults objectForKey:KSex];
    return sex;
}
+(NSString *)getcoin
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *coin = [userDefults objectForKey:KCoin];
    return coin;
}
+(NSString *)level_anchor
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *level_anchors = [userDefults objectForKey:Klevel_anchor];
    return level_anchors;
}

+(NSString *)getChangeNameCost
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *change_name_cost = [userDefults objectForKey:Kchange_name_cost];
    return change_name_cost;
}
+(NSString *)getBalance
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefults objectForKey:Kbalance];
    return mobile;
}


+(NSString *)getChatLevel
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *chat_level = [userDefults objectForKey:Kchat_level];
    return chat_level;
}

+(NSString *)getShowLevel
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *show_level = [userDefults objectForKey:Kshow_level];
    return show_level;
}

+(NSString *)getChessUrl
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *chess_url = [userDefults objectForKey:Kchess_url];
    return chess_url;
}

+(NSString *)getGameUrl
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *game_url = [userDefults objectForKey:Kgame_url];
    return game_url;
}

+(NSString *)getADText
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *adText = [userDefults objectForKey:Kad_text];
    return adText;
}

+(NSString *)getADUrl
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *adurl = [userDefults objectForKey:Kad_url];
    return adurl;
}

+(NSString *)getMobile
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefults objectForKey:Kmobile];
    return mobile;
}
+(NSString *)getUser_login
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefults objectForKey:Kuser_login];
    return mobile;
}


+(NSString *)getUser_email
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *user_email = [userDefults objectForKey:kuser_email];
    return user_email;
}

+(BOOL)getIsBindMobile{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    BOOL ismobile = [userDefults boolForKey:KisBindMobile];
    return ismobile;
}

+ (NSDictionary *)getWithdrawInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *withdrawInfoData = [userDefaults objectForKey:KwithdrawInfo];

    if (withdrawInfoData) {
        NSError *error = nil;
        NSDictionary *withdrawInfo = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class]
                                                                       fromData:withdrawInfoData
                                                                          error:&error];
        if (error || ![withdrawInfo isKindOfClass:[NSDictionary class]]) {
            return @{};
        }
        return withdrawInfo;
    }

    return @{};
}


+(NSString *)canshu{
    return @"zh_cn";

//    if ([lagType isEqual:ZH_CN]) {
//
//    }
}

+(NSString *)getRegionId
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *regionId = [userDefults objectForKey:KregionId];
    return regionId;
}

+(NSString *)getRegion
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *game_url = [userDefults objectForKey:Kregion];
    return game_url;
}

+(NSString *)getRegionCurreny
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *adText = [userDefults objectForKey:Kregion_curreny];
    return adText;
}

+(NSString *)getRegionCurrenyChar
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *adurl = [userDefults objectForKey:Kregion_curreny_char];
    return adurl;
}

+(NSString *)getExchangeRate
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefults objectForKey:Kexchange_rate];
    return mobile;
}

+(NSString *)getVippayBalance
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *vippayBalance = [userDefults objectForKey:Kvippay_balance];
    return vippayBalance;
}

+ (NSArray *)getVideoTickets {
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSArray *items = [userDefults objectForKey:@"kVideoTicketKey"];
    return items;
}

+ (void)setVideoTickets:(NSArray *)items {
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    [userDefults setObject:items forKey:@"kVideoTicketKey"];
    [userDefults synchronize];
}

@end
