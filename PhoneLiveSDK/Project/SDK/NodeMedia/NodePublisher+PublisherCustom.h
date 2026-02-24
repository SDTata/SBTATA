//
//  NodePublisher+PublisherCustom.h
//  QLive
//
//  Created by Co co on 28/12/23.
//  Copyright © 2023 Mingliang Chen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

#import <NodeMediaClient/NodeMediaClient.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NodePublisherCustomDelegate <NSObject>
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@interface NodePublisher (PublisherCustom)

@property (nonatomic, weak) id<NodePublisherCustomDelegate> customDelegate;



@end

NS_ASSUME_NONNULL_END
