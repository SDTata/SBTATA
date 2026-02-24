//
//  ShortVideoLandscapeControlView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "GKDYVideoSlider.h"
#import "ShortVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShortVideoLandscapeControlViewDelegate <NSObject>
- (void)shortVideoLandscapeControlViewDelegateForTapBack;
- (void)shortVideoLandscapeControlViewDelegateForTapChat;
- (void)shortVideoLandscapeControlViewDelegateForTapLike:(BOOL)isAdd;
- (void)shortVideoLandscapeControlViewDelegateForTapFollowAnchor;
- (void)shortVideoLandscapeControlViewDelegateForTapGotoAnchor;
- (void)shortVideoLandscapeControlViewDelegateForTapRetryLoadVideo;
- (void)shortVideoLandscapeControlViewDelegateForTapPlay:(BOOL)isPlay;
@end

@interface ShortVideoLandscapeControlView : UIView<ZFPlayerMediaControl>
@property(nonatomic, assign) id<ShortVideoLandscapeControlViewDelegate> delegate;
@property (nonatomic, strong) ShortVideoModel *model;
@property (nonatomic, strong) GKDYVideoSlider *slider;
- (void)hiddenRetryButton:(BOOL)isHidden;
- (void)hiddenLoading:(BOOL)isHidden;
@end

NS_ASSUME_NONNULL_END
