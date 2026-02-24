//
//  AddUSDTController.h
//  phonelive2
//
//  Created by test on 2022/1/12.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NewType)(void);

NS_ASSUME_NONNULL_BEGIN

@interface AddUSDTController : UIViewController
@property (nonatomic,copy) NewType block;

@end

NS_ASSUME_NONNULL_END
