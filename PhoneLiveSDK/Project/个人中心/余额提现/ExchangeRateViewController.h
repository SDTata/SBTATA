//
//  ExchangeRateViewController.h
//  phonelive2
//
//  Created by lucas on 2021/9/24.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExchangeRateModel.h"

typedef void (^NewExchangeRate)(ExchangeRateModel * _Nullable model);

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeRateViewController : UIViewController

@property (nonatomic,strong) NSString *type;

@property (nonatomic,copy) NewExchangeRate callBlock;

@end

NS_ASSUME_NONNULL_END
