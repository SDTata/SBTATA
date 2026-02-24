//
//  GameToolClass.m
//

#import "GameToolClass.h"
#import<CommonCrypto/CommonDigest.h>
#import "MXBADelegate.h"
#import "LobbyLotteryVC_New.h"
#import "h5game.h"
#import "LotteryBetViewController_Fullscreen.h"
#import "LotteryBetHallVC.h"

@implementation GameToolClass
static GameToolClass* kSingleObject = nil;
static NSInteger curOpenedLotteryType = 0;
static NSString *curGameCenterDefaultType;


/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kSingleObject = [[super allocWithZone:NULL] init];
    });
    
    return kSingleObject;
}

// 重写创建对象空间的方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    // 直接调用单例的创建方法
    return [self sharedInstance];
}
/**
 进入游戏
 @param successBlock 成功的回调
 @param failBlock 失败的回调
 */
+ (void)enterGame:(NSString *)plat menueName:(NSString*)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString*)urlName parentViewController: (UIViewController *)parentVC autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock{
    if ([plat isEqualToString:@"lottery"]) {
        if (([kindID integerValue] == 26 || [kindID integerValue] == 27) && ![YBToolClass sharedInstance].default_old_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            [VC setLotteryType:[kindID integerValue]];
            VC.lotteryDelegate = (id)parentVC;
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if ([kindID integerValue] == 28 && ![YBToolClass sharedInstance].default_oldBJL_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            [VC setLotteryType:[kindID integerValue]];
            VC.lotteryDelegate = (id)parentVC;
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if ([kindID integerValue] == 29 && ![YBToolClass sharedInstance].default_oldZJH_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            [VC setLotteryType:[kindID integerValue]];
            VC.lotteryDelegate = (id)parentVC;
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if ([kindID integerValue] == 30 && ![YBToolClass sharedInstance].default_oldZP_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            [VC setLotteryType:[kindID integerValue]];
            VC.lotteryDelegate = (id)parentVC;
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if ([kindID integerValue] == 31 && ![YBToolClass sharedInstance].default_oldLH_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            [VC setLotteryType:[kindID integerValue]];
            VC.lotteryDelegate = (id)parentVC;
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if (BetType(kindID.integerValue) == LotteryBetTypeLHC && ![YBToolClass sharedInstance].default_oldLHC_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = (id)parentVC;
            VC.lotteryType = [kindID integerValue];
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if (BetType(kindID.integerValue) == LotteryBetTypeSSC && ![YBToolClass sharedInstance].default_oldSSC_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = (id)parentVC;
            VC.lotteryType = [kindID integerValue];
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if (BetType(kindID.integerValue) == LotteryBetTypeSC && ![YBToolClass sharedInstance].default_oldSC_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = (id)parentVC;
            VC.lotteryType = [kindID integerValue];
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        } else if (BetType(kindID.integerValue) == LotteryBetTypeNN && ![YBToolClass sharedInstance].default_oldNN_view) {
            LotteryBetHallVC *VC = [LotteryBetHallVC new];
            VC.lotteryDelegate = (id)parentVC;
            VC.lotteryType = [kindID integerValue];
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        }
        else if([kindID integerValue] == 32 || [kindID integerValue] == 11 || [kindID integerValue] == 6 || [kindID integerValue] == 7 || [kindID integerValue] == 8) {
            LobbyLotteryVC_New *VC = [[LobbyLotteryVC_New alloc]initWithNibName:@"LobbyLotteryVC_New" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            [VC setLotteryType:[kindID integerValue]];
            VC.lotteryDelegate = (id)parentVC;
            //VC.urlName = urlName;
            VC.lotteryName = nameLottery;
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        }
        else {
            /**
             6: 三分时时彩
             7: 香港六合彩
             8: 一分六合彩
             10: 百人牛牛
             11: 一分时时彩
             14: 一分赛车
             26: 一分快三
             27: 三分快三
             28: 百家乐
             29: 炸金花
             30: 轮盘
             31: 龙虎
             32: 澳门六合彩
             */
            LotteryBetViewController_Fullscreen * VC = [[LotteryBetViewController_Fullscreen alloc]initWithNibName:@"LotteryBetViewController_Fullscreen" bundle:[XBundle currentXibBundleWithResourceName:@""]];
            VC.lotteryDelegate = (id)parentVC;
            VC.lotteryNameStr = nameLottery;
            [VC setLotteryType: [kindID integerValue]];
            if (parentVC) {
                VC.hidesBottomBarWhenPushed = YES;
                parentVC.navigationController.navigationBar.hidden = YES;
                [parentVC.navigationController pushViewController:VC animated:YES];
            } else {
                [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
            }
        }
        return;
    }
    [self enterH5Game:plat menueName:nameLottery kindID:kindID iconUrlName:urlName parentViewController:parentVC autoExchange:autoExchange success:successBlock fail:failBlock finishBlock:^(NSString *url, BOOL bKYorLC) {
        [GameToolClass goH5:url bKYorLC:bKYorLC viewController:parentVC];
    }];
}

+ (void)enterVideoH5Game:(NSString *)plat menueName:(NSString *)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString *)urlName parentViewController:(UIViewController *)parentVC autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock {
    [self enterH5Game:plat showHud:false menueName:nameLottery kindID:kindID iconUrlName:urlName parentViewController: nil autoExchange:autoExchange success:successBlock fail:failBlock finishBlock:^(NSString *url, BOOL bKYorLC) {
        [GameToolClass goVideoH5Game:url bKYorLC:bKYorLC];
    }];
}

+ (void)enterHomeH5Game:(NSString *)plat menueName:(NSString *)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString *)urlName autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock finishBlock:(void(^)(NSString *url, BOOL bKYorLC))finishBlock {
    [self enterH5Game:plat showHud:false menueName:nameLottery kindID:kindID iconUrlName:urlName parentViewController: nil autoExchange:autoExchange success:successBlock fail:failBlock finishBlock:finishBlock];
}

+ (void)enterH5Game:(NSString *)plat menueName:(NSString*)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString*)urlName parentViewController: (UIViewController *)parentVC autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock finishBlock:(void(^)(NSString *url, BOOL bKYorLC))finishBlock {
    [self enterH5Game:plat showHud:true menueName:nameLottery kindID:kindID iconUrlName:urlName parentViewController: nil autoExchange:autoExchange success:successBlock fail:failBlock finishBlock:finishBlock];
}
+(void)enterH5Game:(NSString *)plat showHud:(BOOL)showHUd menueName:(NSString*)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString*)urlName parentViewController: (UIViewController *)parentVC autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock finishBlock:(void(^)(NSString *url, BOOL bKYorLC))finishBlock {
    if (showHUd) {
        if(autoExchange){
            // 提示已自动转换余额
            [MBProgressHUD showMessage:YZMsg(@"GameToolClass_switchMoneyType")];
        }else{
            [MBProgressHUD showMessage:YZMsg(@"GameToolClass_EnterGame")];
        }
    }
   
    NSString *enterGameUrl = @"User.enterGame";
    NSDictionary *param = @{@"subplat":plat,@"kindID":kindID,@"autoExchange":[NSNumber numberWithBool:autoExchange]};
    [[YBNetworking sharedManager] postNetworkWithUrl:enterGameUrl withBaseDomian:YES andParameter:param data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        NSString *tipString = @"";
        if(code == 0){
            NSDictionary *gameInfo = info;//[info objectAtIndex:0];
            if(!gameInfo || !gameInfo.count){
                [MBProgressHUD showError:YZMsg(@"GameToolClass_EnterGameError")];
                return;
            }
            if(autoExchange){
                // 提示已自动转换余额
                NSArray *platArray = gameInfo[@"platArray"];
                for (int i=0; i<platArray.count; i++) {
                    NSDictionary *platInfo = [platArray objectAtIndex:i];
//                    if([platInfo[@"plat"] isEqualToString:plat]){
                        tipString = [NSString stringWithFormat:YZMsg(@"GameToolClass_gameName%@_balance%@"), platInfo[@"name"], ([PublicObj checkNull:minstr(platInfo[@"coin"])]?@"0.0":[YBToolClass getRateCurrencyWithoutK:minstr(platInfo[@"coin"])])];
                        break;
//                    }
                }
            }else{
//                [MBProgressHUD hideHUD];
            }
            BOOL bKYorLC = false;
            if([plat isEqualToString:@"ky"] || [plat isEqualToString:@"lc"]){
                bKYorLC = true;
            }
            if ([PublicObj checkNull:gameInfo[@"url"] ]) {
                [MBProgressHUD showError:[NSString stringWithFormat:@"error"]];
                failBlock();
                return;
            }
            if (finishBlock) {
                finishBlock(gameInfo[@"url"], bKYorLC);
            }
            if(tipString.length > 0){
                [GameToolClass showTip:YZMsg(@"GameToolClass_switchMoneyTypeSuccess") tipString:tipString];
            }
            
            successBlock(code, info, msg);
        }
        else{
            if(msg.length > 0){
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",msg]];
            }else{
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@(%d)",YZMsg(@"GameToolClass_EnterGameReson"),code]];
            }
        }
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:YZMsg(@"GameToolClass_EnterGameError")];
        failBlock();
    }];
}

+(void) showTip:(NSString *)title tipString:(NSString *)tipString{
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:tipString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:YZMsg(@"publictool_sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:suerA];
    if (alertC.presentedViewController == nil) {
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }
    
}

+ (void)goH5:(NSString *)url bKYorLC:(BOOL)bKYorLC viewController:(nonnull UIViewController *)parentVC{
    h5game *VC = [[h5game alloc]init];
    
    //
    NSString *paths = url;//[NSString stringWithFormat:@"%@%@", url, @"&jumpType=3&backUrl=backtohome%3a%2f%2f"];//@"https://play.ky206.com/";
    //                                        NSString *paths = @"https://shop209793.m.youzan.com/v2/showcase/homepage?alias=jfm4tjis";
    VC.urls = paths;
    VC.bKYorLC = bKYorLC;
    VC.titles = @"";
    VC.bHiddenReturnBtn = true;
    if (parentVC) {
        VC.hidesBottomBarWhenPushed = YES;
        parentVC.navigationController.navigationBar.hidden = YES;
        [parentVC.navigationController pushViewController:VC animated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    }
}

+ (void)goVideoH5Game:(NSString *)url bKYorLC:(BOOL)bKYorLC {
    h5game *VC = [[h5game alloc]init];
    
    //
    NSString *paths = url;//[NSString stringWithFormat:@"%@%@", url, @"&jumpType=3&backUrl=backtohome%3a%2f%2f"];//@"https://play.ky206.com/";
    //                                        NSString *paths = @"https://shop209793.m.youzan.com/v2/showcase/homepage?alias=jfm4tjis";
    VC.urls = paths;
    VC.bKYorLC = bKYorLC;
    VC.titles = @"";
    VC.bHiddenReturnBtn = true;
    VC.isFromVideo = YES;
    [VC showGameFromBottom];
}

+(void)backAllCoin:(successBlock)successBlock fail:(failBlock)failBlock{
    NSString *backAllCoinUrl = [NSString stringWithFormat:@"User.backAllCoin"];
    NSLog(@"TimeBackCoin:.0%f",[[NSDate date] timeIntervalSince1970]);
    [[YBNetworking sharedManager] postNetworkWithUrl:backAllCoinUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

        successBlock(code, info, msg);
        NSLog(@"TimeBackCoinSuc:%.0f",[[NSDate date] timeIntervalSince1970]);
    } fail:^(NSError * _Nonnull error) {
        failBlock();
        NSLog(@"TimeBackCoinError:%.0f",[[NSDate date] timeIntervalSince1970]);
    }];
}

+ (void)setCurOpenedLotteryType:(NSInteger)lotteryType{
    curOpenedLotteryType = lotteryType;
}

+ (NSInteger)getCurOpenedLotteryType{
    return curOpenedLotteryType;
}

+ (void)setCurGameCenterDefaultType:(NSString *)defaultType{
    curGameCenterDefaultType = defaultType;
}

+ (NSString *)getCurGameCenterDefaultType{
    return curGameCenterDefaultType;
}

+ (BOOL) isLHC:(NSInteger)lotteryType{
    if(lotteryType == 8||lotteryType == 32 ||lotteryType == 7 ){
        return true;
    }
    return false;
}
+ (BOOL) isKS:(NSInteger)lotteryType{
    if(lotteryType == 13 || lotteryType == 22 || lotteryType == 23 || lotteryType == 26 || lotteryType == 27){
        return true;
    }
    return false;
}
+ (BOOL) isSSC:(NSInteger)lotteryType{
    if(lotteryType == 11 || lotteryType == 6){
        return true;
    }
    return false;
}
+ (BOOL) isSC:(NSInteger)lotteryType{
    if(lotteryType == 14 || lotteryType == 9){
        return true;
    }
    return false;
}

@end
