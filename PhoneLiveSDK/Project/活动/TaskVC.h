//
//  TaskVC.h
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskTableVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface TaskVC : UIViewController
@property(nonatomic,assign)id<TaskJumpDelegate> delelgate;

@property(nonatomic,strong)NSString *titleGroupId;

@end

NS_ASSUME_NONNULL_END
