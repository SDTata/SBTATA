//
//  SkitAllEpisodesListView.h
//  phonelive2
//
//  Created by s5346 on 2025/3/16.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitVideoInfoModel.h"
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SkitAllEpisodesListViewDelegate <NSObject>

- (void)skitAllEpisodesListViewDelegateForSelect:(NSString*)videoId;
- (void)skitAllEpisodesListViewDelegateForClose;

@end

@interface SkitAllEpisodesListView : UIView

@property(nonatomic, assign) id<SkitAllEpisodesListViewDelegate> delegate;

- (void)updateData:(HomeRecommendSkit*)infoModel videoInfoModel:(NSArray<SkitVideoInfoModel*>*)videoInfoModels selectVideoId:(NSString*)videoId;

@end

NS_ASSUME_NONNULL_END
