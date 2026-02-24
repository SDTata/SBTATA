//
//  VideoTicketFloatView.h
//  phonelive2
//
//  Created by vick on 2024/7/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFloatView.h"

@interface VideoTicketFloatView : BaseFloatView

+ (void)showFloatView;

+ (void)hideFloatView;

+ (void)refreshFloatData;

- (void)refreshData;

+ (void)hidePostVideoButton;

+ (void)showPostVideoButton;

+ (void)hideTicketButton;

+ (void)showTicketButton;
@end
