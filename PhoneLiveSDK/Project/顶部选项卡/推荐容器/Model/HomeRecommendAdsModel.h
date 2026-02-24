//
//  HomeRecommendAdsModel.h
//  phonelive2
//
//  Created by s5346 on 2024/7/3.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeRecommendAds : NSObject

@property (nonatomic, assign) NSInteger pos;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger show_type;


@end

@interface HomeRecommendAdsModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray<HomeRecommendAds *> *data;
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
