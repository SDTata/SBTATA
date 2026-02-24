//
//  YBUserInfoManager.h
//  phonelive2
//
//  Created by user on 2024/8/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBUserInfoManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, weak) id extraDelegate;
- (void)pushVC:(NSDictionary *)data viewController:(nullable UIViewController *)vc;
- (void)pushNav:(NSString *)nav;
- (void)pushVipPayWebviewinfo:(NSDictionary *)subdic;
// header cell click
- (void)pushLiveNodeList;
- (void)pushFansList;
- (void)pushAttentionList;
- (void)pushEditView;
- (void)pushSetupInfo;
- (void)pushMsgAction:(nullable NSString *)type isMessageList:(BOOL)isMessageList;
- (void)pushExchangeRateAction;
- (void)pushToRecharge;
- (void)pushBillDetails;
- (void)pushExchange;
- (void)pushWithdraw;
- (void)pushBindPhone;
- (void)pushInfoView;
- (void)pushToVipShop;
- (void)pushToOneBuyGirl;
- (void)pushToTaskCenter:(nullable NSString *)name;
- (void)pushToService;
- (void)pushToThirdgame:(NSString *)urlStr;
- (void)pushToRoom:(NSString *)urlStr;
- (void)pushToTask:(NSString *)urlStr;
- (void)pushToPromotion;
- (void)pushOtherUserMsgVC:(NSString *)scheme;

- (void)pushH5Webviewinfo:(NSDictionary *)subdic;

@end

NS_ASSUME_NONNULL_END
