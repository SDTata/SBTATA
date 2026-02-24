//
//  LotteryHeaderView_LHC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryHeaderView_LHC.h"
#import "BetAnimationView_LHC.h"

@interface LotteryHeaderView_LHC ()

@property (nonatomic, strong) BetAnimationView_LHC *animationView;

@end

@implementation LotteryHeaderView_LHC

- (void)setupView {
    [super setupView];
    self.codeView.textListView.hidden = NO;
    
    /// 六合彩动画
    self.animationView = [BetAnimationView_LHC new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(10);
    }];
    
    self.showAnimateTime = 3;
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
