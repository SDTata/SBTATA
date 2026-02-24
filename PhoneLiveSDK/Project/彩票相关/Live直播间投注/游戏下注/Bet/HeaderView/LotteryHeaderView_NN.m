//
//  LotteryHeaderView_NN.m
//  phonelive2
//
//  Created by vick on 2023/12/12.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryHeaderView_NN.h"
#import "LotteryResultView_NN.h"

@interface LotteryHeaderView_NN ()

@property (nonatomic, strong) LotteryResultView_NN *blueResultView;
@property (nonatomic, strong) LotteryResultView_NN *redResultView;

@end

@implementation LotteryHeaderView_NN

- (LotteryResultView_NN *)blueResultView {
    if (!_blueResultView) {
        _blueResultView = [LotteryResultView_NN new];
        _blueResultView.type = NNLotteryResultTypeLeft;
        _blueResultView.startX = 110;
    }
    return _blueResultView;
}

- (LotteryResultView_NN *)redResultView {
    if (!_redResultView) {
        _redResultView = [LotteryResultView_NN new];
        _redResultView.type = NNLotteryResultTypeRight;
        _redResultView.startX = -30;
    }
    return _redResultView;
}

- (void)setupView {
    [super setupView];
    [self.codeView removeFromSuperview];
    
    /// 蓝方
    [self addSubview:self.blueResultView];
    [self.blueResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_centerX).offset(-5);
        make.centerY.mas_equalTo(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(137);
    }];
    
    /// 红方
    [self addSubview:self.redResultView];
    [self.redResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.blueResultView.mas_right).offset(10);
        make.height.width.centerY.mas_equalTo(self.blueResultView);
    }];
}

#pragma mark - 开始投注
- (void)doStart {
    [super doStart];
    
    [self.blueResultView hidePockerAnimation];
    [self.redResultView hidePockerAnimation];
}

#pragma mark - 结束投注
- (void)doStop {
    [super doStop];
    
    [self.blueResultView showPockerAnimation];
    [self.redResultView showPockerAnimation];
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)win {
    [super doWin:win];
    [self.popCodeView removeFromSuperview];
    
    BOOL isBlueWin = [win[@"winWays"] containsObject:YZMsg(@"OpenAward_NiuNiu_BlueWin")];
    NSArray *results = LotteryResults(win[@"result"]);
    
    [self.redResultView setupPockerView];
    [self.blueResultView setupPockerView];
    
    self.blueResultView.result = win[@"niu"][@"blue_niu"];
    self.blueResultView.pockers = results.firstObject;
    self.blueResultView.selected = isBlueWin;
    
    self.redResultView.result = win[@"niu"][@"red_niu"];
    self.redResultView.pockers = results.lastObject;
    self.redResultView.selected = !isBlueWin;
    
    vkGcdAfter(0.0, ^{
        [self.blueResultView openPockerAnimation];
        [self.redResultView openPockerAnimation];
    });
}

@end
