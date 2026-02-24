//
//  SkitPlayerVideoCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitPlayerVideoPortraitControlView.h"
#import "SkitHotModel.h"
#import "SkitVideoInfoModel.h"

@class SkitPlayerManager;
NS_ASSUME_NONNULL_BEGIN

@interface SkitPlayerVideoCell : VKBaseTableViewCell
@property (nonatomic, strong, nullable) SkitPlayerVideoPortraitControlView *controlView;
@property (nonatomic, strong) UIImageView *coverImgView;
@property(nonatomic, readonly) SkitPlayerManager *manager;

- (void)update:(SkitVideoInfoModel*)model infoModel:(HomeRecommendSkit*)infoModel;
- (void)removePlayerManager;
@end

NS_ASSUME_NONNULL_END
