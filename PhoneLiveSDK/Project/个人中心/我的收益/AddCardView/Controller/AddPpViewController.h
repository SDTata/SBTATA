//
//  AddPpViewController.h
//  phonelive2
//
//  Created by lucas on 2022/3/21.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NewType)(void);
NS_ASSUME_NONNULL_BEGIN

@interface AddPpViewController : UIViewController
@property (nonatomic,copy) NewType block;
@property (nonatomic,strong) NSString * titleStr;
@property (nonatomic,strong) NSString * typeNum;
@end

NS_ASSUME_NONNULL_END
