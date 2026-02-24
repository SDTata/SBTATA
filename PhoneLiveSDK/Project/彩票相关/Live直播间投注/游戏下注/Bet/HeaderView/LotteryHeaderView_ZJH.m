//
//  LotteryHeaderView_ZJH.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHeaderView_ZJH.h"
#import "BetAnimationView_ZJH.h"

@interface LotteryHeaderView_ZJH ()

@property (nonatomic, strong) BetAnimationView_ZJH *animationView;

@end

@implementation LotteryHeaderView_ZJH

- (void)setupView {
    [super setupView];
    
    self.animationView = [BetAnimationView_ZJH new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(20);
    }];
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
    
    self.animationView.winTypes = win[@"zjh"][@"pai_type_str"];
    self.animationView.winValue = LotteryResults(win[@"result"]);
    [self.animationView stopAnimation];
}

@end
