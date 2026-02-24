//
//  VideoPayAlertView.h
//  phonelive2
//
//  Created by vick on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoPayAlertView : UIView

@property (nonatomic, assign) NSInteger is_vip;
@property (nonatomic, assign) NSInteger coin_cost;
@property (nonatomic, assign) NSInteger ticket_cost;
@property (nonatomic, assign) NSInteger videoType; //1 短剧 2 短视频 3 长视频(电影) 4直播

@property (nonatomic, copy) void (^clickPayBlock)(NSInteger type);

@end

NS_ASSUME_NONNULL_END
