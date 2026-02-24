//
//  ShortVideoTableViewCell.h
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortVideoPortraitControlView.h"
#import "ShortVideoModel.h"

@class ShortVideoManager;
NS_ASSUME_NONNULL_BEGIN

@interface ShortVideoTableViewCell : UITableViewCell

@property (nonatomic, strong, nullable) ShortVideoPortraitControlView *controlView;
@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, assign) CGFloat tabbarHeight;
@property(nonatomic, readonly) ShortVideoManager *manager;

- (instancetype)initWithTabbarHeight:(CGFloat)height style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)update:(ShortVideoModel*)model isShowCreateTime:(BOOL)isShow;
- (void)removePlayerManager;
@end

NS_ASSUME_NONNULL_END
