//
//  MoviePlayerManager.h
//  phonelive2
//
//  Created by vick on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFPlayer.h"
#import "MovieHomeModel.h"

@protocol MoviePlayerManagerDelegate <NSObject>

- (void)moviePlayerManagerDelegatePlayFinish;
- (void)moviePlayerManagerDelegatePlayPortraitFullScreen;
- (void)moviePlayerManagerDelegatePlayTapTryAction:(NSInteger)type;
- (void)movieControlViewDelegateForTapVoice:(BOOL)isMuted;

@end

@interface MoviePlayerManager : NSObject

@property (nonatomic, strong, readonly) ZFPlayerController *player;
@property (nonatomic, strong) ShortVideoModel *videoModel;
@property (nonatomic, weak) id <MoviePlayerManagerDelegate> delegate;

- (instancetype)initWithContainerView:(UIView *)containerView;

- (void)playWithModel:(ShortVideoModel *)model;

- (void)reset;

- (void)play;

- (void)pause;

- (void)startTrying;

- (void)stopTrying;

- (void)closeTrying;

@end
