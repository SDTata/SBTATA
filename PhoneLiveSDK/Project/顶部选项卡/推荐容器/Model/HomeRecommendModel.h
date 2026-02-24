//
//  HomeRecommendModel.h
//  c700LIVE
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeRecommendAdsModel.h"
#import "HomeRecommendGameModel.h"
#import "HomeRecommendLiveModel.h"
#import "HomeRecommendLongVideoModel.h"
#import "HomeRecommendLotteriesModel.h"
#import "HomeRecommendShortVideoModel.h"
#import "HomeRecommendSkitModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeRecommendModel : NSObject

@property (nonatomic, strong) HomeRecommendAdsModel *adsModel;
@property (nonatomic, strong) HomeRecommendLotteriesModel *gameModel;
@property (nonatomic, strong) HomeRecommendLiveModel *liveModel;
@property (nonatomic, strong) HomeRecommendLongVideoModel *longVideoModel;
@property (nonatomic, strong) HomeRecommendLotteriesModel *lotteryModel;
@property (nonatomic, strong) HomeRecommendShortVideoModel *shortVideoModel;
@property (nonatomic, strong) HomeRecommendSkitModel *skitModel;

@end

NS_ASSUME_NONNULL_END
