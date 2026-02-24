//
//  HomeContainer.h
//  c700LIVE
//
//  Created by user on 2024/6/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKPagerVC.h"
#import "ShortVideoModel.h"

typedef NS_ENUM(NSInteger, HomeContainerType) {
    HomeContainerTypeRecommend,
    HomeContainerTypeShortVideo,
    HomeContainerTypeLongVideo,
    HomeContainerTypeShortSkit,
    HomeContainerTypeGame
};


@interface HomeContainer : VKPagerVC
- (void)setHiddenMenuAndSearchButton:(NSInteger)index;
- (void)showOrHideWobble;
- (void)handleRefreshOrBackToRecommend:(void (^)(BOOL success))completionBlock;
- (void)openShortVideo:(ShortVideoModel*)model;
- (void)changeCategory:(HomeContainerType)type;
@end

