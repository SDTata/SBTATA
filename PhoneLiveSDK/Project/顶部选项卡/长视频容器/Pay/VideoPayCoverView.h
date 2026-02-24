//
//  VideoPayCoverView.h
//  phonelive2
//
//  Created by vick on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieHomeModel.h"

@interface VideoPayCoverView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, assign) NSInteger is_vip;
@property (nonatomic, assign) NSInteger coin_cost;
@property (nonatomic, assign) NSInteger ticket_cost;
@property (nonatomic, assign) NSInteger videoType; //1 短剧 2 短视频 3 长视频(电影) 4直播
@property (nonatomic, copy) void (^clickPayBlock)(NSInteger type);

- (instancetype)initWithFrame:(CGRect)frame videotype:(NSInteger)videotype;

- (void)refresh;

- (void)clickLockAction;

@end
