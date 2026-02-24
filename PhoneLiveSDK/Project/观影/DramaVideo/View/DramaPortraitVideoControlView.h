//
//  DramaPortraitVideoControlView.h
//  DramaTest
//
//  Created by s5346 on 2024/5/1.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "DramaVideoInfoModel.h"
#import "GKDYVideoSlider.h"
#import "DramaInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DramaPortraitVideoControlViewDelegate <NSObject>
- (void)dramaPortraitVideoControlViewDelegateForTapTicket;
- (void)dramaPortraitVideoControlViewDelegateForTapStar:(BOOL)isAdd;
- (void)dramaPortraitVideoControlViewDelegateForTapFullScreen;
- (void)dramaPortraitVideoControlViewDelegateForTapPay;
- (void)dramaPortraitVideoControlViewDelegateForTapAutoNext:(BOOL)open;
@end

@interface DramaPortraitVideoControlView : UIView<ZFPlayerMediaControl>
@property (nonatomic, weak) id<DramaPortraitVideoControlViewDelegate> delegate;
@property (nonatomic, strong) DramaVideoInfoModel *model;
@property (nonatomic, strong) DramaInfoModel *infoModel;
@property (nonatomic, strong) GKDYVideoSlider *slider;

- (void)hiddenPlayButton:(BOOL)isHidden;
- (void)hiddenFullScreen:(BOOL)isHidden;
- (void)updateCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime;
- (void)changeAutoNext:(BOOL)open;
@end

NS_ASSUME_NONNULL_END
