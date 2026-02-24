#import "socketLivePlay.h"
#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "Common.pbobjc.h"
#import "S2C.pbobjc.h"

@interface socketMovieplay()
{
    NSString *webSocketURL;
    BOOL isConnectedBefor;
}
@end

@implementation socketMovieplay

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1 && cardString.length>0) {
        UIPasteboard *paste = [UIPasteboard generalPasteboard];
        paste.string = cardString;
        [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
    }
    cardString = nil;
}
//发送弹幕
-(void)sendBarrageID:(NSString *)ID andTEst:(NSString *)content andModel:(hotModel *)zhuboModel success:(networkSuccessBlock)sucBack fail:(networkFailBlock)failBack{
    /*******发送弹幕开始 **********/
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.sendBarrage"];
    NSDictionary *barrage = @{
        @"uid":[Config getOwnID],
        @"token":[Config getOwnToken],
        @"liveuid":ID,
        @"stream":zhuboModel.stream,
        @"giftid":@"1",
        @"giftcount":@"1",
        @"content":content
    };
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:barrage data:nil success:sucBack fail:failBack];
    
}
//建立socket
- (void)setnodejszhuboModel:(hotModel *)zhuboModel Handler:(getResults)handler andlivetype:(NSString *)livetypes{
    _livetype = livetypes;
    _shut_time = @"0";
    self.playDocModel = zhuboModel;
    [GlobalDate setLiveUID:[zhuboModel.zhuboID integerValue]];
    justonce = 0;
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.enterRoom"];
    NSDictionary *subDic  = @{@"liveuid":zhuboModel.zhuboID,@"city":[cityDefault getMyCity],@"stream":zhuboModel.stream};
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:subDic data:nil success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            NSDictionary *info = [infos firstObject];
            if ([info isKindOfClass:[NSDictionary class]]) {
                strongSelf.shut_time = [NSString stringWithFormat:@"%@",[info valueForKey:@"shut_time"]];//禁言时间
                strongSelf.chatserver = [info valueForKey:@"chatserver"]; // 聊天服地址
                [strongSelf socketStop];
                strongSelf->isConnectedBefor = false;
                [strongSelf addNodeListen:zhuboModel isFirstConnect:YES serverUrl:strongSelf.chatserver];
            }
                
            dispatch_main_async_safe(^{
                handler(infos);
            });
            
           
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:error.localizedDescription];
    }];
}
BOOL isCOnn;
-(void)reconnectByProxyWebsocket:(hotModel*)model{
    
    WeakSelf
    if (isCOnn) {
        return;
    }
    isCOnn = YES;
    BOOL isForceSHild = YES;
    if ((webSocketURL!= nil && [webSocketURL containsString:@"127.0.0"])) {
        isForceSHild = false;
    }
    if (isForceSHild) {
        [[DomainManager sharedInstance] getWebSocketProxyCallback:^(NSString *bestDomain) {
            STRONGSELF
            if (strongSelf != nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (strongSelf != nil) {
                        if (bestDomain!= nil) {
                            [strongSelf socketStop];
                            [strongSelf addNodeListen:model isFirstConnect:NO serverUrl:bestDomain];
                        }else{
                            [strongSelf socketStop];
                            [strongSelf addNodeListen:model isFirstConnect:NO serverUrl:strongSelf.chatserver];
                        }
                    }
                });
                   
            }
            isCOnn = false;
        }];
    }else{
        [self socketStop];
        [self addNodeListen:model isFirstConnect:NO serverUrl:self.chatserver];
        isCOnn = false;
    }
    
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isCOnn = false;
    });

}

 long long millisecondsPing = 0;
 
-(void)addNodeListen:(hotModel *)model isFirstConnect:(BOOL)isFirst serverUrl:(NSString*)serverUrl
{
    users = [Config myProfile];
    isReConSocket = YES;
   
    if (model.centerUrl.length && model.centerUrl != nil) {
        _chatserver = model.centerUrl;
    }
    webSocketURL = serverUrl;
    NSURL* url = [[NSURL alloc] initWithString:serverUrl];
    if (url == nil||serverUrl.length<1 ||[Config getOwnID] == nil) {
        return;
    }
    if (model.centerUrl.length && model.centerUrl != nil) {
        managerSocket = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @NO,@"reconnects":@YES,@"forceWebsockets":@YES,@"compress":@(YES),@"extraHeaders":@{@"X-AspNet-Version":[YBToolClass getSignProxy]},@"reconnectWait":@4,@"path":@"/lobby"}];
        
    }else{
        NSString *pathStr = nil;
        NSString *splitStr = [_chatserver stringByReplacingOccurrencesOfString:@"://" withString:@""];
        splitStr = [splitStr stringByReplacingOccurrencesOfString:@":/" withString:@""];
        NSArray *separateArray = [splitStr componentsSeparatedByString:@"/"];
        for (int i = 0; i<separateArray.count; i++) {
            if ((i+1)<separateArray.count) {
                pathStr = [NSString stringWithFormat:@"%@%@/",(pathStr==nil?@"":pathStr),[separateArray objectAtIndex:(i+1)]];
            }
        }
        
        if (pathStr!= nil) {
            pathStr = [NSString stringWithFormat:@"/%@",[pathStr substringToIndex:pathStr.length-2]];
            managerSocket = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @NO,@"reconnects":@YES,@"forceWebsockets":@YES,@"compress":@(YES),@"extraHeaders":@{@"X-AspNet-Version":[YBToolClass getSignProxy]},@"reconnectWait":@2,@"path":pathStr}];
        }else{
            managerSocket = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @NO,@"reconnects":@YES,@"forceWebsockets":@YES,@"compress":@(YES),@"extraHeaders":@{@"X-AspNet-Version":[YBToolClass getSignProxy]},@"reconnectWait":@2}];
        }
        
    }
    
   
    _ChatSocket = [managerSocket socketForNamespace:@"/pb"];
    WeakSelf
    [_ChatSocket connectWithTimeoutAfter:2 withHandler:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        NSLog(@"socket.io timeout -- ");
        [strongSelf reconnectByProxyWebsocket:model];
        if (![strongSelf.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorDisConnect" object:nil];
        }
    }];
    NSArray *cur = @[@{@"uid":[Config getOwnID],
                       @"token":[Config getOwnToken],
                       @"roomnum":model.zhuboID,
                       @"liveuid":model.zhuboID,
                       @"stream":model.stream,
                       @"lang":[RookieTools currentLanguageServer]
    }];
    if (isFirst||!isConnectedBefor) {
          cur = @[@{
                           @"uid":[Config getOwnID],
                           @"token":[Config getOwnToken],
                           @"roomnum":model.zhuboID,
                           @"liveuid":model.zhuboID,
                           @"stream":model.stream,
                           @"is_enter_room":@"1",
                           @"lang":[RookieTools currentLanguageServer]
        }];
    }
    if (model.centerUrl.length && model.centerUrl != nil) {
        cur = @[@{
            @"uid":[Config getOwnID],
            @"token":[Config getOwnToken],
            @"roomnum":@"0",
            @"liveuid":@"0",
            @"stream":@"",
            @"lang":[RookieTools currentLanguageServer]
        }];
        if (isFirst||!isConnectedBefor) {
            cur = @[@{
                @"uid":[Config getOwnID],
                @"token":[Config getOwnToken],
                @"roomnum":@"0",
                @"liveuid":@"0",
                @"stream":@"",
                @"is_enter_room":@"1",
                @"lang":[RookieTools currentLanguageServer]
            }];
        }
    }

    [_ChatSocket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
       
        //        NSLog(@"socket connected -- status:%d.",[_ChatSocket status]);
//        [strongSelf.ChatSocket off:@"conn"];
        strongSelf->isConnectedBefor = true;
        [strongSelf.ChatSocket emit:@"conn" with:cur];
       
        
    }];
    
    
    [_ChatSocket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        //        [strongSelf reconnectByProxyWebsocket:model];
        NSLog(@"socket.io disconnect---%@",data);
        if (![strongSelf.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorDisConnect" object:nil];
        }
    }];
    [_ChatSocket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if (data && ([minstr(data[0]) rangeOfString:@"Invalid HTTP upgrade"].location!=NSNotFound)) {
            return;
        }
        NSLog(@"socket.io error -- %@",data);
       
        [strongSelf reconnectByProxyWebsocket:model];
        if (![strongSelf.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorDisConnect" object:nil];
        }
    }];
    [_ChatSocket off:@"conn"];
    [_ChatSocket on:@"conn" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket 进入房间");
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf getZombie];
        //第一次进入 扣费 ，广播其他人增加映票
        if ([strongSelf.livetype isEqual:@"3"] || [strongSelf.livetype isEqual:@"2"]) {
            //第一次进入 扣费 ，广播其他人增加映票
            if (strongSelf->justonce == 0) {
                [strongSelf addvotes:strongSelf->type_val isfirst:@"1"];
            }
        }
        [strongSelf.ChatSocket emit:@"ping" with:@[]];
    }];
    

            // 转换为毫秒
   
    long long millisecondsPong = 0;
    
    [_ChatSocket on:@"ping" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        millisecondsPing = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
       
    }];
    
    [_ChatSocket on:@"pong" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        long long millisecondsPong = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        long long   delayTime = millisecondsPong - millisecondsPing;
        
        if (strongSelf.socketDelegate && [strongSelf.socketDelegate respondsToSelector:@selector(timeDelayUpdate:)]) {
            [strongSelf.socketDelegate timeDelayUpdate:delayTime];
        }
       
    }];
    
    
    
    
    [_ChatSocket off:@"broadcastingListen"];
    
    [_ChatSocket on:@"broadcastingListen" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->justonce= 1;
        if([data[0] isKindOfClass:[NSString class]] && [data[0] isEqual:@"stopplay"])
        {
            if (strongSelf.socketDelegate!= nil) {
                [strongSelf.socketDelegate roomCloseByAdmin];
            }
            
            return ;
        }
        //        for (NSString *path in data[0]) {
        //            NSDictionary *jsonArray = [path JSONValue];
        //
        //            NSDictionary *msg = [[jsonArray valueForKey:@"msg"] firstObject];
        //            NSString *retcode = [NSString stringWithFormat:@"%@",[jsonArray valueForKey:@"retcode"]];
        //            NSString *method = [msg valueForKey:@"_method_"];
        //            if ([retcode isEqual:@"409002"]) {
        //                [MBProgressHUD showError:YZMsg(@"你已被禁言")];
        //                return;
        //            }
        //            [strongSelf getmessage:msg andMethod:method];
        //        }
        for (NSData *pbData in data) {
            if ([pbData isKindOfClass:[NSNull class]]|| pbData == nil || ([pbData isKindOfClass:[NSString class]] && [PublicObj checkNull:(NSString*)pbData])) {
                return;
            }
            StreamMsg *smsgPb = [StreamMsg parseFromData:pbData error:nil];
            [strongSelf getmessage:smsgPb];
  
        }
    }];
    
}
-(void)getmessage:(StreamMsg *)smsgPb{
    if (self.socketDelegate == nil) {
        return;
    }
//    BOOL isCloseAdv = [[NSUserDefaults standardUserDefaults] boolForKey:@"isCloseAdv"];
    //僵尸粉
    if (smsgPb.msgId == MsgID_RequestFans) {
        requestFans *refans = [requestFans parseFromData:smsgPb.msgData error:nil];
        if (refans.msg.ct.code == 0) {
            requestFans_InfoStruct *info = refans.msg.ct.info;
            NSMutableArray *fansA = [NSMutableArray array];
            for (requestFans_UserInfo *infos in info.listArray) {
                NSDictionary *dicSub = @{@"id":minnum(infos.id_p),@"avatar":infos.avatar?infos.avatar:@"",@"guard_type":minnum(infos.guardType),@"level":minnum(infos.level)};
                [fansA addObject:dicSub];
            }
            if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(addZombieByArray:)]) {
                [self.socketDelegate addZombieByArray:fansA];
            }
        }
    }
    //会话消息
    if (smsgPb.msgId == MsgID_SendMsg) {
        //SendMsg   msgtype  26  votes
        SendMsg *msg = [SendMsg parseFromData:smsgPb.msgData error:nil];
        if (msg.msg.msgtype == 0 && msg.msg.action == 0  && msg.msg.ct.id_p==0 &&([msg.retmsg isEqualToString:@"OK"] )) {
            return;
        }
        if (msg.retcode == 409002) {
            [MBProgressHUD showError:YZMsg(@"你已被禁言")];
            return;
        }
        if(msg.msg.msgtype == 2)
        {
            NSString* ct;
            NSDictionary *heartDic = [msg.msg.ct mj_keyValues];
            //点亮
            NSString *heartSt = [heartDic objectForKey:@"heart"];
            if (heartSt!=nil && [heartSt isKindOfClass:[NSString class]] && heartSt.length>0) {
                NSString *lightColor = [heartDic valueForKey:@"heart"];
                NSString *light = @"light";
                NSString *titleColor = [light stringByAppendingFormat:@"%@",lightColor];
                ct = [NSString stringWithFormat:@"%@",msg.msg.content];
                NSString* uname = minstr(msg.msg.ct.userNicename);
                NSString *levell = minnum(msg.msg.ct.level);
                NSString *ID = minnum(msg.msg.ct.id_p);
                NSString *vip_type =minnum(msg.msg.ct.vipType);
                NSString *liangname =minstr(msg.msg.ct.liangname);
                NSString *usertype =minnum(msg.msg.ct.usertype);
                NSString *guardType =minnum(msg.msg.ct.guardType);
                NSString *king_icon = ![msg.msg.ct.kingIcon isEqual:@"null"]?msg.msg.ct.kingIcon:@"";
                
                NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",usertype,@"usertype",guardType,@"guard_type",king_icon,@"king_icon",nil];
                
                NSDictionary *levelDic = [common getUserLevelMessage:levell];
                WeakSelf
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager loadImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]
                                  options:SDWebImageHighPriority
                                 progress:nil
                                completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    if (strongSelf.socketDelegate != nil&& [strongSelf.socketDelegate respondsToSelector:@selector(light:)]) {
                        if ([PublicObj checkNull:msg.msg.ct.kingIcon]) {
                            [strongSelf.socketDelegate light:chat];
                        }else{
                           
                            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:msg.msg.ct.kingIcon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                            
                                if (strongSelf == nil) {
                                    return;
                                }
                                [strongSelf.socketDelegate light:chat];
                            }];
                            
                        }
                        
                    }
                }];
                
                
                
                
            }else{
                NSString *titleColor = @"0";
                ct = [NSString stringWithFormat:@"%@",msg.msg.content];
                NSString* uname = minstr(msg.msg.ct.userNicename);
                NSString *levell = minnum(msg.msg.ct.level);
                NSString *ID = minnum(msg.msg.ct.id_p);
                NSString *vip_type =minnum(msg.msg.ct.vipType);
                NSString *liangname =minstr(msg.msg.ct.liangname);
                NSString *usertype =minnum(msg.msg.ct.usertype);
                NSString *isAnchor = minnum(msg.msg.ct.isAnchor);
                NSString *guardType =minnum(msg.msg.ct.guardType);
                NSString *king_icon = ![msg.msg.ct.kingIcon isEqual:@"null"]?msg.msg.ct.kingIcon:@"";
                NSString *lang = minstr(msg.msg.lang);
                //        是否用户发言
                NSString *isUserMsg = @"1";
                NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",usertype,@"usertype",isAnchor,@"isAnchor",guardType,@"guard_type",king_icon,@"king_icon",lang,@"lang",isUserMsg,@"isUserMsg",nil];
               
                
                NSDictionary *levelDic = [common getUserLevelMessage:levell];
                WeakSelf
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager loadImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]
                                  options:SDWebImageHighPriority
                                 progress:nil
                                completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    if (strongSelf.socketDelegate != nil&& [strongSelf.socketDelegate respondsToSelector:@selector(messageListen:)]) {
                        if (![PublicObj checkNull:msg.msg.ct.kingIcon]) {
                          
                            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:msg.msg.ct.kingIcon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               
                                if (strongSelf == nil) {
                                    return;
                                }
                                [strongSelf.socketDelegate messageListen:chat];
                            }];
                        }else{
                            [strongSelf.socketDelegate messageListen:chat];
                        }
                    }
                }];
            }
        }
        //用户离开进入
        if(msg.msg.msgtype ==0)
        {
            //用户离开
            if (msg.msg.action == 1) {
                NSLog(@"用户离开，%@",msg);
                if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(UserLeave:)]) {
                    [self.socketDelegate UserLeave:@{@"ct":@{@"id":minnum(msg.msg.ct.id_p)}}];
                }
            }
            //用户进入
            if (msg.msg.action == 0 && msg.msg.ct.id_p!=0) {
                NSDictionary *dicSub = @{@"ct":@{@"id":minnum(msg.msg.ct.id_p),
                                                 @"user_nicename":msg.msg.ct.userNicename?msg.msg.ct.userNicename:@"",
                                                 @"avatar":msg.msg.ct.avatar?msg.msg.ct.avatar:@"",
                                                 @"avatar_thumb":msg.msg.ct.avatarThumb?msg.msg.ct.avatarThumb:@"",
                                                 @"level":minnum(msg.msg.ct.level),
                                                 @"usertype":minnum(msg.msg.ct.usertype),
                                                 @"vip_type":minnum(msg.msg.ct.vipType),
                                                 @"king_icon":![msg.msg.ct.kingIcon isEqual:@"null"]?msg.msg.ct.kingIcon:@"",
                                                 @"guard_type":minnum(msg.msg.ct.guardType),
                                                 @"liangname":msg.msg.ct.liangname?msg.msg.ct.liangname:@"",
                                                 @"car_id":minnum(msg.msg.ct.carId),
                                                 @"car_swf":msg.msg.ct.carSwf?msg.msg.ct.carSwf:@"",
                                                 @"car_swftime":msg.msg.ct.carSwftime?msg.msg.ct.carSwftime:@"",
                                                 @"car_words":msg.msg.ct.carWords?msg.msg.ct.carWords:@"",
                                                 @"isAnchor":minnum(msg.msg.ct.isAnchor)
                }};
                if (msg.msg.ct.id_p == [[Config getOwnID] integerValue]) {
                    
                }
                
                
                NSDictionary *levelDic = [common getUserLevelMessage:minnum(msg.msg.ct.level)];
                WeakSelf
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager loadImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]
                                  options:SDWebImageHighPriority
                                 progress:nil
                                completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    if (![msg.msg.ct.kingIcon isEqual:@"null"] && msg.msg.ct.kingIcon.length>0) {
                        
                        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:msg.msg.ct.kingIcon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                            
                            if (strongSelf == nil) {
                                return;
                            }
                            if (strongSelf.socketDelegate != nil) {
                                if ([strongSelf.socketDelegate respondsToSelector:@selector(UserAccess:)]) {
                                    [strongSelf.socketDelegate UserAccess:dicSub];
                                }
                            }
                            
                        }];
                    }else{
                        if (strongSelf.socketDelegate != nil) {
                            if ([strongSelf.socketDelegate respondsToSelector:@selector(UserAccess:)]) {
                                [strongSelf.socketDelegate UserAccess:dicSub];
                            }
                        }
                    }
                    
                }];
            }
        }
        //直播关闭
        if (msg.msg.msgtype == 1) {
            if (msg.msg.action == 18) {
                NSLog(@"直播关闭");
                if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(LiveOff)]) {
                    [self.socketDelegate LiveOff];
                }
            }
        }
        if (msg.msg.msgtype == 26) {
            
        }
        //发红包
        if(msg.msg.msgtype  == 255)
        {
            NSString *action = [msg valueForKey:@"action"];
            if ([action isEqual:@"0"]) {
                SendRed *msgred = [[SendRed alloc]init];
                SendRed_Msg *msgR = [[SendRed_Msg alloc]init];
                msgR.ct = msg.msg.content;
                msgR.level = msg.msg.ct.level;
                msgR.uid = msg.msg.ct.id_p;
                msgR.name = msg.msg.ct.userNicename;
                msgR.vipType = msg.msg.ct.vipType;
                msgR.liangname = msg.msg.ct.liangname;
                msgred.msg=msgR;
                if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(showRedbag:)]) {
                    [self.socketDelegate showRedbag:msgred];
                }
            }
        }
        
    }
    //增加映票
    else if (smsgPb.msgId == MsgID_UpdateVotes){
        updateVotes *msg = [updateVotes parseFromData:smsgPb.msgData error:nil];
        if (msg.msg.msgtype == 26)
        {
            if (self.socketDelegate != nil && [self.socketDelegate respondsToSelector:@selector(addvotesdelegate:)]) {
                [self.socketDelegate addvotesdelegate:minnum(msg.msg.votes)];
            }
        }
    }
    //房间类型切换
    else if (smsgPb.msgId == MsgID_ChangeLive)
    {
        changeLive *msg = [changeLive parseFromData:smsgPb.msgData error:nil];
        if (msg && msg.msg && msg.msg.roomType!=nil && msg.msg.roomType.length>0) {
            msg.msg.type = msg.msg.roomType;
        }
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(changeLive:changetype:)]) {
            [self.socketDelegate changeLive:[NSString stringWithFormat:@"%@",msg.msg.typeVal] changetype:[NSString stringWithFormat:@"%@",msg.msg.type]];
        }
    }
    
    //点亮
    else if (smsgPb.msgId == MsgID_Light){
        light *lightPb = [light parseFromData:smsgPb.msgData error:nil];
        
        if(lightPb.msg.msgtype == 0){
            //点亮
            if (lightPb.msg.action == 2) {
                if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(sendLight)]) {
                    [self.socketDelegate sendLight];
                }
            }
        }
    }
    //设置管理员
    else if (smsgPb.msgId == MsgID_SystemNot){
        SystemNot *sysmsg = [SystemNot parseFromData:smsgPb.msgData error:nil];
//        NSString *msgtype = [NSString stringWithFormat:@"%u",sysmsg.msg.msgtype];
//        NSString *action = [NSString stringWithFormat:@"%u",sysmsg.msg.action];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(setSystemNot:)]) {
            [self.socketDelegate setSystemNot:@{@"ct":sysmsg.msg.ct}];
        }
    }else if(smsgPb.msgId == MsgID_SendContactInfo){
        SendContactInfo *contactInfo = [SendContactInfo parseFromData:smsgPb.msgData error:nil];
        if ([contactInfo.msg.ct isKindOfClass:[NSString class]]){
            //主播名片
            if (cardString) {
                return;
            }
            cardString = [[NSString stringWithFormat:@"%@",minstr(contactInfo.msg.ct)] stringByReplacingOccurrencesOfString:YZMsg(@"socketLivePlay_getConatct") withString:@""];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:YZMsg(@"socketLivePlay_getCard") message:[NSString stringWithFormat:@"\n%@",cardString] delegate:self cancelButtonTitle:YZMsg(@"public_cancel") otherButtonTitles:YZMsg(@"publictool_copy"), nil];
            [alert show];
        }
    } else if(smsgPb.msgId == MsgID_ShutUpUser){
        ShutUpUser *sysmsg = [ShutUpUser parseFromData:smsgPb.msgData error:nil];
        NSString *msgtype = [NSString stringWithFormat:@"%u",sysmsg.msg.msgtype];
        NSString *action = [NSString stringWithFormat:@"%u",sysmsg.msg.action];
        NSString *touid = [NSString stringWithFormat:@"%u",sysmsg.msg.touid];
        if([msgtype isEqual:@"4"] && [action isEqual:@"13"]) {
            //设置取消管理员
            if ([touid isEqual:[Config getOwnID]]) {
                [self alertShowMsg:minstr(sysmsg.msg.ct) andTitle:YZMsg(@"public_warningAlert")];
            }
        }
        else if ([msgtype isEqual:@"4"] && [action isEqual:@"1"]) {
            //禁言
            if ([touid isEqual:[Config getOwnID]]) {
                [self alertShowMsg:minstr(sysmsg.msg.ct) andTitle:YZMsg(@"public_warningAlert")];
            }else if ([sysmsg.msg.ct isKindOfClass:[NSString class]] && [sysmsg.msg.ct rangeOfString:YZMsg(@"socketLivePlay_Anchor_Card")].location != NSNotFound){
                //                //主播名片
                //                if (cardString) {
                //                    return;
                //                }
                //                cardString = [[NSString stringWithFormat:@"%@",minstr(sysmsg.msg.ct)] stringByReplacingOccurrencesOfString:@"收到主播名片：" withString:@""];
                //                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"收到主播名片" message:[NSString stringWithFormat:@"\n%@",cardString] delegate:self cancelButtonTitle:YZMsg(@"取消") otherButtonTitles:@"复制", nil];
                //                [alert show];
            }
        }
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(socketShowChatSystem:)]) {
            [self.socketDelegate socketShowChatSystem:@{@"ct":sysmsg.msg.ct}];
        }
    }else if (smsgPb.msgId == MsgID_SetAdmin){
        setAdmin *setAdminModel = [setAdmin parseFromData:smsgPb.msgData error:nil];
        NSString *ct = [NSString stringWithFormat:@"%@",setAdminModel.msg.ct];
        if (ct) {
            if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(setAdmin:)]) {
                [self.socketDelegate setAdmin:setAdminModel];
            }
        }
    }else if (self.socketDelegate && smsgPb.msgId == MsgID_KyGame){
        // 开元弹幕
        kyGame *kygModel = [kyGame parseFromData:smsgPb.msgData error:nil];
        NSString *ct = [NSString stringWithFormat:@"%@",kygModel.msg.ct];
        if (ct) {
            if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(setGameNot:)]) {
                [self.socketDelegate setGameNot:kygModel];
            }
        }
    }else if (self.socketDelegate && smsgPb.msgId == MsgID_PlatGame){
        // 平台弹幕
        platGame *platGameModel = [platGame parseFromData:smsgPb.msgData error:nil];
        NSString *ct = [NSString stringWithFormat:@"%@",platGameModel.msg.ct];
        if (ct) {
            if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(setPlatGameNot:)]) {
                [self.socketDelegate setPlatGameNot:platGameModel];
            }
        }
    }
    // 货币更新
    else if (self.socketDelegate && smsgPb.msgId == MsgID_MoneyChange){
        MoneyChange *moneyChangeModel = [MoneyChange parseFromData:smsgPb.msgData error:nil];
        if (![self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"moneyChange" object:nil userInfo:@{@"money":min2float(moneyChangeModel.msg.money)}];
        }
        
    }
    // 同步彩票信息
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotterySync){
        LotterySync *lotSyneModel = [LotterySync parseFromData:smsgPb.msgData error:nil];
        NSDictionary *subDic = @{@"lotteryType":minnum(lotSyneModel.msg.lotteryType),@"lotteryInfo":@{@"name":lotSyneModel.msg.lotteryInfo.name?lotSyneModel.msg.lotteryInfo.name:@"",
                                                                                                      @"logo":lotSyneModel.msg.lotteryInfo.logo?lotSyneModel.msg.lotteryInfo.logo:@"",
                                                                                                      @"time":minnum(lotSyneModel.msg.lotteryInfo.time),
                                                                                                      @"sealingTim":minnum(lotSyneModel.msg.lotteryInfo.sealingTim),
                                                                                                      @"issue":minnum(lotSyneModel.msg.lotteryInfo.issue),
                                                                                                      @"stopOrSell":minnum(lotSyneModel.msg.lotteryInfo.stopOrSell),
                                                                                                      @"stopMsg":lotSyneModel.msg.lotteryInfo.stopMsg?lotSyneModel.msg.lotteryInfo.stopMsg:@"",
                                                                                                      @"lotteryType":minnum(lotSyneModel.msg.lotteryInfo.lotteryType),
                                                                                                      @"serTime":minnum(lotSyneModel.msg.lotteryInfo.serTime),
        }};
        if (self.socketDelegate != nil && [self.socketDelegate respondsToSelector:@selector(setLotteryInfo:)]) {
            [self.socketDelegate setLotteryInfo:subDic];
        }
        if (![self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"lotteryInfoNotify" object:nil userInfo:subDic];
        }
    }
    // 开奖
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotteryOpenAward){
        LotteryOpenAward *lotteryAwardModel = [LotteryOpenAward parseFromData:smsgPb.msgData error:nil];
        NSDictionary *dicSub = @{@"action":minnum(lotteryAwardModel.msg.action),
                                 @"winWays":lotteryAwardModel.msg.winWaysArray?[NSArray arrayWithArray:lotteryAwardModel.msg.winWaysArray]:@[],
                                 @"ct":lotteryAwardModel.msg.ct?lotteryAwardModel.msg.ct:@"",
                                 @"msgtype":minnum(lotteryAwardModel.msg.msgtype),
                                 @"lotteryType":minnum(lotteryAwardModel.msg.lotteryType),
                                 @"result":lotteryAwardModel.msg.result?lotteryAwardModel.msg.result:@"",
                                 @"name":lotteryAwardModel.msg.name?lotteryAwardModel.msg.name:@"",
                                 @"issue":minnum(lotteryAwardModel.msg.issue),
                                 @"sum_result_str":lotteryAwardModel.msg.sumResultStr?lotteryAwardModel.msg.sumResultStr:@"",
                                 @"niu":@{@"red_niu":lotteryAwardModel.msg.niu.redNiu?lotteryAwardModel.msg.niu.redNiu:@"",@"blue_niu":lotteryAwardModel.msg.niu.blueNiu?lotteryAwardModel.msg.niu.blueNiu:@""
                                 },
                                 @"lh":@{@"dragon_dian":minnum(lotteryAwardModel.msg.lh.dragonDian),@"tiger_dian":minnum(lotteryAwardModel.msg.lh.tigerDian),@"dragon_dian_str":lotteryAwardModel.msg.lh.dragonDianStr?lotteryAwardModel.msg.lh.dragonDianStr:@"",@"tiger_dian_str":lotteryAwardModel.msg.lh.tigerDianStr?lotteryAwardModel.msg.lh.tigerDianStr:@"",@"whoWin":minnum(lotteryAwardModel.msg.lh.whoWin),@"dragon_tiger_str":lotteryAwardModel.msg.lh.tigerDianStr?lotteryAwardModel.msg.lh.tigerDianStr:@""},// 0:龙胜 1:虎胜 2:和
                                 @"bjl":@{@"zhuang_dian":minnum(lotteryAwardModel.msg.bjl.zhuangDian),@"xian_dian":minnum(lotteryAwardModel.msg.bjl.xianDian),@"zhuang_dian_str":lotteryAwardModel.msg.bjl.zhuangDianStr?lotteryAwardModel.msg.bjl.zhuangDianStr:@"",@"xian_dian_str":lotteryAwardModel.msg.bjl.xianDianStr?lotteryAwardModel.msg.bjl.xianDianStr:@"",@"whoWin":minnum(lotteryAwardModel.msg.bjl.whoWin),@"zhuangxian_str":lotteryAwardModel.msg.bjl.zhuangxianStr?lotteryAwardModel.msg.bjl.zhuangxianStr:@""},// 0:庄胜 1:闲胜 2:和
                                 @"zjh":@{@"pai_type":lotteryAwardModel.msg.zjh.paiTypeArray?lotteryAwardModel.msg.zjh.paiTypeArray:@[],@"pai_type_str":lotteryAwardModel.msg.zjh.paiTypeStrArray?lotteryAwardModel.msg.zjh.paiTypeStrArray:@[],@"whoWin":minnum(lotteryAwardModel.msg.zjh.whoWin)}
                                 
        };
        if (![self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LotteryOpenAward" object:nil userInfo:dicSub];
        }
        
      
        if (self.socketDelegate != nil && [self.socketDelegate respondsToSelector:@selector(addOpenAward:)]) {
            [self.socketDelegate addOpenAward:dicSub];
        }
    }
    // 中奖广播
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotteryProfit){
        LotteryProfit *lotteryProfitModel = [LotteryProfit parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil) {
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                if (strongSelf.socketDelegate&& [strongSelf.socketDelegate respondsToSelector:@selector(setLotteryProfitNot:)]) {
                    [strongSelf.socketDelegate setLotteryProfitNot:lotteryProfitModel];
                }
                if ([strongSelf.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
                    return;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:KBetWinAllUserNotificationMsg object:nil userInfo:@{@"model":lotteryProfitModel}];
            });
        }
        
    }
    // 分红广播
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotteryDividend){
        LotteryDividend *lotteryDividendModel = [LotteryDividend parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil && [self.socketDelegate respondsToSelector:@selector(setLotteryDividendNot:)]) {
            [self.socketDelegate setLotteryDividendNot:lotteryDividendModel];
        }
    }
    // 投注广播
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotteryBet){
        LotteryBet *lotteryBetModel = [LotteryBet parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil && [self.socketDelegate respondsToSelector:@selector(setLotteryBetNot:)]) {
            [self.socketDelegate setLotteryBetNot:lotteryBetModel];
        }
        if ([self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KBetDoNotificationMsg object:nil userInfo:@{@"model":lotteryBetModel}];
    }// 中奖飘屏
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotteryBarrage){
        LotteryBarrage *lotteryBarrageModel = [LotteryBarrage parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(setLotteryBarrage:)]) {
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf.socketDelegate setLotteryBarrage:lotteryBarrageModel];
            });
        }
        if ([self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KBetWinNotificationMsg object:nil userInfo:@{@"model":lotteryBarrageModel}];


       
    }// 中奖飘屏当前用户
    else if (self.socketDelegate && smsgPb.msgId == MsgID_LotteryAward){
        LotteryAward *lotteryAwardModel = [LotteryAward parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(setLotteryAward:)]) {
            [self.socketDelegate setLotteryAward:lotteryAwardModel];
        }
        if (![self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LotteryAwardNotificationMsg" object:nil userInfo:@{@"model":lotteryAwardModel}];
        }
    }
    //送礼物
    else if(smsgPb.msgId == MsgID_SendGift)
    {
        SendGift *sendGiftModel = [SendGift parseFromData:smsgPb.msgData error:nil];
        //        if ([minnum(sendGiftModel.msg.ifpk) isEqual:@"1"]) {
        //            [self.socketDelegate changePkProgressViewValue:msg];
        //            if (![minnum(sendGiftModel.msg.roomnum) isEqual:minstr(_playDocModel.zhuboID)]) {
        //                return;
        //            }
        //        }
        
        NSString *haohualiwu =  [NSString stringWithFormat:@"%@",sendGiftModel.msg.evensend];

        NSString *ctt = @"";
        if (sendGiftModel.msg.ct.type == 3 || sendGiftModel.msg.ct.type == 4) {
            ctt = sendGiftModel.msg.ct.giftname;
        } else {
            ctt = [NSString stringWithFormat:YZMsg(@"Livebroadcast_LiveSend%d_gift%@"),sendGiftModel.msg.ct.giftcount, sendGiftModel.msg.ct.giftname];
        }
        NSString *giftType =minnum(sendGiftModel.msg.ct.type);

        NSString *titleColor = @"2";
        NSString* uname = minstr(sendGiftModel.msg.uname);
        NSString *levell = minnum(sendGiftModel.msg.level);
        NSString *ID = minnum(sendGiftModel.msg.uid);
        NSString *leve = [Config getLevel];
        if ([ID isEqualToString:minstr([Config getOwnID])] && ![levell isEqualToString:[Config getLevel]]) {
            LiveUser *userLive = [Config myProfile];
            userLive.level = ([leve intValue] > [levell intValue])?leve:levell;
            [Config updateProfile:userLive];
            levell = userLive.level;
        }
        NSString *avatar = minstr(sendGiftModel.msg.uhead);
        NSString *vip_type =minnum(sendGiftModel.msg.vipType);
        NSString *liangname =minstr(sendGiftModel.msg.liangname);
        NSString *isUserMsg = @"1";
        NSDictionary *chat6 = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ctt,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",avatar,@"avatar",vip_type,@"vip_type",liangname,@"liangname",isUserMsg,@"isUserMsg", giftType, @"giftType",nil];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:[sendGiftModel.msg.ct mj_keyValues]];
        [infoDic setObject:uname forKey:@"nicename"];
        [infoDic setObject:avatar forKey:@"avatar"];
        
        if (self.socketDelegate != nil && [self.socketDelegate respondsToSelector:@selector(sendGift:andLiansong:andTotalCoin:andGiftInfo:)]) {
            [self.socketDelegate sendGift:chat6 andLiansong:haohualiwu andTotalCoin:minnum(sendGiftModel.msg.ct.votestotal) andGiftInfo:infoDic];
        }
        
    }
    //弹幕
    else if(smsgPb.msgId == MsgID_SendBarrage)
    {
        SendBarrage *sendBarrageModel = [SendBarrage parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(SendBarrage:)]) {
            [self.socketDelegate SendBarrage:sendBarrageModel];
        }
        //        NSLog(@"弹幕接受成功%@",msg);
    }
    //结束直播
    else if(smsgPb.msgId == MsgID_StartEndLive)
    {
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(StartEndLive)]) {
            [self.socketDelegate StartEndLive];
        }
    }
    //断开链接
    else if(smsgPb.msgId == MsgID_Disconnect)
    {
        disconnect *disConnectModel = [disconnect parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(UserDisconnect:)]) {
            [self.socketDelegate UserDisconnect:disConnectModel];
        }
        if (![self.socketDelegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorDisConnect" object:nil];
        }
    }
    //踢人消息
    else if(smsgPb.msgId == MsgID_KickUser)
    {
        KickUser *kickUserModel = [KickUser parseFromData:smsgPb.msgData error:nil];
        NSString* unamessss = [NSString stringWithFormat:@"%u",kickUserModel.msg.touid];
        if([unamessss isEqual:[Config getOwnID]] ){
            if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(kickOK)]) {
                [self.socketDelegate kickOK];
            }
        }
        NSString *titleColor = @"firstlogin";
        NSString *ct = kickUserModel.msg.ct;
        NSString *uname = YZMsg(@"Livebroadcast_LiveMsgs");
        NSString *levell = @" ";
        NSString *ID = @" ";
        NSString *icon = @" ";
        NSString *vip_type = @"0";
        NSString *liangname = @"0";
        NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",icon,@"avatar",vip_type,@"vip_type",liangname,@"liangname",nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(KickUser:)]) {
            [self.socketDelegate KickUser:chat];
        }
    }else if(smsgPb.msgId == MsgID_TranslateContent) // 弹幕翻译
    {
        TranslateContent *translateModel = [TranslateContent parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(transalteMsg:)]) {
            [self.socketDelegate transalteMsg:translateModel];
        }
    } else if (smsgPb.msgId == MsgID_GiveVideoTicket) {
        GiveVideoTicket *model = [GiveVideoTicket parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(giveVideoTicketMessage:)]) {
            [self.socketDelegate giveVideoTicketMessage:model];
        }
    }
    //炸金花//收到主播广播准备开始游戏
    ////收到主播广播准备开始游戏
    //    else if ([method isEqual:@"startGame"] || [method isEqual:@"startLodumaniGame"] || [method isEqual:@"startCattleGame"] ){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        NSString *msgtype = [NSString stringWithFormat:@"%@",[msg valueForKey:@"msgtype"]];
    //        if ([action isEqual:@"1"]) {
    //            //出现游戏界面
    //            [self.socketDelegate prepGameandMethod:method andMsgtype:msgtype];
    //        }
    //        else if ([action isEqual:@"2"]){
    //            if ([method isEqual:@"startCattleGame"]) {
    //                NSDictionary *bankdic = [msg valueForKey:@"bankerlist"];
    //                [self.socketDelegate changeBank:bankdic];
    //            }
    //            //开始发牌
    //            [self.socketDelegate takePoker:[msg valueForKey:@"gameid"] Method:method andMsgtype:msgtype];
    //
    //        }
    //        else if ([action isEqual:@"3"]){
    //            //主播关闭游戏
    //            [self.socketDelegate stopGame];
    //        }
    //        else if ([action isEqual:@"4"]){
    //            //游戏开始 倒数计时
    //            NSString *time = [NSString stringWithFormat:@"%@",[msg valueForKey:@"time"]];//游戏时间
    //            [self.socketDelegate startGame:time andGameID:[msg valueForKey:@"gameid"]];
    //        }
    //        else if ([action isEqual:@"5"]){
    //            //用户投注
    //            NSString *money = [NSString stringWithFormat:@"%@",[msg valueForKey:@"money"]];
    //            NSString *type = [NSString stringWithFormat:@"%@",[msg valueForKey:@"type"]];
    //            [self.socketDelegate getCoin:type andMoney:money];
    //        }else if ([action isEqual:@"6"]){
    //            //开奖
    //            NSArray *ct = [msg valueForKey:@"ct"];
    //            [self.socketDelegate getResult:ct];
    //        }
    //    }
    //    else if ([method isEqual:@"startRotationGame"]){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"1"]) {
    //            //出现游戏界面
    //            [self.socketDelegate prepRotationGame];
    //        }
    //        else if ([action isEqual:@"2"]){
    //
    //
    //        }
    //        else if ([action isEqual:@"3"]){
    //            //主播关闭游戏
    //            [self.socketDelegate stopRotationGame];
    //
    //        }
    //        else if ([action isEqual:@"4"]){
    //            //游戏开始 倒数计时
    //            NSString *time = [NSString stringWithFormat:@"%@",[msg valueForKey:@"time"]];//游戏时间
    //            [self.socketDelegate startRotationGame:time andGameID:[msg valueForKey:@"gameid"]];
    //        }
    //        else if ([action isEqual:@"5"]){
    //            //用户投注
    //            NSString *money = [NSString stringWithFormat:@"%@",[msg valueForKey:@"money"]];
    //            NSString *type = [NSString stringWithFormat:@"%@",[msg valueForKey:@"type"]];
    //            [self.socketDelegate getRotationCoin:type andMoney:money];
    //        }else if ([action isEqual:@"6"]){
    //            //开奖
    //            NSArray *ct = [msg valueForKey:@"ct"];
    //            [self.socketDelegate getRotationResult:ct];
    //        }
    //    }
    //    //二八贝
    //    else if (smsgPb.msgId == MsgID_LotterySync){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        NSString *msgtype = [NSString stringWithFormat:@"%@",[msg valueForKey:@"msgtype"]];
    //        if ([action isEqual:@"1"]) {
    //            //出现游戏界面
    //            [self.socketDelegate shellprepGameandMethod:method andMsgtype:msgtype];
    //        }
    //        else if ([action isEqual:@"2"]){
    //            //开始发牌
    //            [self.socketDelegate shelltakePoker:[msg valueForKey:@"gameid"] Method:method andMsgtype:msgtype];
    //        }
    //        else if ([action isEqual:@"3"]){
    //            //主播关闭游戏
    //            [self.socketDelegate shellstopGame];
    //        }
    //        else if ([action isEqual:@"4"]){
    //            //游戏开始 倒数计时
    //            NSString *time = [NSString stringWithFormat:@"%@",[msg valueForKey:@"time"]];//游戏时间
    //            [self.socketDelegate shellstartGame:time andGameID:[msg valueForKey:@"gameid"]];
    //        }
    //        else if ([action isEqual:@"5"]){
    //            //用户投注
    //            NSString *money = [NSString stringWithFormat:@"%@",[msg valueForKey:@"money"]];
    //            NSString *type = [NSString stringWithFormat:@"%@",[msg valueForKey:@"type"]];
    //            [self.socketDelegate shellgetCoin:type andMoney:money];
    //        }else if ([action isEqual:@"6"]){
    //            //开奖
    //            NSArray *ct = [msg valueForKey:@"ct"];
    //            [self.socketDelegate shellgetResult:ct];
    //        }
    //    }
    //    else if (smsgPb.msgId == MsgID_s){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        //有人上庄
    //        if ([action isEqual:@"1"]) {
    //            NSDictionary *subdic = @{
    //                                     @"uid":[msg valueForKey:@"uid"],
    //                                     @"uhead":[msg valueForKey:@"uhead"],
    //                                     @"uname":[msg valueForKey:@"uname"],
    //                                     @"coin":[msg valueForKey:@"coin"]
    //                                     };
    //            [self.socketDelegate getzhuangjianewmessagedelegatem:subdic];
    //        }
    //    }
    
#pragma mark 连麦
    /*
     1 有人发送连麦请求
     2 主播接受连麦
     3 主播拒绝连麦
     4 用户推流，发送自己的播流地址
     5 用户断开连麦
     6 主播断开连麦
     7 主播正忙碌
     8 主播无响应
     */
    //    else if (smsgPb.msgId == MsgID_ConnectVideo){
    
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"1"]) {
    //            return;
    //        }
    //        if ([action isEqual:@"4"]) {
    //            NSString *uid = [NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]];
    //            if (![uid isEqual:[Config getOwnID]]) {
    //                //不是连麦用户的其他用户播放连麦用户的流
    //                [self.socketDelegate playLinkUserUrl:minstr([msg valueForKey:@"playurl"]) andUid:minstr([msg valueForKey:@"uid"])];
    //            }
    //        }
    //        if ([action isEqual:@"5"]){
    //            [self.socketDelegate hostout];
    //            if (![minstr([msg valueForKey:@"uid"]) isEqual:[Config getOwnID]]) {
    //                [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@",minstr([msg valueForKey:@"uname"]),YZMsg(@"已下麦")]];
    //            }
    //        }
    //        if ([action isEqual:@"6"]) {
    //            [self.socketDelegate hostout];
    //            if ([minstr([msg valueForKey:@"touid"]) isEqual:[Config getOwnID]]) {
    //                [MBProgressHUD showError:YZMsg(@"主播已把你下麦")];
    //            }else{
    //                [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@",minstr([msg valueForKey:@"uname"]),YZMsg(@"已下麦")]];
    //            }
    //        }
    //        NSString *touid = [NSString stringWithFormat:@"%@",[msg valueForKey:@"touid"]];
    //        if ([touid isEqual:[Config getOwnID]]) {
    //            if ([action isEqual:@"2"]) {
    //                //同意连麦
    //                [self.socketDelegate startConnectvideo];
    //            }
    //            else if ([action isEqual:@"3"]){
    //                //拒绝连麦
    //                [MBProgressHUD hideHUD];
    //                [MBProgressHUD showError:YZMsg(@"主播拒绝了连麦请求")];
    //                [self.socketDelegate enabledlianmaibtn];
    //            }
    //
    //            //主播正忙碌
    //            if ([action isEqual:@"7"]) {
    //                [MBProgressHUD hideHUD];
    //                [MBProgressHUD showError:YZMsg(@"主播正忙碌")];
    //                [self.socketDelegate enabledlianmaibtn];
    //            }
    //            //主播未响应
    //            if ([action isEqual:@"8"]) {
    //                [MBProgressHUD hideHUD];
    //                [MBProgressHUD showError:YZMsg(@"当前主播暂时无法接通")];
    //                [self.socketDelegate enabledlianmaibtn];
    //            }
    //            //主播未响应
    //            if ([action isEqual:@"10"]) {
    //                [MBProgressHUD hideHUD];
    //                [MBProgressHUD showError:YZMsg(@"主播未开启连麦功能哦～")];
    //                [self.socketDelegate enabledlianmaibtn];
    //            }
    //
    //        }
    
    //    }
    //购买守护
    else if (smsgPb.msgId == MsgID_BuyGuard){
        BuyGuard *bugGuardModel = [BuyGuard parseFromData:smsgPb.msgData error:nil];
        NSDictionary *guardDic = @{@"action":minnum(bugGuardModel.msg.action),
                                   @"msgtype":minnum(bugGuardModel.msg.msgtype),
                                   @"ct":bugGuardModel.msg.ct?bugGuardModel.msg.ct:@"",
                                   @"uid":minnum(bugGuardModel.msg.uid),
                                   @"uname":bugGuardModel.msg.uname?bugGuardModel.msg.uname:@"",
                                   @"uhead":bugGuardModel.msg.uhead?bugGuardModel.msg.uhead:@"",
                                   @"votestotal":bugGuardModel.msg.strvotestotal,
                                   @"guard_nums":minnum(bugGuardModel.msg.guardNums)
        };
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(updateGuardMsg:)]) {
            [self.socketDelegate updateGuardMsg:guardDic];
        }
    
        NSDictionary *dic = @{@"ct":[NSString stringWithFormat:YZMsg(@"socketLivePlay_who%@_Guard"),minstr(bugGuardModel.msg.uname)]};
        if (self.socketDelegate != nil) {
            [self.socketDelegate socketShowChatSystem:dic];
        }
    }
    //发红包
    else if(smsgPb.msgId == MsgID_SendRed)
    {
        SendRed *sendRedModel = [SendRed parseFromData:smsgPb.msgData error:nil];
        if (sendRedModel.msg.action == 0) {
            if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(showRedbag:)]) {
                [self.socketDelegate showRedbag:sendRedModel];
            }
        }
    }
    //    else if (smsgPb.msgId == MsgID_LiveConnect){
    //        LiveConnect *liveConnectModel = [LiveConnect parseFromData:smsgPb.data error:nil];
    //        //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
    //        int action = liveConnectModel.msg.action;
    //        switch (action) {
    //                case 4:
    ////                    [self.socketDelegate anchor_agreeLink:msg];
    //                break;
    //                case 5:
    //                    [MBProgressHUD showError:YZMsg(@"连麦已断开")];
    //                    [self.socketDelegate anchor_stopLink:msg];
    //                break;
    //            default:
    //                break;
    //        }
    //    }
    //else if (smsgPb.msgId == MsgID_LivePk){
    //        LivePK *livePk = [LivePK parseFromData:smsgPb.data error:nil];
    //        //1：发起PK；2；接受PK；3:拒绝PK；4：PK成功通知；5.;7:对方正忙碌 8:对方无响应 9:PK结果
    //        int action = livePk.msg.action;
    //        switch (action) {
    //                case 4:
    //                [self.socketDelegate showPKView:nil];
    //                break;
    //                case 9:
    //                    [self.socketDelegate showPKResult:livePk];
    //                break;
    //
    //            default:
    //                break;
    //        }
    //    }
    else if (smsgPb.msgId == MsgID_AppTopNotice) {
        AppTopNotice *model = [AppTopNotice parseFromData:smsgPb.msgData error:nil];
        if (self.socketDelegate != nil&& [self.socketDelegate respondsToSelector:@selector(giveAppTopNotice:)]) {
            [self.socketDelegate giveAppTopNotice:model];
        }
    }
    
}
//游戏押注
-(void)stakePoke:(NSString *)type andMoney:(NSString *)money andMethod:(NSString *)method andMsgtype:(NSString *)msgtype{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": method,
                    @"action": @"5",
                    @"msgtype":msgtype,
                    @"type":type,
                    @"money":money,
                    @"uid":[Config getOwnID]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//转盘押注
-(void)stakeRotationPoke:(NSString *)type andMoney:(NSString *)money{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"startRotationGame",
                    @"action": @"5",
                    @"msgtype":@"16",
                    @"type":type,
                    @"money":money,
                    @"uid":[Config getOwnID]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//发送竞拍消息
-(void)sendmyjingpaimessage:(NSString *)money{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"auction",
                    @"action": @"2",
                    @"msgtype":@"55",
                    @"money":money,
                    @"uname":[Config getOwnNicename],
                    @"uid":[Config getOwnID],
                    @"uhead":[Config getavatar]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//注销socket
-(void)socketStop{
    if (managerSocket) {
        [managerSocket disconnect];
        managerSocket = nil;
    }
    if (_ChatSocket) {
        [_ChatSocket disconnect];
        [_ChatSocket off:@""];
        _ChatSocket = nil;
    }
}

#pragma mark ----- 发送socket
//红包
-(void)sendRed:(NSString *)money andNodejsInfo:(NSMutableArray *)nodejsInfo{
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=User.sendRed"];
    NSDictionary *subDic = @{@"uid":[Config getOwnID],@"touid":self.playDocModel.zhuboID,@"money":money,@"token":[Config getOwnToken]};
    WeakSelf
    [YBNetworking getNetWorkWithUrl:url andParameter:subDic success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        if(code == 0)
        {
            NSArray *info = infos;
            NSString *coin = [info valueForKey:@"coin"];
            NSString *level = [info valueForKey:@"level"];
            //刷新本地魅力值
            strongSelf->users.coin = [NSString stringWithFormat:@"%@",coin];
            [Config updateProfile:strongSelf->users];
            if (strongSelf.socketDelegate != nil) {
                [strongSelf.socketDelegate reloadChongzhi:coin];
            }
            NSArray *msgData =@[
                @{
                    @"msg": @[
                        @{
                            @"_method_": @"SendRed",
                            @"action": @"0",
                            @"ct":[info valueForKey:@"gifttoken"],
                            @"msgtype": @"1",
                            @"timestamp": @"",
                            @"tougood": @"",
                            @"touid": @"0",
                            @"touname": @"",
                            @"ugood":@"",
                            @"uid": [Config getOwnID],
                            @"uname": [Config getOwnNicename],
                            @"equipment": @"app",
                            @"roomnum": strongSelf.playDocModel.zhuboID,
                            @"level":level,
                            @"city":@"",
                            @"evensend":@"n",
                            @"usign":@"",
                            @"uhead":@"",
                            @"sex":@"",
                            @"vip_type":[Config getVip_type],
                            @"liangname":[Config getliang]
                        }
                    ],
                    @"retcode": @"000000",
                    @"retmsg": @"OK"
                }
            ];
            if (strongSelf.ChatSocket != nil) {
                [strongSelf.ChatSocket emit:@"broadcast" with:msgData];
            }
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:error.localizedDescription];
    }];
}
//点亮
-(void)starlight:(NSString *)level :(NSNumber *)num andUsertype:(NSString *)usertype andGuardType:(NSString *)guardType{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"SendMsg",
                    @"action": @"0",
                    @"ct": YZMsg(@"socketLivePlay_Light"),
                    @"msgtype": @"2",
                    @"uid": [Config getOwnID]?:@"",
                    @"uname": [Config getOwnNicename]?:@"",
                    @"equipment": @"app",
                    @"roomnum": self.playDocModel.zhuboID?:@"",
                    @"level":level?:@"",
                    @"heart":num?:@"",
                    @"vip_type":[Config getVip_type]?:@"",
                    @"liangname":[Config getliang]?:@"",
                    @"usertype":usertype?:@"",
                    @"guard_type":guardType?:@""
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//关注主播
-(void)attentionLive{
    NSString *content = YZMsg(@"socketLivePlay_Followed");
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"SystemNot",
                    @"action": @"13",
                    @"ct":content,
                    @"msgtype": @"4",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touid": @"0",
                    @"city":@"",
                    @"touname": @"",
                    @"ugood": @"",
                    @"uid": [Config getOwnID],
                    @"uname": YZMsg(@"Livebroadcast_LiveMsgs"),
                    @"equipment": @"app",
                    @"roomnum": self.playDocModel.zhuboID,
                    @"usign":@"",
                    @"uhead":@"",
                    @"level":[Config getLevel],
                    @"sex":@""
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//房间关闭
-(void)superStopRoom{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"stopLive",
                    @"action": @"19",
                    @"ct":@"",
                    @"msgtype": @"1",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touid": @"0",
                    @"touname": @"",
                    @"ugood": [Config getOwnID],
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum":self.playDocModel.zhuboID,
                    @"usign":@"",
                    @"uhead":users.avatar,
                    @"level":[Config getLevel],
                    @"city":@"",
                    @"sex":@""
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];}
//发送消息
-(void)sendmessage:(NSString *)text andLevel:(NSString *)level andUsertype:(NSString *)usertype andGuardType:(NSString *)guardType{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_":@"SendMsg",
                    @"action":@"0",
                    @"ct":text,
                    @"msgtype":@"2",
                    @"timestamp":@"",
                    @"tougood":@"",
                    @"touid":@"0",
                    @"city":@"",
                    @"touname":@"",
                    @"ugood":@"",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"equipment":@"app",
                    @"roomnum":self.playDocModel.zhuboID,
                    @"usign":@"",
                    @"uhead":@"",
                    @"level":level,
                    @"sex":@"",
                    @"vip_type":[Config getVip_type],
                    @"liangname":[Config getliang],
                    @"isAnchor":@"0",
                    @"usertype":usertype,
                    @"guard_type":guardType
                }
            ],
            @"retcode":@"000000",
            @"retmsg":@"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//送礼物
-(void)sendGift:(NSString *)level andINfo:(NSString *)info andlianfa:(NSString *)lianfa{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"SendGift",
                    @"action": @"0",
                    @"ct":info ,
                    @"msgtype": @"1",
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum": self.playDocModel.zhuboID,
                    @"level":level,
                    @"evensend":lianfa,
                    @"uhead":users.avatar,
                    @"vip_type":[Config getVip_type],
                    @"liangname":[Config getliang]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//禁言
-(void)shutUp:(NSString *)name andID:(NSString *)ID{
    NSArray* jinyanArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":@"ShutUpUser",
                    @"action":@"1",
                    @"ct":[NSString stringWithFormat:YZMsg(@"socketLivePlay_Who%@_time%@"),name,_shut_time],
                    @"uid":[Config getOwnID],
                    @"touid":ID,
                    @"showid":[Config getOwnID],
                    @"uname":@"",
                    @"msgtype":@"4",
                    @"timestamp":@"",
                    @"tougood":@"",
                    @"touname":@"",
                    @"ugood":@""
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"}];
    
    [MBProgressHUD showError:YZMsg(@"socketLivePlay_DisableSendMsgSuccess")];
    [_ChatSocket emit:@"broadcast" with:jinyanArray];
}
//请求同步彩票信息
-(void)sendSyncLotteryCMD:(NSString *)lotteryType{
    NSArray* sendArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":@"lotteryInfo",
                    @"lotteryType":lotteryType,
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"
        }
    ];
    
    [_ChatSocket emit:@"broadcast" with:sendArray];
}

// 请求同步彩票开奖信息
-(void)sendSyncOpenAwardCMD:(NSString *)lotteryType{
    NSArray* sendArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":@"openAward",
                    @"lotteryType":lotteryType,
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"
        }
    ];
    
    [_ChatSocket emit:@"broadcast" with:sendArray];
}

//踢人
-(void)kickuser:(NSString *)name andID:(NSString *)ID{
    NSArray* jinyanArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":@"KickUser",
                    @"action":@"2",
                    @"ct":[NSString stringWithFormat:YZMsg(@"socketLivePlay_Kick%@Room"),name],
                    @"uid":[Config getOwnID],
                    @"touid":ID,
                    @"showid":[Config getOwnID],
                    @"uname":@"",
                    @"msgtype":@"4",
                    @"timestamp":@"",
                    @"tougood":@"",
                    @"touname":@"",
                    @"ugood":@""
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"}];
    [MBProgressHUD showError:YZMsg(@"socketLivePlay_KickSuccess")];
    [_ChatSocket emit:@"broadcast" with:jinyanArray];
}
//发送联系方式
-(void)sendContactInfo:(NSString *)contactInfo andID:(NSString *)uid{
    NSArray* contactInfoArray = @[
        @{
            @"msg":
                @[@{
                    @"_method_":@"SendContactInfo",
                    @"action":@"2",
                    @"ct":[NSString stringWithFormat:@"%@",contactInfo],
                    @"uid":[Config getOwnID],
                    @"touid":uid,
                }],
            @"retcode":@"000000",
            @"retmsg":@"OK"}];
    [MBProgressHUD showError:YZMsg(@"loginActivity_sendsuccess")];
    [_ChatSocket emit:@"broadcast" with:contactInfoArray];
}
//弹幕
-(void)sendBarrage:(NSString *)level andmessage:(NSString *)test{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"SendBarrage",
                    @"action": @"7",
                    @"ct":test ,
                    @"msgtype": @"1",
                    @"ugood": [Config getOwnID],
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"roomnum": self.playDocModel.zhuboID,
                    @"level":[Config getLevel],
                    @"uhead":users.avatar,
                    @"vip_type":[Config getVip_type],
                    @"liangname":[Config getliang]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//点亮
-(void)starlight{
    //NSLog(@"发送了点亮消息");
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"light",
                    @"action": @"2",
                    @"msgtype": @"0",
                    @"timestamp": @"",
                    @"tougood": @"",
                    @"touname": @"",
                    @"ugood": @"",
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
//弹幕翻译
-(void)sendTranslateMsg:(NSString*)msgContent{
    
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"TranslateContent",
//                    @"action":@"1",
//                    @"msgtype": @"3",
                    @"content":msgContent
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}


//僵尸粉
-(void)getZombie{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"requestFans",
                    @"timestamp":@"",
                    @"msgtype": @"0",
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
#pragma mark 连麦+声网
//连麦socket
-(void)sendlianmaicoin{
    NSArray *msgData2 =@[
        @{
            @"msg": @[
                @{
                    @"_method_":@"ConnectVideo",
                    @"action": @"5",
                    @"msgtype": @"10",
                    @"uid":[Config getOwnID],
                    @"uname": [Config getOwnNicename],
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData2];
}
-(void)xiamaisocket{
    NSArray *msgData2 =@[
        @{
            @"msg": @[
                @{
                    @"_method_":@"ConnectVideo",
                    @"action": @"4",
                    @"msgtype": @"10",
                    @"uid":[Config getOwnID],
                    @"uname": [Config getOwnNicename],
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData2];
}
//上庄
-(void)getzhuangjianewmessagem:(NSDictionary *)subdic{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_":@"shangzhuang",
                    @"action":@"1",
                    @"msgtype":@"25",
                    @"uid":[subdic valueForKey:@"uid"],
                    @"uhead":[subdic valueForKey:@"uhead"],
                    @"uname":[subdic valueForKey:@"uname"],
                    @"coin":[subdic valueForKey:@"coin"]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}

//第一次进入 扣费 ，广播其他人增加映票
-(void)addvotesenterroom:(NSString *)votes{
    type_val = votes;
    
}

//增加映票
-(void)addvotes:(NSString *)votes isfirst:(NSString *)isfirst{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"updateVotes",
                    @"action":@"1",
                    @"votes":votes,
                    @"msgtype": @"26",
                    @"uid":[Config getOwnID],
                    @"isfirst":isfirst
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}

#pragma mark ================ 连麦 ===============
-(void)sendSmallURL:(NSString *)playUrl andID:(NSString *)userID{
    
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"ConnectVideo",
                    @"action":@"4",
                    @"msgtype": @"10",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"playurl":playUrl
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
    
    
}
-(void)closeConnect{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"ConnectVideo",
                    @"action":@"5",
                    @"msgtype": @"10",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
}
-(void)connectvideoToHost{
    LiveUser *cuser = [Config myProfile];
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"ConnectVideo",
                    @"action":@"1",
                    @"msgtype": @"10",
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"uhead":[Config getavatarThumb],
                    @"level":cuser.level,
                    @"sex":[Config getSex]
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
    
}
- (void)alertShowMsg:(NSString *)msg andTitle:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark ================ 守护 ===============
- (void)buyGuardSuccess:(NSDictionary *)dic{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"BuyGuard",
                    @"action":@"0",
                    @"msgtype": @"0",
                    @"ct":YZMsg(@"socketLivePlay_whoGuard"),
                    @"uid":[Config getOwnID],
                    @"uname":[Config getOwnNicename],
                    @"uhead":[Config getavatarThumb],
                    @"votestotal":minstr([dic valueForKey:@"votestotal"]),
                    @"guard_nums":minstr([dic valueForKey:@"guard_nums"])
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
    
}
- (void)fahongbaola{
    NSArray *msgData =@[
        @{
            @"msg": @[
                @{
                    @"_method_": @"SendRed",
                    @"action": @"0",
                    @"ct":YZMsg(@"socketLivePlay_SendRedbag"),
                    @"msgtype": @"0",
                    @"timestamp": @"",
                    @"touid": @"0",
                    @"ugood": [Config getOwnID],
                    @"uid": [Config getOwnID],
                    @"uname": [Config getOwnNicename],
                    @"equipment": @"app",
                    @"uhead":users.avatar,
                    @"level":[Config getLevel],
                    @"vip_type":[Config getVip_type],
                    @"liangname":[Config getliang],
                    @"isAnchor":@"0",
                }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [_ChatSocket emit:@"broadcast" with:msgData];
    
}

//监听切换房间
-(void)changeMtype:(NSString *)type money:(NSString *)money
{
    
}

#pragma mark - 主播指令跳蛋指令
- (void)getLiveToyInfo:(LiveToyInfInfoType)type uid:(NSString*)uid Handler:(getResults)handler {
    NSString *typeString = @"";
    switch (type) {
        case LiveToyInfoRemoteControllerForToy:
            typeString = @"3";
            break;
        case LiveToyInfoRemoteControllerForAnchorman:
            typeString = @"4";
            break;
        default:
            return;
    }
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=Live.getLiveToyInfo"];
    NSDictionary *subDic  = @{@"type": typeString, @"live_uid": uid};
    if (typeString && [typeString isEqualToString:@"3"]) {
        subDic  = @{@"type": typeString};
    }
   
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:subDic data:nil success:^(int code, NSArray *infos, NSString *msg) {
        NSLog(@"====%@", infos);
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0) {
            handler(infos);
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

@end
