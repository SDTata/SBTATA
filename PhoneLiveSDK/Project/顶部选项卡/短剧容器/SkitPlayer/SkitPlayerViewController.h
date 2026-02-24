//
//  SkitPlayerViewController.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeRecommendSkitModel.h"
#import "SkitVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitPlayerViewController : UIViewController

@property (nonatomic, strong) NSArray <HomeRecommendSkit *> *skitArray;
@property (nonatomic, assign) NSInteger skitIndex;

- (instancetype)initWithModel:(HomeRecommendSkit*)model;
+ (void)requestVideo:(NSString*)skitId autoDeduct:(BOOL)autoDeduct refresh_url:(BOOL)refresh_url completion:(nullable void (^)(SkitVideoInfoModel *newModel, BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
