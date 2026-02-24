//
//  CountryFilterModel.h
//  phonelive2
//
//  Created by 400 on 2021/8/6.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CountryFilterModel : NSObject
@property(nonatomic,strong)NSString *countryCode;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *icon;
@end

NS_ASSUME_NONNULL_END
