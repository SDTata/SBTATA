//
//  YBBottomView.h
//  TCLVBIMDemo
//
//  Created by admin on 16/11/11.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"

@interface YBBottomView : UIImageView
{
    SDCycleScrollView *bannerScrollView;
    NSArray           *adBannerInfoArr;
}

-(void)downDataWithHandler:(NSDictionary *)infoDic Handler:(void(^)(BOOL hasData))handler;
@end
