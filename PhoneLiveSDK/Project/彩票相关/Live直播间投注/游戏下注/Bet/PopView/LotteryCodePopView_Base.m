//
//  LotteryCodePopView_Base.m
//  phonelive2
//
//  Created by vick on 2025/2/15.
//  Copyright © 2025 toby. All rights reserved.
//

#import "LotteryCodePopView_Base.h"
#import "LotteryResultView_LH.h"
#import "LotteryResultView_BJL.h"
#import "LotteryResultView_ZJH.h"

@interface LotteryCodePopView_Base ()

@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) LotteryCodeView_Base *codeView;

@end

@implementation LotteryCodePopView_Base

- (LotteryCodeView_Base *)codeView {
    if (!_codeView) {
        switch (BetType(self.lotteryType)) {
            case LotteryBetTypeLH:
                _codeView = [LotteryResultView_LH new];
                break;
            case LotteryBetTypeZJH:
                _codeView = [LotteryResultView_ZJH new];
                break;
            case LotteryBetTypeBJL:
                _codeView = [LotteryResultView_BJL new];
                break;
            default:
                _codeView = [LotteryCodeView_Base createWithType:self.lotteryType];
                break;
        }
        [self addSubview:_codeView];
        [_codeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.right.mas_equalTo(-10);
            make.left.mas_equalTo(10);
        }];
    }
    return _codeView;
}

- (void)setupView {
    self.layer.cornerRadius = 5;
    self.layer.borderColor = vkColorRGB(248, 194, 66).CGColor;
    self.layer.borderWidth = 2;
    self.backgroundColor = vkColorRGBA(0, 0, 0, 0.5);
    self.transform = CGAffineTransformMakeScale(1.4, 1.4);
    
//    UILabel *resultLabel = [UILabel new];
//    resultLabel.textColor = UIColor.redColor;
//    resultLabel.font = vkFont(14);
//    [self addSubview:resultLabel];
//    self.resultLabel = resultLabel;
//    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(0);
//        make.top.mas_equalTo(10);
//    }];
}

- (void)setResultDict:(NSDictionary *)resultDict {
    self.codeView.resultDict = resultDict;
}

- (void)setResult:(NSString *)result {
    self.resultLabel.text = result;
}

@end
