//
//  BetAnimationView_ZJH.m
//  phonelive2
//
//  Created by vick on 2024/1/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "BetAnimationView_ZJH.h"
#import "LotteryBetView_ZJH.h"

@interface BetAnimationView_ZJH ()

@property (nonatomic, strong) LotteryBetView_ZJH *cardOneView;
@property (nonatomic, strong) LotteryBetView_ZJH *cardTwoView;
@property (nonatomic, strong) LotteryBetView_ZJH *cardThreeView;

@end

@implementation BetAnimationView_ZJH

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (LotteryBetView_ZJH *)cardOneView {
    if (!_cardOneView) {
        _cardOneView = [LotteryBetView_ZJH new];
        _cardOneView.type = ZJHLotteryBetViewTypeLeft;
        _cardOneView.startX = 100;
    }
    return _cardOneView;
}

- (LotteryBetView_ZJH *)cardTwoView {
    if (!_cardTwoView) {
        _cardTwoView = [LotteryBetView_ZJH new];
        _cardTwoView.type = ZJHLotteryBetViewTypeCenter;
        _cardTwoView.startX = 0;
    }
    return _cardTwoView;
}

- (LotteryBetView_ZJH *)cardThreeView {
    if (!_cardThreeView) {
        _cardThreeView = [LotteryBetView_ZJH new];
        _cardThreeView.type = ZJHLotteryBetViewTypeRight;
        _cardThreeView.startX = -100;
    }
    return _cardThreeView;
}

- (void)setupView {
    
    [self addSubview:self.cardOneView];
    [self addSubview:self.cardTwoView];
    [self addSubview:self.cardThreeView];
    
    [self.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:5 leadSpacing:0 tailSpacing:0];
    [self.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.height.mas_equalTo(90);
        make.width.mas_equalTo(100);
    }];
}

- (void)startAnimation {
    
}

- (void)stopAnimation {
    self.cardOneView.pockers = [self.winValue safeObjectWithIndex:0];
    self.cardTwoView.pockers = [self.winValue safeObjectWithIndex:1];
    self.cardThreeView.pockers = [self.winValue safeObjectWithIndex:2];
    self.cardOneView.result = [self.winTypes safeObjectWithIndex:0];
    self.cardTwoView.result = [self.winTypes safeObjectWithIndex:1];
    self.cardThreeView.result = [self.winTypes safeObjectWithIndex:2];
    [self.cardOneView openPockerAnimation];
    [self.cardTwoView openPockerAnimation];
    [self.cardThreeView openPockerAnimation];
}

- (void)clear {
    [self.cardOneView hidePockerAnimation];
    [self.cardTwoView hidePockerAnimation];
    [self.cardThreeView hidePockerAnimation];
    
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (!strongSelf) return;
        [strongSelf.cardOneView showPockerAnimation];
        [strongSelf.cardTwoView showPockerAnimation];
        [strongSelf.cardThreeView showPockerAnimation];
    });
}

@end
