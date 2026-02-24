//
//  HotCycleBanner.h
//  phonelive2
//
//  Created by test on 2022/3/15.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"

@interface HotCycleBanner : UIImageView
{
    SDCycleScrollView *bannerScrollView;
    NSArray           *adBannerInfoArr;
}
- (instancetype)initWithFrame:(CGRect)frame andType:(NSInteger)type;
- (void)downDataWithHandler:(void(^)(BOOL hasData))handler;
@end
