//
//  SearchBankViewController.h
//  phonelive2
//
//  Created by lucas on 2021/9/16.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^NewBankName)(NSInteger index,NSString * _Nullable bankName);

NS_ASSUME_NONNULL_BEGIN

@interface SearchBankViewController : UIViewController

@property (nonatomic, strong) NSString *key;

@property (nonatomic,copy) NewBankName callBlock;

@end

NS_ASSUME_NONNULL_END
