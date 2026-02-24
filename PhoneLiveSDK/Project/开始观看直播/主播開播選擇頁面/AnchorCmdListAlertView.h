//
//  AnchorCmdListAlertView.h
//  phonelive2
//
//  Created by vick on 2025/7/25.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteOrderModel.h"

@interface AnchorCmdListAlertView : UIView

@property (nonatomic, strong) NSArray <RemoteOrderModel *> *selectedModels;
@property (nonatomic, assign) BOOL orderSwitchStatus;
@property (nonatomic, copy) void (^clickSaveBlock)(NSArray <RemoteOrderModel *> *models, BOOL status);

@end
