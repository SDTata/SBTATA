//
//  LaunchInitManager.h
//  phonelive
//
//  Created by test on 3/22/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <deviceiOS/SecurityDevice.h>


@interface LaunchInitManager : NSObject
@property(nonatomic,strong)UIWindow *serviceWindow;
+ (instancetype)sharedInstance;
//@property(nonatomic,strong)SecurityDevice * securityDevice;

@property(nonatomic,strong)NSString *aliToken;
@property(nonatomic,strong)NSString *wangyiToken;

-(void)initWangyiToken:(void (^)(BOOL success))callback;

- (UIWindow*)showAndStartLaunchProcess;
- (void)hiddenAndReleaseLaunchProcess;
- (void)startMonitor;
@end

