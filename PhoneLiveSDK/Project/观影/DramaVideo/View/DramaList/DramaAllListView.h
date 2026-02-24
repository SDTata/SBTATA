//
//  DramaAllListView.h
//  phonelive2
//
//  Created by s5346 on 2024/5/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DramaInfoModel.h"
#import "DramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DramaAllListViewDelegate <NSObject>

- (void)dramaAllListViewDelegateForSelect:(NSString*)videoId;
- (void)dramaAllListViewDelegateForClose;

@end

@interface DramaAllListView : UIView

@property(nonatomic, assign) id<DramaAllListViewDelegate> delegate;

- (void)updateData:(DramaInfoModel*)infoModel videoInfoModel:(NSArray<DramaVideoInfoModel*>*)videoInfoModels selectVideoId:(NSString*)videoId;

@end

NS_ASSUME_NONNULL_END
