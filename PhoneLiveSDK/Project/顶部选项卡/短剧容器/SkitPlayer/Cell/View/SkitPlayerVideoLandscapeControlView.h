//
//  SkitPlayerVideoLandscapeControlView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "GKDYVideoSlider.h"
#import "GKDYTools.h"
#import "SkitVideoInfoModel.h"
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SkitPlayerVideoLandscapeControlViewDelegate <NSObject>
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapBack;
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapChat;
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapStar:(BOOL)isAdd;
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapAutoNext:(BOOL)open;
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapRetryLoadVideo;
- (void)skitPlayerVideoLandscapeControlViewDelegateForTapPlay:(BOOL)isPlay;

@end

@interface SkitPlayerVideoLandscapeControlView : UIView<ZFPlayerMediaControl>
@property(nonatomic, assign) id<SkitPlayerVideoLandscapeControlViewDelegate> delegate;
@property (nonatomic, strong) SkitVideoInfoModel *model;
@property (nonatomic, strong) HomeRecommendSkit *infoModel;
@property (nonatomic, strong) GKDYVideoSlider *slider;
- (void)changeAutoNext:(BOOL)open;
- (void)hiddenRetryButton:(BOOL)isHidden;
- (void)hiddenLoading:(BOOL)isHidden;

@end
NS_ASSUME_NONNULL_END
