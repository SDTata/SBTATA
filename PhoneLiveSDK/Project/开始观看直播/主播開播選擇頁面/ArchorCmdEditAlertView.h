//
//  ArchorCmdEditAlertView.h
//  phonelive2
//
//  Created by vick on 2024/5/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteOrderModel.h"

@interface ArchorCmdEditAlertView : UIView

@property (nonatomic, strong) RemoteOrderModel *model;
@property (nonatomic, copy) VKBlock refreshBlock;

@end
