//
//  EnterLivePlay.m
//  phonelive
//
//  Created by 400 on 2020/8/1.
//  Copyright © 2020 toby. All rights reserved.
//

#import "EnterLivePlay.h"
#import "LivePlay.h"
#import "PayViewController.h"
#import "HotAndAttentionPreviewLogic.h"
#import "YBToolClass.h"
#import "UIView+LBExtension.h"
#import "LivePlayCell.h"

@interface EnterLivePlay()
{
           
}

@property(nonatomic,copy)MoviePlayBlock callback;



@end

@implementation EnterLivePlay

static EnterLivePlay* enterLivePlay = nil;

/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enterLivePlay = [[super allocWithZone:NULL] init];
    });
    
    return enterLivePlay;
}

-(void)showLivePlayFromModels:(NSMutableArray *)models index:(NSInteger)index cell:(UIView * _Nullable)cell
{
    LivePlayTableVC *livePlayTableVC = [[LivePlayTableVC alloc]init];
    livePlayTableVC.index = index;
    livePlayTableVC.datas = models;
    [[MXBADelegate sharedAppDelegate] pushViewController:livePlayTableVC cell: cell];
}


-(void)showLivePlayFromLiveID:(NSInteger)liveID fromInfoPage:(BOOL)fromInfoPage
{
  
    if (fromInfoPage) {
        [self jumpToLivePageBy:liveID nplayer:nil];
        return;
    }
    WeakSelf
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"EnterLivePlay_enterWinnerRoom") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[MXBADelegate sharedAppDelegate].topViewController dismissViewControllerAnimated:NO completion:nil];
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"EnterLivePlay_enterRoom") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if(strongSelf == nil){
            return;
        }
        
        
        [strongSelf jumpToLivePageBy:liveID nplayer:nil];
    }];
    [alertContro addAction:sureAction];
    dispatch_main_async_safe(^{
        if ([MXBADelegate sharedAppDelegate].topViewController.presentedViewController != nil)
        {
            [[MXBADelegate sharedAppDelegate].topViewController dismissViewControllerAnimated:NO completion:nil];
        }
        if ([MXBADelegate sharedAppDelegate].topViewController.presentedViewController == nil) {
            [[MXBADelegate sharedAppDelegate].topViewController presentViewController:alertContro animated:YES completion:nil];
        }
    });
    
    
}

-(void)jumpToLivePageBy:(NSInteger)liveID nplayer:(NodePlayer*)tempPlayer {
    WeakSelf
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:30];
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Home.getLiveInfo" withBaseDomian:YES andParameter:@{@"liveuid":@(liveID)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if (code == 0) {
            NSDictionary *infodics = [info firstObject];
            if ([infodics isKindOfClass:[NSDictionary class]]) {
                infodics = [infodics objectForKey:@"info"];
                if (infodics && [infodics isKindOfClass:[NSArray class]]) {
                    infodics = [(NSArray*)infodics firstObject];
                    if ([infodics isKindOfClass:[NSDictionary class]]) {
                        hotModel *model = [hotModel mj_objectWithKeyValues:infodics];
                        if ([infodics objectForKey:@"encryption"] == nil) {
                            model.encryption = true;
                        }
                        if (model!=nil) {
                            [strongSelf showLivePlayFromModel:model nplayer:tempPlayer];
                        }else{
                            [MBProgressHUD showError:YZMsg(@"Livebroadcast_Live_End")];
                        }
                        
                    }else{
                        [MBProgressHUD showError:YZMsg(@"Livebroadcast_Live_End")];
                    }
                }else{
                    [MBProgressHUD showError:YZMsg(@"Livebroadcast_Live_End")];
                }
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
    }];
}

-(void)showLivePlayFromModel:(hotModel *)model nplayer:(NodePlayer*)tempPlayer
{
 
    moviePlay *playerNew = [[moviePlay alloc]init];
    playerNew.playDocModel = model;
    playerNew.isJustPush = YES;
    
    BOOL isContent = NO;
    int i = 0;
    for (UIViewController *subVC in [MXBADelegate sharedAppDelegate].navigationViewController.viewControllers) {
        if ([subVC isKindOfClass:[moviePlay class]]) {
            isContent = YES;
            [(moviePlay*)subVC releaseAll];
            break;
        }
        i++;
    }
    [[MXBADelegate sharedAppDelegate] pushViewController:playerNew animated:YES];
    if (isContent) {
        if ([MXBADelegate sharedAppDelegate].navigationViewController.viewControllers) {
            NSMutableArray *arrays = [NSMutableArray arrayWithArray:[MXBADelegate sharedAppDelegate].navigationViewController.viewControllers];
            moviePlay *playVC = nil;
            if (arrays.count>i) {
                playVC = [arrays objectAtIndex:i];
                [playVC releaseAll];
                playVC.nplayer  = nil;
                [arrays removeObject:playVC];
            }
            [MXBADelegate sharedAppDelegate].navigationViewController.viewControllers = arrays;
        }
    }
    [playerNew changeRoom:model];

    
    NodePlayer *nplayerCurrent  = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
    [playerNew onPlayNodeVideoPlayer:nplayerCurrent  audioEnable:true];
                   
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if(strongSelf == nil){
            return;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCReleaseDatasNotifcation object:nil];
    });
}

-(void)showLivePlayFromLiveModel:(hotModel*)model nplayer:(NodePlayer*)tempPlayer cell:(LiveStreamViewCell*)cell {
    moviePlay *playerNew = [[moviePlay alloc]init];
    playerNew.playDocModel = model;
    playerNew.isJustPush = YES;
    playerNew.fromCell = cell;
    playerNew.nplayer = tempPlayer;
    [[MXBADelegate sharedAppDelegate] pushViewController:playerNew animated:NO];
    [playerNew changeRoom:model];

}
@end
