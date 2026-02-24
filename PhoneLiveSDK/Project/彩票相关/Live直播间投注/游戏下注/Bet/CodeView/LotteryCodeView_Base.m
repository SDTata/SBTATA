//
//  LotteryCodeView_Base.m
//  phonelive2
//
//  Created by vick on 2023/12/1.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeView_Base.h"
#import "LotteryCodeView_LHC.h"
#import "LotteryCodeView_SSC.h"
#import "LotteryCodeView_SC.h"
#import "LotteryCodeView_YFKS.h"
#import "LotteryCodeView_NN.h"
#import "LotteryCodeView_BJL.h"
#import "LotteryCodeView_ZJH.h"
#import "LotteryCodeView_LH.h"
#import "LotteryCodeView_ZP.h"

@implementation LotteryCodeView_Base

+ (instancetype)createWithType:(NSInteger)type {
    switch (BetType(type)) {
        case LotteryBetTypeLHC:
            return [LotteryCodeView_LHC new];
        case LotteryBetTypeSSC:
            return [LotteryCodeView_SSC new];
        case LotteryBetTypeSC:
            return [LotteryCodeView_SC new];
        case LotteryBetTypeYFKS:
            return [LotteryCodeView_YFKS new];
        case LotteryBetTypeNN:
            return [LotteryCodeView_NN new];
        case LotteryBetTypeBJL:
            return [LotteryCodeView_BJL new];
        case LotteryBetTypeZJH:
            return [LotteryCodeView_ZJH new];
        case LotteryBetTypeLH:
            return [LotteryCodeView_LH new];
        case LotteryBetTypeZP:
            return [LotteryCodeView_ZP new];
        default:
            return [LotteryCodeView_Base new];
    }
}

- (BallListView *)codeListView {
    if (!_codeListView) {
        _codeListView = [BallListView new];
    }
    return _codeListView;
}

- (BallListView *)textListView {
    if (!_textListView) {
        _textListView = [BallListView new];
        
        /// 结果样式配置
        _textListView.setupStyleBlock = ^(BallView *ballView) {
            NSString *code = ballView.titleLabel.text;
            if ([code isEqualToString:YZMsg(@"lobby_small")]) {
                [ballView setBackgroundColor: vkColorHex(0x00BA61)];
            } else if ([code isEqualToString:YZMsg(@"lobby_single")]) {
                [ballView setBackgroundColor: vkColorHex(0x00BA61)];
            } else if ([code isEqualToString:YZMsg(@"OpenAward_NiuNiu_Green")]) {
                [ballView setBackgroundColor: vkColorHex(0x00BA61)];
            } else if ([code isEqualToString:YZMsg(@"OpenAward_NiuNiu_Blue")]) {
                [ballView setBackgroundColor: vkColorHex(0x0066FF)];
            } else {
                [ballView setBackgroundColor: vkColorHex(0xFF0000)];
            }
        };
    }
    return _textListView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 5;
    stackView.alignment = UIStackViewAlignmentTrailing;
    [self addSubview:stackView];
    self.stackView = stackView;
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    [stackView addArrangedSubview:self.codeListView];
    [stackView addArrangedSubview:self.textListView];
}

- (void)setInset:(UIEdgeInsets)inset {
    _inset = inset;
    [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(inset);
    }];
}

- (void)setResultModel:(LotteryResultModel *)resultModel {
    _resultModel = resultModel;
    NSArray *codes = [resultModel.open_result componentsSeparatedByString:@","];
    self.codeListView.codes = [self setupCodes:codes];
    self.textListView.codes = [self setupTexts:resultModel.spare_2];
}

- (void)setResultDict:(NSDictionary *)resultDict {
    _resultDict = resultDict;
    NSArray *codes = [resultDict[@"result"] componentsSeparatedByString:@","];
    self.codeListView.codes = [self setupCodes:codes];
    self.textListView.codes = [self setupTexts:@[]];
}

- (NSArray *)setupCodes:(NSArray *)codes {
    return codes;
}

- (NSArray *)setupTexts:(NSArray *)texts {
    return texts;
}

@end
