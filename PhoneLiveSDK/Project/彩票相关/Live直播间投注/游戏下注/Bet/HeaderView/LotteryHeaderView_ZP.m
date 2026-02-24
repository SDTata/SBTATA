//
//  LotteryHeaderView_ZP.m
//  phonelive2
//
//  Created by vick on 2024/1/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LotteryHeaderView_ZP.h"
#import "BetAnimationView_ZP.h"
#import "LotteryBetResultePopView.h"

@interface LotteryHeaderView_ZP ()

@property (nonatomic, strong) BetAnimationView_ZP *animationView;

@end

@implementation LotteryHeaderView_ZP

- (void)setupView {
    [super setupView];
    
    self.animationView = [BetAnimationView_ZP new];
    [self addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(10);
        make.width.height.mas_equalTo(110);
    }];
    
    self.showAnimateTime = 2;
}

- (void)setBetModel:(LotteryBetModel *)betModel {
    [super setBetModel:betModel];
    
    NSString *result = betModel.lastResult.open_result;
    self.animationView.winValue = [self resultPosition:result];
    [self.animationView stopAnimation];
}

#pragma mark - 开始投注
- (void)doStart {
    [super doStart];
    [self.animationView clear];
    UIView *view = [self viewWithTag:2345];
    [view removeFromSuperview];
}

#pragma mark - 结束投注
- (void)doStop {
    [super doStop];
    [self.animationView startAnimation];
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)win {
    [super doWin:win];
    [self.popCodeView removeFromSuperview];
    
    NSInteger index = [self resultPosition:win[@"result"]];
    self.animationView.winValue = index;
    [self.animationView stopAnimation];
    
    /// 悬浮开奖结果
    LotteryBetResultePopView *popView = [[LotteryBetResultePopView alloc]initWithFrame:CGRectMake(0, 0,300, 300)];
    [popView animationWithSelectonIndex:index];
    popView.tag = 2345;
    [self addSubview:popView];
    [popView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_bottom).offset(20);
        make.width.height.mas_equalTo(300);
    }];
}

- (NSInteger)resultPosition:(NSString *)str {
    NSArray * arr = @[@"0",@"32",@"15",@"4",@"19",@"21",@"2",@"25",@"17",@"34",@"6",@"27",@"13",@"36",@"11",@"30",@"8",@"23",@"10",@"5",@"24",@"16",@"33",@"1",@"20",@"14",@"31",@"9",@"22",@"18",@"29",@"7",@"28",@"12",@"35",@"3",@"26"];
    NSInteger index = [arr indexOfObject:str];
    return index;
}

@end
