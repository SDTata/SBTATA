//
//  LongVideoMoreVC.h
//  phonelive2
//
//  Created by vick on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LongVideoMoreVC : UIViewController

@property (nonatomic, strong) MovieCateModel *cateModel;
@property (nonatomic, strong) MovieCateModel *subCateModel;

@end

NS_ASSUME_NONNULL_END
