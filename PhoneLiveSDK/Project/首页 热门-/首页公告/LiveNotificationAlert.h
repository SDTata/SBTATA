//
//  LiveNotificationAlert.h
//  phonelive2
//
//  Created by test on 2021/6/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//0是合并先弹出，1是单独一个个排队弹框。透明的wkwebView 下面一个关闭的圆形X

typedef void (^FinishBlock)(void);

@interface LiveNotificationAlert : UIView



@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
+ (instancetype)instanceNotificationAlertWithMessages:(NSArray *)messages;

- (void)alertShowAnimationWithfishi:(UIViewController*)vc block:(FinishBlock)block;

@end

NS_ASSUME_NONNULL_END
