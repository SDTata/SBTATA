//
//  LotteryCodeResultView_LH.m
//  phonelive2
//
//  Created by vick on 2025/2/14.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryCodeResultView_LH.h"
#import "LotteryResultView_LH.h"

@interface LotteryCodeResultView_LH ()

@property (nonatomic, strong) LotteryResultView_LH *resultView;

@end

@implementation LotteryCodeResultView_LH

- (void)setupView {
    [super setupView];
    
    self.codeListView.setupStyleBlock = ^(BallView *ballView) {
        ballView.titleLabel.font = vkFontMedium(12);
        NSString *code = ballView.titleLabel.text;
        if ([code containsString:@"龙"]) {
            ballView.titleLabel.textColor = vkColorHex(0xFF0000);
        } else if ([code containsString:@"虎"]) {
            ballView.titleLabel.textColor = vkColorHex(0x00BA61);
        } else {
            ballView.titleLabel.textColor = vkColorHex(0xFFFFFF);
        }
    };
    
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    LotteryResultView_LH *resultView = [LotteryResultView_LH new];
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
