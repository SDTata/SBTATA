//
//  YBUserInfoManager.m
//  phonelive2
//
//  Created by user on 2024/8/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YBUserInfoManager.h"
#import "myProfitVC.h"
#import "PayViewController.h"
#import "market.h"
#import "equipment.h"
#import "LiveTaskVC.h"
#import "setView.h"
#import "mineVideoVC.h"
#import "BillVC.h"
#import "VIPVC.h"
#import "DramaHomeViewController.h"
#import "MyCreateMainVC.h"
#import "webH5.h"
#import "MyWalletVC.h"
#import "TaskDailyTaskVC.h"
// header cell click
#import "LiveNodeViewController.h"
#import "fansViewController.h"
#import "attrViewController.h"
#import "myInfoEdit.h"
#import "MessageListViewController.h"
#import "ExchangeRateViewController.h"
#import "ExchangeRateModel.h"
#import "exchangeVC.h"
#import "myWithdrawVC2.h"
#import "BindPhoneNumberViewController.h"
#import "otherUserMsgVC.h"
#import "myPopularizeVC.h"
//@import LiveChat;
#import "OneBuyGirlViewController.h"
#import "TaskCenterMainVC.h"
#import "KingSalaryViewController.h"
#import "EnterLivePlay.h"
#import "TaskVC.h"
#import "LotteryBetHallVC.h"
#import "LobbyLotteryVC_New.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "GameHomeMainVC.h"
#import "NavWeb.h"
#import "UINavModalWebView.h"

#import "TaskBackWaterVC.h"
#import "DailyCheckInViewController.h"
#import "LuckyDrawViewController.h"
#import "VKSupportUtil.h"

static YBUserInfoManager *info;
@interface YBUserInfoManager () {
    UIViewController *viewController;
}
@end
@implementation YBUserInfoManager
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (info == nil) {
            info = [[super allocWithZone:NULL] init];
        }
    });
    return info;
}

- (void)pushVC:(NSDictionary *)data viewController:(nullable UIViewController *)vc {
    viewController = vc;
    int selectedid = [data[@"id"] intValue];//选项ID
    NSString *url = [NSString stringWithFormat:@"%@",[data valueForKey:@"href"]];
    NSString *name = YZMsg(minstr([data valueForKey:@"name"]));
    NSString *scheme = data[@"scheme"];
    NSString *urlShowType = data[@"showType"];
    if (data[@"jump"]) {
        urlShowType = data[@"jump"];
    }
    if (scheme && scheme.length > 0) {
        if ([scheme containsString:@"http"] && urlShowType != nil) {
            scheme = [YBToolClass replaceUrlParams:scheme];
            scheme = [YBToolClass decodeReplaceUrl:scheme];
            // 0应用内显示。1应用外显示
            if(urlShowType && urlShowType != (id)[NSNull null] && [urlShowType isEqualToString:@"0"]){
                NavWeb *VC = [[NavWeb alloc]init];
                VC.titles = @"";
                if ([data objectForKey:@"href"] == nil) {
                    url = scheme;
                }
                VC.urls = url;
                
                UINavModalWebView * navController = [[UINavModalWebView alloc] initWithRootViewController:VC];
                
                if (@available(iOS 13.0, *)) {
                    navController.modalPresentationStyle = UIModalPresentationAutomatic;
                } else {
                    navController.modalPresentationStyle = UIModalPresentationFullScreen;
                }
                
                VC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YZMsg(@"public_back") style:UIBarButtonItemStylePlain target:self action:@selector(closeService:)];
                VC.navigationItem.title = @"";
                
                
                if ([[MXBADelegate sharedAppDelegate] topViewController].presentedViewController != nil)
                {
                    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:NO completion:nil];
                }
                if ([[MXBADelegate sharedAppDelegate] topViewController].presentedViewController==nil) {
                    [[[MXBADelegate sharedAppDelegate] topViewController] presentViewController:navController animated:true completion:nil];
                }
                
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        } else if ([scheme isEqualToString:@"family-residence://"]) { // 家族驻地
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"family-center://"]) { // 家族中心
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"short-drama://"]) { // 精彩短剧
            ///TODO:
        } else if ([scheme isEqualToString:@"customer-service://"]) { // 在线客服
            [self pushToService];
        } else if ([scheme isEqualToString:@"my-funds-details://"]) { // 我的明细
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"live-task://"]) { // 主播任务
            [self pushToTask:name];
        } else if ([scheme isEqualToString:@"my-earnings://"]) { // 我的收益
            [self Myearnings:name isCreator:false];
        } else if ([scheme isEqualToString:@"creator-earnings://"]) { // 我的收益
            [self Myearnings:name isCreator:true];
        } else if ([scheme isEqualToString:@"my-certification://"]) { // 我的认证
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"my-level://"]) { // 我的等级
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"equipment://"]) { // 我的装备
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"shop://"]) { // 在线商城
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"game-report://"]) { // 游戏报表
            [self pushH5Webviewinfo:data];
        } else if ([scheme isEqualToString:@"salary://"]) { // 王者俸禄
            [self pushToKingSalary];
        } else if ([scheme isEqualToString:@"wallet://"]) { // 我的钱包
            [self pushMyWalletVC: data];
        }  else if ([scheme isEqualToString:@"creation-hub://"]) { // 创作中心
            [self pushMyCreate];
        }  else if ([scheme containsString:@"rewards-center://"]) { // 遊戲中心
            [self pushToTaskCenter: nil];
        } else if ([scheme containsString:@"fuckactivity://"]) { // 一元空降
            [self pushToOneBuyGirl];
        } else if ([scheme containsString:@"charge://"]) { // 充值中心
            [self pushToRecharge];
        } else if ([scheme containsString:@"thirdgame://"]) {
           
            [self pushToThirdgame: scheme];
        } else if ([scheme containsString:@"enterroom://"]) {
            [self pushToRoom: scheme];
        } else if ([scheme containsString:@"task://"]) { // 具体任务分组
            NSString *name = [data objectForKey:@"name"];
            RewardHomeModel *model = [[RewardHomeModel alloc]init];
            model.name = name?name:@"";
            model.cell_jump = scheme;
            TaskDailyTaskVC *vc = [TaskDailyTaskVC new];
            vc.rewardModel = model;
            [vc showFromBottom];
            
//            [self pushToTask: scheme];
        } else if ([scheme containsString:@"promotion://"]
                   ||[scheme containsString:@"make-money://"]
                   ||[scheme containsString:@"promote-makemoney://"]) { // 推广奖励
            [self pushToPromotion];
        } else if ([scheme containsString:@"self-info-edit://"]) { // 编辑资料
            [self pushEditView];
        } else if ([scheme containsString:@"bindphone://"]) { // 绑定手机
            [self pushBindPhone];
        }  else if ([scheme containsString:@"bindemail://"]) { // 绑定邮箱
            [self pushBindEmail];
        } else if ([scheme containsString:@"personal-home://"]) { // 会员主页
            [self pushOtherUserMsgVC:scheme];
        } else if ([scheme containsString:@"my-message://"]) { // 我的消息
            [self pushMsgAction:scheme isMessageList:NO];
        }else if ([scheme containsString:@"game-center://"]) { // 我的消息
            GameHomeMainVC *vc = [[GameHomeMainVC alloc] init];
            if (viewController) {
                vc.hidesBottomBarWhenPushed = YES;
                viewController.navigationController.navigationBar.hidden = YES;
                [viewController.navigationController pushViewController:vc animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
            }
        }else if ([scheme containsString:@"rebate://"]) { // 我的消息
            [self clickBackWaterAction];
        }else if([scheme containsString:@"coinrecord://"]) {
            [self pushBillDetails];
        }else if([scheme containsString:@"checkin://"]) {
            [self clickDaySignAction];
        }else if([scheme containsString:@"lucky-draw://"]) {
            [self clickLuckyDrawAction];
        }else if([scheme containsString:@"gesture-pwd://"]) {
            [VKSupportUtil showGesturePassword];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
            if ([dict objectForKey:@"href"] == nil) {
                dict[@"href"] = scheme;
            }
          
            [self pushH5Webviewinfo:dict];
        }
#pragma mark - 旧判断逻辑 ↓
    } else if (url.length > 9) {
        [self pushH5Webviewinfo:data];
    } else {
        /*
         1我的收益  2 我的钻石  4 在线商城 5 装备中心 13 个性设置  19 我的视频
         其他页面 都是H5
         */
        switch (selectedid) {
                //原生页面无法动态添加
            case 1:
                [self Myearnings:name isCreator:false];//我的收益
                break;
            case 2:
                [self MyDiamonds:name];//我的钻石
                break;
            case 4:
                [self ShoppingMall];//在线商城
                break;
            case 5:
                [self Myequipment];//装备中心
                break;
            case 8:
                [self ListTask];//主播任务
                break;
            case 13:
                [self SetUp:name];//设置
                break;
            case 15:
                //[self getVippayInfo:data isJump:YES];
                break;
            case 19:
                [self mineVideo:name];//我的视频
                break;
            case 100:
                [self service:name];
                break;
            case 10000:
                [self pushShouZhi];
                break;
            case 10001:
                [self pushToVIP];
                break;
            case 10002:
                [YBToolClass showService];
                break;
            case 10003:
                [self pushToDrama];
                break;
            case 10004:
                [self pushMyCreate];
                break;
            default:
                break;
        }
    }
    
    /// 置空，防止下次push出错
    viewController = nil;
}

/// 实时返水
- (void)clickBackWaterAction {
    TaskBackWaterVC *vc = [TaskBackWaterVC new];
    [vc showFromBottom];
}

/// 每日签到
- (void)clickDaySignAction {
    DailyCheckInViewController *vc = [DailyCheckInViewController new];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[MXBADelegate sharedAppDelegate].topViewController presentViewController:vc animated:YES completion:nil];
}

/// 幸运抽奖
- (void)clickLuckyDrawAction {
    LuckyDrawViewController *vc = [LuckyDrawViewController new];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[MXBADelegate sharedAppDelegate].topViewController presentViewController:navController animated:YES completion:nil];
}

- (void)pushToVipShop {
    NSArray *array = [common getpersonc];
    NSDictionary *vipDict = [array.firstObject filterBlock:^BOOL(id object) {
        return [object[@"scheme"] hasPrefix:@"shop://"];
    }].firstObject;
    if (!vipDict) {
        return;
    }
    [YBUserInfoManager.sharedManager pushH5Webviewinfo:vipDict];
}

- (void)pushToVIP {
    VIPVC *vc = [[VIPVC alloc]initWithNibName:@"VIPVC" bundle:[XBundle currentXibBundleWithResourceName:@"VIPVC"]];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushShouZhi {
    BillVC *vc = [[BillVC alloc]initWithNibName:@"BillVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];  if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)getVippayInfo:(NSDictionary *)data {
    NSMutableDictionary * dict = [data mutableCopy];
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.vipPayLogin2&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 0) {
            LiveUser *user = [Config myProfile];
            if ([info isKindOfClass:[NSDictionary class]]) {
                NSDictionary *infoDic = info[@"result"];
                NSDictionary *userDic = infoDic[@"userInfo"];
                NSDictionary * dataDic = infoDic[@"data"];
                NSString * tokenStr = infoDic[@"token"];
                NSString * vipPayUrl = [NSString stringWithFormat:@"%@?t=%@",dataDic[@"h5WebAddress"],tokenStr];
                if(userDic== nil) {
                    user.vippay_balance = @"0";
                } else {
                    user.vippay_balance = minstr([userDic valueForKey:@"balance"]);
                }
                
                [Config updateProfile:user];
                dict[@"href"] = vipPayUrl;
                [[YBUserInfoManager sharedManager] pushVipPayWebviewinfo:dict];
            }
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)pushToDrama {
    DramaHomeViewController *vc = [[DramaHomeViewController alloc] init];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushMyCreate {
    MyCreateMainVC *vc = [MyCreateMainVC new];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

// vippay跳转
- (void)pushVipPayWebviewinfo:(NSDictionary *)subdic {
    NSString *url = minstr([subdic valueForKey:@"h5"]);
    if (url.length >9) {
        webH5 *vc = [[webH5 alloc]init];
        vc.titles = YZMsg(minstr([subdic valueForKey:@"name"]));
        vc.urls = url;
        if (viewController) {
            vc.hidesBottomBarWhenPushed = YES;
            viewController.navigationController.navigationBar.hidden = YES;
            [viewController.navigationController pushViewController:vc animated:YES];
        } else {
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    }
}

- (void)pushH5Webviewinfo:(NSDictionary *)subdic {
    NSString *urlString = minstr([subdic valueForKey:@"href"]);
    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSError *error = nil;
    NSAttributedString *decodedAttributedString = [[NSAttributedString alloc] initWithData:data
                                                                                   options:options
                                                                        documentAttributes:nil
                                                                                     error:&error];
    if (error) {
        NSLog(@"Error parsing HTML: %@", error.localizedDescription);
        return;
    }
    NSString *url = decodedAttributedString.string;
    
    if (url.length >9) {
        NSString *urlShowType = subdic[@"showType"];
        if (subdic[@"jump"]) {
            urlShowType = subdic[@"jump"];
        }
        // 0应用内显示。1应用外显示
        if(urlShowType==nil || (urlShowType && urlShowType != (id)[NSNull null] && [urlShowType isEqualToString:@"0"])){
            webH5 *VC = [[webH5 alloc]init];
            
            
            VC.titles = [subdic valueForKey:@"name"]?YZMsg(minstr([subdic valueForKey:@"name"])):@"";
            url = [YBToolClass decodeReplaceUrl:url];
            VC.urls = url;
            VC.scheme = subdic[@"scheme"];
            if (viewController) {
                VC.hidesBottomBarWhenPushed = YES;
                viewController.navigationController.navigationBar.hidden = YES;
                [viewController.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    }
    
}

//我的收益
- (void)Myearnings:(NSString *)name isCreator:(BOOL)iscreator {
    
    myProfitVC *vc = [[myProfitVC alloc]init];
    vc.isCreator = iscreator;
    vc.titleStr = YZMsg(name);
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

//我的钻石 ||  充值中心
- (void)MyDiamonds:(NSString *)name {
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(name);
    [payView setHomeMode:false];
    if (viewController) {
        payView.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:payView animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:payView animated:YES];
    }
}

//商城
- (void)ShoppingMall {
    market *vc = [[market alloc]init];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

//主播任务
- (void)ListTask {
    LiveTaskVC *taskVC = [[LiveTaskVC alloc]initWithNibName:@"LiveTaskVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    //taskVC.delelgate = self;
    taskVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[MXBADelegate sharedAppDelegate].topViewController presentViewController:taskVC animated:NO completion:nil];
}

//装备中心
- (void)Myequipment {
    equipment *vc = [[equipment alloc]init];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

//设置
- (void)SetUp:(NSString *)name {
    setView *vc = [[setView alloc]initWithNibName:@"setView" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    vc.titleStr = YZMsg(name);
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

//我的视频
- (void)mineVideo:(NSString *)name {
    mineVideoVC *vc = [[mineVideoVC alloc]init];
    vc.titleStr = YZMsg(name);
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

//我的客服
- (void)service:(NSString *)name {
    //    LiveChat.licenseId = livechatKey;
    //    LiveChat.name = [Config getOwnID];
    //    if (!LiveChat.isChatPresented) {
    //        [LiveChat presentChatWithAnimated:YES completion:nil];
    //    }else{
    //        [LiveChat dismissChatWithAnimated:YES completion:^(BOOL finished) {
    //
    //        }];
    //    }
    [YBToolClass showService];
}

#pragma mark - header cell click
- (void)pushLiveNodeList {
    LiveNodeViewController *vc = [[LiveNodeViewController alloc]init];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushFansList {
    fansViewController *vc = [[fansViewController alloc]init];
    vc.fensiUid = [Config getOwnID];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushAttentionList {
    attrViewController *vc = [[attrViewController alloc]init];
    vc.guanzhuUID = [Config getOwnID];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushEditView {
    myInfoEdit *vc = [[myInfoEdit alloc]initWithNibName:@"myInfoEdit" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushSetupInfo {
    [self SetUp:YZMsg(@"YBUserInfoVC_personSet")];
}

- (void)pushMsgAction:(nullable NSString *)type isMessageList:(BOOL)isMessageList {
    MessageListViewController *vc = [[MessageListViewController alloc] initWithMessageList:isMessageList];
    if (type != nil) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:type];
        NSString *interactionType = nil;
        for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
            if ([queryItem.name isEqualToString:@"type"]) {
                interactionType = queryItem.value;
                break;
            }
        }
        vc.type = interactionType;
    }
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}


// 汇率转换
- (void)pushExchangeRateAction {
    ExchangeRateViewController * vc = [[ExchangeRateViewController alloc] init];
    WeakSelf
    vc.callBlock = ^(ExchangeRateModel *model) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    };
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

- (void)pushToRecharge {
    [self MyDiamonds:YZMsg(@"Bet_Charge_Title")];
}

- (void)pushBillDetails {
    [self pushShouZhi];
}

- (void)pushExchange {
    exchangeVC *vc = [[exchangeVC alloc]init];
    vc.titleStr = YZMsg(@"h5game_Amount_Conversion");
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushWithdraw {
    myWithdrawVC2 *vc = [[myWithdrawVC2 alloc]init];
    vc.titleStr = YZMsg(@"public_WithDraw");
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushBindPhone {
    BindPhoneNumberViewController *vc = [[BindPhoneNumberViewController alloc]initWithNibName:@"BindPhoneNumberViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushBindEmail {
    BindPhoneNumberViewController *vc = [[BindPhoneNumberViewController alloc]initWithNibName:@"BindPhoneNumberViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    vc.bindingType = BindingTypeForEmail;
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

- (void)pushInfoView {
    otherUserMsgVC *person = [[otherUserMsgVC alloc]init];
    person.userID = [Config getOwnID];
    if (viewController) {
        person.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:person animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    }
}

- (void)pushMyWalletVC:(NSDictionary *)data {
    MyWalletVC *vc = [MyWalletVC new];
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}
// 一元空降
- (void)pushToOneBuyGirl {
    OneBuyGirlViewController *oneBuyGirlVC = [[OneBuyGirlViewController alloc]initWithNibName:@"OneBuyGirlViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    if (viewController) {
        oneBuyGirlVC.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:oneBuyGirlVC animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:oneBuyGirlVC animated:YES];
    }
}
// 宝箱奖励中心
- (void)pushToTaskCenter:(nullable NSString *)name {
    TaskCenterMainVC *vc = [TaskCenterMainVC new];
    vc.titleStr = name;
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

// 王者俸禄
- (void)pushToKingSalary {
    KingSalaryViewController *vc = [KingSalaryViewController new];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[MXBADelegate sharedAppDelegate] presentViewController:vc animated:YES completion:nil];
    
//    if (viewController) {
//        [viewController presentViewController:vc animated:YES completion:nil];
//    } else {
//        [[MXBADelegate sharedAppDelegate] presentViewController:vc animated:YES completion:nil];
//    }
}

// 拉起客服
- (void)pushToService {
    WeakSelf
    [common getServiceUrl:^(NSString *kefuUrl) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSString *serverUrl = kefuUrl;
        
        if (!serverUrl) {
            serverUrl = [DomainManager sharedInstance].kefuServer;
        }
        serverUrl = [YBToolClass replaceUrlParams:serverUrl];
        webH5 *vc = [[webH5 alloc] init];
        vc.urls = serverUrl;
        vc.bAllJump = YES;
        vc.titles = YZMsg(@"activity_login_connectkefu");
        if (strongSelf->viewController) {
            vc.hidesBottomBarWhenPushed = YES;
            [strongSelf->viewController.navigationController pushViewController:vc animated:YES];
        } else {
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        }
    }];
}

- (void)pushToThirdgame:(NSString *)urlStr { //thirdgame://?game=ky&kindid=8003&ext_1=0
    NSDictionary *params = [YBToolClass getUrlParamWithUrl:urlStr];
    if (params) {
        NSString *plat = params[@"game"];
        NSString *kid = params[@"kindid"];
        NSString *ext_1 = params[@"ext_1"];
        if (plat&&kid && plat.length>0&& kid.length>0) {
            [GameToolClass enterGame:plat menueName:@"" kindID:kid iconUrlName:@"" parentViewController: viewController autoExchange:[common getAutoExchange]  success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                
            } fail:^{
            }];
        }
    }
}

- (void)pushToRoom:(NSString *)urlStr {
    //enterroom://?liveuid=123456
    NSDictionary *params = [YBToolClass getUrlParamWithUrl:urlStr];
    if (params) {
        NSString *liveUid = [params objectForKey:@"liveuid"];
        if (liveUid && liveUid.length > 0) {
            [[EnterLivePlay sharedInstance] showLivePlayFromLiveID:[liveUid integerValue] fromInfoPage:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNoticeShowLivePlay" object: viewController];
        }
    }
}

- (void)pushToTask:(NSString *)urlStr {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlStr];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSURLQueryItem *item in components.queryItems) {
        if (item.value != nil) {
            params[item.name] = item.value;
        }
    }
    
    // Access title_group_id value
    NSString *titleGroupId = params[@"title_group_id"];
    
    TaskVC *taskVC = [[TaskVC alloc] initWithNibName:@"TaskVC" bundle: [XBundle currentXibBundleWithResourceName:@""]];
    taskVC.titleGroupId = titleGroupId;
    if (viewController) {
        taskVC.delelgate = self.extraDelegate;
    }
    taskVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[MXBADelegate sharedAppDelegate].topViewController presentViewController:taskVC animated:false completion:nil];
}

// 我的推广
- (void)pushToPromotion {
    myPopularizeVC *vc = [[myPopularizeVC alloc] init];
    vc.titleStr = YZMsg(@"Hotpage_my_expand");
    if (viewController) {
        vc.hidesBottomBarWhenPushed = YES;
        viewController.navigationController.navigationBar.hidden = YES;
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    }
}

// 会员主页
- (void)pushOtherUserMsgVC:(NSString *)scheme {
    NSString *urlString = scheme;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"uid=(\\d+)" options:0 error:&error];

    if (!error) {
        NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
        if (match) {
            NSRange uidRange = [match rangeAtIndex:1];
            NSString *uid = [urlString substringWithRange:uidRange];
            otherUserMsgVC *person = [otherUserMsgVC new];
            person.userID = uid;
            if (viewController) {
                person.hidesBottomBarWhenPushed = YES;
                viewController.navigationController.navigationBar.hidden = YES;
                [viewController.navigationController pushViewController:person animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
            }
        } else {
            NSLog(@"沒有找到 UID");
        }
    } else {
        NSLog(@"正則表達式錯誤：%@", error.localizedDescription);
    }


}

- (void)pushNav:(NSString *)nav {
    if ([nav isEqualToString:@"nav://fuckgirl"]) { // 一元空降
        [self pushToOneBuyGirl];
    } else if ([nav isEqualToString:@"nav://task"]) { // 宝箱奖励中心
        [self pushToTaskCenter: nil];
    }
}
@end
