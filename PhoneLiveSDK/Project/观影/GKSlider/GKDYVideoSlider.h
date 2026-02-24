//
//  GKDYVideoSlider.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKSliderView.h"
#import "ZFPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoSlider : UIView

@property (nonatomic, strong) GKSliderView *sliderView;

@property (nonatomic, copy) void(^slideBlock)(BOOL isDragging);
@property (nonatomic, copy) void(^seekCompletionTime)(float time);
@property (nonatomic, copy) void(^tapEvent)(CGPoint point);

@property (nonatomic, weak) ZFPlayerController *player;

@property (nonatomic, assign) BOOL isDragging;

/// add
@property (nonatomic, assign) CGFloat smallSliderBtnHeight;
@property (nonatomic, assign) CGFloat smallSliderHeight;
@property (nonatomic, assign) CGFloat previewMargin;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval totalTime;

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)showSmallSlider;
- (void)showLargeSlider;

- (void)showLoading;
- (void)hideLoading;

- (void)showBriefTimeSlider:(CGFloat)second;
@end

NS_ASSUME_NONNULL_END
