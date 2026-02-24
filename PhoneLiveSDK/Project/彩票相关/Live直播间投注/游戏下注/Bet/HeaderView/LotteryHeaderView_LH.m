//
//  LotteryHeaderView_LH.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHeaderView_LH.h"
#import "BetAnimationView_LH.h"

@interface LotteryHeaderView_LH ()

@property (nonatomic, strong) BetAnimationView_LH *animationView;

@end

@implementation LotteryHeaderView_LH

- (void)setupView {
    [super setupView];
    
    self.animationView = [BetAnimationView_LH new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    self.showKeys = @[@"龙虎", @"龙虎_龙", @"龙虎_和", @"龙虎_虎"];
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
    
    NSArray <NSArray *> *array = LotteryResults(win[@"result"]);
    self.animationView.winValue = [NSString stringWithFormat:@"%@,%@", array.firstObject.firstObject, array.lastObject.firstObject];
    [self.animationView stopAnimation];
}

@end
