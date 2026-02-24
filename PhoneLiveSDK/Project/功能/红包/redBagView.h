//
//  redBagView.h
//  yunbaolive
//
//  Created by Boom on 2018/11/16.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotModel.h"
#import "LivePlayNOScrollView.h"
typedef void (^sendRedSuccess)(NSString * _Nullable type);
NS_ASSUME_NONNULL_BEGIN

@interface redBagView : LivePlayNOScrollView<UITextFieldDelegate>
@property (nonatomic,strong) hotModel *zhuboModel;
@property (nonatomic,copy) sendRedSuccess block;
@end

NS_ASSUME_NONNULL_END
