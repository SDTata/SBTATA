//
//  SkitAllListView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkitVideoInfoModel.h"
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SkitAllListViewDelegate <NSObject>

- (void)skitAllListViewDelegateForSelect:(NSString*)videoId;
- (void)skitAllListViewDelegateForClose;

@end

@interface SkitAllListView : UIView

@property(nonatomic, assign) id<SkitAllListViewDelegate> delegate;

- (void)updateData:(HomeRecommendSkit*)infoModel videoInfoModel:(NSArray<SkitVideoInfoModel*>*)videoInfoModels selectVideoId:(NSString*)videoId;

@end

NS_ASSUME_NONNULL_END
