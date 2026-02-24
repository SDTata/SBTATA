//
//  FQLockGestureViewController.h
//  PhoneLiveSDK
//
//  Created by wuwuFQ on 2022/9/17.
//  Updated on 2025/04/07.
//

#import <UIKit/UIKit.h>
#import "FQLockConfig.h"
#import "VKSupportUtil.h"

typedef void(^LocalLockBlock)(BOOL complete);

@interface FQLockGestureViewController : UIViewController

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, assign) FQLockType lockType;
@property (nonatomic, strong) LocalLockBlock localLockBlock;

@end
