//
//  MessageListViewController.h
//  phonelive2
//
//  Created by user on 2024/8/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageListViewController : UIViewController
- (instancetype)initWithMessageList:(BOOL)isHomeMessagesList;
@property (nonatomic, assign) BOOL isHomeMessagesList; // 是否為消息列表
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *navTitle;
@end

NS_ASSUME_NONNULL_END
