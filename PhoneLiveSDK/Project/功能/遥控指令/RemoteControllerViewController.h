//
//  RemoteControllerViewController.h
//  phonelive2
//
//  Created by s5346 on 2023/12/4.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteControllerCell.h"
#import "socketLivePlay.h"
#import "RemoteOrderModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^Completed)(NSDictionary *info);
@protocol RemoteControllerViewControllerDelegate <NSObject>

- (void)remoteControllerViewControllerForGetInfo:(LiveToyInfInfoType)type completed:(Completed)completed;
- (void)remoteControllerViewControllerForDismiss;
- (void)remoteControllerViewControllerForSendGiftInfo:(NSArray *)datas andLianFa:(NSString *)lianfa;
- (void)remoteControllerViewControllerForRecharge;

@end

@interface RemoteControllerViewController : UIViewController
@property (nonatomic, weak) id<RemoteControllerViewControllerDelegate> delegate;
- (void)setupViewsForType:(LiveToyInfInfoType)type toyName:(NSString*)toy orderName:(NSString*)order;
- (void)addPlayModel:(hotModel *)playModel;
@end

NS_ASSUME_NONNULL_END
