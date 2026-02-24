//
//  LotteryCodeResultView_BJL.m
//  phonelive2
//
//  Created by vick on 2025/2/15.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryCodeResultView_BJL.h"
#import "LotteryResultView_BJL.h"

@interface LotteryCodeResultView_BJL ()

@property (nonatomic, strong) LotteryResultView_BJL *resultView;

@end

@implementation LotteryCodeResultView_BJL

- (void)setupView {
    [super setupView];
    
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    LotteryResultView_BJL *resultView = [LotteryResultView_BJL new];
    [self addSubview:resultView];
    self.resultView = resultView;
    [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-VKPX(40));
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
        make.left.mas_equalTo(0);
    }];
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    [super setResultModel:resultModel];
    self.resultView.resultModel = resultModel;
}

@end
