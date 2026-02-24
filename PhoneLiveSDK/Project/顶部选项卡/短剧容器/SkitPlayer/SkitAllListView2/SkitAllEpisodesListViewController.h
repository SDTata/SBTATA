//
//  SkitAllEpisodesListViewController.h
//  phonelive2
//
//  Created by s5346 on 2025/3/18.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkitVideoInfoModel.h"
#import "SkitHotModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SkitAllEpisodesListViewControllerDelegate <NSObject>

- (void)SkitAllEpisodesListViewControllerDelegateForSelect:(NSString*)videoId;
- (void)SkitAllEpisodesListViewControllerDelegateForClose;

@end

@interface SkitAllEpisodesListViewController : UIViewController

@property(nonatomic, assign) id<SkitAllEpisodesListViewControllerDelegate> delegate;

- (void)updateData:(HomeRecommendSkit*)infoModel videoInfoModel:(NSArray<SkitVideoInfoModel*>*)videoInfoModels selectVideoId:(NSString*)videoId;

@end

NS_ASSUME_NONNULL_END
