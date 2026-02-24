//
//  RemoteInterfaceView.h
//  c700LIVE
//
//  Created by s5346 on 2023/12/7.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchSuperView.h"
#import "socketLivePlay.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderUserModel : NSObject
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *giftID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *orderName;
@property (nonatomic, strong) NSString *second;
@property (nonatomic, strong) NSString *swiftType;
@property (nonatomic, assign) LiveToyInfInfoType type;
@end

@protocol RemoteInterfaceViewDelegate <NSObject>
@optional
- (void)remoteInterfaceViewDelegateForStartToy:(OrderUserModel*)model;
- (void)remoteInterfaceViewDelegateForSelectToy;
- (void)remoteInterfaceViewDelegateForShowPanel;

@end

@interface RemoteInterfaceView : TouchSuperView
@property(nonatomic, weak) id<RemoteInterfaceViewDelegate> delegate;
- (instancetype)initWithArchir:(BOOL)isArchor;
- (void)forceShrink:(CGPoint)point;
- (void)receiveOrderModel:(OrderUserModel*)info;
// 變更藍牙狀態
- (void)changeToyStatus:(BOOL)isConnected;
- (void)showConnectView;
// 變更電量顯示
-(void)changeBatteryInfo:(int)battery;
@end

NS_ASSUME_NONNULL_END
