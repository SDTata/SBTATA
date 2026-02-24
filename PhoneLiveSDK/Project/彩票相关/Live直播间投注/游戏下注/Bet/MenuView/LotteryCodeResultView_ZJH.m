//
//  LotteryCodeResultView_ZJH.m
//  phonelive2
//
//  Created by vick on 2025/2/14.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryCodeResultView_ZJH.h"
#import "LotteryResultView_ZJH.h"

@interface LotteryCodeResultView_ZJH ()

@property (nonatomic, strong) LotteryResultView_ZJH *resultView;

@end

@implementation LotteryCodeResultView_ZJH

- (void)setupView {
    [super setupView];
    
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    LotteryResultView_ZJH *resultView = [LotteryResultView_ZJH new];
    [self addSubview:resultView];
    self.resultView = resultView;
    [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-VKPX(80));
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
