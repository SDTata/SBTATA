//
//  LiveStreamViewCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotModel.h"

@class LiveStreamViewCell;
NS_ASSUME_NONNULL_BEGIN

@protocol LiveStreamViewCellDelegate <NSObject>

- (void)liveStreamViewCellDelegateForTapLiveStream:(hotModel*)model nplayer:(NodePlayer*)nplayer cell:(LiveStreamViewCell*)cell;

@end

@interface LiveStreamViewCell : UITableViewCell
@property(nonatomic, weak) id<LiveStreamViewCellDelegate> delegate;
- (void)update:(hotModel*)model;
//- (void)pause:(BOOL)isPause;
- (void)mute;
- (void)play;
- (void)setupNPlayer:(NodePlayer*)tempPlayer;
- (void)stop;
- (void)removePlayer;
@end

NS_ASSUME_NONNULL_END
