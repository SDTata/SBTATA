//
//  DramaLandscapeVideoControlView.h
//  DramaTest
//
//  Created by s5346 on 2024/5/14.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "DramaVideoInfoModel.h"
#import "GKDYVideoSlider.h"
#import "GKDYTools.h"
#import "DramaInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DramaLandscapeVideoControlViewDelegate <NSObject>
- (void)dramaLandscapeVideoControlViewDelegateForTapBack;
- (void)dramaLandscapeVideoControlViewDelegateForTapTicket;
- (void)dramaLandscapeVideoControlViewDelegateForTapStar:(BOOL)isAdd;
- (void)dramaLandscapeVideoControlViewDelegateForTapAutoNext:(BOOL)open;
@end

@interface DramaLandscapeVideoControlView : UIView<ZFPlayerMediaControl>
@property(nonatomic, assign) id<DramaLandscapeVideoControlViewDelegate> delegate;
@property (nonatomic, strong) DramaVideoInfoModel *model;
@property (nonatomic, strong) DramaInfoModel *infoModel;
@property (nonatomic, strong) GKDYVideoSlider *slider;
- (void)changeAutoNext:(BOOL)open;
@end

NS_ASSUME_NONNULL_END
