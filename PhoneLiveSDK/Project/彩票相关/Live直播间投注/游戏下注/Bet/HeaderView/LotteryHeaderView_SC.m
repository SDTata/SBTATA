//
//  LotteryHeaderView_SC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryHeaderView_SC.h"
#import "BetAnimationView_SC.h"

@interface LotteryHeaderView_SC ()

@property (nonatomic, strong) BetAnimationView_SC *animationView;

@end

@implementation LotteryHeaderView_SC

- (void)setupView {
    [super setupView];
    
    /// 赛车动画
    self.animationView = [BetAnimationView_SC new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(5);
    }];
    
    self.showAnimateTime = 4;
}

#pragma mark - 开始投注
- (void)doStart {
    [super doStart];
    [self.animationView clear];
}

#pragma mark - 结束投注
- (void)doStop {
    [super doStop];
    [self.animationView startCarAnimation];
}

/// 提前3秒播放红绿灯动画
- (void)doPreAnimate {
    [super doPreAnimate];
    [self.animationView startAnimation];
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)win {
    [super doWin:win];
    self.animationView.winValue = win[@"result"];
    [self.animationView stopAnimation];
}

@end
