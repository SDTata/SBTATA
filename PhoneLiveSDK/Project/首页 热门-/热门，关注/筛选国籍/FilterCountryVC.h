//
//  FilterCountryVC.h
//  phonelive2
//
//  Created by 400 on 2021/8/6.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryFilterModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FilterCountryDelegate <NSObject>

- (void)countryModelSelected:(CountryFilterModel*)model;

@end

@interface FilterCountryVC : UIViewController
@property(nonatomic,assign)BOOL isPayPage;
@property(nonatomic,assign)id<FilterCountryDelegate> delegate;
@property(nonatomic,retain)NSArray *datas;
@end

NS_ASSUME_NONNULL_END
