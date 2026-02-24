//
//  LotteryHeaderView_YFKS.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHeaderView_YFKS.h"
#import "BetAnimationView_YFKS.h"

@interface LotteryHeaderView_YFKS ()

@property (nonatomic, strong) BetAnimationView_YFKS *animationView;

@end

@implementation LotteryHeaderView_YFKS

- (void)setupView {
    [super setupView];
    
    self.animationView = [BetAnimationView_YFKS new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(10);
    }];
    
    self.showKeys = @[@"猜总和"];
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
    
    self.animationView.winValue = win[@"result"];
    [self.animationView stopAnimation];
}

@end
