//
//  ShortVideoPortraitControlView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "GKDYVideoSlider.h"
#import "ShortVideoModel.h"
#import "VideoPayCoverView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShortVideoPortraitControlViewDelegate <NSObject>
- (void)shortVideoPortraitControlViewDelegateForTapChat;
- (void)shortVideoPortraitControlViewDelegateForTapLike:(BOOL)isLike;
- (void)shortVideoPortraitControlViewDelegateForTapFullScreen;
- (void)shortVideoPortraitControlViewDelegateForTapFollowAnchor;
- (void)shortVideoPortraitControlViewDelegateForTapGotoAnchor;
- (void)shortVideoPortraitControlViewDelegateForTapHashtag:(NSString*)hashtag;
- (void)shortVideoPortraitControlViewDelegateForTapRetryLoadVideo;
- (void)shortVideoPortraitControlViewDelegateForTapPlay:(BOOL)isPlay;
@end

@interface ShortVideoPortraitControlView : UIView<ZFPlayerMediaControl>

@property (nonatomic, weak) id<ShortVideoPortraitControlViewDelegate> delegate;
@property (nonatomic, strong) ShortVideoModel *model;
@property (nonatomic, strong) GKDYVideoSlider *slider;
@property (nonatomic, assign) CGFloat tabbarHeight;
@property (nonatomic, assign) BOOL showCreateTime;
@property (nonatomic, strong) VideoPayCoverView *payCoverView;
- (instancetype)initWithTabbarHeight:(CGFloat)height frame:(CGRect)frame;
- (void)hiddenPlayButton:(BOOL)isHidden;
- (void)hiddenFullScreen:(BOOL)isHidden;
- (void)updateCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void)hiddenRetryButton:(BOOL)isHidden;
- (void)hiddenLoading:(BOOL)isHidden;
- (void)updateShowPayStatus:(float)currentTime;
@end

NS_ASSUME_NONNULL_END
