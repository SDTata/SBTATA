//
//  LotteryCodeView_NN.m
//  phonelive2
//
//  Created by vick on 2023/12/12.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeView_NN.h"
#import "LotteryResultView_NN.h"

@interface LotteryCodeView_NN ()

@property (nonatomic, strong) LotteryResultView_NN *blueResultView;
@property (nonatomic, strong) LotteryResultView_NN *redResultView;

@end

@implementation LotteryCodeView_NN

- (LotteryResultView_NN *)blueResultView {
    if (!_blueResultView) {
        _blueResultView = [LotteryResultView_NN new];
        _blueResultView.type = NNLotteryResultTypeLeft;
        [self.stackView addArrangedSubview:_blueResultView];
        [_blueResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.width.mas_equalTo(86);
        }];
        
        [_blueResultView layoutIfNeeded];
        [_blueResultView setupPockerView];
        [_blueResultView openPocker];
    }
    return _blueResultView;
}

- (LotteryResultView_NN *)redResultView {
    if (!_redResultView) {
        _redResultView = [LotteryResultView_NN new];
        _redResultView.type = NNLotteryResultTypeRight;
        [self.stackView addArrangedSubview:_redResultView];
        [_redResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.width.mas_equalTo(86);
        }];
        
        [_redResultView layoutIfNeeded];
        [_redResultView setupPockerView];
        [_redResultView openPocker];
    }
    return _redResultView;
}

- (void)setupView {
    [super setupView];
    
    for (UIView *view in self.stackView.arrangedSubviews) {
        [self.stackView removeArrangedSubview:view];
    }
    
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.spacing = 5;
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    self.blueResultView.result = resultModel.vs[@"blue"][@"niu"];
    self.blueResultView.pockers = resultModel.vs[@"blue"][@"pai"];
    self.blueResultView.selected = !resultModel.who_win;
    
    self.redResultView.result = resultModel.vs[@"red"][@"niu"];
    self.redResultView.pockers = resultModel.vs[@"red"][@"pai"];
    self.redResultView.selected = resultModel.who_win;
}

- (void)setResultDict:(NSDictionary *)resultDict {
    NSArray *result_arr = [resultDict[@"result"] componentsSeparatedByString:@"|"];
    NSString *first = result_arr.firstObject;
    first = [first componentsSeparatedByString:@":"].lastObject;
    NSString *last = result_arr.lastObject;
    last = [last componentsSeparatedByString:@":"].lastObject;
    
    self.blueResultView.result = resultDict[@"niu"][@"blue_niu"];
    self.blueResultView.pockers = [first componentsSeparatedByString:@","];
    
    self.redResultView.result = resultDict[@"niu"][@"red_niu"];
    self.redResultView.pockers = [last componentsSeparatedByString:@","];
}

@end
