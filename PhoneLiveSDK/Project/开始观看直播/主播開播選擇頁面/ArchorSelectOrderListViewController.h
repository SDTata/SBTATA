//
//  ArchorSelectOrderListViewController.h
//  c700LIVE
//
//  Created by s5346 on 2023/12/27.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteControllerCell.h"
#import "socketLivePlay.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ArchorSelectOrderListViewControllerDelegate <NSObject>

- (void)archorSelectOrderListViewControllerForSelectedOrder:(NSArray<RemoteOrderModel*>*)orderModel;

@end

@interface ArchorSelectOrderListViewController : UIViewController
@property(nonatomic, strong) NSArray<RemoteOrderModel*> *oldSelectorderModels;
@property(nonatomic, assign) id<ArchorSelectOrderListViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
