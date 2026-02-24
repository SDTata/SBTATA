//
//  ShortVideoManager.h
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShortVideoModel.h"
#import "DramaProgressModel.h"
#import "ZFPlayer.h"
#import "ExpandCommentVideoView.h"

@class ShortVideoTableViewCell;
NS_ASSUME_NONNULL_BEGIN

#define DramaPlayerManagerAutoNextIfNeed @"DramaPlayerManagerAutoNextIfNeed"
@protocol ShortVideoPlayerManagerDelegate <NSObject>

- (void)shortVideoPlayerManagerDelegateForEnd:(BOOL)isNext;
- (void)shortVideoPlayerManagerDelegateForTapHashtag:(NSString*)hashtag;
- (void)shortVideoPlayerManagerDelegateForTapChat;
- (void)shortVideoPlayerManagerDelegateForTapGotoAnchor;
- (void)shortVideoPlayerManagerDelegateForTapLike;
@end

@interface ShortVideoManager : NSObject

@property (nonatomic, strong, readonly) ZFPlayerController *player;
@property (nonatomic, weak, readonly) ShortVideoModel* model;
@property(nonatomic, weak) id<ShortVideoPlayerManagerDelegate> delegate;

- (void)setupVideoInfoWithCell:(ShortVideoTableViewCell *)cell model:(ShortVideoModel*)mode isShowCreateTime:(BOOL)isShow;
- (void)showVideoInfoWithExpandCoverView:(ExpandCommentVideoView *)containerView model:(ShortVideoModel*)model;
- (void)hideVideoInfoWithExpandCoverView;
- (void)reset;
- (void)startPlayVideo;
- (void)pauseVideo;
- (void)stopVideo;
@end

NS_ASSUME_NONNULL_END
