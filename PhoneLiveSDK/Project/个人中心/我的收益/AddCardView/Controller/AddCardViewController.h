//
//  TestViewController.h
//  BRPickerViewDemo
//
//  Created by 任波 on 2017/8/11.
//  Copyright © 2017年 91renb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NewType)(void);

NS_ASSUME_NONNULL_BEGIN
@interface AddCardViewController : UIViewController

@property (nonatomic,copy) NewType block;

@end
NS_ASSUME_NONNULL_END
