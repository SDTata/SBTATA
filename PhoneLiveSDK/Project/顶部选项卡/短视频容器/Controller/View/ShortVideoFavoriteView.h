//
//  ShortVideoFavoriteView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShortVideoFavoriteView : UIView

@property (nonatomic, assign) UIEdgeInsets touchExtendInsets;
@property (nonatomic, strong) UIImageView      *favoriteBefore;
@property (nonatomic, strong) UIImageView      *favoriteAfter;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) void (^tapLikeblock)(BOOL);

- (void)resetView;
- (BOOL)isLike;
- (void)like:(BOOL)isLike;
- (void)showLikeAnimation;
@end
