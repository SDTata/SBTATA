//
//  OBSViewController.h
//  phonelive2
//
//  Created by s5346 on 2023/12/27.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+Extention.h"
#import "RandomRule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OBSViewControllerDelegate <NSObject>

- (void)oBSViewControllerForStart;
- (void)oBSViewControllerForCancel;

@end

@interface OBSViewController : UIViewController
@property(nonatomic, assign) id<OBSViewControllerDelegate> delegate;
- (void)sendPushStream:(NSString*)pushString;
@end

NS_ASSUME_NONNULL_END
