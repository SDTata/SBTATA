//
//  YBBottomView.m
//  TCLVBIMDemo
//
//  Created by admin on 16/11/11.
//  Copyright © 2016年 tencent. All rights reserved.
//



#import "YBBottomView.h"
#import "webH5.h"
#import "NavWeb.h"
#import "UINavModalWebView.h"
#import "OneBuyGirlViewController.h"
#import <UMCommon/UMCommon.h>

@interface YBBottomView ()<SDCycleScrollViewDelegate>
@end
@implementation YBBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
       
        [self setUI];
        [self downDataWithHandler:nil Handler:nil];
    }
    return self;
}
//MARK:-设置button
-(void)setUI
{
    bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, _window_width - 30, 80*((SCREEN_WIDTH-30)/350))delegate:self placeholderImage:[ImageBundle imagewithBundleName:YZMsg(@"img_zwsj")]];
    bannerScrollView.layer.cornerRadius = 7;
    bannerScrollView.layer.masksToBounds = YES;
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
    if (adBannerInfoArr.count>0) {
        bannerScrollView.frame = CGRectMake(0, 0, _window_width - 30, 80*((SCREEN_WIDTH-30)/350));
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
-(void)downDataWithHandler:(NSDictionary *)infoDic Handler:(void(^)(BOOL hasData))handler{

        NSMutableArray *imageUrlArr = [NSMutableArray array];
        NSMutableArray *infoDataArr = [NSMutableArray array];
        
        if([infoDic objectForKey:@"adlist"])
        {
            NSArray *adListArr = [infoDic objectForKey:@"adlist"];
            
            for(NSDictionary *adDic in adListArr)
            {
                if([[adDic objectForKey:@"pos"] intValue] == 5 || [[adDic objectForKey:@"pos"]  isEqual: @"5"])
                {
                    [infoDataArr addObject:adDic];
                    if([adDic objectForKey:@"image"])
                    {
                        [imageUrlArr addObject:[adDic objectForKey:@"image"]];
                    }
                }
            }
        }
        if (infoDataArr) {
           adBannerInfoArr = [NSArray arrayWithArray:infoDataArr];
        }
        [self reloadUI];
        if (adBannerInfoArr && adBannerInfoArr.count > 0) {
            if (handler) {
                handler(YES);
            }
        }else{
            if (handler) {
                handler(NO);
            }
        }
        bannerScrollView.imageURLStringsGroup = imageUrlArr;
        NSArray *system_msg = [infoDic objectForKey:@"system_msg"];
        [common saveSystemMsg:system_msg];
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
            
            
            if([urlStr length] > 0)
            {
                if ([urlStr containsString:@"http"]) {
                    urlStr = [YBToolClass replaceUrlParams:urlStr];
                    // 0应用内显示。1应用外显示
                    if(urlShowType && urlShowType != (id)[NSNull null] && [urlShowType isEqualToString:@"0"]){
                        NavWeb *VC = [[NavWeb alloc]init];
                        VC.titles = @"";
                        VC.urls = urlStr;
                        
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
                        
                    }
                    else{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    }
                }else{
                    OneBuyGirlViewController *oneBuyGirlVC = [[OneBuyGirlViewController alloc]initWithNibName:@"OneBuyGirlViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
                    [[MXBADelegate sharedAppDelegate] pushViewController:oneBuyGirlVC animated:YES];
                }
                
            }
        }
        [MobClick event:@"mine_banner_click" attributes:@{@"eventType": @(1)}];
    }
}
- (void)closeService:(id)sender{
    [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:YES completion:nil];
}
@end
