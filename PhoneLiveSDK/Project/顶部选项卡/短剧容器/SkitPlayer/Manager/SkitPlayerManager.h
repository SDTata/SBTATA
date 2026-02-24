//
//  SkitPlayerManager.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkitVideoInfoModel.h"
#import "ZFPlayer.h"
#import "SkitHotModel.h"
#import "SkitPlayerVideoCell.h"

NS_ASSUME_NONNULL_BEGIN

#define SkitPlayerManagerAutoNextIfNeed @"skitPlayerManagerAutoNextIfNeed"
@protocol SkitPlayerManagerDelegate <NSObject>

- (void)skitPlayerManagerDelegateForEnd:(BOOL)isNext;
- (void)skitPlayerManagerDelegateForChat;
- (void)skitPlayerManagerDelegateStartPlayIndexPath:(NSIndexPath *)indexPath;
- (void)skitPlayerManagerDelegateForTapVoice:(BOOL)isMuted;
- (void)skitPlayerManagerDelegateForSkit;

@end

@interface SkitPlayerManager : NSObject
@property (nonatomic, strong, readonly) ZFPlayerController *player;
@property (nonatomic, weak, readonly) SkitVideoInfoModel* model;
@property (nonatomic, weak, readonly) HomeRecommendSkit* infoModel;
@property(nonatomic, weak) id<SkitPlayerManagerDelegate> delegate;

//- (instancetype)initWithScrollView:(UIScrollView *)scrollView containerViewTag:(NSInteger)containerViewTag;

- (void)setupVideoInfoWithCell:(SkitPlayerVideoCell *)cell model:(SkitVideoInfoModel*)model infoModel:(HomeRecommendSkit*)infoModel;
- (void)reset;
- (void)startPlayVideo;
- (void)pauseVideo;
- (void)pauseVideoFromSystem;
- (void)startPlayVideoFromSystem;

@end

NS_ASSUME_NONNULL_END
