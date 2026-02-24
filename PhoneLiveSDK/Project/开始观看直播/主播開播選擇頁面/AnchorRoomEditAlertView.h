//
//  AnchorRoomEditAlertView.h
//  phonelive2
//
//  Created by vick on 2025/7/29.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnchorRoomEditAlertView : UIView

@property (nonatomic, copy) void (^clickTypeBlock)(NSString *type, NSString *text);

@end
