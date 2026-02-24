//
//  LotteryHeaderView_SSC.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryHeaderView_SSC.h"
#import "BetAnimationView_SSC.h"

@interface LotteryHeaderView_SSC ()

@property (nonatomic, strong) BetAnimationView_SSC *animationView;

@end

@implementation LotteryHeaderView_SSC

- (void)setupView {
    [super setupView];
    self.codeView.textListView.hidden = NO;
    
    /// 开奖号码背景
    UIImageView *codeBackView = [UIImageView new];
    codeBackView.image = [ImageBundle imagewithBundleName:@"ssc_code_bg"];
    [self addSubview:codeBackView];
    [self sendSubviewToBack:codeBackView];
    [codeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(self.codeView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    self.codeView.backgroundColor = UIColor.clearColor;
    
    /// 老虎机动画
    BetAnimationView_SSC *animationView = [BetAnimationView_SSC new];
    animationView.minLength = 5;
    [self addSubview:animationView];
    self.animationView = animationView;
    [animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(30);
    }];
    
    self.showAnimateTime = 1;
}

- (void)setBetModel:(LotteryBetModel *)betModel {
    [super setBetModel:betModel];
    
    NSString *result = betModel.lastResult.open_result;
    result = [result stringByReplacingOccurrencesOfString:@"," withString:@""];
    self.animationView.winValue = result;
    [self.animationView stopAnimation];
}

#pragma mark - 开始投注
- (void)doStart {
    [super doStart];
}

#pragma mark - 结束投注
- (void)doStop {
    [super doStop];
    
    self.animationView.winValue = [NSString stringWithFormat:@"%@", @(rand() % 5000)];
    [self.animationView startAnimation];
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)win {
    [super doWin:win];
    
    NSString *result = win[@"result"];
    result = [result stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    self.animationView.winValue = result;
    [self.animationView stopAnimation];
}

@end
