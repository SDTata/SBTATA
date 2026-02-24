//
//  StarAnimationView.m
//  phonelive2
//
//  Created by s5346 on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import "StarAnimationView.h"
#import "Lottie.h"

@interface StarAnimationView ()

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) LOTAnimationView *animView;

@end

@implementation StarAnimationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.iconImageView = [[UIImageView alloc] init];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconImageView.image = [ImageBundle imagewithBundleName:@"SkitStarIcon"];
        self.iconImageView.highlightedImage = [ImageBundle imagewithBundleName:@"SkitStarSelectedIcon"];
        [self addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        self.animView = [LOTAnimationView animationNamed:@"Animation - 1720771596977"];
        self.animView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.animView];
        self.animView.loopAnimation = NO;
        self.animView.hidden = NO;
        [self.animView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(2);
            make.size.equalTo(@92);
        }];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tap {
    if (self.iconImageView.isHighlighted) {
        self.iconImageView.highlighted = !self.iconImageView.isHighlighted;
        if (self.tapStarblock) {
            self.tapStarblock(self.iconImageView.isHighlighted);
        }
        return;
    }

    self.animView.hidden = NO;
    self.userInteractionEnabled = NO;
    WeakSelf
    [self.animView playWithCompletion:^(BOOL animationFinished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.userInteractionEnabled = YES;
        strongSelf.iconImageView.highlighted = !strongSelf.iconImageView.isHighlighted;
        if (strongSelf.tapStarblock) {
            strongSelf.tapStarblock(strongSelf.iconImageView.isHighlighted);
        }
        strongSelf.animView.hidden = YES;
    }];
}

- (BOOL)isStar {
    return self.iconImageView.isHighlighted;
}

- (void)star:(BOOL)isStar {
    self.iconImageView.highlighted = isStar;
}

@end
