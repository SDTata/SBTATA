//
//  SkitPlayerVideoPortraitControlView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "SkitHotModel.h"
#import "GKDYVideoSlider.h"
#import "SkitVideoInfoModel.h"
#import "VideoPayCoverView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SkitPlayerVideoPortraitControlViewDelegate <NSObject>
- (void)skitPlayerVideoPortraitControlViewDelegateForTapChat;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapStar:(BOOL)isAdd;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapFullScreen;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapAutoNext:(BOOL)open;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapRetryLoadVideo;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapVoice:(BOOL)isMuted;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapSkit;
- (void)skitPlayerVideoPortraitControlViewDelegateForTapPlay:(BOOL)isPlay;
@end

@interface SkitPlayerVideoPortraitControlView : UIView<ZFPlayerMediaControl>
@property (nonatomic, weak) id<SkitPlayerVideoPortraitControlViewDelegate> delegate;
@property (nonatomic, strong) SkitVideoInfoModel *model;
@property (nonatomic, strong) HomeRecommendSkit *infoModel;
@property (nonatomic, strong) GKDYVideoSlider *slider;
@property (nonatomic, strong) VideoPayCoverView *payCoverView;

- (void)hiddenPlayButton:(BOOL)isHidden;
- (void)hiddenFullScreen:(BOOL)isHidden;
- (void)updateCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void)changeAutoNext:(BOOL)open;
- (void)hiddenRetryButton:(BOOL)isHidden;
- (void)hiddenLoading:(BOOL)isHidden;
- (void)updateShowPayStatus:(float)currentTime;
- (void)handleSingleTapped;

@end

NS_ASSUME_NONNULL_END
