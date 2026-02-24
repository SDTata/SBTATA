//
//  otherUserMsgVC.h
//  phonelive2
//
//  Created by s5346 on 2024/8/13.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMListen.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^chatFollowBlock)(void);

@interface otherUserMsgVC : JMListen

@property(nonatomic,strong)NSString *userID;
@property (nonatomic,copy) chatFollowBlock block;

@end

NS_ASSUME_NONNULL_END
