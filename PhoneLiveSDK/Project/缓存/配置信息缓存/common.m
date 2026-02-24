#import "common.h"
#import "PublicObj.h"
NSString *const  share_title = @"share_title";
NSString *const  share_des = @"share_des";
NSString *const  wx_siteurl = @"wx_siteurl";
NSString *const  ipa_ver = @"ipa_ver";
NSString *const  app_ios = @"app_ios";
NSString *const  ios_shelves = @"ios_shelves";
NSString *const  name_coin = @"name_coin";
NSString *const  name_votes = @"name_votes";
NSString *const  enter_tip_level = @"enter_tip_level";

NSString *const  maintain_switch = @"maintain_switch";
NSString *const  maintain_tips = @"maintain_tips";
NSString *const  live_cha_switch = @"live_cha_switch";
NSString *const  live_pri_switch = @"live_pri_switch";
NSString *const  live_time_coin = @"live_time_coin";
NSString *const  live_time_switch = @"live_time_switch";
NSString *const  live_type = @"live_type";
NSString *const  share_type = @"share_type";
NSString *const  ad_list = @"ad_list";

NSString *const  agorakitid = @"agorakitid";
NSString *const  system_msg_key = @"system_msg";
NSString *const  transfer_name_key = @"transfer_name";
NSString *const  installstr_key = @"installstr";
NSString *const  redBag_des_key = @"redBag_des_key";
NSString *const  personc = @"personc";
NSString *const  gamec = @"gamec";
NSString *const  SystemNewMsgs = @"SystemNewMsgs";
NSString *const  QuickSayString = @"quickSayString";

NSString *const ExtensionPages = @"ExtensionPage";

NSString *const ALLDOMAINSLIST = @"ALLDOMAINSLIST";

NSString *const  lotteryc = @"lotteryc";
NSString *const  liveclass = @"liveclass";

NSString *const  levelUser = @"levelUser";
NSString *const  levelanchor = @"levelanchor";

NSString *const  sprout_key = @"sprout_key";
NSString *const  sprout_white = @"sprout_white";
NSString *const  sprout_skin = @"sprout_skin";
NSString *const  sprout_saturated = @"sprout_saturated";
NSString *const  sprout_pink = @"sprout_pink";
NSString *const  sprout_eye = @"sprout_eye";
NSString *const  sprout_face = @"sprout_face";
NSString *const  jpush_sys_roomid = @"jpush_sys_roomid";
NSString *const  qiniu_domain = @"qiniu_domain";
NSString *const  video_share_title = @"video_share_title";
NSString *const  video_share_des = @"video_share_des";

NSString *const  video_audit_switch = @"video_audit_switch";
NSString *const  tximgfolder = @"tximgfolder";
NSString *const  txvideofolder = @"txvideofolder";
NSString *const  cloudtype = @"cloudtype";

NSString *const  auto_exchange = @"auto_exchange";
NSString *const  chip_index_key = @"chip_index";
NSString *const  chip_num_key = @"chip_num_key";
NSString *const  custom_chip_num_key = @"custom_chip_num_key";
NSString *const  custom_chip_str_key = @"custom_chip_str_key";

NSString *const  lottery_bet_cart = @"lottery_bet_cart_key";

NSString *const  contactPrice_key = @"contactprice_key";

NSString *const  fuckactivity_key = @"fuckactivity_key";

NSString *const  game_table_height_key = @"game_table_height_key%li";

NSString *const  search_redcord_key = @"search_redcord_key";

NSString *const  search_redcord_expand_key = @"search_redcord_expand_key";

NSString *const  home_recommend_data_key = @"home_recommend_data_key";

@implementation common
+ (void)saveProfile:(liveCommon *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user.share_title forKey:share_title];
    [userDefaults setObject:user.share_des forKey:share_des];
    [userDefaults setObject:user.wx_siteurl forKey:wx_siteurl];
    [userDefaults setObject:user.ipa_ver forKey:ipa_ver];
    [userDefaults setObject:user.app_ios forKey:app_ios];
    [userDefaults setObject:user.ios_shelves forKey:ios_shelves];
    [userDefaults setObject:user.name_coin forKey:name_coin];
    [userDefaults setObject:user.name_votes forKey:name_votes];
    [userDefaults setObject:user.enter_tip_level forKey:enter_tip_level];
    
    [userDefaults setObject:user.maintain_switch forKey:maintain_switch];
    [userDefaults setObject:user.maintain_tips forKey:maintain_tips];
    [userDefaults setObject:user.live_cha_switch forKey:live_cha_switch];
    [userDefaults setObject:user.live_pri_switch forKey:live_pri_switch];
    [userDefaults setObject:user.live_time_coin forKey:live_time_coin];
    [userDefaults setObject:user.live_time_switch forKey:live_time_switch];
    [userDefaults setObject:user.live_type forKey:live_type];
    [userDefaults setObject:user.share_type forKey:share_type];
    NSData *dataad_list = [NSKeyedArchiver archivedDataWithRootObject:[user.ad_list mutableCopy]];
    [userDefaults setObject:dataad_list forKey:ad_list];
    [userDefaults setObject:user.liveclass forKey:liveclass];
    [userDefaults setObject:user.userLevel forKey:levelUser];
    [userDefaults setObject:user.anchorLevel forKey:levelanchor];
    
    [userDefaults setObject:user.sprout_key forKey:sprout_key];
    [userDefaults setObject:user.sprout_white forKey:sprout_white];
    [userDefaults setObject:user.sprout_skin forKey:sprout_skin];
    [userDefaults setObject:user.sprout_saturated forKey:sprout_saturated];
    [userDefaults setObject:user.sprout_pink forKey:sprout_pink];
    [userDefaults setObject:user.sprout_eye forKey:sprout_eye];
    [userDefaults setObject:user.sprout_face forKey:sprout_face];
    [userDefaults setObject:user.jpush_sys_roomid forKey:jpush_sys_roomid];
    [userDefaults setObject:user.qiniu_domain forKey:qiniu_domain];
    [userDefaults setObject:user.video_share_title forKey:video_share_title];
    [userDefaults setObject:user.video_share_des forKey:video_share_des];
    [userDefaults setObject:user.video_audit_switch forKey:video_audit_switch];
    [userDefaults setObject:user.tximgfolder forKey:tximgfolder];
    [userDefaults setObject:user.txvideofolder forKey:txvideofolder];
    [userDefaults setObject:user.cloudtype forKey:cloudtype];
    

    [userDefaults synchronize];
}
+ (void)clearProfile{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:share_title];
    [userDefaults setObject:nil forKey:share_des];
    [userDefaults setObject:nil forKey:wx_siteurl];
    [userDefaults setObject:nil forKey:ipa_ver];
    [userDefaults setObject:nil forKey:app_ios];
    [userDefaults setObject:nil forKey:ios_shelves];
    [userDefaults setObject:nil forKey:name_coin];
    [userDefaults setObject:nil forKey:name_votes];
    [userDefaults setObject:nil forKey:enter_tip_level];
    
    [userDefaults setObject:nil forKey:maintain_tips];
    [userDefaults setObject:nil forKey:maintain_switch];
    [userDefaults setObject:nil forKey:live_pri_switch];
    [userDefaults setObject:nil forKey:live_cha_switch];
    [userDefaults setObject:nil forKey:live_time_coin];
    [userDefaults setObject:nil forKey:live_time_switch];
    [userDefaults setObject:nil forKey:live_type];
    [userDefaults setObject:nil forKey:share_type];
    [userDefaults setObject:nil forKey:ad_list];
    [userDefaults setObject:nil forKey:liveclass];
    [userDefaults setObject:nil forKey:qiniu_domain];
    [userDefaults setObject:nil forKey:video_share_title];
    [userDefaults setObject:nil forKey:video_share_des];
    [userDefaults setBool:false forKey:fuckactivity_key];
    
    [userDefaults synchronize];
}
+ (liveCommon *)myProfile{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    liveCommon *user = [[liveCommon alloc] init];
    user.live_time_coin = [userDefaults objectForKey:live_time_coin];
    user.live_time_switch = [userDefaults objectForKey:live_time_switch];
    
    user.share_title = [userDefaults objectForKey:share_title];
    user.share_des = [userDefaults objectForKey:share_des];
    user.wx_siteurl = [userDefaults objectForKey:wx_siteurl];
    user.ipa_ver = [userDefaults objectForKey:ipa_ver];
    user.app_ios = [userDefaults objectForKey:app_ios];
    user.ios_shelves = [userDefaults objectForKey:ios_shelves];
    user.name_coin = [userDefaults objectForKey:name_coin];
    user.name_votes = [userDefaults objectForKey:name_votes];
    user.enter_tip_level = [userDefaults objectForKey:enter_tip_level];
    
    user.maintain_switch = [userDefaults objectForKey:maintain_switch];
    user.maintain_tips = [userDefaults objectForKey:maintain_tips];
    user.live_cha_switch = [userDefaults objectForKey:live_cha_switch];
    user.live_pri_switch = [userDefaults objectForKey:live_pri_switch];
    user.live_type = [userDefaults objectForKey:live_type];
    user.share_type = [userDefaults objectForKey:share_type];
    NSData * dataad_list=  [userDefaults objectForKey:ad_list];
    user.ad_list =  [NSKeyedUnarchiver unarchiveObjectWithData:dataad_list];
    user.liveclass = [userDefaults objectForKey:liveclass];
    user.userLevel = [userDefaults objectForKey:levelUser];
    user.anchorLevel = [userDefaults objectForKey:levelanchor];

    return user;
}
+(NSString *)name_coin{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString* name_coinss = [userDefaults objectForKey: name_coin];
//    return name_coinss;
    return @"";
}
+(NSString *)name_votes{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString* name_votesss = [userDefaults objectForKey: name_votes];
//    return name_votesss;
    return @"";
}
+(NSString *)enter_tip_level{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* enter_tip_levelss = [userDefaults objectForKey: enter_tip_level];
    return enter_tip_levelss;
}
+(NSString *)share_title{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* share_titles = [userDefaults objectForKey: share_title];
    return share_titles;
}
+(NSString *)share_des{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* share_dess = [userDefaults objectForKey: share_des];
    return share_dess;
}
+(NSString *)wx_siteurl{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* wx_siteurls = [userDefaults objectForKey: wx_siteurl];
    return wx_siteurls;
}
+(NSString *)ipa_ver{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* ipa_vers = [userDefaults objectForKey: ipa_ver];
    return ipa_vers;
}
+(NSString *)app_ios{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* app_ioss = [userDefaults objectForKey: app_ios];
    return app_ioss;
}
+(NSString *)ios_shelves{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* ios_shelvess = [userDefaults objectForKey: ios_shelves];
    return ios_shelvess;
}

+(NSString *)maintain_tips {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *maintain_tipss = [userDefaults objectForKey: maintain_tips];
    
    return maintain_tipss;
}
+(NSString *)maintain_switch {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *maintain_switchs = [userDefaults objectForKey:maintain_switch];
    
    return maintain_switchs;
}
+(NSString *)live_pri_switch {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *live_pri_switchs = [userDefaults objectForKey:live_pri_switch];
    return live_pri_switchs;
}
+(NSString *)live_cha_switch {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *live_cha_switchs = [userDefaults objectForKey:live_cha_switch];
    return live_cha_switchs;
}
+(NSString *)live_time_switch{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *live_time_switchs = [userDefaults objectForKey:live_time_switch];
    return live_time_switchs;
    
}
+(NSArray *)live_time_coin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *live_cha_switchs = [userDefaults objectForKey:live_time_coin];
    if (live_cha_switchs==nil) {
        return [NSArray array];
    }
    return live_cha_switchs;
}
+(NSArray  *)live_type{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *livetypes = [userDefaults objectForKey:live_type];
    if (livetypes==nil) {
        return [NSArray array];
    }
    return livetypes;
    
}
+(NSArray  *)share_type{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *share_typess = [userDefaults objectForKey:share_type];
    if (share_typess==nil) {
        return [NSArray array];
    }
    return share_typess;
    
}
+(NSArray *)liveclass{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *liveclasss = [userDefaults objectForKey:liveclass];
    if (liveclasss==nil) {
        return [NSArray array];
    }
    return liveclasss;
}

+(NSArray *)ad_list{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * dataad_list=  [userDefaults objectForKey:ad_list];
    NSArray *ad_lists = [NSKeyedUnarchiver unarchiveObjectWithData:dataad_list];
    if (ad_lists==nil) {
        return [NSArray array];
    }
    return ad_lists;
}

+(void)save_ad_list:(NSArray*)ad_list_Arry {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataad_list = [NSKeyedArchiver archivedDataWithRootObject:[ad_list_Arry mutableCopy]];
    [userDefaults setObject:dataad_list forKey:ad_list];
    [userDefaults synchronize];
}

//保存声网
+(void)saveagorakitid:(NSString *)agorakitids{
    if ([PublicObj checkNull:agorakitids]) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:agorakitids forKey:agorakitid];
    [userDefaults synchronize];
}
+(NSString  *)agorakitid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *agorakitidss = [userDefaults objectForKey:agorakitid];
    return agorakitidss;
    
}
//保存游戏中心缓存
+(void)savegamecontroller:(NSArray *)arrays{
    if (arrays==nil) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:gamec];
    [userDefaults synchronize];
}
+(NSArray *)getgamec{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *gamecsData = [userDefaults objectForKey:gamec];
    NSArray * gamecs =  [NSKeyedUnarchiver unarchiveObjectWithData:gamecsData];
    if (gamecs==nil) {
        return [NSArray array];
    }
    return gamecs;
}
//保存游戏中心缓存
+(void)savelotterycontroller:(NSArray *)arrays{
    if (arrays==nil || ![arrays isKindOfClass:[NSArray class]]) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:lotteryc];
    [userDefaults synchronize];
}

////保存游戏中心table高度
//+(void)savegamecontroller_table_height:(NSInteger)row height:(float)height {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setFloat: height forKey:[NSString stringWithFormat:game_table_height_key, row]];
//    [userDefaults synchronize];
//}
//+(float)getgamecontroller_table_height:(NSInteger)row {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    float height = [userDefaults floatForKey:[NSString stringWithFormat:game_table_height_key, row]];
//    return height;
//}

+(NSArray *)getlotteryc{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data=  [userDefaults objectForKey:lotteryc];
    NSArray * gamecs =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (gamecs==nil) {
        return [NSArray array];
    }
    NSMutableArray *gamecs_list = [NSMutableArray arrayWithArray:gamecs];
//    [ad_list addObjectsFromArray:gamecs];

    return gamecs_list;
}
//自动兑换缓存
+(void)saveAutoExchange:(BOOL)bauto_exchange{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:bauto_exchange] forKey:auto_exchange];
    [userDefaults synchronize];
}
+(BOOL)getAutoExchange{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *bauto_exchange = [userDefaults objectForKey:auto_exchange];
    BOOL ret = [bauto_exchange boolValue];
    if(bauto_exchange == nil){
        return true;
    }
    return ret;
}

//缓存筹码索引
+(void)saveChipIndex:(NSInteger)chip_index{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:chip_index forKey:chip_index_key];
    [userDefaults synchronize];
}
+(NSInteger)getChipIndex{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger chip_index = [userDefaults integerForKey:chip_index_key];
    if(!chip_index){
        return 0;
    }
    return chip_index;
}

//缓存当前筹码数
+(void)saveChipNums:(double)chip_num{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:chip_num forKey:chip_num_key];
    [userDefaults synchronize];
}
+(double)getChipNums{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger chip_num = [userDefaults integerForKey:chip_num_key];
    if(chip_num == 0){
        return 2;
    }
    return chip_num;
}
//缓存当前筹码数
+(void)saveLastChipModel:(ChipsModel*)chip_model{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[chip_model mj_JSONObject]];
    [userDefaults setObject:data1 forKey:@"ChipLastSaved"];
    [userDefaults synchronize];
}
+(ChipsModel*)getLastChipModel{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *datas = [userDefaults objectForKey:@"ChipLastSaved"];
    NSDictionary * chipsmodel =  [NSKeyedUnarchiver unarchiveObjectWithData:datas];
    if (chipsmodel!=nil) {
        return [ChipsModel mj_objectWithKeyValues:chipsmodel];
    }
    return nil;
}

//缓存当前自定义筹码数(平台币)
+(void)saveCustomChipNum:(double)chip_num{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:chip_num forKey:custom_chip_num_key];
    [userDefaults synchronize];
}
+(double)getCustomChipNum{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    double chip_num = [userDefaults doubleForKey:custom_chip_num_key];
    
    return chip_num;
}
//缓存当前自定义筹码显示用 RegionCurreny+数字  // @"JPY+3500"
+(void)saveCustomChipStr:(NSString *)chip_str{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:chip_str forKey:custom_chip_str_key];
    [userDefaults synchronize];
}
+(NSString *)getCustomChipStr{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *chip_str = [userDefaults objectForKey:custom_chip_str_key];
    
    return chip_str; //RegionCurreny+数字  // @"JPY+3500"
}


//保存系统公告（跑马灯）
+(void)saveSystemMsg:(NSArray *)system_msg{
    if (system_msg==nil ||(system_msg!= nil && system_msg.count<1)) {
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:KRefresh_system_msg object:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:system_msg forKey:system_msg_key];
    [userDefaults synchronize];
}

+(NSArray *)getSystemMsg{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *system_msg = [userDefaults objectForKey:system_msg_key];
    if (system_msg==nil) {
        return [NSArray array];
    }
    return system_msg;
}

//保存转账人姓名
+(void)saveTransferName:(NSString *)transfer_name{
     if ([PublicObj checkNull:transfer_name]) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:transfer_name forKey:transfer_name_key];
    [userDefaults synchronize];
}
+(NSString *)getTransferName{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *transfer_name = [userDefaults objectForKey:transfer_name_key];
    return transfer_name;
}

//保存安装参数
+(void)saveInstallParams:(NSString *)installstr{
     if ([PublicObj checkNull:installstr]) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:installstr forKey:installstr_key];
    [userDefaults synchronize];
}
+(NSString *)getInstallParams{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *installstr = [userDefaults objectForKey:installstr_key];
    return installstr;
}


+(void)getServiceUrl:(void (^)(NSString *kefuUrl))callback{
    
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getChatConfigInfo"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        if(code == 0)
        {
            NSDictionary *infoDic = info;
            NSString *chat_service_url = [infoDic objectForKey:@"chat_service_url"];
            if(chat_service_url.length>0){
                if(callback){
                    callback(chat_service_url);
                }
            }else{
                if(callback){
                    callback(nil);
                }
            }
        }else{
            if(callback){
                callback(nil);
            }
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        if(callback){
            callback(nil);
        }
    }];
    
}

//保存红包默认提示语
+(void)saveRedBagDes:(NSString *)redBagDes{
    if (![redBagDes isKindOfClass:[NSString class]] || [PublicObj checkNull:redBagDes]) {
       return;
   }
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   [userDefaults setObject:redBagDes forKey:redBag_des_key];
   [userDefaults synchronize];
}

+ (NSString *)getRedBagDes{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *urlstr = [userDefaults objectForKey:redBag_des_key];
    return urlstr;
}

//保存个人中心选项缓存
+(void)savepersoncontroller:(NSArray *)arrays{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    
    [userDefaults setObject:data1 forKey:personc];
    [userDefaults synchronize];
}
+(NSArray *)getpersonc{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 
    NSData *personData = [userDefaults objectForKey:personc];
    NSArray * personcs =  [NSKeyedUnarchiver unarchiveObjectWithData:personData];
  
    
    if (personcs==nil) {
        return [NSArray array];
    }
    return personcs;
    
}
+(NSDictionary *)getUserLevelMessage:(NSString *)level{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *levelArr = [userDefaults objectForKey:levelUser];
    NSDictionary *dic;
    if ([levelArr isKindOfClass:[NSArray class]]) {
        if ([level integerValue] - 1 < levelArr.count) {
            dic = levelArr[[level integerValue] - 1];
        }else{
            dic = [levelArr lastObject];
        }
    }else{
        dic = @{
                @"levelid": @"0",
                @"thumb": @"123",
                @"colour": @"#000000",
                @"thumb_mark": @"123"
                };
    }
    return dic;
}

+(NSDictionary *)getAnchorLevelMessage:(NSString *)level{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *levelArr = [userDefaults objectForKey:levelanchor];
    NSDictionary *dic;
    if ([levelArr isKindOfClass:[NSArray class]]) {
        if ([level integerValue] - 1 < levelArr.count) {
            dic = levelArr[[level integerValue] - 1];
        }else{
            dic = [levelArr lastObject];
        }
    }else{
        dic = @{
            @"levelid": @"0",
            @"thumb": @"123",
            @"colour": @"#000000",
            @"thumb_mark": @"123"
            };
    }
    if (dic==nil) {
        return [NSDictionary dictionary];
    }
    return dic;
}

+(BOOL)isShowfuckactivity{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL fuckactivityBool = [userDefaults boolForKey:fuckactivity_key];
    return fuckactivityBool;
}

+(void)setFuckActivity:(BOOL)isFucShow{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isFucShow forKey:fuckactivity_key];
    [userDefaults synchronize];
}

+(NSString *)sprout_key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_key];
    return sprout_keyss;
    
}
+(NSString *)sprout_white{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_white];
    return sprout_keyss;
    
}
+(NSString *)sprout_skin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_skin];
    return sprout_keyss;
    
}
+(NSString *)sprout_saturated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_saturated];
    return sprout_keyss;
    
}
+(NSString *)sprout_pink{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_pink];
    return sprout_keyss;
    
}
+(NSString *)sprout_eye{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_eye];
    return sprout_keyss;
    
}
+(NSString *)sprout_face{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_face];
    return sprout_keyss;
    
}
+(NSString *)jpush_sys_roomid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:jpush_sys_roomid];
    return sprout_keyss;
}
+(NSString *)qiniu_domain{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:qiniu_domain];
    return sprout_keyss;
}
+(NSString *)video_share_des{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* share_titles = [userDefaults objectForKey: video_share_des];
    return share_titles;
}
+(NSString *)video_share_title{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* share_titles = [userDefaults objectForKey: video_share_title];
    return share_titles;
}
#pragma mark - 后台审核开关
+(NSString *)getAuditSwitch {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auditSwitch = [userDefaults objectForKey:video_audit_switch];
    return auditSwitch;
}
#pragma mark - 腾讯空间
+(NSString *)getTximgfolder {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auditSwitch = [userDefaults objectForKey:tximgfolder];
    return auditSwitch;
}
+(NSString *)getTxvideofolder {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auditSwitch = [userDefaults objectForKey:txvideofolder];
    return auditSwitch;
}
#pragma mark - 存储类型（七牛-腾讯）
+(NSString *)cloudtype{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cloudtypess = [userDefaults objectForKey:cloudtype];
    return cloudtypess;
}

+(void)saveLotteryBetCart:(NSArray *)arrays{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:arrays forKey:lottery_bet_cart];
    [userDefaults synchronize];
}

+(NSArray *)getLotteryBetCart{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:lottery_bet_cart];
    if (array==nil) {
        return [NSArray array];
    }
    
    return array;
}

//名片价格
+(void)saveContactPrice:(NSArray *)arrays
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:arrays forKey:contactPrice_key];
    [userDefaults synchronize];
}

+(NSArray *)getContactPrice{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:contactPrice_key];
    if (array==nil) {
        return [NSArray array];
    }
    
    return array;
}

+ (void)saveAnchorNoticeText:(NSString *)text {
    vkUserSet(@"AnchorNoticeTextKey", text);
}
+ (NSString *)getAnchorNoticeText {
    return vkUserGet(@"AnchorNoticeTextKey");
}

+ (void)saveAnchorNoticeTime:(NSString *)time {
    vkUserSet(@"AnchorNoticeTimeKey", time);
}
+(NSString *)getAnchorNoticeTime {
    return vkUserGet(@"AnchorNoticeTimeKey");
}

+(void)saveAnchorNoticeSwitch:(BOOL)isOpen {
    vkUserSet(@"AnchorNoticeSwitchKey", @(isOpen));
}
+(BOOL)getAnchorNoticeSwitch {
    return [vkUserGet(@"AnchorNoticeSwitchKey") boolValue];
}

//保存消息
+(void)saveSystemNewMsgs:(NSArray *)arrays{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (arrays==nil) {
        [userDefaults setObject:nil forKey:SystemNewMsgs];
        [userDefaults synchronize];
        return;
    }
   
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:SystemNewMsgs];
    [userDefaults synchronize];
}

+(NSArray *)getSystemNewMsgs{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *gamecsData = [userDefaults objectForKey:SystemNewMsgs];
    NSArray * gamecs =  [NSKeyedUnarchiver unarchiveObjectWithData:gamecsData];
    if (gamecs==nil) {
        return [NSArray array];
    }
    return gamecs;
}
+(void)saveLivePopChargeInfo:(NSArray *)arrays{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (arrays==nil) {
        [userDefaults setObject:nil forKey:@"LivePopChargeInfo"];
        [userDefaults synchronize];
        return;
    }
    
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:@"LivePopChargeInfo"];
    [userDefaults synchronize];
}

+(NSArray *)getLivePopChargeInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *gamecsData = [userDefaults objectForKey:@"LivePopChargeInfo"];
    NSArray * gamecs =  [NSKeyedUnarchiver unarchiveObjectWithData:gamecsData];
    if (gamecs==nil) {
        return [NSArray array];
    }
    return gamecs;
}


//快捷发言
+(void)saveQuickSay:(NSArray*)arrays
{
    NSString *filePath = [self quickSayFilePath];
    BOOL success = [NSKeyedArchiver archiveRootObject:arrays toFile:filePath];
    if (!success) {
        NSLog(@"Failed to save quick says to file.");
    }
    
}
+(NSArray*)getQuickSay{
    NSString *filePath = [self quickSayFilePath];
    NSArray *quickSays = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (quickSays == nil) {
        return [NSArray array];
    }
    return quickSays;
}


// 获取文件路径
+(NSString *)quickSayFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"QuickSays.plist"];
}


+(void)saveExtensionPage:(NSArray*)arrays
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (arrays==nil) {
        [userDefaults setObject:nil forKey:ExtensionPages];
        [userDefaults synchronize];
        return;
    }
    
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:ExtensionPages];
    [userDefaults synchronize];
}
+(NSArray*)getExtensionPage{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *datas = [userDefaults objectForKey:ExtensionPages];
    NSArray * datasArray =  [NSKeyedUnarchiver unarchiveObjectWithData:datas];
    if (datasArray==nil) {
        return [NSArray array];
    }
    return datasArray;
}


//静音   0有声音 1 禁止背景音乐 2 禁止全部声音
+(void)soundControl:(int)soundStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:soundStatus forKey:@"soundControlValue"];
    [userDefaults synchronize];
}
+(NSInteger)soundControlValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger soundValaue =  [userDefaults integerForKey:@"soundControlValue"];
    return soundValaue;
}

//游戏盾
+(void)closeGameShield:(BOOL)closeGameShield
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:closeGameShield forKey:@"closeGameShield"];
    [userDefaults synchronize];
}
+(BOOL)closeGameShield
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL openGameShield =  [userDefaults boolForKey:@"closeGameShield"];
    return openGameShield;
}

//保存搜索页、搜索历史
+(void)saveSearchRedcord:(NSArray *)array {
    if (array==nil) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[array mutableCopy]];
    [userDefaults setObject:data1 forKey:search_redcord_key];
    [userDefaults synchronize];
}

+(NSArray *)getSearchRedcord {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *searchRedcordData = [userDefaults objectForKey:search_redcord_key];
    NSArray * searchRedcord =  [NSKeyedUnarchiver unarchiveObjectWithData:searchRedcordData];
    if (searchRedcord==nil) {
        return [NSArray array];
    }
    return searchRedcord;
}
//保存搜索页、搜索历史(收合)
+(void)saveSearchRedcordExpand:(BOOL)isExpand {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:isExpand] forKey:search_redcord_expand_key];
    [userDefaults synchronize];
}
+(BOOL)getSearchRedcordExpand {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *bauto_exchange = [userDefaults objectForKey:search_redcord_expand_key];
    BOOL ret = [bauto_exchange boolValue];
    if(bauto_exchange == nil){
        return false;
    }
    return ret;
}


//历史域名记录
+(void)saveAllDomians:(NSArray*)arrays
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (arrays==nil) {
        [userDefaults setObject:nil forKey:ALLDOMAINSLIST];
        [userDefaults synchronize];
        return;
    }
    
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:ALLDOMAINSLIST];
    [userDefaults synchronize];
}
+(NSArray*)getAllDomians{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *datas = [userDefaults objectForKey:ALLDOMAINSLIST];
    NSArray * datasArray =  [NSKeyedUnarchiver unarchiveObjectWithData:datas];
    if (datasArray==nil) {
        return [NSArray array];
    }
    return datasArray;
}

// 首页推荐登入串行获取资料
+ (void)saveHomeRecommendData:(NSArray*)arrays {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (arrays==nil) {
        [userDefaults setObject:nil forKey:home_recommend_data_key];
        [userDefaults synchronize];
        return;
    }
    
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[arrays mutableCopy]];
    [userDefaults setObject:data1 forKey:home_recommend_data_key];
    [userDefaults synchronize];
}

+ (NSArray*)getHomeRecommendData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *datas = [userDefaults objectForKey:home_recommend_data_key];
    NSArray * datasArray =  [NSKeyedUnarchiver unarchiveObjectWithData:datas];
    if (datasArray==nil) {
        return [NSArray array];
    }
    return datasArray;
}

+ (void)saveLoginTypes:(NSArray *)loginTypes {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (loginTypes==nil) {
        [userDefaults setObject:nil forKey:@"kLoginTypesKey"];
        [userDefaults synchronize];
        return;
    }
    
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:[loginTypes mutableCopy]];
    [userDefaults setObject:data1 forKey:@"kLoginTypesKey"];
    [userDefaults synchronize];
}

+ (NSArray *)getLoginTypes {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *datas = [userDefaults objectForKey:@"kLoginTypesKey"];
    NSArray * datasArray =  [NSKeyedUnarchiver unarchiveObjectWithData:datas];
    if (datasArray==nil) {
        return [NSArray array];
    }
    return datasArray;
}

@end
