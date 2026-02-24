//
//  LobbyHistoryAlertController.h
//  phonelive2
//
//  Created by test on 2021/6/25.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^Callback)(void);
@interface LobbyHistoryAlertController : UIViewController
@property (nonatomic,copy) Callback closeCallback;
@property(nonatomic,assign) BOOL isPresent;
@end

NS_ASSUME_NONNULL_END
