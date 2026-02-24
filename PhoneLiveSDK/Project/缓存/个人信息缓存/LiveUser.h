//
//  LiveUser.h
//  yunbaolive
//
//  Created by cat on 16/3/9.
//  Copyright © 2016年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LiveAppItem : NSObject<NSCoding>
@property (nonatomic, strong)NSString *app_logo;
@property (nonatomic, strong)NSString *app_name;
@property (nonatomic, strong)NSString *id;
@property (nonatomic, strong)NSString *info;
@end

@interface LiveUser : NSObject
@property (nonatomic, strong)NSString *avatar;
@property (nonatomic, strong)NSString *birthday;
@property (nonatomic, strong)NSString *coin;
@property (nonatomic, strong)NSString *balance;
@property (nonatomic, strong)NSString *ID;
@property (nonatomic, strong)NSString *sex;
@property (nonatomic, strong)NSString *token;
@property (nonatomic, strong)NSString *user_nicename;
@property (nonatomic, strong)NSString *signature;
@property (nonatomic, strong)NSString *contact_info;
@property (nonatomic, strong)NSArray <LiveAppItem *>*app_list;
@property (nonatomic, strong)NSString *city;
@property (nonatomic, strong)NSString *level;
@property (nonatomic, strong)NSString *level_anchor;
@property (nonatomic, strong)NSString *king_level;
@property (nonatomic, strong)NSString *avatar_thumb;
@property (nonatomic, strong)NSString *login_type;
@property (nonatomic, strong)NSString *change_name_cost;
@property (nonatomic, strong)NSString *chat_level;
@property (nonatomic, strong)NSString *show_level;
@property (nonatomic, strong)NSString *chess_url;
@property (nonatomic, strong)NSString *game_url;
@property (nonatomic, strong)NSString *live_ad_text;
@property (nonatomic, strong)NSString *live_ad_url;
@property (nonatomic, strong)NSString *mobile;
@property (nonatomic, strong)NSString *user_email;
@property (nonatomic, strong)NSString *user_login;
@property (nonatomic, strong) NSDictionary *withdrawInfo;
@property (nonatomic, assign)BOOL isBindMobile;
@property (nonatomic, assign)BOOL isZeroCharge;
@property (nonatomic, assign)int liveShowChargeTime;
/** id */
@property (nonatomic, copy) NSString *region_id;
/** 地区 */
@property (nonatomic, copy) NSString *region;
/** 币简称 */
@property (nonatomic, copy) NSString *region_curreny;
/** 符号 */
@property (nonatomic, copy) NSString *region_curreny_char;
/** 汇率 */
@property (nonatomic, copy) NSString *exchange_rate;
/** vippay余额 */
@property (nonatomic, copy) NSString *vippay_balance;


//vip_type

-(void)setValue:(id)value forUndefinedKey:(NSString *)key;
-(instancetype)initWithDic:(NSDictionary *) dic;
+(instancetype)modelWithDic:(NSDictionary *) dic;

@end
