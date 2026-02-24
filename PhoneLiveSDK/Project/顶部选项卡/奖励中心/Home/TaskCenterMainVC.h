//
//  TaskCenterMainVC.h
//  phonelive2
//
//  Created by vick on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskCenterMainVC : UIViewController

@property (nonatomic, assign) BOOL isFromTab;
@property (nullable, nonatomic, strong) NSString *titleStr;
@end

NS_ASSUME_NONNULL_END
