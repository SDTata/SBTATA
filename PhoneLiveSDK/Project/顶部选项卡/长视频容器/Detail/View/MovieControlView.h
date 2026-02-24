//
//  MovieControlView.h
//  phonelive2
//
//  Created by vick on 2024/7/16.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "ShortVideoModel.h"

@protocol MovieControlViewDelegate <NSObject>

- (void)movieControlViewDelegateForTapRetryLoadVideo;
- (void)movieControlViewDelegateForTapPortraitFullScreen;
- (void)movieControlViewDelegateForTapTryAction:(NSInteger)type;
- (void)movieControlViewDelegateForTapVoice:(BOOL)isMuted;

@end

@interface MovieControlView : UIView <ZFPlayerMediaControl>

@property (nonatomic, weak) id<MovieControlViewDelegate> delegate;

@property (nonatomic, strong) UIView *tryingFloatView;

@property (nonatomic, strong) ShortVideoModel *model;

- (void)hiddenFullScreen:(BOOL)isHidden;

- (void)hiddenRetryButton:(BOOL)isHidden;

- (void)startTrying;

- (void)stopTrying;

- (void)closeTrying;

@end
