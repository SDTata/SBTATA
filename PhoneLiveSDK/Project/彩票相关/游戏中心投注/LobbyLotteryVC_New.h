//
//  LobbyLotteryVC_New.h
//  XLPageViewControllerExample
//
//  Created by MengXianLiang on 2019/5/14.
//  Copyright © 2019 xianliang meng. All rights reserved.
//  频道管理举例

#import <UIKit/UIKit.h>
#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "EqualSpaceFlowLayoutEvolve.h"

NS_ASSUME_NONNULL_BEGIN

@interface LobbyLotteryVC_New : UIViewController

@property(nonatomic,strong)SocketIOClient *LobbySocket;
@property(assign,nonatomic) NSInteger lotteryType;
@property(weak)id<lotteryBetViewDelegate>lotteryDelegate;
@property(strong,nonatomic) NSString * urlName;
@property(strong,nonatomic) NSString * lotteryName;

- (void)releaseView;
@end

NS_ASSUME_NONNULL_END
