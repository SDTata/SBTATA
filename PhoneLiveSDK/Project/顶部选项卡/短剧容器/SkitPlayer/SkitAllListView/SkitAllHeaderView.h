//
//  SkitAllHeaderView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkitVideoInfoModel.h"
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkitAllHeaderView : UIView

- (void)updateData:(HomeRecommendSkit*)infoModel videoInfoModel:(NSArray<SkitVideoInfoModel*>*)videoInfoModels;

@end

NS_ASSUME_NONNULL_END
