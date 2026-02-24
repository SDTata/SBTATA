//
//  ExpandCommentVideoView.m
//  phonelive2
//
//  Created by s5346 on 2025/2/17.
//  Copyright © 2025 toby. All rights reserved.
//

#import "ExpandCommentVideoView.h"

@interface ExpandCommentVideoView()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@end

@implementation ExpandCommentVideoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.clipsToBounds = YES;
        [self addSubview:self.coverImageView];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self addSubview:self.blurEffectView];
        [self.blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)showBlueIfNeed:(BOOL)isShow {
    self.blurEffectView.hidden = !isShow;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (UIVisualEffectView *)blurEffectView {
    if (!_blurEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurEffectView.frame = CGRectMake(0, 0, _window_width, _window_height);
        _blurEffectView.alpha = 1.0;
        _blurEffectView.hidden = YES;
    }
    return _blurEffectView;
}

@end
