//
//  HotCycleBanner.m
//  phonelive2
//
//  Created by test on 2022/3/15.
//  Copyright © 2022 toby. All rights reserved.
//

#import "HotCycleBanner.h"
#import "webH5.h"
#import "NavWeb.h"
#import "UINavModalWebView.h"
#import "OneBuyGirlViewController.h"
#import "myWithdrawVC2.h"
#import "PayViewController.h"
#import <UMCommon/UMCommon.h>

@interface HotCycleBanner ()<SDCycleScrollViewDelegate>{
    NSInteger _type;//0 组5 1 组10 2 组0
}
@end
@implementation HotCycleBanner

- (instancetype)initWithFrame:(CGRect)frame andType:(NSInteger)type{
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        _type = type;
        WeakSelf
        [self downDataWithHandler:^(BOOL hasData) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf setUI];
        }];
    }
    return self;
}
//MARK:-设置button
-(void)setUI
{
    
    bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(5, 5, _window_width - 10, 150*((SCREEN_WIDTH - 10)/350.0))delegate:self placeholderImage:[ImageBundle imagewithBundleName:YZMsg(@"img_zwsj")]];
    
    bannerScrollView.layer.cornerRadius = 7;
    bannerScrollView.layer.masksToBounds = YES;
    bannerScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    bannerScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    bannerScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    bannerScrollView.pageControlDotSize = CGSizeMake(6, 6);
    bannerScrollView.pageDotColor = RGB_COLOR(@"#ffffff", 0.4);
    bannerScrollView.currentPageDotColor = RGB_COLOR(@"#ffffff", 0.8);
    bannerScrollView.autoScrollTimeInterval = 5;
    bannerScrollView.backgroundColor = RGB(244, 245, 246);
    [self addSubview:bannerScrollView];
    self.userInteractionEnabled = YES;
  
}
- (void)reloadUI{
    if (self->adBannerInfoArr.count>0) {
        bannerScrollView.frame = CGRectMake(0, 0, _window_width - 30, 150*(SCREEN_WIDTH/350));
        self.hidden = NO;
    }else{
        bannerScrollView.frame = CGRectMake(0, 0, _window_width - 30, 0);
        self.hidden = YES;
    }
}
//MARK:-layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
}
-(void)downDataWithHandler:(void(^)(BOOL hasData))handler{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.GetBaseInfo" withBaseDomian:YES andParameter:@{@"uid":[Config getOwnID],@"token":[Config getOwnToken]} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        NSLog(@"%@",info);
        
        NSMutableArray *imageUrlArr = [NSMutableArray array];
        NSMutableArray *infoDataArr = [NSMutableArray array];
        if([info isKindOfClass:[NSArray class]] && [(NSArray*)info count]>0){
            
            NSDictionary *infoDic = [info objectAtIndex:0];
            
            if([infoDic objectForKey:@"adlist"])
            {
                NSArray *adListArr = [infoDic objectForKey:@"adlist"];
                
                for(NSDictionary *adDic in adListArr)
                {
                    if([[adDic objectForKey:@"pos"] intValue] == 6 && strongSelf->_type == 0)
                    {
                        //组5样式组装数据
                        [infoDataArr addObject:adDic];
                        if([adDic objectForKey:@"image"])
                        {
                            [imageUrlArr addObject:[adDic objectForKey:@"image"]];
                        }
                    }else if([[adDic objectForKey:@"pos"] intValue] == 7 && strongSelf->_type == 1)
                    {
                        //组5样式组装数据
                        [infoDataArr addObject:adDic];
                        if([adDic objectForKey:@"image"])
                        {
                            [imageUrlArr addObject:[adDic objectForKey:@"image"]];
                        }
                    }else if([[adDic objectForKey:@"pos"] intValue] == 8 && strongSelf->_type == 2)
                    {
                        //组5样式组装数据
                        [infoDataArr addObject:adDic];
                        if([adDic objectForKey:@"image"])
                        {
                            [imageUrlArr addObject:[adDic objectForKey:@"image"]];
                        }
                    }
                }
            }
            if (infoDataArr) {
                strongSelf->adBannerInfoArr = [NSArray arrayWithArray:infoDataArr];
            }
            [strongSelf reloadUI];
            if (strongSelf->adBannerInfoArr && strongSelf->adBannerInfoArr.count > 0) {
                if (handler) {
                    handler(YES);
                }
            }else{
                if (handler) {
                    handler(NO);
                }
            }
            strongSelf->bannerScrollView.imageURLStringsGroup = imageUrlArr;
            NSArray *system_msg = [infoDic objectForKey:@"system_msg"];
            [common saveSystemMsg:system_msg];
        }else{
            [MBProgressHUD showError:msg];
        }
       
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        dispatch_main_async_safe(^{
            [strongSelf reloadUI];
            if (handler) {
                handler(NO);
            }
        });
    }];
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    if(adBannerInfoArr.count > index)
    {
        NSDictionary *infoDic = [adBannerInfoArr objectAtIndex:index];
        
        if([infoDic objectForKey:@"url"])
        {
            NSString *urlStr = [infoDic objectForKey:@"url"];
            NSString *urlShowType = [infoDic objectForKey:@"show_type"];
            NSDictionary *data = @{@"scheme": urlStr, @"showType": urlShowType};
            [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
        }
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"event_detail": [NSString stringWithFormat:@"banner%li",index]};
        [MobClick event:@"live_home_detail_click" attributes:dict];
    }
}
- (void)closeService:(id)sender{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}
@end
