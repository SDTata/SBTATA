//
//  socketLive.m
//  yunbaolive
//
//  Created by 王敏欣 on 2017/1/24.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "socketLive.h"
#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "Common.pbobjc.h"
#import <stdatomic.h>

@implementation socketLive
{
    int lianmaitime;//连麦的请求时间10s
    NSTimer *lianmaitimer;//连麦计时10s
    UIAlertView *connectAlert;
    NSString *connectID;
    BOOL isLianMai;
    NSString *connectUserName;
    BOOL isPK;
    SocketManager *ChatSocketManager;
    NSString *webSocketURL;
    BOOL isCOnnaaa;
}

-(void)sendjiangpaimessage:(NSString *)type
{
    
}
-(void)replyConnectvideo:(NSString *)action andAudienceID:(NSString *)uid
{
    
}
-(void)closevideo:(NSString *)ID
{
    
}
-(void)zhaJinHua:(NSString *)gameid andTime:(NSString *)time andJinhuatoken:(NSString *)Jinhuatoken ndMethod:(NSString *)method andMsgtype:(NSString *)msgtype{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": method,
                        @"action": @"4",
                        @"msgtype": msgtype,
                        @"liveuid":[Config getOwnID],
                        @"gameid":gameid,
                        @"time":time,
                        @"token":Jinhuatoken
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//主播发送通知用户开始游戏 展示游戏界面
-(void)prepGameandMethod:(NSString *)method andMsgtype:(NSString *)msgtype{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_":method,
                        @"action": @"1",
                        @"msgtype":msgtype,
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//开始发牌
-(void)takePoker:(NSString *)gameid ndMethod:(NSString *)method andMsgtype:(NSString *)msgtype andBanklist:(NSDictionary *)banklist{
    if (banklist != nil) {
        NSArray *msgData =@[
            @{
                @"msg": @[
                        @{
                            @"_method_": method,
                            @"action": @"2",
                            @"msgtype":msgtype,
                            @"gameid":gameid,
                            @"bankerlist":banklist
                        }
                ],
                @"retcode": @"000000",
                @"retmsg": @"OK"
            }
        ];
        [ChatSocket emit:@"broadcast" with:msgData];
    }
    else{
        NSArray *msgData =@[
            @{
                @"msg": @[
                        @{
                            @"_method_": method,
                            @"action": @"2",
                            @"msgtype":msgtype,
                            @"gameid":gameid,
                        }
                ],
                @"retcode": @"000000",
                @"retmsg": @"OK"
            }
        ];
        [ChatSocket emit:@"broadcast" with:msgData];
    }
}
-(void)stopGamendMethod:(NSString *)method andMsgtype:(NSString *)msgtype{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": method,
                        @"action": @"3",
                        @"msgtype":msgtype,
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//出现界面
-(void)prepRotationGame{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"startRotationGame",
                        @"action": @"1",
                        @"msgtype":@"16",
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//停止游戏
-(void)stopRotationGame{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"startRotationGame",
                        @"action": @"3",
                        @"msgtype":@"16",
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//开始倒计时
-(void)RotatuonGame:(NSString *)gameid andTime:(NSString *)time androtationtoken:(NSString *)rotationtoken{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"startRotationGame",
                        @"action": @"4",
                        @"msgtype": @"16",
                        @"liveuid":[Config getOwnID],
                        @"gameid":gameid,
                        @"time":time,
                        @"token":rotationtoken
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//开奖
-(void)sendMessage:(NSString *)text{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"SendMsg",
                        @"action": @"0",
                        @"ct":text,
                        @"msgtype": @"2",
                        @"timestamp": @"",
                        @"touid": @"0",
                        @"ugood": [Config getOwnID],
                        @"uid": [Config getOwnID],
                        @"uname": [Config getOwnNicename],
                        @"equipment": @"app",
                        @"uhead":user.avatar,
                        @"level":[Config getLevel],
                        @"vip_type":[Config getVip_type],
                        @"liangname":[Config getliang],
                        @"isAnchor":@"1",
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
    
}
-(void)sendBarrage:(NSString *)info{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"SendBarrage",
                        @"action": @"7",
                        @"ct":info ,
                        @"msgtype": @"1",
                        @"timestamp": @"",
                        @"tougood": @"",
                        @"touid": @"0",
                        @"touname": @"",
                        @"ugood": [Config getOwnID],
                        @"uid": [Config getOwnID],
                        @"uname": [Config getOwnNicename],
                        @"equipment": @"app",
                        @"roomnum": [Config getOwnID],
                        @"level":[Config getLevel],
                        @"usign":@"",
                        @"uhead":user.avatar,
                        @"sex":@"",
                        @"city":@"",
                        @"vip_type":[Config getVip_type],
                        @"liangname":[Config getliang]
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    
    [ChatSocket emit:@"broadcast" with:msgData];
}
-(void)shutUp:(NSString *)ID andName:(NSString *)name{
    
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
    [ChatSocket emit:@"broadcast" with:jinyanArray];
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
    
    [ChatSocket emit:@"broadcast" with:sendArray];
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
    
    [ChatSocket emit:@"broadcast" with:sendArray];
}
-(void)kickuser:(NSString *)ID andName:(NSString *)name{
    
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
    [ChatSocket emit:@"broadcast" with:jinyanArray];
}

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
    if ([PublicObj checkNull:contactInfo]) {
        [MBProgressHUD showError:YZMsg(@"loginActivity_senderrorretry")];
        return;
    }else{
        [MBProgressHUD showSuccess:YZMsg(@"loginActivity_sendsuccess")];
    }
   
    [ChatSocket emit:@"broadcast" with:contactInfoArray];
}

-(void)setAdminID:(NSString *)ID andName:(NSString *)name andCt:(NSString *)ct{
    NSString *cts;
    if ([ct isEqual:@"0"]) {
        //不是管理员
        cts = YZMsg(@"socketLive_BecloseManager");
        [MBProgressHUD showError:YZMsg(@"socketLive_closeManagerSuceess")];
    }else{
        //是管理员
        cts = YZMsg(@"socketLive_BeManager");
        [MBProgressHUD showError:YZMsg(@"socketLive_setManagerSuceess")];
    }
    
    NSArray *guanliArray =@[
        @{
            @"msg":@[
                    @{
                        @"_method_":@"setAdmin",
                        @"action":ct,
                        @"ct":[NSString stringWithFormat:@"%@%@",name,cts],
                        @"msgtype":@"1",
                        @"uid":[Config getOwnID],
                        @"uname":YZMsg(@"Livebroadcast_LiveMsgs"),
                        @"touid":ID,
                        @"touname":name
                    }
            ],
            @"retcode":@"000000",
            @"retmsg":@"ok"
        }
    ];
    [ChatSocket emit:@"broadcast" with:guanliArray];
}
-(void)getZombie{
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"requestFans",
                        @"timestamp":@"",
                        @"msgtype": @"0",
                        @"action":@"3"
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
-(void)phoneCall:(NSString *)message{
    NSLog(@"lalala");
    NSArray *guanliArray =@[
        @{
            @"msg":@[
                    @{
                        @"_method_":@"SystemNot",
                        @"action":@"13",
                        @"ct":message,
                        @"msgtype":@"4",
                        @"uid":@"",
                        @"uname":YZMsg(@"Livebroadcast_LiveMsgs"),
                        @"touid":@"",
                        @"touname":@""
                    }
            ],
            @"retcode":@"000000",
            @"retmsg":@"ok"
        }
    ];
    [ChatSocket emit:@"broadcast" with:guanliArray];
}
-(void)closeRoom{
    NSArray *msgData1 =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"StartEndLive",
                        @"action": @"18",
                        @"ct":YZMsg(@"socketLive_CloseLive"),
                        @"msgtype": @"1",
                        @"timestamp": @"",
                        @"tougood": @"",
                        @"touid": @"",
                        @"touname": @"",
                        @"ugood": @"",
                        @"uid": [Config getOwnID],
                        @"uname": [Config getOwnNicename],
                        @"equipment": @"app",
                        @"roomnum": [Config getOwnID]
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData1];
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"SendMsg",
                        @"action": @"18",
                        @"ct":YZMsg(@"socketLive_CloseLive"),
                        @"msgtype": @"1",
                        @"timestamp": @"",
                        @"tougood": @"",
                        @"touid": @"",
                        @"touname": @"",
                        @"ugood":@"",
                        @"uid": [Config getOwnID],
                        @"uname": [Config getOwnNicename],
                        @"equipment": @"app",
                        @"roomnum": [Config getOwnID]
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
-(void)colseSocket{
    // 调用统一的 socketStop 方法来安全关闭 Socket
    [self socketStop];
}
-(void)getshut_time:(NSString *)shut_time{
    
    _shut_time = [NSString stringWithFormat:@"%@",shut_time];
}

-(void)reconnectByProxyWebsocket:(NSString *)socketUrl andTimeString:(NSString*)timestring{
    
    // 使用静态锁对象确保线程安全
    static dispatch_once_t onceToken;
    static NSObject *reconnectLock = nil;
    dispatch_once(&onceToken, ^{
        reconnectLock = [[NSObject alloc] init];
    });
    
    // 使用原子操作检查并设置重连状态，避免多线程并发重连
    static atomic_bool isReconnecting = ATOMIC_VAR_INIT(false);
    bool expected = false;
    if (!atomic_compare_exchange_strong(&isReconnecting, &expected, true)) {
        NSLog(@"Socket正在重连中，忽略重复请求");
        return;
    }
    
    // 设置本地标志，用于后续重置
    @synchronized(reconnectLock) {
        isCOnnaaa = YES;
    }
    
    WeakSelf
    
    // 判断是否使用加速服务
    BOOL isForceSHild = YES;
    if ((webSocketURL!= nil && webSocketURL.length>0 && [webSocketURL containsString:@"127.0.0"])) {
        isForceSHild = false;
    }
    
    if (isForceSHild) {
        // 使用域名管理器获取最佳代理服务器
        [[DomainManager sharedInstance] getWebSocketProxyCallback:^(NSString *bestDomain) {
            STRONGSELF
            if (strongSelf == nil) {
                // 如果对象已释放，重置重连标志并返回
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized(reconnectLock) {
                        isCOnnaaa = NO;
                    }
                });
                return;
            }
            
            // 在主线程执行重连操作
            dispatch_main_async_safe(^{
                // 先关闭旧连接，再创建新连接
                if (bestDomain != nil) {
                    // 只调用一次socketStop
                    [strongSelf socketStop];
                    [strongSelf addNodeListen:bestDomain andTimeString:timestring];
                } else {
                    [strongSelf socketStop];
                    if (strongSelf.zhuboModel != nil) {
                        [strongSelf addNodeListen:strongSelf.zhuboModel.chatserver andTimeString:timestring];
                    } else {
                        [strongSelf addNodeListen:strongSelf->webSocketURL andTimeString:timestring];
                    }
                }
                
                // 重连完成后重置标志
                @synchronized(reconnectLock) {
                    strongSelf->isCOnnaaa = NO;
                }
                atomic_store(&isReconnecting, false);
            });
        }];
    } else {
        // 不使用加速服务的情况
        // 只调用一次socketStop
        [self socketStop];
        
        if (self.zhuboModel != nil) {
            [self addNodeListen:self.zhuboModel.chatserver andTimeString:timestring];
        } else {
            [self addNodeListen:webSocketURL andTimeString:timestring];
        }
        
        // 重连完成后重置标志
        @synchronized(reconnectLock) {
            isCOnnaaa = NO;
        }
        atomic_store(&isReconnecting, false);
    }
    
    // 添加安全机制，确保即使回调失败也能重置标志
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        @synchronized(reconnectLock) {
            if (strongSelf->isCOnnaaa) {
                NSLog(@"Socket重连超时，重置重连标志");
                strongSelf->isCOnnaaa = NO;
                atomic_store(&isReconnecting, false);
            }
        }
    });
}
long long millisecondsPing1 = 0;
-(void)addNodeListen:(NSString *)socketUrl andTimeString:(NSString *)timestring{
    // 使用静态锁对象确保线程安全
    static dispatch_once_t onceToken;
    static NSObject *initLock = nil;
    dispatch_once(&onceToken, ^{
        initLock = [[NSObject alloc] init];
    });
    
    // 在锁内初始化Socket连接，避免多线程并发初始化
    @synchronized(initLock) {
        lianmaitime = 10;
        isbusy = NO;
        user = [Config myProfile];
        NSString *serverUrl = socketUrl;
        
        webSocketURL = serverUrl;
        NSURL* url = [[NSURL alloc] initWithString:serverUrl];
        
        if (url == nil) {
            NSLog(@"Socket URL无效: %@", serverUrl);
            return;
        }
        
        // 先确保旧的Socket连接已经完全关闭
        // 注意：需要在主线程执行socketStop，避免跨线程操作
        if (ChatSocketManager != nil || ChatSocket != nil) {
            if ([NSThread isMainThread]) {
                [self socketStop];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self socketStop];
                });
            }
        }
        
        // 预先获取请求头，避免在初始化时多线程调用getSignProxy
        NSString *signProxy = [YBToolClass getSignProxy];
        
        // 创建Socket配置 - 根据SocketEngine.swift中的发现，简化配置
        // 注意：SocketEngine内部会忽略pingInterval和pingTimeout，使用硬编码值2000和4000
        NSDictionary *socketConfig = @{
            @"log": @NO,
            @"forcePolling": @YES,
            @"forceWebsockets": @YES,
            @"compress": @YES,
            @"extraHeaders": @{@"X-AspNet-Version": signProxy ?: @""},
            @"reconnectWait": @5,    // 整数类型
            @"reconnects": @1        // 整数类型
        };
        
        NSLog(@"Socket配置: %@", socketConfig);
        
        @try {
            ChatSocketManager = [[SocketManager alloc] initWithSocketURL:url config:socketConfig];
            NSLog(@"SocketManager初始化成功");
        } @catch (NSException *exception) {
            NSLog(@"SocketManager初始化异常: %@", exception);
            // 尝试使用最简单的配置
            ChatSocketManager = [[SocketManager alloc] initWithSocketURL:url config:@{
                @"reconnects": @1,
                @"reconnectWait": @5,
                @"extraHeaders": @{@"X-AspNet-Version": signProxy ?: @""}
            }];
        }
        ChatSocket = [ChatSocketManager socketForNamespace:@"/pb"];
    }
    
    // 准备连接参数
    NSArray *cur = @[@{
        @"username": [Config getOwnNicename],
        @"uid": [Config getOwnID],
        @"token": [Config getOwnToken],
        @"roomnum": [Config getOwnID],
        @"stream": timestring,
    }];
    
    WeakSelf
    
    // 设置连接超时处理
    [ChatSocket connectWithTimeoutAfter:2 withHandler:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"socket.io timeout -- ");
        
        // 连接超时，尝试重连
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf reconnectByProxyWebsocket:socketUrl andTimeString:timestring];
        });
    }];
    
    // 设置连接成功回调
    [ChatSocket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        // 确保ChatSocket仍然有效
        if (strongSelf->ChatSocket) {
            [strongSelf->ChatSocket emit:@"conn" with:cur];
            NSLog(@"socket链接成功");
        }
    }];
    [ChatSocket on:@"conn" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"进入房间");
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf getZombie];
        // 检查 ChatSocket 是否仍然有效，避免野指针崩溃
        if (strongSelf->ChatSocket) {
            [strongSelf->ChatSocket emit:@"ping" with:@[]];
        }
    }];
    [ChatSocket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        //        [strongSelf reconnectByProxyWebsocket:socketUrl andTimeString:timestring];
        NSLog(@"socket.io disconnect---%@",data);
    }];
    
    [ChatSocket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"socket.io error -- %@",data);
        if (data && data.count > 0 && ([minstr(data[0]) rangeOfString:@"Invalid HTTP upgrade"].location!=NSNotFound)) {
            return;
        }
        [strongSelf reconnectByProxyWebsocket:socketUrl andTimeString:timestring];
    }];
    
    long long millisecondsPong = 0;
    
    [ChatSocket on:@"ping" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        millisecondsPing1 = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
       
    }];
    
    [ChatSocket on:@"pong" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        long long millisecondsPong = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        long long delayTime = millisecondsPong - millisecondsPing1;

        if (strongSelf.delegate != nil) {
            [strongSelf.delegate timeDelayUpdate:delayTime];
        }

    }];
    
    [ChatSocket on:@"broadcastingListen" callback:^(NSArray* data, SocketAckEmitter* ack) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if([data[0] isKindOfClass:[NSString class]] && [data[0] isEqual:@"stopplay"])
        {
            NSLog(@"%@",[data[0] firstObject]);
            if (strongSelf.delegate) {
                [strongSelf.delegate superStopRoom:@""];
            }

            UIAlertView  *alertsLimit = [[UIAlertView alloc]initWithTitle:YZMsg(@"ocketLive_droppedLive") message:nil delegate:strongSelf cancelButtonTitle:YZMsg(@"publictool_sure") otherButtonTitles:nil, nil];
            [alertsLimit show];
            return ;
        }

        for (NSData *pbData in data) {
            if ([pbData isKindOfClass:[NSNull class]]|| pbData == nil || ([pbData isKindOfClass:[NSString class]] && [PublicObj checkNull:(NSString*)pbData])) {
                return;
            }
            StreamMsg *smsgPb = [StreamMsg parseFromData:pbData error:nil];
            [strongSelf getmessage:smsgPb];

        }


    }];
}

//注销socket
-(void)socketStop{
    // 使用静态锁对象确保线程安全
    static dispatch_once_t onceToken;
    static NSObject *socketLock = nil;
    dispatch_once(&onceToken, ^{
        socketLock = [[NSObject alloc] init];
    });

    // 在锁内执行所有操作，防止多线程并发访问导致崩溃
    @synchronized(socketLock) {
        // 先检查是否为nil，避免重复关闭
        if (ChatSocketManager) {
            [ChatSocketManager disconnect];
            ChatSocketManager = nil;
        }

        if (ChatSocket) {
            // 先移除所有事件监听，再断开连接，最后释放资源
            [ChatSocket off:@""];
            [ChatSocket disconnect];
            [ChatSocket leaveNamespace];
            ChatSocket = nil;
        }
    }
}

-(void)getmessage:(StreamMsg *)smsgPb{
    if (self.delegate == nil) {
        return;
    }
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
            if (self.delegate) {
                [self.delegate getZombieList:fansA];
            }
            
        }
    }
    
    //增加映票
    else if (smsgPb.msgId == MsgID_UpdateVotes){
        updateVotes *msg = [updateVotes parseFromData:smsgPb.msgData error:nil];
        if (msg.msg.msgtype == 26)
        {
          
            if (self.delegate) {
                [self.delegate addvotesdelegate:msg.msg.strvotestotal];
            }
        
        }
    }
    //会话消息
    if (smsgPb.msgId == MsgID_SendMsg) {
        //SendMsg   msgtype  26  votes
        SendMsg *msg = [SendMsg parseFromData:smsgPb.msgData error:nil];
        if (msg.msg.msgtype == 0 && msg.msg.action == 0  && msg.msg.ct.id_p==0 && [msg.retmsg isEqualToString:@"OK"]) {
            return;
        }
        if (msg.retcode == 409002) {
            [MBProgressHUD showError:YZMsg(@"socketLive_silenced")];
            return;
        }
        if(msg.msg.msgtype == 2)
        {
            NSString* ct;
            NSDictionary *heartDic = [msg.msg.ct mj_keyValues];
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
                NSString *king_icon =![msg.msg.ct.kingIcon isEqual:@"null"]?msg.msg.ct.kingIcon:@"";
                NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",usertype,@"usertype",guardType,@"guard_type",king_icon,@"king_icon",nil];
                if (self.delegate) {
                    
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
                        if (![PublicObj checkNull:msg.msg.ct.kingIcon]) {
                            
                            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:msg.msg.ct.kingIcon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               
                                if (strongSelf == nil) {
                                    return;
                                }
                                [strongSelf.delegate sendMessage:chat];
                                [strongSelf.delegate socketLight];
                            }];
                        }else{
                            [strongSelf.delegate sendMessage:chat];
                            [strongSelf.delegate socketLight];
                        }
                    }];
                    
                }
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
                NSString *king_icon =![msg.msg.ct.kingIcon isEqual:@"null"]?msg.msg.ct.kingIcon:@"";
                NSString *lang = minstr(msg.msg.lang);
                //        是否用户发言
                NSString *isUserMsg = @"1";
                NSDictionary *chat = [NSDictionary dictionaryWithObjectsAndKeys:uname,@"userName",ct,@"contentChat",levell,@"levelI",ID,@"id",titleColor,@"titleColor",vip_type,@"vip_type",liangname,@"liangname",usertype,@"usertype",isAnchor,@"isAnchor",guardType,@"guard_type",king_icon,@"king_icon",lang,@"lang",isUserMsg,@"isUserMsg",nil];
                if (self.delegate) {
                    WeakSelf
                    
                    NSDictionary *levelDic = [common getUserLevelMessage:minnum(msg.msg.ct.level)];
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [manager loadImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]
                                      options:SDWebImageHighPriority
                                     progress:nil
                                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        STRONGSELF
                        if (strongSelf == nil) {
                            return;
                        }
                        if (![PublicObj checkNull:msg.msg.ct.kingIcon]) {
                            WeakSelf
                            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:msg.msg.ct.kingIcon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                STRONGSELF
                                if (strongSelf == nil) {
                                    return;
                                }
                                [strongSelf.delegate sendMessage:chat];
                            }];
                        }else{
                            [strongSelf.delegate sendMessage:chat];
                        }
                    }];
                }
            }
        }
        //用户离开进入
        if(msg.msg.msgtype ==0)
        {
            //用户离开
            if (msg.msg.action == 1) {
                if (self.delegate) {
                    [self.delegate socketUserLive:minnum(msg.msg.ct.id_p) and:@{@"ct":@{@"id":minnum(msg.msg.ct.id_p)}}];
                }
            }
            //用户进入
            if (msg.msg.action == 0) {
                NSDictionary *dicSub = @{@"ct":@{@"id":minnum(msg.msg.ct.id_p),
                                                 @"user_nicename":msg.msg.ct.userNicename?msg.msg.ct.userNicename:@"",
                                                 @"avatar":msg.msg.ct.avatar?msg.msg.ct.avatar:@"",
                                                 @"avatar_thumb":msg.msg.ct.avatarThumb?msg.msg.ct.avatarThumb:@"",
                                                 @"level":minnum(msg.msg.ct.level),
                                                 @"usertype":minnum(msg.msg.ct.usertype),
                                                 @"vip_type":minnum(msg.msg.ct.vipType),
                                                 @"guard_type":minnum(msg.msg.ct.guardType),
                                                 @"king_icon":![msg.msg.ct.kingIcon isEqual:@"null"]?msg.msg.ct.kingIcon:@"",
                                                 @"liangname":![msg.msg.ct.liangname isEqual:@"null"]?msg.msg.ct.liangname:@"",
                                                 @"car_id":minnum(msg.msg.ct.carId),
                                                 @"car_swf":msg.msg.ct.carSwf?msg.msg.ct.carSwf:@"",
                                                 @"car_swftime":msg.msg.ct.carSwftime?msg.msg.ct.carSwftime:@"",
                                                 @"car_words":msg.msg.ct.carWords?msg.msg.ct.carWords:@"",
                                                 @"isAnchor":minnum(msg.msg.ct.isAnchor)
                }};
                WeakSelf
                NSDictionary *levelDic = [common getUserLevelMessage:minnum(msg.msg.ct.level)];
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
                            STRONGSELF
                            if (strongSelf == nil) {
                                return;
                            }
                            if (strongSelf.delegate) {
                                [strongSelf.delegate socketUserLogin:minnum(msg.msg.ct.id_p) andDic:dicSub];
                            }

                        }];
                    }else{
                        if (strongSelf.delegate) {
                            [strongSelf.delegate socketUserLogin:minnum(msg.msg.ct.id_p) andDic:dicSub];
                        }
                    }
                }];
                
                
            }
        }
        
    }
    else if (smsgPb.msgId == MsgID_StopLive)//stopLiveStartEndLive
    {
        if (self.delegate) {
            [self.delegate superStopRoom:@""];
        }
    }
    else if(smsgPb.msgId == MsgID_StartEndLive)
    {
//        StartEndLive *starEnd  = [StartEndLive parseFromData:smsgPb.msgData error:nil];
//        if (starEnd.msg.action == 19) {
//            if (self.delegate) {
//                [self.delegate loginOnOtherDevice];
//            }
//        }
    }
    //点亮
    else if (smsgPb.msgId == MsgID_Light){
        light *lightPb = [light parseFromData:smsgPb.msgData error:nil];
        
        if(lightPb.msg.msgtype == 0){
            //点亮
            if (lightPb.msg.action == 2) {
                if (self.delegate) {
                    [self.delegate socketLight];
                }
            }
        }
    }
    else if(smsgPb.msgId == MsgID_SendGift)
    {
        SendGift *sendGiftModel = [SendGift parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate sendGift:[sendGiftModel.msg mj_keyValues]];
        }
    }
    //弹幕
    else if(smsgPb.msgId == MsgID_SendBarrage)
    {
        SendBarrage *sendBarrageModel = [SendBarrage parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate sendDanMu:sendBarrageModel];
        }
    }
    else if (smsgPb.msgId == MsgID_SystemNot){
        SystemNot *sysmsg = [SystemNot parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate socketSystem:sysmsg.msg.ct];
        }
    }else if(smsgPb.msgId == MsgID_ShutUpUser){
        ShutUpUser *sysmsg = [ShutUpUser parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate socketShowChatSystem:sysmsg.msg.ct];
        }
    }
    else if (smsgPb.msgId == MsgID_SetAdmin){
        setAdmin *setAdminModel = [setAdmin parseFromData:smsgPb.msgData error:nil];
        NSString *ct = [NSString stringWithFormat:@"%@",setAdminModel.msg.ct];
        if (ct) {
            if (self.delegate) {
                [self.delegate socketShowChatSystem:ct];
            }
        }
    }
    //断开链接
    else if(smsgPb.msgId == MsgID_Disconnect)
    {
        disconnect *disConnectModel = [disconnect parseFromData:smsgPb.msgData error:nil];
        
        //用户离开
        if (disConnectModel.msg.action == 1) {
            NSString *ID = minnum(disConnectModel.msg.ct.id_p);
            if ([ID isEqual:connectID]) {
                isLianMai = NO;
                if (self.delegate) {
                    [self.delegate changeLivebroadcastLinkState:NO];
                }
            }
            if (self.delegate) {
                [self.delegate socketUserLive:ID and:@{@"ct":disConnectModel.msg.ct,@"id":minnum(disConnectModel.msg.ct.id_p)}];
            }
        }
    }
    // 同步彩票信息
    else if (self.delegate && smsgPb.msgId == MsgID_LotterySync){
        LotterySync *lotSyneModel = [LotterySync parseFromData:smsgPb.msgData error:nil];
        NSDictionary *subDic = @{@"lotteryType":@(lotSyneModel.msg.lotteryType),@"lotteryInfo":@{@"name":lotSyneModel.msg.lotteryInfo.name?lotSyneModel.msg.lotteryInfo.name:@"",
                                                                                                 @"logo":lotSyneModel.msg.lotteryInfo.logo?lotSyneModel.msg.lotteryInfo.logo:@"",
                                                                                                 @"time":minnum(lotSyneModel.msg.lotteryInfo.time),
                                                                                                 @"sealingTim":minnum(lotSyneModel.msg.lotteryInfo.sealingTim),
                                                                                                 @"issue":minnum(lotSyneModel.msg.lotteryInfo.issue),
                                                                                                 @"stopOrSell":minnum(lotSyneModel.msg.lotteryInfo.stopOrSell),
                                                                                                 @"stopMsg":lotSyneModel.msg.lotteryInfo.stopMsg?lotSyneModel.msg.lotteryInfo.stopMsg:@"",
                                                                                                 @"lotteryType":@(lotSyneModel.msg.lotteryInfo.lotteryType),
                                                                                                 @"serTime":minnum(lotSyneModel.msg.lotteryInfo.serTime),
        }};
        if (self.delegate) {
            [self.delegate setLotteryInfo:subDic];
        }
    }
    // 开奖
    else if (self.delegate && smsgPb.msgId == MsgID_LotteryOpenAward){
        LotteryOpenAward *lotteryAwardModel = [LotteryOpenAward parseFromData:smsgPb.msgData error:nil];
        NSDictionary *dicSub = @{@"action":minnum(lotteryAwardModel.msg.action),
                                 @"winWays":lotteryAwardModel.msg.winWaysArray?[NSArray arrayWithArray:lotteryAwardModel.msg.winWaysArray]:@[],
                                 @"ct":lotteryAwardModel.msg.ct?lotteryAwardModel.msg.ct:@"",
                                 @"msgtype":minnum(lotteryAwardModel.msg.msgtype),
                                 @"lotteryType":@(lotteryAwardModel.msg.lotteryType),
                                 @"result":lotteryAwardModel.msg.result?lotteryAwardModel.msg.result:@"",
                                 @"name":lotteryAwardModel.msg.name?lotteryAwardModel.msg.name:@"",
                                 @"issue":minnum(lotteryAwardModel.msg.issue),
                                 @"sum_result_str":lotteryAwardModel.msg.sumResultStr?lotteryAwardModel.msg.sumResultStr:@"",
                                 @"niu":@{@"red_niu":lotteryAwardModel.msg.niu.redNiu?lotteryAwardModel.msg.niu.redNiu:@"",@"blue_niu":lotteryAwardModel.msg.niu.blueNiu?lotteryAwardModel.msg.niu.blueNiu:@""},
                                 @"lh":@{@"dragon_dian":minnum(lotteryAwardModel.msg.lh.dragonDian),@"tiger_dian":minnum(lotteryAwardModel.msg.lh.tigerDian),@"dragon_dian_str":lotteryAwardModel.msg.lh.dragonDianStr?lotteryAwardModel.msg.lh.dragonDianStr:@"",@"tiger_dian_str":lotteryAwardModel.msg.lh.tigerDianStr?lotteryAwardModel.msg.lh.tigerDianStr:@"",@"whoWin":minnum(lotteryAwardModel.msg.lh.whoWin),@"dragon_tiger_str":lotteryAwardModel.msg.lh.tigerDianStr?lotteryAwardModel.msg.lh.tigerDianStr:@""},// 0:龙胜 1:虎胜 2:和
                                 @"bjl":@{@"zhuang_dian":minnum(lotteryAwardModel.msg.bjl.zhuangDian),@"xian_dian":minnum(lotteryAwardModel.msg.bjl.xianDian),@"zhuang_dian_str":lotteryAwardModel.msg.bjl.zhuangDianStr?lotteryAwardModel.msg.bjl.zhuangDianStr:@"",@"xian_dian_str":lotteryAwardModel.msg.bjl.xianDianStr?lotteryAwardModel.msg.bjl.xianDianStr:@"",@"whoWin":minnum(lotteryAwardModel.msg.bjl.whoWin),@"zhuangxian_str":lotteryAwardModel.msg.bjl.zhuangxianStr?lotteryAwardModel.msg.bjl.zhuangxianStr:@""},// 0:庄胜 1:闲胜 2:和
                                 @"zjh":@{@"pai_type":lotteryAwardModel.msg.zjh.paiTypeArray?lotteryAwardModel.msg.zjh.paiTypeArray:@[],@"pai_type_str":lotteryAwardModel.msg.zjh.paiTypeStrArray?lotteryAwardModel.msg.zjh.paiTypeStrArray:@[],@"whoWin":minnum(lotteryAwardModel.msg.zjh.whoWin)}
                                 
        };
        if (![self.delegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LotteryOpenAward" object:nil userInfo:dicSub];
        }
        if (self.delegate) {
            [self.delegate addOpenAward:dicSub];
        }
    }
    // 中奖广播
    else if (self.delegate && smsgPb.msgId == MsgID_LotteryProfit){
        LotteryProfit *lotteryProfitModel = [LotteryProfit parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            WeakSelf
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                [strongSelf.delegate setLotteryProfitNot:lotteryProfitModel];
            });
        }
        if (![self.delegate isKindOfClass:[ZYTabBarController class]]) {
            if (![self.delegate isKindOfClass:[ZYTabBarController class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KBetWinAllUserNotificationMsg object:nil userInfo:@{@"model":lotteryProfitModel}];
            }
        }
    }else if (self.delegate && smsgPb.msgId == MsgID_KyGame){
        // 开元弹幕
        kyGame *kygModel = [kyGame parseFromData:smsgPb.msgData error:nil];
        NSString *ct = [NSString stringWithFormat:@"%@",kygModel.msg.ct];
        if (ct) {
            if (self.delegate) {
                [self.delegate setGameNot:kygModel];
            }
        }
    }else if (self.delegate && smsgPb.msgId == MsgID_PlatGame){
        // 平台弹幕
        platGame *platGameModel = [platGame parseFromData:smsgPb.msgData error:nil];
        NSString *ct = [NSString stringWithFormat:@"%@",platGameModel.msg.ct];
        if (ct) {
            if (self.delegate) {
                [self.delegate setPlatGameNot:platGameModel];
            }
        }
    }
    // 分红广播
    else if (self.delegate && smsgPb.msgId == MsgID_LotteryDividend){
        LotteryDividend *lotteryDividendModel = [LotteryDividend parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate setLotteryDividendNot:lotteryDividendModel];
        }
    }
    // 投注广播
    else if (self.delegate && smsgPb.msgId == MsgID_LotteryBet){
        LotteryBet *lotteryBetModel = [LotteryBet parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate setLotteryBetNot:lotteryBetModel];
        }
        if (![self.delegate isKindOfClass:[ZYTabBarController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KBetDoNotificationMsg object:nil userInfo:@{@"model":lotteryBetModel}];
        }
    }// 中奖飘屏主播端屏蔽
    else if (self.delegate && smsgPb.msgId == MsgID_LotteryBarrage){
        //        [self.delegate setLotteryBarrage:msg];
    }// 中奖飘屏当前用户
    else if (self.delegate && smsgPb.msgId == MsgID_LotteryAward){
        LotteryAward *lotteryAwardModel = [LotteryAward parseFromData:smsgPb.msgData error:nil];
        if (self.delegate) {
            [self.delegate setLotteryAward:lotteryAwardModel];
        }
    }else if(self.delegate && smsgPb.msgId == MsgID_TranslateContent) // 弹幕翻译
    {
        TranslateContent *translateModel = [TranslateContent parseFromData:smsgPb.msgData error:nil];
        if (self.delegate != nil) {
            [self.delegate transalteMsg:translateModel];
        }
    }
    //炸金花游戏结果
    //游戏
    //    else if ([method isEqual:@"startGame"] || [method isEqual:@"startCattleGame"] || [method isEqual:@"startLodumaniGame"] ){
    //
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"2"]) {
    //
    //
    //        }
    //        if ([action isEqual:@"6"]) {
    //            NSArray *ct = [msg valueForKey:@"ct"];
    //            [self.delegate getResult:ct];
    //        }
    //        else if ([action isEqual:@"5"]){
    //            NSString *money = [NSString stringWithFormat:@"%@",[msg valueForKey:@"money"]];
    //            NSString *type = [NSString stringWithFormat:@"%@",[msg valueForKey:@"type"]];
    //            [self.delegate getCoin:type andMoney:money];
    //        }
    //    }
    //    else if ([method isEqual:@"startRotationGame"]){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"6"]) {
    //            NSArray *ct = [msg valueForKey:@"ct"];
    //            [self.delegate getRotationResult:ct];
    //        }
    //        else if ([action isEqual:@"5"]){
    //            NSString *money = [NSString stringWithFormat:@"%@",[msg valueForKey:@"money"]];
    //            NSString *type = [NSString stringWithFormat:@"%@",[msg valueForKey:@"type"]];
    //            [self.delegate getRotationCoin:type andMoney:money];
    //        }
    //    }
    //    else if ([method isEqual:@"startShellGame"] ){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"6"]) {
    //            NSArray *ct = [msg valueForKey:@"ct"];
    //            [self.delegate getShellResult:ct];
    //        }
    //        else if ([action isEqual:@"5"]){
    //            NSString *money = [NSString stringWithFormat:@"%@",[msg valueForKey:@"money"]];
    //            NSString *type = [NSString stringWithFormat:@"%@",[msg valueForKey:@"type"]];
    //            [self.delegate getShellCoin:type andMoney:money];
    //        }
    //    }
    //上庄
    /*
     action 1上庄
     */
    //    else if ([method isEqual:@"shangzhuang"]){
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"1"]) {
    //            NSDictionary *subdic = @{
    //                @"uid":[msg valueForKey:@"uid"],
    //                @"uhead":[msg valueForKey:@"uhead"],
    //                @"uname":[msg valueForKey:@"uname"],
    //                @"coin":[msg valueForKey:@"coin"]
    //            };
    //            [self.delegate getzhuangjianewmessagedelegate:subdic];
    //        }
    //    }
#pragma 连麦
    //连麦
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
    //    else if ([method isEqual:@"ConnectVideo"]){//andAudienceID 连麦申请者ID
#pragma mark 连麦暂时隐藏
    //        NSString *action = [NSString stringWithFormat:@"%@",[msg valueForKey:@"action"]];
    //        if ([action isEqual:@"1"]) {
    //            //连麦数量限制
    //            if (lianmaitime != 10) {
    //                //主播正忙碌
    //                [self hostisbusy:[NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]]];
    //                return;
    //
    //            }
    //            if (isLianMai) {
    //                //主播正忙碌
    //
    //                [self hostisbusy:[NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]]];
    //                return;
    //
    //            }
    //            isAnchorLink = NO;
    //            isPK = NO;
    //            connectID = [NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]];
    //            if (lianmaitimer) {
    //                [lianmaitimer invalidate];
    //                lianmaitimer = nil;
    //            }
    //            if (!lianmaitimer) {
    //                lianmaitimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(lianmaidaojishi) userInfo:nil repeats:YES];
    //            }
    //            connectUserName = minstr([msg valueForKey:@"uname"]);
    //            [self showLinkAlert:msg];
    //            //            NSString *name = [NSString stringWithFormat:@"%@向你发起连麦",[msg valueForKey:@"uname"]];
    //            //            connectAlert = [[UIAlertView alloc]initWithTitle:YZMsg(@"提示") message:name delegate:self cancelButtonTitle:YZMsg(@"拒绝") otherButtonTitles:YZMsg(@"接受"), nil];
    //            //            [connectAlert show];
    //        }
    //        else if ([action isEqual:@"4"]){
    //            if ([connectID isEqual:[msg valueForKey:@"uid"]]) {
    //                [self.delegate getSmallRTMP_URL:[msg valueForKey:@"playurl"] andUserID:[msg valueForKey:@"uid"]];
    //            }
    //        }
    //        else if ([action isEqual:@"5"]){
    //            //有人下麦
    //            NSString *userid;
    //            if ([action isEqual:@"5"]) {
    //                userid = [NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]];
    //            }else{
    //                userid = [NSString stringWithFormat:@"%@",[msg valueForKey:@"touid"]];
    //            }
    //            isLianMai = NO;
    //            [self.delegate usercloseConnect:userid];
    //            [self.delegate changeLivebroadcastLinkState:NO];
    //            [MBProgressHUD showError:[NSString stringWithFormat:@"%@%@",minstr([msg valueForKey:@"uname"]),YZMsg(@"已下麦")]];
    //
    //        }
    //        else if ([action isEqual:@"9"]){
    //            [connectAlert dismissWithClickedButtonIndex:0 animated:YES];
    //        }
    //    }
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
        if (self.delegate) {
            [self.delegate updateGuardMsg:guardDic];
            [self.delegate socketShowChatSystem:[NSString stringWithFormat:@"%@ %@",minstr(bugGuardModel.msg.uname),YZMsg(@"socketLivePlay_whoGuard")]];
        }
    }
    //    else if ([method isEqual:@"LiveConnect"]){
    //        //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
    //        int action = [minstr([msg valueForKey:@"action"]) intValue];
    //        switch (action) {
    //            case 1:
    //                if (lianmaitime != 10) {
    //                    //主播正忙碌
    //                    [self zhubolianmaizhengmanglu:[NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]]];
    //                    return;
    //
    //                }
    //
    //                if (isLianMai) {
    //                    [self zhubolianmaizhengmanglu:[NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]]];
    //                    return;
    //                }
    //                isPK = NO;
    //                isAnchorLink = YES;
    //                connectID = [NSString stringWithFormat:@"%@",[msg valueForKey:@"uid"]];
    //                if (lianmaitimer) {
    //                    [lianmaitimer invalidate];
    //                    lianmaitimer = nil;
    //                }
    //                if (!lianmaitimer) {
    //                    lianmaitimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(lianmaidaojishi) userInfo:nil repeats:YES];
    //                }
    //                connectUserName = minstr([msg valueForKey:@"uname"]);
    //                [self showLinkAlert:msg];
    //
    //                break;
    //            case 3:
    //                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", YZMsg(@"对方拒绝了你的连麦申请")]];
    //                isLianMai = NO;
    //                break;
    //            case 4:
    //                [self.delegate anchor_agreeLink:msg];
    //
    //                break;
    //            case 5:
    //                isLianMai = NO;
    //                [MBProgressHUD showError:YZMsg(@"连麦已断开")];
    //                [self.delegate anchor_stopLink:msg];
    //                break;
    //
    //            case 7:
    //                [MBProgressHUD showError:YZMsg(@"对方正忙碌")];
    //                isLianMai = NO;
    //                break;
    //            case 8:
    //                [MBProgressHUD showError:YZMsg(@"对方无响应")];
    //                isLianMai = NO;
    //
    //                break;
    //
    //            default:
    //                break;
    //        }
    //    }
    //发红包
    else if(smsgPb.msgId == MsgID_SendRed)
    {
        SendRed *sendRedModel = [SendRed parseFromData:smsgPb.msgData error:nil];
        if (sendRedModel.msg.action == 0) {
            if (self.delegate) {
                [self.delegate showRedbag:sendRedModel];
            }
        }
    }
    //else if ([method isEqual:@"LivePK"]){
    //        //1：发起PK；2；接受PK；3:拒绝PK；4：PK成功通知；5.;7:对方正忙碌 8:对方无响应 9:PK结果
    //        int action = [minstr([msg valueForKey:@"action"]) intValue];
    //        switch (action) {
    //            case 1:
    //                isPK = YES;
    //                if (lianmaitimer) {
    //                    [lianmaitimer invalidate];
    //                    lianmaitimer = nil;
    //                }
    //                if (!lianmaitimer) {
    //                    lianmaitimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(lianmaidaojishi) userInfo:nil repeats:YES];
    //                }
    //                connectUserName = minstr([msg valueForKey:@"uname"]);
    //                [self showPKAlert:msg];
    //
    //                break;
    //            case 3:
    //                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", YZMsg(@"对方拒绝了你的PK申请")]];
    //                [self.delegate showPKButton];
    //                break;
    //            case 4:
    //                [self.delegate showPKView];
    //
    //                break;
    //
    //            case 7:
    //                [MBProgressHUD showError:YZMsg(@"对方正忙碌")];
    //                [self.delegate showPKButton];
    //
    //                break;
    //            case 8:
    //                [MBProgressHUD showError:YZMsg(@"对方无响应")];
    //                [self.delegate showPKButton];
    //                break;
    //            case 9:
    //                [self.delegate showPKResult:msg];
    //                break;
    //
    //            default:
    //                break;
    //        }
    //    }
    
    
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
    [ChatSocket emit:@"broadcast" with:msgData];
}
-(void)changeLiveType:(NSString *)type_val changetype:(NSString *)type{
    NSArray *guanliArray =@[
        @{
            @"msg":@[
                    @{
                        @"_method_":@"changeLive",
                        @"action":@"1",
                        @"msgtype":@"27",
                        @"type_val":type_val,
                        @"type":type,
                    }
            ],
            @"retcode":@"000000",
            @"retmsg":@"ok"
        }
    ];
    [ChatSocket emit:@"broadcast" with:guanliArray];
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
    [ChatSocket emit:@"broadcast" with:msgData];
}
//#pragma mark ================ 连麦 ===============
////收到连麦请求倒计时10s，未接受则主动发消息，未响应
//-(void)lianmaidaojishi{
//    lianmaitime -= 1;
//    if (isPK) {
//        //        linkAlert.timeL.text = [NSString stringWithFormat:@"发起PK请求(%ds)...",lianmaitime];
//    }else{
//        linkAlert.timeL.text = [NSString stringWithFormat:@"%@(%ds)...",YZMsg(@"发起连麦请求"),lianmaitime];
//    }
//    
//    if (lianmaitime == 0) {
//        lianmaitime = 10;
//        [lianmaitimer invalidate];
//        lianmaitimer = nil;
//        //        [connectAlert dismissWithClickedButtonIndex:0 animated:YES];
//        [linkAlert removeFromSuperview];
//        linkAlert = nil;
//        if (isPK) {
//            
//        }else{
//            if (isAnchorLink) {
//                [self anchor_operationAndAction:@"8"];
//            }else{
//                [self hostout:connectID];
//            }
//        }
//    }
//}
//主播未响应
-(void)hostout:(NSString *)touid{
    
    NSArray *msgData2 =@[
        @{
            @"msg": @[
                    @{
                        @"_method_":@"ConnectVideo",
                        @"action": @"8",
                        @"msgtype": @"10",
                        @"touid":touid
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData2];
}
//主播正忙碌
-(void)hostisbusy:(NSString *)touid{
    NSArray *msgData2 =@[
        @{
            @"msg": @[
                    @{
                        @"_method_":@"ConnectVideo",
                        @"action": @"7",
                        @"msgtype": @"10",
                        @"touid":touid
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData2];
}

//拒绝连麦请求
-(void)refuseConnect{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"ConnectVideo",
                        @"action":@"3",
                        @"msgtype": @"10",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"touid":connectID
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//同意连麦请求
-(void)agreeMick{
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"ConnectVideo",
                        @"action":@"2",
                        @"msgtype": @"10",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"touid":connectID,
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == connectAlert) {
        if (buttonIndex == 0) {
            //拒绝
            [self refuseConnect];
            if (self.delegate) {
                [self.delegate changeLivebroadcastLinkState:NO];
            }
            [lianmaitimer invalidate];
            lianmaitimer = nil;
            lianmaitime = 10;
            isLianMai = NO;
            return;
        }
        else if (buttonIndex == 1){
            //接受
            [self agreeMick];
            if (self.delegate) {
                [self.delegate changeLivebroadcastLinkState:YES];
            }
            [lianmaitimer invalidate];
            lianmaitimer = nil;
            lianmaitime = 10;
            isLianMai = YES;
        }
    }
}
-(void)closeconnectuser:(NSString *)uid{
    isLianMai = NO;
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"ConnectVideo",
                        @"action":@"6",
                        @"msgtype": @"10",
                        @"touid":uid,
                        @"uname":connectUserName
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
}
//- (void)showLinkAlert:(NSDictionary *)dic{
//    if (linkAlert) {
//        [linkAlert removeFromSuperview];
//        linkAlert = nil;
//    }
//    linkAlert = [[linkAlertView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andUserMsg:dic];
//    if (isPK) {
//        linkAlert.timeL.text = [NSString stringWithFormat:@"%@(%ds)...",YZMsg(@"发起PK请求"),lianmaitime];
//    }else{
//        linkAlert.timeL.text = [NSString stringWithFormat:@"%@(10s)...",YZMsg(@"发起连麦请求")];
//    }
//    [[UIApplication sharedApplication].keyWindow addSubview:linkAlert];
//    [linkAlert show];
//    WeakSelf
//    linkAlert.block = ^(BOOL isAgree) {
//        STRONGSELF
//        if (strongSelf==nil) {
//            return;
//        }
//        if (isAgree) {
//            if (strongSelf->isPK) {
//                [strongSelf pk_operationAndAction:@"2"];
//                
//            }else{
//                if ([dic valueForKey:@"pkuid"]) {
//                    [strongSelf checkLinkLive:dic];
//                }else{
//                    [strongSelf agreeMick];
//                    [strongSelf->lianmaitimer invalidate];
//                    strongSelf->lianmaitimer = nil;
//                    strongSelf->lianmaitime = 10;
//                    strongSelf->isLianMai = YES;
//                    if (strongSelf.delegate) {
//                        [strongSelf.delegate changeLivebroadcastLinkState:YES];
//                    }
//                }
//            }
//            
//        }else{
//            if (strongSelf->isPK) {
//                [strongSelf pk_operationAndAction:@"3"];
//            }else{
//                if ([dic valueForKey:@"pkuid"]) {
//                    [strongSelf anchor_operationAndAction:@"3"];
//                }else{
//                    [strongSelf refuseConnect];
//                }
//                if (strongSelf.delegate) {
//                    [strongSelf.delegate changeLivebroadcastLinkState:NO];
//                }
//            }
//            [strongSelf->lianmaitimer invalidate];
//            strongSelf->lianmaitimer = nil;
//            strongSelf->lianmaitime = 10;
//            strongSelf->isLianMai = NO;
//        }
//    };
//}
- (void)checkLinkLive:(NSDictionary *)dic{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:[NSString stringWithFormat:@"Livepk.CheckLive&stream=%@",minstr([dic valueForKey:@"stream"])] withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf->lianmaitimer invalidate];
        strongSelf->lianmaitimer = nil;
        strongSelf->lianmaitime = 10;
        
        if (code == 0) {
            [strongSelf anchor_Agree:nil];
            strongSelf->isLianMai = YES;
            if (strongSelf.delegate) {
                [strongSelf.delegate changeLivebroadcastLinkState:YES];
            }
            
        }else{
            strongSelf->isLianMai = NO;
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf->lianmaitimer invalidate];
        strongSelf->lianmaitimer = nil;
        strongSelf->lianmaitime = 10;
        strongSelf->isLianMai = NO;
        
    }];
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
    [ChatSocket emit:@"broadcast" with:msgData];
}


#pragma mark ================ 主播与主播连麦 ===============
- (void)anchor_startLink:(NSDictionary *)dic{
    isLianMai = YES;
    connectID = minstr([dic valueForKey:@"uid"]);
    
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"LiveConnect",
                        @"action":@"1",
                        @"msgtype": @"0",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"uhead":[Config getavatarThumb],
                        @"level":[Config getLevel],
                        @"sex":[Config getSex],
                        @"pkuid":minstr([dic valueForKey:@"uid"]),
                        @"pkpull":minstr(_zhuboModel.pull),
                        @"stream":minstr(_zhuboModel.stream),
                        @"level_anchor":[Config level_anchor],
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
}
- (void)anchor_operationAndAction:(NSString *)action{
    //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"LiveConnect",
                        @"action":action,
                        @"msgtype": @"0",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"uhead":[Config getavatarThumb],
                        @"pkuid":connectID,
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
}
- (void)zhubolianmaizhengmanglu:(NSString *)action{
    //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"LiveConnect",
                        @"action":@"7",
                        @"msgtype": @"0",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"uhead":[Config getavatarThumb],
                        @"pkuid":action,
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
}

- (void)anchor_Agree:(NSDictionary *)dic{
    //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"LiveConnect",
                        @"action":@"2",
                        @"msgtype": @"0",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"uhead":[Config getavatarThumb],
                        @"pkuid":connectID,
                        @"pkpull":minstr(_zhuboModel.pull),
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
}
- (void)anchor_DuankaiLink
{
    isLianMai = NO;
    [self anchor_operationAndAction:@"5"];
}
- (void)pk_operationAndAction:(NSString *)action{
    //1：发起连麦；2；接受连麦；3:拒绝连麦；4：连麦成功通知；5.手动断开连麦;7:对方正忙碌 8:对方无响应
    NSArray *msgData =@[
        @{
            @"msg": @[
                    @{
                        @"_method_": @"LivePK",
                        @"action":action,
                        @"msgtype": @"0",
                        @"uid":[Config getOwnID],
                        @"uname":[Config getOwnNicename],
                        @"uhead":[Config getavatarThumb],
                        @"pkuid":connectID,
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
}

#pragma mark ================ 红包 ===============
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
                        @"uhead":user.avatar,
                        @"level":[Config getLevel],
                        @"vip_type":[Config getVip_type],
                        @"liangname":[Config getliang],
                        @"isAnchor":@"1",
                    }
            ],
            @"retcode": @"000000",
            @"retmsg": @"OK"
        }
    ];
    [ChatSocket emit:@"broadcast" with:msgData];
    
}

-(void)removeShouhuView{
    [self pk_operationAndAction:@"8"];
   
}

@end
