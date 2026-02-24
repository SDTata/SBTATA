//
//  LotteryHeaderView_BJL.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHeaderView_BJL.h"
#import "BetAnimationView_BJL.h"

@interface LotteryHeaderView_BJL ()

@property (nonatomic, strong) BetAnimationView_BJL *animationView;

@end

@implementation LotteryHeaderView_BJL

- (void)setupView {
    [super setupView];
    
    self.animationView = [BetAnimationView_BJL new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(10);
        make.height.mas_equalTo(50);
    }];
    
    self.showAnimateTime = 2;
}

#pragma mark - 开始投注
- (void)doStart {
    [super doStart];
    [self.animationView clear];
}

#pragma mark - 结束投注
- (void)doStop {
    [super doStop];
    [self.animationView startAnimation];
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)win {
    [super doWin:win];
    self.chartValue = [win[@"winWays"] firstObject];
    
    self.animationView.winValue = LotteryResults(win[@"result"]);
    [self.animationView stopAnimation];
}

@end
